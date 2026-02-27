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
local reachBoxWeld = nil
local reachBoxConn = nil

local function removeReachBox()
    if reachBoxConn then reachBoxConn:Disconnect(); reachBoxConn = nil end
    if reachBoxPart and reachBoxPart.Parent then reachBoxPart:Destroy() end
    reachBoxPart = nil; reachBoxWeld = nil
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
    weld.Part0 = root; weld.Part1 = box; weld.Parent = box
    reachBoxPart = box; reachBoxWeld = weld
    reachBoxConn = RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r or not reachBoxPart or not reachBoxPart.Parent then return end
        if not reachBoxWeld or not reachBoxWeld.Parent then
            local w = Instance.new("WeldConstraint")
            w.Part0 = r; w.Part1 = reachBoxPart; w.Parent = reachBoxPart
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
    if reachBoxEnabled then task.wait(1); createReachBox(ReachModule.distance) end
end)

-- =====================
-- SPEED BOOST
-- =====================
local speedEnabled = false
local speedMultiplier = 1.2
local speedConn = nil

local function startSpeed()
    if speedConn then return end
    speedConn = RunService.Heartbeat:Connect(function(dt)
        if not speedEnabled then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.MoveDirection.Magnitude == 0 then return end
        local extraSpeed = hum.WalkSpeed * (speedMultiplier - 1)
        local offset = hum.MoveDirection.Unit * extraSpeed * dt
        root.CFrame = root.CFrame + offset
    end)
end

local function stopSpeed()
    if speedConn then speedConn:Disconnect(); speedConn = nil end
end

-- =====================
-- SPAWN BALL (:pb in chat)
-- =====================
local spawnBallKeybind = nil  -- nil = no keybind set
local bindingKeybind = false  -- true when listening for next key press

local function spawnBall()
    local VCS = game:GetService("VirtualChatService") or nil
    -- Use the chat bar to type :pb
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        -- Method: fire the TextChatService / legacy chat
        local TextChatService = game:GetService("TextChatService")
        if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            -- New chat system
            local channel = TextChatService:FindFirstChild("TextChannels")
            if channel then
                local rbxGeneral = channel:FindFirstChild("RBXGeneral")
                if rbxGeneral then
                    rbxGeneral:SendAsync(":pb")
                end
            end
        else
            -- Legacy chat
            game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                :FindFirstChild("SayMessageRequest")
                :FireServer(":pb", "All")
        end
    end)
end

-- =====================
-- UI THEME
-- =====================
local ACCENT     = Color3.fromRGB(65, 115, 255)
local BG         = Color3.fromRGB(18, 18, 20)
local PANEL      = Color3.fromRGB(24, 24, 27)
local SIDEBAR    = Color3.fromRGB(20, 20, 23)
local ROW        = Color3.fromRGB(30, 30, 34)
local ROW_HOVER  = Color3.fromRGB(36, 36, 42)
local DIVIDER    = Color3.fromRGB(42, 42, 48)
local TXT_MAIN   = Color3.fromRGB(220, 220, 225)
local TXT_DIM    = Color3.fromRGB(105, 105, 115)
local TXT_ACCENT = Color3.fromRGB(130, 160, 255)

-- =====================
-- SCREEN GUI
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer.PlayerGui

-- Right Shift toggle
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        -- keybind for spawn ball
        if spawnBallKeybind and input.KeyCode == spawnBallKeybind and not bindingKeybind then
            spawnBall()
        end
        -- right shift
        if input.KeyCode == Enum.KeyCode.RightShift and not bindingKeybind then
            local w = ScreenGui:FindFirstChild("Window")
            if w then w.Visible = not w.Visible end
        end
    end
end)

-- WINDOW
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 530, 0, 380)
Window.Position = UDim2.new(0.5, -265, 0.5, -190)
Window.BackgroundColor3 = BG
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = ScreenGui

local WinCorner = Instance.new("UICorner"); WinCorner.CornerRadius = UDim.new(0, 10); WinCorner.Parent = Window
local WinStroke = Instance.new("UIStroke"); WinStroke.Color = DIVIDER; WinStroke.Thickness = 1; WinStroke.Parent = Window

-- =====================
-- TITLE BAR
-- =====================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = SIDEBAR
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 5
TitleBar.Parent = Window

local TitleDiv = Instance.new("Frame")
TitleDiv.Size = UDim2.new(1, 0, 0, 1)
TitleDiv.Position = UDim2.new(0, 0, 1, -1)
TitleDiv.BackgroundColor3 = DIVIDER
TitleDiv.BorderSizePixel = 0
TitleDiv.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 100, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HUB"
TitleLabel.TextColor3 = TXT_MAIN
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local HintLabel = Instance.new("TextLabel")
HintLabel.Size = UDim2.new(0, 130, 1, 0)
HintLabel.Position = UDim2.new(1, -200, 0, 0)
HintLabel.BackgroundTransparency = 1
HintLabel.Text = "RShift  hide/show"
HintLabel.TextColor3 = TXT_DIM
HintLabel.TextSize = 10
HintLabel.Font = Enum.Font.Gotham
HintLabel.TextXAlignment = Enum.TextXAlignment.Right
HintLabel.Parent = TitleBar

local function makeTitleBtn(offsetX, col)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 11, 0, 11)
    b.Position = UDim2.new(1, offsetX, 0.5, -5)
    b.BackgroundColor3 = col
    b.Text = ""; b.BorderSizePixel = 0; b.ZIndex = 6
    b.Parent = TitleBar
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = b
    return b
end

local CloseBtn = makeTitleBtn(-20, Color3.fromRGB(75, 75, 83))
makeTitleBtn(-38, Color3.fromRGB(75, 75, 83))
makeTitleBtn(-56, Color3.fromRGB(75, 75, 83))

CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 65, 65) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 83) end)
CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = Window.Position end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- =====================
-- BODY
-- =====================
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 1, -40)
Body.Position = UDim2.new(0, 0, 0, 40)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.Parent = Window

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Body

local SideDiv = Instance.new("Frame")
SideDiv.Size = UDim2.new(0, 1, 1, 0)
SideDiv.Position = UDim2.new(1, -1, 0, 0)
SideDiv.BackgroundColor3 = DIVIDER
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

-- CONTENT AREA
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, 0)
Content.Position = UDim2.new(0, 150, 0, 0)
Content.BackgroundColor3 = PANEL
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Body

-- =====================
-- PAGE SYSTEM
-- =====================
local navBtns = {}
local pgFrames = {}
local currentPage = nil

local function setPage(name)
    currentPage = name
    for n, btn in pairs(navBtns) do
        local active = (n == name)
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = active and ROW or SIDEBAR,
            TextColor3 = active and TXT_MAIN or TXT_DIM
        }):Play()
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
    btn.BackgroundColor3 = SIDEBAR
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = TXT_DIM
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.ClipsDescendants = true
    btn.Parent = Sidebar

    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = btn
    local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0, 14); bp.Parent = btn

    local bar = Instance.new("Frame")
    bar.Name = "AccentBar"
    bar.Size = UDim2.new(0, 3, 0.55, 0)
    bar.Position = UDim2.new(0, 0, 0.225, 0)
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
    pg.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 75)
    pg.CanvasSize = UDim2.new(0, 0, 0, 0)
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false
    pg.Parent = Content

    local pl = Instance.new("UIListLayout"); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Padding = UDim.new(0, 5); pl.Parent = pg
    local pp = Instance.new("UIPadding"); pp.PaddingTop = UDim.new(0, 14); pp.PaddingLeft = UDim.new(0, 14); pp.PaddingRight = UDim.new(0, 14); pp.PaddingBottom = UDim.new(0, 14); pp.Parent = pg
    pgFrames[name] = pg

    btn.MouseButton1Click:Connect(function() setPage(name) end)
    btn.MouseEnter:Connect(function() if currentPage ~= name then btn.TextColor3 = Color3.fromRGB(175, 175, 185) end end)
    btn.MouseLeave:Connect(function() if currentPage ~= name then btn.TextColor3 = TXT_DIM end end)

    return pg
end

-- =====================
-- WIDGETS
-- =====================
local function addSection(page, text, order)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, 0, 0, 26)
    wrap.BackgroundTransparency = 1
    wrap.BorderSizePixel = 0
    wrap.LayoutOrder = order
    wrap.Parent = page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.Position = UDim2.new(0, 0, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = text:upper()
    lbl.TextColor3 = TXT_DIM
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = wrap

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = DIVIDER
    line.BorderSizePixel = 0
    line.Parent = wrap
end

local function addToggle(page, label, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = ROW
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = page
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 7); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -68, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = TXT_MAIN
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 42, 0, 22)
    track.Position = UDim2.new(1, -56, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(52, 52, 60)
    track.BorderSizePixel = 0
    track.Parent = row
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = track

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromRGB(145, 145, 155)
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    local thc = Instance.new("UICorner"); thc.CornerRadius = UDim.new(1, 0); thc.Parent = thumb

    local state = false
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0); hitbox.BackgroundTransparency = 1; hitbox.Text = ""; hitbox.BorderSizePixel = 0; hitbox.Parent = row

    local function setState(val)
        state = val
        if state then
            TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.15), {Position = UDim2.new(0, 23, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(52, 52, 60)}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.15), {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(145, 145, 155)}):Play()
        end
        if callback then callback(state) end
    end

    hitbox.MouseButton1Click:Connect(function() setState(not state) end)
    return setState
end

local function addSlider(page, label, minVal, maxVal, default, step, order, callback)
    step = step or 1
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 62)
    container.BackgroundColor3 = ROW
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = page
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 7); cc.Parent = container

    local labelTxt = Instance.new("TextLabel")
    labelTxt.Size = UDim2.new(0.6, 0, 0, 20)
    labelTxt.Position = UDim2.new(0, 14, 0, 10)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label
    labelTxt.TextColor3 = TXT_MAIN
    labelTxt.TextSize = 13
    labelTxt.Font = Enum.Font.Gotham
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left
    labelTxt.Parent = container

    local valBox = Instance.new("Frame")
    valBox.Size = UDim2.new(0, 42, 0, 22)
    valBox.Position = UDim2.new(1, -56, 0, 8)
    valBox.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    valBox.BorderSizePixel = 0
    valBox.Parent = container
    local vbc = Instance.new("UICorner"); vbc.CornerRadius = UDim.new(0, 5); vbc.Parent = valBox

    local valTxt = Instance.new("TextLabel")
    valTxt.Size = UDim2.new(1, 0, 1, 0)
    valTxt.BackgroundTransparency = 1
    valTxt.Text = tostring(default)
    valTxt.TextColor3 = TXT_ACCENT
    valTxt.TextSize = 12
    valTxt.Font = Enum.Font.GothamMedium
    valTxt.Parent = valBox

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -28, 0, 4)
    trackBg.Position = UDim2.new(0, 14, 0, 44)
    trackBg.BackgroundColor3 = Color3.fromRGB(46, 46, 52)
    trackBg.BorderSizePixel = 0
    trackBg.Parent = container
    local tbgc = Instance.new("UICorner"); tbgc.CornerRadius = UDim.new(1, 0); tbgc.Parent = trackBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    fill.Parent = trackBg
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 13, 0, 13)
    thumb.Position = UDim2.new((default - minVal) / (maxVal - minVal), -6, 0.5, -6)
    thumb.BackgroundColor3 = Color3.fromRGB(235, 235, 242)
    thumb.BorderSizePixel = 0
    thumb.Parent = trackBg
    local thc = Instance.new("UICorner"); thc.CornerRadius = UDim.new(1, 0); thc.Parent = thumb

    local value = default
    local sliding = false

    local function updateSlider(inputX)
        local rel = math.clamp((inputX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        local raw = minVal + rel * (maxVal - minVal)
        value = math.floor(raw / step + 0.5) * step
        value = math.clamp(value, minVal, maxVal)
        -- format: if step < 1, show decimals
        local fmt = (step < 1) and string.format("%.1f", value) or tostring(math.floor(value))
        valTxt.Text = fmt
        local snappedRel = (value - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(snappedRel, 0, 1, 0)
        thumb.Position = UDim2.new(snappedRel, -6, 0.5, -6)
        if callback then callback(value) end
    end

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, -28, 0, 22)
    hitbox.Position = UDim2.new(0, 14, 0, 36)
    hitbox.BackgroundTransparency = 1; hitbox.Text = ""; hitbox.BorderSizePixel = 0
    hitbox.Parent = container

    hitbox.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; updateSlider(i.Position.X) end
    end)
    hitbox.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(i.Position.X) end
    end)
end

local function addButton(page, label, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = ROW
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = TXT_MAIN
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.LayoutOrder = order
    btn.Parent = page
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 7); bc.Parent = btn
    local stroke = Instance.new("UIStroke"); stroke.Color = DIVIDER; stroke.Thickness = 1; stroke.Parent = btn
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = ROW_HOVER}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = ROW}):Play() end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(50, 50, 58)}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = ROW_HOVER}):Play() end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

local function addXYZDisplay(page, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundColor3 = ROW
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = page
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 7); fc.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 36, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "POS"
    title.TextColor3 = TXT_DIM
    title.TextSize = 10
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0, 1, 0.5, 0)
    sep.Position = UDim2.new(0, 50, 0.25, 0)
    sep.BackgroundColor3 = DIVIDER
    sep.BorderSizePixel = 0
    sep.Parent = frame

    local xyzLbl = Instance.new("TextLabel")
    xyzLbl.Size = UDim2.new(1, -70, 1, 0)
    xyzLbl.Position = UDim2.new(0, 58, 0, 0)
    xyzLbl.BackgroundTransparency = 1
    xyzLbl.Text = "0.0,  0.0,  0.0"
    xyzLbl.TextColor3 = TXT_ACCENT
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

-- Spawn ball widget with keybind setter
local function addSpawnBallWidget(page, order)
    -- Main spawn button
    local spawnBtn = Instance.new("TextButton")
    spawnBtn.Size = UDim2.new(1, 0, 0, 42)
    spawnBtn.BackgroundColor3 = Color3.fromRGB(38, 55, 95)
    spawnBtn.BorderSizePixel = 0
    spawnBtn.Text = "Spawn Ball  ( :pb )"
    spawnBtn.TextColor3 = Color3.fromRGB(160, 190, 255)
    spawnBtn.TextSize = 13
    spawnBtn.Font = Enum.Font.GothamMedium
    spawnBtn.LayoutOrder = order
    spawnBtn.Parent = page
    local sbc = Instance.new("UICorner"); sbc.CornerRadius = UDim.new(0, 7); sbc.Parent = spawnBtn
    local sbs = Instance.new("UIStroke"); sbs.Color = Color3.fromRGB(55, 80, 160); sbs.Thickness = 1; sbs.Parent = spawnBtn

    spawnBtn.MouseEnter:Connect(function() TweenService:Create(spawnBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(48, 68, 118)}):Play() end)
    spawnBtn.MouseLeave:Connect(function() TweenService:Create(spawnBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(38, 55, 95)}):Play() end)
    spawnBtn.MouseButton1Click:Connect(function() spawnBall() end)

    -- Keybind row
    local keybindRow = Instance.new("Frame")
    keybindRow.Size = UDim2.new(1, 0, 0, 44)
    keybindRow.BackgroundColor3 = ROW
    keybindRow.BorderSizePixel = 0
    keybindRow.LayoutOrder = order + 1
    keybindRow.Parent = page
    local krc = Instance.new("UICorner"); krc.CornerRadius = UDim.new(0, 7); krc.Parent = keybindRow

    local kLabel = Instance.new("TextLabel")
    kLabel.Size = UDim2.new(0.5, 0, 1, 0)
    kLabel.Position = UDim2.new(0, 14, 0, 0)
    kLabel.BackgroundTransparency = 1
    kLabel.Text = "Keybind"
    kLabel.TextColor3 = TXT_MAIN
    kLabel.TextSize = 13
    kLabel.Font = Enum.Font.Gotham
    kLabel.TextXAlignment = Enum.TextXAlignment.Left
    kLabel.Parent = keybindRow

    -- keybind toggle
    local keybindEnabled = false
    local kToggleTrack = Instance.new("Frame")
    kToggleTrack.Size = UDim2.new(0, 42, 0, 22)
    kToggleTrack.Position = UDim2.new(1, -130, 0.5, -11)
    kToggleTrack.BackgroundColor3 = Color3.fromRGB(52, 52, 60)
    kToggleTrack.BorderSizePixel = 0
    kToggleTrack.Parent = keybindRow
    local kttc = Instance.new("UICorner"); kttc.CornerRadius = UDim.new(1, 0); kttc.Parent = kToggleTrack

    local kToggleThumb = Instance.new("Frame")
    kToggleThumb.Size = UDim2.new(0, 16, 0, 16)
    kToggleThumb.Position = UDim2.new(0, 3, 0.5, -8)
    kToggleThumb.BackgroundColor3 = Color3.fromRGB(145, 145, 155)
    kToggleThumb.BorderSizePixel = 0
    kToggleThumb.Parent = kToggleTrack
    local ktthumbc = Instance.new("UICorner"); ktthumbc.CornerRadius = UDim.new(1, 0); ktthumbc.Parent = kToggleThumb

    -- keybind button (shows current key)
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 60, 0, 26)
    keyBtn.Position = UDim2.new(1, -68, 0.5, -13)
    keyBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = "None"
    keyBtn.TextColor3 = TXT_DIM
    keyBtn.TextSize = 11
    keyBtn.Font = Enum.Font.GothamMedium
    keyBtn.Parent = keybindRow
    local kbc = Instance.new("UICorner"); kbc.CornerRadius = UDim.new(0, 5); kbc.Parent = keyBtn
    local kbs = Instance.new("UIStroke"); kbs.Color = DIVIDER; kbs.Thickness = 1; kbs.Parent = keyBtn

    -- toggle keybind on/off
    local kToggleHitbox = Instance.new("TextButton")
    kToggleHitbox.Size = UDim2.new(0, 52, 0, 30)
    kToggleHitbox.Position = UDim2.new(1, -138, 0.5, -15)
    kToggleHitbox.BackgroundTransparency = 1; kToggleHitbox.Text = ""; kToggleHitbox.BorderSizePixel = 0
    kToggleHitbox.Parent = keybindRow

    kToggleHitbox.MouseButton1Click:Connect(function()
        keybindEnabled = not keybindEnabled
        if keybindEnabled then
            TweenService:Create(kToggleTrack, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
            TweenService:Create(kToggleThumb, TweenInfo.new(0.15), {Position = UDim2.new(0, 23, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(kToggleTrack, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(52, 52, 60)}):Play()
            TweenService:Create(kToggleThumb, TweenInfo.new(0.15), {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(145, 145, 155)}):Play()
            -- when disabled, clear keybind
            spawnBallKeybind = nil
            keyBtn.Text = "None"
            keyBtn.TextColor3 = TXT_DIM
        end
    end)

    -- click keyBtn to set keybind
    keyBtn.MouseButton1Click:Connect(function()
        if not keybindEnabled then return end
        bindingKeybind = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = Color3.fromRGB(255, 210, 80)
        kbs.Color = Color3.fromRGB(160, 130, 40)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                -- ignore RightShift (reserved)
                if input.KeyCode == Enum.KeyCode.RightShift then return end
                spawnBallKeybind = input.KeyCode
                keyBtn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                keyBtn.TextColor3 = TXT_ACCENT
                kbs.Color = ACCENT
                bindingKeybind = false
                conn:Disconnect()
            end
        end)
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

addSection(playerPage, "Movement", 2)

addToggle(playerPage, "Speed Boost", 3, function(state)
    speedEnabled = state
    if state then startSpeed() else stopSpeed() end
end)

addSlider(playerPage, "Speed Multiplier", 1.0, 2.0, 1.2, 0.1, 4, function(val)
    speedMultiplier = val
end)

addSection(playerPage, "Reach", 5)

local reachBtn = addButton(playerPage, "Reach Hitbox:  OFF", 6, function()
    reachBoxEnabled = not reachBoxEnabled
    if reachBoxEnabled then
        createReachBox(ReachModule.distance)
    else
        removeReachBox()
    end
end)

reachBtn.MouseButton1Click:Connect(function()
    reachBtn.Text = reachBoxEnabled and "Reach Hitbox:  ON" or "Reach Hitbox:  OFF"
end)

addSlider(playerPage, "Reach Size", 1, 50, 5, 1, 7, function(val)
    ReachModule:SetDistance(val)
    updateReachBoxSize(val)
end)

-- =====================
-- BALL PAGE
-- =====================
addSection(ballPage, "Ball", 0)
addSpawnBallWidget(ballPage, 1)

-- =====================
-- DEFAULT PAGE
-- =====================
setPage("Player")
