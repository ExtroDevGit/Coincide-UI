## Example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ExtroDevGit/Coincide-UI/refs/heads/main/lib.luau"))()

local Watermark = Library:Watermark({ Text = "Coincide | dev" });

local Window = Library:Window({
    Width = 550,
    Height = 555,
    Title = "Coincide"
    }
);

local Preview = Library:PreviewWindow({
    Title = "Preview",
    Width = 240,
    Height = 277
});
Preview:PositionNextTo(Window);
Preview:SyncWithWindow(Window);

local PlayerList = Library:Playerlist({
    Title = "Players",
    Width = 240,
    Height = 276
});
PlayerList:PositionBelow(Preview);
PlayerList:SyncWithWindow(Window);

local Settings = Library:SettingsWindow({
    Title = "Settings",
    Width = 240,
    Height = 555
});
Settings:PositionNextTo(Window);
Settings:SyncWithWindow(Window);

local KeybindList = Library:KeybindList({
    Title = "Keybinds"
    }
);

local TabLegit    = Window:Tab({ Name = "legit" });
local TabRage     = Window:Tab({ Name = "rage" });
local TabPlayers  = Window:Tab({ Name = "players" });
local TabVisuals  = Window:Tab({ Name = "visuals" });
local TabMisc     = Window:Tab({ Name = "misc" });

local SecA = TabLegit:Section({
    Name = "section",
    Side = "Left"
    }
);

SecA:Toggle({
    Name = "Toggle",
    Default = false,
    Tooltip = "A normal toggle"
    }
);

SecA:Toggle({
    Name = "Toggle2",
    Default = true
    })
    :AddKeybind({
        Default = Enum.KeyCode.F,
        Mode = "Toggle"
    }
);

SecA:Toggle({
    Name = "Hold Aim",
    Default = false
    })
    :AddKeybind({
        Default = Enum.KeyCode.LeftShift,
        Mode = "Hold"
    }
);

SecA:Toggle({
    Name = "ESP",
    Default = true
    })
    :AddColorpicker({
        Default = Color3.fromRGB(255, 80, 80)
    })
    :AddColorpicker({
        Default = Color3.fromRGB(80, 255, 120)
    }
);

SecA:Toggle({
    Name = "Toggle3",
    Default = false
    }
);

SecA:Toggle({
    Name = "Risky Option",
    Default = true,
    Risk = "risky",
    Tooltip = "This can get you banned"
    }
);

SecA:Toggle({
    Name = "Warning Option",
    Default = true,
    Risk = "warning",
    Tooltip = "Use with caution"
    }
);

SecA:Slider({
    Name = "Test Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Tooltip = "Drag to adjust"
    }
);

SecA:Slider({
    Name = "Test Slider 2",
    Min = 0,
    Max = 100,
    Default = 25
    }
);

SecA:Dropdown({
    Name = "Dropdown",
    Options = {
        "Value 1",
        "Value 2",
        "Value 3"
        },
        Default = "Value 1"
	}
);

SecA:Dropdown({
    Name = "Multi Dropdown",
    Multi = true,
    Options = {
        "ESP",
        "Tracers",
        "Boxes",
        "Names"
        },
        Default = {
            "ESP",
            "Boxes"
        }
    }
);

SecA:Textbox({
    Name = "Textbox",
    Placeholder = "type here...",
    Default = ""
    }
);

SecA:Keybind({
    Name = "Aim Key",
    Default = Enum.KeyCode.LeftShift,
    Mode = "Hold",
    Tooltip = "Click to rebind, right-click to clear"
    }
);

SecA:Keybind({
    Name = "Menu Key",
    Default = Enum.KeyCode.Insert,
    Mode = "Toggle"
    }
);

SecA:Colorpicker({
    Name = "Color",
    Default = Color3.fromRGB(57, 114, 236),
    Alpha = 1
    }
);

SecA:Button({
    Name = "Button",
    Callback = function()
        print("Button clicked")
    end
    }
);

SecA:Button({
    Name = "Save",
    Callback = function()
        print("Save")
    end
    })
	:Button({
        Name = "Load",
        Callback = function()
            print("Load")
        end
    }
);

SecA:Button({
    Name = "Delete",
    Confirm = true,
    Callback = function()
        print("DELETED")
    end
    }
);

local SecB = TabLegit:Section({
    Name = "section 2",
    Side = "Left"
    }
);

local SecC = TabLegit:Section({
    Name = "section 3",
    Side = "Right"
    }
);

local Master = SecC:Toggle({
    Name = "Master",
    Default = true
    }
);

SecC:Toggle({
    Name = "Child Toggle",
    Default = false,
    Dependency = Master
    }
);

SecC:Slider({
    Name = "Child Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Dependency = Master
    }
);

local SecEsp  = TabVisuals:Section({
    Name = "ESP",
    Side = "Left"
    }
);

local SecPlayers = TabPlayers:Section({
    Name = "Controls",
    Side = "Left"
    }
);

SecPlayers:Button({
    Name = "Refresh List",
    Tooltip = "Manually re-scan current players",
    Callback = function()
        PlayerList:Refresh()
    end
    }
);

SecPlayers:Button({
    Name = "Destroy List",
    Confirm = true,
    Callback = function()
        PlayerList:Destroy()
    end
    }
);

SecEsp:Toggle({
    Name = "Enabled",
    Callback = function(S)
        Preview:Set("Enabled", S)
    end
    }
);

SecEsp:Toggle({
    Name = "Box",
        Callback = function(S)
            Preview:Set("Box", S)
        end
        }
    )
	:AddColorpicker({
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(C, A)
            Preview:Set("BoxColorHigh", C, A)
        end
        }
    )
	:AddColorpicker({
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(C, A)
            Preview:Set("BoxColorLow", C, A)
        end
    }
);

SecEsp:Toggle({
    Name = "Box Fill",
        Callback = function(S)
            Preview:Set("Fill", S)
        end
    })
	:AddColorpicker({
    Default = Color3.fromRGB(255, 255, 255),
        Callback = function(C, A)
            Preview:Set("FillColorHigh", C, A)
        end
    })
	:AddColorpicker({
    Default = Color3.fromRGB(255, 255, 255),
        Callback = function(C, A)
            Preview:Set("FillColorLow", C, A)
        end
    }
);

SecEsp:Toggle({
    Name = "Box Glow",
        Callback = function(S)
            Preview:Set("Glow", S)
        end
    })
	:AddColorpicker({
        Default = Color3.fromRGB(255, 255, 255),
            Callback = function(C, A)
                Preview:Set("GlowColorHigh", C, A)
        end
    }
);

SecEsp:Toggle({
    Name = "Healthbar",
        Callback = function(S)
            Preview:Set("Healthbar", S)
        end
    }
);

SecEsp:Toggle({
    Name = "Healthbar Text",
    Callback = function(S)
        Preview:Set("HealthbarText", S)
    end
    }
);

SecEsp:Toggle({
    Name = "Names",
        Callback = function(S)
            Preview:Set("Name", S)
        end
    })
	:AddColorpicker({
    Default = Color3.fromRGB(255, 255, 255),
        Callback = function(C)
            Preview:Set("NameColor", C)
        end
    }
);

SecEsp:Toggle({
    Name = "Distance",
        Callback = function(S)
            Preview:Set("Distance", S)
        end
    }
);

SecEsp:Toggle({
    Name = "Weapon",
        Callback = function(S)
            Preview:Set("Weapon", S)
        end
    }
);

SecEsp:Toggle({
    Name = "Flags",
        Callback = function(S)
            Preview:Set("Flags", S)
        end
    }
);

SecEsp:Slider({
    Name = "Box Rotation",
    Min = -180,
    Max = 180,
    Default = 90,
    Suffix = "°",
        Callback = function(V)
            Preview:Set("BoxRotation", V)
        end
    }
);

Settings:ApplySettings();

Library:Notify("Loaded!", 2);
```