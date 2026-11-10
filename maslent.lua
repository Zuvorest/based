-- ============================================================
-- MASLENT V0.1 BETA TESTER
-- Hacker / Termux Theme + Auto Farm Logic
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ============================================================
-- THEME & COLORS
-- ============================================================
local Colors = {
    Bg = Color3.fromRGB(10, 12, 16),
    Bg2 = Color3.fromRGB(15, 18, 24),
    Bg3 = Color3.fromRGB(22, 27, 36),
    Bg4 = Color3.fromRGB(32, 40, 52),
    Accent = Color3.fromRGB(0, 255, 200),  -- Neon Cyan
    Accent2 = Color3.fromRGB(0, 150, 255), -- Blue
    Text = Color3.fromRGB(220, 225, 230),
    Dim = Color3.fromRGB(120, 130, 140),
    Red = Color3.fromRGB(255, 80, 100),
    Green = Color3.fromRGB(50, 255, 100),
    Font = Enum.Font.Code,
    FontBold = Enum.Font.Code,
}

local NEON_SEQ = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Accent),
    ColorSequenceKeypoint.new(0.5, Colors.Accent2),
    ColorSequenceKeypoint.new(1, Colors.Accent),
})

local function new(c, p, parent)
    local i = Instance.new(c)
    for k, v in pairs(p or {}) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = p
end

local function stroke(p, c, t)
    local s = Instance.new("UIStroke")
    s.Color = c or Colors.Bg4
    s.Thickness = t or 1
    s.Parent = p
    return s
end

-- ============================================================
-- GAME HOOKS (Dari Source Asli, Disederhanakan)
-- ============================================================
local State = { Running = false, Offsets = {}, SelectedId = nil, PlaceMs = 150, BreakMs = 200 }
local Refs = { SetTile = nil, Punch = nil, World = nil, Inv = nil, State = nil }
local ItemDB = nil

local function getconsts(fn)
    if type(getconstants) == "function" then return getconstants(fn) end
    if debug and type(debug.getconstants) == "function" then return debug.getconstants(fn) end
    return {}
end

local function isSetTileFn(fn)
    local consts = getconsts(fn)
    local a, b, c = false, false, false
    for _, k in pairs(consts) do
        if k == "tile" or k == "SetTile" then a = true
        elseif k == "placedAt" then b = true
        elseif k == "flips" then c = true end
    end
    return a and b and c
end

local function isPunchFn(fn)
    local consts = getconsts(fn)
    local v, m = false, false
    for _, k in pairs(consts) do
        if type(k) == "string" and k:lower():find("vending") then v = true
        elseif k == "newCrack" then m = true end
    end
    return v and m
end

local function scanGame()
    if not getgc then return end
    local ok, objects = pcall(getgc, true)
    if not ok then return end
    
    for i, v in pairs(objects) do
        if type(v) == "table" then
            if not Refs.World and v.fg and v.bg and v.w then
                Refs.World = v
            end
            if not ItemDB then
                local isDB, count = false, 0
                for k, item in pairs(v) do
                    if type(k) == "number" and type(item) == "table" and type(item.name) == "string" then
                        count = count + 1
                        if count > 5 then isDB = true; break end
                    end
                end
                if isDB then ItemDB = v end
            end
            if not Refs.Inv and v.slots and v.capacity and type(v.count) == "function" then
                Refs.Inv = v
            end
            if not Refs.State and type(rawget(v, "state")) == "function" then
                local okS, s = pcall(rawget(v, "state"))
                if okS and type(s) == "table" and type(s.x) == "number" then
                    Refs.State = rawget(v, "state")
                end
            end
        elseif type(v) == "function" then
            if not Refs.SetTile and isSetTileFn(v) then Refs.SetTile = v
            elseif not Refs.Punch and isPunchFn(v) then Refs.Punch = v end
        end
        if i % 500 == 0 then task.wait() end
    end
end

task.spawn(function()
    while true do
        scanGame()
        task.wait(3)
    end
end)

-- ============================================================
-- UI BUILDER
-- ============================================================
local function getGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MaslentUI"
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

local function tween(obj, props)
    TweenService:Create(obj, TweenInfo.new(0.15), props):Play()
end

local ui = {}
local screenGui = getGui()

local root = new("Frame", {
    Size = UDim2.fromOffset(560, 380),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BorderSizePixel = 0,
}, screenGui)
corner(root, 6)

local glow = new("UIGradient", { Parent = root })
glow.Color = NEON_SEQ

local inner = new("Frame", {
    Size = UDim2.new(1, -2, 1, -2),
    Position = UDim2.fromOffset(1, 1),
    BackgroundColor3 = Colors.Bg,
    BorderSizePixel = 0,
}, root)
corner(inner, 5)

local uiscale = new("UIScale", { Parent = root, Scale = 0.85 })
if not UIS.TouchEnabled then uiscale.Scale = 1 end

-- TOP BAR
local topBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Colors.Bg2,
    BorderSizePixel = 0,
    ZIndex = 2,
}, inner)
corner(topBar, 5)
new("Frame", { Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, -5), BackgroundColor3 = Colors.Bg2, BorderSizePixel = 0, ZIndex = 2 }, topBar)

new("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Font = Colors.FontBold,
    Text = "[ MASLENT V0.1 BETA TESTER ]",
    TextSize = 13,
    TextColor3 = Colors.Accent,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, topBar)

local minBtn = new("TextButton", {
    Size = UDim2.fromOffset(24, 20),
    Position = UDim2.new(1, -60, 0.5, -10),
    BackgroundColor3 = Colors.Bg3,
    BorderSizePixel = 0,
    Text = "-",
    Font = Colors.FontBold,
    TextSize = 14,
    TextColor3 = Colors.Text,
    AutoButtonColor = false,
    Active = true,
    ZIndex = 10,
}, topBar)
corner(minBtn, 3)

local closeBtn = new("TextButton", {
    Size = UDim2.fromOffset(24, 20),
    Position = UDim2.new(1, -32, 0.5, -10),
    BackgroundColor3 = Colors.Bg3,
    BorderSizePixel = 0,
    Text = "x",
    Font = Colors.FontBold,
    TextSize = 14,
    TextColor3 = Colors.Red,
    AutoButtonColor = false,
    Active = true,
    ZIndex = 10,
}, topBar)
corner(closeBtn, 3)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(root, TweenInfo.new(0.2), { Size = minimized and UDim2.fromOffset(560, 32) or UDim2.fromOffset(560, 380) }):Play()
    side.Visible = not minimized
    content.Visible = not minimized
    bottom.Visible = not minimized
end)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- SIDEBAR
local side = new("Frame", {
    Size = UDim2.new(0, 130, 1, -54),
    Position = UDim2.fromOffset(0, 32),
    BackgroundColor3 = Colors.Bg2,
    BorderSizePixel = 0,
    ZIndex = 2,
}, inner)
new("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Colors.Bg4, BorderSizePixel = 0, ZIndex = 3 }, side)

local tabList = new("Frame", { Size = UDim2.new(1, -10, 1, -10), Position = UDim2.fromOffset(5, 5), BackgroundTransparency = 1, ZIndex = 3 }, side)
new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabList })

-- CONTENT
local content = new("ScrollingFrame", {
    Size = UDim2.new(1, -130, 1, -54),
    Position = UDim2.fromOffset(130, 32),
    BackgroundColor3 = Colors.Bg,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Colors.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 2,
}, inner)
new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = content })
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })

-- BOTTOM BAR
local bottom = new("Frame", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 1, -22),
    BackgroundColor3 = Colors.Bg2,
    BorderSizePixel = 0,
    ZIndex = 2,
}, inner)
new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Colors.Bg4, BorderSizePixel = 0 }, bottom)
local status = new("TextLabel", {
    Size = UDim2.new(1, -10, 1, 0),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Font = Colors.Font,
    Text = "system: ready",
    TextSize = 11,
    TextColor3 = Colors.Dim,
    TextXAlignment = Enum.TextXAlignment.Left,
}, bottom)

function ui:SetStatus(txt)
    status.Text = "system: " .. txt
end

-- DRAG
local drag, start, pos
topBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag, start, pos = true, i.Position, root.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - start
        root.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
    end
end)

-- ============================================================
-- WIDGETS
-- ============================================================
local function makeTab(name)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Colors.Bg3,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "  > " .. name,
        Font = Colors.FontBold,
        TextSize = 12,
        TextColor3 = Colors.Dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ZIndex = 3,
    }, tabList)
    corner(btn, 3)
    
    local pane = new("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Visible = false })
    new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = pane })
    pane.Parent = content
    
    btn.MouseButton1Click:Connect(function()
        for _, c in pairs(content:GetChildren()) do
            if c:IsA("Frame") then c.Visible = false end
        end
        for _, b in pairs(tabList:GetChildren()) do
            if b:IsA("TextButton") then tween(b, {TextColor3 = Colors.Dim, BackgroundTransparency = 1}) end
        end
        pane.Visible = true
        tween(btn, {TextColor3 = Colors.Accent, BackgroundTransparency = 0.6})
    end)
    return btn, pane
end

local function makeSection(parent, title)
    local holder = new("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
    new("UIListLayout", { Padding = UDim.new(0, 4), Parent = holder })
    
    local hdr = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Colors.Bg2, BorderSizePixel = 0 })
    new("Frame", { Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Colors.Accent }, hdr)
    new("TextLabel", { Size = UDim2.new(1, -10, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Font = Colors.FontBold, Text = "> " .. title, TextSize = 12, TextColor3 = Colors.Text, TextXAlignment = Enum.TextXAlignment.Left }, hdr)
    hdr.Parent = holder
    
    local body = new("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
    new("UIListLayout", { Padding = UDim.new(0, 4), Parent = body })
    body.Parent = holder
    holder.Parent = parent
    return body
end

local function makeButton(parent, text, callback)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Colors.Bg3,
        BorderSizePixel = 0,
        Text = "  [ " .. text .. " ]",
        Font = Colors.FontBold,
        TextSize = 12,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, parent)
    corner(btn, 3)
    stroke(btn, Colors.Bg4)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Colors.Bg4}) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Colors.Bg3}) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

local function makeToggle(parent, title, default, callback)
    local row = new("TextButton", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Colors.Bg3, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, parent)
    corner(row, 3)
    stroke(row, Colors.Bg4)
    new("TextLabel", { Size = UDim2.new(1, -50, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Font = Colors.Font, Text = title, TextSize = 12, TextColor3 = Colors.Text, TextXAlignment = Enum.TextXAlignment.Left }, row)
    local ind = new("TextLabel", { Size = UDim2.fromOffset(30, 1), Position = UDim2.new(1, -35, 0, 0), BackgroundTransparency = 1, Font = Colors.FontBold, Text = "", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right }, row)
    
    local state = default
    local function update()
        ind.Text = state and "[ON]" or "[OFF]"
        ind.TextColor3 = state and Colors.Green or Colors.Dim
    end
    update()
    row.MouseButton1Click:Connect(function()
        state = not state
        update()
        if callback then callback(state) end
    end)
end

-- ============================================================
-- TAB 1: FARM
-- ============================================================
local farmBtn, farmPane = makeTab("Farm")
farmBtn.MouseButton1Click:Connect(function() farmBtn.MouseButton1Click() end) -- Trigger default

-- Section Auto Farm
local sAuto = makeSection(farmPane, "Auto Farm")
local startBtn
startBtn = makeButton(sAuto, "START AUTO FARM", function()
    State.Running = not State.Running
    if State.Running then
        startBtn.Text = "  [ STOP AUTO FARM ]"
        startBtn.TextColor3 = Colors.Red
        ui:SetStatus("Auto Farm RUNNING")
        task.spawn(function()
            while State.Running do
                if not (Refs.SetTile and Refs.Punch and Refs.State) then
                    ui:SetStatus("Hooks missing, waiting...")
                    task.wait(1)
                    continue
                end
                local ok, s = pcall(Refs.State)
                if not ok or not s or type(s.x) ~= "number" then task.wait(0.5) continue end
                local px, py = math.floor(s.x), math.floor(s.y - 0.475)
                
                -- Place
                for key in pairs(State.Offsets) do
                    if not State.Running then break end
                    local dx, dy = key:match("^(-?%d+),(-?%d+)$")
                    dx, dy = tonumber(dx), tonumber(dy)
                    if dx and dy and State.SelectedId then
                        local tx, ty = px + dx, py + dy
                        local fg = 0
                        if ty >= 0 and ty < Refs.World.h and Refs.World.fg[ty] then fg = Refs.World.fg[ty][tx] or 0 end
                        if fg == 0 then
                            pcall(Refs.SetTile, "fg", tx, ty, State.SelectedId, false, false)
                            task.wait(State.PlaceMs / 1000)
                        end
                    end
                end
                
                -- Break
                for key in pairs(State.Offsets) do
                    if not State.Running then break end
                    local dx, dy = key:match("^(-?%d+),(-?%d+)$")
                    dx, dy = tonumber(dx), tonumber(dy)
                    if dx and dy then
                        local tx, ty = px + dx, py + dy
                        local fg = 0
                        if ty >= 0 and ty < Refs.World.h and Refs.World.fg[ty] then fg = Refs.World.fg[ty][tx] or 0 end
                        if fg ~= 0 then
                            pcall(Refs.Punch, tx, ty, false, nil)
                            task.wait(State.BreakMs / 1000)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        startBtn.Text = "  [ START AUTO FARM ]"
        startBtn.TextColor3 = Colors.Text
        ui:SetStatus("Auto Farm STOPPED")
    end
end)

-- Section Select Block
local sBlock = makeSection(farmPane, "Select Block")
local selectedLbl = "None selected"
local ddRow = new("TextButton", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Colors.Bg3, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, sBlock)
corner(ddRow, 3)
stroke(ddRow, Colors.Bg4)
local ddText = new("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Font = Colors.Font, Text = "> " .. selectedLbl, TextSize = 12, TextColor3 = Colors.Dim, TextXAlignment = Enum.TextXAlignment.Left }, ddRow)
local drop = new("Frame", { Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 1, 4), BackgroundColor3 = Colors.Bg2, BorderSizePixel = 0, Visible = false, ZIndex = 20 }, ddRow)
corner(drop, 3)
stroke(drop, Colors.Bg4)
new("UIListLayout", { Padding = UDim.new(0, 2), Parent = drop })
new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = drop })

ddRow.MouseButton1Click:Connect(function()
    drop.Visible = not drop.Visible
    if drop.Visible then
        drop.ZIndex = 30
        for _, c in pairs(drop:GetChildren()) do c.ZIndex = 31 end
    end
end)

makeButton(sBlock, "REFRESH INVENTORY", function()
    scanGame()
    for _, c in pairs(drop:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local items, h = {}, 0
    if Refs.Inv and ItemDB then
        for _, slot in pairs(Refs.Inv.slots) do
            if type(slot) == "table" and slot.id and slot.n > 0 then
                local item = ItemDB[slot.id]
                if item and item.name and item.kind ~= "tool" and not item.lock then
                    local label = item.name .. " [" .. slot.id .. "] x" .. slot.n
                    table.insert(items, label)
                    local opt = new("TextButton", { Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Colors.Bg3, BorderSizePixel = 0, Text = "  " .. label, Font = Colors.Font, TextSize = 11, TextColor3 = Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 21 }, drop)
                    corner(opt, 2)
                    opt.MouseButton1Click:Connect(function()
                        drop.Visible = false
                        ddText.Text = "> " .. label
                        ddText.TextColor3 = Colors.Accent
                        State.SelectedId = slot.id
                        ui:SetStatus("Selected: " .. item.name)
                    end)
                    h = h + 24
                end
            end
        end
    end
    drop.Size = UDim2.new(1, 0, 0, math.min(h + 8, 120))
    ui:SetStatus("Found " .. #items .. " blocks.")
end)

-- Section Tiles (Target)
local sTiles = makeSection(farmPane, "Tiles (Target)")
local gridHolder = new("Frame", { Size = UDim2.new(1, 0, 0, 160), BackgroundTransparency = 1 }, sTiles)
local gridFrame = new("Frame", { Size = UDim2.fromOffset(150, 150), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Colors.Bg2 }, gridHolder)
corner(gridFrame, 4)
stroke(gridFrame, Colors.Bg4)

local cells = {}
local function updateGrid()
    for _, c in pairs(cells) do
        if State.Offsets[c.key] then tween(c.btn, {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.Bg})
        else tween(c.btn, {BackgroundColor3 = Colors.Bg3, TextColor3 = Colors.Dim}) end
    end
end

for r = 0, 4 do
    for c = 0, 4 do
        local dx, dy = c - 2, r - 2
        local key = dx .. "," .. dy
        local btn = new("TextButton", {
            Size = UDim2.fromOffset(26, 26),
            Position = UDim2.fromOffset(10 + c * 28, 10 + r * 28),
            BackgroundColor3 = Colors.Bg3,
            BorderSizePixel = 0,
            Text = (dx == 0 and dy == 0) and "ME" or "",
            Font = Colors.Font, TextSize = 10, TextColor3 = Colors.Dim, AutoButtonColor = false,
        }, gridFrame)
        corner(btn, 2)
        if dx == 0 and dy == 0 then
            btn.BackgroundColor3 = Colors.Accent2
            btn.TextColor3 = Colors.Text
        else
            btn.MouseButton1Click:Connect(function()
                State.Offsets[key] = not State.Offsets[key]
                updateGrid()
            end)
        end
        table.insert(cells, { btn = btn, key = key })
    end
end

makeButton(sTiles, "CLEAR TILES", function()
    State.Offsets = {}
    updateGrid()
    ui:SetStatus("Tiles cleared.")
end)

-- ============================================================
-- TAB 2: SETTINGS
-- ============================================================
local setBtn, setPane = makeTab("Settings")
local sSpeed = makeSection(setPane, "Speed Settings")

makeToggle(sSpeed, "Auto Collect (Visual Only)", true, function(v) end)

local function makeSlider(parent, title, min, max, default, callback)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Colors.Bg3, BorderSizePixel = 0 }, parent)
    corner(row, 3)
    stroke(row, Colors.Bg4)
    new("TextLabel", { Size = UDim2.new(0.6, 0, 0, 16), Position = UDim2.fromOffset(10, 4), BackgroundTransparency = 1, Font = Colors.Font, Text = title, TextSize = 12, TextColor3 = Colors.Text, TextXAlignment = Enum.TextXAlignment.Left }, row)
    local valLbl = new("TextLabel", { Size = UDim2.new(0.3, 0, 0, 16), Position = UDim2.new(0.7, 0, 0, 4), BackgroundTransparency = 1, Font = Colors.FontBold, Text = tostring(default), TextSize = 11, TextColor3 = Colors.Accent, TextXAlignment = Enum.TextXAlignment.Right }, row)
    local track = new("Frame", { Size = UDim2.new(1, -20, 0, 4), Position = UDim2.new(0, 10, 1, -10), BackgroundColor3 = Colors.Bg, BorderSizePixel = 0 }, row)
    corner(track, 2)
    local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Colors.Accent, BorderSizePixel = 0 }, track)
    corner(fill, 2)
    
    local val = default
    local function apply(v, fire)
        v = math.clamp(v, min, max)
        val = v
        local p = (max - min) > 0 and (v - min) / (max - min) or 0
        fill.Size = UDim2.new(p, 0, 1, 0)
        valLbl.Text = tostring(math.floor(v))
        if fire and callback then callback(v) end
    end
    apply(default, false)
    
    local dragging = false
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = (i.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X)
            apply(min + (max - min) * math.clamp(rel, 0, 1), true)
        end
    end)
end

makeSlider(sSpeed, "Place Delay (ms)", 50, 500, State.PlaceMs, function(v) State.PlaceMs = v end)
makeSlider(sSpeed, "Break Delay (ms)", 50, 500, State.BreakMs, function(v) State.BreakMs = v end)

-- ============================================================
-- INIT & ANIMATION
-- ============================================================
farmBtn.MouseButton1Click() -- Select Farm tab by default

task.spawn(function()
    while screenGui.Parent do
        glow.Offset = Vector2.new((tick() % 2), 0)
        task.wait(0.03)
    end
end)

-- Mobile Toggle Button
local toggleBtn = new("TextButton", {
    Size = UDim2.fromOffset(45, 45),
    Position = UDim2.new(1, -60, 0, 80),
    BackgroundColor3 = Colors.Bg2,
    BorderSizePixel = 0,
    Text = "N4",
    Font = Colors.FontBold,
    TextSize = 13,
    TextColor3 = Colors.Accent,
    Active = true,
    ZIndex = 100
}, screenGui)
corner(toggleBtn, 999)
stroke(toggleBtn, Colors.Accent, 2)

toggleBtn.MouseButton1Click:Connect(function()
    root.Visible = not root.Visible
end)

ui:SetStatus("Loaded successfully.")
