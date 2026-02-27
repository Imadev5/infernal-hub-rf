local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- =====================
-- REACH MODULE
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
local C_WIN        = Color3.fromRGB(20, 20, 23)
local C_SIDEBAR    = Color3.fromRGB(16, 16, 19)
local C_CONTENT    = Color3.fromRGB(24, 24, 28)
local C_ROW        = Color3.fromRGB(30, 30, 35)
local C_ROW_HOVER  = Color3.fromRGB(38, 38, 45)
local C_DIVIDER    = Color3.fromRGB(40, 40, 46)

local C_TAB_OFF    = Color3.fromRGB(16, 16, 19)
local C_TAB_ON     = Color3.fromRGB(30, 30, 36)
local C_TAB_HOVER  = Color3.fromRGB(24, 24, 29)

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

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(0,80,1,0); TitleLabel.Position = UDim2.new(0,16,0,0)
TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "HUB"
TitleLabel.TextColor3 = C_TXT; TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Dragging Logic
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
-- BODY
-- =====================
local Body = Instance.new("Frame", Window)
Body.Size = UDim2.new(1,0,1,-40); Body.Position = UDim2.new(0,0,0,40)
Body.BackgroundTransparency = 1

local Sidebar = Instance.new("Frame", Body)
Sidebar.Size = UDim2.new(0, 148, 1, 0)
Sidebar.BackgroundColor3 = C_SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 4)

-- Fixed Padding for Sidebar
local SidePadding = Instance.new("UIPadding", Sidebar)
SidePadding.PaddingTop = UDim.new(0, 10)
SidePadding.PaddingLeft = UDim.new(0, 8)
SidePadding.PaddingRight = UDim.new(0, 8)

local Content = Instance.new("Frame", Body)
Content.Size = UDim2.new(1, -148, 1, 0)
Content.Position = UDim2.new(0, 148, 0, 0)
Content.BackgroundColor3 = C_CONTENT
Content.BorderSizePixel = 0

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
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and C_TAB_ON or C_TAB_OFF
        }):Play()
        btn.TextColor3 = on and C_TXT or C_TXT_DIM
        btn:FindFirstChild("_bar").Visible = on
    end
    for n, pg in pairs(pgFrames) do
        pg.Visible = (n == name)
    end
end

local function addPage(name, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Name = "NavBtn_"..name
    btn.Size = UDim2.new(1, 0, 0, 34) -- Uses 1 scale because Sidebar has UIPadding
    btn.BackgroundColor3 = C_TAB_OFF
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = name
    btn.TextColor3 = C_TXT_DIM
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local bp = Instance.new("UIPadding", btn)
    bp.PaddingLeft = UDim.new(0, 12)

    local bar = Instance.new("Frame", btn)
    bar.Name = "_bar"
    bar.Size = UDim2.new(0, 3, 0.4, 0)
    bar.Position = UDim2.new(0, -12, 0.3, 0) -- Positioned relative to the button's padding
    bar.BackgroundColor3 = C_ACCENT
    bar.BorderSizePixel = 0
    bar.Visible = false
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    navBtns[name] = btn
    btn.MouseButton1Click:Connect(function() setPage(name) end)

    local pg = Instance.new("ScrollingFrame", Content)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 2
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false

    local pl = Instance.new("UIListLayout", pg)
    pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Padding = UDim.new(0, 6)

    local pp = Instance.new("UIPadding", pg)
    pp.PaddingTop = UDim.new(0,15); pp.PaddingLeft = UDim.new(0,15); pp.PaddingRight = UDim.new(0,15)

    pgFrames[name] = pg
    return pg
end

-- =====================
-- WIDGETS
-- =====================
local function addSection(page, text, order)
    local wrap = Instance.new("Frame", page)
    wrap.Size = UDim2.new(1,0,0,25); wrap.BackgroundTransparency = 1
    wrap.LayoutOrder = order
    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = text:upper(); lbl.TextColor3 = C_TXT_MUTED
    lbl.TextSize = 10; lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function addToggle(page, label, order, callback)
    local row = Instance.new("Frame", page)
    row.Size = UDim2.new(1,0,0,40); row.BackgroundColor3 = C_ROW
    row.BorderSizePixel = 0; row.LayoutOrder = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C_TXT
    lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0,36,0,18); track.Position = UDim2.new(1,-48,0.5,-9)
    track.BackgroundColor3 = Color3.fromRGB(45,45,52)
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0,12,0,12); thumb.Position = UDim2.new(0,3,0.5,-6)
    thumb.BackgroundColor3 = Color3.fromRGB(120,120,130)
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)

    local state = false
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = state and C_ACCENT or Color3.fromRGB(45,45,52)}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.15), {Position = state and UDim2.new(0,21,0.5,-6) or UDim2.new(0,3,0.5,-6)}):Play()
        callback(state)
    end)
end

local function addSlider(page, label, min, max, def, step, order, callback)
    local row = Instance.new("Frame", page)
    row.Size = UDim2.new(1,0,0,55); row.BackgroundColor3 = C_ROW; row.LayoutOrder = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-24,0,25); lbl.Position = UDim2.new(0,12,0,5)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C_TXT
    lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size = UDim2.new(0,40,0,25); valLbl.Position = UDim2.new(1,-52,0,5)
    valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(def); valLbl.TextColor3 = C_ACCENT_TXT
    valLbl.TextSize = 12; valLbl.Font = Enum.Font.GothamBold; valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bg = Instance.new("Frame", row)
    bg.Size = UDim2.new(1,-24,0,4); bg.Position = UDim2.new(0,12,0,38)
    bg.BackgroundColor3 = Color3.fromRGB(45,45,52)
    
    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = C_ACCENT
    
    local trigger = Instance.new("TextButton", row)
    trigger.Size = UDim2.new(1,0,0,20); trigger.Position = UDim2.new(0,0,0,30)
    trigger.BackgroundTransparency = 1; trigger.Text = ""

    local function update(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local val = math.floor(((pos * (max - min)) + min) / step + 0.5) * step
        valLbl.Text = tostring(val)
        fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
        callback(val)
    end

    local dragging = false
    trigger.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(i) end end)
    trigger.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
end

-- =====================
-- BUILD UI
-- =====================
local pPage = addPage("Player", 1)
local bPage = addPage("Ball", 2)
local mPage = addPage("Misc", 3)

addSection(pPage, "Movement", 1)
addToggle(pPage, "Speed Boost", 2, function(v) speedEnabled = v if v then startSpeed() else stopSpeed() end end)
addSlider(pPage, "Speed Multiplier", 1, 3, 1.2, 0.1, 3, function(v) speedMultiplier = v end)

addSection(pPage, "Reach", 4)
addToggle(pPage, "Enable Reach", 5, function(v) ReachModule.enabled = v end)
addSlider(pPage, "Reach Distance", 1, 50, 5, 1, 6, function(v) ReachModule.distance = v; updateReachBoxSize(v) end)

addSection(bPage, "Actions", 1)
local spawnBtn = Instance.new("TextButton", bPage)
spawnBtn.Size = UDim2.new(1,0,0,40); spawnBtn.BackgroundColor3 = C_ROW
spawnBtn.Text = "Spawn Ball (:pb)"; spawnBtn.TextColor3 = C_ACCENT_TXT
spawnBtn.Font = Enum.Font.GothamBold; spawnBtn.TextSize = 13
Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0,6)
spawnBtn.MouseButton1Click:Connect(spawnBall)

setPage("Player")

