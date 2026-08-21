# Toggle

Boolean control with optional dependency, tooltip, risk label, keybind, and chained color pickers.

## Entry point
- `Section:Toggle({ Name, Default, Tooltip?, Risk?, Dependency?, Callback? })`

## Common chained helpers
- `Toggle:AddKeybind({ Default, Mode })`
- `Toggle:AddColorpicker({ Default, Alpha?, Callback? })`

## State
- `Get()`
- `Set(value)`
- `OnChange(callback)`
