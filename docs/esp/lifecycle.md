# Lifecycle API

The ESP module is returned from `esp_lib.lua` and auto-loads when required.

## Public methods
- `ESP:Load(config?)` — resets and starts ESP with merged config overrides
- `ESP:Unload()` — stops runtime loop and destroys rendered artifacts
- `ESP:GetConfig()` — returns active config table

## Runtime behavior
- Uses `RenderStepped` for updates
- Supports a global unload hook: `getgenv().HydrogenESP_Unload`
