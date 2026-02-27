local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // Reach Logic Module
local ReachModule = {
    enabled = false,
    size = Vector3.new(10, 10, 10),
    connection = nil,
    cachedBalls = {},    
    lastUpdate = 0,       
    cachedLimbs = {},
    visualizer = nil
}

-- // UI Creation Helpers
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

-- // Drag and Drop Functionality
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- // 3D Visualizer Logic
local function UpdateVisualizer()
    if not ReachModule.enabled then 
        if ReachModule.visualizer then ReachModule.visualizer:Destroy() ReachModule.visualizer = nil end
        return 
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if not ReachModule.visualizer then
        local box = Create("Part", {
            Name = "ReachVisualizer",
            Parent = char,
            Material = Enum.Material.ForceField,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.6,
            CanCollide = false,
            CanQuery = false,
            Massless = true
        })
        
        Create("Weld", {
            Parent = box,
            Part0 = root,
            Part1 = box
        })
        ReachModule.visualizer = box
    end
    ReachModule.visualizer.Size = ReachModule.size
end

-- // Main UI Components
local ScreenGui = Create("ScreenGui", {Name = "BiggieHub", Parent = CoreGui, ResetOnSpawn = false})
local MainFrame = Create("Frame", {
    Name = "Main",
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -250, 0.5, -175),
    Size = UDim2.new(0, 500, 0, 350)
})
Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = MainFrame})
MakeDraggable(MainFrame) -- Apply Drag and Drop

-- Left Sidebar
local Sidebar = Create("Frame", {
    Name = "Sidebar",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    Size = UDim2.new(0, 150, 1, 0)
})
Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})

-- Content Area
local Content = Create("Frame", {
    Name = "Content",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 160, 0, 40),
    Size = UDim2.new(1, -170, 1, -290)
})

-- // Slider Creation Logic
local function CreateSlider(parent, name, min, max, default, callback)
    local row = Create("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1})
    local label = Create("TextLabel", {
        Parent = row, Text = name .. ": " .. default, TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.SourceSans
    })
    
    local tray = Create("Frame", {
        Parent = row, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, -10, 0, 6),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderSizePixel = 0
    })
    local fill = Create("Frame", {
        Parent = tray, Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(60, 120, 255), BorderSizePixel = 0
    })

    local function Update(input)
        local pos = math.clamp((input.Position.X - tray.AbsolutePosition.X) / tray.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (pos * (max - min)))
        label.Text = name .. ": " .. val
        callback(val)
    end

    tray.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    Update(moveInput)
                end
            end)
            UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                end
            end)
            Update(input)
        end
    end)
end

-- // Initialize Player Tab
local PlayerTab = Create("Frame", {Parent = Content, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
Create("UIListLayout", {Parent = PlayerTab, Padding = UDim.new(0, 10)})

local ReachToggle = Create("TextButton", {
    Parent = PlayerTab, Size = UDim2.new(1, -10, 0, 35),
    BackgroundColor3 = Color3.fromRGB(35, 35, 35), Text = "Reach: OFF",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold
})
Create("UICorner", {Parent = ReachToggle})

ReachToggle.MouseButton1Click:Connect(function()
    ReachModule.enabled = not ReachModule.enabled
    ReachToggle.Text = ReachModule.enabled and "Reach: ON" or "Reach: OFF"
    ReachToggle.BackgroundColor3 = ReachModule.enabled and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(35, 35, 35)
    UpdateVisualizer()
end)

CreateSlider(PlayerTab, "Reach X", 1, 50, 10, function(v) ReachModule.size = Vector3.new(v, ReachModule.size.Y, ReachModule.size.Z) UpdateVisualizer() end)
CreateSlider(PlayerTab, "Reach Y", 1, 50, 10, function(v) ReachModule.size = Vector3.new(ReachModule.size.X, v, ReachModule.size.Z) UpdateVisualizer() end)
CreateSlider(PlayerTab, "Reach Z", 1, 50, 10, function(v) ReachModule.size = Vector3.new(ReachModule.size.X, ReachModule.size.Y, v) UpdateVisualizer() end)

-- // Reach Engine Loop
RunService.Heartbeat:Connect(function()
    if not ReachModule.enabled then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if tick() - ReachModule.lastUpdate > 1 then
        local balls = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj:FindFirstChild("network") then table.insert(balls, obj) end
        end
        ReachModule.cachedBalls = balls
        ReachModule.cachedLimbs = {}
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then table.insert(ReachModule.cachedLimbs, part) end
        end
        ReachModule.lastUpdate = tick()
    end

    for _, ball in ipairs(ReachModule.cachedBalls) do
        if ball and ball.Parent then
            local relPos = root.CFrame:PointToObjectSpace(ball.Position)
            if math.abs(relPos.X) <= ReachModule.size.X/2 and 
               math.abs(relPos.Y) <= ReachModule.size.Y/2 and 
               math.abs(relPos.Z) <= ReachModule.size.Z/2 then
                for _, limb in ipairs(ReachModule.cachedLimbs) do
                    if firetouchinterest then
                        firetouchinterest(ball, limb, 0)
                        firetouchinterest(ball, limb, 1)
                    end
                end
            end
        end
    end
end)

