-- ASTATINE PREMIUM V2.0 - ADVANCED REACH SYSTEM
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Astatine  V2.0",
    LoadingTitle = "Initializing Advanced Systems...",
    LoadingSubtitle = "Loading nigger Features...",
    ConfigurationSaving = {Enabled = true, FolderName = "AstatinePremium"},
    Discord = {Enabled = false}
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer

-- Tabs
local tabReach = Window:CreateTab("advanced Reach")
local tabPlayer = Window:CreateTab(" Player")
local tabBall = Window:CreateTab(" Ball Controls")
local tabOP = Window:CreateTab("OP Features")
local tabGK = Window:CreateTab("Goalkeeper")
local tabSettings = Window:CreateTab("⚙️ Settings")

-- Advanced Variables
local reachSystem = {
    enabled = false,
    distance = 8,
    maxDistance = 100,
    mode = "Smart",
    bypassLevel = 3,
    visualizer = true,
    autoAdjust = true,
    prediction = true,
    multiTouch = true,
    smartDelay = true,
    lastTouch = 0,
    touchCount = 0,
    ballHistory = {},
    connections = {}
}

-- ADVANCED BYPASSER SYSTEM
local bypassMethods = {
    -- Method 1: Hook overlapCheck and gkCheck functions
    hookOverlapChecks = function()
        for _, v in ipairs(getgc(true)) do
            if type(v) == "table" then
                if rawget(v, "overlapCheck") then
                    hookfunction(v.overlapCheck, function(...) return true end)
                end
                if rawget(v, "gkCheck") then
                    hookfunction(v.gkCheck, function(...) return true end)
                end
                if rawget(v, "ballCheck") then
                    hookfunction(v.ballCheck, function(...) return true end)
                end
                if rawget(v, "distanceCheck") then
                    hookfunction(v.distanceCheck, function(...) return true end)
                end
            end
        end
    end,
    
    -- Method 2: Advanced network bypassing
    bypassNetworkChecks = function()
        local success = pcall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    if remote.Name:lower():find("ball") or remote.Name:lower():find("touch") then
                        local oldFireServer = remote.FireServer
                        remote.FireServer = function(self, ...)
                            return oldFireServer(self, ...)
                        end
                    end
                end
            end
        end)
        return success
    end,
    
    -- Method 3: Memory scanning for anti-cheat
    scanMemory = function()
        local success = pcall(function()
            for _, obj in pairs(getgc(true)) do
                if type(obj) == "function" then
                    local info = debug.getinfo(obj)
                    if info and info.source and (
                        info.source:find("anticheat") or 
                        info.source:find("detection") or
                        info.source:find("security")
                    ) then
                        hookfunction(obj, function() return end)
                    end
                end
            end
        end)
        return success
    end
}

-- Initialize all bypass methods
task.spawn(function()
    bypassMethods.hookOverlapChecks()
    bypassMethods.bypassNetworkChecks()
    bypassMethods.scanMemory()
end)

-- ADVANCED REACH TAB
tabReach:CreateDropdown({
    Name = "Reach Mode",
    Options = {"Smart", "Aggressive", "Stealth", "Prediction", "Hybrid"},
    CurrentOption = "Smart",
    Flag = "ReachMode",
    Callback = function(option)
        reachSystem.mode = option
        Rayfield:Notify({Title = "Reach System", Content = "🎯 Mode set to " .. option})
    end
})

tabReach:CreateSlider({
    Name = "Reach Distance",
    Range = {3, reachSystem.maxDistance},
    Increment = 0.5,
    CurrentValue = 8,
    Flag = "ReachDistance",
    Callback = function(val)
        reachSystem.distance = val
    end
})

tabReach:CreateSlider({
    Name = "Bypass Level",
    Range = {1, 5},
    Increment = 1,
    CurrentValue = 3,
    Flag = "BypassLevel",
    Callback = function(val)
        reachSystem.bypassLevel = val
        Rayfield:Notify({Title = "Bypass", Content = "🛡️ Bypass level: " .. val})
    end
})

tabReach:CreateToggle({
    Name = "Enable Advanced Reach",
    CurrentValue = false,
    Flag = "AdvancedReach",
    Callback = function(v)
        reachSystem.enabled = v
        if v then
            startAdvancedReach()
        else
            stopAdvancedReach()
        end
        Rayfield:Notify({Title = "Advanced Reach", Content = v and "🟢 Advanced reach enabled" or "🔴 Advanced reach disabled"})
    end
})

tabReach:CreateToggle({
    Name = "Ball Prediction",
    CurrentValue = true,
    Flag = "BallPrediction",
    Callback = function(v)
        reachSystem.prediction = v
    end
})

tabReach:CreateToggle({
    Name = "Multi-Touch System",
    CurrentValue = true,
    Flag = "MultiTouch",
    Callback = function(v)
        reachSystem.multiTouch = v
    end
})

tabReach:CreateToggle({
    Name = "Smart Delay",
    CurrentValue = true,
    Flag = "SmartDelay",
    Callback = function(v)
        reachSystem.smartDelay = v
    end
})

tabReach:CreateToggle({
    Name = "Visual Reach Box",
    CurrentValue = true,
    Flag = "VisualReach",
    Callback = function(v)
        reachSystem.visualizer = v
    end
})

-- PLAYER TAB
local playerSystem = {
    stamina = false,
    speed = false,
    speedMult = 2,
    originalSpeed = nil,
    jump = false,
    jumpPower = 50,
    noclip = false,
    fly = false,
    flySpeed = 16
}

tabPlayer:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "InfiniteStamina",
    Callback = function(v)
        playerSystem.stamina = v
        Rayfield:Notify({Title = "Player", Content = v and "🟢 Infinite stamina enabled" or "🔴 Infinite stamina disabled"})
    end
})

tabPlayer:CreateSlider({
    Name = "Speed Multiplier",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 2,
    Flag = "SpeedMultiplier",
    Callback = function(val)
        playerSystem.speedMult = val
    end
})

tabPlayer:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedBoost",
    Callback = function(v)
        playerSystem.speed = v
        Rayfield:Notify({Title = "Player", Content = v and "🏃 Speed boost enabled" or "🏃 Speed boost disabled"})
    end
})

tabPlayer:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 10,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(val)
        playerSystem.jumpPower = val
    end
})

tabPlayer:CreateToggle({
    Name = "Super Jump",
    CurrentValue = false,
    Flag = "SuperJump",
    Callback = function(v)
        playerSystem.jump = v
        Rayfield:Notify({Title = "Player", Content = v and "🦘 Super jump enabled" or "🦘 Super jump disabled"})
    end
})

tabPlayer:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v)
        playerSystem.noclip = v
        Rayfield:Notify({Title = "Player", Content = v and "👻 Noclip enabled" or "👻 Noclip disabled"})
    end
})

-- Player system handler
local playerConnection = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        -- Speed
        if not playerSystem.originalSpeed then
            playerSystem.originalSpeed = hum.WalkSpeed
        end
        if playerSystem.speed then
            hum.WalkSpeed = playerSystem.originalSpeed * playerSystem.speedMult
        else
            hum.WalkSpeed = playerSystem.originalSpeed
        end
        
        -- Jump
        if playerSystem.jump then
            hum.JumpPower = playerSystem.jumpPower
        else
            hum.JumpPower = 50
        end
    end
    
    -- Stamina
    if playerSystem.stamina then
        local stamina = LocalPlayer:FindFirstChild("PlayerScripts")
        if stamina then
            stamina = stamina:FindFirstChild("controllers")
            if stamina then
                stamina = stamina:FindFirstChild("movementController")
                if stamina then
                    stamina = stamina:FindFirstChild("stamina")
                    if stamina then
                        stamina.Value = 100
                    end
                end
            end
        end
    end
    
    -- Noclip
    if playerSystem.noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ADVANCED REACH SYSTEM FUNCTIONS
local visualParts = {}
local reachConnections = {}

-- Create advanced visualizer
local function createAdvancedVisualizer()
    -- Clear existing parts
    for _, part in pairs(visualParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    visualParts = {}
    
    -- Create sphere visualizer
    local sphere = Instance.new("Part")
    sphere.Name = "ReachSphere"
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.Material = Enum.Material.ForceField
    sphere.Shape = Enum.PartType.Ball
    sphere.Color = Color3.fromRGB(0, 255, 255)
    sphere.Transparency = 0.8
    sphere.Parent = workspace
    visualParts.sphere = sphere
    
    -- Create edge lines for better visibility
    for i = 1, 24 do
        local edge = Instance.new("Part")
        edge.Name = "ReachEdge" .. i
        edge.Anchored = true
        edge.CanCollide = false
        edge.Material = Enum.Material.Neon
        edge.Color = Color3.fromRGB(255, 255, 255)
        edge.Size = Vector3.new(0.1, 0.1, 1)
        edge.Transparency = 0.5
        edge.Parent = workspace
        visualParts["edge" .. i] = edge
    end
end

-- Predict ball movement
local function predictBallPosition(ball, deltaTime)
    if not reachSystem.prediction then return ball.Position end
    
    local velocity = ball.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    local predictedPos = ball.Position + (velocity * deltaTime)
    
    -- Store ball history for better prediction
    table.insert(reachSystem.ballHistory, {pos = ball.Position, time = tick()})
    if #reachSystem.ballHistory > 10 then
        table.remove(reachSystem.ballHistory, 1)
    end
    
    return predictedPos
end

-- Advanced touch system with multiple methods
local function advancedFireTouch(ball, character)
    local methods = {
        -- Method 1: Standard firetouchinterest
        function()
            for _, limb in pairs(character:GetDescendants()) do
                if limb:IsA("BasePart") and limb.Name ~= "HumanoidRootPart" then
                    firetouchinterest(ball, limb, 0)
                    task.wait(0.001)
                    firetouchinterest(ball, limb, 1)
                end
            end
        end,
        
        -- Method 2: Direct position manipulation
        function()
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                local originalPos = root.CFrame
                root.CFrame = CFrame.new(ball.Position + Vector3.new(0, 2, 0))
                task.wait(0.01)
                root.CFrame = originalPos
            end
        end,
        
        -- Method 3: Velocity-based approach
        function()
            if ball.AssemblyLinearVelocity then
                local originalVel = ball.AssemblyLinearVelocity
                ball.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                task.wait(0.005)
                ball.AssemblyLinearVelocity = originalVel
            end
        end
    }
    
    -- Execute based on bypass level
    local methodsToUse = math.min(reachSystem.bypassLevel, #methods)
    for i = 1, methodsToUse do
        task.spawn(methods[i])
    end
end

-- Smart delay system
local function getSmartDelay()
    if not reachSystem.smartDelay then return 0.05 end
    
    local baseDelay = 0.02
    local distanceMultiplier = reachSystem.distance / 20
    local modeMultiplier = ({
        Smart = 1,
        Aggressive = 0.5,
        Stealth = 2,
        Prediction = 1.2,
        Hybrid = 0.8
    })[reachSystem.mode] or 1
    
    return baseDelay * distanceMultiplier * modeMultiplier
end

-- Main reach function
local function processReach()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local currentTime = tick()
    local smartDelay = getSmartDelay()
    
    if currentTime - reachSystem.lastTouch < smartDelay then return end
    
    for _, ball in pairs(workspace:GetDescendants()) do
        if ball:IsA("Part") and ball:FindFirstChild("network") then
            local ballPos = predictBallPosition(ball, 0.1)
            local distance = (ballPos - root.Position).Magnitude
            
            if distance <= reachSystem.distance then
                -- Mode-specific behavior
                local shouldTouch = false
                
                if reachSystem.mode == "Smart" then
                    shouldTouch = distance <= reachSystem.distance * 0.8
                elseif reachSystem.mode == "Aggressive" then
                    shouldTouch = true
                elseif reachSystem.mode == "Stealth" then
                    shouldTouch = distance <= reachSystem.distance * 0.6 and math.random() > 0.3
                elseif reachSystem.mode == "Prediction" then
                    shouldTouch = distance <= reachSystem.distance * 0.9
                elseif reachSystem.mode == "Hybrid" then
                    shouldTouch = distance <= reachSystem.distance * (0.6 + math.random() * 0.3)
                end
                
                if shouldTouch then
                    advancedFireTouch(ball, char)
                    reachSystem.lastTouch = currentTime
                    reachSystem.touchCount = reachSystem.touchCount + 1
                    
                    if not reachSystem.multiTouch then
                        break
                    end
                end
            end
        end
    end
end

-- Update visualizer
local function updateVisualizer()
    if not reachSystem.visualizer then
        for _, part in pairs(visualParts) do
            if part and part.Parent then
                part.Transparency = 1
            end
        end
        return
    end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local pulse = math.sin(tick() * 3) * 0.1 + 0.8
    
    -- Update sphere
    if visualParts.sphere then
        visualParts.sphere.Size = Vector3.new(reachSystem.distance * 2, reachSystem.distance * 2, reachSystem.distance * 2)
        visualParts.sphere.CFrame = root.CFrame
        visualParts.sphere.Transparency = pulse
        
        -- Color based on mode
        local colors = {
            Smart = Color3.fromRGB(0, 255, 255),
            Aggressive = Color3.fromRGB(255, 0, 0),
            Stealth = Color3.fromRGB(128, 0, 128),
            Prediction = Color3.fromRGB(0, 255, 0),
            Hybrid = Color3.fromRGB(255, 255, 0)
        }
        visualParts.sphere.Color = colors[reachSystem.mode] or Color3.fromRGB(255, 255, 255)
    end
    
    -- Update edges
    for i = 1, 24 do
        local edge = visualParts["edge" .. i]
        if edge then
            local angle = (i / 24) * math.pi * 2
            local radius = reachSystem.distance
            local height = math.sin(angle * 3) * 2
            
            local pos = root.Position + Vector3.new(
                math.cos(angle) * radius,
                height,
                math.sin(angle) * radius
            )
            
            edge.CFrame = CFrame.new(pos, root.Position)
            edge.Size = Vector3.new(0.1, 0.1, (pos - root.Position).Magnitude)
            edge.Transparency = pulse * 0.7
        end
    end
end

-- Start advanced reach system
function startAdvancedReach()
    createAdvancedVisualizer()
    
    reachConnections.main = RunService.Heartbeat:Connect(processReach)
    reachConnections.visual = RunService.RenderStepped:Connect(updateVisualizer)
    
    Rayfield:Notify({
        Title = "Advanced Reach",
        Content = "🎯 Advanced reach system activated with " .. reachSystem.mode .. " mode"
    })
end

-- Stop advanced reach system
function stopAdvancedReach()
    for name, connection in pairs(reachConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    reachConnections = {}
    
    for _, part in pairs(visualParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    visualParts = {}
end

-- BALL CONTROLS TAB
local ballSystem = {
    autoGoal = false,
    goalPower = 150,
    airPower = 200,
    ballMagnet = false,
    magnetStrength = 50,
    ballFreeze = false,
    ballTeleport = false,
    shootCooldown = false,
    lastShot = 0
}

tabBall:CreateToggle({
    Name = "Auto Goal (Advanced)",
    CurrentValue = false,
    Flag = "AutoGoalAdvanced",
    Callback = function(v)
        ballSystem.autoGoal = v
        Rayfield:Notify({Title = "Ball Control", Content = v and "⚽ Advanced auto goal enabled" or "⚽ Advanced auto goal disabled"})
    end
})

tabBall:CreateSlider({
    Name = "Goal Power",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Flag = "GoalPowerAdvanced",
    Callback = function(val)
        ballSystem.goalPower = val
    end
})

tabBall:CreateSlider({
    Name = "Air Shot Power",
    Range = {100, 800},
    Increment = 20,
    CurrentValue = 200,
    Flag = "AirPowerAdvanced",
    Callback = function(val)
        ballSystem.airPower = val
    end
})

tabBall:CreateToggle({
    Name = "Ball Magnet",
    CurrentValue = false,
    Flag = "BallMagnet",
    Callback = function(v)
        ballSystem.ballMagnet = v
        Rayfield:Notify({Title = "Ball Control", Content = v and "🧲 Ball magnet enabled" or "🧲 Ball magnet disabled"})
    end
})

tabBall:CreateSlider({
    Name = "Magnet Strength",
    Range = {10, 100},
    Increment = 5,
    CurrentValue = 50,
    Flag = "MagnetStrength",
    Callback = function(val)
        ballSystem.magnetStrength = val
    end
})

tabBall:CreateToggle({
    Name = "Ball Freeze",
    CurrentValue = false,
    Flag = "BallFreeze",
    Callback = function(v)
        ballSystem.ballFreeze = v
        Rayfield:Notify({Title = "Ball Control", Content = v and "🧊 Ball freeze enabled" or "🧊 Ball freeze disabled"})
    end
})

tabBall:CreateButton({
    Name = "Teleport Ball to Me",
    Callback = function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, ball in pairs(workspace:GetDescendants()) do
            if ball:IsA("Part") and ball:FindFirstChild("network") then
                ball.CFrame = root.CFrame + root.CFrame.LookVector * 3
                ball.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                Rayfield:Notify({Title = "Ball Control", Content = "⚽ Ball teleported to you"})
                break
            end
        end
    end
})

-- Advanced shooting function
local function advancedShootBall(ball, targetPos, power, curve)
    if ballSystem.shootCooldown or tick() - ballSystem.lastShot < 0.3 then return end
    ballSystem.shootCooldown = true
    ballSystem.lastShot = tick()
    
    task.spawn(function()
        pcall(function()
            local direction = (targetPos - ball.Position).Unit
            local distance = (targetPos - ball.Position).Magnitude
            
            -- Add curve for more realistic shots
            if curve then
                local rightVector = direction:Cross(Vector3.new(0, 1, 0))
                direction = direction + rightVector * (math.random(-0.2, 0.2))
            end
            
            -- Multiple velocity application methods
            local methods = {
                function()
                    ball.AssemblyLinearVelocity = direction * power
                end,
                function()
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = direction * power
                    bv.Parent = ball
                    Debris:AddItem(bv, 0.15)
                end,
                function()
                    local bp = Instance.new("BodyPosition")
                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bp.Position = targetPos
                    bp.Parent = ball
                    Debris:AddItem(bp, 0.1)
                end
            }
            
            -- Execute multiple methods for better success rate
            for i = 1, math.min(reachSystem.bypassLevel, #methods) do
                methods[i]()
                task.wait(0.01)
            end
        end)
        
        task.wait(0.5)
        ballSystem.shootCooldown = false
    end)
end

-- Ball system handler
local ballConnection = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for _, ball in pairs(workspace:GetDescendants()) do
        if ball:IsA("Part") and ball:FindFirstChild("network") then
            local distance = (ball.Position - root.Position).Magnitude
            
            -- Ball magnet
            if ballSystem.ballMagnet and distance <= 20 then
                local direction = (root.Position - ball.Position).Unit
                ball.AssemblyLinearVelocity = direction * ballSystem.magnetStrength
            end
            
            -- Ball freeze
            if ballSystem.ballFreeze then
                ball.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                ball.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            
            -- Auto goal
            if ballSystem.autoGoal and distance <= reachSystem.distance then
                for _, goal in pairs(workspace:GetDescendants()) do
                    if goal:IsA("Model") and (goal.Name:lower():find("goal") or goal.Name:lower():find("net")) then
                        local goalPart = goal:FindFirstChildWhichIsA("BasePart")
                        if goalPart then
                            local isAirBall = ball.Position.Y > 8
                            local power = isAirBall and ballSystem.airPower or ballSystem.goalPower
                            local shouldCurve = math.random() > 0.7 -- 30% chance for curve
                            
                            advancedShootBall(ball, goalPart.Position, power, shouldCurve)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- OP FEATURES TAB
local opSystem = {
    ballsBroken = false,
    playersLagged = false,
    serverCrash = false
}

tabOP:CreateButton({
    Name = "💀 Ultimate Ball Break",
    Callback = function()
        for _, ball in pairs(workspace:GetDescendants()) do
            if ball:IsA("Part") and ball:FindFirstChild("network") then
                task.spawn(function()
                    pcall(function()
                        ball.Anchored = true
                        ball.CanCollide = false
                        ball.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        ball.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        
                        -- Destroy network components
                        for _, child in pairs(ball:GetChildren()) do
                            if child.Name:lower():find("network") or child.Name:lower():find("script") then
                                child:Destroy()
                            end
                        end
                        
                        -- Make ball invisible to others
                        ball.Transparency = 0.9
                        ball.Material = Enum.Material.ForceField
                    end)
                end)
            end
        end
        opSystem.ballsBroken = true
        Rayfield:Notify({Title = "OP Features", Content = "💀 Ultimate ball break activated!"})
    end
})

tabOP:CreateButton({
    Name = "✅ Restore Ball Physics",
    Callback = function()
        for _, ball in pairs(workspace:GetDescendants()) do
            if ball:IsA("Part") and (ball.Name:lower():find("ball") or ball.Name:lower():find("football")) then
                task.spawn(function()
                    pcall(function()
                        ball.Anchored = false
                        ball.CanCollide = true
                        ball.Transparency = 0
                        ball.Material = Enum.Material.Plastic
                    end)
                end)
            end
        end
        opSystem.ballsBroken = false
        Rayfield:Notify({Title = "OP Features", Content = "✅ Ball physics restored!"})
    end
})

tabOP:CreateButton({
    Name = "🌪️ Chaos Mode (Ragdoll All)",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                task.spawn(function()
                    pcall(function()
                        local char = player.Character
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        local root = char:FindFirstChild("HumanoidRootPart")
                        
                        if hum and root then
                            -- Multiple ragdoll methods
                            hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
                            hum.PlatformStand = true
                            hum.Sit = true
                            
                            -- Add spinning effect
                            local spin = Instance.new("BodyAngularVelocity")
                            spin.AngularVelocity = Vector3.new(0, 50, 0)
                            spin.MaxTorque = Vector3.new(0, math.huge, 0)
                            spin.Parent = root
                            Debris:AddItem(spin, 3)
                            
                            -- Launch them
                            local launch = Instance.new("BodyVelocity")
                            launch.Velocity = Vector3.new(math.random(-50, 50), 50, math.random(-50, 50))
                            launch.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            launch.Parent = root
                            Debris:AddItem(launch, 0.5)
                        end
                    end)
                end)
            end
        end
        Rayfield:Notify({Title = "OP Features", Content = "🌪️ Chaos mode activated!"})
    end
})

tabOP:CreateButton({
    Name = "⚡ Server Lag Bomb",
    Callback = function()
        for i = 1, 100 do
            task.spawn(function()
                local part = Instance.new("Part")
                part.Size = Vector3.new(0.1, 0.1, 0.1)
                part.Material = Enum.Material.Neon
                part.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                part.Position = Vector3.new(math.random(-100, 100), math.random(10, 50), math.random(-100, 100))
                part.Parent = workspace
                
                local spin = Instance.new("BodyAngularVelocity")
                spin.AngularVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
                spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                spin.Parent = part
                
                Debris:AddItem(part, 10)
            end)
        end
        Rayfield:Notify({Title = "OP Features", Content = "⚡ Server lag bomb deployed!"})
    end
})

tabOP:CreateButton({
    Name = "🎭 Invisible Mode",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                elseif part:IsA("Accessory") then
                    part.Handle.Transparency = 1
                end
            end
            Rayfield:Notify({Title = "OP Features", Content = "🎭 You are now invisible!"})
        end
    end
})

tabOP:CreateButton({
    Name = "👁️ Visible Mode",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                elseif part:IsA("Accessory") then
                    part.Handle.Transparency = 0
                end
            end
            Rayfield:Notify({Title = "OP Features", Content = "👁️ You are now visible!"})
        end
    end
})

-- GOALKEEPER TAB
local gkSystem = {
    autoSave = false,
    saveDistance = 15,
    divePower = 100,
    reflexMode = false
}

tabGK:CreateToggle({
    Name = "Auto Save",
    CurrentValue = false,
    Flag = "AutoSave",
    Callback = function(v)
        gkSystem.autoSave = v
        Rayfield:Notify({Title = "Goalkeeper", Content = v and "🧤 Auto save enabled" or "🧤 Auto save disabled"})
    end
})

tabGK:CreateSlider({
    Name = "Save Distance",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = 15,
    Flag = "SaveDistance",
    Callback = function(val)
        gkSystem.saveDistance = val
    end
})

tabGK:CreateSlider({
    Name = "Dive Power",
    Range = {50, 200},
    Increment = 10,
    CurrentValue = 100,
    Flag = "DivePower",
    Callback = function(val)
        gkSystem.divePower = val
    end
})

tabGK:CreateToggle({
    Name = "Reflex Mode",
    CurrentValue = false,
    Flag = "ReflexMode",
    Callback = function(v)
        gkSystem.reflexMode = v
        Rayfield:Notify({Title = "Goalkeeper", Content = v and "⚡ Reflex mode enabled" or "⚡ Reflex mode disabled"})
    end
})

-- Goalkeeper system
local gkConnection = RunService.Heartbeat:Connect(function()
    if not gkSystem.autoSave then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for _, ball in pairs(workspace:GetDescendants()) do
        if ball:IsA("Part") and ball:FindFirstChild("network") then
            local distance = (ball.Position - root.Position).Magnitude
            local ballVelocity = ball.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
            
            if distance <= gkSystem.saveDistance and ballVelocity.Magnitude > 10 then
                -- Predict where ball will be
                local timeToReach = distance / ballVelocity.Magnitude
                local predictedPos = ball.Position + (ballVelocity * timeToReach)
                
                -- Move to intercept
                if gkSystem.reflexMode then
                    root.CFrame = CFrame.new(predictedPos)
                else
                    local direction = (predictedPos - root.Position).Unit
                    root.AssemblyLinearVelocity = direction * gkSystem.divePower
                end
                
                -- Touch the ball
                task.spawn(function()
                    advancedFireTouch(ball, char)
                end)
            end
        end
    end
end)

-- SETTINGS TAB
tabSettings:CreateButton({
    Name = "📊 Performance Stats",
    Callback = function()
        local stats = {
            "🎯 Reach Touches: " .. reachSystem.touchCount,
            "⚽ Current Mode: " .. reachSystem.mode,
            "📏 Reach Distance: " .. reachSystem.distance,
            "🛡️ Bypass Level: " .. reachSystem.bypassLevel,
            "⏱️ Last Touch: " .. math.floor((tick() - reachSystem.lastTouch) * 100) / 100 .. "s ago"
        }
        
        local message = table.concat(stats, "\n")
        Rayfield:Notify({Title = "Performance Stats", Content = message, Duration = 5})
    end
})

tabSettings:CreateButton({
    Name = "🔄 Reset All Settings",
    Callback = function()
        reachSystem.distance = 8
        reachSystem.mode = "Smart"
        reachSystem.bypassLevel = 3
        playerSystem.speedMult = 2
        ballSystem.goalPower = 150
        
        Rayfield:Notify({Title = "Settings", Content = "🔄 All settings reset to default"})
    end
})

tabSettings:CreateButton({
    Name = "🧹 Clean Workspace",
    Callback = function()
        local cleaned = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name:find("Reach") then
                obj:Destroy()
                cleaned = cleaned + 1
            end
        end
        Rayfield:Notify({Title = "Cleanup", Content = "🧹 Cleaned " .. cleaned .. " objects"})
    end
})

tabSettings:CreateButton({
    Name = "🛑 Emergency Stop",
    Callback = function()
        reachSystem.enabled = false
        stopAdvancedReach()
        
        playerSystem.speed = false
        playerSystem.noclip = false
        ballSystem.autoGoal = false
        ballSystem.ballMagnet = false
        gkSystem.autoSave = false
        
        Rayfield:Notify({Title = "Emergency", Content = "🛑 All features disabled!"})
    end
})

tabSettings:CreateButton({
    Name = "💥 Unload Script",
    Callback = function()
        -- Disconnect all connections
        if playerConnection then playerConnection:Disconnect() end
        if ballConnection then ballConnection:Disconnect() end
        if gkConnection then gkConnection:Disconnect() end
        
        stopAdvancedReach()
        
        -- Clean up visual parts
        for _, part in pairs(visualParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        
        Rayfield:Notify({Title = "System", Content = "💥 Astatine Premium V2.0 unloaded successfully!"})
        task.wait(2)
        Rayfield:Destroy()
    end
})

-- Initialize notification
Rayfield:Notify({
    Title = "Astatine Premium V2.0",
    Content = "🚀 Advanced systems loaded successfully!\n🎯 Advanced reach with 5 modes\n🛡️ Multi-layer bypasser\n⚡ Overpowered features ready!",
    Duration = 5
})
