-- ============================================================
-- StarX UI Library (v28 Topographic Theme)
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local SoundService     = game:GetService("SoundService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local ENV = (getgenv and getgenv()) or _G

local Library = {}

-- ============================================================
-- CONFIG & THEME
-- ============================================================
local LOGO_IMAGE_ID = "71462783345465"
local TOPO_IMAGE_ID = "rbxassetid://137559326703430" -- ลาย Topographic

local SOUND_IDS = { click = "6895079853", on = "6895079853", off = "6895079853" }
local NAV_ICONS = { farm = "81535612333178", set = "135444280907249", win = "79730240288406", dash = "" }
local ICON_PLATE = false 

local function fixId(id)
    if id and id ~= "" and tonumber(id) then return "rbxassetid://" .. id end
    return id or ""
end
LOGO_IMAGE_ID = fixId(LOGO_IMAGE_ID)

local C = {
    Window = Color3.fromRGB(24, 18, 21), Sidebar = Color3.fromRGB(14, 10, 12), Bar = Color3.fromRGB(14, 10, 12), Card = Color3.fromRGB(20, 20, 22),
    Text = Color3.fromRGB(244, 238, 240), Dim = Color3.fromRGB(189, 178, 182), Accent = Color3.fromRGB(196, 43, 63), Accent2 = Color3.fromRGB(122, 20, 36),
    AccentText = Color3.fromRGB(226, 149, 159), Off = Color3.fromRGB(60, 50, 54), Plate = Color3.fromRGB(236, 228, 231),
    Red = Color3.fromRGB(229, 72, 77), Yellow = Color3.fromRGB(242, 182, 61), Green = Color3.fromRGB(63, 191, 107), Live = Color3.fromRGB(63, 191, 107),
    White = Color3.fromRGB(255, 255, 255), ScrollBar = Color3.fromRGB(120, 100, 105),
}
local T = { Window = 0.26, Sidebar = 0.04, Bar = 0.28, Card = 0.3, Line = 0.92, Stroke = 0.88 }
local DOT_OFF = Color3.fromRGB(95, 88, 92); local KNOB_OFF = Color3.fromRGB(207, 197, 201)
local FONT, FONT_B = Enum.Font.Gotham, Enum.Font.GothamBold
local Connections = {}

-- ============================================================
-- HELPERS
-- ============================================================
local function bind(sig, fn)
    local c = sig:Connect(fn)
    table.insert(Connections, c)
    return c
end

local function mk(class, props, parent)
    local o = Instance.new(class); for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end; return o
end

local function corner(parent, r) return mk("UICorner", { CornerRadius = UDim.new(0, r) }, parent) end
local function stroke(parent, color, transp, thickness)
    return mk("UIStroke", { Color = color, Transparency = transp or 0, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent)
end

local tweenReg = setmetatable({}, { __mode = "k" })
local function tw(obj, t, props, style, dir)
    local keys = {}; for k in pairs(props) do keys[#keys + 1] = k end; table.sort(keys)
    local key = table.concat(keys, ","); local reg = tweenReg[obj]
    if not reg then reg = {}; tweenReg[obj] = reg end
    local old = reg[key]; if old then old:Cancel() end
    local tween = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    reg[key] = tween; tween:Play(); return tween
end

local function playSound(kind)
    local id = fixId(SOUND_IDS[kind])
    if id == "" then return end
    local s = Instance.new("Sound"); s.SoundId = id; s.Volume = 0.5; s.Parent = SoundService; s:Play()
    task.delay(4, function() if s then s:Destroy() end end)
end

local function label(parent, props)
    local p = { BackgroundTransparency = 1, TextColor3 = C.Text, Font = FONT, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left }
    for k, v in pairs(props) do p[k] = v end; return mk("TextLabel", p, parent)
end

local function redGradient(parent, rotation) return mk("UIGradient", { Rotation = rotation or 0, Color = ColorSequence.new(C.Accent2, C.Accent) }, parent) end

local function press(btn, target, silent)
    target = target or btn; local sc = mk("UIScale", { Scale = 1 }, target)
    bind(btn.MouseButton1Down, function()
        if not silent then playSound("click") end
        tw(sc, 0.1, { Scale = 0.95 }, Enum.EasingStyle.Quad)
    end)
    local function up() tw(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back) end
    bind(btn.MouseButton1Up, up); bind(btn.MouseLeave, up); return sc
end

local function isPointer(input) return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local ToastHolder
local toastCount = 0
local TOAST_COLORS = { info = C.Accent, ok = C.Live, warn = C.Yellow, err = C.Red }

local function notify(title, text, kind, duration)
    if not ToastHolder then return end
    duration = duration or 3.5; toastCount += 1
    local frames = {}
    for _, ch in ipairs(ToastHolder:GetChildren()) do if ch:IsA("Frame") then table.insert(frames, ch) end end
    if #frames >= 4 then frames[1]:Destroy() end
    local color = TOAST_COLORS[kind or "info"] or C.Accent
    local slot = mk("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, LayoutOrder = toastCount }, ToastHolder)
    local card = mk("CanvasGroup", { Size = UDim2.fromScale(1, 1), Position = UDim2.new(1, 40, 0, 0), BackgroundColor3 = C.Window, BackgroundTransparency = 0.08, BorderSizePixel = 0, GroupTransparency = 1 }, slot)
    corner(card, 12); stroke(card, C.White, 0.88, 1)
    local bar = mk("Frame", { Size = UDim2.fromOffset(4, 28), Position = UDim2.fromOffset(12, 16), BackgroundColor3 = color, BorderSizePixel = 0 }, card)
    corner(bar, 2)
    label(card, { Size = UDim2.new(1, -36, 0, 18), Position = UDim2.fromOffset(26, 11), Text = title, Font = FONT_B, TextSize = 15, TextTruncate = Enum.TextTruncate.AtEnd })
    label(card, { Size = UDim2.new(1, -36, 0, 16), Position = UDim2.fromOffset(26, 30), Text = text, TextSize = 13, TextColor3 = C.Dim, TextTruncate = Enum.TextTruncate.AtEnd })
    local timer = mk("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = color, BackgroundTransparency = 0.3, BorderSizePixel = 0 }, card)
    tw(card, 0.5, { Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0 }, Enum.EasingStyle.Back)
    tw(timer, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        if not slot.Parent then return end
        tw(card, 0.3, { Position = UDim2.new(1, 40, 0, 0), GroupTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.3)
        if slot.Parent then tw(slot, 0.2, { Size = UDim2.new(1, 0, 0, 0) }); task.wait(0.2); if slot.Parent then slot:Destroy() end end
    end)
end

-- ============================================================
-- CLASS DEFINITIONS
-- ============================================================
local Window = {}; Window.__index = Window
local Tab = {}; Tab.__index = Tab
local Section = {}; Section.__index = Section

-- ============================================================
-- WINDOW CREATION
-- ============================================================
function Library.CreateLib(title, theme)
    for _, g in ipairs(PG:GetChildren()) do if g.Name == "StarXHub" then g:Destroy() end end

    local self = setmetatable({}, Window)
    self.Title = title or "StarX Hub"
    self.Tabs = {}
    self.Minimized = false

    local GUI = mk("ScreenGui", { Name = "StarXHub", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, PG)
    self.GUI = GUI
    
    local WIN_W, WIN_H, SIDE_W, TOP_H, BOT_H = 700, 440, 190, 44, 32
    local function fitScale() local vp = GUI.AbsoluteSize; if vp.X < 100 or vp.Y < 100 then return 1 end; return math.clamp(math.min(vp.X / (WIN_W + 40), vp.Y / (WIN_H + 80)), 0.5, 1) end

    -- Glow
    local GLOW_PAD = 70
    local Glow = mk("CanvasGroup", { Name = "Glow", BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 1 }, GUI)
    for i = 1, 9 do
        local e = i * 5
        local layer = mk("Frame", { BackgroundColor3 = C.Accent, BackgroundTransparency = 0.955, BorderSizePixel = 0, Position = UDim2.new(0, GLOW_PAD - e, 0.42, -e * 0.2), Size = UDim2.new(1, -2 * (GLOW_PAD - e), 0.58, e * 1.2 - GLOW_PAD + 10) }, Glow)
        corner(layer, 16 + e)
    end

    -- Main Window
    local Main = mk("CanvasGroup", { Name = "Main", Size = UDim2.fromOffset(WIN_W, WIN_H), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = C.Window, BackgroundTransparency = T.Window, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 2, ClipsDescendants = true }, GUI)
    corner(Main, 16); stroke(Main, C.White, T.Stroke - 0.01, 1)
    local MainScale = mk("UIScale", { Scale = 0.85 }, Main)

    bind(RunService.RenderStepped, function()
        Glow.Visible = Main.Visible; Glow.GroupTransparency = Main.GroupTransparency
        local ap, as = Main.AbsolutePosition, Main.AbsoluteSize
        Glow.Position = UDim2.fromOffset(ap.X - GLOW_PAD, ap.Y - GLOW_PAD); Glow.Size = UDim2.fromOffset(as.X + GLOW_PAD * 2, as.Y + GLOW_PAD * 2)
    end)
    tw(Main, 0.45, { GroupTransparency = 0 }); tw(MainScale, 0.55, { Scale = fitScale() }, Enum.EasingStyle.Back)

    -- Top Line
    local TopLine = mk("Frame", { Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 10 }, Main)
    mk("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 50, 54)), ColorSequenceKeypoint.new(0.5, C.Accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(59, 50, 54)) }) }, TopLine)

    -- Sidebar (Topographic)
    local Sidebar = mk("Frame", { Size = UDim2.new(0, SIDE_W, 1, 0), BackgroundColor3 = C.Sidebar, BackgroundTransparency = T.Sidebar, BorderSizePixel = 0, ZIndex = 2, ClipsDescendants = true }, Main)
    corner(Sidebar, 16)
    mk("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = C.White, BackgroundTransparency = T.Line, BorderSizePixel = 0 }, Sidebar)
    
    mk("ImageLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = TOPO_IMAGE_ID,
        ImageColor3 = Color3.fromRGB(100, 90, 95), ImageTransparency = 0.6, ScaleType = Enum.ScaleType.Crop, ZIndex = 0
    }, Sidebar)

    -- Brand / Logo
    local Brand = mk("Frame", { Size = UDim2.new(1, 0, 0, 72), BackgroundTransparency = 1, ZIndex = 2 }, Sidebar)
    local logo = mk("Frame", { Size = UDim2.fromOffset(48, 48), Position = UDim2.fromOffset(12, 12), BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 2 }, Brand)
    corner(logo, math.floor(48 * 0.3))
    mk("UIGradient", { Rotation = 45, Color = ColorSequence.new(C.Accent, C.Accent2) }, logo)
    
    if LOGO_IMAGE_ID ~= "" then
        local g = logo:FindFirstChildOfClass("UIGradient"); if g then g:Destroy() end
        logo.BackgroundColor3 = C.Plate; logo.BackgroundTransparency = 1
        mk("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = LOGO_IMAGE_ID, ScaleType = Enum.ScaleType.Fit }, logo)
    end

    label(Brand, { Size = UDim2.new(1, -76, 0, 20), Position = UDim2.fromOffset(70, 16), Text = "StarX Hub★", Font = FONT_B, TextSize = 18, ZIndex = 2 })
    label(Brand, { Size = UDim2.new(1, -76, 0, 14), Position = UDim2.fromOffset(70, 38), Text = "Build a Boat", TextSize = 13, TextColor3 = C.Dim, ZIndex = 2 })

    -- Tab List
    local NavList = mk("ScrollingFrame", { Size = UDim2.new(1, -12, 1, -72 - 52), Position = UDim2.fromOffset(6, 72), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = C.ScrollBar, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 2 }, Sidebar)
    mk("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 4) }, NavList)
    mk("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, NavList)
    self.NavList = NavList

    -- Profile
    local Profile = mk("Frame", { Size = UDim2.new(1, 0, 0, 52), Position = UDim2.new(0, 0, 1, -52), BackgroundTransparency = 1, ZIndex = 2 }, Sidebar)
    mk("Frame", { Size = UDim2.new(1, -24, 0, 1), Position = UDim2.fromOffset(12, 0), BackgroundColor3 = C.White, BackgroundTransparency = T.Line, BorderSizePixel = 0 }, Profile)
    local avatar = mk("ImageLabel", { Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(14, 11), BackgroundColor3 = Color3.fromRGB(58, 50, 54), BorderSizePixel = 0, Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=60&h=60" }, Profile)
    corner(avatar, 15); stroke(avatar, C.White, 0.82, 1)
    label(Profile, { Size = UDim2.new(1, -60, 0, 30), Position = UDim2.fromOffset(52, 11), Text = LP.DisplayName, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = C.Text })

    -- Content Area
    local Content = mk("Frame", { Size = UDim2.new(1, -SIDE_W, 1, 0), Position = UDim2.fromOffset(SIDE_W, 0), BackgroundTransparency = 1 }, Main)
    
    -- TopBar (Topographic)
    local TopBar = mk("Frame", { Size = UDim2.new(1, 0, 0, TOP_H), BackgroundColor3 = C.Bar, BackgroundTransparency = T.Bar, BorderSizePixel = 0, ZIndex = 2, ClipsDescendants = true }, Content)
    mk("ImageLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = TOPO_IMAGE_ID,
        ImageColor3 = Color3.fromRGB(100, 90, 95), ImageTransparency = 0.6, ScaleType = Enum.ScaleType.Crop, ZIndex = 0
    }, TopBar)
    
    mk("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = C.White, BackgroundTransparency = T.Line, BorderSizePixel = 0, ZIndex = 2 }, TopBar)
    local Crumb = label(TopBar, { Size = UDim2.new(1, -120, 1, 0), Position = UDim2.fromOffset(18, 0), RichText = true, Text = "", TextSize = 14, TextColor3 = C.Dim, ZIndex = 2 })
    self.Crumb = Crumb

    -- Window Controls (Traffic Lights)
    local function trafficLight(xFromRight, color)
        local b = mk("TextButton", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(1, xFromRight, 0.5, -6), BackgroundColor3 = color, BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 2 }, TopBar)
        corner(b, 7); press(b)
        bind(b.MouseEnter, function() tw(b, 0.15, { Size = UDim2.fromOffset(15, 15), Position = UDim2.new(1, xFromRight - 1, 0.5, -7) }) end)
        bind(b.MouseLeave, function() tw(b, 0.15, { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(1, xFromRight, 0.5, -6) }) end)
        return b
    end
    self.CloseBtn = trafficLight(-62, C.Red)
    local MinBtn = trafficLight(-42, C.Yellow)
    local MaxBtn = trafficLight(-22, C.Green)
    stroke(self.CloseBtn, C.Red, 0.6, 2)

    -- Page Holder
    local PageHolder = mk("Frame", { Size = UDim2.new(1, 0, 1, -(TOP_H + BOT_H)), Position = UDim2.fromOffset(0, TOP_H), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2 }, Content)
    self.PageHolder = PageHolder

    -- Status Bar
    local StatusBar = mk("Frame", { Size = UDim2.new(1, 0, 0, BOT_H), Position = UDim2.new(0, 0, 1, -BOT_H), BackgroundColor3 = C.Bar, BackgroundTransparency = T.Bar, BorderSizePixel = 0 }, Content)
    mk("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.White, BackgroundTransparency = T.Line, BorderSizePixel = 0 }, StatusBar)
    local StatusDot = mk("Frame", { Size = UDim2.fromOffset(7, 7), Position = UDim2.new(0, 18, 0.5, -3), BackgroundColor3 = C.AccentText, BorderSizePixel = 0 }, StatusBar)
    corner(StatusDot, 4); stroke(StatusDot, C.Accent, 0.5, 2)
    
    self.StatusLabel = label(StatusBar, { Size = UDim2.new(1, -182, 1, 0), Position = UDim2.fromOffset(32, 0), Text = "พร้อมใช้งาน", TextSize = 13, TextColor3 = C.Dim, TextTruncate = Enum.TextTruncate.AtEnd })
    label(StatusBar, { Size = UDim2.fromOffset(60, BOT_H), Position = UDim2.new(1, -132, 0, 0), Text = "รอบ: 0", TextSize = 13, TextColor3 = C.Dim, TextXAlignment = Enum.TextXAlignment.Right })
    label(StatusBar, { Size = UDim2.fromOffset(50, BOT_H), Position = UDim2.new(1, -66, 0, 0), Text = "00:00", TextSize = 13, TextColor3 = C.Dim, TextXAlignment = Enum.TextXAlignment.Right })

    -- Toasts
    ToastHolder = mk("Frame", { Name = "Toasts", Size = UDim2.new(0, 280, 1, -80), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 64), BackgroundTransparency = 1, ZIndex = 30 }, GUI)
    mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Right }, ToastHolder)

    -- Draggable
    local dragging, dragStart, startPos = false, nil, nil
    local function makeDraggable(handle)
        bind(handle.InputBegan, function(input)
            if isPointer(input) then dragging = true; dragStart = input.Position; startPos = Main.Position end
        end)
    end
    makeDraggable(TopBar); makeDraggable(Brand)
    
    bind(UserInputService.InputChanged, function(input)
        local moving = input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
        if not moving or not dragging then return end
        local d = input.Position - dragStart; local vp = GUI.AbsoluteSize
        local limX, limY = vp.X / 2 - 80, vp.Y / 2 - 40
        local nx = math.clamp(startPos.X.Offset + d.X, -limX, limX); local ny = math.clamp(startPos.Y.Offset + d.Y, -limY, limY)
        Main.Position = UDim2.new(startPos.X.Scale, nx, startPos.Y.Scale, ny)
    end)
    bind(UserInputService.InputEnded, function(input)
        if isPointer(input) then dragging = false end
    end)

    bind(self.CloseBtn.Activated, function() self:Destroy() end)
    bind(MinBtn.Activated, function() self:Minimize() end)
    bind(MaxBtn.Activated, function() 
        if self.Minimized then return end
        local isMax = (Main.Size.Y.Offset > WIN_H)
        tw(Main, 0.55, { Size = isMax and UDim2.fromOffset(WIN_W, WIN_H) or UDim2.fromOffset(880, 540) }, Enum.EasingStyle.Back)
    end)

    -- Dynamic Island
    local Island = mk("TextButton", {
        Name = "DynamicIsland", Size = UDim2.fromOffset(148, 37), AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 11), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0,
        AutoButtonColor = false, Text = "", ClipsDescendants = true, Visible = false, ZIndex = 20,
    }, GUI)
    corner(Island, 18); stroke(Island, C.Accent, 0.65, 1)
    
    label(Island, { Size = UDim2.fromOffset(100, 37), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Text = "STARX HUB", Font = FONT_B, TextSize = 12, TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5 })
    local islLogo = mk("Frame", { Size = UDim2.fromOffset(22, 22), Position = UDim2.fromOffset(13, 7), BackgroundTransparency = 1, ZIndex = 6 }, Island)
    mk("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = LOGO_IMAGE_ID, ScaleType = Enum.ScaleType.Fit, ZIndex = 6 }, islLogo)
    bind(Island.MouseButton1Click, function() self:Restore() end)

    return self
end

-- ============================================================
-- WINDOW METHODS
-- ============================================================
function Window:NewTab(name)
    local btn = mk("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Text = "" }, self.NavList)
    corner(btn, 10)
    local bst = stroke(btn, C.AccentText, 1, 1)
    local bar = mk("Frame", { Size = UDim2.fromOffset(3, 18), Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = C.AccentText, BackgroundTransparency = 1, BorderSizePixel = 0 }, btn)
    corner(bar, 2)
    label(btn, { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(12, 0), Text = name, TextSize = 15 })

    local group = mk("CanvasGroup", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, Visible = false }, self.PageHolder)
    local sf = mk("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = C.ScrollBar, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, group)
    mk("UIPadding", { PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, sf)
    mk("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, sf)

    local tab = { Name = name, Page = group, Scroll = sf, Button = btn, Stroke = bst, Bar = bar, Window = self, _secCount = 0 }
    setmetatable(tab, Tab)
    table.insert(self.Tabs, tab)

    local win = self
    bind(btn.MouseButton1Click, function() win:SelectTab(tab) end)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    self.CurrentTab = tab
    for _, t in ipairs(self.Tabs) do
        local on = (t == tab)
        tw(t.Button, 0.2, { BackgroundTransparency = on and 0.8 or 1 })
        tw(t.Stroke, 0.2, { Transparency = on and 0.5 or 1 })
        tw(t.Bar, 0.2, { BackgroundTransparency = on and 0 or 1 })
        if on then t.Page.Visible = true; tw(t.Page, 0.3, { GroupTransparency = 0 })
        else tw(t.Page, 0.2, { GroupTransparency = 1 }); task.delay(0.2, function() if self.CurrentTab ~= t then t.Page.Visible = false end end) end
    end
    self.Crumb.Text = self.Title .. '  ›  <font color="#FFFFFF">' .. tab.Name .. "</font>"
end

function Window:SetStatus(text) self.StatusLabel.Text = text end
function Window:Notify(title, text, kind, dur) notify(title, text, kind, dur) end

function Window:Minimize()
    if self.Minimized then return end
    self.Minimized = true
    local Main, MainScale = self.GUI:FindFirstChild("Main"), self.GUI:FindFirstChild("Main"):FindFirstChildOfClass("UIScale")
    tw(MainScale, 0.45, { Scale = 0.05 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tw(Main, 0.45, { GroupTransparency = 1 })
    task.delay(0.45, function() if self.Minimized then Main.Visible = false end end)
    
    local Island = self.GUI:FindFirstChild("DynamicIsland")
    Island.Visible = true; Island.Size = UDim2.fromOffset(0, 37)
    tw(Island, 0.5, { Size = UDim2.fromOffset(148, 37) }, Enum.EasingStyle.Back)
end

function Window:Restore()
    if not self.Minimized then return end
    self.Minimized = false
    local Island = self.GUI:FindFirstChild("DynamicIsland")
    tw(Island, 0.3, { Size = UDim2.fromOffset(0, 37) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.3, function() if not self.Minimized then Island.Visible = false end end)

    local Main, MainScale = self.GUI:FindFirstChild("Main"), self.GUI:FindFirstChild("Main"):FindFirstChildOfClass("UIScale")
    Main.Visible = true; tw(Main, 0.4, { GroupTransparency = 0 }); tw(MainScale, 0.55, { Scale = 1 }, Enum.EasingStyle.Back)
end

function Window:Destroy()
    if self.GUI then self.GUI:Destroy() end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Connections)
end

-- ============================================================
-- TAB METHODS
-- ============================================================
function Tab:NewSection(name)
    self._secCount = self._secCount + 1
    local sec = mk("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.Card, BackgroundTransparency = T.Card, BorderSizePixel = 0, LayoutOrder = self._secCount, ClipsDescendants = true }, self.Scroll)
    corner(sec, 12); stroke(sec, C.White, T.Stroke - 0.02, 1)
    mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, sec)
    
    local title = label(sec, { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.fromOffset(14, 0), Text = name, Font = FONT_B, TextSize = 15, LayoutOrder = 0 })
    mk("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.White, BackgroundTransparency = T.Line, BorderSizePixel = 0 }, sec)
    
    local section = { Name = name, Frame = sec, Title = title, Tab = self, _rowCount = 0 }
    setmetatable(section, Section)
    return section
end

-- ============================================================
-- SECTION COMPONENTS
-- ============================================================
function Section:_row(h)
    self._rowCount = self._rowCount + 1
    local r = mk("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, LayoutOrder = self._rowCount }, self.Frame)
    if self._rowCount > 1 then mk("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.White, BackgroundTransparency = T.Line, BorderSizePixel = 0 }, r) end
    return r
end

function Section:NewButton(text, info, callback)
    local r = self:_row(54)
    label(r, { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.fromOffset(14, 7), Text = text, Font = FONT_B, TextSize = 15 })
    if info and info ~= "" then label(r, { Size = UDim2.new(1, -80, 0, 16), Position = UDim2.fromOffset(14, 27), Text = info, TextSize = 13, TextColor3 = C.Dim, TextTruncate = Enum.TextTruncate.AtEnd }) end
    
    local btn = mk("TextButton", { Size = UDim2.fromOffset(80, 26), Position = UDim2.new(1, -94, 0.5, -13), BackgroundColor3 = C.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Text = "Execute", TextColor3 = C.AccentText, Font = FONT_B, TextSize = 13 }, r)
    corner(btn, 6); stroke(btn, C.AccentText, 0.5, 1)
    
    local sc = mk("UIScale", { Scale = 1 }, btn)
    bind(btn.MouseButton1Down, function() tw(sc, 0.1, { Scale = 0.95 }) end)
    bind(btn.MouseButton1Up, function() tw(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back) end)
    bind(btn.MouseLeave, function() tw(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back) end)
    
    local buttonObj = {}
    function buttonObj:UpdateButton(newText) btn.Text = newText end
    bind(btn.MouseButton1Click, function()
        playSound("click")
        if callback then pcall(callback) end
    end)
    return buttonObj
end

function Section:NewToggle(text, info, initial, callback)
    if type(initial) == "function" then callback = initial; initial = false end
    local r = self:_row(52)
    label(r, { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.fromOffset(14, 7), Text = text, Font = FONT_B, TextSize = 15 })
    if info and info ~= "" then label(r, { Size = UDim2.new(1, -80, 0, 16), Position = UDim2.fromOffset(14, 27), Text = info, TextSize = 13, TextColor3 = C.Dim, TextTruncate = Enum.TextTruncate.AtEnd }) end

    local track = mk("TextButton", { Size = UDim2.fromOffset(42, 24), Position = UDim2.new(1, -56, 0.5, -12), BackgroundColor3 = C.Off, BackgroundTransparency = initial and 1 or 0.88, BorderSizePixel = 0, AutoButtonColor = false, Text = "" }, r)
    corner(track, 12)
    local tstroke = stroke(track, initial and C.AccentText or C.White, initial and 0.55 or 0.85, 1)
    local fill = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.White, BackgroundTransparency = initial and 0 or 1, BorderSizePixel = 0 }, track)
    corner(fill, 12); redGradient(fill, 20)
    local knob = mk("Frame", { Size = UDim2.fromOffset(20, 20), Position = initial and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = initial and C.White or KNOB_OFF, BorderSizePixel = 0, ZIndex = 2 }, track)
    corner(knob, 10); press(track, nil, true)

    local value = initial
    local toggleObj = {}
    function toggleObj:Set(v, silent)
        value = v
        tw(fill, 0.25, { BackgroundTransparency = v and 0 or 1 })
        tw(track, 0.25, { BackgroundTransparency = v and 1 or 0.88 })
        tw(tstroke, 0.25, { Color = v and C.AccentText or C.White, Transparency = v and 0.55 or 0.85 })
        tw(knob, 0.35, { Position = v and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2) }, Enum.EasingStyle.Back)
        tw(knob, 0.25, { BackgroundColor3 = v and C.White or KNOB_OFF })
        if not silent then
            playSound(v and "on" or "off")
            if callback then pcall(callback, v) end
        end
    end
    bind(track.Activated, function() toggleObj:Set(not value) end)
    return toggleObj
end

function Section:NewSlider(text, info, maxV, minV, callback)
    local r = self:_row(54)
    label(r, { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.fromOffset(14, 7), Text = text, Font = FONT_B, TextSize = 15 })
    if info and info ~= "" then label(r, { Size = UDim2.new(1, -80, 0, 16), Position = UDim2.fromOffset(14, 27), Text = info, TextSize = 13, TextColor3 = C.Dim, TextTruncate = Enum.TextTruncate.AtEnd }) end
    local valLabel = label(r, { Size = UDim2.fromOffset(60, 20), Position = UDim2.new(1, -74, 0, 7), Text = tostring(minV), TextSize = 14, TextColor3 = C.AccentText, Font = FONT_B, TextXAlignment = Enum.TextXAlignment.Right })

    local trackBg = mk("Frame", { Size = UDim2.new(1, -88, 0, 6), Position = UDim2.fromOffset(14, 36), BackgroundColor3 = Color3.fromRGB(50, 44, 46), BackgroundTransparency = 0.5, BorderSizePixel = 0 }, r)
    corner(trackBg, 3)
    local fill = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.White, BorderSizePixel = 0 }, trackBg)
    corner(fill, 3); redGradient(fill, 0)
    local knob = mk("Frame", { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 3 }, trackBg)
    corner(knob, 7); stroke(knob, C.Accent, 0.35, 2)
    local hitbox = mk("TextButton", { Size = UDim2.new(1, 20, 0, 30), Position = UDim2.new(0, -10, 0.5, -15), BackgroundTransparency = 1, Text = "", ZIndex = 4 }, trackBg)

    local sliderObj = {}
    function sliderObj:Set(v, silent)
        v = math.clamp(v, minV, maxV)
        local rel = (v - minV) / (maxV - minV)
        fill.Size = UDim2.fromScale(rel, 1); knob.Position = UDim2.fromScale(rel, 0.5); valLabel.Text = string.format("%.0f", v)
        if not silent and callback then pcall(callback, v) end
    end

    local dragging = false
    local function update(x)
        local width = math.max(trackBg.AbsoluteSize.X, 1)
        local rel = math.clamp((x - trackBg.AbsolutePosition.X) / width, 0, 1)
        sliderObj:Set(minV + (maxV - minV) * rel)
    end
    bind(hitbox.InputBegan, function(input)
        if isPointer(input) then dragging = true; update(input.Position.X) end
    end)
    bind(UserInputService.InputChanged, function(input)
        local moving = input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
        if dragging and moving then update(input.Position.X) end
    end)
    bind(UserInputService.InputEnded, function(input)
        if isPointer(input) then dragging = false end
    end)
    return sliderObj
end

return Library
