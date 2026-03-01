 local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled

pcall(function()
    local container = gethui and gethui() or CoreGui
    local old = container:FindFirstChild("EZHUB")
    if old then old:Destroy() end
end)

local reachOn = false
local reachDist = 5
local staminaOn = false
local staminaConn = nil
local jumpBoostOn = false
local jumpPower = 50
local speedBoostOn = false
local speedMultiplier = 2
local autoGoalOn = false
local targetNet = "Home"
local goalPower = 50
local originalJumpPower = 50
local jumpConn = nil
local jumpCharConn = nil
local speedConn = nil
local kickButtonHooked = false
local reachBoxTransparency = 0.8
local reachBoxPart = nil
local reachBoxWeld = nil
local reachBoxConn = nil
local breakReactOn = false
local breakReactConn = nil
local allConnections = {}
local activeSlider = nil

local function trackConn(conn)
    if conn then table.insert(allConnections, conn) end
    return conn
end

do
    pcall(function()
        for _, v in ipairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "overlapCheck") and rawget(v, "gkCheck") then
                hookfunction(v.overlapCheck, function() return true end)
                hookfunction(v.gkCheck, function() return true end)
            end
        end
    end)
end

local function fireTouch(ball, limb)
    if not firetouchinterest then return end
    if not ball or not ball.Parent then return end
    firetouchinterest(ball, limb, 0)
    task.wait(0.03)
    firetouchinterest(ball, limb, 1)
end

local function fireTouchInstant(ball, limb)
    if not firetouchinterest then return end
    if not ball or not ball.Parent then return end
    if not limb or not limb.Parent then return end
    firetouchinterest(ball, limb, 0)
    firetouchinterest(ball, limb, 1)
end

local function isInsideBox(ballPos, rootPos, dist)
    local diff = ballPos - rootPos
    return math.abs(diff.X) <= dist and math.abs(diff.Y) <= dist and math.abs(diff.Z) <= dist
end

local ReachModule = {
    enabled = false,
    distance = 5,
    connection = nil,
    cachedBalls = {},
    lastUpdate = 0,
    cachedLimbs = {},
    lastChar = nil
}

local function refreshBallCache()
    local balls = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj:FindFirstChild("network") then
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
        local now = tick()
        if now - self.lastUpdate > 1 or char ~= self.lastChar then
            self.cachedBalls = refreshBallCache()
            self.cachedLimbs = {}
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    table.insert(self.cachedLimbs, part)
                end
            end
            self.lastUpdate = now
            self.lastChar = char
        end
        local rootPos = root.Position
        local dist = self.distance
        for _, ball in ipairs(self.cachedBalls) do
            if ball and ball.Parent then
                if isInsideBox(ball.Position, rootPos, dist) then
                    for _, limb in ipairs(self.cachedLimbs) do
                        task.spawn(fireTouch, ball, limb)
                    end
                end
            end
        end
    end)
    trackConn(self.connection)
end

function ReachModule:Stop()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

function ReachModule:SetDistance(dist)
    self.distance = dist
    reachDist = dist
end

function ReachModule:Toggle(state)
    self.enabled = state
    if state then self:Start() else self:Stop() end
end

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
    box.Shape = Enum.PartType.Block
    box.Size = Vector3.new(distance * 2, distance * 2, distance * 2)
    box.Anchored = false
    box.CanCollide = false
    box.CastShadow = false
    box.Massless = true
    box.Transparency = reachBoxTransparency
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
    reachBoxConn = RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r or not reachBoxPart or not reachBoxPart.Parent then return end
        if not reachBoxWeld or not reachBoxWeld.Parent then
            local w = Instance.new("WeldConstraint")
            w.Part0 = r
            w.Part1 = reachBoxPart
            w.Parent = reachBoxPart
            reachBoxWeld = w
        end
    end)
    trackConn(reachBoxConn)
end

local function updateReachBoxSize(distance)
    if reachBoxPart and reachBoxPart.Parent then
        reachBoxPart.Size = Vector3.new(distance * 2, distance * 2, distance * 2)
    end
end

trackConn(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if reachOn then
        createReachBox(ReachModule.distance)
    end
end))

local brBallCache = {}
local brLimbCache = {}
local brLastUpdate = 0
local brLastChar = nil
local brFrame = 0

local function startBreakReact()
    if breakReactConn then return end
    breakReactConn = RunService.Heartbeat:Connect(function()
        if not breakReactOn then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not root then return end
        brFrame = brFrame + 1
        if brFrame % 3 == 0 or brFrame <= 1 then
            local now = tick()
            if now - brLastUpdate > 1 or char ~= brLastChar then
                brBallCache = refreshBallCache()
                brLimbCache = {}
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        table.insert(brLimbCache, part)
                    end
                end
                brLastUpdate = now
                brLastChar = char
            end
        end
        for _, ball in ipairs(brBallCache) do
            if ball and ball.Parent then
                for _, limb in ipairs(brLimbCache) do
                    fireTouchInstant(ball, limb)
                end
                pcall(function()
                    ball.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    ball.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end)
            end
        end
    end)
    trackConn(breakReactConn)
end

local function stopBreakReact()
    if breakReactConn then breakReactConn:Disconnect(); breakReactConn = nil end
    brBallCache = {}
    brLimbCache = {}
    brLastUpdate = 0
    brLastChar = nil
    brFrame = 0
end

local function hookStamina()
    if staminaConn then staminaConn:Disconnect() end
    task.spawn(function()
        local ok, stamina = pcall(function()
            return LocalPlayer:WaitForChild("PlayerScripts", 5)
                :WaitForChild("controllers", 5)
                :WaitForChild("movementController", 5)
                :WaitForChild("stamina", 5)
        end)
        if ok and stamina then
            staminaConn = RunService.Heartbeat:Connect(function()
                if staminaOn and stamina and stamina.Parent then
                    pcall(function() stamina.Value = 100 end)
                end
            end)
            trackConn(staminaConn)
        end
    end)
end

local function stopStamina()
    if staminaConn then staminaConn:Disconnect(); staminaConn = nil end
end

local function startJumpBoost()
    if jumpConn then return end
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then originalJumpPower = humanoid.JumpPower end
    jumpConn = RunService.Heartbeat:Connect(function()
        if not jumpBoostOn then return end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.JumpPower ~= jumpPower then h.JumpPower = jumpPower end
    end)
    trackConn(jumpConn)
    if jumpCharConn then jumpCharConn:Disconnect(); jumpCharConn = nil end
    jumpCharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        if jumpBoostOn then
            local h = newChar:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower = jumpPower end
        end
    end)
    trackConn(jumpCharConn)
end

local function stopJumpBoost()
    if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
    if jumpCharConn then jumpCharConn:Disconnect(); jumpCharConn = nil end
    local char = LocalPlayer.Character
    local h = char and char:FindFirstChildOfClass("Humanoid")
    if h then h.JumpPower = originalJumpPower end
end

local function startSpeedBoost()
    if speedConn then return end
    speedConn = RunService.Heartbeat:Connect(function()
        if not speedBoostOn then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if root and humanoid then
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                root.CFrame = root.CFrame + (moveDir * (0.15 * speedMultiplier))
            end
        end
    end)
    trackConn(speedConn)
end

local function stopSpeedBoost()
    if speedConn then speedConn:Disconnect(); speedConn = nil end
end

local function getNet()
    local pitch = workspace:FindFirstChild("pitch")
    if not pitch then return nil end
    local nets = pitch:FindFirstChild("nets")
    if not nets then return nil end
    return nets:FindFirstChild(targetNet)
end

local function getNetPos(net)
    if not net then return nil end
    local sum, count = Vector3.new(), 0
    for _, p in ipairs(net:GetDescendants()) do
        if p:IsA("BasePart") then sum = sum + p.Position; count = count + 1 end
    end
    if count > 0 then return sum / count end
    local ok, pos = pcall(function() return net:GetPivot().Position end)
    if ok then return pos end
    return nil
end

local function doAutoGoal()
    if not autoGoalOn then return end
    local char = LocalPlayer.Character
    if not char then return end
    local limbs = {}
    for _, limb in pairs(char:GetDescendants()) do
        if limb:IsA("BasePart") then table.insert(limbs, limb) end
    end
    local net = getNet()
    local netPos = getNetPos(net)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj:FindFirstChild("network") and obj.Parent then
            for _, limb in ipairs(limbs) do
                task.spawn(fireTouch, obj, limb)
            end
            if netPos then
                task.wait(0.05)
                local dir = (netPos - obj.Position)
                if dir.Magnitude > 0.1 then
                    pcall(function()
                        obj.AssemblyLinearVelocity = dir.Unit * (goalPower * 3)
                        obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end)
                end
            end
        end
    end
end

local function watchKickButton()
    if kickButtonHooked then return end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local main = pg:FindFirstChild("main")
    if not main then return end
    local mobile = main:FindFirstChild("mobile")
    if not mobile then return end
    local ctc = mobile:FindFirstChild("contextTabContainer")
    if not ctc then return end
    local ckc = ctc:FindFirstChild("contextKickContainer")
    if not ckc then return end
    local kickBtn = ckc:FindFirstChild("contextActionKickButton")
    if not kickBtn then return end
    if kickBtn:IsA("GuiButton") then
        kickButtonHooked = true
        trackConn(kickBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if autoGoalOn then
                    task.spawn(doAutoGoal)
                end
            end
        end))
    end
end

trackConn(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    kickButtonHooked = false
    watchKickButton()
end))

task.spawn(function()
    for i = 1, 10 do
        task.wait(1)
        if kickButtonHooked then break end
        watchKickButton()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EZHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

local W = isMobile and 310 or 440
local H = isMobile and 350 or 310
local SW = isMobile and 80 or 100
local HH = 34

local c_bg = Color3.fromRGB(15, 15, 19)
local c_side = Color3.fromRGB(18, 18, 23)
local c_head = Color3.fromRGB(18, 18, 23)
local c_el = Color3.fromRGB(24, 24, 30)
local c_elh = Color3.fromRGB(32, 32, 40)
local c_acc = Color3.fromRGB(88, 101, 242)
local c_accd = Color3.fromRGB(68, 78, 190)
local c_txt = Color3.fromRGB(210, 210, 220)
local c_dim = Color3.fromRGB(100, 100, 118)
local c_toff = Color3.fromRGB(38, 38, 46)
local c_div = Color3.fromRGB(32, 32, 40)
local c_knob = Color3.fromRGB(220, 220, 228)
local fs = isMobile and 10 or 12
local fss = isMobile and 9 or 11

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, W, 0, H)
Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = c_bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1, 0, 0, HH)
hdr.BackgroundColor3 = c_head
hdr.BorderSizePixel = 0
hdr.Parent = Main

local hline = Instance.new("Frame")
hline.Size = UDim2.new(1, 0, 0, 1)
hline.Position = UDim2.new(0, 0, 1, -1)
hline.BackgroundColor3 = c_div
hline.BorderSizePixel = 0
hline.Parent = hdr

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(1, -70, 1, 0)
ttl.Position = UDim2.new(0, 10, 0, 0)
ttl.BackgroundTransparency = 1
ttl.RichText = true
ttl.Text = '<font color="#5865F2">●</font>  ez hub'
ttl.TextColor3 = c_txt
ttl.TextSize = isMobile and 13 or 15
ttl.Font = Enum.Font.GothamBold
ttl.TextXAlignment = Enum.TextXAlignment.Left
ttl.Parent = hdr

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, HH - 6, 0, HH - 6)
closeBtn.Position = UDim2.new(1, -HH + 1, 0, 3)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(180, 60, 60)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = hdr

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(180, 60, 60)}):Play()
end)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, HH - 6, 0, HH - 6)
minBtn.Position = UDim2.new(1, -HH * 2 + 8, 0, 3)
minBtn.BackgroundTransparency = 1
minBtn.Text = "–"
minBtn.TextColor3 = c_dim
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = hdr

minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), {TextColor3 = c_txt}):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), {TextColor3 = c_dim}):Play()
end)

local side = Instance.new("Frame")
side.Size = UDim2.new(0, SW, 1, -HH)
side.Position = UDim2.new(0, 0, 0, HH)
side.BackgroundColor3 = c_side
side.BorderSizePixel = 0
side.Parent = Main

local sdiv = Instance.new("Frame")
sdiv.Size = UDim2.new(0, 1, 1, -8)
sdiv.Position = UDim2.new(1, -1, 0, 4)
sdiv.BackgroundColor3 = c_div
sdiv.BorderSizePixel = 0
sdiv.Parent = side

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -SW, 1, -HH)
content.Position = UDim2.new(0, SW, 0, HH)
content.BackgroundTransparency = 1
content.Parent = Main

local mobBtn = Instance.new("TextButton")
mobBtn.Size = UDim2.new(0, 40, 0, 40)
mobBtn.Position = UDim2.new(1, -50, 1, -55)
mobBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
mobBtn.Text = "E"
mobBtn.TextColor3 = c_acc
mobBtn.TextSize = 16
mobBtn.Font = Enum.Font.GothamBold
mobBtn.Parent = ScreenGui
Instance.new("UICorner", mobBtn).CornerRadius = UDim.new(0, 8)

mobBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end))

trackConn(UserInputService.InputChanged:Connect(function(i)
    if activeSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        activeSlider(i.Position.X)
    end
end))

trackConn(UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        activeSlider = nil
    end
end))

local tabs = {"Player", "Ball"}
local currentTab = ""
local tabBtns = {}
local contentFrames = {}

local function makeTab(name, idx)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, isMobile and 28 or 30)
    b.Position = UDim2.new(0, 4, 0, 4 + (idx - 1) * (isMobile and 32 or 34))
    b.BackgroundColor3 = c_el
    b.BackgroundTransparency = 1
    b.Text = name
    b.TextColor3 = c_dim
    b.TextSize = fss
    b.Font = Enum.Font.GothamSemibold
    b.AutoButtonColor = false
    b.Parent = side
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseEnter:Connect(function()
        if currentTab ~= name then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if currentTab ~= name then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
    end)
    return b
end

local function makeContent(name)
    local f = Instance.new("ScrollingFrame")
    f.Size = UDim2.new(1, -10, 1, -10)
    f.Position = UDim2.new(0, 5, 0, 5)
    f.BackgroundTransparency = 1
    f.ScrollBarThickness = 2
    f.ScrollBarImageColor3 = c_accd
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.Visible = false
    f.Parent = content
    local l = Instance.new("UIListLayout", f)
    l.Padding = UDim.new(0, 3)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return f
end

local function makeToggle(par, name, ord, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, isMobile and 34 or 36)
    f.BackgroundColor3 = c_el
    f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0
    f.LayoutOrder = ord
    f.Parent = par
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(f, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(f, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
        end
    end)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -55, 1, 0)
    lb.Position = UDim2.new(0, 10, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextColor3 = c_txt
    lb.TextSize = fs
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = f
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0, 36, 0, 18)
    tb.Position = UDim2.new(1, -44, 0.5, -9)
    tb.BackgroundColor3 = c_toff
    tb.Text = ""
    tb.AutoButtonColor = false
    tb.Parent = f
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(0, 12, 0, 12)
    d.Position = UDim2.new(0, 3, 0.5, -6)
    d.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
    d.BorderSizePixel = 0
    d.Parent = tb
    Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
    local on = false
    tb.MouseButton1Click:Connect(function()
        on = not on
        local t = TweenInfo.new(0.2, Enum.EasingStyle.Quint)
        TweenService:Create(tb, t, {BackgroundColor3 = on and c_acc or c_toff}):Play()
        TweenService:Create(d, t, {
            Position = on and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 130)
        }):Play()
        cb(on)
    end)
    return f
end

local function makeSlider(par, name, ord, lo, hi, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, isMobile and 46 or 48)
    f.BackgroundColor3 = c_el
    f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0
    f.LayoutOrder = ord
    f.Parent = par
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(f, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(f, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
        end
    end)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -50, 0, 20)
    lb.Position = UDim2.new(0, 10, 0, 3)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextColor3 = c_txt
    lb.TextSize = fs
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = f
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 40, 0, 18)
    vl.Position = UDim2.new(1, -46, 0, 4)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(def)
    vl.TextColor3 = c_acc
    vl.TextSize = fss
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = f
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -20, 0, 4)
    bg.Position = UDim2.new(0, 10, 1, -13)
    bg.BackgroundColor3 = c_toff
    bg.BorderSizePixel = 0
    bg.Parent = f
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local fr = math.clamp((def - lo) / (hi - lo), 0, 1)
    local fl = Instance.new("Frame")
    fl.Size = UDim2.new(fr, 0, 1, 0)
    fl.BackgroundColor3 = c_acc
    fl.BorderSizePixel = 0
    fl.Parent = bg
    Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 10, 0, 10)
    kn.Position = UDim2.new(fr, -5, 0.5, -5)
    kn.BackgroundColor3 = c_knob
    kn.BorderSizePixel = 0
    kn.Parent = bg
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    local function upd(px)
        if bg.AbsoluteSize.X == 0 then return end
        local p = math.clamp((px - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local v = math.clamp(math.floor(lo + (hi - lo) * p + 0.5), lo, hi)
        vl.Text = tostring(v)
        fl.Size = UDim2.new(p, 0, 1, 0)
        kn.Position = UDim2.new(p, -5, 0.5, -5)
        cb(v)
    end
    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 6, 0, 20)
    hit.Position = UDim2.new(0, -3, 1, -20)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.ZIndex = 5
    hit.Parent = f
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            activeSlider = upd
            upd(i.Position.X)
            TweenService:Create(kn, TweenInfo.new(0.1), {Size = UDim2.new(0, 14, 0, 14)}):Play()
        end
    end)
    hit.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if activeSlider == upd then activeSlider = nil end
            TweenService:Create(kn, TweenInfo.new(0.1), {Size = UDim2.new(0, 10, 0, 10)}):Play()
        end
    end)
    return f
end

local function makeDropToggle(par, name, ord, opts, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, isMobile and 34 or 36)
    f.BackgroundColor3 = c_el
    f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0
    f.ClipsDescendants = false
    f.LayoutOrder = ord
    f.Parent = par
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(f, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(f, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
        end
    end)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -120, 1, 0)
    lb.Position = UDim2.new(0, 10, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextColor3 = c_txt
    lb.TextSize = fs
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = f
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0, 36, 0, 18)
    tb.Position = UDim2.new(1, -44, 0.5, -9)
    tb.BackgroundColor3 = c_toff
    tb.Text = ""
    tb.AutoButtonColor = false
    tb.Parent = f
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 3, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
    dot.BorderSizePixel = 0
    dot.Parent = tb
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local dd = Instance.new("TextButton")
    dd.Size = UDim2.new(0, 52, 0, 20)
    dd.Position = UDim2.new(1, -100, 0.5, -10)
    dd.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    dd.Text = def
    dd.TextColor3 = c_dim
    dd.TextSize = fss
    dd.Font = Enum.Font.Gotham
    dd.AutoButtonColor = false
    dd.Parent = f
    Instance.new("UICorner", dd).CornerRadius = UDim.new(0, 4)
    dd.MouseEnter:Connect(function()
        TweenService:Create(dd, TweenInfo.new(0.1), {BackgroundColor3 = c_elh}):Play()
    end)
    dd.MouseLeave:Connect(function()
        TweenService:Create(dd, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
    end)
    local ddl = Instance.new("Frame")
    ddl.Size = UDim2.new(0, 52, 0, 0)
    ddl.Position = UDim2.new(1, -100, 1, 2)
    ddl.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    ddl.BorderSizePixel = 0
    ddl.Visible = false
    ddl.ClipsDescendants = true
    ddl.ZIndex = 30
    ddl.Parent = f
    Instance.new("UICorner", ddl).CornerRadius = UDim.new(0, 4)
    Instance.new("UIListLayout", ddl).SortOrder = Enum.SortOrder.LayoutOrder
    local isOn = false
    local cur = def
    local open = false
    for _, o in ipairs(opts) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, 0, 0, 20)
        ob.BackgroundTransparency = 1
        ob.Text = o
        ob.TextColor3 = c_dim
        ob.TextSize = fss
        ob.Font = Enum.Font.Gotham
        ob.AutoButtonColor = false
        ob.ZIndex = 31
        ob.Parent = ddl
        ob.MouseButton1Click:Connect(function()
            cur = o
            dd.Text = o
            open = false
            TweenService:Create(ddl, TweenInfo.new(0.12), {Size = UDim2.new(0, 52, 0, 0)}):Play()
            task.delay(0.12, function() ddl.Visible = false end)
            cb(isOn, cur)
        end)
        ob.MouseEnter:Connect(function()
            TweenService:Create(ob, TweenInfo.new(0.1), {TextColor3 = c_txt}):Play()
        end)
        ob.MouseLeave:Connect(function()
            TweenService:Create(ob, TweenInfo.new(0.1), {TextColor3 = c_dim}):Play()
        end)
    end
    dd.MouseButton1Click:Connect(function()
        open = not open
        if open then
            ddl.Visible = true
            TweenService:Create(ddl, TweenInfo.new(0.12), {Size = UDim2.new(0, 52, 0, #opts * 20)}):Play()
        else
            TweenService:Create(ddl, TweenInfo.new(0.12), {Size = UDim2.new(0, 52, 0, 0)}):Play()
            task.delay(0.12, function() ddl.Visible = false end)
        end
    end)
    tb.MouseButton1Click:Connect(function()
        isOn = not isOn
        local t = TweenInfo.new(0.2, Enum.EasingStyle.Quint)
        TweenService:Create(tb, t, {BackgroundColor3 = isOn and c_acc or c_toff}):Play()
        TweenService:Create(dot, t, {
            Position = isOn and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 130)
        }):Play()
        cb(isOn, cur)
    end)
    return f
end

for i, t in ipairs(tabs) do
    tabBtns[t] = makeTab(t, i)
    contentFrames[t] = makeContent(t)
end

local function switchTab(name)
    if currentTab == name then return end
    currentTab = name
    for n, b in pairs(tabBtns) do
        local a = n == name
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundTransparency = a and 0 or 1,
            TextColor3 = a and c_txt or c_dim
        }):Play()
        contentFrames[n].Visible = a
    end
end

for n, b in pairs(tabBtns) do
    b.MouseButton1Click:Connect(function()
        switchTab(n)
    end)
end

local pContent = contentFrames["Player"]
local bContent = contentFrames["Ball"]

makeToggle(pContent, "Reach", 0, function(s)
    reachOn = s
    ReachModule:Toggle(s)
    if s then createReachBox(ReachModule.distance) else removeReachBox() end
end)

makeSlider(pContent, "Reach Size", 1, 1, 1000, 5, function(v)
    ReachModule:SetDistance(v)
    updateReachBoxSize(v)
end)

makeSlider(pContent, "Box Transparency", 2, 0, 100, 80, function(v)
    reachBoxTransparency = v / 100
    if reachBoxPart and reachBoxPart.Parent then
        reachBoxPart.Transparency = reachBoxTransparency
    end
end)

makeToggle(pContent, "Infinite Stamina", 3, function(s)
    staminaOn = s
    if s then hookStamina() else stopStamina() end
end)

makeToggle(pContent, "Jump Boost", 4, function(s)
    jumpBoostOn = s
    if s then startJumpBoost() else stopJumpBoost() end
end)

makeSlider(pContent, "Jump Power", 5, 50, 300, 50, function(v)
    jumpPower = v
end)

makeToggle(pContent, "Speed Boost", 6, function(s)
    speedBoostOn = s
    if s then startSpeedBoost() else stopSpeedBoost() end
end)

makeSlider(pContent, "Speed Multiplier", 7, 1, 5, 2, function(v)
    speedMultiplier = v
end)

makeDropToggle(bContent, "Auto Goal", 0, {"Home", "Away"}, "Home", function(s, o)
    autoGoalOn = s
    targetNet = o
end)

makeSlider(bContent, "Shot Power", 1, 1, 300, 50, function(v)
    goalPower = v
end)

makeToggle(bContent, "Break React", 2, function(s)
    breakReactOn = s
    if s then startBreakReact() else stopBreakReact() end
end)

switchTab("Player")

do
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    hdr.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    hdr.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    trackConn(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
end

local function cleanupAll()
    for _, conn in ipairs(allConnections) do
        pcall(function() conn:Disconnect() end)
    end
    allConnections = {}
    stopStamina()
    stopJumpBoost()
    stopSpeedBoost()
    stopBreakReact()
    ReachModule:Stop()
    removeReachBox()
end

minBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, W, 0, 0)
    }):Play()
    task.delay(0.2, function()
        cleanupAll()
        pcall(function() ScreenGui:Destroy() end)
    end)
end)

Main.Size = UDim2.new(0, W, 0, 0)
Main.BackgroundTransparency = 1
TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, W, 0, H),
    BackgroundTransparency = 0
}):Play()
