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
        root.CFrame = root.CFrame + hum.MoveDirection.Unit * extraSpeed * dt
    end)
end

local function stopSpeed()
    if speedConn then speedConn:Disconnect(); speedConn = nil end
end

-- =====================
-- SPAWN BALL
-- =====================
local spawnBallKeybind = nil
local bindingKeybind = false

local function spawnBall()
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channels = TextChatService:FindFirstChild("TextChannels")
            if channels then
                local general = channels:FindFirstChild("RBXGeneral")
                if general then general:SendAsync(":pb") end
            end
        else
            local rs = game:GetService("ReplicatedStorage")
            local events = rs:FindFirstChild("DefaultChatSystemChatEvents")
            if events then
                local say = events:FindFirstChild("SayMessageRequest")
                if say then say:FireServer(":pb", "All") end
            end
        end
    end)
end

-- =====================
-- THEME
-- =====================
-- Window background layers
local C_WIN        = Color3.fromRGB(20, 20, 23)       -- outer window
local C_SIDEBAR    = Color3.fromRGB(16, 16, 19)       -- sidebar (darker than window)
local C_CONTENT    = Color3.fromRGB(24, 24, 28)       -- content area (lighter)
local C_ROW        = Color3.fromRGB(30, 30, 35)       -- widget row bg
local C_ROW_HOVER  = Color3.fromRGB(38, 38, 45)       -- widget row hover
local C_DIVIDER    = Color3.fromRGB(40, 40, 46)       -- dividers/strokes

-- Tab states - must contrast against C_SIDEBAR
local C_TAB_OFF    = Color3.fromRGB(16, 16, 19)       -- same as sidebar = blends = text only visible
local C_TAB_ON     = Color3.fromRGB(30, 30, 36)       -- noticeably lighter card
local C_TAB_HOVER  = Color3.fromRGB(24, 24, 29)

-- Text
local C_TXT        = Color3.fromRGB(215, 215, 220)
local C_TXT_DIM    = Color3.fromRGB(110, 110, 122)
local C_TXT_MUTED  = Color3.fromRGB(72, 72, 82)
local C_ACCENT     = Color3.fromRGB(70, 120, 255)
local C_ACCENT_TXT = Color3.fromRGB(140, 170, 255)

-- =====================
-- SCREEN GUI
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer.PlayerGui

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == Enum.KeyCode.RightShift and not bindingKeybind then
        local w = ScreenGui:FindFirstChild("Window")
        if w then w.Visible = not w.Visible end
    end
    if spawnBallKeybind and input.KeyCode == spawnBallKeybind and not bindingKeybind then
        spawnBall()
    end
end)

-- =====================
-- WINDOW
-- =====================
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 530, 0, 380)
Window.Position = UDim2.new(0.5, -265, 0.5, -190)
Window.BackgroundColor3 = C_WIN
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = ScreenGui
Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 10)
local ws = Instance.new("UIStroke", Window); ws.Color = C_DIVIDER; ws.Thickness = 1

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = C_SIDEBAR
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 5
TitleBar.Parent = Window
local tdiv = Instance.new("Frame", TitleBar)
tdiv.Size = UDim2.new(1,0,0,1); tdiv.Position = UDim2.new(0,0,1,-1)
tdiv.BackgroundColor3 = C_DIVIDER; tdiv.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(0,80,1,0); TitleLabel.Position = UDim2.new(0,16,0,0)
TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "HUB"
TitleLabel.TextColor3 = C_TXT; TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local HintLbl = Instance.new("TextLabel", TitleBar)
HintLbl.Size = UDim2.new(0,150,1,0); HintLbl.Position = UDim2.new(1,-218,0,0)
HintLbl.BackgroundTransparency = 1; HintLbl.Text = "RShift  hide / show"
HintLbl.TextColor3 = C_TXT_MUTED; HintLbl.TextSize = 10
HintLbl.Font = Enum.Font.Gotham; HintLbl.TextXAlignment = Enum.TextXAlignment.Right

local function makeDot(ox, col)
    local b = Instance.new("TextButton", TitleBar)
    b.Size = UDim2.new(0,11,0,11); b.Position = UDim2.new(1,ox,0.5,-5)
    b.BackgroundColor3 = col; b.Text = ""; b.BorderSizePixel = 0; b.ZIndex = 6
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    return b
end
local CloseBtn = makeDot(-20, Color3.fromRGB(72,72,80))
makeDot(-38, Color3.fromRGB(72,72,80)); makeDot(-56, Color3.fromRGB(72,72,80))
CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(255,60,60) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(72,72,80) end)
CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)

local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=i.Position; startPos=Window.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

-- =====================
-- BODY (sidebar + content side by side)
-- =====================
local Body = Instance.new("Frame", Window)
Body.Size = UDim2.new(1,0,1,-40); Body.Position = UDim2.new(0,0,0,40)
Body.BackgroundTransparency = 1; Body.BorderSizePixel = 0

-- SIDEBAR FRAME
local Sidebar = Instance.new("Frame", Body)
Sidebar.Size = UDim2.new(0, 148, 1, 0)
Sidebar.BackgroundColor3 = C_SIDEBAR
Sidebar.BorderSizePixel = 0

-- sidebar right edge divider
local sdiv = Instance.new("Frame", Sidebar)
sdiv.Size = UDim2.new(0,1,1,0); sdiv.Position = UDim2.new(1,-1,0,0)
sdiv.BackgroundColor3 = C_DIVIDER; sdiv.BorderSizePixel = 0

-- layout inside sidebar - NO padding on left/right so buttons fill full width
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 2)

local SidePadding = Instance.new("UIPadding", Sidebar)
SidePadding.PaddingTop = UDim.new(0, 8)
SidePadding.PaddingBottom = UDim.new(0, 8)
-- NO left/right padding here - handled per-button with text padding

-- CONTENT FRAME
local Content = Instance.new("Frame", Body)
Content.Size = UDim2.new(1, -148, 1, 0)
Content.Position = UDim2.new(0, 148, 0, 0)
Content.BackgroundColor3 = C_CONTENT
Content.BorderSizePixel = 0
Content.ClipsDescendants = true

-- =====================
-- PAGE SYSTEM
-- =====================
local navBtns = {}
local pgFrames = {}
local currentPage = nil

local function setPage(name)
    currentPage = name
    for n, btn in pairs(navBtns) do
        local on = (n == name)
        TweenService:Create(btn, TweenInfo.new(0.13), {
            BackgroundColor3 = on and C_TAB_ON or C_TAB_OFF
        }):Play()
        btn.TextColor3 = on and C_TXT or C_TXT_DIM
        local bar = btn:FindFirstChild("_bar")
        if bar then bar.Visible = on end
    end
    for n, pg in pairs(pgFrames) do
        pg.Visible = (n == name)
    end
end

local function addPage(name, order)
    -- NAV BUTTON
    -- Full width, text left-padded, background slightly different from sidebar when active
    local btn = Instance.new("TextButton", Sidebar)
    btn.Name = "NavBtn_"..name
    btn.Size = UDim2.new(1, -16, 0, 36)    -- 8px margin each side via position
    btn.Position = UDim2.new(0, 8, 0, 0)
    btn.BackgroundColor3 = C_TAB_OFF
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = name
    btn.TextColor3 = C_TXT_DIM
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.ClipsDescendants = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local bp = Instance.new("UIPadding", btn); bp.PaddingLeft = UDim.new(0, 14)

    -- accent bar on left edge
    local bar = Instance.new("Frame", btn)
    bar.Name = "_bar"
    bar.Size = UDim2.new(0, 3, 0.5, 0)
    bar.Position = UDim2.new(0, 0, 0.25, 0)
    bar.BackgroundColor3 = C_ACCENT
    bar.BorderSizePixel = 0
    bar.Visible = false
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    navBtns[name] = btn

    btn.MouseButton1Click:Connect(function() setPage(name) end)
    btn.MouseEnter:Connect(function()
        if currentPage ~= name then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C_TAB_HOVER}):Play()
            btn.TextColor3 = Color3.fromRGB(170, 170, 180)
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentPage ~= name then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C_TAB_OFF}):Play()
            btn.TextColor3 = C_TXT_DIM
        end
    end)

    -- PAGE SCROLL FRAME
    local pg = Instance.new("ScrollingFrame", Content)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 2
    pg.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    pg.CanvasSize = UDim2.new(0, 0, 0, 0)
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false

    local pl = Instance.new("UIListLayout", pg)
    pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Padding = UDim.new(0, 5)

    local pp = Instance.new("UIPadding", pg)
    pp.PaddingTop = UDim.new(0,14); pp.PaddingLeft = UDim.new(0,14)
    pp.PaddingRight = UDim.new(0,14); pp.PaddingBottom = UDim.new(0,14)

    pgFrames[name] = pg
    return pg
end

-- =====================
-- WIDGET HELPERS
-- =====================
local function addSection(page, text, order)
    local wrap = Instance.new("Frame", page)
    wrap.Size = UDim2.new(1,0,0,28); wrap.BackgroundTransparency = 1
    wrap.BorderSizePixel = 0; wrap.LayoutOrder = order
    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size = UDim2.new(1,0,0,14); lbl.Position = UDim2.new(0,0,0,8)
    lbl.BackgroundTransparency = 1; lbl.Text = text:upper()
    lbl.TextColor3 = C_TXT_MUTED; lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", wrap)
    line.Size = UDim2.new(1,0,0,1); line.Position = UDim2.new(0,0,1,-1)
    line.BackgroundColor3 = C_DIVIDER; line.BorderSizePixel = 0
end

local function addToggle(page, label, order, callback)
    local row = Instance.new("Frame", page)
    row.Size = UDim2.new(1,0,0,44); row.BackgroundColor3 = C_ROW
    row.BorderSizePixel = 0; row.LayoutOrder = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-68,1,0); lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = C_TXT; lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0,42,0,22); track.Position = UDim2.new(1,-56,0.5,-11)
    track.BackgroundColor3 = Color3.fromRGB(50,50,58); track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0,16,0,16); thumb.Position = UDim2.new(0,3,0.5,-8)
    thumb.BackgroundColor3 = Color3.fromRGB(140,140,150); thumb.BorderSizePixel = 0
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)

    local state = false
    local hb = Instance.new("TextButton", row)
    hb.Size = UDim2.new(1,0,1,0); hb.BackgroundTransparency = 1; hb.Text = ""; hb.BorderSizePixel = 0

    local function setState(v)
        state = v
        if state then
            TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = C_ACCENT}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.15), {Position=UDim2.new(0,23,0.5,-8), BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50,50,58)}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.15), {Position=UDim2.new(0,3,0.5,-8), BackgroundColor3=Color3.fromRGB(140,140,150)}):Play()
        end
        if callback then callback(state) end
    end
    hb.MouseButton1Click:Connect(function() setState(not state) end)
    return setState
end

local function addSlider(page, label, minVal, maxVal, default, step, order, callback)
    local container = Instance.new("Frame", page)
    container.Size = UDim2.new(1,0,0,62); container.BackgroundColor3 = C_ROW
    container.BorderSizePixel = 0; container.LayoutOrder = order
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(0.6,0,0,20); lbl.Position = UDim2.new(0,14,0,10)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = C_TXT; lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valBox = Instance.new("Frame", container)
    valBox.Size = UDim2.new(0,44,0,22); valBox.Position = UDim2.new(1,-58,0,8)
    valBox.BackgroundColor3 = Color3.fromRGB(36,36,42); valBox.BorderSizePixel = 0
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 5)

    local valTxt = Instance.new("TextLabel", valBox)
    valTxt.Size = UDim2.new(1,0,1,0); valTxt.BackgroundTransparency = 1
    valTxt.TextColor3 = C_ACCENT_TXT; valTxt.TextSize = 12; valTxt.Font = Enum.Font.GothamMedium
    valTxt.Text = (step < 1) and string.format("%.1f", default) or tostring(default)

    local trackBg = Instance.new("Frame", container)
    trackBg.Size = UDim2.new(1,-28,0,4); trackBg.Position = UDim2.new(0,14,0,44)
    trackBg.BackgroundColor3 = Color3.fromRGB(44,44,50); trackBg.BorderSizePixel = 0
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", trackBg)
    fill.Size = UDim2.new((default-minVal)/(maxVal-minVal),0,1,0)
    fill.BackgroundColor3 = C_ACCENT; fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame", trackBg)
    thumb.Size = UDim2.new(0,13,0,13)
    thumb.Position = UDim2.new((default-minVal)/(maxVal-minVal),-6,0.5,-6)
    thumb.BackgroundColor3 = Color3.fromRGB(235,235,242); thumb.BorderSizePixel = 0
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)

    local value = default
    local sliding = false

    local function update(ix)
        local rel = math.clamp((ix - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        local raw = minVal + rel * (maxVal - minVal)
        value = math.floor(raw / step + 0.5) * step
        value = math.clamp(value, minVal, maxVal)
        local srel = (value - minVal) / (maxVal - minVal)
        valTxt.Text = (step < 1) and string.format("%.1f", value) or tostring(math.floor(value))
        fill.Size = UDim2.new(srel,0,1,0)
        thumb.Position = UDim2.new(srel,-6,0.5,-6)
        if callback then callback(value) end
    end

    local hb = Instance.new("TextButton", container)
    hb.Size = UDim2.new(1,-28,0,24); hb.Position = UDim2.new(0,14,0,36)
    hb.BackgroundTransparency = 1; hb.Text = ""; hb.BorderSizePixel = 0

    hb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding=true; update(i.Position.X) end
    end)
    hb.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end
    end)
end

local function addButton(page, label, order, callback)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(1,0,0,40); btn.BackgroundColor3 = C_ROW
    btn.BorderSizePixel = 0; btn.Text = label; btn.TextColor3 = C_TXT
    btn.TextSize = 13; btn.Font = Enum.Font.Gotham; btn.LayoutOrder = order
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke", btn); s.Color = C_DIVIDER; s.Thickness = 1
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C_ROW_HOVER}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C_ROW}):Play() end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(btn,TweenInfo.new(0.05),{BackgroundColor3=Color3.fromRGB(48,48,56)}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C_ROW_HOVER}):Play() end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

local function addXYZDisplay(page, order)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1,0,0,44); frame.BackgroundColor3 = C_ROW
    frame.BorderSizePixel = 0; frame.LayoutOrder = order
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(0,36,1,0); title.Position = UDim2.new(0,14,0,0)
    title.BackgroundTransparency = 1; title.Text = "POS"
    title.TextColor3 = C_TXT_DIM; title.TextSize = 10
    title.Font = Enum.Font.GothamMedium; title.TextXAlignment = Enum.TextXAlignment.Left

    local sep = Instance.new("Frame", frame)
    sep.Size = UDim2.new(0,1,0.5,0); sep.Position = UDim2.new(0,50,0.25,0)
    sep.BackgroundColor3 = C_DIVIDER; sep.BorderSizePixel = 0

    local xyzLbl = Instance.new("TextLabel", frame)
    xyzLbl.Size = UDim2.new(1,-68,1,0); xyzLbl.Position = UDim2.new(0,58,0,0)
    xyzLbl.BackgroundTransparency = 1; xyzLbl.Text = "0.0,  0.0,  0.0"
    xyzLbl.TextColor3 = C_ACCENT_TXT; xyzLbl.TextSize = 12
    xyzLbl.Font = Enum.Font.Code; xyzLbl.TextXAlignment = Enum.TextXAlignment.Left

    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local p = root.Position
            xyzLbl.Text = string.format("%.1f,  %.1f,  %.1f", p.X, p.Y, p.Z)
        end
    end)
end

local function addSpawnBallWidget(page, order)
    local spawnBtn = Instance.new("TextButton", page)
    spawnBtn.Size = UDim2.new(1,0,0,42); spawnBtn.BackgroundColor3 = Color3.fromRGB(28,45,90)
    spawnBtn.BorderSizePixel = 0; spawnBtn.Text = "Spawn Ball  ( :pb )"
    spawnBtn.TextColor3 = Color3.fromRGB(150,185,255); spawnBtn.TextSize = 13
    spawnBtn.Font = Enum.Font.GothamMedium; spawnBtn.LayoutOrder = order
    spawnBtn.AutoButtonColor = false
    Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0, 7)
    local sbs = Instance.new("UIStroke", spawnBtn); sbs.Color = Color3.fromRGB(50,75,155); sbs.Thickness = 1
    spawnBtn.MouseEnter:Connect(function() TweenService:Create(spawnBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(38,58,110)}):Play() end)
    spawnBtn.MouseLeave:Connect(function() TweenService:Create(spawnBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(28,45,90)}):Play() end)
    spawnBtn.MouseButton1Click:Connect(function() spawnBall() end)

    -- Keybind row
    local krow = Instance.new("Frame", page)
    krow.Size = UDim2.new(1,0,0,44); krow.BackgroundColor3 = C_ROW
    krow.BorderSizePixel = 0; krow.LayoutOrder = order + 1
    Instance.new("UICorner", krow).CornerRadius = UDim.new(0, 7)

    local kLbl = Instance.new("TextLabel", krow)
    kLbl.Size = UDim2.new(0.4,0,1,0); kLbl.Position = UDim2.new(0,14,0,0)
    kLbl.BackgroundTransparency = 1; kLbl.Text = "Keybind"
    kLbl.TextColor3 = C_TXT; kLbl.TextSize = 13
    kLbl.Font = Enum.Font.Gotham; kLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- toggle
    local kEnabled = false
    local kTrack = Instance.new("Frame", krow)
    kTrack.Size = UDim2.new(0,42,0,22); kTrack.Position = UDim2.new(1,-122,0.5,-11)
    kTrack.BackgroundColor3 = Color3.fromRGB(50,50,58); kTrack.BorderSizePixel = 0
    Instance.new("UICorner", kTrack).CornerRadius = UDim.new(1,0)

    local kThumb = Instance.new("Frame", kTrack)
    kThumb.Size = UDim2.new(0,16,0,16); kThumb.Position = UDim2.new(0,3,0.5,-8)
    kThumb.BackgroundColor3 = Color3.fromRGB(140,140,150); kThumb.BorderSizePixel = 0
    Instance.new("UICorner", kThumb).CornerRadius = UDim.new(1,0)

    -- key display button
    local keyBtn = Instance.new("TextButton", krow)
    keyBtn.Size = UDim2.new(0,58,0,26); keyBtn.Position = UDim2.new(1,-68,0.5,-13)
    keyBtn.BackgroundColor3 = Color3.fromRGB(36,36,42); keyBtn.BorderSizePixel = 0
    keyBtn.Text = "None"; keyBtn.TextColor3 = C_TXT_DIM
    keyBtn.TextSize = 11; keyBtn.Font = Enum.Font.GothamMedium
    keyBtn.AutoButtonColor = false
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)
    local kbs = Instance.new("UIStroke", keyBtn); kbs.Color = C_DIVIDER; kbs.Thickness = 1

    local kToggleHb = Instance.new("TextButton", krow)
    kToggleHb.Size = UDim2.new(0,52,0,32); kToggleHb.Position = UDim2.new(1,-130,0.5,-16)
    kToggleHb.BackgroundTransparency = 1; kToggleHb.Text = ""; kToggleHb.BorderSizePixel = 0

    kToggleHb.MouseButton1Click:Connect(function()
        kEnabled = not kEnabled
        if kEnabled then
            TweenService:Create(kTrack,TweenInfo.new(0.15),{BackgroundColor3=C_ACCENT}):Play()
            TweenService:Create(kThumb,TweenInfo.new(0.15),{Position=UDim2.new(0,23,0.5,-8),BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
        else
            TweenService:Create(kTrack,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(50,50,58)}):Play()
            TweenService:Create(kThumb,TweenInfo.new(0.15),{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=Color3.fromRGB(140,140,150)}):Play()
            spawnBallKeybind = nil; keyBtn.Text = "None"; keyBtn.TextColor3 = C_TXT_DIM; kbs.Color = C_DIVIDER
        end
    end)

    keyBtn.MouseButton1Click:Connect(function()
        if not kEnabled then return end
        bindingKeybind = true
        keyBtn.Text = "..."; keyBtn.TextColor3 = Color3.fromRGB(255,210,70); kbs.Color = Color3.fromRGB(160,130,40)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.RightShift then return end
                spawnBallKeybind = input.KeyCode
                local kname = tostring(input.KeyCode):gsub("Enum%.KeyCode%.", "")
                keyBtn.Text = kname; keyBtn.TextColor3 = C_ACCENT_TXT; kbs.Color = C_ACCENT
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

-- PLAYER
addSection(playerPage, "Position", 0)
addXYZDisplay(playerPage, 1)

addSection(playerPage, "Movement", 2)
addToggle(playerPage, "Speed Boost", 3, function(state)
    speedEnabled = state
    if state then startSpeed() else stopSpeed() end
end)
addSlider(playerPage, "Speed Multiplier", 1.0, 2.0, 1.2, 0.1, 4, function(val) speedMultiplier = val end)

addSection(playerPage, "Reach", 5)
local reachBtn = addButton(playerPage, "Reach Hitbox:  OFF", 6, nil)
reachBtn.MouseButton1Click:Connect(function()
    reachBoxEnabled = not reachBoxEnabled
    if reachBoxEnabled then createReachBox(ReachModule.distance) else removeReachBox() end
    reachBtn.Text = reachBoxEnabled and "Reach Hitbox:  ON" or "Reach Hitbox:  OFF"
end)
addSlider(playerPage, "Reach Size", 1, 50, 5, 1, 7, function(val)
    ReachModule:SetDistance(val); updateReachBoxSize(val)
end)

-- BALL
addSection(ballPage, "Ball", 0)
addSpawnBallWidget(ballPage, 1)

-- ACTIVATE
setPage("Player")
