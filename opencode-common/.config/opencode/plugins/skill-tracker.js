import { appendFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs"
import os from "node:os"
import { basename, dirname } from "node:path"

const DATA_PATH = `${process.env.HOME}/.config/opencode/skill-usage.json`
const AUDIT_LOG_PATH = `${process.env.HOME}/.config/opencode/skill-usage.audit.jsonl`
const STATUS_PATH = `${process.env.HOME}/.config/opencode/skill-tracker-status.json`
const LOCK_DIR_PATH = `${process.env.HOME}/.config/opencode/skill-tracker.lock`
const LOCK_INFO_PATH = `${LOCK_DIR_PATH}/owner`
const DATA_VERSION = 2
const MAX_RECENT_INVOCATIONS = 20
const LOCK_RETRY_COUNT = 50
const LOCK_RETRY_DELAY_MS = 20
const LOCK_STALE_MS = 10_000

function createEmptyData() {
  return {
    version: DATA_VERSION,
    totalInvocations: 0,
    skills: {},
    projects: {},
  }
}

function normalizeData(raw) {
  const base = createEmptyData()

  if (!raw || typeof raw !== "object") {
    return base
  }

  return {
    version: DATA_VERSION,
    totalInvocations: typeof raw.totalInvocations === "number" ? raw.totalInvocations : 0,
    firstInvocationAt: raw.firstInvocationAt,
    lastInvocationAt: raw.lastInvocationAt,
    skills: raw.skills || {},
    projects: raw.projects || {},
  }
}

function ensureParentDir(filePath) {
  const dir = dirname(filePath)
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true })
}

function loadData() {
  try {
    return normalizeData(JSON.parse(readFileSync(DATA_PATH, "utf-8")))
  } catch {
    return createEmptyData()
  }
}

function saveData(data) {
  ensureParentDir(DATA_PATH)
  writeFileSync(DATA_PATH, JSON.stringify(data, null, 2))
}

function appendAuditLog(record) {
  ensureParentDir(AUDIT_LOG_PATH)
  appendFileSync(AUDIT_LOG_PATH, `${JSON.stringify(record)}\n`)
}

function saveStatus(status) {
  ensureParentDir(STATUS_PATH)
  writeFileSync(STATUS_PATH, JSON.stringify(status, null, 2))
}

async function sleep(ms) {
  await new Promise((resolve) => setTimeout(resolve, ms))
}

function readLockTimestamp() {
  try {
    return Number(readFileSync(LOCK_INFO_PATH, "utf-8"))
  } catch {
    return undefined
  }
}

async function withDataLock(fn) {
  ensureParentDir(LOCK_DIR_PATH)
  let acquired = false

  for (let attempt = 0; attempt < LOCK_RETRY_COUNT; attempt += 1) {
    try {
      mkdirSync(LOCK_DIR_PATH)
      acquired = true
      break
    } catch (error) {
      const isAlreadyLocked = error && typeof error === "object" && error.code === "EEXIST"

      if (!isAlreadyLocked) {
        throw error
      }

      const lockTimestamp = readLockTimestamp()
      if (lockTimestamp && Date.now() - lockTimestamp > LOCK_STALE_MS) {
        try {
          rmSync(LOCK_DIR_PATH, { recursive: true, force: true })
        } catch {
          // Another process still owns or replaced the lock.
        }
      }

      await sleep(LOCK_RETRY_DELAY_MS)
    }
  }

  if (!acquired || !existsSync(LOCK_DIR_PATH)) {
    throw new Error("Failed to acquire skill tracker data lock")
  }

  writeFileSync(LOCK_INFO_PATH, String(Date.now()))

  try {
    return await fn()
  } finally {
    try {
      rmSync(LOCK_DIR_PATH, { recursive: true, force: true })
    } catch {
      // Ignore lock cleanup failures.
    }
  }
}

async function updateData(mutator) {
  return withDataLock(async () => {
    const data = loadData()
    const result = await mutator(data)
    saveData(data)
    return result
  })
}

function toNonEmptyString(value, fallback) {
  return typeof value === "string" && value.trim().length > 0 ? value : fallback
}

function getProjectInfo(input) {
  const worktree = toNonEmptyString(input.worktree || input.project?.worktree, input.directory)
  const directory = toNonEmptyString(input.directory, worktree)
  const projectKey = worktree || directory
  const projectName = toNonEmptyString(input.project?.name, basename(projectKey) || projectKey)
  const projectId = toNonEmptyString(input.project?.id, projectKey)
  const host = toNonEmptyString(process.env.HOSTNAME || process.env.HOST, os.hostname())

  return {
    projectKey,
    projectName,
    projectId,
    directory,
    worktree,
    host,
  }
}

function ensureSkillEntry(data, skillName, now) {
  const existing = data.skills[skillName]
  if (existing) {
    existing.projects ||= {}
    existing.recentInvocations ||= []
    return existing
  }

  data.skills[skillName] = {
    name: skillName,
    count: 0,
    lastUsed: now,
    firstUsed: now,
    projects: {},
    recentInvocations: [],
  }

  return data.skills[skillName]
}

function ensureSkillProjectEntry(skillEntry, invocation) {
  const existing = skillEntry.projects[invocation.projectKey]
  if (existing) return existing

  skillEntry.projects[invocation.projectKey] = {
    projectKey: invocation.projectKey,
    projectName: invocation.projectName,
    projectId: invocation.projectId,
    directory: invocation.directory,
    worktree: invocation.worktree,
    count: 0,
    firstUsed: invocation.timestamp,
    lastUsed: invocation.timestamp,
  }

  return skillEntry.projects[invocation.projectKey]
}

function ensureProjectEntry(data, invocation) {
  const existing = data.projects[invocation.projectKey]
  if (existing) {
    existing.skills ||= {}
    return existing
  }

  data.projects[invocation.projectKey] = {
    key: invocation.projectKey,
    name: invocation.projectName,
    id: invocation.projectId,
    directory: invocation.directory,
    worktree: invocation.worktree,
    host: invocation.host,
    count: 0,
    firstUsed: invocation.timestamp,
    lastUsed: invocation.timestamp,
    skills: {},
  }

  return data.projects[invocation.projectKey]
}

function ensureProjectSkillEntry(projectEntry, skillName, now) {
  const existing = projectEntry.skills[skillName]
  if (existing) return existing

  projectEntry.skills[skillName] = {
    name: skillName,
    count: 0,
    firstUsed: now,
    lastUsed: now,
  }

  return projectEntry.skills[skillName]
}

function findRecentInvocationByCallID(entry, callID) {
  for (let i = entry.recentInvocations.length - 1; i >= 0; i -= 1) {
    const invocation = entry.recentInvocations[i]
    if (invocation.callID === callID) {
      return invocation
    }
  }

  return undefined
}

export const SkillTrackerPlugin = async ({ project, directory, worktree, client }) => {
  const projectInfo = getProjectInfo({ project, directory, worktree })
  const pendingInvocations = new Map()

  saveStatus({
    version: DATA_VERSION,
    pluginLoadedAt: new Date().toISOString(),
    host: projectInfo.host,
    projectKey: projectInfo.projectKey,
    projectName: projectInfo.projectName,
    projectId: projectInfo.projectId,
    directory: projectInfo.directory,
    worktree: projectInfo.worktree,
  })

  if (client?.app?.log) {
    await client.app.log({
      body: {
        service: "skill-tracker",
        level: "info",
        message: "Skill tracker plugin initialized",
        extra: {
          projectKey: projectInfo.projectKey,
          directory: projectInfo.directory,
        },
      },
    })
  }

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "skill") return

      const skillName = output.args?.name || "unknown"
      const now = new Date().toISOString()
      const invocation = {
        callID: input.callID,
        sessionID: input.sessionID,
        skillName,
        timestamp: now,
        ...projectInfo,
      }

      pendingInvocations.set(input.callID, invocation)

      await updateData((data) => {
        const skillEntry = ensureSkillEntry(data, skillName, now)
        const skillProjectEntry = ensureSkillProjectEntry(skillEntry, invocation)
        const projectEntry = ensureProjectEntry(data, invocation)
        const projectSkillEntry = ensureProjectSkillEntry(projectEntry, skillName, now)

        if (!data.firstInvocationAt) data.firstInvocationAt = now
        data.lastInvocationAt = now
        data.totalInvocations += 1

        skillEntry.count += 1
        skillEntry.lastUsed = now
        skillProjectEntry.count += 1
        skillProjectEntry.lastUsed = now

        projectEntry.count += 1
        projectEntry.lastUsed = now
        projectSkillEntry.count += 1
        projectSkillEntry.lastUsed = now

        skillEntry.recentInvocations.push({
          callID: invocation.callID,
          sessionID: invocation.sessionID,
          timestamp: invocation.timestamp,
          projectKey: invocation.projectKey,
          projectName: invocation.projectName,
          projectId: invocation.projectId,
          directory: invocation.directory,
          worktree: invocation.worktree,
          host: invocation.host,
        })

        if (skillEntry.recentInvocations.length > MAX_RECENT_INVOCATIONS) {
          skillEntry.recentInvocations = skillEntry.recentInvocations.slice(-MAX_RECENT_INVOCATIONS)
        }
      })
    },

    "tool.execute.after": async (input, output) => {
      if (input.tool !== "skill") return

      const pending = pendingInvocations.get(input.callID)
      const skillName = pending?.skillName || input.args?.name || "unknown"
      const completedAt = new Date().toISOString()
      const durationMs = typeof output.metadata?.duration === "number" ? output.metadata.duration : undefined
      let auditRecord

      await updateData((data) => {
        const skillEntry = data.skills[skillName]
        const recentInvocation = skillEntry ? findRecentInvocationByCallID(skillEntry, input.callID) : undefined

        if (recentInvocation) {
          if (durationMs != null) recentInvocation.durationMs = durationMs
          recentInvocation.success = true
        }

        auditRecord = {
          callID: input.callID,
          sessionID: input.sessionID,
          skill: skillName,
          timestamp: pending?.timestamp || recentInvocation?.timestamp || completedAt,
          completedAt,
          durationMs,
          success: true,
          host: pending?.host || recentInvocation?.host || projectInfo.host,
          projectKey: pending?.projectKey || recentInvocation?.projectKey || projectInfo.projectKey,
          projectName: pending?.projectName || recentInvocation?.projectName || projectInfo.projectName,
          projectId: pending?.projectId || recentInvocation?.projectId || projectInfo.projectId,
          directory: pending?.directory || recentInvocation?.directory || projectInfo.directory,
          worktree: pending?.worktree || recentInvocation?.worktree || projectInfo.worktree,
        }
      })

      appendAuditLog(auditRecord)

      pendingInvocations.delete(input.callID)
    },
  }
}
