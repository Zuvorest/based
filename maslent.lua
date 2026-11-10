-- ============================================================
-- N4 SIMPLE UI — single-file build
-- Load: loadstring(game:HttpGet("URL_RAW"))()
-- Test: Delta Executor (mobile)
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TS         = game:GetService("TweenService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ============================================================
-- PALETTE
-- ============================================================
local C = {
    BG        = Color3.fromRGB(10, 10, 14),
    BG2       = Color3.fromRGB(16, 16, 22),
    BG3       = Color3.fromRGB(22, 22, 30),
    BORDER    = Color3.fromRGB(40, 40, 55),
    TEXT      = Color3.fromRGB(230, 230, 240),
    TEXT_DIM  = Color3.fromRGB(150, 150, 165),
    NEON_A    = Color3.fromRGB(0, 245, 255),
    NEON_B    = Color3.fromRGB(180, 60, 255),
    NEON_C    = Color3.fromRGB(255, 60, 200),
    GREEN     = Color3.fromRGB(0, 230, 130),
    RED       = Color3.fromRGB(255, 70, 90),
    FONT      = Enum.Font.Code,
    FONT_BOLD = Enum.Font.Code,
}

local NEON_SEQ = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, C.NEON_A),
    ColorSequenceKeypoint.new(0.33, C.NEON_B),
    ColorSequenceKeypoint.new(0.66, C.NEON_C),
    ColorSequenceKeypoint.new(1.00, C.NEON_A),
})

-- ============================================================
-- HELPERS
-- ============================================================
local function getGUIParent()
    local sg = Instance.new("ScreenGui")
    sg.Name = "N4Simple"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 9999
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, sg)
        sg.Parent = game:GetService("CoreGui")
        return sg
    end
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then sg.Parent = hui else sg.Parent = PG end
    return sg
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function stroke(p, color, thickness, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or C.BORDER
    s.Thickness = thickness or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function new(class, props, parent)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

-- ============================================================
-- N4 CORE
-- ============================================================
local N4 = {}
N4._neon = {}

local function registerNeon(gradient, speed)
    gradient.Color    = NEON_SEQ
    gradient.Rotation = 0
    table.insert(N4._neon, { g = gradient, s = speed or 0.5, off = 0 })
end

task.spawn(function()
    RunService.RenderStepped:Connect(function(dt)
        for _, t in ipairs(N4._neon) do
            if t.g and t.g.Parent then
                t.off = (t.off + dt * t.s) % 1
                t.g.Offset = Vector2.new(t.off, 0)
            end
        end
    end)
end)

-- ============================================================
-- WINDOW
-- ============================================================
function N4.new(opts)
    opts = opts or {}
    local self = {}
    self.Tabs      = {}
    self.ActiveTab = nil
    self.Size      = opts.Size or UDim2.fromOffset(660, 440)

    local sg = getGUIParent()
    self.Gui = sg

    local root = new("Frame", {
        Name = "Root",
        Size = self.Size,
        Position = UDim2.new(0.5, -self.Size.X.Offset / 2, 0.5, -self.Size.Y.Offset / 2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, sg)
    corner(root, 9)
    local rootGrad = new("UIGradient", { Parent = root })
    registerNeon(rootGrad, 0.35)

    local inner = new("Frame", {
        Name = "Inner",
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.fromOffset(1, 1),
        BackgroundColor3 = C.BG,
        BorderSizePixel = 0,
    }, root)
    corner(inner, 8)

    local titleBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = C.BG2,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, inner)
    corner(titleBar, 8)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = C.BG2,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, titleBar)

    local dot = new("Frame", {
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(0, 12, 0.5, -4),
        BackgroundColor3 = C.NEON_A,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, titleBar)
    corner(dot, 999)
    stroke(dot, C.NEON_A, 1, 0.3)

    new("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.fromOffset(26, 0),
        BackgroundTransparency = 1,
        Font = C.FONT_BOLD,
        Text = opts.Title or "N4",
        TextSize = 15,
        TextColor3 = C.TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, titleBar)

    new("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.fromOffset(90, 0),
        BackgroundTransparency = 1,
        Font = C.FONT,
        Text = "// " .. (opts.Subtitle or "v1.0"),
        TextSize = 12,
        TextColor3 = C.TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, titleBar)

    local function makeWinBtn(ch, xOffset, color, onClick)
        local b = new("TextButton", {
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.new(1, xOffset, 0.5, -11),
            BackgroundColor3 = C.BG3,
            BorderSizePixel = 0,
            Font = C.FONT_BOLD,
            Text = ch,
            TextSize = 13,
            TextColor3 = color or C.TEXT_DIM,
            AutoButtonColor = false,
            ZIndex = 3,
        }, titleBar)
        corner(b, 4)
        stroke(b, C.BORDER, 1, 0.5)
        b.MouseEnter:Connect(function()
            TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.BG2, TextColor3 = C.TEXT }):Play()
        end)
        b.MouseLeave:Connect(function()
            TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.BG3, TextColor3 = color or C.TEXT_DIM }):Play()
        end)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    makeWinBtn("–", -56, C.NEON_A, function() end)
    makeWinBtn("×", -30, C.RED,    function() root.Visible = false end)

    local topLine = new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 4,
    }, titleBar)
    local tlGrad = new("UIGradient", { Parent = topLine })
    registerNeon(tlGrad, 0.6)

    local sidebar = new("Frame", {
        Size = UDim2.new(0, 150, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = C.BG2,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, inner)

    new("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundColor3 = C.BORDER,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, sidebar)

    local tabList = new("Frame", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, sidebar)
    new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList,
    })

    local content = new("Frame", {
        Size = UDim2.new(1, -151, 1, -36 - 22),
        Position = UDim2.new(0, 151, 0, 36),
        BackgroundColor3 = C.BG,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, inner)

    local statusBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = C.BG2,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, inner)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = C.BORDER,
        BorderSizePixel = 0,
    }, statusBar)

    self.StatusLbl = new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Font = C.FONT,
        Text = "◆ ready",
        TextSize = 11,
        TextColor3 = C.TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, statusBar)

    -- drag
    do
        local dragging, dragStart, startPos = false, nil, nil
        titleBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, i.Position, root.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dragStart
                root.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    self.Root    = root
    self.Inner   = inner
    self.Content = content

    function self:Tab(name)
        local tab = {}
        tab.Name = name
        tab._order = 0
        tab._nextOrder = function() tab._order = tab._order + 1; return tab._order end

        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = C.BG3,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "   " .. name,
            Font = C.FONT,
            TextSize = 13,
            TextColor3 = C.TEXT_DIM,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = 3,
        }, tabList)
        corner(btn, 4)

        local indicator = new("Frame", {
            Size = UDim2.new(0, 2, 1, -8),
            Position = UDim2.fromOffset(0, 4),
            BackgroundColor3 = C.NEON_A,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 4,
        }, btn)
        corner(indicator, 2)
        registerNeon(new("UIGradient", { Parent = indicator }), 0.8)

        local pane = new("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.fromOffset(10, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = C.BORDER,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 3,
        }, content)
        new("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = pane,
        })

        btn.MouseEnter:Connect(function()
            if self.ActiveTab ~= tab then
                TS:Create(btn, TweenInfo.new(0.15), { TextColor3 = C.TEXT, BackgroundTransparency = 0.5 }):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if self.ActiveTab ~= tab then
                TS:Create(btn, TweenInfo.new(0.15), { TextColor3 = C.TEXT_DIM, BackgroundTransparency = 1 }):Play()
            end
        end)
        btn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

        tab.Button    = btn
        tab.Indicator = indicator
        tab.Pane      = pane

        N4.AttachWidgets(tab)

        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then self:SelectTab(tab) end
        return tab
    end

    function self:SelectTab(tab)
        if self.ActiveTab == tab then return end
        for _, t in ipairs(self.Tabs) do
            t.Pane.Visible = false
            TS:Create(t.Button, TweenInfo.new(0.15), { TextColor3 = C.TEXT_DIM, BackgroundTransparency = 1 }):Play()
            TS:Create(t.Indicator, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
        end
        self.ActiveTab = tab
        tab.Pane.Visible = true
        TS:Create(tab.Button, TweenInfo.new(0.15), { TextColor3 = C.NEON_A, BackgroundTransparency = 0.7 }):Play()
        TS:Create(tab.Indicator, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
    end

    function self:SetStatus(text)
        if self.StatusLbl then
            self.StatusLbl.Text = "◆ " .. tostring(text)
        end
    end

    return self
end

-- ============================================================
-- WIDGETS
-- ============================================================
function N4.AttachWidgets(tab)
    local pane = tab.Pane
    local nextOrder = tab._nextOrder
        or (function() tab._order = (tab._order or 0) + 1; return tab._order end)

    function tab:Section(title)
        local holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
        }, pane)
        holder.AutomaticSize = Enum.AutomaticSize.Y
        local hl = new("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = holder,
        })
        hl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            holder.Size = UDim2.new(1, 0, 0, hl.AbsoluteContentSize.Y)
        end)

        local hdr = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = C.BG3,
            BorderSizePixel = 0,
            Text = "  ▾  " .. title,
            Font = C.FONT_BOLD,
            TextSize = 12,
            TextColor3 = C.NEON_A,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            LayoutOrder = 0,
        }, holder)
        corner(hdr, 3)
        stroke(hdr, C.BORDER, 1, 0.4)

        local body = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
        }, holder)
        body.AutomaticSize = Enum.AutomaticSize.Y
        local bl = new("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = body,
        })
        bl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            body.Size = UDim2.new(1, 0, 0, bl.AbsoluteContentSize.Y)
        end)

        local expanded = true
        hdr.MouseButton1Click:Connect(function()
            expanded = not expanded
            body.Visible = expanded
            hdr.Text = "  " .. (expanded and "▾" or "▸") .. "  " .. title
        end)
        hdr.MouseEnter:Connect(function()
            TS:Create(hdr, TweenInfo.new(0.15), { BackgroundColor3 = C.BG2 }):Play()
        end)
        hdr.MouseLeave:Connect(function()
            TS:Create(hdr, TweenInfo.new(0.15), { BackgroundColor3 = C.BG3 }):Play()
        end)

        local sub = { Pane = body, _order = 0 }
        function sub._nextOrder()
            sub._order = sub._order + 1
            return sub._order
        end
        N4.AttachWidgets(sub)
        return sub
    end

    local function makeRow(title, desc, height)
        local row = new("Frame", {
            Size = UDim2.new(1, 0, 0, height or (desc and 40 or 32)),
            BackgroundColor3 = C.BG3,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
        }, pane)
        corner(row, 4)
        local st = stroke(row, C.BORDER, 1, 0.6)

        new("TextLabel", {
            Size = UDim2.new(0.6, 0, 0, 16),
            Position = UDim2.fromOffset(10, 6),
            BackgroundTransparency = 1,
            Font = C.FONT,
            Text = title or "",
            TextSize = 12,
            TextColor3 = C.TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)
        if desc then
            new("TextLabel", {
                Size = UDim2.new(0.6, 0, 0, 12),
                Position = UDim2.fromOffset(10, 22),
                BackgroundTransparency = 1,
                Font = C.FONT,
                Text = desc,
                TextSize = 10,
                TextColor3 = C.TEXT_DIM,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, row)
        end
        row.MouseEnter:Connect(function()
            TS:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = C.BG2 }):Play()
            st.Transparency = 0.4
        end)
        row.MouseLeave:Connect(function()
            TS:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = C.BG3 }):Play()
            st.Transparency = 0.6
        end)
        return row
    end

    function tab:Paragraph(text)
        local row = new("Frame", {
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = C.BG3,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
        }, pane)
        corner(row, 4)
        stroke(row, C.BORDER, 1, 0.6)
        row.AutomaticSize = Enum.AutomaticSize.Y

        local lbl = new("TextLabel", {
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.fromOffset(10, 6),
            BackgroundTransparency = 1,
            Font = C.FONT,
            Text = text or "",
            TextSize = 12,
            TextColor3 = C.TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, row)
        new("UIPadding", {
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
            Parent = row,
        })

        local api = {}
        function api:Set(t) lbl.Text = tostring(t or "") end
        function api:Get() return lbl.Text end
        return api
    end

    function tab:Button(title, callback, opts)
        opts = opts or {}
        local row = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = opts.Danger and Color3.fromRGB(60, 20, 25) or C.BG3,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = nextOrder(),
        }, pane)
        corner(row, 4)
        local st = stroke(row, opts.Danger and C.RED or C.BORDER, 1, 0.5)

        new("TextLabel", {
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.fromOffset(12, 0),
            BackgroundTransparency = 1,
            Font = C.FONT_BOLD,
            Text = title or "Button",
            TextSize = 12,
            TextColor3 = opts.Danger and C.RED or C.TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local bar = new("Frame", {
            Size = UDim2.new(0, 2, 1, -8),
            Position = UDim2.fromOffset(0, 4),
            BackgroundColor3 = opts.Danger and C.RED or C.NEON_A,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, row)
        corner(bar, 2)

        row.MouseEnter:Connect(function()
            TS:Create(row, TweenInfo.new(0.15), {
                BackgroundColor3 = opts.Danger and Color3.fromRGB(85, 26, 32) or C.BG2
            }):Play()
            st.Transparency = 0.2
            TS:Create(bar, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
        end)
        row.MouseLeave:Connect(function()
            TS:Create(row, TweenInfo.new(0.15), {
                BackgroundColor3 = opts.Danger and Color3.fromRGB(60, 20, 25) or C.BG3
            }):Play()
            st.Transparency = 0.5
            TS:Create(bar, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
        end)
        row.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        return row
    end

    function tab:Toggle(title, default, callback, desc)
        local row = makeRow(title, desc, desc and 40 or 32)
        local sw = new("Frame", {
            Size = UDim2.fromOffset(38, 18),
            Position = UDim2.new(1, -48, 0.5, -9),
            BackgroundColor3 = C.BG,
            BorderSizePixel = 0,
        }, row)
        corner(sw, 9)
        local swStroke = stroke(sw, C.BORDER, 1, 0.3)
        local knob = new("Frame", {
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.fromOffset(2, 2),
            BackgroundColor3 = C.TEXT_DIM,
            BorderSizePixel = 0,
        }, sw)
        corner(knob, 999)

        local state = default == true
        local function update()
            if state then
                TS:Create(sw, TweenInfo.new(0.15), { BackgroundColor3 = C.BG2 }):Play()
                swStroke.Color = C.NEON_A
                swStroke.Transparency = 0.2
                TS:Create(knob, TweenInfo.new(0.15), {
                    Position = UDim2.fromOffset(22, 2),
                    BackgroundColor3 = C.NEON_A
                }):Play()
            else
                TS:Create(sw, TweenInfo.new(0.15), { BackgroundColor3 = C.BG }):Play()
                swStroke.Color = C.BORDER
                swStroke.Transparency = 0.3
                TS:Create(knob, TweenInfo.new(0.15), {
                    Position = UDim2.fromOffset(2, 2),
                    BackgroundColor3 = C.TEXT_DIM
                }):Play()
            end
        end
        update()

        row.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                state = not state
                update()
                if callback then pcall(callback, state) end
            end
        end)

        local api = {}
        function api:Set(v) state = v == true; update() end
        function api:Get() return state end
        return api
    end

    function tab:Slider(title, min, max, default, callback, desc)
        local row = makeRow(title, desc, desc and 46 or 38)
        local valueLbl = new("TextLabel", {
            Size = UDim2.new(0, 70, 0, 12),
            Position = UDim2.new(1, -80, 0, 6),
            BackgroundTransparency = 1,
            Font = C.FONT_BOLD,
            Text = tostring(default),
            TextSize = 11,
            TextColor3 = C.NEON_A,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, row)

        local track = new("Frame", {
            Size = UDim2.new(1, -20, 0, 4),
            Position = UDim2.new(0, 10, 1, -12),
            BackgroundColor3 = C.BG,
            BorderSizePixel = 0,
        }, row)
        corner(track, 2)

        local fill = new("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
        }, track)
        corner(fill, 2)
        registerNeon(new("UIGradient", { Parent = fill }), 0.6)

        local knob = new("Frame", {
            Size = UDim2.fromOffset(10, 10),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = C.NEON_A,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, track)
        corner(knob, 999)
        stroke(knob, C.BG, 2, 0)

        local val = default
        local function apply(v, fire)
            v = math.clamp(v, min, max)
            val = v
            local p = (max - min) > 0 and (v - min) / (max - min) or 0
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            valueLbl.Text = tostring(math.floor(v * 100 + 0.5) / 100)
            if fire and callback then pcall(callback, v) end
        end
        apply(default, false)

        local dragging = false
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch) then
                local rel = (i.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X)
                apply(min + (max - min) * math.clamp(rel, 0, 1), true)
            end
        end)

        local api = {}
        function api:Set(v) apply(v, false) end
        function api:Get() return val end
        return api
    end

    function tab:Dropdown(title, values, default, callback)
        local row = makeRow(title, nil, 32)
        local current = default or values[1]
        local valueLbl = new("TextLabel", {
            Size = UDim2.new(0, 130, 1, 0),
            Position = UDim2.new(1, -140, 0, 0),
            BackgroundTransparency = 1,
            Font = C.FONT,
            Text = tostring(current) .. "  ▾",
            TextSize = 11,
            TextColor3 = C.NEON_A,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, row)

        local dropdown
        local function buildList()
            if dropdown then dropdown:Destroy() end
            local visible = math.min(#values, 8)
            dropdown = new("Frame", {
                Size = UDim2.new(1, 0, 0, visible * 24 + 8),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = C.BG2,
                BorderSizePixel = 0,
                ZIndex = 50,
                Visible = false,
            }, row)
            corner(dropdown, 4)
            stroke(dropdown, C.NEON_A, 1, 0.4)
            new("UIListLayout", { Padding = UDim.new(0, 2), Parent = dropdown })
            new("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
                Parent = dropdown,
            })
            for i, v in ipairs(values) do
                local item = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundColor3 = C.BG3,
                    BorderSizePixel = 0,
                    Font = C.FONT,
                    Text = "  " .. tostring(v),
                    TextSize = 11,
                    TextColor3 = C.TEXT,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    LayoutOrder = i,
                    ZIndex = 51,
                }, dropdown)
                corner(item, 3)
                item.MouseEnter:Connect(function()
                    TS:Create(item, TweenInfo.new(0.1), { BackgroundColor3 = C.BG, TextColor3 = C.NEON_A }):Play()
                end)
                item.MouseLeave:Connect(function()
                    TS:Create(item, TweenInfo.new(0.1), { BackgroundColor3 = C.BG3, TextColor3 = C.TEXT }):Play()
                end)
                item.MouseButton1Click:Connect(function()
                    current = v
                    valueLbl.Text = tostring(v) .. "  ▾"
                    dropdown.Visible = false
                    if callback then pcall(callback, v) end
                end)
            end
        end
        buildList()

        row.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                dropdown.Visible = not dropdown.Visible
            end
        end)

        local api = {}
        function api:Set(v)
            current = v
            valueLbl.Text = tostring(v) .. "  ▾"
        end
        function api:Get() return current end
        return api
    end

    function tab:Input(title, default, placeholder, callback)
        local row = makeRow(title, nil, 32)
        local box = new("TextBox", {
            Size = UDim2.new(0.45, 0, 0, 20),
            Position = UDim2.new(1, -10, 0.5, -10),
            BackgroundColor3 = C.BG,
            BorderSizePixel = 0,
            Font = C.FONT,
            Text = default or "",
            PlaceholderText = placeholder or "",
            PlaceholderColor3 = C.TEXT_DIM,
            TextSize = 11,
            TextColor3 = C.TEXT,
            ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        corner(box, 3)
        stroke(box, C.BORDER, 1, 0.3)
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            Parent = box,
        })
        box.Focused:Connect(function()
            TS:Create(box, TweenInfo.new(0.15), { BackgroundColor3 = C.BG2 }):Play()
        end)
        box.FocusLost:Connect(function()
            TS:Create(box, TweenInfo.new(0.15), { BackgroundColor3 = C.BG }):Play()
            if callback then pcall(callback, box.Text) end
        end)

        local api = {}
        function api:Set(v) box.Text = tostring(v) end
        function api:Get() return box.Text end
        return api
    end

    return tab
end

-- ============================================================
-- BUILD UI
-- ============================================================
local ui = N4.new({
    Title    = "N4 Rebuild",
    Subtitle = "v0.1",
    Size     = UDim2.fromOffset(660, 440),
})

local farm = ui:Tab("Farm")
local main = farm:Section("Auto Farm")
main:Toggle("Enable", false, function(v)
    ui:SetStatus("Auto Farm: " .. (v and "ON" or "OFF"))
end)
main:Slider("Speed (ms)", 50, 500, 220, function(v)
    ui:SetStatus("Speed: " .. v .. " ms")
end)
main:Slider("Multi target", 1, 5, 1, function(v) end, "Tile dipukul bergantian")
main:Dropdown("Mode", { "Place + Break", "Break only", "Place only" }, "Place + Break", function(v)
    ui:SetStatus("Mode: " .. v)
end)

local block = farm:Section("Block")
block:Dropdown("Pilih block", { "Dirt", "Stone", "Wood" }, "Dirt", function(v) end)
block:Button("Refresh daftar", function()
    ui:SetStatus("Refreshing...")
end)

local set = ui:Tab("Settings")
local misc = set:Section("Karakter")
misc:Toggle("Infinite Jump", false, function(v) end)
misc:Toggle("Fly + Noclip", false, function(v) end, "Bisa kena rollback")
misc:Slider("Walkspeed %", 50, 500, 100, function(v) end)

local info = set:Section("Info")
info:Paragraph("N4 Rebuild — IMGUI + neon running.\nTekan Insert / RShift untuk sembunyikan, atau tombol [N4] di kanan atas.")

local cons = ui:Tab("Console")
local log = cons:Paragraph("◆ " .. os.date("%H:%M:%S") .. "  ready")
cons:Button("Log sesuatu", function()
    log:Set("◆ " .. os.date("%H:%M:%S") .. "  tombol ditekan")
end)
cons:Button("Reset UI", function()
    ui:SetStatus("Reset")
end, { Danger = true })

ui:SetStatus("UI siap")

-- ============================================================
-- MOBILE TOGGLE BUTTON (pojok kanan atas)
-- ============================================================
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "N4Toggle"
toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.DisplayOrder = 10000

local okH, hui = pcall(function() return gethui and gethui() end)
toggleGui.Parent = (okH and hui) or PG

local btn = Instance.new("TextButton")
btn.Size = UDim2.fromOffset(50, 50)
btn.Position = UDim2.new(1, -70, 0, 20)
btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
btn.Text = "N4"
btn.Font = Enum.Font.Code
btn.TextSize = 14
btn.TextColor3 = Color3.fromRGB(0, 245, 255)
btn.BorderSizePixel = 0
btn.AutoButtonColor = false
btn.Parent = toggleGui

local c1 = Instance.new("UICorner", btn)
c1.CornerRadius = UDim.new(1, 0)

local s1 = Instance.new("UIStroke", btn)
s1.Color = Color3.fromRGB(0, 245, 255)
s1.Thickness = 2

local uig = Instance.new("UIGradient", s1)
uig.Color = NEON_SEQ

btn.MouseButton1Click:Connect(function()
    ui.Root.Visible = not ui.Root.Visible
end)

-- drag tombol toggle
do
    local dragging, dragStart, startPos = false, nil, nil
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, btn.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- keyboard toggle (PC)
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.RightShift then
        ui.Root.Visible = not ui.Root.Visible
    end
end)

print("[N4] UI loaded — tekan tombol N4 atau Insert untuk toggle")
