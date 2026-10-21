--[[
    Simple UI Library (UI เปล่า — ไม่มี logic เกม)
    
    วิธีใช้:
        local UI = loadstring(...)()
        local win = UI.new({ Title = "My Hub" })
        local tab = win:AddTab("Main")
        tab:AddToggle("Toggle", false, function(v) print(v) end)
        tab:AddButton("Click", function() print("hi") end)
        tab:AddSlider("Speed", 50, 1, 100, function(v) print(v) end)
        tab:AddSpinner("Delay", 1, 0.5, 0, 10, 1, function(v) print(v) end)
        win:Notify("Title", "Text", 3)
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local UI = {}

-- ============================================================
-- THEME / SIZES / FONTS
-- ============================================================
local Theme = {
    Background  = Color3.fromRGB(28, 28, 32),
    Sidebar     = Color3.fromRGB(20, 20, 24),
    Topbar      = Color3.fromRGB(20, 20, 24),
    Card        = Color3.fromRGB(40, 40, 46),
    Text        = Color3.fromRGB(235, 235, 235),
    SubText     = Color3.fromRGB(160, 160, 170),
    Accent      = Color3.fromRGB(120, 120, 220),
    Off         = Color3.fromRGB(70, 70, 80),
    Stroke      = Color3.fromRGB(60, 60, 70),
    ScrollBar   = Color3.fromRGB(100, 100, 120),
    White       = Color3.fromRGB(255, 255, 255),
}
local Sizes = { WindowW=620, WindowH=400, SidebarW=170, TopbarH=38, StatusH=26 }
local Fonts = { Regular=Enum.Font.Gotham, Bold=Enum.Font.GothamBold }

-- ============================================================
-- HELPERS
-- ============================================================
local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r) return mk("UICorner", { CornerRadius = UDim.new(0, r) }, p) end
local function stroke(p, color, transp)
    return mk("UIStroke", {
        Color = color or Theme.Stroke,
        Transparency = transp or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, p)
end
local function tw(obj, t, props, style, dir)
    local tween = TweenService:Create(obj,
        TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end
local function bind(sig, fn) return sig:Connect(fn) end
local function label(parent, props)
    local p = {
        BackgroundTransparency=1, TextColor3=Theme.Text,
        Font=Fonts.Regular, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left,
    }
    for k, v in pairs(props) do p[k] = v end
    return mk("TextLabel", p, parent)
end
local function button(parent, props)
    local p = {
        BackgroundTransparency=1, BackgroundColor3=Theme.Card,
        BorderSizePixel=0, AutoButtonColor=false, Text="",
    }
    for k, v in pairs(props) do p[k] = v end
    return mk("TextButton", p, parent)
end

-- ============================================================
-- TAB CLASS  (ประกาศก่อน UI.new เพื่อให้ setmetatable ใช้ได้)
-- ============================================================
local Tab = {}
Tab.__index = Tab

function Tab:AddSection(text)
    self._order = self._order + 1
    return label(self.Page, {
        Size=UDim2.new(1,0,0,18), Text=text, Font=Fonts.Bold,
        TextSize=13, TextColor3=Theme.SubText, LayoutOrder=self._order,
    })
end

function Tab:AddLabel(text)
    self._order = self._order + 1
    return label(self.Page, {
        Size=UDim2.new(1,0,0,18), Text=text, TextSize=13, LayoutOrder=self._order,
    })
end

function Tab:AddButton(text, callback)
    self._order = self._order + 1
    local container = mk("Frame", {
        Size=UDim2.new(1,0,0,30), BackgroundColor3=Theme.Card,
        BorderSizePixel=0, LayoutOrder=self._order,
    }, self.Page)
    corner(container, 6); stroke(container, Theme.Stroke, 0.5)

    local btn = button(container, { Size=UDim2.fromScale(1,1), BackgroundTransparency=1 })
    label(btn, {
        Size=UDim2.new(1,-16,1,0), Position=UDim2.fromOffset(10,0),
        Text=text, TextSize=13,
    })
    bind(btn.MouseEnter, function() tw(container, 0.15, { BackgroundTransparency=0.3 }) end)
    bind(btn.MouseLeave, function() tw(container, 0.15, { BackgroundTransparency=0 }) end)
    bind(btn.MouseButton1Click, function()
        if callback then pcall(callback) end
    end)
    return btn
end

function Tab:AddToggle(text, initial, callback)
    self._order = self._order + 1
    local container = mk("Frame", {
        Size=UDim2.new(1,0,0,34), BackgroundColor3=Theme.Card,
        BorderSizePixel=0, LayoutOrder=self._order,
    }, self.Page)
    corner(container, 6)

    label(container, {
        Size=UDim2.new(1,-60,1,0), Position=UDim2.fromOffset(10,0),
        Text=text, TextSize=13,
    })

    local track = button(container, {
        Size=UDim2.fromOffset(38,20), Position=UDim2.new(1,-48,0.5,-10),
        BackgroundColor3=initial and Theme.Accent or Theme.Off, BorderSizePixel=0,
    })
    corner(track, 10)

    local knob = mk("Frame", {
        Size=UDim2.fromOffset(16,16),
        Position=initial and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2),
        BackgroundColor3=Theme.White, BorderSizePixel=0,
    }, track)
    corner(knob, 8)

    local value = initial
    local function set(v, silent)
        value = v
        tw(track, 0.2, { BackgroundColor3 = v and Theme.Accent or Theme.Off })
        tw(knob, 0.2, { Position = v and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2) })
        if not silent and callback then pcall(callback, v) end
    end
    bind(track.MouseButton1Click, function() set(not value) end)
    return { Set=set, Get=function() return value end }
end

function Tab:AddSlider(text, initial, min, max, callback)
    self._order = self._order + 1
    local container = mk("Frame", {
        Size=UDim2.new(1,0,0,54), BackgroundColor3=Theme.Card,
        BorderSizePixel=0, LayoutOrder=self._order,
    }, self.Page)
    corner(container, 6)

    label(container, {
        Size=UDim2.new(1,-80,0,20), Position=UDim2.fromOffset(10,6),
        Text=text, TextSize=13,
    })
    local valueLabel = label(container, {
        Size=UDim2.fromOffset(70,20), Position=UDim2.new(1,-80,0,6),
        Text=tostring(initial), TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Right, TextColor3=Theme.Accent,
    })

    local trackBg = mk("Frame", {
        Size=UDim2.new(1,-20,0,5), Position=UDim2.fromOffset(10,36),
        BackgroundColor3=Theme.Off, BorderSizePixel=0,
    }, container)
    corner(trackBg, 3)

    local fill = mk("Frame", {
        Size=UDim2.fromScale((initial-min)/(max-min),1),
        BackgroundColor3=Theme.Accent, BorderSizePixel=0,
    }, trackBg)
    corner(fill, 3)

    local knob = mk("Frame", {
        Size=UDim2.fromOffset(14,14), AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale((initial-min)/(max-min), 0.5),
        BackgroundColor3=Theme.White, BorderSizePixel=0, ZIndex=2,
    }, trackBg)
    corner(knob, 7)

    local hit = button(container, {
        Size=UDim2.new(1,0,0,30), Position=UDim2.fromOffset(0,24),
        BackgroundTransparency=1,
    })

    local value = initial
    local function set(v, silent)
        v = math.clamp(v, min, max); value = v
        local rel = (v-min)/(max-min)
        fill.Size = UDim2.fromScale(rel, 1)
        knob.Position = UDim2.fromScale(rel, 0.5)
        valueLabel.Text = tostring(math.floor(v+0.5))
        if not silent and callback then pcall(callback, v) end
    end

    local dragging = false
    local function updateFromX(x)
        local width = math.max(trackBg.AbsoluteSize.X, 1)
        local rel = math.clamp((x - trackBg.AbsolutePosition.X)/width, 0, 1)
        set(min + (max-min)*rel)
    end

    bind(hit.InputBegan, function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            dragging = true; updateFromX(input.Position.X)
        end
    end)
    bind(UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch then
            updateFromX(input.Position.X)
        end
    end)
    bind(UserInputService.InputEnded, function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Set=set, Get=function() return value end }
end

function Tab:AddSpinner(text, initial, step, min, max, decimals, callback)
    self._order = self._order + 1
    local container = mk("Frame", {
        Size=UDim2.new(1,0,0,34), BackgroundColor3=Theme.Card,
        BorderSizePixel=0, LayoutOrder=self._order,
    }, self.Page)
    corner(container, 6)

    label(container, {
        Size=UDim2.new(1,-130,1,0), Position=UDim2.fromOffset(10,0),
        Text=text, TextSize=13,
    })

    local function fmt(v) return string.format("%."..decimals.."f", v) end
    local function smallBtn(t, xOff)
        local b = button(container, {
            Size=UDim2.fromOffset(24,24), Position=UDim2.new(1,xOff,0.5,-12),
            BackgroundColor3=Theme.Off,
        })
        corner(b, 5)
        label(b, {
            Size=UDim2.fromScale(1,1), Text=t, TextSize=14,
            TextXAlignment=Enum.TextXAlignment.Center,
        })
        return b
    end
    local minus = smallBtn("−", -112)
    local valueLabel = label(container, {
        Size=UDim2.fromOffset(60,24), Position=UDim2.new(1,-88,0.5,-12),
        Text=fmt(initial), TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Center, TextColor3=Theme.Accent,
    })
    local plus = smallBtn("+", -28)

    local value = initial
    local function set(v, silent)
        v = math.clamp(v, min, max)
        v = math.floor(v/step + 0.5)*step
        v = math.clamp(v, min, max)
        value = v; valueLabel.Text = fmt(v)
        if not silent and callback then pcall(callback, v) end
    end
    bind(minus.MouseButton1Click, function() set(value - step) end)
    bind(plus.MouseButton1Click, function() set(value + step) end)
    return { Set=set, Get=function() return value end }
end

function Tab:AddProgress()
    self._order = self._order + 1
    local container = mk("Frame", {
        Size=UDim2.new(1,0,0,8), BackgroundColor3=Theme.Off,
        BorderSizePixel=0, LayoutOrder=self._order,
    }, self.Page)
    corner(container, 4)
    local fill = mk("Frame", {
        Size=UDim2.fromScale(0,1), BackgroundColor3=Theme.Accent, BorderSizePixel=0,
    }, container)
    corner(fill, 4)
    return function(rel)
        tw(fill, 0.2, { Size=UDim2.fromScale(math.clamp(rel,0,1),1) }, Enum.EasingStyle.Linear)
    end
end

-- ============================================================
-- NOTIFICATION
-- ============================================================
local function makeNotifier(gui)
    local holder = mk("Frame", {
        Name="Notifier", Size=UDim2.new(0,260,1,-60),
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-14,0,40),
        BackgroundTransparency=1, ZIndex=50,
    }, gui)
    mk("UIListLayout", {
        Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
    }, holder)

    local count = 0
    return function(title, text, duration)
        duration = duration or 3
        count = count + 1
        local slot = mk("Frame", {
            Size=UDim2.new(1,0,0,50), BackgroundTransparency=1, LayoutOrder=count,
        }, holder)
        local card = mk("Frame", {
            Size=UDim2.fromScale(1,1), Position=UDim2.new(1,20,0,0),
            BackgroundColor3=Theme.Background, BackgroundTransparency=0.05,
            BorderSizePixel=0,
        }, slot)
        corner(card, 8); stroke(card, Theme.Stroke, 0.4)
        label(card, {
            Size=UDim2.new(1,-20,0,18), Position=UDim2.fromOffset(10,7),
            Text=title, Font=Fonts.Bold, TextSize=14,
        })
        label(card, {
            Size=UDim2.new(1,-20,0,14), Position=UDim2.fromOffset(10,26),
            Text=text, TextSize=12, TextColor3=Theme.SubText,
        })
        tw(card, 0.3, { Position=UDim2.new(0,0,0,0) }, Enum.EasingStyle.Back)
        task.delay(duration, function()
            if not slot.Parent then return end
            tw(card, 0.25, { Position=UDim2.new(1,20,0,0) },
                Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.wait(0.25)
            if slot.Parent then slot:Destroy() end
        end)
    end
end

-- ============================================================
-- WINDOW
-- ============================================================
local Window = {}
Window.__index = Window

function UI.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Window)
    self.Title = opts.Title or "UI"
    self.Theme = Theme

    local old = PG:FindFirstChild("SimpleUI")
    if old then old:Destroy() end

    local gui = mk("ScreenGui", {
        Name="SimpleUI", ResetOnSpawn=false, IgnoreGuiInset=true,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    }, PG)
    self.Gui = gui

    local main = mk("Frame", {
        Name="Main", Size=UDim2.fromOffset(Sizes.WindowW, Sizes.WindowH),
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
        BackgroundColor3=Theme.Background, BorderSizePixel=0,
    }, gui)
    corner(main, 10); stroke(main, Theme.Stroke)
    self.Main = main

    -- Topbar
    local topbar = mk("Frame", {
        Size=UDim2.new(1,0,0,Sizes.TopbarH),
        BackgroundColor3=Theme.Topbar, BorderSizePixel=0,
    }, main)
    corner(topbar, 10)
    mk("Frame", {
        Size=UDim2.new(1,0,0,Sizes.TopbarH/2),
        Position=UDim2.new(0,0,0,Sizes.TopbarH/2),
        BackgroundColor3=Theme.Topbar, BorderSizePixel=0,
    }, topbar)
    self.Topbar = topbar

    label(topbar, {
        Size=UDim2.new(1,-100,1,0), Position=UDim2.fromOffset(14,0),
        Text=self.Title, Font=Fonts.Bold, TextSize=14,
    })

    local closeBtn = button(topbar, {
        Size=UDim2.fromOffset(24,24), Position=UDim2.new(1,-32,0.5,-12),
        BackgroundColor3=Theme.Off,
    })
    corner(closeBtn, 6)
    label(closeBtn, {
        Size=UDim2.fromScale(1,1), Text="×", TextSize=16,
        TextXAlignment=Enum.TextXAlignment.Center, TextColor3=Theme.Text,
    })
    bind(closeBtn.MouseButton1Click, function() self:Destroy() end)

    -- Sidebar
    local sidebar = mk("Frame", {
        Size=UDim2.new(0,Sizes.SidebarW,1,-(Sizes.TopbarH+Sizes.StatusH)),
        Position=UDim2.fromOffset(0,Sizes.TopbarH),
        BackgroundColor3=Theme.Sidebar, BorderSizePixel=0,
    }, main)
    self.Sidebar = sidebar

    local tabList = mk("ScrollingFrame", {
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=2, ScrollBarImageColor3=Theme.ScrollBar,
        CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    }, sidebar)
    mk("UIPadding", {
        PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6),
    }, tabList)
    mk("UIListLayout", { Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder }, tabList)
    self.TabList = tabList

    local content = mk("Frame", {
        Size=UDim2.new(1,-Sizes.SidebarW,1,-(Sizes.TopbarH+Sizes.StatusH)),
        Position=UDim2.fromOffset(Sizes.SidebarW,Sizes.TopbarH),
        BackgroundTransparency=1,
    }, main)
    self.Content = content

    local pageHolder = mk("Frame", {
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ClipsDescendants=true,
    }, content)
    self.PageHolder = pageHolder

    local status = mk("Frame", {
        Size=UDim2.new(1,0,0,Sizes.StatusH),
        Position=UDim2.new(0,0,1,-Sizes.StatusH),
        BackgroundColor3=Theme.Topbar, BorderSizePixel=0,
    }, main)
    self.StatusBar = status
    self.StatusLabel = label(status, {
        Size=UDim2.new(1,-20,1,0), Position=UDim2.fromOffset(12,0),
        Text="", TextSize=12, TextColor3=Theme.SubText,
        TextTruncate=Enum.TextTruncate.AtEnd,
    })

    -- Draggable
    local dragging, dragStart, startPos = false, nil, nil
    bind(topbar.InputBegan, function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    bind(UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end)
    bind(UserInputService.InputEnded, function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    self._notify = makeNotifier(gui)
    self.Tabs = {}
    self._tabCount = 0
    return self
end

function Window:AddTab(name)
    self._tabCount = self._tabCount + 1
    local order = self._tabCount

    local btn = button(self.TabList, {
        Size=UDim2.new(1,0,0,30), BackgroundColor3=Theme.Card,
        BackgroundTransparency=1, LayoutOrder=order,
    })
    corner(btn, 6)
    label(btn, {
        Size=UDim2.new(1,-12,1,0), Position=UDim2.fromOffset(10,0),
        Text=name, TextSize=13,
    })
    local indicator = mk("Frame", {
        Size=UDim2.fromOffset(3,16), Position=UDim2.new(0,0,0.5,-8),
        BackgroundColor3=Theme.Accent, BackgroundTransparency=1, BorderSizePixel=0,
    }, btn)
    corner(indicator, 2)

    local page = mk("ScrollingFrame", {
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=Theme.ScrollBar,
        CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false,
    }, self.PageHolder)
    mk("UIPadding", {
        PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10),
        PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,12),
    }, page)
    mk("UIListLayout", { Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder }, page)

    local tab = setmetatable({
        Name = name, Page = page, Button = btn,
        Indicator = indicator, Window = self, _order = 0,
    }, Tab)

    local win = self
    bind(btn.MouseButton1Click, function() win:SelectTab(tab) end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    if self.CurrentTab == tab then return end
    self.CurrentTab = tab
    for _, t in ipairs(self.Tabs) do
        local on = (t == tab)
        tw(t.Button, 0.15, { BackgroundTransparency = on and 0.85 or 1 })
        tw(t.Indicator, 0.15, { BackgroundTransparency = on and 0 or 1 })
        t.Page.Visible = on
    end
end

function Window:SetStatus(text) self.StatusLabel.Text = text end
function Window:Notify(title, text, duration) self._notify(title, text, duration) end
function Window:Destroy() if self.Gui then self.Gui:Destroy() end end

-- ============================================================
-- RETURN
-- ============================================================
_G.SimpleUI = UI
return UI
