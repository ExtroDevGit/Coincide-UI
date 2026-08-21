# Directories / Tracking Targets

Defines non-player targets to scan and render (vehicles, props, NPC groups, etc.).

## Entry structure
Each directory entry supports:
- `DisplayName`
- `Path`
- `Multiple`
- `Cheap`
- `NonHuman`
- `NoStatus`
- `Contains`
- `Names`
- `BlockNames` (optional)
- `Recursive` (optional)
- `Config` (optional per-target override)

## Notes
- Per-entry `Config` overrides global ESP settings for matching targets
- Useful for giving unique visuals to specific world objects
