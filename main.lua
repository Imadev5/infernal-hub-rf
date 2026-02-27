local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- =====================
-- REACH MODULE (unchanged)
-- =====================
local ReachModule = {
    enabled = true,
    distance = 5,
    connection = nil,
    cachedBalls = {},    
    lastUpdate = 0,       
    cachedLimbs = {}    
}

pcall(function()
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "overlapCheck") and rawget(v, "gkCheck") then
            hookfunction(v.overlapCheck, function() return true end)
            hookfunction(v.gkCheck, function() return true end)
        end
    end
end)

local function fireTouch(ball, limb)
    if not firetouchinterest then return end
    if not ball or not ball.Parent then return end
    firetouchinterest(ball, limb, 0)
    firetouchinterest(ball, limb, 1)
end

local function refreshCache()
    local balls = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj:FindFirstChild("network") then
            table.insert(balls, obj)
        end
    end
    return balls
end

function ReachModule:Start()
    if self.connection then return end
    self.connection = RunService.Heartbeat:Connect(function()
        if not self.enabled then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if tick() - self.lastUpdate > 1 then
            self.cachedBalls = refreshCache()
            self.cachedLimbs = {}
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    table.insert(self.cachedLimbs, part)
                end
            end
            self.lastUpdate = tick()
        end
        for _, ball in ipairs(self.cachedBalls) do
            if ball and ball.Parent then
                local dist = (ball.Position - root.Position).Magnitude
                if dist <= self.distance then
                    for _, limb in ipairs(self.cachedLimbs) do
                        task.spawn(fireTouch, ball, limb)
                    end
                end
            end
        end
    end)
end

function ReachModule:Stop()
    if self.connection then self.connection:Disconnect() self.connection = nil end
end

function ReachModule:SetDistance(dist) self.distance = dist end

function ReachModule:Toggle(state)
    self.enabled = state
    if state and not self.connection then self:Start() end
end

ReachModule:Start()

-- =====================
-- REACH BOX (3D white box attached to root, static, follows player)
-- =====================
local reachBoxEnabled = false
local reachBoxPart = nil

local function removeReachBox()
    if reachBoxPart then
        reachBoxPart:Destroy()
        reachBoxPart = nil
    end
end

local function createReachBox(distance)
    removeReachBox()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local box = Instance.new("Part")
    box.Name = "ReachBox"
    box.Size = Vector3.new(distance * 2, distance * 2, distance * 2)
    box.Anchored = false
    box.CanCollide = false
    box.CastShadow = false
    box.Massless = true
    box.Transparency = 0.75
    box.BrickColor = BrickColor.new("White")
    box.Material = Enum.Material.Neon
    box.Parent = workspace

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = box
    weld.Parent = box

    box.CFrame = root.CFrame

    reachBoxPart = box
end

local function updateReachBoxSize(distance)
    if reachBoxPart then
        reachBoxPart.Size = Vector3.new(distance * 2, distance * 2, distance * 2)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    if reachBoxEnabled then
        task.wait(1)
        createReachBox(ReachModule.distance)
    end
end)

-- =====================
-- UI HELPERS
-- =====================
local COLORS = {
    bg         = Color3.fromRGB(17, 17, 22),
    titleBg    = Color3.fromRGB(13, 13, 18),
    border     = Color3.fromRGB(30, 30, 42),
    rowBg      = Color3.fromRGB(22, 22, 31),
    rowHover   = Color3.fromRGB(24, 24, 40),
    rowSel     = Color3.fromRGB(22, 22, 58),
    rowSelBdr  = Color3.fromRGB(51, 51, 170),
    toggleOff  = Color3.fromRGB(34, 34, 42),
    toggleOn   = Color3.fromRGB(51, 51, 204),
    thumbOff   = Color3.fromRGB(80, 80, 90),
    thumbOn    = Color3.fromRGB(170, 170, 255),
    text       = Color3.fromRGB(187, 187, 187),
    textSel    = Color3.fromRGB(170, 170, 255),
    textDim    = Color3.fromRGB(100, 100, 120),
    accent     = Color3.fromRGB(85, 85, 255),
    sliderBg   = Color3.fromRGB(34, 34, 42),
    sliderFill = Color3.fromRGB(85, 85, 255),
}

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.border
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function makePadding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent
    return p
end

-- =====================
-- SCREEN GUI + WINDOW
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer.PlayerGui

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 340, 0, 0)
Window.Position = UDim2.new(0.5, -170, 0, 80)
Window.BackgroundColor3 = COLORS.bg
Window.BorderSizePixel = 0
Window.AutomaticSize = Enum.AutomaticSize.Y
Window.ClipsDescendants = false
Window.Parent = ScreenGui
makeCorner(Window, 8)
makeStroke(Window, COLORS.border, 1)

local WindowLayout = Instance.new("UIListLayout")
WindowLayout.SortOrder = Enum.SortOrder.LayoutOrder
WindowLayout.Padding = UDim.new(0, 0)
WindowLayout.Parent = Window

-- =====================
-- TITLE BAR
-- =====================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = COLORS.titleBg
TitleBar.BorderSizePixel = 0
TitleBar.LayoutOrder = 0
TitleBar.Parent = Window

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = COLORS.border
TitleStroke.Thickness = 1
TitleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TitleStroke.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "EXECUTOR"
TitleLabel.TextColor3 = COLORS.textDim
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 10, 0, 10)
CloseBtn.Position = UDim2.new(1, -20, 0.5, -5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 74)
CloseBtn.Text = ""
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
makeCorner(CloseBtn, 10)

CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 77, 77) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 74) end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Window.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- =====================
-- TAB BAR
-- =====================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.BackgroundColor3 = COLORS.titleBg
TabBar.BorderSizePixel = 0
TabBar.LayoutOrder = 1
TabBar.Parent = Window

local TabBarStroke = Instance.new("UIStroke")
TabBarStroke.Color = COLORS.border
TabBarStroke.Thickness = 1
TabBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TabBarStroke.Parent = TabBar

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabBarLayout.Parent = TabBar

-- Tab pages container
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, 0, 0, 0)
Pages.BackgroundTransparency = 1
Pages.BorderSizePixel = 0
Pages.AutomaticSize = Enum.AutomaticSize.Y
Pages.LayoutOrder = 2
Pages.Parent = Window

local PagesLayout = Instance.new("UIListLayout")
PagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
PagesLayout.Parent = Pages

-- =====================
-- TAB BUILDER
-- =====================
local tabButtons = {}
local tabPages = {}
local activeTab = nil

local function setActiveTab(name)
    activeTab = name
    for n, btn in pairs(tabButtons) do
        if n == name then
            btn.BackgroundColor3 = COLORS.bg
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            -- accent underline
            btn.BorderSizePixel = 0
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke:Destroy() end
            local accent = Instance.new("Frame")
            accent.Name = "Accent"
            accent.Size = UDim2.new(1, 0, 0, 2)
            accent.Position = UDim2.new(0, 0, 1, -2)
            accent.BackgroundColor3 = COLORS.accent
            accent.BorderSizePixel = 0
            accent.Parent = btn
        else
            btn.BackgroundColor3 = COLORS.titleBg
            btn.TextColor3 = Color3.fromRGB(68, 68, 85)
            local accent = btn:FindFirstChild("Accent")
            if accent then accent:Destroy() end
        end
    end
    for n, page in pairs(tabPages) do
        page.Visible = (n == name)
    end
end

local function addTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/3, 0, 1, 0)
    btn.BackgroundColor3 = COLORS.titleBg
    btn.BorderSizePixel = 0
    btn.Text = name:upper()
    btn.TextColor3 = Color3.fromRGB(68, 68, 85)
    btn.TextSize = 10
    btn.Font = Enum.Font.Code
    btn.LayoutOrder = order
    btn.Parent = TabBar
    btn.ClipsDescendants = true
    tabButtons[name] = btn

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.LayoutOrder = order
    page.Parent = Pages
    tabPages[name] = page

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 0)
    pageLayout.Parent = page

    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingTop = UDim.new(0, 10)
    pagePad.PaddingBottom = UDim.new(0, 10)
    pagePad.PaddingLeft = UDim.new(0, 12)
    pagePad.PaddingRight = UDim.new(0, 12)
    pagePad.Parent = page

    btn.MouseButton1Click:Connect(function() setActiveTab(name) end)

    return page
end

-- =====================
-- ROW / TOGGLE BUILDER
-- =====================
local function addToggleRow(page, label, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = page

    local rowPad = Instance.new("UIPadding")
    rowPad.PaddingBottom = UDim.new(0, 5)
    rowPad.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 29)
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0
    bg.Parent = row
    makeCorner(bg, 5)
    local bgStroke = makeStroke(bg, Color3.fromRGB(0,0,0), 1)
    bgStroke.Transparency = 1

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COLORS.text
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = bg

    -- Toggle track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 32, 0, 17)
    track.Position = UDim2.new(1, -42, 0.5, -8)
    track.BackgroundColor3 = COLORS.toggleOff
    track.BorderSizePixel = 0
    track.Parent = bg
    makeCorner(track, 9)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 11, 0, 11)
    thumb.Position = UDim2.new(0, 3, 0.5, -5)
    thumb.BackgroundColor3 = COLORS.thumbOff
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    makeCorner(thumb, 6)

    local state = false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = bg

    local function setState(val)
        state = val
        if state then
            bg.BackgroundTransparency = 0
            bg.BackgroundColor3 = COLORS.rowSel
            bgStroke.Color = COLORS.rowSelBdr
            bgStroke.Transparency = 0
            lbl.TextColor3 = COLORS.textSel
            track.BackgroundColor3 = COLORS.toggleOn
            TweenService:Create(thumb, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 18, 0.5, -5),
                BackgroundColor3 = COLORS.thumbOn
            }):Play()
        else
            bg.BackgroundTransparency = 1
            bgStroke.Transparency = 1
            lbl.TextColor3 = COLORS.text
            track.BackgroundColor3 = COLORS.toggleOff
            TweenService:Create(thumb, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 3, 0.5, -5),
                BackgroundColor3 = COLORS.thumbOff
            }):Play()
        end
        if callback then callback(state) end
    end

    btn.MouseEnter:Connect(function()
        if not state then
            bg.BackgroundTransparency = 0
            bg.BackgroundColor3 = COLORS.rowHover
        end
    end)
    btn.MouseLeave:Connect(function()
        if not state then
            bg.BackgroundTransparency = 1
        end
    end)
    btn.MouseButton1Click:Connect(function() setState(not state) end)

    return setState
end

-- =====================
-- SLIDER BUILDER
-- =====================
local function addSlider(page, label, min, max, default, order, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 46)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = page

    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 16)
    topRow.BackgroundTransparency = 1
    topRow.BorderSizePixel = 0
    topRow.Parent = container

    local labelTxt = Instance.new("TextLabel")
    labelTxt.Size = UDim2.new(0.7, 0, 1, 0)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label
    labelTxt.TextColor3 = Color3.fromRGB(100, 100, 120)
    labelTxt.TextSize = 10
    labelTxt.Font = Enum.Font.Code
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left
    labelTxt.Parent = topRow

    local valTxt = Instance.new("TextLabel")
    valTxt.Size = UDim2.new(0.3, 0, 1, 0)
    valTxt.Position = UDim2.new(0.7, 0, 0, 0)
    valTxt.BackgroundTransparency = 1
    valTxt.Text = tostring(default)
    valTxt.TextColor3 = COLORS.textSel
    valTxt.TextSize = 10
    valTxt.Font = Enum.Font.Code
    valTxt.TextXAlignment = Enum.TextXAlignment.Right
    valTxt.Parent = topRow

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 26)
    track.BackgroundColor3 = COLORS.sliderBg
    track.BorderSizePixel = 0
    track.Parent = container
    makeCorner(track, 2)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = COLORS.sliderFill
    fill.BorderSizePixel = 0
    fill.Parent = track
    makeCorner(fill, 2)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    thumb.BackgroundColor3 = COLORS.accent
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    makeCorner(thumb, 6)

    local value = default
    local sliding = false

    local function updateSlider(inputX)
        local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + rel * (max - min))
        valTxt.Text = tostring(value)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -6, 0.5, -6)
        if callback then callback(value) end
    end

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 0, 20)
    sliderBtn.Position = UDim2.new(0, 0, 0, 18)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.BorderSizePixel = 0
    sliderBtn.Parent = container

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateSlider(input.Position.X)
        end
    end)
    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)

    return container
end

-- =====================
-- SECTION LABEL
-- =====================
local function addSectionLabel(page, text, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.Parent = page

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 8)
    line.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    line.BorderSizePixel = 0
    line.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 0, 0, 14)
    lbl.Position = UDim2.new(0, 0, 0, 14)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.BackgroundTransparency = 1
    lbl.Text = text:upper()
    lbl.TextColor3 = Color3.fromRGB(51, 51, 68)
    lbl.TextSize = 9
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
end

-- =====================
-- BUTTON BUILDER
-- =====================
local function addButton(page, label, order, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.Parent = page

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = label:upper()
    btn.TextColor3 = Color3.fromRGB(100, 100, 120)
    btn.TextSize = 10
    btn.Font = Enum.Font.Code
    btn.Parent = f
    makeCorner(btn, 4)
    local s = makeStroke(btn, Color3.fromRGB(42, 42, 58), 1)

    btn.MouseEnter:Connect(function()
        btn.TextColor3 = COLORS.textSel
        s.Color = COLORS.rowSelBdr
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(17, 17, 48)
    end)
    btn.MouseLeave:Connect(function()
        btn.TextColor3 = Color3.fromRGB(100, 100, 120)
        s.Color = Color3.fromRGB(42, 42, 58)
        btn.BackgroundTransparency = 1
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- =====================
-- BUILD TABS
-- =====================
local playerPage = addTab("player", 0)
local visualPage = addTab("visual", 1)
local miscPage   = addTab("misc",   2)

-- =====================
-- PLAYER TAB
-- =====================
addButton(playerPage, "add reach hitbox", 0, function()
    reachBoxEnabled = not reachBoxEnabled
    if reachBoxEnabled then
        createReachBox(ReachModule.distance)
    else
        removeReachBox()
    end
end)

addSlider(playerPage, "reach size", 1, 50, 5, 1, function(val)
    ReachModule:SetDistance(val)
    if reachBoxPart then
        updateReachBoxSize(val)
    end
end)

addSectionLabel(playerPage, "movement", 2)

addToggleRow(playerPage, "speed", 3, function(state)
    -- hook your speed logic here
end)

addToggleRow(playerPage, "fly", 4, function(state)
    -- hook your fly logic here
end)

addToggleRow(playerPage, "noclip", 5, function(state)
    -- hook your noclip logic here
end)

-- =====================
-- VISUAL TAB
-- =====================
addToggleRow(visualPage, "player esp", 0, function(state)
end)

addToggleRow(visualPage, "chams", 1, function(state)
end)

addToggleRow(visualPage, "tracers", 2, function(state)
end)

addToggleRow(visualPage, "fullbright", 3, function(state)
end)

-- =====================
-- MISC TAB
-- =====================
addToggleRow(miscPage, "anti-afk", 0, function(state)
end)

addToggleRow(miscPage, "auto rejoin", 1, function(state)
end)

addToggleRow(miscPage, "fov changer", 2, function(state)
end)

-- =====================
-- ACTIVATE DEFAULT TAB
-- =====================
setActiveTab("player")
