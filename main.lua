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
-- REACH BOX
-- =====================
local reachBoxEnabled = false
local reachBoxPart = nil

local function removeReachBox()
    if reachBoxPart and reachBoxPart.Parent then
        reachBoxPart:Destroy()
    end
    reachBoxPart = nil
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
    box.Transparency = 0.8
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Material = Enum.Material.Neon
    box.CFrame = root.CFrame
    box.Parent = workspace

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = box
    weld.Parent = box

    reachBoxPart = box
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
-- UI
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer.PlayerGui

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 500, 0, 360)
Window.Position = UDim2.new(0.5, -250, 0.5, -180)
Window.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = ScreenGui

local WinCorner = Instance.new("UICorner")
WinCorner.CornerRadius = UDim.new(0, 10)
WinCorner.Parent = Window

local WinStroke = Instance.new("UIStroke")
WinStroke.Color = Color3.fromRGB(55, 55, 60)
WinStroke.Thickness = 1
WinStroke.Parent = Window

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Window

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HUB"
TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local TitleDiv = Instance.new("Frame")
TitleDiv.Size = UDim2.new(1, 0, 0, 1)
TitleDiv.Position = UDim2.new(0, 0, 1, -1)
TitleDiv.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
TitleDiv.BorderSizePixel = 0
TitleDiv.Parent = TitleBar

-- Title buttons
local function makeTitleBtn(offsetX, col)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 12, 0, 12)
    b.Position = UDim2.new(1, offsetX, 0.5, -6)
    b.BackgroundColor3 = col
    b.Text = ""
    b.BorderSizePixel = 0
    b.Parent = TitleBar
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = b
    return b
end

local CloseBtn = makeTitleBtn(-22, Color3.fromRGB(80, 80, 85))
makeTitleBtn(-42, Color3.fromRGB(80, 80, 85))
makeTitleBtn(-62, Color3.fromRGB(80, 80, 85))

CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 85) end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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

-- BODY
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 1, -40)
Body.Position = UDim2.new(0, 0, 0, 40)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.Parent = Window

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Body

local SideDiv = Instance.new("Frame")
SideDiv.Size = UDim2.new(0, 1, 1, 0)
SideDiv.Position = UDim2.new(1, -1, 0, 0)
SideDiv.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
SideDiv.BorderSizePixel = 0
SideDiv.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 2)
SideLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 10)
SidePad.PaddingLeft = UDim.new(0, 8)
SidePad.PaddingRight = UDim.new(0, 8)
SidePad.Parent = Sidebar

-- CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -140, 1, 0)
Content.Position = UDim2.new(0, 140, 0, 0)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Body

-- =====================
-- NAV + PAGE SYSTEM
-- =====================
local navBtns = {}
local pgFrames = {}
local currentPage = nil

local function setPage(name)
    currentPage = name
    for n, btn in pairs(navBtns) do
        if n == name then
            btn.BackgroundColor3 = Color3.fromRGB(48, 48, 52)
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        else
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
            btn.TextColor3 = Color3.fromRGB(130, 130, 135)
        end
    end
    for n, pg in pairs(pgFrames) do
        pg.Visible = (n == name)
    end
end

local function addPage(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(130, 130, 135)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.Parent = Sidebar
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,6); bc.Parent = btn
    local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0,10); bp.Parent = btn
    navBtns[name] = btn

    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 2
    pg.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    pg.CanvasSize = UDim2.new(0, 0, 0, 0)
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false
    pg.Parent = Content
    local pl = Instance.new("UIListLayout"); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Padding = UDim.new(0,4); pl.Parent = pg
    local pp = Instance.new("UIPadding"); pp.PaddingTop = UDim.new(0,14); pp.PaddingLeft = UDim.new(0,16); pp.PaddingRight = UDim.new(0,16); pp.PaddingBottom = UDim.new(0,14); pp.Parent = pg
    pgFrames[name] = pg

    btn.MouseButton1Click:Connect(function() setPage(name) end)
    btn.MouseEnter:Connect(function() if currentPage ~= name then btn.TextColor3 = Color3.fromRGB(185,185,190) end end)
    btn.MouseLeave:Connect(function() if currentPage ~= name then btn.TextColor3 = Color3.fromRGB(130,130,135) end end)

    return pg
end

-- =====================
-- WIDGETS
-- =====================
local function addSection(page, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(160, 160, 165)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = page
end

local function addToggle(page, label, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = page
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(210, 210, 215)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 24)
    track.Position = UDim2.new(1, -58, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    track.BorderSizePixel = 0
    track.Parent = row
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1,0); tc.Parent = track

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = UDim2.new(0, 3, 0.5, -9)
    thumb.BackgroundColor3 = Color3.fromRGB(160, 160, 165)
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    local thc = Instance.new("UICorner"); thc.CornerRadius = UDim.new(1,0); thc.Parent = thumb

    local state = false
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1,0,1,0); hitbox.BackgroundTransparency = 1; hitbox.Text = ""; hitbox.BorderSizePixel = 0; hitbox.Parent = row

    local function setState(val)
        state = val
        if state then
            TweenService:Create(track, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(50,100,255)}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.18), {Position = UDim2.new(0,23,0.5,-9), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(60,60,65)}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.18), {Position = UDim2.new(0,3,0.5,-9), BackgroundColor3 = Color3.fromRGB(160,160,165)}):Play()
        end
        if callback then callback(state) end
    end

    hitbox.MouseButton1Click:Connect(function() setState(not state) end)
    return setState
end

local function addSlider(page, label, min, max, default, order, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = page
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,6); cc.Parent = container

    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, -28, 0, 20)
    topRow.Position = UDim2.new(0, 14, 0, 10)
    topRow.BackgroundTransparency = 1
    topRow.BorderSizePixel = 0
    topRow.Parent = container

    local labelTxt = Instance.new("TextLabel")
    labelTxt.Size = UDim2.new(0.65, 0, 1, 0)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label
    labelTxt.TextColor3 = Color3.fromRGB(210, 210, 215)
    labelTxt.TextSize = 13
    labelTxt.Font = Enum.Font.Gotham
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left
    labelTxt.Parent = topRow

    local valBox = Instance.new("Frame")
    valBox.Size = UDim2.new(0, 36, 0, 20)
    valBox.Position = UDim2.new(1, -36, 0, 0)
    valBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    valBox.BorderSizePixel = 0
    valBox.Parent = topRow
    local vbc = Instance.new("UICorner"); vbc.CornerRadius = UDim.new(0,4); vbc.Parent = valBox

    local valTxt = Instance.new("TextLabel")
    valTxt.Size = UDim2.new(1,0,1,0)
    valTxt.BackgroundTransparency = 1
    valTxt.Text = tostring(default)
    valTxt.TextColor3 = Color3.fromRGB(200, 200, 205)
    valTxt.TextSize = 12
    valTxt.Font = Enum.Font.GothamMedium
    valTxt.Parent = valBox

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -28, 0, 4)
    trackBg.Position = UDim2.new(0, 14, 0, 42)
    trackBg.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    trackBg.BorderSizePixel = 0
    trackBg.Parent = container
    local tbgc = Instance.new("UICorner"); tbgc.CornerRadius = UDim.new(1,0); tbgc.Parent = trackBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
    fill.BorderSizePixel = 0
    fill.Parent = trackBg
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = trackBg
    local thc = Instance.new("UICorner"); thc.CornerRadius = UDim.new(1,0); thc.Parent = thumb

    local value = default
    local sliding = false

    local function updateSlider(inputX)
        local rel = math.clamp((inputX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + rel * (max - min))
        valTxt.Text = tostring(value)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -7, 0.5, -7)
        if callback then callback(value) end
    end

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, -28, 0, 20)
    hitbox.Position = UDim2.new(0, 14, 0, 34)
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
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(210, 210, 215)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.LayoutOrder = order
    btn.Parent = page
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,6); bc.Parent = btn
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(60,60,65); stroke.Thickness = 1; stroke.Parent = btn
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(48,48,52) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(35,35,38) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
end

-- =====================
-- PAGES
-- =====================
local playerPage = addPage("Player", 0)
local ballPage   = addPage("Ball",   1)
local miscPage   = addPage("Misc",   2)
local configPage = addPage("Config", 3)

-- PLAYER
addSection(playerPage, "Player Reach", 0)

addButton(playerPage, "Add Reach Hitbox", 1, function()
    reachBoxEnabled = not reachBoxEnabled
    if reachBoxEnabled then
        createReachBox(ReachModule.distance)
    else
        removeReachBox()
    end
end)

addSlider(playerPage, "Reach Size", 1, 50, 5, 2, function(val)
    ReachModule:SetDistance(val)
    updateReachBoxSize(val)
end)

-- =====================
-- DEFAULT
-- =====================
setPage("Player")
