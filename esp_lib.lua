if not LPH_OBFUSCATED then
	LPH_JIT = LPH_JIT or function(...) return ... end
	LPH_JIT_MAX = LPH_JIT_MAX or function(...) return ... end
	LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(...) return ... end
	LPH_NO_UPVALUES = LPH_NO_UPVALUES or function(f) return function(...) return f(...) end end
	LPH_ENCSTR = LPH_ENCSTR or function(...) return ... end
	LPH_ENCNUM = LPH_ENCNUM or function(...) return ... end
	LPH_ENCFUNC = LPH_ENCFUNC or function(func, key1, key2)
		if key1 ~= key2 then return print("LPH_ENCFUNC mismatch") end
		return func
	end
	LPH_CRASH = LPH_CRASH or function() return print(debug.traceback()) end
end

local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera
local WtS              = Camera.WorldToViewportPoint
local UIContainer      = gethui and gethui() or CoreGui
local BootstrapPlayers = Players
local LPHNoVirtualize  = LPH_NO_VIRTUALIZE
local ESP              = {}
local ChamsContainer, MeshChamsFolder, ScreenGui
local PlayerRemovingConnection, InputBeganConnection
local CurrentRunId = HttpService:GenerateGUID(false)
local version = "1.0"
print(version or "fail")

if getgenv().HydrogenESP_Unload then pcall(getgenv().HydrogenESP_Unload) end

local oldChams = UIContainer:FindFirstChild("HydrogenESP_Chams")
if oldChams then pcall(function() oldChams:Destroy() end) end

local oldMeshFolder = Workspace:FindFirstChild("HydrogenESP_MeshChams")
if oldMeshFolder then pcall(function() oldMeshFolder:Destroy() end) end

-- ─── Mesh-cham artifact detection ────────────────────────────────────────────
local function IsMeshChamArtifact(obj)
	if not obj then return false end
	if obj:GetAttribute("HydrogenESP_MeshCham") == true then return true end
	if obj:IsA("Model")    and obj.Name == "ChamShells"         then return true end
	if obj:IsA("BasePart") and obj.Name:match("^ChamShell_")    then return true end
	if obj:IsA("Highlight") and obj.Name == "ChamShellHighlight" then return true end
	return false
end

local function CleanupMeshChams(root)
	if not root then return end
	for _, obj in ipairs(root:GetDescendants()) do
		if IsMeshChamArtifact(obj) then pcall(function() obj:Destroy() end) end
	end
end

local function CleanupCharacterMeshChams(character)
	if not character then return end
	for _, child in ipairs(character:GetChildren()) do
		if IsMeshChamArtifact(child) then pcall(function() child:Destroy() end) end
	end
end

CleanupMeshChams(Workspace)
for _, player in ipairs(BootstrapPlayers:GetPlayers()) do
	CleanupCharacterMeshChams(player.Character)
end

-- ─── Root instance setup ─────────────────────────────────────────────────────
local function EnsureRootInstances()
	if not ChamsContainer or not ChamsContainer.Parent then
		ChamsContainer = Instance.new("Folder")
		ChamsContainer.Name = "HydrogenESP_Chams"
		ChamsContainer.Parent = UIContainer
	end
	if not MeshChamsFolder or not MeshChamsFolder.Parent then
		MeshChamsFolder = Instance.new("Folder")
		MeshChamsFolder.Name = "HydrogenESP_MeshChams"
		MeshChamsFolder.Parent = Workspace
	end
	if not ScreenGui or not ScreenGui.Parent then
		ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "HydrogenESP"
		ScreenGui.ResetOnSpawn = false
		ScreenGui.IgnoreGuiInset = true
		ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		getgenv().HydrogenESP_UI = ScreenGui
		local ok = pcall(function() ScreenGui.Parent = CoreGui end)
		if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	end
end

-- ─── DrawLine ────────────────────────────────────────────────────────────────
local labelStrokeMap = setmetatable({}, { __mode = "k" })
local DrawLine = LPHNoVirtualize(function(line, p1, p2, thickness, color)
	local diff  = p2 - p1
	local dist  = diff.Magnitude
	local angle = math.deg(math.atan2(diff.Y, diff.X))
	line.Size     = UDim2.new(0, math.floor(dist + 0.5), 0, thickness)
	line.Position = UDim2.new(0,
		math.floor(p1.X + diff.X/2 - dist/2 + 0.5), 0,
		math.floor(p1.Y + diff.Y/2 - thickness/2 + 0.5))
	line.Rotation         = angle
	line.BackgroundColor3 = color
	line.Visible          = true
end)

-- ─── ESPConfig ───────────────────────────────────────────────────────────────
local ESPConfig = {
	Enabled = false,
	Keybind = { Enabled = false, Key = Enum.KeyCode.B },
	Players = true, LocalPlayer = false,
	LimitFPS = 42,
	DynamicBoxes = false, DynamicBoxesCheap = false, DynamicBoxesIncludeAll = false,
	VisibilityCheckRate = 0.3,

	Boxes = false, BoxType = "Corner",
	BoxColor = Color3.fromRGB(255,255,255), BoxThickness = 1,
	Glow = false, GlowColor = Color3.fromRGB(255,255,255), GlowTransparency = 0.72, GlowGradient = false,
	Outlines = { Style = "None", Color = Color3.fromRGB(0,0,0), Thickness = 1 },

	BoxFill = {
		Enabled = false, Color = Color3.fromRGB(255,255,255), Transparency = 0.9,
		Gradient = {
			Enabled = true,
			Color1 = Color3.fromRGB(180,255,255), Color2 = Color3.fromRGB(0,255,255), Color3 = Color3.fromRGB(0,120,255),
			Rotation = 90, Animated = false, Speed = 125, Direction = "Right",
			Alpha1 = 0.1, Alpha2 = 0.3, Alpha3 = 0.5,
		},
	},

	HealthBar = {
		Enabled = false, Position = "Left", SideGap = 2, Width = 1,
		ShowText = false, TextFollowBar = false, HideWhenFullHP = false, FollowGradientColorText = true,
		Font = "Smallest Pixel-7", TextSize = 9,
		Outline = { Style = "Full", Color = Color3.fromRGB(0,0,0) },
		Gradient = {
			Enabled = true,
			Color1 = Color3.fromRGB(0,255,0), Color2 = Color3.fromRGB(255,255,0), Color3 = Color3.fromRGB(255,0,0),
		},
	},

	Names = false, TextSize = 12, TextColor = Color3.fromRGB(255,255,255),
	TextOutline = false, TextOutlineStyle = "Full", TextGap = 3, Font = "Proggy Clean",

	TeamIndicator = {
		Enabled = true, Position = "Right", UseTeamColor = false,
		Color = Color3.fromRGB(255,255,255), Compact = false, TextSize = 10,
	},
	FriendlyIndicator = {
		Enabled = true, Position = "Right", CheckTeam = false, CheckFriends = false,
		Text = "[F]", Color = Color3.fromRGB(0,255,0),
	},
	Weapon = {
		Enabled = false, Gap = 1, OutlineStyle = "Full", Font = "Proggy Clean", TextSize = 12,
		Color = Color3.fromRGB(255,255,255),
		InventoryPath = "ReplicatedStorage.Players.%NAME%.Inventory", UseToolFallback = false,
	},

	Flags = {
		Enabled = false, Position = "Right", Gap = 2, SideGap = 4, TextGap = 2,
		OutlineStyle = "Full", Font = "Smallest Pixel-7", TextSize = 9,
		Options = { Idle = false, Moving = true, Jumping = false, Swimming = false },
		Colors = {
			Idle    = Color3.fromRGB(255,255,255), Moving  = Color3.fromRGB(255,255,255),
			Jumping = Color3.fromRGB(255,255,255), Swimming = Color3.fromRGB(65,65,255),
		},
	},

	Skeleton = {
		Enabled = false, Color = Color3.fromRGB(255,255,255),
		Outline = true, OutlineColor = Color3.fromRGB(0,0,0),
		Gradient = { Enabled = true, Color1 = Color3.fromRGB(255,255,255), Color2 = Color3.fromRGB(100,200,255) },
	},

	OffScreenArrows = {
		Enabled = false, Size = 14, Color = Color3.fromRGB(255,255,255),
		OrbitRadius = 100, ArrowMode = "Camera", Outline = false, OutlineColor = Color3.fromRGB(0,0,0),
		Names    = { Enabled=false, Font="Smallest Pixel-7", TextSize=9, Color=Color3.fromRGB(255,255,255), Outline=true, OutlineColor=Color3.fromRGB(0,0,0), Side="Bottom", Gap=4 },
		Distance = { Enabled=false, Font="Smallest Pixel-7", TextSize=9, Color=Color3.fromRGB(255,255,255), Outline=false, OutlineColor=Color3.fromRGB(0,0,0), Side="Bottom", Gap=2 },
	},

	Distance = {
		Enabled = false, Unit = "Meters", StudsPerMeter = 3, Ending = "m",
		Gap = 3, OutlineStyle = "Full", Font = "Proggy Clean", TextSize = 12,
		Color = Color3.fromRGB(255,255,255),
	},

	Chams = {
		Enabled = false, Type = "MeshChams",
		Highlight   = { FillColor=Color3.fromRGB(255,255,255), FillTransparency=1, OutlineColor=Color3.fromRGB(255,255,255), OutlineTransparency=0, VisibleCheck=false },
		Adornment   = { Color=Color3.fromRGB(59,144,204), VisibleColor=Color3.fromRGB(59,204,90), Transparency=0.7, AlwaysOnTop=false, VisibleCheck=false },
		MeshChams   = { FillColor=Color3.fromRGB(59,144,204), FillTransparency=0.6, OutlineColor=Color3.fromRGB(255,255,255), OutlineTransparency=0, VisibleCheck=false },
	},

	Directories = {
		{
			DisplayName = "UAZ", Path = "workspace", Multiple = true,
			Cheap = false, NonHuman = true, NoStatus = true, Contains = {}, Names = { "UAZ" },
			Config = {
				Boxes = true, BoxColor = Color3.fromRGB(255,150,0), BoxThickness = 1.5,
				BoxFill = {
					Enabled = true, Color = Color3.fromRGB(255,150,0), Transparency = 0.8,
					Gradient = { Enabled=true, Color1=Color3.fromRGB(255,150,0), Color2=Color3.fromRGB(255,255,255), Color3=Color3.fromRGB(255,150,0), Rotation=0, Animated=true, Speed=90, Direction="Left" },
				},
				TextColor = Color3.fromRGB(255,200,50), TextSize = 12, TextOutline = true, TextGap = 4, Font = "Proggy Clean",
				Distance  = { Enabled=true, Unit="Meters", Ending="m", Gap=5, Color=Color3.fromRGB(255,200,50) },
				Chams = {
					Enabled = true, Type = "Highlight",
					Highlight = { FillColor=Color3.fromRGB(255,150,0), FillTransparency=0.7, OutlineColor=Color3.fromRGB(255,255,255), OutlineTransparency=1, VisibleCheck=false },
					Adornment = { Color=Color3.fromRGB(255,150,0), VisibleColor=Color3.fromRGB(0,255,0), Transparency=0.5, AlwaysOnTop=true, VisibleCheck=true },
				},
				Flags = {
					Enabled=true, Position="Left", SideGap=4, TextGap=2, Font="Smallest Pixel-7", TextSize=9,
					Options = { Idle=true, Moving=true },
					Colors  = { Idle=Color3.fromRGB(255,255,255), Moving=Color3.fromRGB(255,150,0) },
				},
				HealthBar = {
					Enabled=true, Position="Bottom", SideGap=2, Width=2, ShowText=true,
					TextFollowBar=true, HideWhenFullHP=false, FollowGradientColorText=true,
					Outline   = { Style="Full", Color=Color3.fromRGB(0,0,0) },
					Gradient  = { Enabled=true, Color1=Color3.fromRGB(0,255,0), Color2=Color3.fromRGB(255,255,0), Color3=Color3.fromRGB(255,0,0) },
				},
				Skeleton = { Enabled=false, Color=Color3.fromRGB(255,255,255), Outline=true, OutlineColor=Color3.fromRGB(0,0,0) },
			},
		},
	},
}

-- ─── Utility: deep copy / merge ──────────────────────────────────────────────
local function DeepCopy(tbl)
	if type(tbl) ~= "table" then return tbl end
	local copy = {}
	for k,v in pairs(tbl) do copy[k] = DeepCopy(v) end
	return copy
end

local function DeepMerge(base, override)
	if type(override) ~= "table" then return base end
	for k,v in pairs(override) do
		if type(v) == "table" and type(base[k]) == "table" then DeepMerge(base[k], v)
		else base[k] = v end
	end
	return base
end

local DefaultESPConfig = DeepCopy(ESPConfig)

-- ─── Helpers ─────────────────────────────────────────────────────────────────
local function CompactTeamName(teamName)
	if type(teamName) ~= "string" or teamName == "" then return "" end
	local parts = {}
	for part in teamName:gmatch("[^%s%-_]+") do
		if part ~= "" then table.insert(parts, part) end
	end
	if #parts == 0 then return teamName end
	if #parts == 1 then
		local s = parts[1]
		return (#s <= 4) and s:upper() or s:sub(1,1):upper()
	end
	local compact = {}
	for _, part in ipairs(parts) do table.insert(compact, part:sub(1,1):upper()) end
	return table.concat(compact)
end

local function ColorToHex(color)
	local r = math.clamp(math.floor(color.R*255+0.5),0,255)
	local g = math.clamp(math.floor(color.G*255+0.5),0,255)
	local b = math.clamp(math.floor(color.B*255+0.5),0,255)
	return string.format("#%02X%02X%02X",r,g,b)
end

-- ─── Fonts ───────────────────────────────────────────────────────────────────
local _fontMap = {
	["Proggy Clean"]      = Enum.Font.SourceSans,
	["Smallest Pixel-7"]  = Enum.Font.SourceSans,
	["Tahoma"]            = Enum.Font.SourceSans,
	["Minecraftia"]       = Enum.Font.SourceSans,
	["Tahoma Modern Bold"]= Enum.Font.SourceSansBold,
}
local FontsToDownload = {
	["Tahoma"]            = { TTF = "https://github.com/ExtroDevGit/Coincide-UI/raw/refs/heads/main/zekton_rg.ttf" },
	["Minecraftia"]       = { TTF = "https://github.com/ExtroDevGit/Coincide-UI/raw/refs/heads/main/Minecraftia.ttf" },
	["Smallest Pixel-7"]  = { TTF = "https://github.com/ExtroDevGit/Coincide-UI/raw/refs/heads/main/smallest_pixel-7.ttf" },
	["Proggy Clean"]      = { TTF = "https://github.com/ExtroDevGit/Coincide-UI/raw/refs/heads/main/ProggyClean.ttf" },
	["Tahoma Modern Bold"]= { TTF = "https://github.com/ExtroDevGit/Coincide-UI/raw/refs/heads/main/Tahoma-Modern-Bold.ttf" },
}
local ESPFonts = { Loaded = {} }
local FontsStillLoading = true

-- ─── Skeleton bone definitions ───────────────────────────────────────────────
local SKELETON_BONE_DEFS = {
	{"UpperTorso","LowerTorso"},{"Head","UpperTorso"},
	{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
	{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
	{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
	{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local function GetBonePosition(character, boneName)
	local part = character:FindFirstChild(boneName)
	if part then return part.Position end
	if boneName == "Head" then
		part = character:FindFirstChild("Head")
	elseif boneName == "UpperTorso" then
		part = character:FindFirstChild("Torso")
	elseif boneName == "LowerTorso" then
		part = character:FindFirstChild("Torso")
		if part then return (part.CFrame * CFrame.new(0,-1.2,0)).Position end
	elseif boneName == "LeftUpperArm" then
		part = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftArm")
	elseif boneName == "LeftLowerArm" then
		part = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftArm")
		if part then return (part.CFrame * CFrame.new(0,-0.8,0)).Position end
	elseif boneName == "LeftHand" then
		part = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftArm")
		if part then return (part.CFrame * CFrame.new(0,-1.5,0)).Position end
	elseif boneName == "RightUpperArm" then
		part = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightArm")
	elseif boneName == "RightLowerArm" then
		part = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightArm")
		if part then return (part.CFrame * CFrame.new(0,-0.8,0)).Position end
	elseif boneName == "RightHand" then
		part = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightArm")
		if part then return (part.CFrame * CFrame.new(0,-1.5,0)).Position end
	elseif boneName == "LeftUpperLeg" then
		part = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLeg")
	elseif boneName == "LeftLowerLeg" then
		part = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLeg")
		if part then return (part.CFrame * CFrame.new(0,-0.8,0)).Position end
	elseif boneName == "LeftFoot" then
		part = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLeg")
		if part then return (part.CFrame * CFrame.new(0,-1.5,0)).Position end
	elseif boneName == "RightUpperLeg" then
		part = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLeg")
	elseif boneName == "RightLowerLeg" then
		part = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLeg")
		if part then return (part.CFrame * CFrame.new(0,-0.8,0)).Position end
	elseif boneName == "RightFoot" then
		part = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLeg")
		if part then return (part.CFrame * CFrame.new(0,-1.5,0)).Position end
	end
	return part and part.Position
end

-- ─── Font loading ────────────────────────────────────────────────────────────
local FontLoadingCapable = writefile and isfile and getcustomasset

local function LoadCustomFont(Name, Link)
	if not FontLoadingCapable then return end
	local fn = Name:gsub("%s+","")
	local okDL, data = pcall(function() return game:HttpGet(Link) end)
	if not okDL or not data or data == "" then return end
	local okWrite = pcall(writefile, fn..".ttf", data)
	if not okWrite then return end
	local okConfig = pcall(function()
		local cfg = { name = fn, faces = {{ name="Regular", weight=400, style="normal", assetId=getcustomasset(fn..".ttf") }} }
		writefile(fn..".ttf.json", HttpService:JSONEncode(cfg))
	end)
	if not okConfig then return end
	local okLoad, font = pcall(Font.new, getcustomasset(fn..".ttf.json"), Enum.FontWeight.Regular)
	if okLoad and font then ESPFonts.Loaded[Name] = font end
end

local function AttemptLoadFonts()
	if not FontLoadingCapable then FontsStillLoading = false; return end
	for Name, Table in pairs(FontsToDownload) do
		if not ESPFonts.Loaded[Name] then LoadCustomFont(Name, Table.TTF) end
	end
	FontsStillLoading = false
	for Name in pairs(FontsToDownload) do
		if not ESPFonts.Loaded[Name] then FontsStillLoading = true; break end
	end
end

task.spawn(function() task.wait(1); AttemptLoadFonts() end)

-- ─── Config cache (version-based, no per-frame wipe) ─────────────────────────
local _defaultCfgCache    = {}
local _overrideCfgCaches  = setmetatable({}, { __mode = "k" })
local _cfgCache           = _defaultCfgCache
local _currentConfigOverride = nil

local _configVersion      = 0
local _defaultCfgVersion  = -1
local _overrideCfgVersions = setmetatable({}, { __mode = "k" })
local _splitCache         = {}   -- path → pre-split key array, never cleared

-- Call this whenever ESPConfig is mutated from outside
local function InvalidateConfigCache()
	_configVersion = _configVersion + 1
end

-- Called once per RuntimeStep — just resets the active-cache pointer, no wipe
local function BeginConfigCacheFrame()
	_cfgCache = _defaultCfgCache
	_currentConfigOverride = nil
end

local function GetCfg(path)
	local version = _configVersion
	if _currentConfigOverride then
		local ovc = _overrideCfgVersions[_currentConfigOverride]
		if ovc ~= version then
			_overrideCfgCaches[_currentConfigOverride] = {}
			_overrideCfgVersions[_currentConfigOverride] = version
		end
		_cfgCache = _overrideCfgCaches[_currentConfigOverride]
	else
		if _defaultCfgVersion ~= version then
			table.clear(_defaultCfgCache)
			_defaultCfgVersion = version
		end
		_cfgCache = _defaultCfgCache
	end

	local cached = _cfgCache[path]
	if cached ~= nil then return cached end

	local keys = _splitCache[path]
	if not keys then
		keys = path:split(".")
		_splitCache[path] = keys
	end

	-- Try override walk
	local current    = _currentConfigOverride
	local foundOver  = current ~= nil
	if foundOver then
		for _, key in ipairs(keys) do
			if type(current) == "table" and current[key] ~= nil then
				current = current[key]
			else
				foundOver = false
				break
			end
		end
	end
	if foundOver then
		_cfgCache[path] = current
		return current
	end

	-- Default walk
	local def = ESPConfig
	for _, key in ipairs(keys) do def = def[key] end
	_cfgCache[path] = def
	return def
end

-- ─── Module-level reused tables (no per-frame alloc) ─────────────────────────
local _leftTags       = {}
local _rightTags      = {}
local _bonePositions  = {}   -- reused every skeleton draw call

-- ─── Team tag cache (invalidate on team change, not every frame) ──────────────
local _teamTagCache    = {}
local _teamTagConns    = {}

local function GetTeamTag(player, compact, useTeamColor, fallbackColor)
	if not player.Team then return nil end
	local team   = player.Team
	local color  = useTeamColor and team.TeamColor.Color or fallbackColor
	local name   = team.Name
	local cached = _teamTagCache[player]
	if cached and cached.teamName == name and cached.color == color and cached.compact == compact then
		return cached.tag
	end
	local displayName = compact and CompactTeamName(name) or name
	local tag = string.format('<font color="%s">[%s]</font>', ColorToHex(color), displayName)
	_teamTagCache[player] = { teamName=name, color=color, compact=compact, tag=tag }
	if not _teamTagConns[player] then
		_teamTagConns[player] = player.AncestryChanged:Connect(function()
			_teamTagCache[player]  = nil
			if _teamTagConns[player] then
				_teamTagConns[player]:Disconnect()
				_teamTagConns[player] = nil
			end
		end)
	end
	return tag
end

-- ─── Variables ───────────────────────────────────────────────────────────────
local TrackedInstances = {}

-- ─── Instance path resolver ───────────────────────────────────────────────────
local function GetInstanceFromPath(path)
	local parts   = string.split(path,".")
	local current = game
	for _, partName in ipairs(parts) do
		if current == game and (partName == "Workspace" or partName == "workspace") then
			current = Workspace
		elseif current == game and partName == "Players" then
			current = Players
		else
			local found = current:FindFirstChild(partName)
			if found then current = found else return nil end
		end
	end
	return current ~= game and current or nil
end

-- ─── CreateLine ──────────────────────────────────────────────────────────────
local function CreateLine(parent)
	local line = Instance.new("Frame")
	line.BorderSizePixel  = 0
	line.BackgroundColor3 = ESPConfig.BoxColor
	line.Parent           = parent
	local outline = Instance.new("Frame")
	outline.BorderSizePixel  = 0
	outline.BackgroundColor3 = ESPConfig.Outlines.Color
	outline.ZIndex           = 0
	outline.Parent           = line
	return line, outline
end

-- ─── CreateESPObj ────────────────────────────────────────────────────────────
local CreateESPObj = LPHNoVirtualize(function(name)
	local espObj = {
		Visible = false, Lines = {}, Outlines = {},
		CornerLines = {}, CornerOutlines = {}, FlagLabels = {},
		LastVisCheck = 0, CachedModelVisible = true,
	}

	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Name   = "ESPObj"
	container.Parent = ScreenGui
	espObj.Container = container

	local boxFill = Instance.new("Frame")
	boxFill.BorderSizePixel = 0; boxFill.ZIndex = 0; boxFill.Visible = false
	boxFill.Parent = container
	espObj.BoxFill = boxFill

	local fillGradient = Instance.new("UIGradient")
	fillGradient.Parent = boxFill
	espObj.BoxFillGradient = fillGradient

	local glow = Instance.new("ImageLabel")
	glow.Name="Glow"; glow.Position=UDim2.new(0,-23,0,-23); glow.Size=UDim2.new(1,46,1,46)
	glow.BackgroundTransparency=1; glow.BorderSizePixel=0
	glow.Image="rbxassetid://18245826428"; glow.ImageColor3=Color3.fromRGB(255,255,255)
	glow.ImageTransparency=0.8; glow.ScaleType=Enum.ScaleType.Slice
	glow.SliceCenter=Rect.new(Vector2.new(21,21),Vector2.new(80,80))
	glow.Visible=false; glow.ZIndex=1; glow.Parent=container
	local glowGradient = Instance.new("UIGradient"); glowGradient.Rotation=90; glowGradient.Parent=glow
	espObj.Glow=glow; espObj.GlowGradient=glowGradient

	for i=1,4 do
		local l,o = CreateLine(container)
		espObj.Lines[i]=l; espObj.Outlines[i]=o
	end
	for i=1,8 do
		local l,o = CreateLine(container)
		l.Visible=false; o.Visible=false
		espObj.CornerLines[i]=l; espObj.CornerOutlines[i]=o
	end

	local function SetupLabel(label)
		label.BackgroundTransparency = 1
		label.Size        = UDim2.new(0,100,0,ESPConfig.TextSize)
		label.Font        = _fontMap[ESPConfig.Font] or Enum.Font.Code
		if ESPFonts.Loaded[ESPConfig.Font] then label.FontFace = ESPFonts.Loaded[ESPConfig.Font] end
		label.TextSize    = ESPConfig.TextSize
		label.TextColor3  = ESPConfig.TextColor
		label.TextStrokeTransparency = 1
		label.ZIndex      = 2
		label.Parent      = container
		local stroke = Instance.new("UIStroke")
		stroke.Thickness    = 1
		stroke.Color        = ESPConfig.TextOutlineColor or ESPConfig.Outlines.Color
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
		stroke.Enabled      = ESPConfig.TextOutline
		stroke.Parent       = label
		labelStrokeMap[label] = stroke
	end

	local nameText = Instance.new("TextLabel"); SetupLabel(nameText)
	nameText.TextYAlignment=Enum.TextYAlignment.Bottom; nameText.RichText=true
	nameText.Text=name; nameText.Visible=ESPConfig.Names
	espObj.Text=nameText
	espObj.TeamText=nil; espObj.TeamTextStroke=nil; espObj.FriendlyText=nil; espObj.FriendlyTextStroke=nil

	local distText = Instance.new("TextLabel"); SetupLabel(distText)
	distText.TextYAlignment=Enum.TextYAlignment.Top; distText.Visible=false
	espObj.DistanceText=distText

	local weaponText = Instance.new("TextLabel"); SetupLabel(weaponText)
	weaponText.TextYAlignment=Enum.TextYAlignment.Top; weaponText.Visible=false
	espObj.WeaponText=weaponText

	local healthBarOutline = Instance.new("Frame")
	healthBarOutline.BackgroundColor3=ESPConfig.Outlines.Color; healthBarOutline.BorderSizePixel=0
	healthBarOutline.Visible=false; healthBarOutline.ZIndex=1; healthBarOutline.Parent=container
	espObj.HealthBarOutline=healthBarOutline

	local healthBarContainer = Instance.new("Frame")
	healthBarContainer.BackgroundTransparency=1; healthBarContainer.ClipsDescendants=true
	healthBarContainer.BorderSizePixel=0; healthBarContainer.ZIndex=2; healthBarContainer.Parent=healthBarOutline
	espObj.HealthBarContainer=healthBarContainer

	local healthBar = Instance.new("Frame")
	healthBar.BackgroundColor3=Color3.fromRGB(255,255,255); healthBar.BorderSizePixel=0
	healthBar.ZIndex=2; healthBar.Parent=healthBarContainer
	espObj.HealthBar=healthBar

	local healthGradient = Instance.new("UIGradient")
	healthGradient.Enabled = ESPConfig.HealthBar.Gradient.Enabled
	healthGradient.Color   = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   ESPConfig.HealthBar.Gradient.Color1),
		ColorSequenceKeypoint.new(0.5, ESPConfig.HealthBar.Gradient.Color2),
		ColorSequenceKeypoint.new(1,   ESPConfig.HealthBar.Gradient.Color3),
	})
	healthGradient.Parent = healthBar
	espObj.HealthGradient = healthGradient

	local healthText = Instance.new("TextLabel"); SetupLabel(healthText)
	healthText.TextYAlignment=Enum.TextYAlignment.Center; healthText.ZIndex=3; healthText.Visible=false
	espObj.HealthText=healthText

	for i=1,5 do
		local flag = Instance.new("TextLabel"); SetupLabel(flag)
		flag.TextSize = ESPConfig.Flags.TextSize
		flag.Font     = _fontMap[ESPConfig.Flags.Font] or Enum.Font.Code
		if ESPFonts.Loaded[ESPConfig.Flags.Font] then flag.FontFace = ESPFonts.Loaded[ESPConfig.Flags.Font] end
		flag.Visible  = false
		espObj.FlagLabels[i] = flag
	end

	espObj.Bones={}; espObj.BoneOutlines={}
	for i=1,#SKELETON_BONE_DEFS do
		local outline=Instance.new("Frame"); outline.BorderSizePixel=0; outline.Visible=false; outline.ZIndex=1; outline.Parent=container
		local bone   =Instance.new("Frame"); bone.BorderSizePixel=0;    bone.Visible=false;    bone.ZIndex=2;   bone.Parent=container
		espObj.BoneOutlines[i]=outline; espObj.Bones[i]=bone
	end

	local arrowInner = Instance.new("TextLabel")
	arrowInner.BackgroundTransparency=1; arrowInner.Text="▲"
	arrowInner.TextColor3=ESPConfig.OffScreenArrows.Color; arrowInner.TextSize=ESPConfig.OffScreenArrows.Size
	arrowInner.Font=Enum.Font.SourceSans
	arrowInner.Size=UDim2.new(0,ESPConfig.OffScreenArrows.Size*2,0,ESPConfig.OffScreenArrows.Size*2)
	arrowInner.ZIndex=100; arrowInner.Visible=false; arrowInner.Parent=ScreenGui
	espObj.ArrowInner=arrowInner

	local arrowOutline = Instance.new("TextLabel")
	arrowOutline.BackgroundTransparency=1; arrowOutline.Text="▲"
	arrowOutline.TextColor3=ESPConfig.OffScreenArrows.OutlineColor
	arrowOutline.TextSize=ESPConfig.OffScreenArrows.Size+2; arrowOutline.Font=Enum.Font.SourceSans
	arrowOutline.Size=UDim2.new(0,(ESPConfig.OffScreenArrows.Size+2)*2,0,(ESPConfig.OffScreenArrows.Size+2)*2)
	arrowOutline.ZIndex=99; arrowOutline.Visible=false; arrowOutline.Parent=ScreenGui
	espObj.ArrowOutline=arrowOutline

	local function makeArrowLabel()
		local l=Instance.new("TextLabel")
		l.BackgroundTransparency=1; l.Size=UDim2.new(0,150,0,12)
		l.TextStrokeTransparency=1; l.ZIndex=110; l.TextColor3=Color3.fromRGB(255,255,255)
		l.Visible=false; l.Parent=ScreenGui
		local stroke=Instance.new("UIStroke"); stroke.Parent=l; labelStrokeMap[l]=stroke
		return l
	end
	espObj.ArrowName=makeArrowLabel(); espObj.ArrowDist=makeArrowLabel()
	espObj.Adornments={}; espObj.Highlight=nil

	espObj.Destroy = function()
		container:Destroy()
		if espObj.Highlight  then espObj.Highlight:Destroy() end
		if espObj.MeshShell  then espObj.MeshShell:Destroy() end
		for _, a in pairs(espObj.Adornments) do a:Destroy() end
		if espObj.ArrowInner  then espObj.ArrowInner:Destroy() end
		if espObj.ArrowOutline then espObj.ArrowOutline:Destroy() end
		if espObj.ArrowName   then espObj.ArrowName:Destroy() end
		if espObj.ArrowDist   then espObj.ArrowDist:Destroy() end
	end
	return espObj
end)

-- ─── UpdateESPObj ────────────────────────────────────────────────────────────
local UpdateESPObj = LPHNoVirtualize(function(
	espObj, position, size, name, distanceStuds,
	instance, resolvedHumanoid,        -- humanoid pre-resolved by caller
	isCheap, nonHuman, noStatus, configOverride, onScreen
)
	-- Set active config
	_currentConfigOverride = configOverride
	if configOverride then
		local ovc = _overrideCfgVersions[configOverride]
		if ovc ~= _configVersion then
			_overrideCfgCaches[configOverride] = {}
			_overrideCfgVersions[configOverride] = _configVersion
		end
		_cfgCache = _overrideCfgCaches[configOverride]
		if not _cfgCache then _cfgCache = {}; _overrideCfgCaches[configOverride] = _cfgCache end
	else
		if _defaultCfgVersion ~= _configVersion then
			table.clear(_defaultCfgCache); _defaultCfgVersion = _configVersion
		end
		_cfgCache = _defaultCfgCache
	end

	local _now    = tick()
	local humanoid = resolvedHumanoid   -- use pre-resolved value

	-- Resolve playerOwner once
	local playerOwner = (not nonHuman and instance:IsA("Model"))
		and Players:GetPlayerFromCharacter(instance) or nil

	-- ── Chams ──────────────────────────────────────────────────────────────
	local isDead       = (humanoid and humanoid.Health <= 0)
	local chamsEnabled = GetCfg("Chams.Enabled")
	if chamsEnabled and not isDead then
		local chamType = GetCfg("Chams.Type")

		if chamType == "Highlight" and (instance:IsA("Model") or instance:IsA("BasePart")) then
			if espObj.MeshShell then espObj.MeshShell:Destroy(); espObj.MeshShell=nil; espObj.MeshHighlight=nil end
			if not espObj.Highlight then espObj.Highlight = Instance.new("Highlight") end
			local h = espObj.Highlight
			h.Parent             = ChamsContainer
			h.Adornee            = instance
			h.FillColor          = GetCfg("Chams.Highlight.FillColor")
			h.FillTransparency   = GetCfg("Chams.Highlight.FillTransparency")
			h.OutlineColor       = GetCfg("Chams.Highlight.OutlineColor")
			h.OutlineTransparency= GetCfg("Chams.Highlight.OutlineTransparency")
			h.DepthMode          = GetCfg("Chams.Highlight.VisibleCheck") and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
			h.Enabled            = true
			if espObj.Adornments then for _, a in pairs(espObj.Adornments) do a.Visible=false end end

		elseif chamType == "Adornment" then
			if espObj.Highlight then espObj.Highlight:Destroy(); espObj.Highlight=nil end
			if espObj.MeshShell then espObj.MeshShell:Destroy(); espObj.MeshShell=nil; espObj.MeshHighlight=nil end

			local parts    = instance:IsA("Model") and instance:GetChildren() or {instance}
			local idx      = 0
			local visCheck = GetCfg("Chams.Adornment.VisibleCheck")
			local visRate  = GetCfg("VisibilityCheckRate") or 0.1
			local shouldUpdate = (_now - (espObj.LastVisCheck or 0)) > visRate

			if visCheck and shouldUpdate then
				espObj.LastVisCheck = _now
				local ignore = {UIContainer}
				if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
				if instance:IsA("Model") then
					for _, v in ipairs(instance:GetDescendants()) do table.insert(ignore,v) end
				else table.insert(ignore, instance) end
				local root = instance:IsA("Model")
					and (instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChildWhichIsA("BasePart"))
					or instance
				if root and root:IsA("BasePart") then
					espObj.CachedModelVisible = (#Camera:GetPartsObscuringTarget({root.Position}, ignore) == 0)
				end
			end

			local finalColor = (visCheck and espObj.CachedModelVisible)
				and GetCfg("Chams.Adornment.VisibleColor") or GetCfg("Chams.Adornment.Color")
			for _, p in ipairs(parts) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					idx = idx + 1
					local a = espObj.Adornments[idx]
					if not a then
						a = Instance.new("BoxHandleAdornment"); a.Name="Cham"; a.Parent=ChamsContainer
						espObj.Adornments[idx] = a
					end
					a.Adornee    = p; a.Size = p.Size; a.Color3 = finalColor
					a.Transparency = GetCfg("Chams.Adornment.Transparency")
					a.AlwaysOnTop  = GetCfg("Chams.Adornment.AlwaysOnTop")
					a.ZIndex=10; a.Visible=true
				end
			end
			for i=idx+1,#espObj.Adornments do espObj.Adornments[i].Visible=false end

		elseif chamType == "MeshChams" then
			if not playerOwner then
				if espObj.MeshShell then espObj.MeshShell:Destroy(); espObj.MeshShell=nil; espObj.MeshHighlight=nil end
			else
				if espObj.Highlight then espObj.Highlight:Destroy(); espObj.Highlight=nil end
				if espObj.Adornments then for _, a in pairs(espObj.Adornments) do a.Visible=false end end

				if not espObj.MeshShell or not espObj.MeshShell.Parent then
					if espObj.MeshShell then espObj.MeshShell:Destroy(); espObj.MeshShell=nil; espObj.MeshHighlight=nil end
					CleanupCharacterMeshChams(instance)

					local r6Parts  = {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
					local r15Parts = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
					local hInst    = instance:FindFirstChild("Humanoid")
					local bodyParts = (hInst and hInst.RigType == Enum.HumanoidRigType.R15) and r15Parts or r6Parts

					local shellModel = Instance.new("Model")
					shellModel.Name = "ChamShells"
					shellModel:SetAttribute("HydrogenESP_MeshCham", true)
					shellModel:SetAttribute("HydrogenESP_RunId",    CurrentRunId)
					shellModel.Parent = instance

					for _, partName in ipairs(bodyParts) do
						local realPart = instance:FindFirstChild(partName)
						if realPart and realPart:IsA("BasePart") then
							local shell = Instance.new("Part")
							shell.Name = "ChamShell_"..partName
							shell:SetAttribute("HydrogenESP_MeshCham", true)
							shell:SetAttribute("HydrogenESP_RunId",    CurrentRunId)
							shell.Size=realPart.Size*1.015; shell.Transparency=0.9999999
							shell.CastShadow=false; shell.CanCollide=false; shell.CanQuery=false
							shell.CanTouch=false; shell.Anchored=false; shell.Massless=true
							shell.CFrame=realPart.CFrame; shell.Parent=shellModel
							local weld=Instance.new("Weld"); weld.Part0=shell; weld.Part1=realPart
							weld.C0=CFrame.new(); weld.C1=CFrame.new(); weld.Parent=shell
						end
					end

					local hl = Instance.new("Highlight")
					hl.Name="ChamShellHighlight"
					hl:SetAttribute("HydrogenESP_MeshCham",true)
					hl:SetAttribute("HydrogenESP_RunId",   CurrentRunId)
					hl.Adornee=shellModel; hl.Parent=shellModel
					espObj.MeshShell=shellModel; espObj.MeshHighlight=hl
				end

				if espObj.MeshHighlight then
					local hl = espObj.MeshHighlight
					hl.FillColor          = GetCfg("Chams.MeshChams.FillColor")
					hl.FillTransparency   = GetCfg("Chams.MeshChams.FillTransparency")
					hl.OutlineColor       = GetCfg("Chams.MeshChams.OutlineColor")
					hl.OutlineTransparency= GetCfg("Chams.MeshChams.OutlineTransparency")
					hl.DepthMode          = GetCfg("Chams.MeshChams.VisibleCheck") and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
					hl.Enabled            = true
				end
			end
		end
	else
		if espObj.Highlight then espObj.Highlight:Destroy(); espObj.Highlight=nil end
		if espObj.Adornments then for _, a in pairs(espObj.Adornments) do a.Visible=false end end
		if espObj.MeshShell  then espObj.MeshShell:Destroy(); espObj.MeshShell=nil; espObj.MeshHighlight=nil end
	end

	-- ── ApplyTextOutline (local helper) ────────────────────────────────────
	local function ApplyTextOutline(label, style, color)
		local stroke = labelStrokeMap[label] or label:FindFirstChildOfClass("UIStroke")
		if not stroke then return end
		if style == "None" then stroke.Enabled=false
		else stroke.Enabled=true; stroke.Thickness=1; stroke.Color=color or Color3.fromRGB(0,0,0) end
	end

	-- ── Off-screen arrows ──────────────────────────────────────────────────
	if espObj.ArrowInner and GetCfg("OffScreenArrows.Enabled") and instance:IsA("Model") then
		local rp = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChildWhichIsA("BasePart")
		if rp then
			local sp  = Camera:WorldToViewportPoint(rp.Position)
			local vp  = Camera.ViewportSize
			local cx,cy = vp.X/2, vp.Y/2
			local onVp = sp.Z>0 and sp.X>=0 and sp.X<=vp.X and sp.Y>=0 and sp.Y<=vp.Y
			if not onVp then
				local orbit = GetCfg("OffScreenArrows.OrbitRadius")
				local nx,ny,rot
				if GetCfg("OffScreenArrows.ArrowMode") == "Compass" then
					local playerRoot = LocalPlayer.Character and (
						LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or
						LocalPlayer.Character:FindFirstChild("Torso") or
						LocalPlayer.Character:FindFirstChildWhichIsA("BasePart"))
					local fromPos  = playerRoot and playerRoot.Position or Camera.CFrame.Position
					local toTarget = (Vector3.new(rp.Position.X,0,rp.Position.Z) - Vector3.new(fromPos.X,0,fromPos.Z)).Unit
					local rel      = playerRoot and playerRoot.CFrame:VectorToObjectSpace(toTarget) or toTarget
					nx,ny = rel.X, rel.Z; rot = math.deg(math.atan2(rel.Z,rel.X))+90
				else
					local dir     = (rp.Position - Camera.CFrame.Position).Unit
					local viewDir = Camera.CFrame:VectorToObjectSpace(dir)
					nx,ny = viewDir.X,-viewDir.Y; rot = math.deg(math.atan2(-viewDir.Y,viewDir.X))+90
				end
				local d = math.sqrt(nx*nx+ny*ny)
				if d > 0.001 then nx,ny = nx/d,ny/d else nx,ny = 0,-1 end
				local ax,ay = cx+nx*orbit, cy+ny*orbit
				local sz    = GetCfg("OffScreenArrows.Size")
				local col   = GetCfg("OffScreenArrows.Color")

				if GetCfg("OffScreenArrows.Outline") then
					espObj.ArrowOutline.TextSize   = sz+2
					espObj.ArrowOutline.TextColor3 = GetCfg("OffScreenArrows.OutlineColor")
					espObj.ArrowOutline.Position   = UDim2.new(0,ax-sz-2,0,ay-sz-2)
					espObj.ArrowOutline.Rotation   = rot; espObj.ArrowOutline.Visible=true
				else espObj.ArrowOutline.Visible=false end

				espObj.ArrowInner.Text="▲"; espObj.ArrowInner.Font=Enum.Font.SourceSans
				espObj.ArrowInner.TextSize=sz; espObj.ArrowInner.TextColor3=col
				espObj.ArrowInner.Position=UDim2.new(0,ax-sz,0,ay-sz)
				espObj.ArrowInner.Size=UDim2.new(0,sz*2,0,sz*2)
				espObj.ArrowInner.Rotation=rot; espObj.ArrowInner.Visible=true

				local textY = ay+sz+4

				if GetCfg("OffScreenArrows.Names.Enabled") and name and name ~= "" then
					local nFont=GetCfg("OffScreenArrows.Names.Font"); local nTxtSz=GetCfg("OffScreenArrows.Names.TextSize")
					local nFontObj=_fontMap[nFont] or Enum.Font.Code; local nFontLoaded=ESPFonts.Loaded[nFont]
					local nSide=GetCfg("OffScreenArrows.Names.Side"); local nGap=GetCfg("OffScreenArrows.Names.Gap") or 4
					local nCol=GetCfg("OffScreenArrows.Names.Color"); local nOut=GetCfg("OffScreenArrows.Names.Outline")
					local nOutCol=GetCfg("OffScreenArrows.Names.OutlineColor")
					espObj.ArrowName.Font=nFontObj; if nFontLoaded then espObj.ArrowName.FontFace=nFontLoaded end
					espObj.ArrowName.TextSize=nTxtSz; espObj.ArrowName.TextColor3=nCol; espObj.ArrowName.Text=name
					if nSide=="Top" then espObj.ArrowName.Position=UDim2.new(0,ax-75,0,ay-sz-nGap-nTxtSz)
					elseif nSide=="Left" then espObj.ArrowName.Position=UDim2.new(0,ax-sz-nGap-150,0,ay-6)
					elseif nSide=="Right" then espObj.ArrowName.Position=UDim2.new(0,ax+sz+nGap,0,ay-6)
					else espObj.ArrowName.Position=UDim2.new(0,ax-75,0,textY); textY=textY+nTxtSz+1 end
					ApplyTextOutline(espObj.ArrowName, nOut and "Full" or "None", nOutCol or Color3.fromRGB(0,0,0))
					espObj.ArrowName.Visible=true
				else espObj.ArrowName.Visible=false end

				if GetCfg("OffScreenArrows.Distance.Enabled") then
					local dFont=GetCfg("OffScreenArrows.Distance.Font"); local dTxtSz=GetCfg("OffScreenArrows.Distance.TextSize")
					local dFontObj=_fontMap[dFont] or Enum.Font.Code; local dFontLoaded=ESPFonts.Loaded[dFont]
					local dSide=GetCfg("OffScreenArrows.Distance.Side"); local dGap=GetCfg("OffScreenArrows.Distance.Gap") or 2
					local dCol=GetCfg("OffScreenArrows.Distance.Color"); local dOut=GetCfg("OffScreenArrows.Distance.Outline")
					local dOutCol=GetCfg("OffScreenArrows.Distance.OutlineColor")
					local dUnit=GetCfg("Distance.Unit")
					local dVal = (dUnit=="Meters") and math.floor(distanceStuds/GetCfg("Distance.StudsPerMeter")) or math.floor(distanceStuds)
					espObj.ArrowDist.Font=dFontObj; if dFontLoaded then espObj.ArrowDist.FontFace=dFontLoaded end
					espObj.ArrowDist.TextSize=dTxtSz; espObj.ArrowDist.TextColor3=dCol
					espObj.ArrowDist.Text=dVal..GetCfg("Distance.Ending")
					if dSide=="Top" then espObj.ArrowDist.Position=UDim2.new(0,ax-75,0,ay-sz-dGap-dTxtSz)
					elseif dSide=="Left" then espObj.ArrowDist.Position=UDim2.new(0,ax-sz-dGap-150,0,ay-6)
					elseif dSide=="Right" then espObj.ArrowDist.Position=UDim2.new(0,ax+sz+dGap,0,ay-6)
					else espObj.ArrowDist.Position=UDim2.new(0,ax-75,0,textY) end
					ApplyTextOutline(espObj.ArrowDist, dOut and "Full" or "None", dOutCol or Color3.fromRGB(0,0,0))
					espObj.ArrowDist.Visible=true
				else espObj.ArrowDist.Visible=false end
			else
				espObj.ArrowInner.Visible=false; espObj.ArrowOutline.Visible=false
				espObj.ArrowName.Visible=false;  espObj.ArrowDist.Visible=false
			end
		else
			espObj.ArrowInner.Visible=false; espObj.ArrowOutline.Visible=false
			espObj.ArrowName.Visible=false;  espObj.ArrowDist.Visible=false
		end
	else
		if espObj.ArrowInner then
			espObj.ArrowInner.Visible=false; espObj.ArrowOutline.Visible=false
			espObj.ArrowName.Visible=false;  espObj.ArrowDist.Visible=false
		end
	end

	if not onScreen or not position or not size then
		espObj.Container.Visible = false
		return
	end

	espObj.Container.Visible = true
	espObj.Container.ZIndex  = nonHuman and 1 or 10
	if GetCfg("Names") then espObj.Text.Text = name end

	local textOutlineStyle = GetCfg("TextOutlineStyle")
	if GetCfg("TextOutline") == false then textOutlineStyle = "None" end
	local textOutlineColor = GetCfg("TextOutlineColor") or GetCfg("Outlines.Color")

	local t        = GetCfg("BoxThickness")
	local o        = GetCfg("Outlines.Thickness")
	local textSize = GetCfg("TextSize")
	local textColor= GetCfg("TextColor")
	local fontName = GetCfg("Font")
	local fontObj  = _fontMap[fontName] or Enum.Font.Code
	local fontLoaded = ESPFonts.Loaded[fontName]
	local boxColor = GetCfg("BoxColor")

	espObj.Text.TextSize=textSize; espObj.Text.TextColor3=textColor; espObj.Text.Font=fontObj
	if fontLoaded then espObj.Text.FontFace=fontLoaded end
	ApplyTextOutline(espObj.Text, textOutlineStyle, textOutlineColor)

	do
		local distFont=GetCfg("Distance.Font"); local distFontObj=_fontMap[distFont] or Enum.Font.Code
		espObj.DistanceText.TextSize=GetCfg("Distance.TextSize") or textSize
		espObj.DistanceText.TextColor3=GetCfg("Distance.Color"); espObj.DistanceText.Font=distFontObj
		if ESPFonts.Loaded[distFont] then espObj.DistanceText.FontFace=ESPFonts.Loaded[distFont] end
		ApplyTextOutline(espObj.DistanceText, GetCfg("Distance.OutlineStyle") or textOutlineStyle, textOutlineColor)
	end
	do
		local wepFont=GetCfg("Weapon.Font"); local wepFontObj=_fontMap[wepFont] or Enum.Font.Code
		espObj.WeaponText.TextSize=GetCfg("Weapon.TextSize") or textSize
		espObj.WeaponText.TextColor3=GetCfg("Weapon.Color"); espObj.WeaponText.Font=wepFontObj
		if ESPFonts.Loaded[wepFont] then espObj.WeaponText.FontFace=ESPFonts.Loaded[wepFont] end
		ApplyTextOutline(espObj.WeaponText, GetCfg("Weapon.OutlineStyle") or textOutlineStyle, textOutlineColor)
	end

	local px,py = math.floor(position.X), math.floor(position.Y)
	local sx,sy = math.floor(size.X),     math.floor(size.Y)
	local x,y   = math.floor(px-sx/2),    math.floor(py-sy/2)

	local health,maxHealth,healthPercent = 100,100,1
	if humanoid then
		health=humanoid.Health; maxHealth=humanoid.MaxHealth
		healthPercent=math.clamp(health/maxHealth,0,1)
	end

	local topOffset,bottomOffset,leftOffset,rightOffset = 0,0,0,0
	if GetCfg("HealthBar.Enabled") and instance:IsA("Model") and humanoid then
		local hpPos     = GetCfg("HealthBar.Position")
		local thickness = GetCfg("HealthBar.Width")+2+GetCfg("HealthBar.SideGap")
		local textExtra = (GetCfg("HealthBar.ShowText") and health < maxHealth) and 20 or 0
		if     hpPos=="Top"    then topOffset    = thickness
		elseif hpPos=="Bottom" then bottomOffset = thickness
		elseif hpPos=="Left"   then leftOffset   = thickness+textExtra
		elseif hpPos=="Right"  then rightOffset  = thickness+textExtra end
	end

	if isCheap then
		for i=1,4 do espObj.Lines[i].Visible=false; espObj.Outlines[i].Visible=false end
		espObj.HealthBarOutline.Visible=false; espObj.HealthText.Visible=false; espObj.WeaponText.Visible=false
		for _, l in ipairs(espObj.FlagLabels) do l.Visible=false end
		local distUnit=GetCfg("Distance.Unit")
		local distVal=(distUnit=="Meters") and math.floor(distanceStuds/GetCfg("Distance.StudsPerMeter")) or math.floor(distanceStuds)
		espObj.Text.Text=name.." "..distVal..GetCfg("Distance.Ending")
		espObj.Text.Position=UDim2.new(0,px-50,0,py-(textSize/2))
		espObj.Text.Visible=GetCfg("Names"); espObj.DistanceText.Visible=false
		return
	end

	-- Normal lines
	espObj.Lines[1].Position=UDim2.new(0,x,0,y);          espObj.Lines[1].Size=UDim2.new(0,sx,0,t)
	espObj.Lines[2].Position=UDim2.new(0,x,0,y+sy);       espObj.Lines[2].Size=UDim2.new(0,sx+t,0,t)
	espObj.Lines[3].Position=UDim2.new(0,x,0,y);          espObj.Lines[3].Size=UDim2.new(0,t,0,sy)
	espObj.Lines[4].Position=UDim2.new(0,x+sx,0,y);       espObj.Lines[4].Size=UDim2.new(0,t,0,sy+t)

	local boxesEnabled   = GetCfg("Boxes")
	local boxType        = GetCfg("BoxType") or "Normal"
	local useCornerBoxes = boxType == "Corner"
	local outlineStyle   = GetCfg("Outlines.Style")
	if GetCfg("Outlines.Enabled") == false then outlineStyle="None" end
	local outlineColor      = GetCfg("Outlines.Color")
	local outlineThickness  = GetCfg("Outlines.Thickness")
	local hasOutline        = outlineStyle ~= "None"

	local _glowMinDim = math.min(sx,sy)
	if ESPConfig.Glow and boxesEnabled and _glowMinDim >= 20 then
		local glowPad=23; local pulse=math.sin(_now*3)*0.2
		espObj.Glow.Position=UDim2.new(0,x-glowPad,0,y-glowPad)
		espObj.Glow.Size=UDim2.new(0,sx+glowPad*2,0,sy+glowPad*2)
		espObj.Glow.ImageColor3=ESPConfig.GlowColor; espObj.Glow.Visible=true
		espObj.Glow.ImageTransparency=math.clamp((ESPConfig.GlowTransparency or 0.5)+pulse,0,0.95)
	else espObj.Glow.Visible=false end

	if useCornerBoxes then
		local cw=math.max(math.floor(sx*0.25),t*3); local ch=math.max(math.floor(sy*0.25),t*3)
		local cd={{x,y,cw,t},{x,y,t,ch},{x+sx-cw+t,y,cw,t},{x+sx,y,t,ch},{x,y+sy,cw,t},{x,y+sy-ch+t,t,ch},{x+sx-cw+t,y+sy,cw,t},{x+sx,y+sy-ch+t,t,ch}}
		for i=1,8 do
			espObj.CornerLines[i].Position=UDim2.new(0,cd[i][1],0,cd[i][2])
			espObj.CornerLines[i].Size=UDim2.new(0,cd[i][3],0,cd[i][4])
		end
	end

	for i=1,4 do
		espObj.Lines[i].Visible=boxesEnabled and not useCornerBoxes
		espObj.Outlines[i].Visible=boxesEnabled and hasOutline and not useCornerBoxes
		espObj.Outlines[i].Position=UDim2.new(0,-outlineThickness,0,-outlineThickness)
		espObj.Outlines[i].Size=UDim2.new(1,outlineThickness*2,1,outlineThickness*2)
		espObj.Outlines[i].BackgroundTransparency=0
		espObj.Lines[i].BackgroundColor3=boxColor; espObj.Outlines[i].BackgroundColor3=outlineColor
	end
	for i=1,8 do
		espObj.CornerLines[i].Visible=boxesEnabled and useCornerBoxes
		espObj.CornerOutlines[i].Visible=boxesEnabled and hasOutline and useCornerBoxes
		espObj.CornerOutlines[i].Position=UDim2.new(0,-outlineThickness,0,-outlineThickness)
		espObj.CornerOutlines[i].Size=UDim2.new(1,outlineThickness*2,1,outlineThickness*2)
		espObj.CornerOutlines[i].BackgroundTransparency=0
		espObj.CornerLines[i].BackgroundColor3=boxColor; espObj.CornerOutlines[i].BackgroundColor3=outlineColor
	end

	-- BoxFill
	local fill=espObj.BoxFill; local grad=espObj.BoxFillGradient
	if GetCfg("BoxFill.Enabled") and boxesEnabled then
		fill.Visible=true; fill.Position=UDim2.new(0,x,0,y); fill.Size=UDim2.new(0,sx,0,sy)
		if GetCfg("BoxFill.Gradient.Enabled") then
			fill.BackgroundTransparency=0; fill.BackgroundColor3=Color3.fromRGB(255,255,255); grad.Enabled=true
			grad.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,   GetCfg("BoxFill.Gradient.Color1")),
				ColorSequenceKeypoint.new(0.5, GetCfg("BoxFill.Gradient.Color2")),
				ColorSequenceKeypoint.new(1,   GetCfg("BoxFill.Gradient.Color3")),
			})
			grad.Transparency=NumberSequence.new({
				NumberSequenceKeypoint.new(0,   GetCfg("BoxFill.Gradient.Alpha1") or 0.1),
				NumberSequenceKeypoint.new(0.5, GetCfg("BoxFill.Gradient.Alpha2") or 0.3),
				NumberSequenceKeypoint.new(1,   GetCfg("BoxFill.Gradient.Alpha3") or 0.5),
			})
			local rot=GetCfg("BoxFill.Gradient.Rotation") or 90
			if GetCfg("BoxFill.Gradient.Animated") then
				local speed=GetCfg("BoxFill.Gradient.Speed")
				local dir=(GetCfg("BoxFill.Gradient.Direction")=="Left") and -1 or 1
				rot=(rot+(_now*speed*dir))%360
			end
			grad.Rotation=rot
		else
			grad.Enabled=false; fill.BackgroundColor3=GetCfg("BoxFill.Color")
			local fdc=math.clamp(1-(math.min(sx,sy)/60),0,0.45)
			fill.BackgroundTransparency=math.max(0,GetCfg("BoxFill.Transparency")-fdc)
		end
	else fill.Visible=false end

	-- Name tags (reuse module-level tables)
	local nameY    = y - textSize - (GetCfg("TextGap") or 0) - topOffset
	local teamOwner = instance:IsA("Model") and playerOwner or nil
	table.clear(_leftTags); table.clear(_rightTags)

	if GetCfg("TeamIndicator.Enabled") and teamOwner and teamOwner.Team then
		local teamTag = GetTeamTag(
			teamOwner,
			GetCfg("TeamIndicator.Compact"),
			GetCfg("TeamIndicator.UseTeamColor"),
			GetCfg("TeamIndicator.Color")
		)
		if teamTag then
			if GetCfg("TeamIndicator.Position")=="Left" then table.insert(_leftTags,teamTag)
			else table.insert(_rightTags,teamTag) end
		end
	end

	local isFriendly = false
	if teamOwner and GetCfg("FriendlyIndicator.Enabled") then
		if GetCfg("FriendlyIndicator.CheckTeam") and LocalPlayer.Team ~= nil and teamOwner.Team == LocalPlayer.Team then
			isFriendly = true
		end
		if not isFriendly and GetCfg("FriendlyIndicator.CheckFriends") then
			local ok, result = pcall(function() return LocalPlayer:IsFriendsWith(teamOwner.UserId) end)
			if ok and result then isFriendly=true end
		end
	end

	if isFriendly then
		local friendlyTag=string.format('<font color="%s">%s</font>',ColorToHex(GetCfg("FriendlyIndicator.Color")),GetCfg("FriendlyIndicator.Text"))
		if GetCfg("FriendlyIndicator.Position")=="Left" then table.insert(_leftTags,friendlyTag)
		else table.insert(_rightTags,friendlyTag) end
	end

	local finalNameText = name
	if #_leftTags > 0  then finalNameText = table.concat(_leftTags," ").." "..finalNameText end
	if #_rightTags > 0 then finalNameText = finalNameText.." "..table.concat(_rightTags," ") end

	if GetCfg("Names") then
		espObj.Text.Text=finalNameText; espObj.Text.Position=UDim2.new(0,px-50,0,nameY); espObj.Text.Visible=true
	else espObj.Text.Visible=false end

	local distGap=GetCfg("Distance.Gap") or 0
	local currentBottomY=y+sy+distGap+bottomOffset
	if GetCfg("Distance.Enabled") then
		espObj.DistanceText.Visible=true; espObj.DistanceText.Position=UDim2.new(0,px-50,0,currentBottomY)
		local distUnit=GetCfg("Distance.Unit")
		local distVal=(distUnit=="Meters") and math.floor(distanceStuds/GetCfg("Distance.StudsPerMeter")) or math.floor(distanceStuds)
		espObj.DistanceText.Text=distVal..GetCfg("Distance.Ending")
		currentBottomY=currentBottomY+(GetCfg("Distance.TextSize") or textSize)+(GetCfg("Weapon.Gap") or 0)
	else espObj.DistanceText.Visible=false end

	-- Weapon
	if GetCfg("Weapon.Enabled") then
		local weaponName=nil
		local holding=instance:FindFirstChild("Holding")
		if holding then
			if holding:IsA("ValueBase") then if holding.Value then weaponName=tostring(holding.Value) end
			else weaponName=holding.Name end
		end
		if (not weaponName or weaponName=="" or weaponName=="nil") and GetCfg("Weapon.UseToolFallback") then
			local tool=instance:FindFirstChildWhichIsA("Tool"); if tool then weaponName=tool.Name end
		end
		if weaponName and weaponName ~= "" and weaponName ~= "nil" then
			espObj.WeaponText.Visible=true; espObj.WeaponText.Text=weaponName
			espObj.WeaponText.Position=UDim2.new(0,px-50,0,currentBottomY)
		else espObj.WeaponText.Visible=false end
	else espObj.WeaponText.Visible=false end

	-- HealthBar
	if GetCfg("HealthBar.Enabled") and instance:IsA("Model") and humanoid then
		local hpPos=GetCfg("HealthBar.Position"); local isHorizontal=(hpPos=="Top" or hpPos=="Bottom")
		local hpWidth=GetCfg("HealthBar.Width"); local hpSideGap=GetCfg("HealthBar.SideGap")
		local hpTextFollowBar=GetCfg("HealthBar.TextFollowBar")
		local hpOutlineStyle=GetCfg("HealthBar.Outline.Style")
		if GetCfg("HealthBar.Outline.Enabled")==false then hpOutlineStyle="None" end
		espObj.HealthBarOutline.Visible=hpOutlineStyle ~= "None"
		espObj.HealthBarOutline.BackgroundTransparency=0
		espObj.HealthBarOutline.BackgroundColor3=GetCfg("HealthBar.Outline.Color")
		local barWidth
		if isHorizontal then
			barWidth=math.floor((sx+1)*healthPercent)
			espObj.HealthBarOutline.Size=UDim2.new(0,sx+3,0,hpWidth+2)
			if hpPos=="Top" then espObj.HealthBarOutline.Position=UDim2.new(0,x-1,0,y-o-hpSideGap-hpWidth-1)
			else espObj.HealthBarOutline.Position=UDim2.new(0,x-1,0,y+sy+o+hpSideGap) end
			espObj.HealthBarContainer.Size=UDim2.new(0,barWidth,0,hpWidth); espObj.HealthBarContainer.Position=UDim2.new(0,1,0,1)
			espObj.HealthBar.Size=UDim2.new(0,sx+1,0,hpWidth); espObj.HealthBar.Position=UDim2.new(0,0,0,0)
		else
			local barHeight=math.floor((sy+1)*healthPercent)
			espObj.HealthBarOutline.Size=UDim2.new(0,hpWidth+2,0,sy+3)
			if hpPos=="Left" then espObj.HealthBarOutline.Position=UDim2.new(0,x-o-hpSideGap-hpWidth-1,0,y-1)
			else espObj.HealthBarOutline.Position=UDim2.new(0,x+sx+o+hpSideGap,0,y-1) end
			espObj.HealthBarContainer.Size=UDim2.new(0,hpWidth,0,barHeight)
			espObj.HealthBarContainer.Position=UDim2.new(0,1,0,(sy+1)-barHeight+1)
			espObj.HealthBar.Size=UDim2.new(0,hpWidth,0,sy+1); espObj.HealthBar.Position=UDim2.new(0,0,0,-(sy+1-barHeight))
		end

		local gradientEnabled=GetCfg("HealthBar.Gradient.Enabled")
		local showText=GetCfg("HealthBar.ShowText")
		if GetCfg("HealthBar.HideWhenFullHP") and health>=maxHealth then showText=false end
		local followColorText=showText and GetCfg("HealthBar.FollowGradientColorText")
		local healthColor=Color3.fromHSV(healthPercent*0.3,1,1)

		if gradientEnabled and not isHorizontal then
			espObj.HealthGradient.Rotation=90; espObj.HealthBar.BackgroundColor3=Color3.fromRGB(255,255,255)
			if followColorText then
				if healthPercent>0.5 then
					local ratio=(1-healthPercent)*2
					healthColor=GetCfg("HealthBar.Gradient.Color1"):Lerp(GetCfg("HealthBar.Gradient.Color2"),ratio)
				else
					local ratio=(0.5-healthPercent)*2
					healthColor=GetCfg("HealthBar.Gradient.Color2"):Lerp(GetCfg("HealthBar.Gradient.Color3"),ratio)
				end
			end
		else espObj.HealthBar.BackgroundColor3=healthColor end

		if showText then
			espObj.HealthText.Visible=true; espObj.HealthText.Text=math.floor(health)
			espObj.HealthText.TextSize=GetCfg("HealthBar.TextSize")
			local hpFont=GetCfg("HealthBar.Font"); local hpFontObj=_fontMap[hpFont] or Enum.Font.Code
			espObj.HealthText.Font=hpFontObj
			if ESPFonts.Loaded[hpFont] then espObj.HealthText.FontFace=ESPFonts.Loaded[hpFont] end
			espObj.HealthText.TextColor3=followColorText and healthColor or GetCfg("TextColor")
			ApplyTextOutline(espObj.HealthText, hpOutlineStyle, textOutlineColor)

			if isHorizontal then
				barWidth=math.floor((sx+1)*healthPercent)
				local barLeftX=x+barWidth-1; local textY=espObj.HealthBarOutline.Position.Y.Offset
				espObj.HealthText.TextXAlignment=Enum.TextXAlignment.Center; espObj.HealthText.Size=UDim2.new(0,0,0,0)
				if hpTextFollowBar then espObj.HealthText.Position=UDim2.new(0,barLeftX,0,textY+(hpWidth/2)+1)
				else espObj.HealthText.Position=UDim2.new(0,x+sx,0,textY+(hpWidth/2)+1) end
			else
				local barHeight=math.floor((sy+1)*healthPercent)
				local barOutlineX=espObj.HealthBarOutline.Position.X.Offset; local barTopY=y+(sy+1)-barHeight
				espObj.HealthText.TextXAlignment=hpPos=="Left" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
				espObj.HealthText.Size=UDim2.new(0,0,0,0)
				local textX=hpPos=="Left" and (barOutlineX-2) or (barOutlineX+hpWidth+4)
				local textY=hpTextFollowBar and barTopY or y
				espObj.HealthText.Position=UDim2.new(0,textX,0,textY)
			end
		else espObj.HealthText.Visible=false end
	else espObj.HealthBarOutline.Visible=false; espObj.HealthText.Visible=false end

	-- Flags
	for _, label in ipairs(espObj.FlagLabels) do label.Visible=false end
	if GetCfg("Flags.Enabled") and instance:IsA("Model") and not noStatus and humanoid then
		local state=humanoid:GetState()
		local isMoving=humanoid.MoveDirection.Magnitude>0
		local isJumping=(state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.FallingDown or state==Enum.HumanoidStateType.Freefall)
		local isSwimming=state==Enum.HumanoidStateType.Swimming
		local fOptMoving=GetCfg("Flags.Options.Moving"); local fOptJumping=GetCfg("Flags.Options.Jumping")
		local fOptSwimming=GetCfg("Flags.Options.Swimming"); local fOptIdle=GetCfg("Flags.Options.Idle")
		local fColMoving=GetCfg("Flags.Colors.Moving"); local fColJumping=GetCfg("Flags.Colors.Jumping")
		local fColSwimming=GetCfg("Flags.Colors.Swimming"); local fColIdle=GetCfg("Flags.Colors.Idle")
		local flagFont=GetCfg("Flags.Font"); local flagTextSize=GetCfg("Flags.TextSize")
		local flagTextGap=GetCfg("Flags.TextGap"); local flagGap=GetCfg("Flags.Gap") or 2
		local flagSideGap=GetCfg("Flags.SideGap"); local flagPosition=GetCfg("Flags.Position")
		-- reuse a local flags table each call (small, so ok)
		local flags={}
		if isMoving and isJumping and fOptMoving and fOptJumping then table.insert(flags,{text="Moving & Jumping",color=fColMoving})
		elseif isJumping and fOptJumping then table.insert(flags,{text="Jumping",color=fColJumping})
		elseif isMoving and fOptMoving   then table.insert(flags,{text="Moving", color=fColMoving})
		elseif isSwimming and fOptSwimming then table.insert(flags,{text="Swimming",color=fColSwimming})
		elseif fOptIdle then table.insert(flags,{text="Idle",color=fColIdle}) end

		local isRight=flagPosition=="Right"
		local fx=isRight and (x+sx+flagSideGap+rightOffset) or (x-100-flagSideGap-leftOffset)
		local fy=y-flagGap
		if flagFont=="Smallest Pixel-7" then fy=fy-3 end
		local flagsFontObj=_fontMap[flagFont] or Enum.Font.Code; local flagsFontLoaded=ESPFonts.Loaded[flagFont]
		local flagOutlineStyle=GetCfg("Flags.OutlineStyle") or textOutlineStyle
		for i, data in ipairs(flags) do
			local label=espObj.FlagLabels[i]
			if label then
				label.Visible=true; label.Text=data.text; label.TextColor3=data.color
				label.Font=flagsFontObj; if flagsFontLoaded then label.FontFace=flagsFontLoaded end
				label.TextSize=flagTextSize
				label.TextXAlignment=isRight and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
				label.Position=UDim2.new(0,fx,0,fy+(i-1)*(flagTextSize+flagTextGap))
				ApplyTextOutline(label,flagOutlineStyle,textOutlineColor)
			end
		end
	end

	-- Skeleton (module-level _bonePositions reused, no alloc per frame)
	if GetCfg("Skeleton.Enabled") and instance:IsA("Model") then
		local skeletonOutline=GetCfg("Skeleton.Outline")
		local skeletonColor=GetCfg("Skeleton.Color"); local skeletonOutlineColor=GetCfg("Skeleton.OutlineColor")
		table.clear(_bonePositions)
		for _, def in ipairs(SKELETON_BONE_DEFS) do
			for _, bn in ipairs(def) do
				if _bonePositions[bn] == nil then
					local wp = GetBonePosition(instance,bn)
					local sp, on = wp and WtS(Camera,wp)
					_bonePositions[bn] = (wp and on) and Vector2.new(sp.X,sp.Y) or false
				end
			end
		end
		for i, def in ipairs(SKELETON_BONE_DEFS) do
			local pA=_bonePositions[def[1]]; local pB=_bonePositions[def[2]]
			if pA and pB then
				if skeletonOutline then DrawLine(espObj.BoneOutlines[i],pA,pB,3,skeletonOutlineColor)
				else espObj.BoneOutlines[i].Visible=false end
				DrawLine(espObj.Bones[i],pA,pB,1,skeletonColor)
			else espObj.Bones[i].Visible=false; espObj.BoneOutlines[i].Visible=false end
		end
	else
		if espObj.Bones then
			for _,b in ipairs(espObj.Bones) do b.Visible=false end
			for _,b in ipairs(espObj.BoneOutlines) do b.Visible=false end
		end
	end
end)

-- ─── Bounding box ────────────────────────────────────────────────────────────
local _fallbackCorners = table.create(8)

local function FillCorners(corners, cf, size)
	local hx,hy,hz = size.X/2, size.Y/2, size.Z/2
	corners[1]=cf*Vector3.new( hx, hy, hz); corners[2]=cf*Vector3.new(-hx, hy, hz)
	corners[3]=cf*Vector3.new( hx,-hy, hz); corners[4]=cf*Vector3.new(-hx,-hy, hz)
	corners[5]=cf*Vector3.new( hx, hy,-hz); corners[6]=cf*Vector3.new(-hx, hy,-hz)
	corners[7]=cf*Vector3.new( hx,-hy,-hz); corners[8]=cf*Vector3.new(-hx,-hy,-hz)
end

local Get2DBoundingBox = LPHNoVirtualize(function(instance, trackedData)
	local rootPart
	if instance:IsA("Model") then
		rootPart = instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChild("Torso")
			or instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
	elseif instance:IsA("BasePart") then rootPart=instance end
	if not rootPart then return false,nil,nil end
	local position,onScreen = Camera:WorldToViewportPoint(rootPart.Position)
	if not onScreen then return false,nil,nil end

	if not ESPConfig.DynamicBoxes then
		local humanoid = instance:IsA("Model") and instance:FindFirstChild("Humanoid")
		if humanoid then
			local isR6=humanoid.RigType==Enum.HumanoidRigType.R6
			local topOff=isR6 and 2.8 or 3.0; local botOff=isR6 and 3.0 or 3.5
			local top2D=Camera:WorldToViewportPoint(rootPart.Position+Vector3.new(0,topOff,0))
			local bot2D=Camera:WorldToViewportPoint(rootPart.Position-Vector3.new(0,botOff,0))
			local height=math.abs(top2D.Y-bot2D.Y)
			return true,Vector2.new(position.X,(top2D.Y+bot2D.Y)/2),Vector2.new(height*0.65,height)
		end
		local cf,size
		if instance:IsA("Model") then cf,size=instance:GetBoundingBox()
		else cf,size=instance.CFrame,instance.Size end
		local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
		local corners=trackedData and trackedData.Corners or _fallbackCorners
		FillCorners(corners,cf,size)
		for i=1,8 do
			local sp=Camera:WorldToViewportPoint(corners[i])
			if sp.X<minX then minX=sp.X end; if sp.X>maxX then maxX=sp.X end
			if sp.Y<minY then minY=sp.Y end; if sp.Y>maxY then maxY=sp.Y end
		end
		return true,Vector2.new((minX+maxX)/2,(minY+maxY)/2),Vector2.new(maxX-minX,maxY-minY)
	else
		local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
		local parts
		if instance:IsA("Model") then
			if trackedData and (trackedData.PartsListDirty or not trackedData.PartsList) then
				local includeAll=ESPConfig.DynamicBoxesIncludeAll; local built={}
				for _, v in ipairs(instance:GetChildren()) do
					if v:IsA("BasePart") and (includeAll or (v.Name~="HumanoidRootPart" and v.Transparency~=1)) then
						built[#built+1]=v
					end
				end
				trackedData.PartsList=built; trackedData.PartsListDirty=false
			end
			parts=(trackedData and trackedData.PartsList) or {}
		else parts={instance} end
		if #parts==0 then return false,nil,nil end

		if ESPConfig.DynamicBoxesCheap then
			for _, part in ipairs(parts) do
				local cf,size=part.CFrame,part.Size; local hs=size/2
				local p1=cf*Vector3.new(hs.X,hs.Y,hs.Z); local p2=cf*Vector3.new(-hs.X,-hs.Y,-hs.Z)
				local s1=Camera:WorldToViewportPoint(p1); local s2=Camera:WorldToViewportPoint(p2)
				if s1.X<minX then minX=s1.X end; if s1.X>maxX then maxX=s1.X end
				if s1.Y<minY then minY=s1.Y end; if s1.Y>maxY then maxY=s1.Y end
				if s2.X<minX then minX=s2.X end; if s2.X>maxX then maxX=s2.X end
				if s2.Y<minY then minY=s2.Y end; if s2.Y>maxY then maxY=s2.Y end
			end
		else
			local corners=trackedData and trackedData.Corners or _fallbackCorners
			for _, part in ipairs(parts) do
				FillCorners(corners,part.CFrame,part.Size)
				for i=1,8 do
					local sp=Camera:WorldToViewportPoint(corners[i])
					if sp.X<minX then minX=sp.X end; if sp.X>maxX then maxX=sp.X end
					if sp.Y<minY then minY=sp.Y end; if sp.Y>maxY then maxY=sp.Y end
				end
			end
		end
		return true,Vector2.new((minX+maxX)/2,(minY+maxY)/2),Vector2.new(maxX-minX,maxY-minY)
	end
end)

-- ─── Name/contains/blockname checks ──────────────────────────────────────────
local function CheckContains(instance, containsList)
	if type(containsList)~="table" or #containsList==0 then return true end
	if #containsList==1 and containsList[1]=="" then return true end
	for _, containName in ipairs(containsList) do
		local found=false
		for _, child in ipairs(instance:GetChildren()) do if child.Name==containName then found=true; break end end
		if not found then return false end
	end
	return true
end

local function CheckNames(instance, namesList)
	if type(namesList)~="table" or #namesList==0 then return true end
	if #namesList==1 and namesList[1]=="" then return true end
	for _, name in ipairs(namesList) do if instance.Name==name then return true end end
	return false
end

local function CheckBlockNames(inst, blockList)
	if not blockList or #blockList==0 then return false end
	local current=inst
	while current and current ~= game do
		for _, name in ipairs(blockList) do if name~="" and current.Name:find(name) then return true end end
		current=current.Parent
	end
	return false
end

-- ─── Directory dirty flag (avoids rescanning every 1s unconditionally) ───────
local _directoryDirty = true
local function MarkDirectoryDirty() _directoryDirty=true end
Workspace.ChildAdded:Connect(MarkDirectoryDirty)
Workspace.ChildRemoved:Connect(MarkDirectoryDirty)

-- ─── ScanDirectories (fixed — no self-recursion, no stray `now` ref) ─────────
local ScanDirectories = LPHNoVirtualize(function()
	local newTracked = {}

	if ESPConfig.Players then
		for _, player in ipairs(Players:GetPlayers()) do
			if not ESPConfig.LocalPlayer and player==LocalPlayer then continue end
			if player.Character then
				local humanoid=player.Character:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health>0 then
					newTracked[player.Character]={name=player.Name,Cheap=false}
				end
			end
		end
	end

	for key, config in pairs(ESPConfig.Directories) do
		local displayName=nil
		if type(config)=="table" and config.DisplayName and config.DisplayName~="" then displayName=config.DisplayName
		elseif type(key)=="string" then displayName=key end

		if type(config)=="string" then
			local inst=GetInstanceFromPath(config)
			if inst then newTracked[inst]={name=displayName or inst.Name,Cheap=false} end
		elseif type(config)=="table" then
			local path=config.Path; if not path then continue end
			local inst=GetInstanceFromPath(path); if not inst then continue end
			local isCheap=config.Cheap or false; local nonHuman=config.NonHuman or false
			local noStatus=config.NoStatus or false; local customConfig=config.Config or {}
			local isRecursive=config.Recursive or false

			if config.Multiple then
				local children=isRecursive and inst:GetDescendants() or inst:GetChildren()
				for _, child in ipairs(children) do
					if child:IsA("Model") or child:IsA("BasePart") then
						local hasTrackedAncestor=false
						local p=child.Parent
						while p and p~=inst and p~=game do
							if newTracked[p] then hasTrackedAncestor=true; break end
							p=p.Parent
						end
						if not hasTrackedAncestor
							and CheckNames(child,config.Names)
							and CheckContains(child,config.Contains)
							and not CheckBlockNames(child,config.BlockNames)
						then
							local humanoid=child:FindFirstChild("Humanoid")
							if nonHuman or (not humanoid or humanoid.Health>0) then
								local actualName=(displayName and displayName~="") and displayName or child.Name
								newTracked[child]={name=actualName,Cheap=isCheap,NonHuman=nonHuman,NoStatus=noStatus,Config=customConfig}
							end
						end
					end
				end
			else
				if CheckNames(inst,config.Names) and CheckContains(inst,config.Contains) and not CheckBlockNames(inst,config.BlockNames) then
					local humanoid=inst:FindFirstChild("Humanoid")
					if nonHuman or (not humanoid or humanoid.Health>0) then
						local actualName=(displayName and displayName~="") and displayName or inst.Name
						newTracked[inst]={name=actualName,Cheap=isCheap,NonHuman=nonHuman,NoStatus=noStatus,Config=customConfig}
					end
				end
			end
		end
	end

	for inst, data in pairs(newTracked) do
		if not TrackedInstances[inst] then
			local entry={
				espObj=CreateESPObj(data.name), name=data.name, Cheap=data.Cheap,
				NonHuman=data.NonHuman, NoStatus=data.NoStatus, Config=data.Config,
				PartsList=nil, PartsListDirty=true, Corners=table.create(8), ChildConnections={},
			}
			if inst:IsA("Model") then
				entry.ChildConnections[1]=inst.ChildAdded:Connect(function()
					local t=TrackedInstances[inst]; if t then t.PartsListDirty=true end
				end)
				entry.ChildConnections[2]=inst.ChildRemoved:Connect(function()
					local t=TrackedInstances[inst]; if t then t.PartsListDirty=true end
				end)
			end
			TrackedInstances[inst]=entry
		else
			TrackedInstances[inst].name=data.name; TrackedInstances[inst].Cheap=data.Cheap
			TrackedInstances[inst].NonHuman=data.NonHuman; TrackedInstances[inst].NoStatus=data.NoStatus
			TrackedInstances[inst].Config=data.Config
		end
	end

	for inst, data in pairs(TrackedInstances) do
		if not newTracked[inst] or not inst.Parent then
			if data.ChildConnections then for _,conn in ipairs(data.ChildConnections) do conn:Disconnect() end end
			data.espObj:Destroy(); TrackedInstances[inst]=nil
		end
	end
end)

-- ─── Runtime loop ────────────────────────────────────────────────────────────
local lastScan      = 0
local lastRender    = 0
local lastFontRetry = 0
local _espDebugDone = true
local _disabledChamsConfig = { Chams = { Enabled = false } }

local SCAN_INTERVAL_CLEAN = 3
local SCAN_INTERVAL_DIRTY = 0.2

local function RuntimeStep()
	BeginConfigCacheFrame()

	if not ESPConfig.Enabled then
		for inst, data in pairs(TrackedInstances) do
			if data.espObj then
				UpdateESPObj(data.espObj,nil,nil,"",0,inst,nil,data.Cheap,data.NonHuman,data.NoStatus,_disabledChamsConfig,false)
			end
		end
		return
	end

	local now = tick()

	if FontsStillLoading and now-lastFontRetry > 5 then
		lastFontRetry=now; AttemptLoadFonts()
	end

	if ESPConfig.LimitFPS and ESPConfig.LimitFPS > 0 then
		if now-lastRender < (1/ESPConfig.LimitFPS) then return end
		lastRender=now
	end

	-- Dirty-flag-driven scan (3s passive, 0.2s when workspace changes)
	local scanInterval = _directoryDirty and SCAN_INTERVAL_DIRTY or SCAN_INTERVAL_CLEAN
	if now-lastScan > scanInterval then
		lastScan=now; _directoryDirty=false
		ScanDirectories()
	end

	for inst, data in pairs(TrackedInstances) do
		if not inst or not inst.Parent then
			data.espObj:Destroy(); TrackedInstances[inst]=nil; continue
		end

		-- Resolve humanoid once here, pass it down — no double FindFirstChild
		local humanoid = not data.NonHuman and inst:FindFirstChild("Humanoid") or nil
		if humanoid and humanoid.Health<=0 then
			data.espObj:Destroy(); TrackedInstances[inst]=nil; continue
		end

		local rootPart = inst:IsA("Model")
			and (inst.PrimaryPart or inst:FindFirstChild("HumanoidRootPart") or inst:FindFirstChildWhichIsA("BasePart"))
			or (inst:IsA("BasePart") and inst)

		if rootPart then
			local onscreen,pos2d,size2d = Get2DBoundingBox(inst,data)
			local distanceStuds = (Camera.CFrame.Position-rootPart.Position).Magnitude
			UpdateESPObj(
				data.espObj, pos2d, size2d, data.name, distanceStuds,
				inst, humanoid,    -- pass resolved humanoid
				data.Cheap, data.NonHuman, data.NoStatus, data.Config, onscreen
			)
		else
			UpdateESPObj(
				data.espObj, nil, nil, data.name, 0,
				inst, humanoid,
				data.Cheap, data.NonHuman, data.NoStatus, data.Config, false
			)
		end
	end
end

-- ─── ESP API ─────────────────────────────────────────────────────────────────
function ESP:Unload()
	for inst, data in pairs(TrackedInstances) do
		if data.ChildConnections then for _,conn in ipairs(data.ChildConnections) do conn:Disconnect() end end
		if data.espObj then data.espObj:Destroy() end
		TrackedInstances[inst]=nil
	end
	if PlayerRemovingConnection then PlayerRemovingConnection:Disconnect(); PlayerRemovingConnection=nil end
	if InputBeganConnection     then InputBeganConnection:Disconnect();     InputBeganConnection=nil end
	if getgenv().HydrogenESP_Loop then getgenv().HydrogenESP_Loop:Disconnect(); getgenv().HydrogenESP_Loop=nil end
	if ScreenGui      then ScreenGui:Destroy();      ScreenGui=nil end
	if ChamsContainer then ChamsContainer:Destroy(); ChamsContainer=nil end
	if MeshChamsFolder then MeshChamsFolder:Destroy(); MeshChamsFolder=nil end
	CleanupMeshChams(Workspace)
	for _,player in ipairs(BootstrapPlayers:GetPlayers()) do CleanupCharacterMeshChams(player.Character) end
	getgenv().HydrogenESP_UI=nil
end

function ESP:Load(config)
	self:Unload()
	ESPConfig=DeepMerge(DeepCopy(DefaultESPConfig), config or {})
	InvalidateConfigCache()   -- flush cache on full reload
	EnsureRootInstances()
	CurrentRunId=HttpService:GenerateGUID(false)
	lastScan=0; lastRender=0; _directoryDirty=true

	PlayerRemovingConnection=Players.PlayerRemoving:Connect(function(player)
		for inst, data in pairs(TrackedInstances) do
			if Players:GetPlayerFromCharacter(inst)==player then
				data.espObj:Destroy(); TrackedInstances[inst]=nil
			end
		end
	end)

	InputBeganConnection=UserInputService.InputBegan:Connect(function(input,gpe)
		if not gpe and ESPConfig.Keybind.Enabled and input.KeyCode==ESPConfig.Keybind.Key then
			ESPConfig.Enabled=not ESPConfig.Enabled
		end
	end)

	getgenv().HydrogenESP_Loop=RunService.RenderStepped:Connect(RuntimeStep)
	ScanDirectories()
	return self
end

function ESP:GetConfig() return ESPConfig end
function ESP:InvalidateCache() InvalidateConfigCache() end

getgenv().HydrogenESP_Unload = function() ESP:Unload() end
ESP:Load()
return ESP
