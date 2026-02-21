# Kanata Layout Docs

This folder stores the visual documentation for the Kanata layout in
`kanata/.config/kanata/kanata.kbd`.

## Source of truth

- Behavior and key outputs: `kanata/.config/kanata/kanata.kbd`
- Visual layer diagrams: files in this folder (`*.png`)
- Diagram source files: Keyboard Layout Editor JSON files (`*.json`)

## Edit workflow

When you change Kanata layers, update both the config and diagrams.

1. Update `kanata/.config/kanata/kanata.kbd`
2. Update the matching diagram JSON in `kanata/docs/*.json`
3. Regenerate or re-export PNG diagrams in `kanata/docs/*.png`

## Diagram tool

The JSON format in this folder is for Keyboard Layout Editor (KLE):

- https://www.keyboard-layout-editor.com/

To edit a diagram:

1. Open KLE
2. Paste one of the JSON files from this folder into the Raw Data editor
3. Make layout/legend updates
4. Save updated JSON back to the same file
5. Export/update the matching PNG

## Current diagram files

- `Enthium Elegant Keymap.json` / `Enthium Elegant Keymap.png`
- `Enthium Elegant Keymap - Symbol.json` / `Enthium Elegant Keymap - Symbol.png`
- `Enthium Elegant Keymap - Nav.json` / `Enthium Elegant Keymap - Nav.png`
- `Enthium Elegant Keymap - Num.json` / `Enthium Elegant Keymap - Num.png`
- Composite/alternate images: `layers.png`, `base-layer.png`, `symbol-layer.png`, `cursor-layer.png`, `number-layer.png`, `Enthium Elegant Keymap - All Layers.png`
