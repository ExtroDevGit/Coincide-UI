--!nolint
--!nocheck

local UserInputService = game:GetService("UserInputService");
local Workspace = game:GetService("Workspace");
local HttpService = game:GetService("HttpService");
local GuiService = game:GetService("GuiService");
local RunService = game:GetService("RunService");
local CoreGui = game:GetService("CoreGui");
local TweenService = game:GetService("TweenService");

local GuiInset = GuiService:GetGuiInset().Y;

local NewColorSequence = ColorSequence.new;
local NewColorSequenceKeypoint = ColorSequenceKeypoint.new;
local NewNumberSequence = NumberSequence.new;
local NewNumberSequenceKeypoint = NumberSequenceKeypoint.new;

local Library = {
	Flags = {};
	Toggles = {};
	Options = {};
	Connections = {};
	Directory = "afffaafafafafafafafafaa";
	Folders = { "/Fonts", "/Configs", "/Logs" };
	CurrentlyOpen = nil;
	AnimationSpeed = 1;
	LogFile = "afffaaaa/Logs/Session.log";
};

local Palette = {
	Default = {
		Top = Color3.fromHex("161616");
		Bottom = Color3.fromHex("1E1E1E");
		ContentTop = Color3.fromHex("151515");
		ContentBottom = Color3.fromHex("171717");
		FooterTop = Color3.fromHex("151515");
		FooterBottom = Color3.fromHex("1F1F1F");
		Outline = Color3.fromHex("000105");
		InnerOutline = Color3.fromHex("252527");
		TitleTop = Color3.fromHex("F3F4F8");
		TitleBottom = Color3.fromHex("557294");
		TabActive = Color3.fromHex("557294");
		Accent = Color3.fromHex("df2081");
		TabInactive = Color3.fromHex("BFC4CC");
	};
};
Library.Palette = Palette;

Library.Accent          = Palette.Default.Accent;
Library.AccentParts     = {};
Library.AccentGradients = {};
Library.AccentCallbacks = {};

local function LightenAccent(C)
	return C:Lerp(Color3.fromRGB(255, 255, 255), 0.6);
end;

function Library:RegisterAccent(Inst, Prop)
	Prop = Prop or "BackgroundColor3";
	table.insert(self.AccentParts, { Inst = Inst, Prop = Prop });
	Inst[Prop] = self.Accent;
end;

function Library:RegisterAccentGradient(Gradient)
	table.insert(self.AccentGradients, Gradient);
	Gradient.Color = NewColorSequence({
		NewColorSequenceKeypoint(0,   self.Accent);
		NewColorSequenceKeypoint(0.5, LightenAccent(self.Accent));
		NewColorSequenceKeypoint(1,   self.Accent);
	});
end;

Library.Keybinds         = {};
Library.KeybindListeners = {};

function Library:RegisterKeybind(Entry)
	if typeof(Entry) ~= "table" then return end;
	table.insert(self.Keybinds, Entry);
	self:NotifyKeybind();
	return Entry;
end;

function Library:NotifyKeybind()
	for _, Fn in self.KeybindListeners do Fn() end;
end;

function Library:OnKeybindChange(Fn)
	if typeof(Fn) ~= "function" then return end;
	table.insert(self.KeybindListeners, Fn);
	Fn();
end;

local AccentClock = 0;
game:GetService("RunService").Heartbeat:Connect(function(Dt)
	AccentClock = AccentClock + Dt * 0.4;
	local Off = (AccentClock % 2) - 1;
	local OffsetV = Vector2.new(Off, 0);
	for _, G in Library.AccentGradients do
		if G and G.Parent then
			G.Offset = OffsetV;
		end;
	end;
end);

function Library:OnAccent(Fn)
	if typeof(Fn) ~= "function" then return end;
	table.insert(self.AccentCallbacks, Fn);
	Fn(self.Accent);
end;

function Library:SetAccent(C)
	if typeof(C) ~= "Color3" then return end;
	self.Accent = C;
	for _, P in self.AccentParts do
		if P.Inst and P.Inst.Parent then
			P.Inst[P.Prop] = C;
		end;
	end;
	for _, G in self.AccentGradients do
		if G and G.Parent then
			G.Color = NewColorSequence({
				NewColorSequenceKeypoint(0,   C);
				NewColorSequenceKeypoint(0.5, LightenAccent(C));
				NewColorSequenceKeypoint(1,   C);
			});
		end;
	end;
	for _, Fn in self.AccentCallbacks do
		Fn(C);
	end;
end;

for _, FolderPath in Library.Folders do
	makefolder(Library.Directory .. FolderPath);
end;

if isfile(Library.LogFile) then
	delfile(Library.LogFile);
end;
writefile(Library.LogFile, Library.Directory .. " has started\n");

local LogStart = tick();

function Library:Log(Text)
	local Stamp = string.format("%.3f", tick() - LogStart);
	appendfile(self.LogFile, "[" .. Stamp .. "s] " .. tostring(Text) .. "\n");
end;

Library.KeyNames = {
	[Enum.UserInputType.MouseButton1] = "MB1";
	[Enum.UserInputType.MouseButton2] = "MB2";
	[Enum.UserInputType.MouseButton3] = "MB3";

	[Enum.KeyCode.LeftShift] = "LS";
	[Enum.KeyCode.RightShift] = "RS";
	[Enum.KeyCode.LeftControl] = "LC";
	[Enum.KeyCode.RightControl] = "RC";
	[Enum.KeyCode.LeftAlt] = "LA";
	[Enum.KeyCode.RightAlt] = "RA";
	[Enum.KeyCode.CapsLock] = "CAPS";
	[Enum.KeyCode.Insert] = "INS";
	[Enum.KeyCode.Backspace] = "BS";
	[Enum.KeyCode.Return] = "Ent";
	[Enum.KeyCode.Escape] = "ESC";
	[Enum.KeyCode.Space] = "SPC";

	[Enum.KeyCode.Zero] = "0";
	[Enum.KeyCode.One] = "1";
	[Enum.KeyCode.Two] = "2";
	[Enum.KeyCode.Three] = "3";
	[Enum.KeyCode.Four] = "4";
	[Enum.KeyCode.Five] = "5";
	[Enum.KeyCode.Six] = "6";
	[Enum.KeyCode.Seven] = "7";
	[Enum.KeyCode.Eight] = "8";
	[Enum.KeyCode.Nine] = "9";

	[Enum.KeyCode.KeypadZero] = "Num0";
	[Enum.KeyCode.KeypadOne] = "Num1";
	[Enum.KeyCode.KeypadTwo] = "Num2";
	[Enum.KeyCode.KeypadThree] = "Num3";
	[Enum.KeyCode.KeypadFour] = "Num4";
	[Enum.KeyCode.KeypadFive] = "Num5";
	[Enum.KeyCode.KeypadSix] = "Num6";
	[Enum.KeyCode.KeypadSeven] = "Num7";
	[Enum.KeyCode.KeypadEight] = "Num8";
	[Enum.KeyCode.KeypadNine] = "Num9";

	[Enum.KeyCode.Minus] = "-";
	[Enum.KeyCode.Equals] = "=";
	[Enum.KeyCode.Tilde] = "~";
	[Enum.KeyCode.LeftBracket] = "[";
	[Enum.KeyCode.RightBracket] = "]";
	[Enum.KeyCode.LeftParenthesis] = "(";
	[Enum.KeyCode.RightParenthesis] = ")";
	[Enum.KeyCode.Semicolon] = ",";
	[Enum.KeyCode.Quote] = "'";
	[Enum.KeyCode.BackSlash] = "\\";
	[Enum.KeyCode.Comma] = ",";
	[Enum.KeyCode.Period] = ".";
	[Enum.KeyCode.Slash] = "/";
	[Enum.KeyCode.Asterisk] = "*";
	[Enum.KeyCode.Plus] = "+";
	[Enum.KeyCode.Backquote] = "`";
};

if getgenv().Library then getgenv().Library:Unload() end;
getgenv().Library = Library;

function Library:Connection(Signal, Callback)
	local Conn = Signal:Connect(Callback);
	table.insert(self.Connections, Conn);
	return Conn;
end;

function Library:CreateInstance(ClassName, Properties)
	local Inst = Instance.new(ClassName);
	for K, V in (Properties or {}) do
		Inst[K] = V;
	end;
	return Inst;
end;

function Library:Tween(Inst, Info, Props)
	local Speed = self.AnimationSpeed or 1;
	if Speed < 0.05 then Speed = 0.05 end;
	local Scale = 1 / Speed;
	local Style = self.EasingStyle      or Info.EasingStyle;
	local Dir   = self.EasingDirection  or Info.EasingDirection;
	if Scale == 1 and Style == Info.EasingStyle and Dir == Info.EasingDirection then
		return TweenService:Create(Inst, Info, Props);
	end;
	local Scaled = TweenInfo.new(Info.Time * Scale, Style, Dir, Info.RepeatCount, Info.Reverses, Info.DelayTime);
	return TweenService:Create(Inst, Scaled, Props);
end;

Library._ActiveDraggers = {};

function Library:_RegisterDragger(Handler)
	if typeof(Handler) ~= "function" then return end;
	local Self = self;
	if not Self._DispatcherConn then
		Self._DispatcherConn = UserInputService.InputChanged:Connect(function(Input)
			local Ut = Input.UserInputType;
			if Ut ~= Enum.UserInputType.MouseMovement and Ut ~= Enum.UserInputType.Touch then
				return;
			end;
			local List = Self._ActiveDraggers;
			for I = 1, #List do
				List[I](Input);
			end;
		end);
		table.insert(Self.Connections, Self._DispatcherConn);
	end;
	table.insert(Self._ActiveDraggers, Handler);
	return Handler;
end;

function Library:_UnregisterDragger(Handler)
	if not Handler then return end;
	local List = self._ActiveDraggers;
	if not List then return end;
	for I = #List, 1, -1 do
		if List[I] == Handler then
			List[I] = List[#List];
			List[#List] = nil;
			return;
		end;
	end;
end;

function Library:IsEffectivelyVisible(Inst)
	local Cur = Inst;
	while Cur do
		if Cur:IsA("ScreenGui") then return Cur.Enabled end;
		if Cur:IsA("GuiObject") and not Cur.Visible then return false end;
		Cur = Cur.Parent;
	end;
	return false;
end;

function Library:Debounce(Delay, Fn)
	local Token = 0;
	return function(...)
		Token = Token + 1;
		local Mine = Token;
		local Args = { ... };
		task.delay(Delay, function()
			if Mine == Token then Fn(table.unpack(Args)) end;
		end);
	end;
end;

function Library:RegisterFont(Name, Url, Weight, Style)
	local Folder = self.Directory .. "/Fonts";
	local TtfPath = Folder .. "/" .. Name .. ".ttf";
	local DescPath = Folder .. "/" .. Name .. ".font";

	if not isfile(TtfPath) then
		writefile(TtfPath, game:HttpGet(Url));
	end;
	if isfile(DescPath) then
		delfile(DescPath);
	end;

	writefile(DescPath, HttpService:JSONEncode({
		name = Name;
		faces = {
			{ name = "Regular", weight = Weight or 400, style = Style or "normal", assetId = getcustomasset(TtfPath) };
		};
	}));

	self:Log("Registered font " .. Name);
	return getcustomasset(DescPath);
end;

function Library:Draggable(TargetFrame, DragHandle)
	local Handle = DragHandle or TargetFrame;
	local Dragging = false;
	local DragStart, StartPosition;
	local DragInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);

	local function Set(Input)
		if not DragStart or not StartPosition then return end;
		local Delta = Input.Position - DragStart;
		Library:Tween(TargetFrame, DragInfo, {
			Position = UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset + Delta.X,
				StartPosition.Y.Scale,
				StartPosition.Y.Offset + Delta.Y
			);
		}):Play();
	end;

	self:Connection(Handle.InputBegan, function(Input)
		if
			Input.UserInputType ~= Enum.UserInputType.MouseButton1
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return;
		end;
		Dragging      = true;
		DragStart     = Input.Position;
		StartPosition = TargetFrame.Position;
	end);

	self:Connection(Handle.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = false;
		end;
	end);

	self:Connection(UserInputService.InputChanged, function(Input)
		if
			Input.UserInputType ~= Enum.UserInputType.MouseMovement
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return;
		end;
		if Dragging then Set(Input) end;
	end);
end;

function Library:Resizable(TargetFrame, Minimum, Maximum)
	Minimum = Minimum or Vector2.new(TargetFrame.Size.X.Offset, TargetFrame.Size.Y.Offset);
	local ResizeInfo = TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);

	local Grip = self:CreateInstance("TextButton", {
		Parent                 = TargetFrame;
		AnchorPoint            = Vector2.new(1, 1);
		BorderColor3           = Color3.fromRGB(0, 0, 0);
		Size                   = UDim2.new(0, 8, 0, 8);
		Position               = UDim2.new(1, 0, 1, 0);
		Name                   = "\0";
		BorderSizePixel        = 0;
		BackgroundTransparency = 1;
		AutoButtonColor        = false;
		Visible                = true;
		Text                   = "";
	});

	local Resizing  = false;
	local Start     = UDim2.new();
	local Delta     = UDim2.new();
	local ResizeMax = TargetFrame.Parent.AbsoluteSize - TargetFrame.AbsoluteSize;

	self:Connection(Grip.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Resizing = true;
			Start    = TargetFrame.Size - UDim2.new(0, Input.Position.X, 0, Input.Position.Y);
		end;
	end);

	self:Connection(Grip.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Resizing = false;
		end;
	end);

	self:Connection(UserInputService.InputChanged, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and Resizing then
			ResizeMax = Maximum or (TargetFrame.Parent.AbsoluteSize - TargetFrame.AbsoluteSize);
			Delta = Start + UDim2.new(0, Input.Position.X, 0, Input.Position.Y);
			Delta = UDim2.new(
				0, math.clamp(Delta.X.Offset, Minimum.X, ResizeMax.X),
				0, math.clamp(Delta.Y.Offset, Minimum.Y, ResizeMax.Y)
			);
			Library:Tween(TargetFrame, ResizeInfo, { Size = Delta }):Play();
		end;
	end);

	return Grip;
end;

local ProggyCleanFont;
do
	local Asset = Library:RegisterFont("ProggyClean", "https://github.com/networph-private874612748471/curly-octo-memory/raw/refs/heads/main/fs-tahoma-8px.ttf", 400, "normal");
	if Asset then
		ProggyCleanFont = Font.new(Asset, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	else
		print("font no work");
	end;
end;

function Library:Tooltip(Inst, Text)
	if not Inst or not Text or Text == "" then return end;

	if not self._TooltipFrame then
		local Gui = self:CreateInstance("ScreenGui", {
			Name           = "Tooltip";
			Parent         = (gethui and gethui()) or CoreGui;
			IgnoreGuiInset = true;
			ResetOnSpawn   = false;
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
			DisplayOrder   = 9999;
		});
		local Frame = self:CreateInstance("CanvasGroup", {
			Name              = "Box";
			Parent            = Gui;
			Size              = UDim2.new(0, 0, 0, 0);
			AutomaticSize     = Enum.AutomaticSize.XY;
			BackgroundColor3  = Color3.fromHex("000000");
			BorderSizePixel   = 0;
			Visible           = false;
			GroupTransparency = 1;
			ZIndex            = 200;
		});
		self:CreateInstance("UIPadding", {
			Parent = Frame; PaddingLeft = UDim.new(0, 1); PaddingRight = UDim.new(0, 1);
			PaddingTop = UDim.new(0, 1); PaddingBottom = UDim.new(0, 1);
		});
		local Gray = self:CreateInstance("Frame", {
			Parent           = Frame;
			Size             = UDim2.new(0, 0, 0, 0);
			AutomaticSize    = Enum.AutomaticSize.XY;
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
		});
		self:CreateInstance("UIPadding", {
			Parent = Gray; PaddingLeft = UDim.new(0, 1); PaddingRight = UDim.new(0, 1);
			PaddingTop = UDim.new(0, 1); PaddingBottom = UDim.new(0, 1);
		});
		local Inside = self:CreateInstance("Frame", {
			Parent           = Gray;
			Size             = UDim2.new(0, 0, 0, 0);
			AutomaticSize    = Enum.AutomaticSize.XY;
			BackgroundColor3 = Color3.fromHex("131313");
			BorderSizePixel  = 0;
		});
		self:CreateInstance("UIPadding", {
			Parent = Inside; PaddingLeft = UDim.new(0, 6); PaddingRight = UDim.new(0, 6);
			PaddingTop = UDim.new(0, 3); PaddingBottom = UDim.new(0, 3);
		});
		local Lbl = self:CreateInstance("TextLabel", {
			Name                   = "Text";
			Parent                 = Inside;
			Size                   = UDim2.new(0, 0, 0, 0);
			AutomaticSize          = Enum.AutomaticSize.XY;
			BackgroundTransparency = 1;
			Text                   = "";
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

		self._TooltipGui   = Gui;
		self._TooltipFrame = Frame;
		self._TooltipLabel = Lbl;
	end;

	local Frame    = self._TooltipFrame;
	local Lbl      = self._TooltipLabel;
	local InInfo   = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	local OutInfo  = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
	local SwapInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In);

	self:Connection(Inst.MouseEnter, function()
		self._TooltipActive = Inst;
		self._TooltipToken  = (self._TooltipToken or 0) + 1;
		local Mine = self._TooltipToken;

		local function FadeIn()
			Lbl.Text                = tostring(Text);
			Frame.Visible           = true;
			Frame.GroupTransparency = 1;
			Library:Tween(Frame, InInfo, { GroupTransparency = 0 }):Play();
		end;

		if Frame.Visible and Frame.GroupTransparency < 1 then
			Library:Tween(Frame, SwapInfo, { GroupTransparency = 1 }):Play();
			task.delay(SwapInfo.Time, function()
				if self._TooltipToken == Mine then FadeIn() end;
			end);
		else
			FadeIn();
		end;
	end);
	self:Connection(Inst.MouseMoved, function(X, Y)
		if self._TooltipActive ~= Inst then return end;
		Frame.Position = UDim2.fromOffset(X + 14, Y + 6);
	end);
	self:Connection(Inst.MouseLeave, function()
		if self._TooltipActive ~= Inst then return end;
		self._TooltipActive = nil;
		local Mine = (self._TooltipToken or 0) + 1;
		self._TooltipToken = Mine;
		Library:Tween(Frame, OutInfo, { GroupTransparency = 1 }):Play();
		task.delay(OutInfo.Time, function()
			if self._TooltipToken == Mine then Frame.Visible = false end;
		end);
	end);
end;

function Library:Window(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Width     = tonumber(Opts.Width)     or 400;
	local Height    = tonumber(Opts.Height)    or 700;
	local MinWidth  = tonumber(Opts.MinWidth)  or 280;
	local MinHeight = tonumber(Opts.MinHeight) or 400;
	if Width  < MinWidth  then Width  = MinWidth  end;
	if Height < MinHeight then Height = MinHeight end;

	local Gui = self:CreateInstance("ScreenGui", {
		Name = "NetworphTallWindow";
		Parent = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});

	local Outer = self:CreateInstance("Frame", {
		Name = "Outer";
		Parent = Gui;
		AnchorPoint = Vector2.new(0.5, 0.5);
		Position = UDim2.new(0.5, 0, 0.5, 0);
		Size = UDim2.fromOffset(Width, Height);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Outer;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("212121"));
			NewColorSequenceKeypoint(1, Color3.fromHex("1A1A1A"));
		});
	});
	self:CreateInstance("UIStroke", {
		Parent          = Outer;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});

	local InnerOutline = self:CreateInstance("Frame", {
		Name = "InnerOutline";
		Parent = Outer;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2);
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
	});
	self:CreateInstance("UIStroke", {
		Parent          = InnerOutline;
		Color           = Color3.fromHex("393939");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});

	local TopLine = self:CreateInstance("Frame", {
		Name = "TopLine";
		Parent = Outer;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel = 0;
		ZIndex = 10;
	});
	local TopLineGradient = self:CreateInstance("UIGradient", {
		Parent = TopLine;
		Rotation = 0;
	});
	Library:RegisterAccentGradient(TopLineGradient);

	local TitleText = tostring(Opts.Title or Opts.Name or "Networph");
	local Title = self:CreateInstance("TextLabel", {
		Name                   = "Title";
		Parent                 = Outer;
		Position               = UDim2.new(0, 6, 0, 9);
		Size                   = UDim2.new(0, 200, 0, 18);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		Text                   = TitleText;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then Title.FontFace = ProggyCleanFont end;

	local Content = self:CreateInstance("Frame", {
		Name             = "Content";
		Parent           = Outer;
		Position         = UDim2.new(0, 5, 0, 34);
		Size             = UDim2.new(1, -10, 1, -39);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Content;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
			NewColorSequenceKeypoint(1, Color3.fromHex("101010"));
		});
	});

	local function ContentEdge(Name, Anchor, Pos, Sz, Color)
		self:CreateInstance("Frame", {
			Name             = Name;
			Parent           = Content;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 10;
		});
	end;
	ContentEdge("LeftBlack",   Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),   "000000");
	ContentEdge("LeftGray",    Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(0, 1, 1, -2),  "393939");
	ContentEdge("RightBlack",  Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),   "000000");
	ContentEdge("RightGray",   Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2),  "393939");
	ContentEdge("BottomBlack", Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),   "000000");
	ContentEdge("BottomGray",  Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1),  "393939");

	self:Draggable(Outer);
	self:Resizable(Outer, Vector2.new(MinWidth, MinHeight));

	local Window = { Gui = Gui, Outer = Outer, TopLine = TopLine, Content = Content };
	Window._Tabs = {};

	function Window:Tab(NameOrOpts)
		local TabOpts = typeof(NameOrOpts) == "table" and NameOrOpts or { Name = tostring(NameOrOpts) };
		local TabName = tostring(TabOpts.Name or TabOpts.Title or "Tab");

		if not self.TabBar then
			self.TabBar = Library:CreateInstance("Frame", {
				Name                   = "TabBar";
				Parent                 = self.Content;
				Position               = UDim2.new(0, 0, 0, 0);
				Size                   = UDim2.new(1, 0, 0, 24);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				ZIndex                 = 5;
			});
			Library:CreateInstance("UIListLayout", {
				Parent        = self.TabBar;
				FillDirection = Enum.FillDirection.Horizontal;
				SortOrder     = Enum.SortOrder.LayoutOrder;
				Padding       = UDim.new(0, 0);
			});
		end;

		local Btn = Library:CreateInstance("TextButton", {
			Name                   = "Tab_" .. TabName;
			Parent                 = self.TabBar;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			AutoButtonColor        = false;
			Text                   = "";
			LayoutOrder            = #self._Tabs + 1;
		});

		local Bg = Library:CreateInstance("Frame", {
			Name             = "Bg";
			Parent           = Btn;
			Position         = UDim2.new(0, 0, 0, 0);
			Size             = UDim2.new(1, 0, 1, 0);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		local Gradient = Library:CreateInstance("UIGradient", {
			Parent   = Bg;
			Rotation = 90;
			Color    = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
				NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
			});
		});

		local function MakePiece(Name, Anchor, Pos, Sz, Color, ZIdx)
			return Library:CreateInstance("Frame", {
				Name                   = Name;
				Parent                 = Bg;
				AnchorPoint            = Anchor;
				Position               = Pos;
				Size                   = Sz;
				BackgroundColor3       = Color3.fromHex(Color);
				BorderSizePixel        = 0;
				BackgroundTransparency = 1;
				ZIndex                 = ZIdx;
			});
		end;

		local TopBlack    = MakePiece("TopBlack",    Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 1), "000000", 4);
		local TopGray     = MakePiece("TopGray",     Vector2.new(0, 0), UDim2.new(0, 0, 0, 1), UDim2.new(1, 0, 0, 1), "393939", 4);
		local BottomBlack = MakePiece("BottomBlack", Vector2.new(0, 1), UDim2.new(0, 0, 1, 0), UDim2.new(1, 0, 0, 1), "000000", 4);
		local BottomGray  = MakePiece("BottomGray",  Vector2.new(0, 1), UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), "393939", 4);
		local LeftBlack   = MakePiece("LeftBlack",   Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(0, 1, 1, 0), "000000", 3);
		local LeftGray    = MakePiece("LeftGray",    Vector2.new(0, 0), UDim2.new(0, 1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
		local RightBlack  = MakePiece("RightBlack",  Vector2.new(1, 0), UDim2.new(1, 0, 0, 0), UDim2.new(0, 1, 1, 0), "000000", 3);
		local RightGray   = MakePiece("RightGray",   Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);

		local Separator = Library:CreateInstance("Frame", {
			Name                   = "Separator";
			Parent                 = Bg;
			AnchorPoint            = Vector2.new(1, 0);
			Position               = UDim2.new(1, 0, 0, 2);
			Size                   = UDim2.new(0, 1, 1, -4);
			BackgroundColor3       = Color3.fromHex("393939");
			BorderSizePixel        = 0;
			BackgroundTransparency = 1;
			ZIndex                 = 2;
		});

		local Lbl = Library:CreateInstance("TextLabel", {
			Name                   = "Label";
			Parent                 = Bg;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			Text                   = TabName;
			TextSize               = 12;
			TextColor3             = Color3.fromHex("8C8F99");
			TextXAlignment         = Enum.TextXAlignment.Center;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

		local TopGradient = Library:CreateInstance("Frame", {
			Name                   = "TopGradient";
			Parent                 = Bg;
			AnchorPoint            = Vector2.new(0, 0);
			Position               = UDim2.new(0, 0, 0, 0);
			Size                   = UDim2.new(1, 0, 0, 1);
			BackgroundColor3       = Color3.fromHex("FFFFFF");
			BorderSizePixel        = 0;
			BackgroundTransparency = 1;
			ZIndex                 = 5;
		});
		local TabTopGradient = Library:CreateInstance("UIGradient", {
			Parent   = TopGradient;
			Rotation = 0;
		});
		Library:RegisterAccentGradient(TabTopGradient);

		local Page = Library:CreateInstance("CanvasGroup", {
			Name                   = "Page_" .. TabName;
			Parent                 = self.Content;
			Position               = UDim2.new(0, 0, 0, 24);
			Size                   = UDim2.new(1, 0, 1, -24);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			Visible                = false;
			GroupTransparency      = 1;
		});
		Library:CreateInstance("UIPadding", {
			Parent        = Page;
			PaddingLeft   = UDim.new(0, 6);
			PaddingRight  = UDim.new(0, 6);
			PaddingTop    = UDim.new(0, 11);
			PaddingBottom = UDim.new(0, 6);
		});

		local LeftColumn = Library:CreateInstance("ScrollingFrame", {
			Name                   = "Left";
			Parent                 = Page;
			AnchorPoint            = Vector2.new(0, 0);
			Position               = UDim2.new(0, 0, 0, -2);
			Size                   = UDim2.new(0.5, -3, 1, 2);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			CanvasSize             = UDim2.new(0, 0, 0, 0);
			AutomaticCanvasSize    = Enum.AutomaticSize.Y;
			ScrollBarThickness     = 0;
			ScrollingDirection     = Enum.ScrollingDirection.Y;
			ClipsDescendants       = true;
		});
		Library:CreateInstance("UIListLayout", {
			Parent        = LeftColumn;
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 6);
		});
		Library:CreateInstance("UIPadding", {
			Parent        = LeftColumn;
			PaddingTop    = UDim.new(0, 4);
			PaddingBottom = UDim.new(0, 6);
		});

		local RightColumn = Library:CreateInstance("ScrollingFrame", {
			Name                   = "Right";
			Parent                 = Page;
			AnchorPoint            = Vector2.new(1, 0);
			Position               = UDim2.new(1, 0, 0, -2);
			Size                   = UDim2.new(0.5, -3, 1, 2);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			CanvasSize             = UDim2.new(0, 0, 0, 0);
			AutomaticCanvasSize    = Enum.AutomaticSize.Y;
			ScrollBarThickness     = 0;
			ScrollingDirection     = Enum.ScrollingDirection.Y;
			ClipsDescendants       = true;
		});
		Library:CreateInstance("UIListLayout", {
			Parent        = RightColumn;
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 6);
		});
		Library:CreateInstance("UIPadding", {
			Parent        = RightColumn;
			PaddingTop    = UDim.new(0, 4);
			PaddingBottom = UDim.new(0, 6);
		});

		local TabRef = {
			Name        = TabName;
			Button      = Btn;
			Bg          = Bg;
			Label       = Lbl;
			Page        = Page;
			Left        = LeftColumn;
			Right       = RightColumn;
			Gradient    = Gradient;
			Separator   = Separator;
			TopBlack    = TopBlack;
			TopGray     = TopGray;
			BottomBlack = BottomBlack;
			BottomGray  = BottomGray;
			LeftBlack   = LeftBlack;
			LeftGray    = LeftGray;
			RightBlack  = RightBlack;
			RightGray   = RightGray;
			TopGradient = TopGradient;
			Active      = false;
			IsLeft      = false;
			IsRight     = false;
		};

		local PageInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local BgInfo   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local InactiveA, InactiveB = Color3.fromHex("1F1F1F"), Color3.fromHex("181818");
		local ActiveA,   ActiveB   = Color3.fromHex("161616"), Color3.fromHex("151515");
		local GradT      = TabRef.Active and 1 or 0;
		local GradTarget = GradT;
		local function ApplyGrad()
			Gradient.Color = NewColorSequence({
				NewColorSequenceKeypoint(0, InactiveA:Lerp(ActiveA, GradT));
				NewColorSequenceKeypoint(1, InactiveB:Lerp(ActiveB, GradT));
			});
		end;
		Gradient.Enabled = true;
		ApplyGrad();
		Library:Connection(RunService.Heartbeat, function(Dt)
			if math.abs(GradTarget - GradT) < 0.001 then
				if GradT ~= GradTarget then GradT = GradTarget; ApplyGrad() end;
				return;
			end;
			GradT = GradT + (GradTarget - GradT) * (1 - math.exp(-Dt * 16));
			ApplyGrad();
		end);

		function TabRef:SetActive(State)
			self.Active = State;
			if State then
				self.Page.Visible = true;
				Library:Tween(self.Page, PageInfo, { GroupTransparency = 0 }):Play();
				local Lo = self.IsLeft  and 1 or 0;
				local Ro = self.IsRight and 1 or 0;
				Library:Tween(Bg, BgInfo, {
					Position = UDim2.new(0, Lo, 0, 1);
					Size     = UDim2.new(1, -Lo - Ro, 1, -1);
				}):Play();
				GradTarget          = 1;
				Bg.BackgroundColor3 = Color3.fromHex("FFFFFF");
				Library:Tween(Lbl, BgInfo, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
				TopGradient.Position = UDim2.new(0, 0, 0, 0);
				TopGradient.Size     = UDim2.new(1, 0, 0, 1);
			else
				local P = self.Page;
				Library:Tween(P, PageInfo, { GroupTransparency = 1 }):Play();
				task.delay(PageInfo.Time, function()
					if not self.Active then P.Visible = false end;
				end);
				Library:Tween(Bg, BgInfo, {
					Position = UDim2.new(0, 0, 0, 0);
					Size     = UDim2.new(1, 0, 1, 0);
				}):Play();
				GradTarget          = 0;
				Bg.BackgroundColor3 = Color3.fromHex("FFFFFF");
				Library:Tween(Lbl, BgInfo, { TextColor3 = Color3.fromHex("8C8F99") }):Play();
			end;
		end;

		function TabRef:Section(SecOpts)
			SecOpts = typeof(SecOpts) == "table" and SecOpts or { Name = tostring(SecOpts) };
			local SecName = tostring(SecOpts.Name or SecOpts.Title or "section");
			local Side    = string.lower(tostring(SecOpts.Side or "Left"));
			local Column  = (Side == "right") and self.Right or self.Left;

			local Sec = Library:CreateInstance("Frame", {
				Name                   = "Section_" .. SecName;
				Parent                 = Column;
				Size                   = UDim2.new(1, 0, 0, 0);
				AutomaticSize          = Enum.AutomaticSize.Y;
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
			});

			local function Edge(Anchor, Pos, Sz, Color)
				Library:CreateInstance("Frame", {
					Parent           = Sec;
					AnchorPoint      = Anchor;
					Position         = Pos;
					Size             = Sz;
					BackgroundColor3 = Color3.fromHex(Color);
					BorderSizePixel  = 0;
					ZIndex           = 5;
				});
			end;
			Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000"); -- top black
			local TopLine = Library:CreateInstance("Frame", {
				Name             = "TopLine";
				Parent           = Sec;
				AnchorPoint      = Vector2.new(0, 0);
				Position         = UDim2.new(0, 0, 0, 1);
				Size             = UDim2.new(1, 0, 0, 1);
				BackgroundColor3 = Color3.fromHex("FFFFFF");
				BorderSizePixel  = 0;
				ZIndex           = 5;
			});
			local SecTopGradient = Library:CreateInstance("UIGradient", {
				Parent   = TopLine;
				Rotation = 0;
			});
			Library:RegisterAccentGradient(SecTopGradient);
			Edge(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000"); -- bottom black
			Edge(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939"); -- bottom gray
			Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000"); -- left black
			Edge(Vector2.new(0, 0), UDim2.new(0, 1, 0, 2),  UDim2.new(0, 1, 1, -3), "393939"); -- left gray
			Edge(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000"); -- right black
			Edge(Vector2.new(1, 0), UDim2.new(1, -1, 0, 2), UDim2.new(0, 1, 1, -3), "393939"); -- right gray

			local TitleCover = Library:CreateInstance("Frame", {
				Name             = "TitleCover";
				Parent           = Sec;
				Position         = UDim2.new(0, 7, 0, 0);
				Size             = UDim2.new(0, 0, 0, 2);
				BackgroundColor3 = Color3.fromHex("161616");
				BorderSizePixel  = 0;
				ZIndex           = 6;
			});

			local GradTop    = Color3.fromHex("161616");
			local GradBottom = Color3.fromHex("101010");
			local function UpdateCoverColor()
				local Ch = self.Page.Parent.AbsoluteSize.Y;
				if Ch <= 0 then return end;
				local T = math.clamp(
					(TitleCover.AbsolutePosition.Y - self.Page.Parent.AbsolutePosition.Y) / Ch,
					0, 1
				);
				TitleCover.BackgroundColor3 = GradTop:Lerp(GradBottom, T);
			end;
			TitleCover:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateCoverColor);
			self.Page.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCoverColor);
			task.defer(UpdateCoverColor);

			local SecTitle = Library:CreateInstance("TextLabel", {
				Name                   = "Title";
				Parent                 = Sec;
				AnchorPoint            = Vector2.new(0, 0.5);
				Position               = UDim2.new(0, 11, 0, 2);
				AutomaticSize          = Enum.AutomaticSize.X;
				Size                   = UDim2.new(0, 0, 0, 14);
				BackgroundTransparency = 1;
				Text                   = SecName;
				TextColor3             = Color3.fromHex("FFFFFF");
				TextSize               = 12;
				TextXAlignment         = Enum.TextXAlignment.Left;
				TextYAlignment         = Enum.TextYAlignment.Center;
				ZIndex                 = 7;
			});
			if ProggyCleanFont then SecTitle.FontFace = ProggyCleanFont end;

			local function UpdateCover()
				TitleCover.Size = UDim2.new(0, SecTitle.AbsoluteSize.X + 8, 0, 2);
			end;
			SecTitle:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCover);
			UpdateCover();

			local Body = Library:CreateInstance("Frame", {
				Name                   = "Body";
				Parent                 = Sec;
				Position               = UDim2.new(0, 8, 0, 12);
				Size                   = UDim2.new(1, -16, 0, 0);
				AutomaticSize          = Enum.AutomaticSize.Y;
				BackgroundTransparency = 1;
			});
			Library:CreateInstance("UIListLayout", {
				Parent        = Body;
				FillDirection = Enum.FillDirection.Vertical;
				SortOrder     = Enum.SortOrder.LayoutOrder;
				Padding       = UDim.new(0, 4);
			});
			Library:CreateInstance("UIPadding", {
				Parent        = Body;
				PaddingBottom = UDim.new(0, 8);
			});

			local SecRef = { Name = SecName, Frame = Sec, Title = SecTitle, Body = Body };

			function SecRef:Toggle(Opts)
				Opts = typeof(Opts) == "table" and Opts or {};
				local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Toggle");
				local Default  = Opts.Default == true;
				local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
				local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
				local State    = Default;
				Library.Flags[Flag] = State;

				local Risk = Opts.Risk and string.lower(tostring(Opts.Risk))
					or (Opts.Risky and "risky") or (Opts.Warning and "warning") or nil;
				local OnColor  = Color3.fromHex("FFFFFF");
				local OffColor = Color3.fromHex("8C8F99");
				if Risk == "risky" or Risk == "danger" or Risk == "red" then
					OnColor  = Color3.fromHex("FF8585");
					OffColor = OnColor:Lerp(Color3.fromHex("4A4A4A"), 0.45);
				elseif Risk == "warning" or Risk == "warn" or Risk == "yellow" then
					OnColor  = Color3.fromHex("FFD27B");
					OffColor = OnColor:Lerp(Color3.fromHex("4A4A4A"), 0.45);
				end;

				local Row = Library:CreateInstance("TextButton", {
					Name                   = "Toggle_" .. Name;
					Parent                 = self.Body;
					Size                   = UDim2.new(1, 0, 0, 16);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					AutoButtonColor        = false;
					Text                   = "";
				});

				local Box = Library:CreateInstance("Frame", {
					Name             = "Box";
					Parent           = Row;
					AnchorPoint      = Vector2.new(0, 0.5);
					Position         = UDim2.new(0, 0, 0.5, 0);
					Size             = UDim2.fromOffset(14, 14);
					BackgroundColor3 = Color3.fromHex("000000");
					BorderSizePixel  = 0;
				});
				local BoxGray = Library:CreateInstance("Frame", {
					Name             = "Gray";
					Parent           = Box;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
				});
				local BoxInside = Library:CreateInstance("Frame", {
					Name             = "Inside";
					Parent           = BoxGray;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("131313");
					BorderSizePixel  = 0;
				});

				local Fill = Library:CreateInstance("Frame", {
					Name                   = "Fill";
					Parent                 = BoxInside;
					AnchorPoint            = Vector2.new(0.5, 0.5);
					Position               = UDim2.new(0.5, 0, 0.5, 0);
					Size                   = UDim2.new(0, 0, 0, 0);
					BackgroundColor3       = Color3.fromHex("3972EC");
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
				});
				Library:RegisterAccent(Fill);

				local Lbl = Library:CreateInstance("TextLabel", {
					Name                   = "Label";
					Parent                 = Row;
					AnchorPoint            = Vector2.new(0, 0.5);
					Position               = UDim2.new(0, 20, 0.5, 0);
					Size                   = UDim2.new(1, -20, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					Text                   = Name;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
				});
				if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

				local TweenIn  = TweenInfo.new(0.16, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out);
				local TweenOut = TweenInfo.new(0.14, Enum.EasingStyle.Quad,  Enum.EasingDirection.In);

				local function Render()
					local Info = State and TweenIn or TweenOut;
					Library:Tween(Fill, Info, {
						Size                   = State and UDim2.new(1, -2, 1, -2) or UDim2.new(0, 0, 0, 0);
						BackgroundTransparency = State and 0 or 1;
					}):Play();
					Library:Tween(Lbl, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextColor3 = State and OnColor or OffColor;
					}):Play();
				end;
				-- initial state without animation
				Fill.Size                   = State and UDim2.new(1, -2, 1, -2) or UDim2.new(0, 0, 0, 0);
				Fill.BackgroundTransparency = State and 0 or 1;
				Lbl.TextColor3              = State and OnColor or OffColor;

				local Listeners = {};
				local function SetState(V, Fire)
					V = V == true;
					if V == State then return end;
					State = V;
					Library.Flags[Flag] = State;
					Render();
					if Fire ~= false then Callback(State) end;
					for _, Fn in Listeners do Fn(State) end;
				end;

				Row.MouseButton1Click:Connect(function() SetState(not State) end);

				if Opts.Tooltip then Library:Tooltip(Row, Opts.Tooltip) end;

				local Obj = { Container = Row, Box = Box, Fill = Fill };
				function Obj:Get() return State end;
				function Obj:Set(V) SetState(V) end;
				function Obj:OnChange(Fn)
					if typeof(Fn) ~= "function" then return end;
					table.insert(Listeners, Fn);
					Fn(State);
				end;

				function Obj:AddKeybind(BindOpts)
					if self._HasKeybind then return self end;
					self._HasKeybind = true;
					BindOpts = typeof(BindOpts) == "table" and BindOpts or {};
					local BindMode = string.lower(tostring(BindOpts.Mode or "Toggle"));
					local Key      = BindOpts.Default;

					local function KeyText(K)
						if K == nil then return "None" end;
						if typeof(K) == "EnumItem" then return Library.KeyNames[K] or K.Name end;
						return tostring(K);
					end;

					local KBoxW = 48;
					local Off = self._RightOffset or 0;

					local KBtn = Library:CreateInstance("TextButton", {
						Name             = "Keybind";
						Parent           = Row;
						AnchorPoint      = Vector2.new(1, 0.5);
						Position         = UDim2.new(1, -Off, 0.5, 0);
						Size             = UDim2.fromOffset(KBoxW, 16);
						BackgroundColor3 = Color3.fromHex("000000");
						BorderSizePixel  = 0;
						AutoButtonColor  = false;
						Text             = "";
					});
					local KGray = Library:CreateInstance("Frame", {
						Name             = "Gray";
						Parent           = KBtn;
						Position         = UDim2.new(0, 1, 0, 1);
						Size             = UDim2.new(1, -2, 1, -2);
						BackgroundColor3 = Color3.fromHex("393939");
						BorderSizePixel  = 0;
					});
					local KInside = Library:CreateInstance("Frame", {
						Name             = "Inside";
						Parent           = KGray;
						Position         = UDim2.new(0, 1, 0, 1);
						Size             = UDim2.new(1, -2, 1, -2);
						BackgroundColor3 = Color3.fromHex("FFFFFF");
						BorderSizePixel  = 0;
					});
					Library:CreateInstance("UIGradient", {
						Parent   = KInside;
						Rotation = 90;
						Color    = NewColorSequence({
							NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
							NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
						});
					});
					local KLbl = Library:CreateInstance("TextLabel", {
						Name                   = "Display";
						Parent                 = KInside;
						Size                   = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						Text                   = KeyText(Key);
						TextColor3             = Color3.fromHex("FFFFFF");
						TextSize               = 12;
						TextXAlignment         = Enum.TextXAlignment.Center;
						TextYAlignment         = Enum.TextYAlignment.Center;
					});
					if ProggyCleanFont then KLbl.FontFace = ProggyCleanFont end;

					local Listening = false;
					local ListenConn;
					local function Refresh()
						if Listening then
							KLbl.Text       = "...";
							KLbl.TextColor3 = Library.Accent;
						else
							KLbl.Text       = KeyText(Key);
							KLbl.TextColor3 = Color3.fromHex("FFFFFF");
						end;
					end;
					local function CancelListen()
						if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
						Listening = false;
						Refresh();
					end;
					local function StartListen()
						if Listening then CancelListen(); return end;
						Listening = true;
						Refresh();
						task.defer(function()
							if not Listening then return end;
							ListenConn = UserInputService.InputBegan:Connect(function(Input)
								local T = Input.UserInputType;
								if T == Enum.UserInputType.Keyboard then
									local K = Input.KeyCode;
									if K == Enum.KeyCode.Escape then
										CancelListen();
									else
										Key = K;
										Listening = false;
										if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
										Refresh();
										Library:NotifyKeybind();
									end;
								elseif T == Enum.UserInputType.MouseButton1
									or T == Enum.UserInputType.MouseButton2
									or T == Enum.UserInputType.MouseButton3 then
									Key = T;
									Listening = false;
									if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
									Refresh();
									Library:NotifyKeybind();
								end;
							end);
						end);
					end;

					KBtn.MouseButton1Click:Connect(StartListen);
					KBtn.MouseButton2Click:Connect(function()
						if Listening then CancelListen() end;
						Key = nil;
						Refresh();
						Library:NotifyKeybind();
					end);

					local function KeyMatches(Input)
						if Key == nil or typeof(Key) ~= "EnumItem" then return false end;
						if Key.EnumType == Enum.KeyCode then
							return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key;
						elseif Key.EnumType == Enum.UserInputType then
							return Input.UserInputType == Key;
						end;
						return false;
					end;
					Library:Connection(UserInputService.InputBegan, function(Input, GameProc)
						if GameProc then return end;
						if Listening then return end;
						if UserInputService:GetFocusedTextBox() then return end;
						if not KeyMatches(Input) then return end;
						if BindMode == "hold" then
							SetState(true);
						else
							SetState(not State);
						end;
					end);
					Library:Connection(UserInputService.InputEnded, function(Input)
						if BindMode ~= "hold" then return end;
						if not KeyMatches(Input) then return end;
						SetState(false);
					end);

					Library:RegisterKeybind({
						Name     = Name;
						Mode     = BindMode;
						GetKey   = function() return Key end;
						GetState = function() return State end;
					});

					self._RightOffset = Off + KBoxW + 4;
					Lbl.Size = UDim2.new(1, -20 - self._RightOffset, 1, 0);
					self.Keybind        = KBtn;
					self.KeybindDisplay = KLbl;
					return self;
				end;

				function Obj:AddColorpicker(CpOpts)
					CpOpts = typeof(CpOpts) == "table" and CpOpts or {};
					local Color    = typeof(CpOpts.Default) == "Color3" and CpOpts.Default or Color3.fromRGB(255,255,255);
					local Alpha    = tonumber(CpOpts.Alpha) or 1;
					local Callback = typeof(CpOpts.Callback) == "function" and CpOpts.Callback or function() end;
					self._Colors   = (self._Colors or 0) + 1;
					local Flag     = tostring(CpOpts.Flag or CpOpts.Pointer or ("_" .. Name .. "Color" .. self._Colors));
					local H, Sa, Va = Color3.toHSV(Color);
					local A         = math.clamp(Alpha, 0, 1);
					Library.Flags[Flag] = Color;

					local SwW, SwH = 25, 15;
					local Off = self._RightOffset or 0;

					local Swatch = Library:CreateInstance("TextButton", {
						Name             = "ToggleSwatch";
						Parent           = Row;
						AnchorPoint      = Vector2.new(1, 0.5);
						Position         = UDim2.new(1, -Off, 0.5, 0);
						Size             = UDim2.fromOffset(SwW, SwH);
						AutoButtonColor  = false;
						Text             = "";
						BackgroundColor3 = Color3.fromHex("000105");
						BorderSizePixel  = 0;
					});
					local SwInline = Library:CreateInstance("Frame", {
						Parent           = Swatch;
						Position         = UDim2.new(0, 1, 0, 1);
						Size             = UDim2.new(1, -2, 1, -2);
						BackgroundColor3 = Color3.fromHex("252527");
						BorderSizePixel  = 0;
					});
					local SwHandle = Library:CreateInstance("Frame", {
						Parent           = SwInline;
						Position         = UDim2.new(0, 1, 0, 1);
						Size             = UDim2.new(1, -2, 1, -2);
						BackgroundColor3 = Color3.fromRGB(255, 255, 255);
						BorderSizePixel  = 0;
					});
					Library:CreateInstance("ImageLabel", {
						Parent                 = SwHandle;
						Size                   = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
						Image                  = "rbxassetid://18274452449";
						ScaleType              = Enum.ScaleType.Tile;
						TileSize               = UDim2.new(0, 6, 0, 6);
						ZIndex                 = 2;
					});
					local SwFill = Library:CreateInstance("Frame", {
						Parent                 = SwHandle;
						Size                   = UDim2.new(1, 0, 1, 0);
						BackgroundColor3       = Color;
						BackgroundTransparency = 1 - Alpha;
						BorderSizePixel        = 0;
						ZIndex                 = 3;
					});
					Library:CreateInstance("UIGradient", {
						Parent   = SwFill;
						Rotation = 90;
						Color    = NewColorSequence({
							NewColorSequenceKeypoint(0, Color3.fromRGB(255, 255, 255));
							NewColorSequenceKeypoint(1, Color3.fromRGB(167, 167, 167));
						});
					});

					self._RightOffset = Off + SwW + 4;
					Lbl.Size = UDim2.new(1, -20 - self._RightOffset, 1, 0);

					local PickerHolder = Library:CreateInstance("CanvasGroup", {
						Name              = "TogglePicker";
						Parent            = Gui;
						Size              = UDim2.new(0, 218, 0, 248);
						BackgroundColor3  = Color3.fromHex("131313");
						BorderSizePixel   = 0;
						Visible           = false;
						GroupTransparency = 1;
						ZIndex            = 50;
					});
					local PickerOuterStroke = Library:CreateInstance("UIStroke", {
						Parent          = PickerHolder;
						Color           = Color3.fromHex("000000");
						Thickness       = 1;
						Transparency    = 1;
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					});
					local PickerInner = Library:CreateInstance("Frame", {
						Parent                 = PickerHolder;
						Position               = UDim2.new(0, 1, 0, 1);
						Size                   = UDim2.new(1, -2, 1, -2);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
					});
					local PickerInnerStroke = Library:CreateInstance("UIStroke", {
						Parent          = PickerInner;
						Color           = Color3.fromHex("393939");
						Thickness       = 1;
						Transparency    = 1;
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					});
					local PickerBody = Library:CreateInstance("Frame", {
						Parent                 = PickerHolder;
						Size                   = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
					});
					Library:CreateInstance("UIPadding", {
						Parent        = PickerBody;
						PaddingTop    = UDim.new(0, 8);
						PaddingBottom = UDim.new(0, 8);
						PaddingLeft   = UDim.new(0, 8);
						PaddingRight  = UDim.new(0, 8);
					});
					local MainBg = Library:CreateInstance("Frame", {
						Parent                 = PickerBody;
						Size                   = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
					});

					local TabBar = Library:CreateInstance("Frame", {
						Name                   = "TabBar";
						Parent                 = MainBg;
						Position               = UDim2.new(0, 0, 0, 0);
						Size                   = UDim2.new(1, 0, 0, 20);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
					});
					local CpInactiveSeq = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
						NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
					});
					local CpActiveSeq = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
						NewColorSequenceKeypoint(1, Color3.fromHex("151515"));
					});
					local CpAnimInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
					local CpInactiveA, CpInactiveB = Color3.fromHex("1F1F1F"), Color3.fromHex("181818");
					local CpActiveA,   CpActiveB   = Color3.fromHex("161616"), Color3.fromHex("151515");
					local CpOutlineNames = { "TopBlack", "TopGray", "BottomBlack", "BottomGray", "LeftBlack", "LeftGray", "RightBlack", "RightGray" };
					local ColorPage, AnimationsPanel;
					local CpTabToken = 0;

					local TabButtons = {};
					local function MakeCpTab(Name, Idx, Total)
						local Btn = Library:CreateInstance("TextButton", {
							Parent                 = TabBar;
							Size                   = UDim2.new(1 / Total, 0, 1, 0);
							Position               = UDim2.new((Idx - 1) / Total, 0, 0, 0);
							BackgroundTransparency = 1;
							BorderSizePixel        = 0;
							AutoButtonColor        = false;
							Text                   = "";
						});
						local Bg = Library:CreateInstance("Frame", {
							Name             = "Bg";
							Parent           = Btn;
							Size             = UDim2.new(1, 0, 1, 0);
							BackgroundColor3 = Color3.fromHex("FFFFFF");
							BorderSizePixel  = 0;
						});
						local BgGrad = Library:CreateInstance("UIGradient", {
							Parent   = Bg;
							Rotation = 90;
							Color    = CpInactiveSeq;
						});
						local function MakePiece(Anchor, Pos, Sz, Color, ZIdx)
							return Library:CreateInstance("Frame", {
								Parent                 = Bg;
								AnchorPoint            = Anchor;
								Position               = Pos;
								Size                   = Sz;
								BackgroundColor3       = Color3.fromHex(Color);
								BorderSizePixel        = 0;
								BackgroundTransparency = 1;
								ZIndex                 = ZIdx;
							});
						end;
						local TopBlack    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
						local TopGray     = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(1, -2, 0, 1), "393939", 4);
						local BottomBlack = MakePiece(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
						local BottomGray  = MakePiece(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939", 4);
						local LeftBlack   = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
						local LeftGray    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(0, 1, 1, -2), "393939", 3);
						local RightBlack  = MakePiece(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
						local RightGray   = MakePiece(Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
						local TopGradient = Library:CreateInstance("Frame", {
							Parent                 = Bg;
							AnchorPoint            = Vector2.new(0, 0);
							Position               = UDim2.new(0, 0, 0, 0);
							Size                   = UDim2.new(1, 0, 0, 1);
							BackgroundColor3       = Color3.fromHex("FFFFFF");
							BorderSizePixel        = 0;
							BackgroundTransparency = 1;
							ZIndex                 = 5;
						});
						local Grad = Library:CreateInstance("UIGradient", { Parent = TopGradient; Rotation = 0 });
						Library:RegisterAccentGradient(Grad);
						local Lbl = Library:CreateInstance("TextLabel", {
							Name                   = "Label";
							Parent                 = Bg;
							Size                   = UDim2.new(1, 0, 1, 0);
							BackgroundTransparency = 1;
							BorderSizePixel        = 0;
							Text                   = Name;
							TextSize               = 12;
							TextColor3             = Color3.fromHex("FFFFFF");
							TextXAlignment         = Enum.TextXAlignment.Center;
							TextYAlignment         = Enum.TextYAlignment.Center;
							ZIndex                 = 6;
						});
						if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

						local Entry = {
							Btn = Btn, Bg = Bg, Lbl = Lbl, BgGrad = BgGrad, TopGradient = TopGradient;
							TopBlack = TopBlack, TopGray = TopGray;
							BottomBlack = BottomBlack, BottomGray = BottomGray;
							LeftBlack = LeftBlack, LeftGray = LeftGray;
							RightBlack = RightBlack, RightGray = RightGray;
							GradT = 0; GradTarget = 0;
						};
						local function ApplyGrad()
							BgGrad.Color = NewColorSequence({
								NewColorSequenceKeypoint(0, CpInactiveA:Lerp(CpActiveA, Entry.GradT));
								NewColorSequenceKeypoint(1, CpInactiveB:Lerp(CpActiveB, Entry.GradT));
							});
						end;
						ApplyGrad();
						Library:Connection(RunService.Heartbeat, function(Dt)
							if math.abs(Entry.GradTarget - Entry.GradT) < 0.001 then
								if Entry.GradT ~= Entry.GradTarget then
									Entry.GradT = Entry.GradTarget;
									ApplyGrad();
								end;
								return;
							end;
							Entry.GradT = Entry.GradT + (Entry.GradTarget - Entry.GradT) * (1 - math.exp(-Dt * 16));
							ApplyGrad();
						end);
						table.insert(TabButtons, Entry);
						return Btn;
					end;
					local ColorTabBtn = MakeCpTab("Color", 1, 2);
					local AnimationsTabBtn = MakeCpTab("Animations", 2, 2);

					local function SetCpTab(I)
						for i, T in TabButtons do
							if i == I then
								T.GradTarget = 1;
								Library:Tween(T.TopGradient, CpAnimInfo, { BackgroundTransparency = 0 }):Play();
								for _, N in CpOutlineNames do
									Library:Tween(T[N], CpAnimInfo, { BackgroundTransparency = 1 }):Play();
								end;
							else
								T.GradTarget = 0;
								Library:Tween(T.TopGradient, CpAnimInfo, { BackgroundTransparency = 1 }):Play();
								for _, N in CpOutlineNames do
									Library:Tween(T[N], CpAnimInfo, { BackgroundTransparency = 0 }):Play();
								end;
							end;
						end;
						if ColorPage and AnimationsPanel then
							CpTabToken = CpTabToken + 1;
							local Mine = CpTabToken;
							ColorPage.Visible       = true;
							AnimationsPanel.Visible = true;
							if I == 1 then
								Library:Tween(ColorPage,       CpAnimInfo, { GroupTransparency = 0 }):Play();
								Library:Tween(AnimationsPanel, CpAnimInfo, { GroupTransparency = 1 }):Play();
							else
								Library:Tween(ColorPage,       CpAnimInfo, { GroupTransparency = 1 }):Play();
								Library:Tween(AnimationsPanel, CpAnimInfo, { GroupTransparency = 0 }):Play();
							end;
							task.delay(CpAnimInfo.Time, function()
								if CpTabToken ~= Mine then return end;
								if I == 1 then AnimationsPanel.Visible = false end;
								if I == 2 then ColorPage.Visible       = false end;
							end);
						end;
					end;
					SetCpTab(1);
					ColorTabBtn.MouseButton1Click:Connect(function() SetCpTab(1) end);
					AnimationsTabBtn.MouseButton1Click:Connect(function() SetCpTab(2) end);

					ColorPage = Library:CreateInstance("CanvasGroup", {
						Name                   = "ColorPage";
						Parent                 = MainBg;
						Size                   = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
						GroupTransparency      = 0;
						ZIndex                 = 54;
					});

					local SatValArea = Library:CreateInstance("Frame", {
						Parent           = ColorPage;
						Position         = UDim2.new(0, 0, 0, 24);
						Size             = UDim2.new(1, -30, 1, -66);
						BackgroundColor3 = Color3.fromRGB(255, 0, 0);
						BorderSizePixel  = 0;
					});
					Library:CreateInstance("UIStroke", {
						Parent          = SatValArea;
						Color           = Color3.fromHex("000105");
						Thickness       = 1;
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					});
					local SatLayer = Library:CreateInstance("TextButton", {
						Parent           = SatValArea;
						Size             = UDim2.new(1, 0, 1, 0);
						BackgroundColor3 = Color3.fromRGB(255, 255, 255);
						BorderSizePixel  = 0;
						AutoButtonColor  = false;
						Text             = "";
					});
					Library:CreateInstance("UIGradient", {
						Parent       = SatLayer;
						Rotation     = 270;
						Transparency = NewNumberSequence({
							NewNumberSequenceKeypoint(0, 0);
							NewNumberSequenceKeypoint(1, 1);
						});
						Color = NewColorSequence({
							NewColorSequenceKeypoint(0, Color3.fromRGB(0, 0, 0));
							NewColorSequenceKeypoint(1, Color3.fromRGB(0, 0, 0));
						});
					});
					local ValLayer = Library:CreateInstance("TextButton", {
						Parent           = SatValArea;
						Size             = UDim2.new(1, 0, 1, 0);
						BackgroundColor3 = Color3.fromRGB(255, 255, 255);
						BorderSizePixel  = 0;
						AutoButtonColor  = false;
						Text             = "";
					});
					Library:CreateInstance("UIGradient", {
						Parent       = ValLayer;
						Transparency = NewNumberSequence({
							NewNumberSequenceKeypoint(0, 0);
							NewNumberSequenceKeypoint(1, 1);
						});
					});
					local SatValMarker = Library:CreateInstance("Frame", {
						Parent           = SatValArea;
						Size             = UDim2.new(0, 2, 0, 2);
						BorderSizePixel  = 1;
						BorderColor3     = Color3.fromRGB(0, 0, 0);
						BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					});
					local HueArea = Library:CreateInstance("TextButton", {
						Parent           = ColorPage;
						AnchorPoint      = Vector2.new(1, 0);
						Position         = UDim2.new(1, -14, 0, 24);
						Size             = UDim2.new(0, 12, 1, -66);
						BackgroundColor3 = Color3.fromRGB(255, 255, 255);
						BorderSizePixel  = 0;
						AutoButtonColor  = false;
						Text             = "";
					});
					Library:CreateInstance("UIStroke", {
						Parent          = HueArea;
						Color           = Color3.fromHex("000105");
						Thickness       = 1;
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					});
					Library:CreateInstance("UIGradient", {
						Parent   = HueArea;
						Rotation = 270;
						Color    = NewColorSequence({
							NewColorSequenceKeypoint(0,    Color3.fromRGB(255, 0, 0));
							NewColorSequenceKeypoint(0.17, Color3.fromRGB(255, 255, 0));
							NewColorSequenceKeypoint(0.33, Color3.fromRGB(0, 255, 0));
							NewColorSequenceKeypoint(0.5,  Color3.fromRGB(0, 255, 255));
							NewColorSequenceKeypoint(0.67, Color3.fromRGB(0, 0, 255));
							NewColorSequenceKeypoint(0.83, Color3.fromRGB(255, 0, 255));
							NewColorSequenceKeypoint(1,    Color3.fromRGB(255, 0, 0));
						});
					});
					local HueMarker = Library:CreateInstance("Frame", {
						Parent           = HueArea;
						Size             = UDim2.new(1, 0, 0, 2);
						BorderSizePixel  = 1;
						BorderColor3     = Color3.fromRGB(0, 0, 0);
						BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					});
					local AlphaArea = Library:CreateInstance("TextButton", {
						Parent           = ColorPage;
						AnchorPoint      = Vector2.new(1, 0);
						Position         = UDim2.new(1, 0, 0, 24);
						Size             = UDim2.new(0, 12, 1, -66);
						BackgroundColor3 = Color;
						BorderSizePixel  = 0;
						AutoButtonColor  = false;
						Text             = "";
					});
					Library:CreateInstance("UIStroke", {
						Parent          = AlphaArea;
						Color           = Color3.fromHex("000105");
						Thickness       = 1;
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					});
					local AlphaCheckers = Library:CreateInstance("ImageLabel", {
						Parent                 = AlphaArea;
						Size                   = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
						Image                  = "rbxassetid://18274452449";
						ScaleType              = Enum.ScaleType.Tile;
						TileSize               = UDim2.new(0, 6, 0, 6);
					});
					Library:CreateInstance("UIGradient", {
						Parent       = AlphaCheckers;
						Rotation     = 270;
						Transparency = NewNumberSequence({
							NewNumberSequenceKeypoint(0, 0);
							NewNumberSequenceKeypoint(1, 1);
						});
					});
					local AlphaMarker = Library:CreateInstance("Frame", {
						Parent           = AlphaArea;
						Size             = UDim2.new(1, 0, 0, 2);
						BackgroundColor3 = Color3.fromRGB(255, 255, 255);
						BorderSizePixel  = 1;
						BorderColor3     = Color3.fromRGB(0, 0, 0);
					});

					local function MakeInput(YOffFromBottom)
						local Box = Library:CreateInstance("Frame", {
							Parent           = ColorPage;
							AnchorPoint      = Vector2.new(0, 1);
							Position         = UDim2.new(0, 0, 1, -YOffFromBottom);
							Size             = UDim2.new(1, 0, 0, 18);
							BackgroundColor3 = Color3.fromHex("000000");
							BorderSizePixel  = 0;
						});
						local Gray = Library:CreateInstance("Frame", {
							Parent           = Box;
							Position         = UDim2.new(0, 1, 0, 1);
							Size             = UDim2.new(1, -2, 1, -2);
							BackgroundColor3 = Color3.fromHex("393939");
							BorderSizePixel  = 0;
						});
						local Inside = Library:CreateInstance("Frame", {
							Parent           = Gray;
							Position         = UDim2.new(0, 1, 0, 1);
							Size             = UDim2.new(1, -2, 1, -2);
							BackgroundColor3 = Color3.fromHex("FFFFFF");
							BorderSizePixel  = 0;
						});
						Library:CreateInstance("UIGradient", {
							Parent   = Inside;
							Rotation = 90;
							Color    = NewColorSequence({
								NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
								NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
							});
						});
						local Input = Library:CreateInstance("TextBox", {
							Parent                 = Inside;
							Size                   = UDim2.new(1, -6, 1, 0);
							Position               = UDim2.new(0, 3, 0, 0);
							BackgroundTransparency = 1;
							BorderSizePixel        = 0;
							ClearTextOnFocus       = false;
							Text                   = "";
							PlaceholderColor3      = Color3.fromHex("5E626B");
							TextColor3             = Color3.fromHex("FFFFFF");
							TextSize               = 12;
							TextXAlignment         = Enum.TextXAlignment.Center;
							TextYAlignment         = Enum.TextYAlignment.Center;
							ClipsDescendants       = true;
						});
						if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;
						return Input, Box;
					end;

					local HexInput, HexBox = MakeInput(0);
					HexInput.PlaceholderText = "Hex";
					local RgbInput, RgbBox = MakeInput(20);
					RgbInput.PlaceholderText = "R, G, B";

					AnimationsPanel = Library:CreateInstance("CanvasGroup", {
						Name              = "AnimationsPanel";
						Parent            = MainBg;
						Position          = UDim2.new(0, 0, 0, 28);
						Size              = UDim2.new(1, 0, 1, -28);
						BackgroundColor3  = Color3.fromHex("131313");
						BorderSizePixel   = 0;
						Visible           = false;
						GroupTransparency = 1;
						ZIndex            = 55;
					});
					local Mode  = "Solid";
					local Speed = 50;
					local function FontIt(L) if ProggyCleanFont then L.FontFace = ProggyCleanFont end end;
					local function AnimLbl(Text, Y)
						local L = Library:CreateInstance("TextLabel", {
							Parent                 = AnimationsPanel;
							Position               = UDim2.new(0, 0, 0, Y);
							Size                   = UDim2.new(1, 0, 0, 12);
							BackgroundTransparency = 1;
							Text                   = Text;
							TextColor3             = Color3.fromHex("FFFFFF");
							TextSize               = 12;
							TextXAlignment         = Enum.TextXAlignment.Left;
						});
						FontIt(L);
					end;

					AnimLbl("Mode", 0);
					local ModeBox = Library:CreateInstance("TextButton", {
						Parent           = AnimationsPanel;
						Position         = UDim2.new(0, 0, 0, 14);
						Size             = UDim2.new(1, 0, 0, 21);
						BackgroundColor3 = Color3.fromHex("000000");
						BorderSizePixel  = 0;
						AutoButtonColor  = false;
						Text             = "";
					});
					local ModeBoxGray = Library:CreateInstance("Frame", {
						Parent = ModeBox; Position = UDim2.new(0, 1, 0, 1);
						Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
					});
					local ModeInside = Library:CreateInstance("Frame", {
						Parent = ModeBoxGray; Position = UDim2.new(0, 1, 0, 1);
						Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
					});
					Library:CreateInstance("UIGradient", {
						Parent = ModeInside; Rotation = 90;
						Color = NewColorSequence({
							NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
							NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
						});
					});
					local ModeVal = Library:CreateInstance("TextLabel", {
						Parent = ModeInside; Position = UDim2.new(0, 4, 0, 0); Size = UDim2.new(1, -14, 1, 0);
						BackgroundTransparency = 1; Text = Mode; TextColor3 = Color3.fromHex("FFFFFF"); TextSize = 12;
						TextXAlignment = Enum.TextXAlignment.Left; TextYAlignment = Enum.TextYAlignment.Center;
					}); FontIt(ModeVal);
					local ModeArrow = Library:CreateInstance("Frame", {
						Parent = ModeInside; AnchorPoint = Vector2.new(1, 0.5);
						Position = UDim2.new(1, -4, 0.5, 0); Size = UDim2.fromOffset(7, 7);
						BackgroundTransparency = 1; BorderSizePixel = 0;
					});
					Library:CreateInstance("Frame", {
						Parent = ModeArrow; AnchorPoint = Vector2.new(0.5, 0.5);
						Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.fromOffset(7, 1);
						BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
					});
					local ModeArrowV = Library:CreateInstance("Frame", {
						Parent = ModeArrow; AnchorPoint = Vector2.new(0.5, 0.5);
						Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.fromOffset(1, 7);
						BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
					});
					local function SetModeArrow(Plus) ModeArrowV.Visible = Plus end;

					local ModePopup = Library:CreateInstance("CanvasGroup", {
						Parent            = AnimationsPanel;
						Position          = UDim2.new(0, 0, 0, 36);
						Size              = UDim2.new(1, 0, 0, 44);
						BackgroundColor3  = Color3.fromHex("000000");
						BorderSizePixel   = 0;
						Visible           = false;
						GroupTransparency = 1;
						ZIndex            = 60;
					});
					local ModePopupGray = Library:CreateInstance("Frame", {
						Parent = ModePopup; Position = UDim2.new(0, 1, 0, 1);
						Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0; ZIndex = 60;
					});
					local ModePopupInside = Library:CreateInstance("Frame", {
						Parent = ModePopupGray; Position = UDim2.new(0, 1, 0, 1);
						Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("131313"); BorderSizePixel = 0; ZIndex = 61;
					});
					Library:CreateInstance("UIListLayout", {
						Parent = ModePopupInside; FillDirection = Enum.FillDirection.Vertical;
						SortOrder = Enum.SortOrder.LayoutOrder; Padding = UDim.new(0, 0);
					});
					local ModeOptionBtns = {};
					local function RefreshModeOpts()
						for N, B in ModeOptionBtns do
							B.TextColor3 = (N == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
						end;
					end;
					Library:OnAccent(function() RefreshModeOpts() end);
					local ModePopupOpen = false;
					local ModePopupToken = 0;
					local ModePopupInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
					local ModePopupBaseY = 36;
					local ModePopupSlide = 6;
					local function CloseModePopup()
						if not ModePopupOpen then return end;
						ModePopupOpen = false;
						ModePopupToken = ModePopupToken + 1;
						local Mine = ModePopupToken;
						SetModeArrow(true);
						Library:Tween(ModePopup, ModePopupInfo, {
							GroupTransparency = 1;
							Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
						}):Play();
						task.delay(ModePopupInfo.Time, function()
							if ModePopupToken == Mine then ModePopup.Visible = false end;
						end);
					end;
					local function OpenModePopup()
						if ModePopupOpen then return end;
						ModePopupOpen = true;
						ModePopupToken = ModePopupToken + 1;
						SetModeArrow(false);
						ModePopup.GroupTransparency = 1;
						ModePopup.Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
						ModePopup.Visible           = true;
						Library:Tween(ModePopup, ModePopupInfo, {
							GroupTransparency = 0;
							Position          = UDim2.new(0, 0, 0, ModePopupBaseY);
						}):Play();
					end;
					local function AddModeOpt(Name, Idx)
						local Btn = Library:CreateInstance("TextButton", {
							Parent = ModePopupInside; Size = UDim2.new(1, 0, 0, 14);
							BackgroundTransparency = 1; BorderSizePixel = 0; AutoButtonColor = false;
							Text = Name; TextColor3 = (Name == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
							TextSize = 12; TextXAlignment = Enum.TextXAlignment.Left; LayoutOrder = Idx; ZIndex = 62;
						});
						Library:CreateInstance("UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 5) });
						FontIt(Btn);
						ModeOptionBtns[Name] = Btn;
						Btn.MouseButton1Click:Connect(function()
							Mode = Name; ModeVal.Text = Mode; RefreshModeOpts();
							CloseModePopup();
						end);
					end;
					AddModeOpt("Solid",   1);
					AddModeOpt("Rainbow", 2);
					AddModeOpt("Fading",  3);
					ModeBox.MouseButton1Click:Connect(function()
						if ModePopupOpen then CloseModePopup() else OpenModePopup() end;
					end);

					AnimLbl("Speed", 42);
					local SpeedVal = Library:CreateInstance("TextLabel", {
						Parent = AnimationsPanel; AnchorPoint = Vector2.new(1, 0);
						Position = UDim2.new(1, 0, 0, 42); Size = UDim2.new(0, 40, 0, 12);
						BackgroundTransparency = 1; Text = "50%"; TextColor3 = Color3.fromHex("8C8F99"); TextSize = 12;
						TextXAlignment = Enum.TextXAlignment.Right;
					}); FontIt(SpeedVal);
					local SpTrack = Library:CreateInstance("TextButton", {
						Parent = AnimationsPanel; Position = UDim2.new(0, 0, 0, 58);
						Size = UDim2.new(1, 0, 0, 10); BackgroundColor3 = Color3.fromHex("000000");
						BorderSizePixel = 0; AutoButtonColor = false; Text = "";
					});
					Library:CreateInstance("Frame", {
						Parent = SpTrack; Position = UDim2.new(0, 1, 0, 1);
						Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
					});
					local SpInside = Library:CreateInstance("Frame", {
						Parent = SpTrack:FindFirstChildOfClass("Frame"); Position = UDim2.new(0, 1, 0, 1);
						Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("131313"); BorderSizePixel = 0;
					});
					local SpFill = Library:CreateInstance("Frame", {
						Parent = SpInside; Position = UDim2.new(0, 1, 0, 1);
						Size = UDim2.new(0.5, -2, 1, -2); BackgroundColor3 = Library.Accent; BorderSizePixel = 0;
					});
					Library:RegisterAccent(SpFill);
					local SpDragging = false;
					local SpVisualT = 0.5;
					local SpTargetT = 0.5;
					Library:Connection(RunService.Heartbeat, function(Dt)
						if math.abs(SpTargetT - SpVisualT) < 0.001 then return end;
						local Alpha = 1 - math.exp(-Dt * 14);
						SpVisualT = SpVisualT + (SpTargetT - SpVisualT) * Alpha;
						SpFill.Size = UDim2.new(SpVisualT, -2, 1, -2);
					end);
					local function SpUpdate(Px)
						local Ax, Aw = SpInside.AbsolutePosition.X, SpInside.AbsoluteSize.X;
						if Aw <= 0 then return end;
						local T = math.clamp((Px - Ax) / Aw, 0, 1);
						Speed = math.floor(T * 100 + 0.5);
						SpTargetT = T;
						SpeedVal.Text = Speed .. "%";
					end;
					Library:Connection(SpTrack.InputBegan, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							SpDragging = true; SpUpdate(Input.Position.X);
						end;
					end);
					Library:Connection(SpTrack.InputEnded, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							SpDragging = false;
						end;
					end);
					Library:Connection(UserInputService.InputChanged, function(Input)
						if not SpDragging then return end;
						if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
							SpUpdate(Input.Position.X);
						end;
					end);

					local function RgbString(C)
						return string.format("%d, %d, %d", math.round(C.R * 255), math.round(C.G * 255), math.round(C.B * 255));
					end;

					local function ApplyState()
						local C = Color3.fromHSV(H, Sa, Va);
						Color                              = C;
						SwFill.BackgroundColor3            = C;
						SwFill.BackgroundTransparency      = 1 - A;
						AlphaArea.BackgroundColor3         = C;
						SatValArea.BackgroundColor3        = Color3.fromHSV(H, 1, 1);
						local SOff = (Sa < 1) and 0 or -3;
						local VOff = ((1 - Va) < 1) and 0 or -3;
						SatValMarker.Position = UDim2.new(Sa, SOff, 1 - Va, VOff);
						local HOff = ((1 - H) < 1) and 0 or -2;
						HueMarker.Position = UDim2.new(0, 0, 1 - H, HOff);
						local AOff = ((1 - A) < 1) and 0 or -2;
						AlphaMarker.Position = UDim2.new(0, 0, 1 - A, AOff);
						if not RgbInput:IsFocused() then RgbInput.Text = RgbString(C) end;
						if not HexInput:IsFocused() then HexInput.Text = C:ToHex() end;
						Library.Flags[Flag] = C;
						Callback(C, A);
					end;
					ApplyState();

					local FadeColorA = Color3.fromRGB(255, 0, 0);
					local FadeColorB = Color3.fromRGB(0, 0, 255);
					Library:Connection(RunService.Heartbeat, function(Dt)
						if Mode == "Rainbow" then
							H = (H + Dt * (Speed / 100)) % 1;
							ApplyState();
						elseif Mode == "Fading" then
							local T = (math.sin(tick() * (Speed / 25)) + 1) * 0.5;
							local C = FadeColorA:Lerp(FadeColorB, T);
							H, Sa, Va = Color3.toHSV(C);
							ApplyState();
						end;
					end);

					RgbInput.FocusLost:Connect(function()
						local r, g, b = string.match(RgbInput.Text, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)");
						r, g, b = tonumber(r), tonumber(g), tonumber(b);
						if r and g and b and r <= 255 and g <= 255 and b <= 255 then
							H, Sa, Va = Color3.toHSV(Color3.fromRGB(r, g, b));
						end;
						ApplyState();
					end);
					HexInput.FocusLost:Connect(function()
						local Text = string.gsub(HexInput.Text, "^#", "");
						if #Text == 6 then
							local ok, C = pcall(Color3.fromHex, Text);
							if ok and C then H, Sa, Va = Color3.toHSV(C) end;
						end;
						ApplyState();
					end);

					local DraggingSat, DraggingHue, DraggingAlpha = false, false, false;
					local Open = false;
					local PickerIn  = TweenInfo.new(0.2,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
					local PickerOut = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
					local SlideOff  = 10;
					local function AnchorXY()
						local AbsP = Swatch.AbsolutePosition;
						return AbsP.X - PickerHolder.AbsoluteSize.X + Swatch.AbsoluteSize.X, AbsP.Y + Swatch.AbsoluteSize.Y + 65;
					end;
					local function SetVisible(B)
						if B == Open then return end;
						Open = B;
						local X, Y = AnchorXY();
						if Open then
							PickerHolder.Visible           = true;
							PickerHolder.Position          = UDim2.fromOffset(X, Y - SlideOff);
							PickerHolder.GroupTransparency = 1;
							PickerOuterStroke.Transparency = 1;
							PickerInnerStroke.Transparency = 1;
							Library:Tween(PickerHolder, PickerIn, {
								Position          = UDim2.fromOffset(X, Y);
								GroupTransparency = 0;
							}):Play();
							Library:Tween(PickerOuterStroke, PickerIn, { Transparency = 0 }):Play();
							Library:Tween(PickerInnerStroke, PickerIn, { Transparency = 0 }):Play();
						else
							Library:Tween(PickerHolder, PickerOut, {
								Position          = UDim2.fromOffset(X, Y - SlideOff);
								GroupTransparency = 1;
							}):Play();
							Library:Tween(PickerOuterStroke, PickerOut, { Transparency = 1 }):Play();
							Library:Tween(PickerInnerStroke, PickerOut, { Transparency = 1 }):Play();
							task.delay(PickerOut.Time, function()
								if not Open then PickerHolder.Visible = false end;
							end);
						end;
					end;

					local function HookDown(Inst, Setter)
						Library:Connection(Inst.InputBegan, function(Input)
							if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
								Setter(true);
							end;
						end);
					end;
					Library:Connection(Swatch.MouseButton1Click, function() SetVisible(not Open) end);
					HookDown(SatLayer,  function(B) DraggingSat   = B end);
					HookDown(ValLayer,  function(B) DraggingSat   = B end);
					HookDown(HueArea,   function(B) DraggingHue   = B end);
					HookDown(AlphaArea, function(B) DraggingAlpha = B end);

					Library:Connection(UserInputService.InputEnded, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							DraggingSat = false; DraggingHue = false; DraggingAlpha = false;
						end;
					end);
					Library:Connection(UserInputService.InputChanged, function(Input)
						if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end;
						if not (DraggingSat or DraggingHue or DraggingAlpha) then return end;
						local M = UserInputService:GetMouseLocation();
						local Mx, My = M.X, M.Y - GuiInset;
						if DraggingSat then
							local Ap, Sz = SatValArea.AbsolutePosition, SatValArea.AbsoluteSize;
							Sa = Sz.X > 0 and math.clamp((Mx - Ap.X) / Sz.X, 0, 1) or 0;
							Va = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
						elseif DraggingHue then
							local Ap, Sz = HueArea.AbsolutePosition, HueArea.AbsoluteSize;
							H = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
						elseif DraggingAlpha then
							local Ap, Sz = AlphaArea.AbsolutePosition, AlphaArea.AbsoluteSize;
							A = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
						end;
						ApplyState();
					end);
					Library:Connection(UserInputService.InputBegan, function(Input)
						if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
						if not Open then return end;
						local M = UserInputService:GetMouseLocation();
						local Mx, My = M.X, M.Y - GuiInset;
						local function Inside(F)
							local Ap, Sz = F.AbsolutePosition, F.AbsoluteSize;
							return Mx >= Ap.X and Mx <= Ap.X + Sz.X and My >= Ap.Y and My <= Ap.Y + Sz.Y;
						end;
						if not Inside(PickerHolder) and not Inside(Swatch) then
							SetVisible(false);
						end;
					end);

					return self;
				end;

				if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
					Opts.Dependency:OnChange(function(S) Row.Visible = S end);
				end;
				return Obj;
			end;

			function SecRef:Slider(Opts)
				Opts = typeof(Opts) == "table" and Opts or {};
				local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Slider");
				local Min      = tonumber(Opts.Min) or 0;
				local Max      = tonumber(Opts.Max) or 100;
				local Step     = tonumber(Opts.Step) or 1;
				local Suffix   = tostring(Opts.Suffix or "");
				local Decimals = tonumber(Opts.Decimals) or 0;
				local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
				local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
				local Value    = math.clamp(tonumber(Opts.Default) or Min, Min, Max);
				Library.Flags[Flag] = Value;

				local Container = Library:CreateInstance("Frame", {
					Name                   = "Slider_" .. Name;
					Parent                 = self.Body;
					Size                   = UDim2.new(1, 0, 0, 26);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
				});

				local Lbl = Library:CreateInstance("TextLabel", {
					Name                   = "Label";
					Parent                 = Container;
					Position               = UDim2.new(0, 0, 0, 0);
					Size                   = UDim2.new(1, -40, 0, 14);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					Text                   = Name;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
				});

				local ValLbl = Library:CreateInstance("TextLabel", {
					Name                   = "Value";
					Parent                 = Container;
					AnchorPoint            = Vector2.new(1, 0);
					Position               = UDim2.new(1, 0, 0, 0);
					Size                   = UDim2.new(0, 40, 0, 14);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					TextColor3             = Color3.fromHex("8C8F99");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Right;
					TextYAlignment         = Enum.TextYAlignment.Center;
					Text                   = "";
				});
				if ProggyCleanFont then
					Lbl.FontFace    = ProggyCleanFont;
					ValLbl.FontFace = ProggyCleanFont;
				end;

				local Track = Library:CreateInstance("TextButton", {
					Name             = "Track";
					Parent           = Container;
					AnchorPoint      = Vector2.new(0, 1);
					Position         = UDim2.new(0, 0, 1, 0);
					Size             = UDim2.new(1, 0, 0, 10);
					BackgroundColor3 = Color3.fromHex("000000");
					BorderSizePixel  = 0;
					AutoButtonColor  = false;
					Text             = "";
				});
				local TrackGray = Library:CreateInstance("Frame", {
					Parent           = Track;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
				});
				local TrackInside = Library:CreateInstance("Frame", {
					Parent           = TrackGray;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("131313");
					BorderSizePixel  = 0;
				});

				local Fill = Library:CreateInstance("Frame", {
					Name             = "Fill";
					Parent           = TrackInside;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(0, 0, 1, -2);
					BackgroundColor3 = Color3.fromHex("3972EC");
					BorderSizePixel  = 0;
				});
				Library:RegisterAccent(Fill);

				local function FormatVal(V)
					if Decimals > 0 then
						return string.format("%." .. Decimals .. "f", V) .. Suffix;
					end;
					return tostring(math.round(V)) .. Suffix;
				end;

				local VisualT = (Value - Min) / (Max - Min);
				local TargetT = VisualT;

				local function Render()
					TargetT = (Value - Min) / (Max - Min);
					ValLbl.Text = FormatVal(Value);
				end;
				Render();
				Fill.Size = UDim2.new(VisualT, -2, 1, -2);

				Library:Connection(RunService.Heartbeat, function(Dt)
					if math.abs(TargetT - VisualT) < 0.001 then return end;
					local Alpha = 1 - math.exp(-Dt * 14);
					VisualT   = VisualT + (TargetT - VisualT) * Alpha;
					Fill.Size = UDim2.new(VisualT, -2, 1, -2);
				end);

				local function SetVal(V, Fire)
					V = math.clamp(math.floor((V - Min) / Step + 0.5) * Step + Min, Min, Max);
					if V == Value then return end;
					Value = V;
					Library.Flags[Flag] = Value;
					Render();
					if Fire ~= false then Callback(Value) end;
				end;

				local Dragging = false;
				local function UpdateFromInput(Px)
					local AbsX, AbsW = TrackInside.AbsolutePosition.X, TrackInside.AbsoluteSize.X;
					if AbsW <= 0 then return end;
					local T = math.clamp((Px - AbsX) / AbsW, 0, 1);
					SetVal(Min + T * (Max - Min));
				end;

				Library:Connection(Track.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragging = true;
						UpdateFromInput(Input.Position.X);
					end;
				end);
				Library:Connection(Track.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragging = false;
					end;
				end);
				Library:Connection(UserInputService.InputChanged, function(Input)
					if not Dragging then return end;
					if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
						UpdateFromInput(Input.Position.X);
					end;
				end);

				if Opts.Tooltip then Library:Tooltip(Container, Opts.Tooltip) end;
				if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
					Opts.Dependency:OnChange(function(S) Container.Visible = S end);
				end;

				local Obj = { Container = Container, Track = Track, Fill = Fill };
				function Obj:Get() return Value end;
				function Obj:Set(V) SetVal(tonumber(V) or Value) end;
				return Obj;
			end;

			function SecRef:Button(Opts)
				Opts = typeof(Opts) == "table" and Opts or {};
				local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Button");
				local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;

				local Row = Library:CreateInstance("Frame", {
					Name                   = "ButtonRow_" .. Name;
					Parent                 = self.Body;
					Size                   = UDim2.new(1, 0, 0, 21);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
				});
				Library:CreateInstance("UIListLayout", {
					Parent        = Row;
					FillDirection = Enum.FillDirection.Horizontal;
					SortOrder     = Enum.SortOrder.LayoutOrder;
					Padding       = UDim.new(0, 4);
				});

				local Buttons = {};
				local function Resize()
					local N = #Buttons;
					if N == 0 then return end;
					local Gap = 4 * (N - 1);
					for _, B in Buttons do
						B.Btn.Size = UDim2.new(1 / N, -(Gap / N), 1, 0);
					end;
				end;

				local function MakeBtn(BtnName, BtnCB, Confirm)
					local Btn = Library:CreateInstance("TextButton", {
						Name                   = "Btn_" .. BtnName;
						Parent                 = Row;
						BackgroundColor3       = Color3.fromHex("000000");
						BorderSizePixel        = 0;
						AutoButtonColor        = false;
						Text                   = "";
						LayoutOrder            = #Buttons + 1;
					});
					local BGray = Library:CreateInstance("Frame", {
						Parent           = Btn;
						Position         = UDim2.new(0, 1, 0, 1);
						Size             = UDim2.new(1, -2, 1, -2);
						BackgroundColor3 = Color3.fromHex("393939");
						BorderSizePixel  = 0;
					});
					local BInside = Library:CreateInstance("Frame", {
						Parent           = BGray;
						Position         = UDim2.new(0, 1, 0, 1);
						Size             = UDim2.new(1, -2, 1, -2);
						BackgroundColor3 = Color3.fromHex("FFFFFF");
						BorderSizePixel  = 0;
					});
					Library:CreateInstance("UIGradient", {
						Parent   = BInside;
						Rotation = 90;
						Color    = NewColorSequence({
							NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
							NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
						});
					});
					local Lbl = Library:CreateInstance("TextLabel", {
						Name                   = "Label";
						Parent                 = BInside;
						Size                   = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
						Text                   = BtnName;
						TextColor3             = Color3.fromHex("FFFFFF");
						TextSize               = 12;
						TextXAlignment         = Enum.TextXAlignment.Center;
						TextYAlignment         = Enum.TextYAlignment.Center;
					});
					if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

					local ClickIn  = TweenInfo.new(0.1,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
					local ClickOut = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
					local function FlashBg()
						Library:Tween(BInside, ClickIn, { BackgroundColor3 = Color3.fromHex("DDDDDD") }):Play();
						task.delay(ClickIn.Time, function()
							Library:Tween(BInside, ClickOut, { BackgroundColor3 = Color3.fromHex("FFFFFF") }):Play();
						end);
					end;
					if Confirm then
						local Confirming = false;
						local Token      = 0;
						Btn.MouseButton1Click:Connect(function()
							if Confirming then
								Confirming = false;
								Token = Token + 1;
								Lbl.Text = BtnName;
								Library:Tween(Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
								FlashBg();
								BtnCB();
							else
								Confirming = true;
								Token = Token + 1;
								local Mine = Token;
								Lbl.Text = "Confirm?";
								Library:Tween(Lbl, ClickIn, { TextColor3 = Library.Accent }):Play();
								task.delay(3, function()
									if Token == Mine then
										Confirming = false;
										Lbl.Text = BtnName;
										Library:Tween(Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
									end;
								end);
							end;
						end);
					else
						Btn.MouseButton1Click:Connect(function()
							FlashBg();
							Library:Tween(Lbl, ClickIn, { TextColor3 = Library.Accent }):Play();
							task.delay(ClickIn.Time, function()
								Library:Tween(Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
							end);
							BtnCB();
						end);
					end;

					local BRef = { Btn = Btn, Label = Lbl };
					table.insert(Buttons, BRef);
					Resize();
					return BRef;
				end;

				MakeBtn(Name, Callback, Opts.Confirm);

				if Opts.Tooltip then Library:Tooltip(Row, Opts.Tooltip) end;
				if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
					Opts.Dependency:OnChange(function(S) Row.Visible = S end);
				end;

				local Obj = { Container = Row };
				function Obj:Button(MoreOpts)
					MoreOpts = typeof(MoreOpts) == "table" and MoreOpts or {};
					local N = tostring(MoreOpts.Name or MoreOpts.Title or MoreOpts.Text or "Button");
					local CB = typeof(MoreOpts.Callback) == "function" and MoreOpts.Callback or function() end;
					MakeBtn(N, CB, MoreOpts.Confirm);
					return self;
				end;
				return Obj;
			end;

			function SecRef:Colorpicker(Opts)
				Opts = typeof(Opts) == "table" and Opts or {};
				local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Color");
				local Color    = typeof(Opts.Default) == "Color3" and Opts.Default or Color3.fromRGB(255, 255, 255);
				local Alpha    = tonumber(Opts.Alpha) or 1;
				local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
				local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
				local H, S, V  = Color3.toHSV(Color);
				local A        = math.clamp(Alpha, 0, 1);

				local Row = Library:CreateInstance("Frame", {
					Name                   = "Colorpicker_" .. Name;
					Parent                 = self.Body;
					Size                   = UDim2.new(1, 0, 0, 18);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
				});

				local Lbl = Library:CreateInstance("TextLabel", {
					Name                   = "Label";
					Parent                 = Row;
					AnchorPoint            = Vector2.new(0, 0.5);
					Position               = UDim2.new(0, 0, 0.5, 0);
					Size                   = UDim2.new(1, -32, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					Text                   = Name;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
				});
				if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

				local Swatch = Library:CreateInstance("TextButton", {
					Name             = "Swatch";
					Parent           = Row;
					AnchorPoint      = Vector2.new(1, 0.5);
					Position         = UDim2.new(1, 0, 0.5, 0);
					Size             = UDim2.new(0, 27, 0, 15);
					AutoButtonColor  = false;
					Text             = "";
					BackgroundColor3 = Color3.fromHex("000105");
					BorderSizePixel  = 0;
				});
				local SwatchInline = Library:CreateInstance("Frame", {
					Name             = "Inline";
					Parent           = Swatch;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("252527");
					BorderSizePixel  = 0;
				});
				local SwatchHandle = Library:CreateInstance("Frame", {
					Name             = "Handle";
					Parent           = SwatchInline;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					BorderSizePixel  = 0;
				});
				Library:CreateInstance("ImageLabel", {
					Name             = "Checkers";
					Parent           = SwatchHandle;
					Size             = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel  = 0;
					Image            = "rbxassetid://18274452449";
					ScaleType        = Enum.ScaleType.Tile;
					TileSize         = UDim2.new(0, 6, 0, 6);
					ZIndex           = 2;
				});
				local SwatchFill = Library:CreateInstance("Frame", {
					Name                   = "Fill";
					Parent                 = SwatchHandle;
					Size                   = UDim2.new(1, 0, 1, 0);
					BackgroundColor3       = Color;
					BackgroundTransparency = 1 - Alpha;
					BorderSizePixel        = 0;
					ZIndex                 = 3;
				});
				Library:CreateInstance("UIGradient", {
					Parent   = SwatchFill;
					Rotation = 90;
					Color    = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromRGB(255, 255, 255));
						NewColorSequenceKeypoint(1, Color3.fromRGB(167, 167, 167));
					});
				});

				local PickerHolder = Library:CreateInstance("CanvasGroup", {
					Name              = "Picker_" .. Name;
					Parent            = Gui;
					Size              = UDim2.new(0, 218, 0, 248);
					BackgroundColor3  = Color3.fromHex("131313");
					BorderSizePixel   = 0;
					Visible           = false;
					GroupTransparency = 1;
					ZIndex            = 50;
				});
				local PickerOuterStroke = Library:CreateInstance("UIStroke", {
					Parent          = PickerHolder;
					Color           = Color3.fromHex("000000");
					Thickness       = 1;
					Transparency    = 1;
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				});
				local PickerInner = Library:CreateInstance("Frame", {
					Name                   = "InnerOutline";
					Parent                 = PickerHolder;
					Position               = UDim2.new(0, 1, 0, 1);
					Size                   = UDim2.new(1, -2, 1, -2);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					ZIndex                 = 51;
				});
				local PickerInnerStroke = Library:CreateInstance("UIStroke", {
					Parent          = PickerInner;
					Color           = Color3.fromHex("393939");
					Thickness       = 1;
					Transparency    = 1;
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				});
				local PickerBody = Library:CreateInstance("Frame", {
					Name                   = "Body";
					Parent                 = PickerHolder;
					Size                   = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					ZIndex                 = 52;
				});
				Library:CreateInstance("UIPadding", {
					Parent        = PickerBody;
					PaddingTop    = UDim.new(0, 8);
					PaddingBottom = UDim.new(0, 8);
					PaddingLeft   = UDim.new(0, 8);
					PaddingRight  = UDim.new(0, 8);
				});

				local MainBg = Library:CreateInstance("Frame", {
					Name                   = "Main";
					Parent                 = PickerBody;
					Size                   = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					ZIndex                 = 53;
				});

				local TabBar = Library:CreateInstance("Frame", {
					Name                   = "TabBar";
					Parent                 = MainBg;
					Position               = UDim2.new(0, 0, 0, 0);
					Size                   = UDim2.new(1, 0, 0, 20);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					ZIndex                 = 54;
				});

				local CpInactiveSeq = NewColorSequence({
					NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
					NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
				});
				local CpActiveSeq = NewColorSequence({
					NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
					NewColorSequenceKeypoint(1, Color3.fromHex("151515"));
				});

				local CpAnimInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
				local CpInactiveA, CpInactiveB = Color3.fromHex("1F1F1F"), Color3.fromHex("181818");
				local CpActiveA,   CpActiveB   = Color3.fromHex("161616"), Color3.fromHex("151515");
				local CpOutlineNames = { "TopBlack", "TopGray", "BottomBlack", "BottomGray", "LeftBlack", "LeftGray", "RightBlack", "RightGray" };
				local ColorPage, AnimationsPanel;
				local CpTabToken = 0;

				local TabButtons = {};
				local function MakeCpTab(Name, Idx, Total)
					local Btn = Library:CreateInstance("TextButton", {
						Name                   = "Tab_" .. Name;
						Parent                 = TabBar;
						Size                   = UDim2.new(1 / Total, 0, 1, 0);
						Position               = UDim2.new((Idx - 1) / Total, 0, 0, 0);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
						AutoButtonColor        = false;
						Text                   = "";
					});
					local Bg = Library:CreateInstance("Frame", {
						Name             = "Bg";
						Parent           = Btn;
						Size             = UDim2.new(1, 0, 1, 0);
						BackgroundColor3 = Color3.fromHex("FFFFFF");
						BorderSizePixel  = 0;
					});
					local BgGrad = Library:CreateInstance("UIGradient", {
						Parent   = Bg;
						Rotation = 90;
						Color    = CpInactiveSeq;
					});
					local function MakePiece(Anchor, Pos, Sz, Color, ZIdx)
						return Library:CreateInstance("Frame", {
							Parent                 = Bg;
							AnchorPoint            = Anchor;
							Position               = Pos;
							Size                   = Sz;
							BackgroundColor3       = Color3.fromHex(Color);
							BorderSizePixel        = 0;
							BackgroundTransparency = 1;
							ZIndex                 = ZIdx;
						});
					end;
					local TopBlack    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
					local TopGray     = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(1, -2, 0, 1), "393939", 4);
					local BottomBlack = MakePiece(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
					local BottomGray  = MakePiece(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939", 4);
					local LeftBlack   = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
					local LeftGray    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(0, 1, 1, -2), "393939", 3);
					local RightBlack  = MakePiece(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
					local RightGray   = MakePiece(Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
					local TopGradient = Library:CreateInstance("Frame", {
						Parent                 = Bg;
						AnchorPoint            = Vector2.new(0, 0);
						Position               = UDim2.new(0, 0, 0, 0);
						Size                   = UDim2.new(1, 0, 0, 1);
						BackgroundColor3       = Color3.fromHex("FFFFFF");
						BorderSizePixel        = 0;
						BackgroundTransparency = 1;
						ZIndex                 = 5;
					});
					local Grad = Library:CreateInstance("UIGradient", { Parent = TopGradient; Rotation = 0 });
					Library:RegisterAccentGradient(Grad);
					local Lbl = Library:CreateInstance("TextLabel", {
						Name                   = "Label";
						Parent                 = Bg;
						Size                   = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
						Text                   = Name;
						TextSize               = 12;
						TextColor3             = Color3.fromHex("FFFFFF");
						TextXAlignment         = Enum.TextXAlignment.Center;
						TextYAlignment         = Enum.TextYAlignment.Center;
						ZIndex                 = 6;
					});
					if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

					local Entry = {
						Btn = Btn, Bg = Bg, Lbl = Lbl, BgGrad = BgGrad, TopGradient = TopGradient;
						TopBlack = TopBlack, TopGray = TopGray;
						BottomBlack = BottomBlack, BottomGray = BottomGray;
						LeftBlack = LeftBlack, LeftGray = LeftGray;
						RightBlack = RightBlack, RightGray = RightGray;
						GradT = 0; GradTarget = 0;
					};
					local function ApplyGrad()
						BgGrad.Color = NewColorSequence({
							NewColorSequenceKeypoint(0, CpInactiveA:Lerp(CpActiveA, Entry.GradT));
							NewColorSequenceKeypoint(1, CpInactiveB:Lerp(CpActiveB, Entry.GradT));
						});
					end;
					ApplyGrad();
					Library:Connection(RunService.Heartbeat, function(Dt)
						if math.abs(Entry.GradTarget - Entry.GradT) < 0.001 then
							if Entry.GradT ~= Entry.GradTarget then
								Entry.GradT = Entry.GradTarget;
								ApplyGrad();
							end;
							return;
						end;
						Entry.GradT = Entry.GradT + (Entry.GradTarget - Entry.GradT) * (1 - math.exp(-Dt * 16));
						ApplyGrad();
					end);
					table.insert(TabButtons, Entry);
					return Btn;
				end;
				local ColorTabBtn = MakeCpTab("Color", 1, 2);
				local AnimationsTabBtn = MakeCpTab("Animations", 2, 2);

				local function SetCpTab(I)
					for i, T in TabButtons do
						if i == I then
							T.GradTarget = 1;
							Library:Tween(T.TopGradient, CpAnimInfo, { BackgroundTransparency = 0 }):Play();
							for _, N in CpOutlineNames do
								Library:Tween(T[N], CpAnimInfo, { BackgroundTransparency = 1 }):Play();
							end;
						else
							T.GradTarget = 0;
							Library:Tween(T.TopGradient, CpAnimInfo, { BackgroundTransparency = 1 }):Play();
							for _, N in CpOutlineNames do
								Library:Tween(T[N], CpAnimInfo, { BackgroundTransparency = 0 }):Play();
							end;
						end;
					end;
					if ColorPage and AnimationsPanel then
						CpTabToken = CpTabToken + 1;
						local Mine = CpTabToken;
						ColorPage.Visible       = true;
						AnimationsPanel.Visible = true;
						if I == 1 then
							Library:Tween(ColorPage,       CpAnimInfo, { GroupTransparency = 0 }):Play();
							Library:Tween(AnimationsPanel, CpAnimInfo, { GroupTransparency = 1 }):Play();
						else
							Library:Tween(ColorPage,       CpAnimInfo, { GroupTransparency = 1 }):Play();
							Library:Tween(AnimationsPanel, CpAnimInfo, { GroupTransparency = 0 }):Play();
						end;
						task.delay(CpAnimInfo.Time, function()
							if CpTabToken ~= Mine then return end;
							if I == 1 then AnimationsPanel.Visible = false end;
							if I == 2 then ColorPage.Visible = false end;
						end);
					end;
				end;
				SetCpTab(1);
				ColorTabBtn.MouseButton1Click:Connect(function() SetCpTab(1) end);
				AnimationsTabBtn.MouseButton1Click:Connect(function() SetCpTab(2) end);

				ColorPage = Library:CreateInstance("CanvasGroup", {
					Name                   = "ColorPage";
					Parent                 = MainBg;
					Size                   = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					GroupTransparency      = 0;
					ZIndex                 = 54;
				});

				AnimationsPanel = Library:CreateInstance("CanvasGroup", {
					Name              = "AnimationsPanel";
					Parent            = MainBg;
					Position          = UDim2.new(0, 0, 0, 28);
					Size              = UDim2.new(1, 0, 1, -28);
					BackgroundColor3  = Color3.fromHex("131313");
					BorderSizePixel   = 0;
					Visible           = false;
					GroupTransparency = 1;
					ZIndex            = 55;
				});
				local Mode  = "Solid";
				local Speed = 50;

				local function FontIt(L) if ProggyCleanFont then L.FontFace = ProggyCleanFont end end;
				local function AnimLbl(Text, Y)
					local L = Library:CreateInstance("TextLabel", {
						Parent                 = AnimationsPanel;
						Position               = UDim2.new(0, 0, 0, Y);
						Size                   = UDim2.new(1, 0, 0, 12);
						BackgroundTransparency = 1;
						Text                   = Text;
						TextColor3             = Color3.fromHex("FFFFFF");
						TextSize               = 12;
						TextXAlignment         = Enum.TextXAlignment.Left;
					});
					FontIt(L);
					return L;
				end;

				AnimLbl("Mode", 0);
				local ModeBox = Library:CreateInstance("TextButton", {
					Parent           = AnimationsPanel;
					Position         = UDim2.new(0, 0, 0, 14);
					Size             = UDim2.new(1, 0, 0, 21);
					BackgroundColor3 = Color3.fromHex("000000");
					BorderSizePixel  = 0;
					AutoButtonColor  = false;
					Text             = "";
				});
				Library:CreateInstance("Frame", {
					Parent           = ModeBox;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
				});
				local ModeInside = Library:CreateInstance("Frame", {
					Parent           = ModeBox:FindFirstChildOfClass("Frame");
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				Library:CreateInstance("UIGradient", {
					Parent   = ModeInside;
					Rotation = 90;
					Color    = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
						NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
					});
				});
				local ModeVal = Library:CreateInstance("TextLabel", {
					Parent                 = ModeInside;
					Position               = UDim2.new(0, 4, 0, 0);
					Size                   = UDim2.new(1, -14, 1, 0);
					BackgroundTransparency = 1;
					Text                   = Mode;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
				}); FontIt(ModeVal);
				local ModeArrow = Library:CreateInstance("Frame", {
					Parent                 = ModeInside;
					AnchorPoint            = Vector2.new(1, 0.5);
					Position               = UDim2.new(1, -4, 0.5, 0);
					Size                   = UDim2.fromOffset(7, 7);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
				});
				Library:CreateInstance("Frame", {
					Parent           = ModeArrow;
					AnchorPoint      = Vector2.new(0.5, 0.5);
					Position         = UDim2.new(0.5, 0, 0.5, 0);
					Size             = UDim2.fromOffset(7, 1);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				local ModeArrowV = Library:CreateInstance("Frame", {
					Parent           = ModeArrow;
					AnchorPoint      = Vector2.new(0.5, 0.5);
					Position         = UDim2.new(0.5, 0, 0.5, 0);
					Size             = UDim2.fromOffset(1, 7);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				local function SetModeArrow(Plus) ModeArrowV.Visible = Plus end;

				local ModePopup = Library:CreateInstance("CanvasGroup", {
					Parent            = AnimationsPanel;
					Position          = UDim2.new(0, 0, 0, 36);
					Size              = UDim2.new(1, 0, 0, 44);
					BackgroundColor3  = Color3.fromHex("000000");
					BorderSizePixel   = 0;
					Visible           = false;
					GroupTransparency = 1;
					ZIndex            = 60;
				});
				local ModePopupGray = Library:CreateInstance("Frame", {
					Parent           = ModePopup;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
					ZIndex           = 60;
				});
				local ModePopupInside = Library:CreateInstance("Frame", {
					Parent           = ModePopupGray;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("131313");
					BorderSizePixel  = 0;
					ZIndex           = 61;
				});
				Library:CreateInstance("UIListLayout", {
					Parent        = ModePopupInside;
					FillDirection = Enum.FillDirection.Vertical;
					SortOrder     = Enum.SortOrder.LayoutOrder;
					Padding       = UDim.new(0, 0);
				});
				local ModeOptionBtns = {};
				local function RefreshModeOpts()
					for N, B in ModeOptionBtns do
						B.TextColor3 = (N == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
					end;
				end;
				Library:OnAccent(function() RefreshModeOpts() end);
				local ModePopupOpen = false;
				local ModePopupToken = 0;
				local ModePopupInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
				local ModePopupBaseY = 36;
				local ModePopupSlide = 6;
				local function CloseModePopup()
					if not ModePopupOpen then return end;
					ModePopupOpen = false;
					ModePopupToken = ModePopupToken + 1;
					local Mine = ModePopupToken;
					SetModeArrow(true);
					Library:Tween(ModePopup, ModePopupInfo, {
						GroupTransparency = 1;
						Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
					}):Play();
					task.delay(ModePopupInfo.Time, function()
						if ModePopupToken == Mine then ModePopup.Visible = false end;
					end);
				end;
				local function OpenModePopup()
					if ModePopupOpen then return end;
					ModePopupOpen = true;
					ModePopupToken = ModePopupToken + 1;
					SetModeArrow(false);
					ModePopup.GroupTransparency = 1;
					ModePopup.Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
					ModePopup.Visible           = true;
					Library:Tween(ModePopup, ModePopupInfo, {
						GroupTransparency = 0;
						Position          = UDim2.new(0, 0, 0, ModePopupBaseY);
					}):Play();
				end;
				local function AddModeOpt(Name, Idx)
					local Btn = Library:CreateInstance("TextButton", {
						Parent                 = ModePopupInside;
						Size                   = UDim2.new(1, 0, 0, 14);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
						AutoButtonColor        = false;
						Text                   = Name;
						TextColor3             = (Name == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
						TextSize               = 12;
						TextXAlignment         = Enum.TextXAlignment.Left;
						LayoutOrder            = Idx;
						ZIndex                 = 62;
					});
					Library:CreateInstance("UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 5) });
					FontIt(Btn);
					ModeOptionBtns[Name] = Btn;
					Btn.MouseButton1Click:Connect(function()
						Mode = Name;
						ModeVal.Text = Mode;
						RefreshModeOpts();
						CloseModePopup();
					end);
				end;
				AddModeOpt("Solid",   1);
				AddModeOpt("Rainbow", 2);
				AddModeOpt("Fading",  3);
				ModeBox.MouseButton1Click:Connect(function()
					if ModePopupOpen then CloseModePopup() else OpenModePopup() end;
				end);

				AnimLbl("Speed", 42);
				local SpeedVal = Library:CreateInstance("TextLabel", {
					Parent                 = AnimationsPanel;
					AnchorPoint            = Vector2.new(1, 0);
					Position               = UDim2.new(1, 0, 0, 42);
					Size                   = UDim2.new(0, 40, 0, 12);
					BackgroundTransparency = 1;
					Text                   = "50%";
					TextColor3             = Color3.fromHex("8C8F99");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Right;
				}); FontIt(SpeedVal);
				local SpTrack = Library:CreateInstance("TextButton", {
					Parent           = AnimationsPanel;
					Position         = UDim2.new(0, 0, 0, 58);
					Size             = UDim2.new(1, 0, 0, 10);
					BackgroundColor3 = Color3.fromHex("000000");
					BorderSizePixel  = 0;
					AutoButtonColor  = false;
					Text             = "";
				});
				local SpGray = Library:CreateInstance("Frame", {
					Parent = SpTrack; Position = UDim2.new(0, 1, 0, 1);
					Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
				});
				local SpInside = Library:CreateInstance("Frame", {
					Parent = SpGray; Position = UDim2.new(0, 1, 0, 1);
					Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("131313"); BorderSizePixel = 0;
				});
				local SpFill = Library:CreateInstance("Frame", {
					Parent           = SpInside;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(0.5, -2, 1, -2);
					BackgroundColor3 = Library.Accent;
					BorderSizePixel  = 0;
				});
				Library:RegisterAccent(SpFill);

				local SpDragging = false;
				local SpVisualT = 0.5;
				local SpTargetT = 0.5;
				Library:Connection(RunService.Heartbeat, function(Dt)
					if math.abs(SpTargetT - SpVisualT) < 0.001 then return end;
					local Alpha = 1 - math.exp(-Dt * 14);
					SpVisualT = SpVisualT + (SpTargetT - SpVisualT) * Alpha;
					SpFill.Size = UDim2.new(SpVisualT, -2, 1, -2);
				end);
				local function SpUpdate(Px)
					local Ax, Aw = SpInside.AbsolutePosition.X, SpInside.AbsoluteSize.X;
					if Aw <= 0 then return end;
					local T = math.clamp((Px - Ax) / Aw, 0, 1);
					Speed = math.floor(T * 100 + 0.5);
					SpTargetT = T;
					SpeedVal.Text = Speed .. "%";
				end;
				Library:Connection(SpTrack.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						SpDragging = true; SpUpdate(Input.Position.X);
					end;
				end);
				Library:Connection(SpTrack.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						SpDragging = false;
					end;
				end);
				Library:Connection(UserInputService.InputChanged, function(Input)
					if not SpDragging then return end;
					if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
						SpUpdate(Input.Position.X);
					end;
				end);

				local SatValArea = Library:CreateInstance("Frame", {
					Name             = "SatVal";
					Parent           = ColorPage;
					Position         = UDim2.new(0, 0, 0, 24);
					Size             = UDim2.new(1, -30, 1, -66);
					BackgroundColor3 = Color3.fromRGB(255, 0, 0);
					BorderSizePixel  = 0;
					ZIndex           = 55;
				});
				Library:CreateInstance("UIStroke", {
					Parent          = SatValArea;
					Color           = Color3.fromHex("000105");
					Thickness       = 1;
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				});
				local SatLayer = Library:CreateInstance("TextButton", {
					Name             = "Sat";
					Parent           = SatValArea;
					Size             = UDim2.new(1, 0, 1, 0);
					BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					BorderSizePixel  = 0;
					AutoButtonColor  = false;
					Text             = "";
					ZIndex           = 56;
				});
				Library:CreateInstance("UIGradient", {
					Parent       = SatLayer;
					Rotation     = 270;
					Transparency = NewNumberSequence({
						NewNumberSequenceKeypoint(0, 0);
						NewNumberSequenceKeypoint(1, 1);
					});
					Color = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromRGB(0, 0, 0));
						NewColorSequenceKeypoint(1, Color3.fromRGB(0, 0, 0));
					});
				});
				local ValLayer = Library:CreateInstance("TextButton", {
					Name             = "Val";
					Parent           = SatValArea;
					Size             = UDim2.new(1, 0, 1, 0);
					BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					BorderSizePixel  = 0;
					AutoButtonColor  = false;
					Text             = "";
					ZIndex           = 57;
				});
				Library:CreateInstance("UIGradient", {
					Parent       = ValLayer;
					Transparency = NewNumberSequence({
						NewNumberSequenceKeypoint(0, 0);
						NewNumberSequenceKeypoint(1, 1);
					});
				});
				local SatValMarker = Library:CreateInstance("Frame", {
					Name             = "Marker";
					Parent           = SatValArea;
					Size             = UDim2.new(0, 2, 0, 2);
					BorderSizePixel  = 1;
					BorderColor3     = Color3.fromRGB(0, 0, 0);
					BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					ZIndex           = 58;
				});

				local HueArea = Library:CreateInstance("TextButton", {
					Name             = "Hue";
					Parent           = ColorPage;
					AnchorPoint      = Vector2.new(1, 0);
					Position         = UDim2.new(1, -14, 0, 24);
					Size             = UDim2.new(0, 12, 1, -66);
					BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					BorderSizePixel  = 0;
					AutoButtonColor  = false;
					Text             = "";
					ZIndex           = 55;
				});
				Library:CreateInstance("UIStroke", {
					Parent          = HueArea;
					Color           = Color3.fromHex("000105");
					Thickness       = 1;
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				});
				Library:CreateInstance("UIGradient", {
					Parent   = HueArea;
					Rotation = 270;
					Color    = NewColorSequence({
						NewColorSequenceKeypoint(0,    Color3.fromRGB(255, 0, 0));
						NewColorSequenceKeypoint(0.17, Color3.fromRGB(255, 255, 0));
						NewColorSequenceKeypoint(0.33, Color3.fromRGB(0, 255, 0));
						NewColorSequenceKeypoint(0.5,  Color3.fromRGB(0, 255, 255));
						NewColorSequenceKeypoint(0.67, Color3.fromRGB(0, 0, 255));
						NewColorSequenceKeypoint(0.83, Color3.fromRGB(255, 0, 255));
						NewColorSequenceKeypoint(1,    Color3.fromRGB(255, 0, 0));
					});
				});
				local HueMarker = Library:CreateInstance("Frame", {
					Name             = "Marker";
					Parent           = HueArea;
					Size             = UDim2.new(1, 0, 0, 2);
					BorderSizePixel  = 1;
					BorderColor3     = Color3.fromRGB(0, 0, 0);
					BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					ZIndex           = 56;
				});

				local AlphaArea = Library:CreateInstance("TextButton", {
					Name             = "Alpha";
					Parent           = ColorPage;
					AnchorPoint      = Vector2.new(1, 0);
					Position         = UDim2.new(1, 0, 0, 24);
					Size             = UDim2.new(0, 12, 1, -66);
					BackgroundColor3 = Color;
					BorderSizePixel  = 0;
					AutoButtonColor  = false;
					Text             = "";
					ZIndex           = 55;
				});
				Library:CreateInstance("UIStroke", {
					Parent          = AlphaArea;
					Color           = Color3.fromHex("000105");
					Thickness       = 1;
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				});
				local AlphaCheckers = Library:CreateInstance("ImageLabel", {
					Name                   = "Checkers";
					Parent                 = AlphaArea;
					Size                   = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					Image                  = "rbxassetid://18274452449";
					ScaleType              = Enum.ScaleType.Tile;
					TileSize               = UDim2.new(0, 6, 0, 6);
					ZIndex                 = 56;
				});
				Library:CreateInstance("UIGradient", {
					Parent       = AlphaCheckers;
					Rotation     = 270;
					Transparency = NewNumberSequence({
						NewNumberSequenceKeypoint(0, 0);
						NewNumberSequenceKeypoint(1, 1);
					});
				});
				local AlphaMarker = Library:CreateInstance("Frame", {
					Name             = "Marker";
					Parent           = AlphaArea;
					Size             = UDim2.new(1, 0, 0, 2);
					BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					BorderSizePixel  = 1;
					BorderColor3     = Color3.fromRGB(0, 0, 0);
					ZIndex           = 57;
				});

				local function MakeInput(YOffFromBottom)
					local Box = Library:CreateInstance("Frame", {
						Parent           = ColorPage;
						AnchorPoint      = Vector2.new(0, 1);
						Position         = UDim2.new(0, 0, 1, -YOffFromBottom);
						Size             = UDim2.new(1, 0, 0, 18);
						BackgroundColor3 = Color3.fromHex("000000");
						BorderSizePixel  = 0;
						ZIndex           = 55;
					});
					local Gray = Library:CreateInstance("Frame", {
						Parent           = Box;
						Position         = UDim2.new(0, 1, 0, 1);
						Size             = UDim2.new(1, -2, 1, -2);
						BackgroundColor3 = Color3.fromHex("393939");
						BorderSizePixel  = 0;
					});
					local Inside = Library:CreateInstance("Frame", {
						Parent           = Gray;
						Position         = UDim2.new(0, 1, 0, 1);
						Size             = UDim2.new(1, -2, 1, -2);
						BackgroundColor3 = Color3.fromHex("FFFFFF");
						BorderSizePixel  = 0;
					});
					Library:CreateInstance("UIGradient", {
						Parent   = Inside;
						Rotation = 90;
						Color    = NewColorSequence({
							NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
							NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
						});
					});
					local Input = Library:CreateInstance("TextBox", {
						Parent                 = Inside;
						Size                   = UDim2.new(1, -6, 1, 0);
						Position               = UDim2.new(0, 3, 0, 0);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
						ClearTextOnFocus       = false;
						Text                   = "";
						PlaceholderColor3      = Color3.fromHex("5E626B");
						TextColor3             = Color3.fromHex("FFFFFF");
						TextSize               = 12;
						TextXAlignment         = Enum.TextXAlignment.Center;
						TextYAlignment         = Enum.TextYAlignment.Center;
						ClipsDescendants       = true;
					});
					if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;
					return Input;
				end;

				local HexInput = MakeInput(0);
				HexInput.PlaceholderText = "Hex";
				local RgbInput = MakeInput(20);
				RgbInput.PlaceholderText = "R, G, B";

				local function RgbString(C)
					return string.format("%d, %d, %d", math.round(C.R * 255), math.round(C.G * 255), math.round(C.B * 255));
				end;

				local function ApplyState()
					local C = Color3.fromHSV(H, S, V);
					Color                              = C;
					SwatchFill.BackgroundColor3        = C;
					SwatchFill.BackgroundTransparency  = 1 - A;
					AlphaArea.BackgroundColor3         = C;
					SatValArea.BackgroundColor3        = Color3.fromHSV(H, 1, 1);

					local SOff = (S < 1) and 0 or -3;
					local VOff = ((1 - V) < 1) and 0 or -3;
					SatValMarker.Position = UDim2.new(S, SOff, 1 - V, VOff);

					local HOff = ((1 - H) < 1) and 0 or -2;
					HueMarker.Position = UDim2.new(0, 0, 1 - H, HOff);

					local AOff = ((1 - A) < 1) and 0 or -2;
					AlphaMarker.Position = UDim2.new(0, 0, 1 - A, AOff);

					if not RgbInput:IsFocused() then RgbInput.Text = RgbString(C) end;
					if not HexInput:IsFocused() then HexInput.Text = C:ToHex() end;

					Library.Flags[Flag] = C;
					Callback(C, A);
				end;
				ApplyState();

				local FadeColorA = Color3.fromRGB(255, 0, 0);
				local FadeColorB = Color3.fromRGB(0, 0, 255);
				Library:Connection(RunService.Heartbeat, function(Dt)
					if Mode == "Rainbow" then
						H = (H + Dt * (Speed / 100)) % 1;
						ApplyState();
					elseif Mode == "Fading" then
						local T = (math.sin(tick() * (Speed / 25)) + 1) * 0.5;
						local C = FadeColorA:Lerp(FadeColorB, T);
						H, S, V = Color3.toHSV(C);
						ApplyState();
					end;
				end);

				RgbInput.FocusLost:Connect(function()
					local r, g, b = string.match(RgbInput.Text, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)");
					r, g, b = tonumber(r), tonumber(g), tonumber(b);
					if r and g and b and r <= 255 and g <= 255 and b <= 255 then
						H, S, V = Color3.toHSV(Color3.fromRGB(r, g, b));
					end;
					ApplyState();
				end);
				HexInput.FocusLost:Connect(function()
					local Text = string.gsub(HexInput.Text, "^#", "");
					if #Text == 6 then
						local ok, C = pcall(Color3.fromHex, Text);
						if ok and C then H, S, V = Color3.toHSV(C) end;
					end;
					ApplyState();
				end);

				local DraggingSat, DraggingHue, DraggingAlpha = false, false, false;
				local Open = false;
				local PickerIn   = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
				local PickerOut  = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
				local SlideOff   = 10;
				local function AnchorXY()
					local AbsP = Swatch.AbsolutePosition;
					return AbsP.X - PickerHolder.AbsoluteSize.X + Swatch.AbsoluteSize.X, AbsP.Y + Swatch.AbsoluteSize.Y + 65;
				end;
				local function SetVisible(B)
					if B == Open then return end;
					Open = B;
					local X, Y = AnchorXY();
					if Open then
						PickerHolder.Visible           = true;
						PickerHolder.Position          = UDim2.fromOffset(X, Y - SlideOff);
						PickerHolder.GroupTransparency = 1;
						PickerOuterStroke.Transparency = 1;
						PickerInnerStroke.Transparency = 1;
						Library:Tween(PickerHolder, PickerIn, {
							Position          = UDim2.fromOffset(X, Y);
							GroupTransparency = 0;
						}):Play();
						Library:Tween(PickerOuterStroke, PickerIn, { Transparency = 0 }):Play();
						Library:Tween(PickerInnerStroke, PickerIn, { Transparency = 0 }):Play();
					else
						Library:Tween(PickerHolder, PickerOut, {
							Position          = UDim2.fromOffset(X, Y - SlideOff);
							GroupTransparency = 1;
						}):Play();
						Library:Tween(PickerOuterStroke, PickerOut, { Transparency = 1 }):Play();
						Library:Tween(PickerInnerStroke, PickerOut, { Transparency = 1 }):Play();
						task.delay(PickerOut.Time, function()
							if not Open then PickerHolder.Visible = false end;
						end);
					end;
				end;

				local function HookDown(Inst, Setter)
					Library:Connection(Inst.InputBegan, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							Setter(true);
						end;
					end);
				end;

				Library:Connection(Swatch.MouseButton1Click, function() SetVisible(not Open) end);
				HookDown(SatLayer,  function(B) DraggingSat   = B end);
				HookDown(ValLayer,  function(B) DraggingSat   = B end);
				HookDown(HueArea,   function(B) DraggingHue   = B end);
				HookDown(AlphaArea, function(B) DraggingAlpha = B end);

				Library:Connection(UserInputService.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						DraggingSat   = false;
						DraggingHue   = false;
						DraggingAlpha = false;
					end;
				end);

				Library:Connection(UserInputService.InputChanged, function(Input)
					if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end;
					if not (DraggingSat or DraggingHue or DraggingAlpha) then return end;
					local M = UserInputService:GetMouseLocation();
					local Mx, My = M.X, M.Y - GuiInset;
					if DraggingSat then
						local Ap = SatValArea.AbsolutePosition;
						local Sz = SatValArea.AbsoluteSize;
						S = Sz.X > 0 and math.clamp((Mx - Ap.X) / Sz.X, 0, 1) or 0;
						V = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
					elseif DraggingHue then
						local Ap = HueArea.AbsolutePosition;
						local Sz = HueArea.AbsoluteSize;
						H = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
					elseif DraggingAlpha then
						local Ap = AlphaArea.AbsolutePosition;
						local Sz = AlphaArea.AbsoluteSize;
						A = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
					end;
					ApplyState();
				end);

				Library:Connection(UserInputService.InputBegan, function(Input)
					if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
					if not Open then return end;
					local M = UserInputService:GetMouseLocation();
					local Mx, My = M.X, M.Y - GuiInset;
					local function Inside(F)
						local Ap, Sz = F.AbsolutePosition, F.AbsoluteSize;
						return Mx >= Ap.X and Mx <= Ap.X + Sz.X and My >= Ap.Y and My <= Ap.Y + Sz.Y;
					end;
					if not Inside(PickerHolder) and not Inside(Swatch) then
						SetVisible(false);
					end;
				end);

				if Opts.Tooltip then Library:Tooltip(Row, Opts.Tooltip) end;
				if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
					Opts.Dependency:OnChange(function(S) Row.Visible = S end);
				end;

				local CpObj = { Container = Row, Swatch = Swatch, Picker = PickerHolder };
				function CpObj:Get() return Color, A end;
				function CpObj:Set(NewColor, NewAlpha)
					if typeof(NewColor) == "Color3" then H, S, V = Color3.toHSV(NewColor) end;
					if NewAlpha then A = math.clamp(NewAlpha, 0, 1) end;
					ApplyState();
				end;
				return CpObj;
			end;

			function SecRef:Dropdown(Opts)
				Opts = typeof(Opts) == "table" and Opts or {};
				local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Dropdown");
				local Options  = typeof(Opts.Options) == "table" and Opts.Options or {};
				local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
				local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
				local Multi    = Opts.Multi == true;

				local Value;
				if Multi then
					Value = {};
					if typeof(Opts.Default) == "table" then
						for _, V in Opts.Default do Value[tostring(V)] = true end;
					elseif Opts.Default ~= nil then
						Value[tostring(Opts.Default)] = true;
					end;
				else
					Value = tostring(Opts.Default or Options[1] or "");
				end;
				Library.Flags[Flag] = Value;

				local Container = Library:CreateInstance("Frame", {
					Name                   = "Dropdown_" .. Name;
					Parent                 = self.Body;
					Size                   = UDim2.new(1, 0, 0, 36);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
				});

				local Lbl = Library:CreateInstance("TextLabel", {
					Name                   = "Label";
					Parent                 = Container;
					Position               = UDim2.new(0, 0, 0, 0);
					Size                   = UDim2.new(1, 0, 0, 12);
					BackgroundTransparency = 1;
					Text                   = Name;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
				});
				if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

				local Box = Library:CreateInstance("TextButton", {
					Name             = "Box";
					Parent           = Container;
					AnchorPoint      = Vector2.new(0, 1);
					Position         = UDim2.new(0, 0, 1, 0);
					Size             = UDim2.new(1, 0, 0, 21);
					BackgroundColor3 = Color3.fromHex("000000");
					BorderSizePixel  = 0;
					AutoButtonColor  = false;
					Text             = "";
				});
				local BoxGray = Library:CreateInstance("Frame", {
					Parent           = Box;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
				});
				local BoxInside = Library:CreateInstance("Frame", {
					Parent           = BoxGray;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				Library:CreateInstance("UIGradient", {
					Parent   = BoxInside;
					Rotation = 90;
					Color    = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
						NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
					});
				});

				local ValLbl = Library:CreateInstance("TextLabel", {
					Name                   = "Value";
					Parent                 = BoxInside;
					Position               = UDim2.new(0, 4, 0, 0);
					Size                   = UDim2.new(1, -14, 1, 0);
					BackgroundTransparency = 1;
					Text                   = "";
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
					TextTruncate           = Enum.TextTruncate.AtEnd;
					ClipsDescendants       = true;
				});
				local Arrow = Library:CreateInstance("Frame", {
					Name                   = "Arrow";
					Parent                 = BoxInside;
					AnchorPoint            = Vector2.new(1, 0.5);
					Position               = UDim2.new(1, -4, 0.5, 0);
					Size                   = UDim2.fromOffset(7, 7);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
				});
				Library:CreateInstance("Frame", {
					Name             = "Horiz";
					Parent           = Arrow;
					AnchorPoint      = Vector2.new(0.5, 0.5);
					Position         = UDim2.new(0.5, 0, 0.5, 0);
					Size             = UDim2.fromOffset(7, 1);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				local ArrowV = Library:CreateInstance("Frame", {
					Name             = "Vert";
					Parent           = Arrow;
					AnchorPoint      = Vector2.new(0.5, 0.5);
					Position         = UDim2.new(0.5, 0, 0.5, 0);
					Size             = UDim2.fromOffset(1, 7);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				local function SetArrow(Plus) ArrowV.Visible = Plus end;
				if ProggyCleanFont then
					ValLbl.FontFace = ProggyCleanFont;
				end;

				local Popup = Library:CreateInstance("CanvasGroup", {
					Name              = "DropdownPopup";
					Parent            = Gui;
					Size              = UDim2.new(0, 100, 0, 0);
					AutomaticSize     = Enum.AutomaticSize.Y;
					BackgroundColor3  = Color3.fromHex("000000");
					BorderSizePixel   = 0;
					Visible           = false;
					GroupTransparency = 1;
					ZIndex            = 50;
				});
				Library:CreateInstance("UIPadding", {
					Parent        = Popup;
					PaddingLeft   = UDim.new(0, 1);
					PaddingRight  = UDim.new(0, 1);
					PaddingTop    = UDim.new(0, 1);
					PaddingBottom = UDim.new(0, 1);
				});
				local PopupGray = Library:CreateInstance("Frame", {
					Parent           = Popup;
					Position         = UDim2.new(0, 0, 0, 0);
					Size             = UDim2.new(1, 0, 0, 0);
					AutomaticSize    = Enum.AutomaticSize.Y;
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
					ZIndex           = 50;
				});
				Library:CreateInstance("UIPadding", {
					Parent        = PopupGray;
					PaddingLeft   = UDim.new(0, 1);
					PaddingRight  = UDim.new(0, 1);
					PaddingTop    = UDim.new(0, 1);
					PaddingBottom = UDim.new(0, 1);
				});
				local PopupInside = Library:CreateInstance("Frame", {
					Parent                 = PopupGray;
					Position               = UDim2.new(0, 0, 0, 0);
					Size                   = UDim2.new(1, 0, 0, 0);
					AutomaticSize          = Enum.AutomaticSize.Y;
					BackgroundColor3       = Color3.fromHex("131313");
					BorderSizePixel        = 0;
					ZIndex                 = 50;
				});
				Library:CreateInstance("UIListLayout", {
					Parent        = PopupInside;
					FillDirection = Enum.FillDirection.Vertical;
					SortOrder     = Enum.SortOrder.LayoutOrder;
					Padding       = UDim.new(0, 0);
				});

				local Open = false;
				local OptionButtons = {};
				local ClosePopup;

				local function IsSelected(Opt)
					Opt = tostring(Opt);
					if Multi then return Value[Opt] == true end;
					return Opt == Value;
				end;

				local function DisplayText()
					if not Multi then return tostring(Value) end;
					local Sel = {};
					for _, Opt in Options do
						if Value[tostring(Opt)] then table.insert(Sel, tostring(Opt)) end;
					end;
					return (#Sel > 0) and table.concat(Sel, ", ") or "None";
				end;

				local OptColorInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
				local function RefreshColors()
					for _, B in OptionButtons do
						local Target = IsSelected(B.Text) and Library.Accent or Color3.fromHex("FFFFFF");
						Library:Tween(B, OptColorInfo, { TextColor3 = Target }):Play();
					end;
				end;

				local function SetVal(V, Fire)
					V = tostring(V);
					if Multi then
						Value[V] = (not Value[V]) or nil;
					else
						if V == Value then return end;
						Value = V;
					end;
					Library.Flags[Flag] = Value;
					ValLbl.Text = DisplayText();
					RefreshColors();
					if Fire ~= false then Callback(Value) end;
				end;

				local function BuildOptions()
					for _, C in PopupInside:GetChildren() do
						if C:IsA("TextButton") then C:Destroy() end;
					end;
					table.clear(OptionButtons);
					for I, Opt in Options do
						local Btn = Library:CreateInstance("TextButton", {
							Name                   = "Option_" .. tostring(Opt);
							Parent                 = PopupInside;
							Size                   = UDim2.new(1, 0, 0, 14);
							BackgroundColor3       = Color3.fromHex("131313");
							BorderSizePixel        = 0;
							AutoButtonColor        = false;
							Text                   = tostring(Opt);
							TextColor3             = IsSelected(Opt) and Library.Accent or Color3.fromHex("FFFFFF");
							TextSize               = 12;
							TextXAlignment         = Enum.TextXAlignment.Left;
							TextYAlignment         = Enum.TextYAlignment.Center;
							LayoutOrder            = I;
							ZIndex                 = 51;
						});
						Library:CreateInstance("UIPadding", {
							Parent      = Btn;
							PaddingLeft = UDim.new(0, 5);
						});
						if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
						Btn.MouseButton1Click:Connect(function()
							SetVal(Btn.Text);
							if not Multi and ClosePopup then ClosePopup() end;
						end);
						table.insert(OptionButtons, Btn);
					end;
				end;
				BuildOptions();
				ValLbl.Text = DisplayText();
				Library:OnAccent(RefreshColors);

				local PopupIn  = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
				local PopupOut = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
				local SlideOff = 10;
				local PopupGap = 60;

				local function AnchorXY()
					local AbsPos  = Box.AbsolutePosition;
					local AbsSize = Box.AbsoluteSize;
					Popup.Size = UDim2.new(0, AbsSize.X, 0, 0);
					return AbsPos.X, AbsPos.Y + AbsSize.Y + PopupGap;
				end;

				ClosePopup = function()
					if not Open then return end;
					Open = false;
					local X, Y = AnchorXY();
					Library:Tween(Popup, PopupOut, {
						Position          = UDim2.fromOffset(X, Y - SlideOff);
						GroupTransparency = 1;
					}):Play();
					task.delay(PopupOut.Time, function()
						if not Open then Popup.Visible = false end;
					end);
					SetArrow(true);
				end;

				Box.MouseButton1Click:Connect(function()
					Open = not Open;
					local X, Y = AnchorXY();
					if Open then
						Popup.Visible           = true;
						Popup.Position          = UDim2.fromOffset(X, Y - SlideOff);
						Popup.GroupTransparency = 1;
						Library:Tween(Popup, PopupIn, {
							Position          = UDim2.fromOffset(X, Y);
							GroupTransparency = 0;
						}):Play();
						SetArrow(false);
					else
						Library:Tween(Popup, PopupOut, {
							Position          = UDim2.fromOffset(X, Y - SlideOff);
							GroupTransparency = 1;
						}):Play();
						task.delay(PopupOut.Time, function()
							if not Open then Popup.Visible = false end;
						end);
						SetArrow(true);
					end;
				end);

				Library:Connection(UserInputService.InputBegan, function(Input)
					if not Open then return end;
					if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
					local Mx, My = Input.Position.X, Input.Position.Y;
					local function InAbs(Inst)
						local P, S = Inst.AbsolutePosition, Inst.AbsoluteSize;
						return Mx >= P.X and Mx <= P.X + S.X and My >= P.Y and My <= P.Y + S.Y;
					end;
					if InAbs(Box) or InAbs(Popup) then return end;
					Open = false;
					local X, Y = AnchorXY();
					Library:Tween(Popup, PopupOut, {
						Position          = UDim2.fromOffset(X, Y - SlideOff);
						GroupTransparency = 1;
					}):Play();
					task.delay(PopupOut.Time, function()
						if not Open then Popup.Visible = false end;
					end);
					SetArrow(true);
				end);

				if Opts.Tooltip then Library:Tooltip(Box, Opts.Tooltip) end;
				if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
					Opts.Dependency:OnChange(function(S) Container.Visible = S end);
				end;

				local Obj = { Container = Container, Box = Box, Popup = Popup };
				function Obj:Get() return Value end;
				function Obj:Set(V)
					if Multi then
						Value = {};
						if typeof(V) == "table" then
							for _, Item in V do Value[tostring(Item)] = true end;
						elseif V ~= nil then
							Value[tostring(V)] = true;
						end;
						Library.Flags[Flag] = Value;
						ValLbl.Text = DisplayText();
						RefreshColors();
						Callback(Value);
					else
						SetVal(V);
					end;
				end;
				function Obj:SetOptions(Opts2)
					Options = typeof(Opts2) == "table" and Opts2 or {};
					BuildOptions();
					ValLbl.Text = DisplayText();
				end;
				return Obj;
			end;

			function SecRef:Textbox(Opts)
				Opts = typeof(Opts) == "table" and Opts or {};
				local Name        = tostring(Opts.Name or Opts.Title or Opts.Text or "Textbox");
				local Default     = tostring(Opts.Default or "");
				local Placeholder = tostring(Opts.Placeholder or "...");
				local Numeric     = Opts.Numeric == true;
				local Callback    = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
				local Flag        = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
				Library.Flags[Flag] = Default;

				local Container = Library:CreateInstance("Frame", {
					Name                   = "Textbox_" .. Name;
					Parent                 = self.Body;
					Size                   = UDim2.new(1, 0, 0, 36);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
				});

				local Lbl = Library:CreateInstance("TextLabel", {
					Name                   = "Label";
					Parent                 = Container;
					Position               = UDim2.new(0, 0, 0, 0);
					Size                   = UDim2.new(1, 0, 0, 12);
					BackgroundTransparency = 1;
					Text                   = Name;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
				});
				if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

				local Box = Library:CreateInstance("Frame", {
					Name             = "Box";
					Parent           = Container;
					AnchorPoint      = Vector2.new(0, 1);
					Position         = UDim2.new(0, 0, 1, 0);
					Size             = UDim2.new(1, 0, 0, 21);
					BackgroundColor3 = Color3.fromHex("000000");
					BorderSizePixel  = 0;
				});
				local BoxGray = Library:CreateInstance("Frame", {
					Parent           = Box;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
				});
				local BoxInside = Library:CreateInstance("Frame", {
					Parent           = BoxGray;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				Library:CreateInstance("UIGradient", {
					Parent   = BoxInside;
					Rotation = 90;
					Color    = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
						NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
					});
				});

				local Input = Library:CreateInstance("TextBox", {
					Name                   = "Input";
					Parent                 = BoxInside;
					Position               = UDim2.new(0, 4, 0, 0);
					Size                   = UDim2.new(1, -8, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					ClearTextOnFocus       = false;
					Text                   = Default;
					PlaceholderText        = Placeholder;
					PlaceholderColor3      = Color3.fromHex("5E626B");
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
					ClipsDescendants       = true;
				});
				if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;

				local function Commit(V, Fire)
					V = tostring(V);
					if Numeric then
						local Num = tonumber(V);
						V = Num and tostring(Num) or "";
					end;
					Input.Text = V;
					Library.Flags[Flag] = V;
					if Fire ~= false then Callback(V) end;
				end;

				Input.FocusLost:Connect(function(Enter)
					Commit(Input.Text);
				end);

				if Opts.Tooltip then Library:Tooltip(Box, Opts.Tooltip) end;
				if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
					Opts.Dependency:OnChange(function(S) Container.Visible = S end);
				end;

				local Obj = { Container = Container, Box = Box, Input = Input };
				function Obj:Get() return Input.Text end;
				function Obj:Set(V) Commit(V, false) end;
				return Obj;
			end;

			function SecRef:Keybind(Opts)
				Opts = typeof(Opts) == "table" and Opts or {};
				local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Keybind");
				local Mode     = string.lower(tostring(Opts.Mode or "Toggle"));
				local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
				local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
				local Key      = Opts.Default;
				local State    = false;
				Library.Flags[Flag] = State;

				local function KeyDisplay(K)
					if K == nil then return "None" end;
					if typeof(K) == "EnumItem" then
						return Library.KeyNames[K] or K.Name;
					end;
					return tostring(K);
				end;

				local Row = Library:CreateInstance("TextButton", {
					Name                   = "Keybind_" .. Name;
					Parent                 = self.Body;
					Size                   = UDim2.new(1, 0, 0, 16);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					AutoButtonColor        = false;
					Text                   = "";
				});

				local Lbl = Library:CreateInstance("TextLabel", {
					Name                   = "Label";
					Parent                 = Row;
					AnchorPoint            = Vector2.new(0, 0.5);
					Position               = UDim2.new(0, 0, 0.5, 0);
					Size                   = UDim2.new(1, -62, 1, 0);
					BackgroundTransparency = 1;
					Text                   = Name;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
				});
				if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

				local Box = Library:CreateInstance("Frame", {
					Name             = "KeyBox";
					Parent           = Row;
					AnchorPoint      = Vector2.new(1, 0.5);
					Position         = UDim2.new(1, 0, 0.5, 0);
					Size             = UDim2.fromOffset(56, 16);
					BackgroundColor3 = Color3.fromHex("000000");
					BorderSizePixel  = 0;
				});
				local BoxGray = Library:CreateInstance("Frame", {
					Parent           = Box;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
				});
				local BoxInside = Library:CreateInstance("Frame", {
					Parent           = BoxGray;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				Library:CreateInstance("UIGradient", {
					Parent   = BoxInside;
					Rotation = 90;
					Color    = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
						NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
					});
				});

				local Display = Library:CreateInstance("TextLabel", {
					Name                   = "Display";
					Parent                 = BoxInside;
					Size                   = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					Text                   = KeyDisplay(Key);
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Center;
					TextYAlignment         = Enum.TextYAlignment.Center;
				});
				if ProggyCleanFont then Display.FontFace = ProggyCleanFont end;

				local Listening = false;
				local ListenConn;

				local function Refresh()
					if Listening then
						Display.Text       = "...";
						Display.TextColor3 = Library.Accent;
					else
						Display.Text       = KeyDisplay(Key);
						Display.TextColor3 = Color3.fromHex("FFFFFF");
					end;
				end;

				local function CancelListen()
					if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
					Listening = false;
					Refresh();
				end;

				local function StartListen()
					if Listening then CancelListen(); return end;
					Listening = true;
					Refresh();
					task.defer(function()
						if not Listening then return end;
						ListenConn = UserInputService.InputBegan:Connect(function(Input)
							local T = Input.UserInputType;
							if T == Enum.UserInputType.Keyboard then
								local K = Input.KeyCode;
								if K == Enum.KeyCode.Escape then
									CancelListen();
								else
									Key = K;
									Listening = false;
									if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
									Refresh();
									Library:NotifyKeybind();
								end;
							elseif T == Enum.UserInputType.MouseButton1
								or T == Enum.UserInputType.MouseButton2
								or T == Enum.UserInputType.MouseButton3 then
								Key = T;
								Listening = false;
								if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
								Refresh();
								Library:NotifyKeybind();
							end;
						end);
					end);
				end;

				Row.MouseButton1Click:Connect(StartListen);

				local ModeOpts = { "Toggle", "Hold", "Always" };

				local Popup = Library:CreateInstance("CanvasGroup", {
					Name              = "KeybindPopup_" .. Name;
					Parent            = Gui;
					Size              = UDim2.new(0, 80, 0, 0);
					AutomaticSize     = Enum.AutomaticSize.Y;
					BackgroundColor3  = Color3.fromHex("000000");
					BorderSizePixel   = 0;
					Visible           = false;
					GroupTransparency = 1;
					ZIndex            = 50;
				});
				Library:CreateInstance("UIPadding", {
					Parent        = Popup;
					PaddingLeft   = UDim.new(0, 1);
					PaddingRight  = UDim.new(0, 1);
					PaddingTop    = UDim.new(0, 1);
					PaddingBottom = UDim.new(0, 1);
				});
				local PopupGray = Library:CreateInstance("Frame", {
					Parent           = Popup;
					Size             = UDim2.new(1, 0, 0, 0);
					AutomaticSize    = Enum.AutomaticSize.Y;
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
					ZIndex           = 50;
				});
				Library:CreateInstance("UIPadding", {
					Parent        = PopupGray;
					PaddingLeft   = UDim.new(0, 1);
					PaddingRight  = UDim.new(0, 1);
					PaddingTop    = UDim.new(0, 1);
					PaddingBottom = UDim.new(0, 1);
				});
				local PopupInside = Library:CreateInstance("Frame", {
					Parent           = PopupGray;
					Size             = UDim2.new(1, 0, 0, 0);
					AutomaticSize    = Enum.AutomaticSize.Y;
					BackgroundColor3 = Color3.fromHex("131313");
					BorderSizePixel  = 0;
					ZIndex           = 50;
				});
				Library:CreateInstance("UIListLayout", {
					Parent        = PopupInside;
					FillDirection = Enum.FillDirection.Vertical;
					SortOrder     = Enum.SortOrder.LayoutOrder;
					Padding       = UDim.new(0, 0);
				});
				Library:CreateInstance("UIPadding", {
					Parent        = PopupInside;
					PaddingTop    = UDim.new(0, 2);
					PaddingBottom = UDim.new(0, 2);
				});

				local PopupOpen = false;
				local PopupToken = 0;
				local PopupInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
				local PopupSlide = 8;
				local ModeBtns = {};

				local function RefreshModeBtns()
					for M, B in ModeBtns do
						B.TextColor3 = (M == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
					end;
				end;

				local function ClosePopup()
					if not PopupOpen then return end;
					PopupOpen = false;
					PopupToken = PopupToken + 1;
					local Mine = PopupToken;
					local Ap = Box.AbsolutePosition;
					local Sz = Box.AbsoluteSize;
					Library:Tween(Popup, PopupInfo, {
						GroupTransparency = 1;
						Position          = UDim2.fromOffset(Ap.X + Sz.X - 80, Ap.Y + Sz.Y + 62 - PopupSlide);
					}):Play();
					task.delay(PopupInfo.Time, function()
						if PopupToken == Mine then Popup.Visible = false end;
					end);
				end;

				local function OpenPopup()
					if PopupOpen then ClosePopup(); return end;
					PopupOpen = true;
					PopupToken = PopupToken + 1;
					RefreshModeBtns();
					local Ap = Box.AbsolutePosition;
					local Sz = Box.AbsoluteSize;
					Popup.GroupTransparency = 1;
					Popup.Position = UDim2.fromOffset(Ap.X + Sz.X - 80, Ap.Y + Sz.Y + 62 - PopupSlide);
					Popup.Visible = true;
					Library:Tween(Popup, PopupInfo, {
						GroupTransparency = 0;
						Position          = UDim2.fromOffset(Ap.X + Sz.X - 80, Ap.Y + Sz.Y + 62);
					}):Play();
				end;

				for I, M in ModeOpts do
					local Btn = Library:CreateInstance("TextButton", {
						Parent                 = PopupInside;
						Size                   = UDim2.new(1, 0, 0, 14);
						BackgroundTransparency = 1;
						BorderSizePixel        = 0;
						AutoButtonColor        = false;
						Text                   = M;
						TextColor3             = Color3.fromHex("FFFFFF");
						TextSize               = 12;
						TextXAlignment         = Enum.TextXAlignment.Left;
						LayoutOrder            = I;
					});
					Library:CreateInstance("UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 6) });
					if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
					ModeBtns[M:lower()] = Btn;
					Btn.MouseButton1Click:Connect(function()
						Mode = M:lower();
						if Mode == "always" then
							State = true;
							Library.Flags[Flag] = State;
							Callback(true);
						end;
						RefreshModeBtns();
						Library:NotifyKeybind();
						ClosePopup();
					end);
				end;
				RefreshModeBtns();

				Row.MouseButton2Click:Connect(OpenPopup);

				Library:Connection(UserInputService.InputBegan, function(Input)
					if not PopupOpen then return end;
					if Input.UserInputType ~= Enum.UserInputType.MouseButton1
						and Input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end;
					local M = UserInputService:GetMouseLocation();
					local Ap = Popup.AbsolutePosition;
					local Sz = Popup.AbsoluteSize;
					if M.X < Ap.X or M.Y < Ap.Y or M.X > Ap.X + Sz.X or M.Y > Ap.Y + Sz.Y then
						local Bp = Box.AbsolutePosition;
						local Bs = Box.AbsoluteSize;
						if M.X < Bp.X or M.Y < Bp.Y or M.X > Bp.X + Bs.X or M.Y > Bp.Y + Bs.Y then
							ClosePopup();
						end;
					end;
				end);

				local function KeyMatches(Input)
					if Key == nil or typeof(Key) ~= "EnumItem" then return false end;
					if Key.EnumType == Enum.KeyCode then
						return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key;
					elseif Key.EnumType == Enum.UserInputType then
						return Input.UserInputType == Key;
					end;
					return false;
				end;

				Library:Connection(UserInputService.InputBegan, function(Input, GameProc)
					if GameProc then return end;
					if Listening then return end;
					if UserInputService:GetFocusedTextBox() then return end;
					if not KeyMatches(Input) then return end;
					if Mode == "always" then
						Callback();
					elseif Mode == "hold" then
						State = true;
						Library.Flags[Flag] = State;
						Callback(true);
					else
						State = not State;
						Library.Flags[Flag] = State;
						Callback(State);
					end;
				end);

				Library:Connection(UserInputService.InputEnded, function(Input)
					if Mode ~= "hold" then return end;
					if not KeyMatches(Input) then return end;
					if State then
						State = false;
						Library.Flags[Flag] = State;
						Callback(false);
					end;
				end);

				if Opts.Tooltip then Library:Tooltip(Row, Opts.Tooltip) end;
				if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
					Opts.Dependency:OnChange(function(S) Row.Visible = S end);
				end;

				Library:RegisterKeybind({
					Name     = Name;
					GetMode  = function() return Mode end;
					GetKey   = function() return Key end;
					GetState = function() return State end;
				});

				local Obj = { Container = Row, Box = Box, Display = Display };
				function Obj:Get() return State end;
				function Obj:GetKey() return Key end;
				function Obj:SetKey(K)
					if Listening then CancelListen() end;
					Key = K;
					Refresh();
				end;
				return Obj;
			end;

			function SecRef:List(Opts)
				Opts = typeof(Opts) == "table" and Opts or {};
				local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "List");
				local Options  = typeof(Opts.Options) == "table" and Opts.Options or {};
				local Multi    = Opts.Multi == true;
				local Height   = tonumber(Opts.Height) or 100;
				local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
				local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));

				local Value;
				if Multi then
					Value = {};
					if typeof(Opts.Default) == "table" then
						for _, V in Opts.Default do Value[tostring(V)] = true end;
					end;
				else
					Value = tostring(Opts.Default or Options[1] or "");
				end;
				Library.Flags[Flag] = Value;

				local Container = Library:CreateInstance("Frame", {
					Name                   = "List_" .. Name;
					Parent                 = self.Body;
					Size                   = UDim2.new(1, 0, 0, Height + 16);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
				});

				local Lbl = Library:CreateInstance("TextLabel", {
					Parent                 = Container;
					Size                   = UDim2.new(1, 0, 0, 12);
					BackgroundTransparency = 1;
					Text                   = Name;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
				});
				if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

				local Box = Library:CreateInstance("Frame", {
					Name             = "Box";
					Parent           = Container;
					AnchorPoint      = Vector2.new(0, 1);
					Position         = UDim2.new(0, 0, 1, 0);
					Size             = UDim2.new(1, 0, 0, Height);
					BackgroundColor3 = Color3.fromHex("000000");
					BorderSizePixel  = 0;
				});
				local BoxGray = Library:CreateInstance("Frame", {
					Parent = Box; Position = UDim2.new(0, 1, 0, 1);
					Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
				});
				local BoxInside = Library:CreateInstance("Frame", {
					Parent = BoxGray; Position = UDim2.new(0, 1, 0, 1);
					Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
				});
				Library:CreateInstance("UIGradient", {
					Parent = BoxInside; Rotation = 90;
					Color = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
						NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
					});
				});

				local Scroller = Library:CreateInstance("ScrollingFrame", {
					Parent                 = BoxInside;
					Size                   = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					CanvasSize             = UDim2.new(0, 0, 0, 0);
					AutomaticCanvasSize    = Enum.AutomaticSize.Y;
					ScrollBarThickness     = 2;
					ScrollBarImageColor3   = Library.Accent;
					ScrollingDirection     = Enum.ScrollingDirection.Y;
					ClipsDescendants       = true;
				});
				Library:RegisterAccent(Scroller, "ScrollBarImageColor3");
				Library:CreateInstance("UIListLayout", {
					Parent        = Scroller;
					FillDirection = Enum.FillDirection.Vertical;
					SortOrder     = Enum.SortOrder.LayoutOrder;
				});
				Library:CreateInstance("UIPadding", {
					Parent     = Scroller;
					PaddingTop = UDim.new(0, 2);
				});

				local OptionButtons = {};
				local function IsSelected(Opt)
					Opt = tostring(Opt);
					if Multi then return Value[Opt] == true end;
					return Opt == Value;
				end;
				local OptColorInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
				local function RefreshColors()
					for _, B in OptionButtons do
						local Target = IsSelected(B.Text) and Library.Accent or Color3.fromHex("FFFFFF");
						Library:Tween(B, OptColorInfo, { TextColor3 = Target }):Play();
					end;
				end;
				local function SetVal(V, Fire)
					V = tostring(V);
					if Multi then
						Value[V] = (not Value[V]) or nil;
					else
						if V == Value then return end;
						Value = V;
					end;
					Library.Flags[Flag] = Value;
					RefreshColors();
					if Fire ~= false then Callback(Value) end;
				end;
				local function BuildOptions()
					for _, C in Scroller:GetChildren() do
						if C:IsA("TextButton") then C:Destroy() end;
					end;
					table.clear(OptionButtons);
					for I, Opt in Options do
						local Btn = Library:CreateInstance("TextButton", {
							Name                   = "Opt_" .. tostring(Opt);
							Parent                 = Scroller;
							Size                   = UDim2.new(1, 0, 0, 14);
							BackgroundTransparency = 1;
							BorderSizePixel        = 0;
							AutoButtonColor        = false;
							Text                   = tostring(Opt);
							TextColor3             = IsSelected(Opt) and Library.Accent or Color3.fromHex("FFFFFF");
							TextSize               = 12;
							TextXAlignment         = Enum.TextXAlignment.Left;
							LayoutOrder            = I;
						});
						Library:CreateInstance("UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 5) });
						if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
						Btn.MouseButton1Click:Connect(function() SetVal(Btn.Text) end);
						table.insert(OptionButtons, Btn);
					end;
				end;
				BuildOptions();
				Library:OnAccent(RefreshColors);

				if Opts.Tooltip then Library:Tooltip(Box, Opts.Tooltip) end;
				if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
					Opts.Dependency:OnChange(function(S) Container.Visible = S end);
				end;

				local Obj = { Container = Container, Box = Box, Scroller = Scroller };
				function Obj:Get() return Value end;
				function Obj:Set(V) SetVal(V) end;
				function Obj:SetOptions(Opts2)
					Options = typeof(Opts2) == "table" and Opts2 or {};
					BuildOptions();
				end;
				return Obj;
			end;

			return SecRef;
		end;

		local WinRef = self;
		Btn.MouseButton1Click:Connect(function()
			for _, T in WinRef._Tabs do
				if T ~= TabRef and T.Active then T:SetActive(false) end;
			end;
			TabRef:SetActive(true);
		end);

		table.insert(self._Tabs, TabRef);

		local N = #self._Tabs;
		for I, T in self._Tabs do
			T.Button.Size = UDim2.new(1 / N, 0, 1, 0);
			T.IsLeft  = (I == 1);
			T.IsRight = (I == N);
			T:SetActive(T.Active);
		end;

		if N == 1 then
			TabRef:SetActive(true);
		end;

		local SepInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local function FadePiece(P, T)
			Library:Tween(P, SepInfo, { BackgroundTransparency = T }):Play();
		end;
		local function RefreshSeparators()
			for I, T in self._Tabs do
				local Prev = self._Tabs[I - 1];
				local Next = self._Tabs[I + 1];
				if T.Active then
					FadePiece(T.Separator,   1);
					FadePiece(T.TopBlack,    1);
					FadePiece(T.TopGray,     1);
					FadePiece(T.BottomBlack, 1);
					FadePiece(T.BottomGray,  1);
					FadePiece(T.LeftBlack,   1);
					FadePiece(T.LeftGray,    1);
					FadePiece(T.RightBlack,  1);
					FadePiece(T.RightGray,   1);
					FadePiece(T.TopGradient, 0);
				else
					FadePiece(T.TopGradient, 1);
					local LeftShown  = (Prev ~= nil) and Prev.Active;
					local RightShown = (Next ~= nil) and Next.Active;
					FadePiece(T.TopBlack,    0);
					FadePiece(T.TopGray,     0);
					FadePiece(T.BottomBlack, 0);
					FadePiece(T.BottomGray,  0);
					FadePiece(T.LeftBlack,   LeftShown  and 0 or 1);
					FadePiece(T.LeftGray,    LeftShown  and 0 or 1);
					FadePiece(T.RightBlack,  RightShown and 0 or 1);
					FadePiece(T.RightGray,   RightShown and 0 or 1);
					FadePiece(T.Separator,   (Next ~= nil and not Next.Active) and 0 or 1);
					local Li = LeftShown and 1 or 0;
					local Ri = RightShown and 1 or 0;
					T.TopGray.Position    = UDim2.new(0, Li, 0, 1);
					T.TopGray.Size        = UDim2.new(1, -Li - Ri, 0, 1);
					T.BottomGray.Position = UDim2.new(0, Li, 1, -1);
					T.BottomGray.Size     = UDim2.new(1, -Li - Ri, 0, 1);
				end;
			end;
		end;
		RefreshSeparators();

		local OrigSetActive = TabRef.SetActive;
		function TabRef:SetActive(State)
			OrigSetActive(self, State);
			RefreshSeparators();
		end;

		function TabRef:ApplySettings()
			local ConfigDir    = Library.Directory .. "/Configs";
			local ThemeDir     = Library.Directory .. "/Themes";
			local AutoLoadFile = Library.Directory .. "/Autoload.txt";

			local function ListConfigs()
				local Out = {};
				if isfolder and isfolder(ConfigDir) then
					for _, F in listfiles(ConfigDir) do
						if string.find(F, "%.json$") then
							local Nm = string.gsub(F, ".*[/\\]", ""):gsub("%.json$", "");
							if not string.match(string.lower(Nm), "^autoload") then
								table.insert(Out, Nm);
							end;
						end;
					end;
				end;
				if #Out == 0 then table.insert(Out, "default") end;
				return Out;
			end;

			local function ListThemes()
				local Out = {};
				if isfolder and isfolder(ThemeDir) then
					for _, F in listfiles(ThemeDir) do
						if string.find(F, "%.json$") then
							local Nm = string.gsub(F, ".*[/\\]", ""):gsub("%.json$", "");
							table.insert(Out, Nm);
						end;
					end;
				end;
				if #Out == 0 then table.insert(Out, "default") end;
				return Out;
			end;

			local SecCfg = self:Section({ Name = "Configuration", Side = "Left" });
			local ConfigList = SecCfg:List({
				Name    = "Configs";
				Options = ListConfigs();
				Default = "default";
				Height  = 90;
			});
			SecCfg:Textbox({ Name = "Config Name", Flag = "ConfigName", Placeholder = "name..." });
			SecCfg:Button({
				Name = "Save";
				Callback = function()
					local Nm = Library.Flags.ConfigName;
					if not Nm or Nm == "" then Library:Notify("Enter a config name first", 3); return end;
					local Save = {};
					for K, V in Library.Flags do
						if typeof(V) == "Color3" then Save[K] = { _t = "Color3", v = V:ToHex() };
						elseif typeof(V) == "table" then Save[K] = V;
						else Save[K] = V end;
					end;
					writefile(ConfigDir .. "/" .. Nm .. ".json", HttpService:JSONEncode(Save));
					ConfigList:SetOptions(ListConfigs());
					Library:Notify("Saved config: " .. Nm, 3);
				end;
			}):Button({
				Name = "Load";
				Callback = function()
					local Nm = ConfigList:Get();
					local Path = ConfigDir .. "/" .. Nm .. ".json";
					if not (isfile and isfile(Path)) then Library:Notify("Config not found", 3); return end;
					local Ok, Data = pcall(HttpService.JSONDecode, HttpService, readfile(Path));
					if not Ok then Library:Notify("Failed to decode config", 3); return end;
					for K, V in Data do
						if typeof(V) == "table" and V._t == "Color3" then
							Library.Flags[K] = Color3.fromHex(V.v);
						else
							Library.Flags[K] = V;
						end;
					end;
					Library:Notify("Loaded: " .. Nm, 3);
				end;
			});
			SecCfg:Button({
				Name = "Delete"; Confirm = true;
				Callback = function()
					local Nm = ConfigList:Get();
					local Path = ConfigDir .. "/" .. Nm .. ".json";
					if isfile and isfile(Path) then delfile(Path) end;
					ConfigList:SetOptions(ListConfigs());
					Library:Notify("Deleted: " .. Nm, 3);
				end;
			}):Button({
				Name = "Refresh";
				Callback = function()
					ConfigList:SetOptions(ListConfigs());
					Library:Notify("Refreshed configs", 2);
				end;
			});
			SecCfg:Button({
				Name = "Set As Auto Load";
				Callback = function()
					writefile(AutoLoadFile, ConfigList:Get());
					Library:Notify("Auto-load: " .. ConfigList:Get(), 3);
				end;
			});
			SecCfg:Button({
				Name = "Remove Auto Load"; Confirm = true;
				Callback = function()
					if isfile and isfile(AutoLoadFile) then writefile(AutoLoadFile, "") end;
					Library:Notify("Auto-load cleared", 3);
				end;
			});
			SecCfg:Button({
				Name = "Test Notification";
				Callback = function()
					Library:Notify('Hello there', 4);
				end;
			});

			local SecMenu = self:Section({ Name = "Menu", Side = "Left" });
			SecMenu:Dropdown({
				Name    = "Easing Style"; Flag = "MenuEaseStyle";
				Options = { "Linear", "Cubic", "Quad", "Quart", "Quint", "Sine", "Exponential", "Circular", "Back", "Elastic", "Bounce" };
				Default = "Quint";
				Callback = function(V) Library.EasingStyle = Enum.EasingStyle[V] end;
			});
			SecMenu:Dropdown({
				Name = "Easing Direction"; Flag = "MenuEaseDir";
				Options = { "In", "Out", "InOut" };
				Default = "Out";
				Callback = function(V) Library.EasingDirection = Enum.EasingDirection[V] end;
			});
			Library.EasingStyle     = Enum.EasingStyle.Quint;
			Library.EasingDirection = Enum.EasingDirection.Out;
			SecMenu:Slider({
				Name = "Tweening Speed"; Flag = "TweeningSpeed";
				Min = 0.05, Max = 2, Step = 0.05, Decimals = 2, Default = 1;
				Callback = function(V) Library.AnimationSpeed = V end;
			});
			SecMenu:Slider({ Name = "Dragging Speed", Flag = "DraggingSpeed", Min = 0, Max = 2, Step = 0.05, Decimals = 2, Default = 0.05 });
			SecMenu:Textbox({ Name = "Prefix", Flag = "MenuPrefix", Placeholder = "menu prefix" });
			SecMenu:Textbox({ Name = "Suffix", Flag = "MenuSuffix", Placeholder = "menu suffix" });
			SecMenu:Keybind({
				Name     = "Menu Keybind";
				Default  = Enum.KeyCode.Insert;
				Mode     = "Always";
				Callback = function() Window:Toggle() end;
			});

			local SecHud = self:Section({ Name = "HUD", Side = "Right" });
			SecHud:Toggle({
				Name     = "Watermark", Default = true;
				Callback = function(S) if Library._Watermark then Library._Watermark.Gui.Enabled = S end end;
			});
			SecHud:Dropdown({
				Name    = "Watermark Options";
				Multi   = true;
				Flag    = "WatermarkOpts";
				Options = { "Title", "Fps", "Ping", "Game Name", "User ID", "LocalPlayer Name", "Date" };
				Default = { "Title", "Fps", "Ping" };
			});
			SecHud:Slider({ Name = "Refresh Rate", Flag = "WatermarkRate", Min = 0, Max = 2, Step = 0.05, Decimals = 2, Default = 0.1 });
			SecHud:Toggle({
				Name     = "Keybind List", Default = true;
				Callback = function(S) if Library._KeybindList then Library._KeybindList.Gui.Enabled = S end end;
			});

			do
				local LP = game:GetService("Players").LocalPlayer;
				local Fps, FpsAcc, FpsCnt = 60, 0, 0;
				Library:Connection(RunService.RenderStepped, function(Dt)
					FpsCnt = FpsCnt + 1; FpsAcc = FpsAcc + Dt;
					if FpsAcc >= 0.5 then
						Fps = math.round(FpsCnt / FpsAcc);
						FpsCnt, FpsAcc = 0, 0;
					end;
				end);
				local GameName = "Roblox";
				task.spawn(function()
					local Ok, Info = pcall(game.GetService(game, "MarketplaceService").GetProductInfo, game:GetService("MarketplaceService"), game.PlaceId);
					if Ok and Info and Info.Name then GameName = Info.Name end;
				end);
				local Acc = 0;
				Library:Connection(RunService.Heartbeat, function(Dt)
					local W = Library._Watermark;
					if not (W and W.Gui and W.Gui.Enabled) then return end;
					local Rate = Library.Flags.WatermarkRate or 0.1;
					Acc = Acc + Dt;
					if Acc < Rate then return end;
					Acc = 0;
					local Opts = Library.Flags.WatermarkOpts or {};
					local Parts = {};
					if Opts.Title              then table.insert(Parts, "Coincide") end;
					if Opts.Fps                then table.insert(Parts, Fps .. " fps") end;
					if Opts.Ping and LP        then table.insert(Parts, math.round(LP:GetNetworkPing() * 1000) .. " ms") end;
					if Opts["Game Name"]       then table.insert(Parts, GameName) end;
					if Opts["User ID"] and LP  then table.insert(Parts, tostring(LP.UserId)) end;
					if Opts["LocalPlayer Name"] and LP then table.insert(Parts, LP.Name) end;
					if Opts.Date               then table.insert(Parts, os.date("%H:%M:%S")) end;
					if #Parts > 0 then
						local Body   = table.concat(Parts, " | ");
						local Prefix = Library.Flags.MenuPrefix or "";
						local Suffix = Library.Flags.MenuSuffix or "";
						if Prefix ~= "" then Body = Prefix .. " " .. Body end;
						if Suffix ~= "" then Body = Body   .. " " .. Suffix end;
						W:SetText(Body);
					end;
				end);
			end;

			local SecTheme = self:Section({ Name = "Theming", Side = "Right" });
			SecTheme:Colorpicker({
				Name     = "Accent"; Flag = "Accent";
				Default  = Library.Accent;
				Alpha    = 1;
				Callback = function(C) Library:SetAccent(C) end;
			});
			SecTheme:Textbox({ Name = "Theme Name", Flag = "ThemeName", Placeholder = "theme name..." });
			local ThemeList = SecTheme:List({
				Name    = "Themes";
				Options = ListThemes();
				Default = "default";
				Height  = 80;
			});
			SecTheme:Button({
				Name = "Save";
				Callback = function()
					local Nm = Library.Flags.ThemeName;
					if not Nm or Nm == "" then Library:Notify("Enter a theme name", 3); return end;
					local Save = { Accent = Library.Accent:ToHex() };
					writefile(ThemeDir .. "/" .. Nm .. ".json", HttpService:JSONEncode(Save));
					ThemeList:SetOptions(ListThemes());
					Library:Notify("Saved theme: " .. Nm, 3);
				end;
			}):Button({
				Name = "Load";
				Callback = function()
					local Nm = ThemeList:Get();
					local Path = ThemeDir .. "/" .. Nm .. ".json";
					if not (isfile and isfile(Path)) then Library:Notify("Theme not found", 3); return end;
					local Ok, Data = pcall(HttpService.JSONDecode, HttpService, readfile(Path));
					if Ok and Data.Accent then
						Library:SetAccent(Color3.fromHex(Data.Accent));
						Library:Notify("Loaded theme: " .. Nm, 3);
					end;
				end;
			});
			SecTheme:Button({
				Name = "Delete"; Confirm = true;
				Callback = function()
					local Nm = ThemeList:Get();
					local Path = ThemeDir .. "/" .. Nm .. ".json";
					if isfile and isfile(Path) then delfile(Path) end;
					ThemeList:SetOptions(ListThemes());
					Library:Notify("Deleted theme: " .. Nm, 3);
				end;
			}):Button({
				Name = "Refresh";
				Callback = function()
					ThemeList:SetOptions(ListThemes());
					Library:Notify("Refreshed themes", 2);
				end;
			});

			return self;
		end;

		return TabRef;
	end;
	self.CurrentlyOpen = Window;

	Window.Visible = true;
	Window._FadeToken = 0;
	Window._FadeOriginals = nil;
	local FadeProps = {
		Frame          = { "BackgroundTransparency" };
		TextLabel      = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" };
		TextButton     = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" };
		TextBox        = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" };
		ImageLabel     = { "BackgroundTransparency", "ImageTransparency" };
		ImageButton    = { "BackgroundTransparency", "ImageTransparency" };
		ScrollingFrame = { "BackgroundTransparency", "ScrollBarImageTransparency" };
		CanvasGroup    = { "BackgroundTransparency", "GroupTransparency" };
		UIStroke       = { "Transparency" };
	};
	local function CaptureOriginals()
		local Map = {};
		for _, Inst in Outer:GetDescendants() do
			local Props = FadeProps[Inst.ClassName];
			if Props then
				local PMap = {};
				for _, P in Props do
					local Ok, V = pcall(function() return Inst[P] end);
					if Ok then PMap[P] = V end;
				end;
				Map[Inst] = PMap;
			end;
		end;
		local OuterProps = FadeProps[Outer.ClassName];
		if OuterProps then
			local PMap = {};
			for _, P in OuterProps do
				local Ok, V = pcall(function() return Outer[P] end);
				if Ok then PMap[P] = V end;
			end;
			Map[Outer] = PMap;
		end;
		return Map;
	end;
	function Window:SetVisible(State)
		if self.Visible == State then return end;
		self.Visible = State and true or false;
		self._FadeToken = self._FadeToken + 1;
		local Mine = self._FadeToken;
		if not self._FadeOriginals then
			self._FadeOriginals = CaptureOriginals();
		end;
		local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
		if self.Visible then
			Gui.Enabled = true;
			for Inst, PMap in self._FadeOriginals do
				if Inst.Parent then
					local Goal = {};
					for P, V in PMap do Goal[P] = V end;
					Library:Tween(Inst, Info, Goal):Play();
				end;
			end;
		else
			for Inst, PMap in self._FadeOriginals do
				if Inst.Parent then
					local Goal = {};
					for P in PMap do Goal[P] = 1 end;
					Library:Tween(Inst, Info, Goal):Play();
				end;
			end;
			task.delay(Info.Time, function()
				if self._FadeToken == Mine and not self.Visible then
					Gui.Enabled = false;
				end;
			end);
		end;
	end;
	function Window:Toggle()
		self:SetVisible(not self.Visible);
	end;

	function Window:Destroy()
		Gui:Destroy();
		if Library.CurrentlyOpen == self then Library.CurrentlyOpen = nil end;
	end;

	return Window;
end;

function Library:KeybindList(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Title = tostring(Opts.Title or Opts.Text or "Keybinds");
	local Width = tonumber(Opts.Width) or 170;

	local Gui = self:CreateInstance("ScreenGui", {
		Name           = "KeybindList";
		Parent         = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn   = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});

	local Frame = self:CreateInstance("Frame", {
		Name             = "Keybinds";
		Parent           = Gui;
		AnchorPoint      = Vector2.new(1, 0);
		Position         = UDim2.new(1, -10, 0, 210);
		Size             = UDim2.new(0, Width, 0, 0);
		AutomaticSize    = Enum.AutomaticSize.Y;
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Frame;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
			NewColorSequenceKeypoint(1, Color3.fromHex("141414"));
		});
	});

	local function Edge(Anchor, Pos, Sz, Color)
		self:CreateInstance("Frame", {
			Parent           = Frame;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 5;
		});
	end;
	Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000"); -- top black
	local TopLine = self:CreateInstance("Frame", {
		Name             = "TopLine";
		Parent           = Frame;
		Position         = UDim2.new(0, 0, 0, 1);
		Size             = UDim2.new(1, 0, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ZIndex           = 5;
	});
	local TopGrad = self:CreateInstance("UIGradient", { Parent = TopLine; Rotation = 0 });
	Library:RegisterAccentGradient(TopGrad);
	Edge(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000");
	Edge(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939");
	Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000");
	Edge(Vector2.new(0, 0), UDim2.new(0, 1, 0, 2),  UDim2.new(0, 1, 1, -3), "393939");
	Edge(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000");
	Edge(Vector2.new(1, 0), UDim2.new(1, -1, 0, 2), UDim2.new(0, 1, 1, -3), "393939");

	local Inner = self:CreateInstance("Frame", {
		Name                   = "Inner";
		Parent                 = Frame;
		Position               = UDim2.new(0, 8, 0, 6);
		Size                   = UDim2.new(1, -16, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	self:CreateInstance("UIListLayout", {
		Parent        = Inner;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder     = Enum.SortOrder.LayoutOrder;
		Padding       = UDim.new(0, 2);
	});
	self:CreateInstance("UIPadding", {
		Parent        = Inner;
		PaddingBottom = UDim.new(0, 8);
	});

	local TitleLbl = self:CreateInstance("TextLabel", {
		Name                   = "Title";
		Parent                 = Inner;
		Position               = UDim2.new(0, -1, 0, 0);
		Size                   = UDim2.new(1, 0, 0, 13);
		BackgroundTransparency = 1;
		Text                   = Title;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
		LayoutOrder            = 1;
	});
	if ProggyCleanFont then TitleLbl.FontFace = ProggyCleanFont end;

	local Entries = self:CreateInstance("Frame", {
		Name                   = "Entries";
		Parent                 = Inner;
		Size                   = UDim2.new(1, 0, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		LayoutOrder            = 2;
	});
	self:CreateInstance("UIListLayout", {
		Parent        = Entries;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder     = Enum.SortOrder.LayoutOrder;
		Padding       = UDim.new(0, 2);
	});
	self:CreateInstance("UIPadding", {
		Parent     = Entries;
		PaddingTop = UDim.new(0, 5);
	});

	self:Draggable(Frame);

	local function KeyName(Key)
		if Key == nil then return "None" end;
		if typeof(Key) == "EnumItem" then return Library.KeyNames[Key] or Key.Name end;
		return tostring(Key);
	end;

	local Rows = {};
	local function Rebuild()
		for _, R in Rows do R:Destroy() end;
		table.clear(Rows);
		for I, Entry in Library.Keybinds do
			local Key = Entry.GetKey and Entry.GetKey() or nil;
			if Key ~= nil then
				local Row = Library:CreateInstance("Frame", {
					Name                   = "Entry";
					Parent                 = Entries;
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					Size                   = UDim2.new(1, 0, 0, 13);
					LayoutOrder            = I;
				});
				local DisplayName = tostring(Entry.Name or "?");
				local NameLbl = Library:CreateInstance("TextLabel", {
					Parent                 = Row;
					AnchorPoint            = Vector2.new(0, 0.5);
					Position               = UDim2.new(0, 0, 0.5, 0);
					Size                   = UDim2.new(1, -50, 1, 0);
					BackgroundTransparency = 1;
					Text                   = DisplayName;
					RichText               = true;
					TextColor3             = Color3.fromHex("BFC4CC");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
				});
				local KeyLbl = Library:CreateInstance("TextLabel", {
					Parent                 = Row;
					AnchorPoint            = Vector2.new(1, 0.5);
					Position               = UDim2.new(1, 0, 0.5, 0);
					Size                   = UDim2.new(0, 46, 1, 0);
					BackgroundTransparency = 1;
					Text                   = KeyName(Key);
					TextColor3             = Library.Accent;
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Right;
					TextYAlignment         = Enum.TextYAlignment.Center;
				});
				Library:RegisterAccent(KeyLbl, "TextColor3");
				if ProggyCleanFont then
					NameLbl.FontFace = ProggyCleanFont;
					KeyLbl.FontFace  = ProggyCleanFont;
				end;
				table.insert(Rows, Row);
			end;
		end;
	end;
	Library:OnKeybindChange(Rebuild);

	local Obj = { Gui = Gui, Frame = Frame, TitleLabel = TitleLbl };
	function Obj:Refresh() Rebuild() end;
	function Obj:SetTitle(NewTitle) TitleLbl.Text = string.upper(tostring(NewTitle)) end;
	function Obj:Destroy() Gui:Destroy() end;
	Library._KeybindList = Obj;
	return Obj;
end;

function Library:Watermark(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Text = tostring(Opts.Text or Opts.Title or "Networph");

	local Gui = self:CreateInstance("ScreenGui", {
		Name = "Watermark";
		Parent = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});

	local Frame = self:CreateInstance("Frame", {
		Name             = "Watermark";
		Parent           = Gui;
		AnchorPoint      = Vector2.new(0, 0);
		Position         = UDim2.fromOffset(10, 110);
		Size             = UDim2.new(0, 0, 0, 24);
		AutomaticSize    = Enum.AutomaticSize.X;
		BackgroundColor3 = Color3.fromHex("000000");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIPadding", {
		Parent        = Frame;
		PaddingLeft   = UDim.new(0, 1);
		PaddingRight  = UDim.new(0, 1);
		PaddingTop    = UDim.new(0, 1);
		PaddingBottom = UDim.new(0, 1);
	});

	local Gray = self:CreateInstance("Frame", {
		Name             = "Gray";
		Parent           = Frame;
		Size             = UDim2.new(0, 0, 1, 0);
		AutomaticSize    = Enum.AutomaticSize.X;
		BackgroundColor3 = Color3.fromHex("393939");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIPadding", {
		Parent        = Gray;
		PaddingLeft   = UDim.new(0, 1);
		PaddingRight  = UDim.new(0, 1);
		PaddingTop    = UDim.new(0, 1);
		PaddingBottom = UDim.new(0, 1);
	});

	local GradRing = self:CreateInstance("Frame", {
		Name             = "GradientRing";
		Parent           = Gray;
		Size             = UDim2.new(0, 0, 1, 0);
		AutomaticSize    = Enum.AutomaticSize.X;
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	local RingGradient = self:CreateInstance("UIGradient", {
		Parent   = GradRing;
		Rotation = 0;
	});
	Library:RegisterAccentGradient(RingGradient);
	self:CreateInstance("UIPadding", {
		Parent        = GradRing;
		PaddingLeft   = UDim.new(0, 1);
		PaddingRight  = UDim.new(0, 1);
		PaddingTop    = UDim.new(0, 1);
		PaddingBottom = UDim.new(0, 1);
	});

	local Inside = self:CreateInstance("Frame", {
		Name             = "Inside";
		Parent           = GradRing;
		Size             = UDim2.new(0, 0, 1, 0);
		AutomaticSize    = Enum.AutomaticSize.X;
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Inside;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
			NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
		});
	});
	self:CreateInstance("UIPadding", {
		Parent       = Inside;
		PaddingLeft  = UDim.new(0, 10);
		PaddingRight = UDim.new(0, 10);
	});

	local Lbl = self:CreateInstance("TextLabel", {
		Name                   = "Label";
		Parent                 = Inside;
		AnchorPoint            = Vector2.new(0, 0.5);
		Position               = UDim2.new(0, 0, 0.5, 0);
		Size                   = UDim2.new(0, 0, 1, 0);
		AutomaticSize          = Enum.AutomaticSize.X;
		BackgroundTransparency = 1;
		Text                   = Text;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

	self:Draggable(Frame);

	local Obj = { Gui = Gui, Frame = Frame, Label = Lbl };
	function Obj:SetText(NewText) Lbl.Text = tostring(NewText) end;
	function Obj:Destroy() Gui:Destroy() end;
	Library._Watermark = Obj;
	return Obj;
end;

function Library:Notify(Text, Time)
	Text = tostring(Text or "");
	Time = tonumber(Time) or 3;

	if not self._NotifyStack then
		local Gui = self:CreateInstance("ScreenGui", {
			Name           = "Notifications";
			Parent         = (gethui and gethui()) or CoreGui;
			IgnoreGuiInset = true;
			ResetOnSpawn   = false;
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
		});
		local Stack = self:CreateInstance("Frame", {
			Name                   = "Stack";
			Parent                 = Gui;
			AnchorPoint            = Vector2.new(0, 0);
			Position               = UDim2.new(0, 10, 0, 200);
			Size                   = UDim2.new(0, 200, 1, -210);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		self:CreateInstance("UIListLayout", {
			Parent              = Stack;
			FillDirection       = Enum.FillDirection.Vertical;
			SortOrder           = Enum.SortOrder.LayoutOrder;
			VerticalAlignment   = Enum.VerticalAlignment.Top;
			HorizontalAlignment = Enum.HorizontalAlignment.Left;
			Padding             = UDim.new(0, 6);
		});
		self._NotifyGui   = Gui;
		self._NotifyStack = Stack;
		self._NotifyOrder = 0;
	end;

	self._NotifyOrder = self._NotifyOrder + 1;

	local Wrapper = self:CreateInstance("Frame", {
		Name                   = "NotifWrapper";
		Parent                 = self._NotifyStack;
		Size                   = UDim2.new(0, 0, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.XY;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		LayoutOrder            = self._NotifyOrder;
		ClipsDescendants       = false;
	});

	local Outer = self:CreateInstance("CanvasGroup", {
		Name              = "Notification";
		Parent            = Wrapper;
		AnchorPoint       = Vector2.new(0, 0);
		Position          = UDim2.new(0, -60, 0, 0);
		Size              = UDim2.new(0, 0, 0, 0);
		AutomaticSize     = Enum.AutomaticSize.XY;
		BackgroundColor3  = Color3.fromHex("000000");
		BorderSizePixel   = 0;
		GroupTransparency = 1;
	});
	self:CreateInstance("UIPadding", {
		Parent        = Outer;
		PaddingBottom = UDim.new(0, 2);
	});

	local Inline = self:CreateInstance("Frame", {
		Name             = "Inline";
		Parent           = Outer;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, 0);
		BackgroundColor3 = Color3.fromHex("393939");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIPadding", {
		Parent        = Inline;
		PaddingBottom = UDim.new(0, 2);
	});

	local Background = self:CreateInstance("Frame", {
		Name             = "Background";
		Parent           = Inline;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, 0);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Background;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("262626"));
			NewColorSequenceKeypoint(1, Color3.fromHex("191919"));
		});
	});

	local Title = self:CreateInstance("TextLabel", {
		Name                   = "Title";
		Parent                 = Background;
		Position               = UDim2.new(0, 4, 0, 4);
		Size                   = UDim2.new(0, 0, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.XY;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		Text                   = Text;
		TextColor3             = Color3.fromHex("A0A0A0");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Top;
		RichText               = true;
	});
	if ProggyCleanFont then Title.FontFace = ProggyCleanFont end;
	self:CreateInstance("UIStroke", {
		Parent          = Title;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	self:CreateInstance("UIPadding", {
		Parent        = Title;
		PaddingRight  = UDim.new(0, 7);
		PaddingBottom = UDim.new(0, 3);
	});

	local Accent = self:CreateInstance("Frame", {
		Name             = "Accent";
		Parent           = Outer;
		Position         = UDim2.new(0, 2, 1, -1);
		Size             = UDim2.new(0, 0, 0, 1);
		BackgroundColor3 = Library.Accent;
		BorderSizePixel  = 0;
		ZIndex           = 3;
	});
	Library:RegisterAccent(Accent);

	local InInfo  = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	local OutInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In);

	TweenService:Create(Outer, InInfo, {
		Position          = UDim2.new(0, 0, 0, 0);
		GroupTransparency = 0;
	}):Play();

	task.spawn(function()
		task.wait();
		local Target = math.max(0, Outer.AbsoluteSize.X - 4);
		TweenService:Create(Accent, TweenInfo.new(Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, Target, 0, 1);
		}):Play();
	end);

	task.delay(Time, function()
		if not Wrapper.Parent then return end;
		TweenService:Create(Outer, OutInfo, {
			Position          = UDim2.new(0, -60, 0, 0);
			GroupTransparency = 1;
		}):Play();
		task.delay(OutInfo.Time, function()
			if Wrapper and Wrapper.Parent then Wrapper:Destroy() end;
		end);
	end);

	return Wrapper;
end;

function Library:Unload()
	self:Log("Unload requested");
	for _, Conn in self.Connections do
		if Conn ~= nil then
			Conn:Disconnect();
		end;
	end;
	self.Connections = {};

	local Win = self.CurrentlyOpen;
	if typeof(Win) == "table" and typeof(Win.Gui) == "Instance" and Win.Gui.Parent then
		Win.Gui:Destroy();
	end;
	self.CurrentlyOpen = nil;

	self.Flags = {};
	self.Toggles = {};
	self.Options = {};
	self:Log("Unload complete");
end;

local Watermark = Library:Watermark({ Text = "Coincide | dev" });

local w = Library:Window({ Width = 550, Height = 555, Title = "Coincide" });
local TabLegit    = w:Tab({ Name = "legit" });
local TabRage     = w:Tab({ Name = "rage" });
local TabPlayers  = w:Tab({ Name = "players" });
local TabVisuals  = w:Tab({ Name = "visuals" });
local TabMisc     = w:Tab({ Name = "misc" });
local TabSettings = w:Tab({ Name = "settings" });

local SecA = TabLegit:Section({ Name = "section",   Side = "Left" });
SecA:Toggle({ Name = "Toggle",  Default = false, Tooltip = "A normal toggle" });
SecA:Toggle({ Name = "Toggle2", Default = true  })
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
SecA:Slider({ Name = "Test Slider",  Min = 0, Max = 100, Default = 50, Tooltip = "Drag to adjust" });
SecA:Slider({ Name = "Test Slider 2", Min = 0, Max = 100, Default = 25 });
SecA:Dropdown({ Name = "Dropdown", Options = { "Value 1", "Value 2", "Value 3" }, Default = "Value 1" });
SecA:Dropdown({ Name = "Multi Dropdown", Multi = true, Options = { "ESP", "Tracers", "Boxes", "Names" }, Default = { "ESP", "Boxes" } });
SecA:Textbox({ Name = "Textbox", Placeholder = "type here...", Default = "" });
SecA:Keybind({ Name = "Aim Key",   Default = Enum.KeyCode.LeftShift, Mode = "Hold",   Tooltip = "Click to rebind, right-click to clear" });
SecA:Keybind({ Name = "Menu Key",  Default = Enum.KeyCode.Insert,    Mode = "Toggle" });
SecA:Colorpicker({ Name = "Color", Default = Color3.fromRGB(57, 114, 236), Alpha = 1 });
SecA:Button({ Name = "Button", Callback = function() print("Button clicked") end });
SecA:Button({ Name = "Save",   Callback = function() print("Save") end })
	:Button({ Name = "Load",   Callback = function() print("Load") end });
SecA:Button({ Name = "Delete", Confirm = true, Callback = function() print("DELETED") end });

local SecB = TabLegit:Section({ Name = "section 2", Side = "Left" });

local SecC = TabLegit:Section({ Name = "section 3", Side = "Right" });
local Master = SecC:Toggle({ Name = "Master", Default = true });
SecC:Toggle({ Name = "Child Toggle", Default = false, Dependency = Master });
SecC:Slider({ Name = "Child Slider", Min = 0, Max = 100, Default = 50, Dependency = Master });

TabSettings:ApplySettings();
Library:Notify('Gxentry', 2);
Library:Log("Library ready");
return Library;
