-- Infernal Hub Free - Real Football Hitbox Extender + Roblox Notification!
-- 100% Universal: Football, Soccer, Kick, Touch, Custom Hitbox, Real visual/topbar notification
-- Direct link compatible for ALL executors

if not game:IsLoaded() then game.Loaded:Wait() end
local plr = game.Players.LocalPlayer

-- Real Roblox TopBar Notification (just like friend requests)
local function roblox_notify(title, text, duration)
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Notice";
            Text = text or "";
            Duration = duration or 3;
        })
    end)
end

roblox_notify("Infernal Hub", "Infernal Hub loading...", 4)

-- Delayed actual load for effect
task.wait(2.5)

-- UI + animated helper
local TweenService = game:GetService("TweenService")
local function anim(instance, prop, target, time, easing)
    local tween = TweenService:Create(instance, TweenInfo.new(time or 0.22, easing or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {[prop]=target})
    tween:Play()
end

local gui = Instance.new("ScreenGui")
gui.Name = "InfernalHubFree"
if syn and syn.protect_gui then syn.protect_gui(gui) end
gui.Parent = game.CoreGui

local bg = Instance.new("Frame", gui)
bg.Name = "MainBG"
bg.BackgroundColor3 = Color3.fromRGB(33,33,44)
bg.Size = UDim2.new(0,480,0,340)
bg.Position = UDim2.new(0.5,-240,0.5,-170)
bg.Active = true
bg.Draggable = true
bg.BorderSizePixel = 0
local corner = Instance.new("UICorner", bg)
corner.CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", bg)
title.Text = "Infernal Hub Free - Football Hitbox"
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,0,0,56)
title.Position = UDim2.new(0,0,0,0)
title.TextColor3 = Color3.fromRGB(255,65,95)

local tabNames = {"Player", "GK", "Ball"}
local tabNum, tabs, tabFrames = 1, {}, {}

local tabBar = Instance.new("Frame", bg)
tabBar.BackgroundTransparency = 1
tabBar.Position = UDim2.new(0,26,0,64)
tabBar.Size = UDim2.new(0,419,0,36)
local selector = Instance.new("Frame", tabBar)
selector.Size = UDim2.new(0,118,0,7)
selector.Position = UDim2.new(0,0,0,30)
selector.BackgroundColor3 = Color3.fromRGB(250,85,105)
selector.BackgroundTransparency = 0.23
local selCorner = Instance.new("UICorner", selector)
selCorner.CornerRadius = UDim.new(1,0)

for i, name in ipairs(tabNames) do
    local t = Instance.new("TextButton", tabBar)
    t.Name = "Tab"..i
    t.Size = UDim2.new(0,118,0,28)
    t.Position = UDim2.new(0,(i-1)*133,0,0)
    t.Text = name
    t.Font = Enum.Font.GothamBold
    t.TextSize = 18
    t.BackgroundColor3 = Color3.fromRGB(42,42,49)
    t.TextColor3 = Color3.fromRGB(240,240,240)
    t.BorderSizePixel = 0
    local tc = Instance.new("UICorner", t)
    tc.CornerRadius = UDim.new(0.7,0)
    tabs[i] = t
    local f = Instance.new("Frame", bg)
    f.Name = "TabContent"..i
    f.BackgroundTransparency = 1
    f.Size = UDim2.new(1,-52,1,-119)
    f.Position = UDim2.new(0,26,0,108)
    f.Visible = (i == 1)
    tabFrames[i] = f

    t.MouseButton1Down:Connect(function()
        if tabNum ~= i then
            anim(selector, "Position", UDim2.new(0,(i-1)*133,0,30), 0.23)
            anim(t, "BackgroundColor3", Color3.fromRGB(255,95,120), 0.23)
            for j,tab in ipairs(tabs) do
                if j ~= i then
                    anim(tab, "BackgroundColor3", Color3.fromRGB(42,42,49), 0.26)
                end
            end
            for j,frame in ipairs(tabFrames) do
                if j == i then
                    frame.Visible = true
                    frame.BackgroundTransparency = 1
                    anim(frame, "BackgroundTransparency", 0, 0.27, Enum.EasingStyle.Quint)
                else
                    anim(frame, "BackgroundTransparency", 1, 0.24)
                    delay(0.22,function() frame.Visible = false end)
                end
            end
            tabNum = i
        end
    end)
end
selector.Position = tabs[tabNum].Position + UDim2.new(0,0,0,30)

local function createSlider(parent, text, min, max, def, decimal)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-44,0,65)
    frame.Position = UDim2.new(0,24,0,14+(#parent:GetChildren()-1)*74)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 19
    label.Size = UDim2.new(0.28,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Position = UDim2.new(0,0,0,0)

    local slideBar = Instance.new("Frame", frame)
    slideBar.Size = UDim2.new(0,210,0,7)
    slideBar.Position = UDim2.new(0.33,0,0.55,-4)
    slideBar.BackgroundColor3 = Color3.fromRGB(130,65,85)
    slideBar.BorderSizePixel = 0
    local sbCorner = Instance.new("UICorner", slideBar)
    sbCorner.CornerRadius = UDim.new(0.8,0)

    local thumb = Instance.new("Frame", frame)
    thumb.Size = UDim2.new(0,20,0,20)
    thumb.Position = UDim2.new(0,.33,0.5,-10)
    thumb.BackgroundColor3 = Color3.fromRGB(225,65,130)
    local tCorner = Instance.new("UICorner", thumb)
    tCorner.CornerRadius = UDim.new(1,0)

    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Position = UDim2.new(0.83,0,0,0)
    valLabel.Size = UDim2.new(0.16,0,1,-2)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = Color3.fromRGB(255,255,250)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 18

    local val = def
    valLabel.Text = def

    local dragging = false
    local UIS = game:GetService("UserInputService")
    thumb.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            anim(thumb,"Size",UDim2.new(0,28,0,28), 0.15)
        end
    end)
    thumb.InputEnded:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            anim(thumb,"Size",UDim2.new(0,20,0,20), 0.18)
        end
    end)
    slideBar.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 then
            local x = io.Position.X - slideBar.AbsolutePosition.X
            x = math.clamp(x,0,210)
            anim(thumb, "Position", UDim2.new(0,slideBar.Position.X.Offset + x -10,0.5,-10), 0.15)
            val = decimal and math.floor((x/210)*(max-min)+min*100)/100 or math.floor((x/210)*(max-min)+min+0.5)
            valLabel.Text = tostring(val)
        end
    end)
    UIS.InputChanged:Connect(function(io)
        if dragging and io.UserInputType == Enum.UserInputType.MouseMovement then
            local x = io.Position.X - slideBar.AbsolutePosition.X
            x = math.clamp(x,0,210)
            anim(thumb, "Position", UDim2.new(0,slideBar.Position.X.Offset + x-10,0.5,-10), 0.14)
            val = decimal and math.floor((x/210)*(max-min)+min*100)/100 or math.floor((x/210)*(max-min)+min+0.5)
            valLabel.Text = tostring(val)
        end
    end)
    function frame:get() return val end
    return frame
end

local reachSlider = createSlider(tabFrames[1], "Hitbox Size (studs)", 2, 20, 4, false)
local transpSlider = createSlider(tabFrames[1], "Hitbox Transparency", 0, 1, 0.4, true)

-- UNIVERSAL SOCCER/FOOTBALL HITBOX NAMES (edit for new games)
local football_names = {"hitbox","kick","foot","leg","touch","reach","balltouch","soccer","box","collision"}

-- Recursive expander: Target every hitbox part in your character and child models/folders
local function expand_all_hitboxes(char, size, transparency)
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("BasePart") then
            for _,name in ipairs(football_names) do
                if desc.Name:lower():find(name) then
                    desc.Size = Vector3.new(size,size,size)
                    desc.Transparency = transparency
                    desc.CanCollide = false
                    desc.Massless = true
                end
            end
        end
    end
    -- Always update HumanoidRootPart for classic scripts
    if char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Size = Vector3.new(size,size,size)
        char.HumanoidRootPart.Transparency = transparency
        char.HumanoidRootPart.CanCollide = false
        char.HumanoidRootPart.Massless = true
    end
end

-- Permanent visible hitbox part attached to you for feedback
local hitboxVisual = Instance.new("Part")
hitboxVisual.Name = "InfernalHitbox"
hitboxVisual.Anchored = false
hitboxVisual.CanCollide = false
hitboxVisual.Massless = true
hitboxVisual.Shape = Enum.PartType.Block
hitboxVisual.Material = Enum.Material.ForceField
hitboxVisual.Color = Color3.fromRGB(255, 20, 75)
hitboxVisual.Transparency = 0.4
hitboxVisual.Size = Vector3.new(4,4,4)
hitboxVisual.Parent = workspace
hitboxVisual.CastShadow = false
local hitCorner = Instance.new("UICorner", hitboxVisual)
hitCorner.CornerRadius = UDim.new(0.34,0)

local function attachHitbox()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        hitboxVisual.Parent = workspace
        if not hitboxVisual:FindFirstChild("HitboxWeld") then
            local weld = Instance.new("WeldConstraint")
            weld.Name = "HitboxWeld"
            weld.Part0 = plr.Character.HumanoidRootPart
            weld.Part1 = hitboxVisual
            weld.Parent = hitboxVisual
        end
        hitboxVisual.Position = plr.Character.HumanoidRootPart.Position
    end
end

plr.CharacterAdded:Connect(function()
    for _,c in ipairs(workspace:GetChildren()) do if c:IsA("Part") and c.Name == "InfernalHitbox" then c:Destroy() end end
    wait(1)
    attachHitbox()
end)
attachHitbox()

local function updateVisual()
    if plr.Character then
        expand_all_hitboxes(plr.Character, reachSlider:get(), transpSlider:get())
        if plr.Character:FindFirstChild("HumanoidRootPart") then
            hitboxVisual.Size = Vector3.new(reachSlider:get(), reachSlider:get(), reachSlider:get())
            hitboxVisual.Transparency = transpSlider:get()
            local t = 1-transpSlider:get()
            local newColor = Color3.fromRGB(255,20+(200*t),75+(160*t))
            anim(hitboxVisual,"Color",newColor, 0.13)
            hitboxVisual.Position = plr.Character.HumanoidRootPart.Position
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(updateVisual)
plr.OnTeleport:Connect(function()
    gui:Destroy() 
    if hitboxVisual then hitboxVisual:Destroy() end
end)

roblox_notify("Infernal Hub", "Infernal Hub loaded! Enjoy!", 3)

print("[Infernal Hub Free - Universal Football Hitbox Loaded. Notification shown!]")
