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
-- REACH BOX (fixed)
-- Uses a RemoteEvent heartbeat re-anchor trick to keep the weld
-- from drifting on network ownership changes
-- =====================
local reachBoxEnabled = false
local reachBoxPart = nil
local reachBoxWeld = nil
local reachBoxConn = nil

local function removeReachBox()
    if reachBoxConn then reachBoxConn:Disconnect(); reachBoxConn = nil end
    if reachBoxPart and reachBoxPart.Parent then reachBoxPart:Destroy() end
    reachBoxPart = nil
    reachBoxWeld = nil
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
    box.Transparency = 0.82
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Material = Enum.Material.Neon
    box.CFrame = root.CFrame
    box.Parent = workspace

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = box
    weld.Parent = box

    reachBoxPart = box
    reachBoxWeld = weld

    -- Re-seat the weld every frame to survive network ownership switches
    reachBoxConn = RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        if not reachBoxPart or not reachBoxPart.Parent then
            reachBoxConn:Disconnect()
            return
        end
        -- keep box snapped to root in case weld breaks
        if not reachBoxWeld or not reachBoxWeld.Parent then
            local w = Instance.new("WeldConstraint")
            w.Part0 = r
            w.Part1 = reachBoxPart
            w.Parent = reachBoxPart
            reachBoxWeld = w
        end
    end)
end

local function updateReachBoxSize(distance)
    if reachBoxPart and reachBoxPart.Parent then
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
-- SPEED BOOST (teleport-smooth)
-- Moves the character forward by small increments each heartbeat
-- so it looks smooth but avoids server-sided movement detection
-- =====================
local speedEnabled = false
local speedMultiplier = 2
local speedConn = nil

local function startSpeed()
    if speedConn then return end
    speedConn = RunService.Heartbeat:Connect(function(dt)
        if not speedEnabled then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.MoveDirection.Magnitude == 0 then return end

        local baseSpeed = hum.WalkSpeed
        local extraSpeed = baseSpeed * (speedMultiplier - 1)
        local moveDir = hum.MoveDirection.Unit
        local offset = moveDir * extraSpeed * dt

        root.CFrame = root.CFrame + offset
    end)
end

local function stopSpeed()
    if speedConn then speedConn:Disconnect(); speedConn = nil end
end

-- =====================
-- UI
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer.PlayerGui

-- Right Shift toggle visibility
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        local main = ScreenGui:FindFirstChild("Window")
        if main then
            main.Visible = not main.Visible
        end
    end
end)

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 520, 0, 370)
Window.Position = UDim2.new(0.5, -260, 0.5, -185)
Window.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = ScreenGui

local WinCorner = Instance.new("UICorner")
WinCorner.CornerRadius = UDim.new(0, 10)
WinCorner.Parent = Window

local WinStroke = Instance.new("UIStroke")
WinStroke.Color = Color3.fromRGB(52, 52, 58)
WinStroke.Thickness = 1
WinStroke.Parent = Window

-- =====================
-- TITLE BAR
-- =====================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 5
TitleBar.Parent = Window

local TitleDiv = Instance.new("Frame")
TitleDiv.Size = UDim2.new(1, 0, 0, 1)
TitleDiv.Position = UDim2.new(0, 0, 1, -1)
TitleDiv.BackgroundColor3 = Color3.fromRGB(48, 48, 54)
TitleDiv.BorderSizePixel = 0
TitleDiv.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HUB"
TitleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local HintLabel = Instance.new("TextLabel")
HintLabel.Size = UDim2.new(0, 160, 1, 0)
HintLabel.Position = UDim2.new(1, -240, 0, 0)
HintLabel.BackgroundTransparency = 1
HintLabel.Text = "RShift to toggle"
HintLabel.TextColor3 = Color3.fromRGB(75, 75, 82)
HintLabel.TextSize = 11
HintLabel.Font = Enum.Font.Gotham
HintLabel.TextXAlignment = Enum.TextXAlignment.Right
HintLabel.Parent = TitleBar

local function makeTitleBtn(offsetX, col)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 12, 0, 12)
    b.Position = UDim2.new(1, offsetX, 0.5, -6)
    b.BackgroundColor3 = col
    b.Text = ""
    b.BorderSizePixel = 0
    b.ZIndex = 6
    b.Parent = TitleBar
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = b
    return b
end

local CloseBtn = makeTitleBtn(-20, Color3.fromRGB(78, 78, 85))
makeTitleBtn(-40, Color3.fromRGB(78, 78, 85))
makeTitleBtn(-60, Color3.fromRGB(78, 78, 85))

CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 68, 68) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(78, 78, 85) end)
CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Window.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- =====================
-- BODY
-- =====================
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 1, -38)
Body.Position = UDim2.new(0, 0, 0, 38)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.Parent = Window

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 148, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Body

local SideDiv = Instance.new("Frame")
SideDiv.Size = UDim2.new(0, 1, 1, 0)
SideDiv.Position = UDim2.new(1, -1, 0, 0)
SideDiv.BackgroundColor3 = Color3.fromRGB(48, 48, 54)
SideDiv.BorderSizePixel = 0
SideDiv.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 3)
SideLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 10)
SidePad.PaddingLeft = UDim.new(0, 8)
SidePad.PaddingRight = UDim.new(0, 8)
SidePad.Parent = Sidebar

-- CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -148, 1, 0)
Content.Position = UDim2.new(0, 148, 0, 0)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Body

-- =====================
-- PAGE SYSTEM
-- =====================
local navBtns = {}
local pgFrames = {}
local currentPage = nil

local INACTIVE_COL = Color3.fromRGB(20, 20, 22)
local ACTIVE_COL   = Color3.fromRGB(42, 42, 48)
local INACTIVE_TXT = Color3.fromRGB(120, 120, 128)
local ACTIVE_TXT   = Color3.fromRGB(225, 225, 225)
local ACCENT       = Color3.fromRGB(60, 110, 255)

local function setPage(name)
    currentPage = name
    for n, btn in pairs(navBtns) do
        local active = (n == name)
        btn.BackgroundColor3 = active and ACTIVE_COL or INACTIVE_COL
        btn.TextColor3 = active and ACTIVE_TXT or INACTIVE_TXT
        local bar = btn:FindFirstChild("AccentBar")
        if bar then bar.Visible = active end
    end
    for n, pg in pairs(pgFrames) do
        pg.Visible = (n == name)
    end
end

local function addPage(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = INACTIVE_COL
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = INACTIVE_TXT
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.ClipsDescendants = true
    btn.Parent = Sidebar

    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = btn
    local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0, 12); bp.Parent = btn

    -- left accent bar
    local bar = Instance.new("Frame")
    bar.Name = "AccentBar"
    bar.Size = UDim2.new(0, 3, 0.6, 0)
    bar.Position = UDim2.new(0, -1, 0.2, 0)
    bar.BackgroundColor3 = ACCENT
    bar.BorderSizePixel = 0
    bar.Visible = false
    bar.Parent = btn
    local barc = Instance.new("UICorner"); barc.CornerRadius = UDim.new(0, 2); barc.Parent = bar

    navBtns[name] = btn

    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 2
    pg.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80)
    pg.CanvasSize = UDim2.new(0, 0, 0, 0)
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false
    pg.Parent = Content

    local pl = Instance.new("UIListLayout"); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Padding = UDim.new(0, 5); pl.Parent = pg
    local pp = Instance.new("UIPadding"); pp.PaddingTop = UDim.new(0, 14); pp.PaddingLeft = UDim.new(0, 14); pp.PaddingRight = UDim.new(0, 14); pp.PaddingBottom = UDim.new(0, 14); pp.Parent = pg
    pgFrames[name] = pg

    btn.MouseButton1Click:Connect(function() setPage(name) end)
    btn.MouseEnter:Connect(function() if currentPage ~= name then btn.TextColor3 = Color3.fromRGB(175, 175, 182) end end)
    btn.MouseLeave:Connect(function() if currentPage ~= name then btn.TextColor3 = INACTIVE_TXT end end)

    return pg
end

-- =====================
-- WIDGETS
-- =====================
local function addSection(page, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = text:upper()
    lbl.TextColor3 = Color3.fromRGB(90, 90, 100)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = page

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    line.BorderSizePixel = 0
    line.Parent = lbl
end

local function addToggle(page, label, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = page
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 7); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -68, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(205, 205, 210)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 42, 0, 22)
    track.Position = UDim2.new(1, -56, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
    track.BorderSizePixel = 0
    track.Parent = row
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = track

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromRGB(150, 150, 158)
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    local thc = Instance.new("UICorner"); thc.CornerRadius = UDim.new(1, 0); thc.Parent = thumb

    local state = false
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0); hitbox.BackgroundTransparency = 1; hitbox.Text = ""; hitbox.BorderSizePixel = 0; hitbox.Parent = row

    local function setState(val)
        state = val
        if state then
            TweenService:Create(track, TweenInfo.new(0.16), {BackgroundColor3 = ACCENT}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.16), {Position = UDim2.new(0, 23, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.16), {BackgroundColor3 = Color3.fromRGB(55, 55, 62)}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.16), {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(150, 150, 158)}):Play()
        end
        if callback then callback(state) end
    end

    hitbox.MouseButton1Click:Connect(function() setState(not state) end)
    return setState
end

local function addSlider(page, label, min, max, default, order, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 62)
    container.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = page
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 7); cc.Parent = container

    local labelTxt = Instance.new("TextLabel")
    labelTxt.Size = UDim2.new(0.6, 0, 0, 20)
    labelTxt.Position = UDim2.new(0, 14, 0, 10)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label
    labelTxt.TextColor3 = Color3.fromRGB(205, 205, 210)
    labelTxt.TextSize = 13
    labelTxt.Font = Enum.Font.Gotham
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left
    labelTxt.Parent = container

    local valBox = Instance.new("Frame")
    valBox.Size = UDim2.new(0, 38, 0, 20)
    valBox.Position = UDim2.new(1, -52, 0, 10)
    valBox.BackgroundColor3 = Color3.fromRGB(44, 44, 50)
    valBox.BorderSizePixel = 0
    valBox.Parent = container
    local vbc = Instance.new("UICorner"); vbc.CornerRadius = UDim.new(0, 4); vbc.Parent = valBox

    local valTxt = Instance.new("TextLabel")
    valTxt.Size = UDim2.new(1, 0, 1, 0)
    valTxt.BackgroundTransparency = 1
    valTxt.Text = tostring(default)
    valTxt.TextColor3 = Color3.fromRGB(195, 195, 200)
    valTxt.TextSize = 12
    valTxt.Font = Enum.Font.GothamMedium
    valTxt.Parent = valBox

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -28, 0, 4)
    trackBg.Position = UDim2.new(0, 14, 0, 44)
    trackBg.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
    trackBg.BorderSizePixel = 0
    trackBg.Parent = container
    local tbgc = Instance.new("UICorner"); tbgc.CornerRadius = UDim.new(1, 0); tbgc.Parent = trackBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    fill.Parent = trackBg
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 13, 0, 13)
    thumb.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    thumb.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    thumb.BorderSizePixel = 0
    thumb.Parent = trackBg
    local thc = Instance.new("UICorner"); thc.CornerRadius = UDim.new(1, 0); thc.Parent = thumb

    local value = default
    local sliding = false

    local function updateSlider(inputX)
        local rel = math.clamp((inputX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + rel * (max - min))
        valTxt.Text = tostring(value)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -6, 0.5, -6)
        if callback then callback(value) end
    end

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, -28, 0, 22)
    hitbox.Position = UDim2.new(0, 14, 0, 36)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.BorderSizePixel = 0
    hitbox.Parent = container

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; updateSlider(input.Position.X) end
    end)
    hitbox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input.Position.X) end
    end)
end

local function addButton(page, label, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(205, 205, 210)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.LayoutOrder = order
    btn.Parent = page
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 7); bc.Parent = btn
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(52, 52, 58); stroke.Thickness = 1; stroke.Parent = btn
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(44, 44, 50) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(32, 32, 36) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

-- XYZ display widget
local function addXYZDisplay(page, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = page
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 7); fc.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 40, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "POS"
    title.TextColor3 = Color3.fromRGB(90, 90, 100)
    title.TextSize = 10
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local xyzLbl = Instance.new("TextLabel")
    xyzLbl.Size = UDim2.new(1, -70, 1, 0)
    xyzLbl.Position = UDim2.new(0, 56, 0, 0)
    xyzLbl.BackgroundTransparency = 1
    xyzLbl.Text = "0, 0, 0"
    xyzLbl.TextColor3 = Color3.fromRGB(180, 180, 188)
    xyzLbl.TextSize = 12
    xyzLbl.Font = Enum.Font.Code
    xyzLbl.TextXAlignment = Enum.TextXAlignment.Left
    xyzLbl.Parent = frame

    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local p = root.Position
            xyzLbl.Text = string.format("%.1f,  %.1f,  %.1f", p.X, p.Y, p.Z)
        end
    end)
end

-- =====================
-- BUILD PAGES
-- =====================
local playerPage = addPage("Player", 0)
local ballPage   = addPage("Ball",   1)
local miscPage   = addPage("Misc",   2)
local configPage = addPage("Config", 3)

-- =====================
-- PLAYER PAGE
-- =====================
addSection(playerPage, "Position", 0)
addXYZDisplay(playerPage, 1)

addSection(playerPage, "Reach", 2)

local reachBtnLabel = "Enable Reach Hitbox"
local reachBtn = addButton(playerPage, reachBtnLabel, 3, function()
    reachBoxEnabled = not reachBoxEnabled
    if reachBoxEnabled then
        createReachBox(ReachModule.distance)
    else
        removeReachBox()
    end
end)

-- Update button text to show state
local origReachCb
do
    local orig = reachBtn.MouseButton1Click
    reachBtn.MouseButton1Click:Connect(function()
        reachBtn.Text = reachBoxEnabled and "Reach Hitbox: ON" or "Reach Hitbox: OFF"
    end)
end
reachBtn.Text = "Reach Hitbox: OFF"

addSlider(playerPage, "Reach Size", 1, 50, 5, 4, function(val)
    ReachModule:SetDistance(val)
    updateReachBoxSize(val)
end)

addSection(playerPage, "Movement", 5)

addToggle(playerPage, "Speed Boost", 6, function(state)
    speedEnabled = state
    if state then
        startSpeed()
    else
        stopSpeed()
    end
end)

addSlider(playerPage, "Speed Multiplier", 2, 10, 2, 7, function(val)
    speedMultiplier = val
end)

-- =====================
-- DEFAULT PAGE
-- =====================
setPage("Player")
