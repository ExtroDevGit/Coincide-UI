## Example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ExtroDevGit/Coincide-UI/refs/heads/main/lib.luau"))()

local Watermark = Library:Watermark({ Text = "Coincide | dev" });

local Window = Library:Window({ Width = 550, Height = 555, Title = "Coincide" });
local TabLegit    = Window:Tab({ Name = "legit" });
local TabRage     = Window:Tab({ Name = "rage" });
local TabPlayers  = Window:Tab({ Name = "players" });
local TabVisuals  = Window:Tab({ Name = "visuals" });
local TabMisc     = Window:Tab({ Name = "misc" });
local TabSettings = Window:Tab({ Name = "settings" });

local SecA = TabLegit:Section({ Name = "section", Side = "Left" });
SecA:Toggle({ Name = "Toggle",  Default = false, Tooltip = "A normal toggle" });
SecA:Toggle({ Name = "Toggle2", Default = true })
	:AddKeybind({ Default = Enum.KeyCode.F, Mode = "Toggle" });
SecA:Toggle({ Name = "Hold Aim", Default = false })
	:AddKeybind({ Default = Enum.KeyCode.LeftShift, Mode = "Hold" });
SecA:Toggle({ Name = "ESP", Default = true })
	:AddColorpicker({ Default = Color3.fromRGB(255, 80, 80) })
	:AddColorpicker({ Default = Color3.fromRGB(80, 255, 120) });
SecA:Toggle({ Name = "Toggle3", Default = false });

local KeybindList = Library:KeybindList({ Title = "Keybinds" });

SecA:Toggle({ Name = "Risky Option",   Default = true, Risk = "risky",   Tooltip = "This can get you banned" });
SecA:Toggle({ Name = "Warning Option", Default = true, Risk = "warning", Tooltip = "Use with caution" });
SecA:Slider({ Name = "Test Slider",   Min = 0, Max = 100, Default = 50, Tooltip = "Drag to adjust" });
SecA:Slider({ Name = "Test Slider 2", Min = 0, Max = 100, Default = 25 });
SecA:Dropdown({ Name = "Dropdown", Options = { "Value 1", "Value 2", "Value 3" }, Default = "Value 1" });
SecA:Dropdown({ Name = "Multi Dropdown", Multi = true, Options = { "ESP", "Tracers", "Boxes", "Names" }, Default = { "ESP", "Boxes" } });
SecA:Textbox({ Name = "Textbox", Placeholder = "type here...", Default = "" });
SecA:Keybind({ Name = "Aim Key",  Default = Enum.KeyCode.LeftShift, Mode = "Hold",   Tooltip = "Click to rebind, right-click to clear" });
SecA:Keybind({ Name = "Menu Key", Default = Enum.KeyCode.Insert,    Mode = "Toggle" });
SecA:Colorpicker({ Name = "Color", Default = Color3.fromRGB(57, 114, 236), Alpha = 1 });
SecA:Button({ Name = "Button", Callback = function() print("Button clicked") end });
SecA:Button({ Name = "Save", Callback = function() print("Save") end })
	:Button({ Name = "Load", Callback = function() print("Load") end });
SecA:Button({ Name = "Delete", Confirm = true, Callback = function() print("DELETED") end });

local SecB = TabLegit:Section({ Name = "section 2", Side = "Left" });

local SecC = TabLegit:Section({ Name = "section 3", Side = "Right" });
local Master = SecC:Toggle({ Name = "Master", Default = true });
SecC:Toggle({ Name = "Child Toggle", Default = false, Dependency = Master });
SecC:Slider({ Name = "Child Slider", Min = 0, Max = 100, Default = 50, Dependency = Master });




TabSettings:ApplySettings();

Library:Notify("Loaded!", 2);
```
