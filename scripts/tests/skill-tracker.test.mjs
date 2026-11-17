import assert from "node:assert/strict"
import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs"
import { join } from "node:path"
import { test } from "node:test"

test("V2 skill hooks preserve history, project counts, audit records, and cleanup", async () => {
  const home = mkdtempSync("/tmp/opencode/skill-tracker-test-")
  const previousHome = process.env.HOME
  process.env.HOME = home

  try {
    const config = join(home, ".config/opencode")
    mkdirSync(config, { recursive: true })
    const dataPath = join(config, "skill-usage.json")
    writeFileSync(dataPath, JSON.stringify({
      version: 2,
      totalInvocations: 3,
      skills: { existing: { name: "existing", count: 3 } },
      projects: {},
    }))

    const { default: plugin } = await import("../../opencode-common/.config/opencode/plugins/skill-tracker/index.js")
    assert.equal(plugin.id, "skill-tracker")
    const hooks = new Map()
    const dispose = await plugin.setup({
      location: {
        directory: "/projects/example/packages/app",
        project: { id: "project-example", directory: "/projects/example", canonical: "/projects/example" },
      },
      tool: {
        async hook(name, callback) {
          hooks.set(name, callback)
        },
      },
    })

    const before = hooks.get("execute.before")
    const after = hooks.get("execute.after")
    const data = () => JSON.parse(readFileSync(dataPath, "utf8"))
    const audit = () => readFileSync(join(config, "skill-usage.audit.jsonl"), "utf8")
      .trim().split("\n").map((line) => JSON.parse(line))
    const call = (id, skill = "learning-mode") => ({
      tool: "skill", id, sessionID: "session-example", input: { id: skill },
    })

    await before({ tool: "read", input: { path: "README.md" } })
    await after({ tool: "read", status: "completed", result: {} })
    assert.equal(data().totalInvocations, 3)

    await before(call("call-success"))
    await after({ ...call("call-success"), status: "completed", result: { metadata: { duration: 25 } } })
    assert.equal(data().totalInvocations, 4)
    assert.equal(data().skills.existing.count, 3)
    assert.equal(data().skills["learning-mode"].count, 1)
    assert.equal(data().projects["/projects/example"].skills["learning-mode"].count, 1)
    assert.equal(audit()[0].durationMs, 25)
    assert.equal(audit()[0].success, true)
    assert.equal(audit()[0].callID, "call-success")
    assert.equal(audit()[0].projectId, "project-example")
    assert.equal(audit()[0].directory, "/projects/example/packages/app")

    await before(call("call-error"))
    await after({ ...call("call-error"), status: "error", error: { message: "Skill not found" } })
    assert.equal(data().totalInvocations, 5)
    assert.equal(audit()[1].success, false)
    assert.equal(data().skills["learning-mode"].recentInvocations[1].success, false)

    await Promise.all(Array.from({ length: 22 }, (_, i) => before(call(`call-${i}`))))
    assert.equal(data().totalInvocations, 27)
    assert.equal(data().skills["learning-mode"].recentInvocations.length, 20)
    const status = JSON.parse(readFileSync(join(config, "skill-tracker-status.json"), "utf8"))
    assert.equal(status.projectKey, "/projects/example")
    assert.equal(typeof status.pluginLoadedAt, "string")
    dispose()
  } finally {
    if (previousHome === undefined) delete process.env.HOME
    else process.env.HOME = previousHome
    rmSync(home, { recursive: true, force: true })
  }
})
