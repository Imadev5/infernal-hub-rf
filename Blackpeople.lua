 local L_0=game:GetService("Players")
local L_1=game:GetService("RunService")
local L_2=game:GetService("TweenService")
local L_3=game:GetService("UserInputService")
local L_4=game:GetService("CoreGui")
local L_5=L_0.LocalPlayer
local L_6=L_3.TouchEnabled
pcall(function()local L_49=gethui and gethui()or L_4;local L_50=L_49:FindFirstChild("BIGGIEHUB")if L_50 then L_50:Destroy()end end)
local L_7=false;local L_8=5;local L_9=false;local L_10=nil;local L_11=false;local L_12=50;local L_13=false;local L_14=2;local L_15=false;local L_16="Home";local L_17=50;local L_18=50;local L_19=nil;local L_20=nil;local L_21=nil;local L_22=false;local L_23=0.8;local L_24=nil;local L_25=nil;local L_26=nil;local L_27=false;local L_28=nil;local L_29={};local L_30=nil
local function L_31(L_51)if L_51 then table.insert(L_29,L_51)end;return L_51 end
do pcall(function()for _,L_52 in ipairs(getgc(true))do if type(L_52)=="table" and rawget(L_52,"overlapCheck") and rawget(L_52,"gkCheck") then hookfunction(L_52.overlapCheck,function()return true end)hookfunction(L_52.gkCheck,function()return true end)end end end)end
local function L_32(L_53,L_54)if not firetouchinterest then return end;if not L_53 or not L_53.Parent then return end;firetouchinterest(L_53,L_54,0)task.wait(0.03)firetouchinterest(L_53,L_54,1)end
local function L_33(L_55,L_56)if not firetouchinterest then return end;if not L_55 or not L_55.Parent then return end;if not L_56 or not L_56.Parent then return end;firetouchinterest(L_55,L_56,0)firetouchinterest(L_55,L_56,1)end
local function L_34(L_57,L_58,L_59)local L_60=L_57-L_58;return math.abs(L_60.X)<=L_59 and math.abs(L_60.Y)<=L_59 and math.abs(L_60.Z)<=L_59 end
local L_35={};local L_36=0;local L_37=2
local function L_38b(L_x)if not L_x:IsA("BasePart") then return false end;for _,L_c in ipairs(L_x:GetChildren())do local L_n=L_c.Name:lower()if L_n=="network" or L_n=="owner" or L_n:find("network") or L_n:find("owner") then return true end end;return false end
local function L_38()local L_61=tick()if L_61-L_36<L_37 and #L_35>0 then return L_35 end;local L_62={};for _,L_63 in ipairs(workspace:GetDescendants())do if L_38b(L_63) then table.insert(L_62,L_63)end end;L_35=L_62;L_36=L_61;return L_62 end
workspace.DescendantAdded:Connect(function(L_64)if L_38b(L_64) then L_36=0 end end)
workspace.DescendantRemoving:Connect(function(L_65)if L_65:IsA("BasePart") then L_36=0 end end)
local L_39={L_66=false;L_67=5;L_68=nil;L_69={};L_70=nil;L_71=0}
local function L_40(L_72)local L_73=tick()if L_72==L_39.L_70 and L_73-L_39.L_71<1 then return L_39.L_69 end;local L_74={};for _,L_75 in ipairs(L_72:GetChildren())do if L_75:IsA("BasePart") then table.insert(L_74,L_75)end end;L_39.L_69=L_74;L_39.L_70=L_72;L_39.L_71=L_73;return L_74 end
function L_39:L_76()if self.L_68 then return end;self.L_68=L_1.Heartbeat:Connect(function()if not self.L_66 then return end;local L_77=L_5.Character;local L_78=L_77 and L_77:FindFirstChild("HumanoidRootPart")if not L_78 then return end;local L_79=L_38();local L_80=L_40(L_77);local L_81=L_78.Position;local L_82=self.L_67;for L_83=#L_79,1,-1 do local L_84=L_79[L_83]if not L_84 or not L_84.Parent then table.remove(L_79,L_83)L_36=0 else if L_34(L_84.Position,L_81,L_82)then for _,L_85 in ipairs(L_80)do task.spawn(L_32,L_84,L_85)end end end end end)L_31(self.L_68)end
function L_39:L_86()if self.L_68 then self.L_68:Disconnect()self.L_68=nil end end
function L_39:L_87(L_88)self.L_67=L_88;L_8=L_88 end
function L_39:L_89(L_90)self.L_66=L_90;if L_90 then self:L_76()else self:L_86()end end
local function L_41()if L_26 then L_26:Disconnect()L_26=nil end;if L_24 and L_24.Parent then L_24:Destroy()end;L_24=nil;L_25=nil end
local function L_42(L_91)L_41()local L_92=L_5.Character;local L_93=L_92 and L_92:FindFirstChild("HumanoidRootPart")if not L_93 then return end;local L_94=Instance.new("Part")L_94.Name="ReachBox";L_94.Shape=Enum.PartType.Block;L_94.Size=Vector3.new(L_91*2,L_91*2,L_91*2)L_94.Anchored=false;L_94.CanCollide=false;L_94.CastShadow=false;L_94.Massless=true;L_94.Transparency=L_23;L_94.Color=Color3.fromRGB(255,255,255)L_94.Material=Enum.Material.Neon;L_94.CFrame=L_93.CFrame;L_94.Parent=workspace;local L_95=Instance.new("WeldConstraint")L_95.Part0=L_93;L_95.Part1=L_94;L_95.Parent=L_94;L_24=L_94;L_25=L_95;L_26=L_1.Heartbeat:Connect(function()local L_96=L_5.Character;local L_97=L_96 and L_96:FindFirstChild("HumanoidRootPart")if not L_97 or not L_24 or not L_24.Parent then return end;if not L_25 or not L_25.Parent then local L_98=Instance.new("WeldConstraint")L_98.Part0=L_97;L_98.Part1=L_24;L_98.Parent=L_24;L_25=L_98 end end)L_31(L_26)end
local function L_43(L_99)if L_24 and L_24.Parent then L_24.Size=Vector3.new(L_99*2,L_99*2,L_99*2)end end
L_31(L_5.CharacterAdded:Connect(function()task.wait(1)if L_7 then L_42(L_39.L_67)end end))
local L_44={};local L_45={};local L_46=nil;local L_47=0;local L_48=0
local function L_100()if L_28 then return end;L_28=L_1.Heartbeat:Connect(function()if not L_27 then return end;local L_101=L_5.Character;local L_102=L_101 and L_101:FindFirstChild("HumanoidRootPart")if not L_101 or not L_102 then return end;L_48=L_48+1;if L_48%3==0 or L_48<=1 then local L_103=tick()if L_103-L_47>1 or L_101~=L_46 then L_44=L_38();L_45={};for _,L_104 in ipairs(L_101:GetChildren())do if L_104:IsA("BasePart") then table.insert(L_45,L_104)end end;L_47=L_103;L_46=L_101 end end;for _,L_105 in ipairs(L_44)do if L_105 and L_105.Parent then for _,L_106 in ipairs(L_45)do L_33(L_105,L_106)end;pcall(function()L_105.AssemblyLinearVelocity=Vector3.new(0,0,0)L_105.AssemblyAngularVelocity=Vector3.new(0,0,0)end)end end end)L_31(L_28)end
local function L_107()if L_28 then L_28:Disconnect()L_28=nil end;L_44={};L_45={};L_47=0;L_46=nil;L_48=0 end
local function L_108()if L_10 then L_10:Disconnect()end;task.spawn(function()local L_109,L_110=pcall(function()return L_5:WaitForChild("PlayerScripts",5):WaitForChild("controllers",5):WaitForChild("movementController",5):WaitForChild("stamina",5)end)if L_109 and L_110 then L_10=L_1.Heartbeat:Connect(function()if L_9 and L_110 and L_110.Parent then pcall(function()L_110.Value=100 end)end end)L_31(L_10)end end)end
local function L_111()if L_10 then L_10:Disconnect()L_10=nil end end
local function L_112()if L_19 then return end;local L_113=L_5.Character;local L_114=L_113 and L_113:FindFirstChildOfClass("Humanoid")if L_114 then L_18=L_114.JumpPower end;L_19=L_1.Heartbeat:Connect(function()if not L_11 then return end;local L_115=L_5.Character;local L_116=L_115 and L_115:FindFirstChildOfClass("Humanoid")if L_116 and L_116.JumpPower~=L_12 then L_116.JumpPower=L_12 end end)L_31(L_19)if L_20 then L_20:Disconnect()L_20=nil end;L_20=L_5.CharacterAdded:Connect(function(L_117)task.wait(0.5)if L_11 then local L_118=L_117:FindFirstChildOfClass("Humanoid")if L_118 then L_118.JumpPower=L_12 end end end)L_31(L_20)end
local function L_119()if L_19 then L_19:Disconnect()L_19=nil end;if L_20 then L_20:Disconnect()L_20=nil end;local L_120=L_5.Character;local L_121=L_120 and L_120:FindFirstChildOfClass("Humanoid")if L_121 then L_121.JumpPower=L_18 end end
local function L_122()if L_21 then return end;L_21=L_1.Heartbeat:Connect(function()if not L_13 then return end;local L_123=L_5.Character;local L_124=L_123 and L_123:FindFirstChild("HumanoidRootPart")local L_125=L_123 and L_123:FindFirstChildOfClass("Humanoid")if L_124 and L_125 then local L_126=L_125.MoveDirection;if L_126.Magnitude>0 then L_124.CFrame=L_124.CFrame+(L_126*(0.15*L_14))end end end)L_31(L_21)end
local function L_127()if L_21 then L_21:Disconnect()L_21=nil end end
local function L_128()local L_129=workspace:FindFirstChild("pitch")if not L_129 then return nil end;local L_130=L_129:FindFirstChild("nets")if not L_130 then return nil end;return L_130:FindFirstChild(L_16)end
local function L_131(L_132)if not L_132 then return nil end;local L_133,L_134=Vector3.new(),0;for _,L_135 in ipairs(L_132:GetDescendants())do if L_135:IsA("BasePart") then L_133=L_133+L_135.Position;L_134=L_134+1 end end;if L_134>0 then return L_133/L_134 end;local L_136,L_137=pcall(function()return L_132:GetPivot().Position end)if L_136 then return L_137 end;return nil end
local function L_138()if not L_15 then return end;local L_139=L_5.Character;if not L_139 then return end;local L_140={};for _,L_141 in pairs(L_139:GetDescendants())do if L_141:IsA("BasePart") then table.insert(L_140,L_141)end end;local L_142=L_128();local L_143=L_131(L_142)for _,L_144 in ipairs(workspace:GetDescendants())do if L_144:IsA("Part") and L_144:FindFirstChild("network") and L_144.Parent then for _,L_145 in ipairs(L_140)do task.spawn(L_32,L_144,L_145)end;if L_143 then task.wait(0.05)local L_146=L_143-L_144.Position;if L_146.Magnitude>0.1 then pcall(function()L_144.AssemblyLinearVelocity=L_146.Unit*(L_17*3)L_144.AssemblyAngularVelocity=Vector3.new(0,0,0)end)end end end end end
local function L_147()if L_22 then return end;local L_148=L_5:FindFirstChild("PlayerGui")if not L_148 then return end;local L_149=L_148:FindFirstChild("main")if not L_149 then return end;local L_150=L_149:FindFirstChild("mobile")if not L_150 then return end;local L_151=L_150:FindFirstChild("contextTabContainer")if not L_151 then return end;local L_152=L_151:FindFirstChild("contextKickContainer")if not L_152 then return end;local L_153=L_152:FindFirstChild("contextActionKickButton")if not L_153 then return end;if L_153:IsA("GuiButton") then L_22=true;L_31(L_153.InputBegan:Connect(function(L_154)if L_154.UserInputType==Enum.UserInputType.MouseButton1 or L_154.UserInputType==Enum.UserInputType.Touch then if L_15 then task.spawn(L_138)end end end))end end
L_31(L_5.CharacterAdded:Connect(function()task.wait(2)L_22=false;L_147()end))
task.spawn(function()for L_155=1,10 do task.wait(1)if L_22 then break end;L_147()end end)
-- PC M1 auto goal: fires when player has Kick tool equipped, on MouseButton1 release
local L_m1Held=false
L_31(L_3.InputBegan:Connect(function(L_inp,L_gp)
    if L_gp then return end
    if L_inp.UserInputType==Enum.UserInputType.MouseButton1 then
        local L_chr=L_5.Character
        local L_bp=L_chr and L_chr:FindFirstChildOfClass("Tool")
        if L_bp and L_bp.Name=="Kick" then
            L_m1Held=true
        end
    end
end))
L_31(L_3.InputEnded:Connect(function(L_inp)
    if L_inp.UserInputType==Enum.UserInputType.MouseButton1 then
        if L_m1Held then
            L_m1Held=false
            if L_15 then
                task.spawn(L_138)
            end
        end
    end
end))
local L_156=Instance.new("ScreenGui")L_156.Name="BIGGIEHUB";L_156.ResetOnSpawn=false;L_156.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
if gethui then L_156.Parent=gethui()elseif syn and syn.protect_gui then syn.protect_gui(L_156)L_156.Parent=L_4 else L_156.Parent=L_4 end
local L_157=L_6 and 280 or 380;local L_158=L_6 and 300 or 260;local L_159=L_6 and 64 or 80;local L_160=28
local L_156=Instance.new("ScreenGui")L_156.Name="BIGGIEHUB";L_156.ResetOnSpawn=false;L_156.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
if gethui then L_156.Parent=gethui()elseif syn and syn.protect_gui then syn.protect_gui(L_156)L_156.Parent=L_4 else L_156.Parent=L_4 end
local L_cW=L_6 and 320 or 480;local L_cH=L_6 and 340 or 380;local L_cSW=L_6 and 90 or 120;local L_cHH=32
local L_cBG=Color3.fromRGB(24,24,30);local L_cSB=Color3.fromRGB(20,20,26);local L_cDiv=Color3.fromRGB(38,38,48);local L_cTxt=Color3.fromRGB(210,210,218);local L_cDim=Color3.fromRGB(110,110,128);local L_cInpBG=Color3.fromRGB(16,16,22);local L_cInpBd=Color3.fromRGB(52,52,65);local L_cToff=Color3.fromRGB(48,48,60);local L_fN=Enum.Font.Gotham;local L_fB=Enum.Font.GothamBold;local L_fS=Enum.Font.GothamSemibold;local L_fs=L_6 and 10 or 11;local L_fsS=L_6 and 9 or 10
local L_175=Instance.new("Frame")L_175.Name="MainFrame";L_175.Size=UDim2.new(0,L_cW,0,L_cH)L_175.Position=UDim2.new(0.5,-L_cW/2,0.5,-L_cH/2)L_175.BackgroundColor3=L_cBG;L_175.BorderSizePixel=0;L_175.ClipsDescendants=true;L_175.Parent=L_156;Instance.new("UICorner",L_175).CornerRadius=UDim.new(0,6)
local L_176=Instance.new("Frame")L_176.Size=UDim2.new(1,0,0,L_cHH)L_176.BackgroundColor3=L_cSB;L_176.BorderSizePixel=0;L_176.ZIndex=2;L_176.Parent=L_175
Instance.new("Frame",L_176).Size=UDim2.new(1,0,0,1);do local L_x=L_176:FindFirstChildOfClass("Frame")L_x.Position=UDim2.new(0,0,1,-1)L_x.BackgroundColor3=L_cDiv;L_x.BorderSizePixel=0 end
local L_ttl=Instance.new("TextLabel")L_ttl.Size=UDim2.new(1,-70,1,0)L_ttl.Position=UDim2.new(0,10,0,0)L_ttl.BackgroundTransparency=1;L_ttl.Text="BIGGIE HUB 4.0";L_ttl.TextColor3=L_cTxt;L_ttl.TextSize=L_6 and 11 or 12;L_ttl.Font=L_fB;L_ttl.TextXAlignment=Enum.TextXAlignment.Left;L_ttl.Parent=L_176
local L_179=Instance.new("TextButton")L_179.Size=UDim2.new(0,26,0,26)L_179.Position=UDim2.new(1,-30,0.5,-13)L_179.BackgroundTransparency=1;L_179.Text="✕";L_179.TextColor3=Color3.fromRGB(170,55,55)L_179.TextSize=13;L_179.Font=L_fB;L_179.Parent=L_176
L_179.MouseEnter:Connect(function()L_2:Create(L_179,TweenInfo.new(0.1),{TextColor3=Color3.fromRGB(230,70,70)}):Play()end)
L_179.MouseLeave:Connect(function()L_2:Create(L_179,TweenInfo.new(0.1),{TextColor3=Color3.fromRGB(170,55,55)}):Play()end)
local L_180=Instance.new("TextButton")L_180.Size=UDim2.new(0,26,0,26)L_180.Position=UDim2.new(1,-58,0.5,-13)L_180.BackgroundTransparency=1;L_180.Text="–";L_180.TextColor3=L_cDim;L_180.TextSize=13;L_180.Font=L_fB;L_180.Parent=L_176
L_180.MouseEnter:Connect(function()L_2:Create(L_180,TweenInfo.new(0.1),{TextColor3=L_cTxt}):Play()end)
L_180.MouseLeave:Connect(function()L_2:Create(L_180,TweenInfo.new(0.1),{TextColor3=L_cDim}):Play()end)
local L_181=Instance.new("Frame")L_181.Size=UDim2.new(0,L_cSW,1,-L_cHH)L_181.Position=UDim2.new(0,0,0,L_cHH)L_181.BackgroundColor3=L_cSB;L_181.BorderSizePixel=0;L_181.Parent=L_175
Instance.new("Frame",L_181).Size=UDim2.new(0,1,1,0);do local L_x=L_181:FindFirstChildOfClass("Frame")L_x.Position=UDim2.new(1,-1,0,0)L_x.BackgroundColor3=L_cDiv;L_x.BorderSizePixel=0 end
local L_183=Instance.new("Frame")L_183.Size=UDim2.new(1,-L_cSW,1,-L_cHH)L_183.Position=UDim2.new(0,L_cSW,0,L_cHH)L_183.BackgroundTransparency=1;L_183.ClipsDescendants=true;L_183.Parent=L_175
local L_floatBtn=Instance.new("TextButton")L_floatBtn.Size=UDim2.new(0,32,0,32)L_floatBtn.Position=UDim2.new(1,-38,1,-38)L_floatBtn.BackgroundColor3=Color3.fromRGB(20,20,26)L_floatBtn.Text="B";L_floatBtn.TextColor3=L_cDim;L_floatBtn.TextSize=12;L_floatBtn.Font=L_fB;L_floatBtn.Parent=L_156;Instance.new("UICorner",L_floatBtn).CornerRadius=UDim.new(0,6)
L_floatBtn.MouseButton1Click:Connect(function()L_175.Visible=not L_175.Visible end)
L_31(L_3.InputBegan:Connect(function(L_a,L_b)if L_b then return end;if L_a.UserInputType==Enum.UserInputType.Keyboard and L_a.KeyCode==Enum.KeyCode.RightShift then L_175.Visible=not L_175.Visible end end))
local L_tabNames={"Player","Ball","Auto Goal","GK","OP","Teams","Config","Info"}
local L_curTab="";local L_tabBtns={};local L_tabFrames={}
local function L_mkTab(L_nm,L_idx)
    local L_b=Instance.new("TextButton")L_b.Size=UDim2.new(1,0,0,L_6 and 28 or 30)L_b.Position=UDim2.new(0,0,0,(L_idx-1)*(L_6 and 28 or 30))L_b.BackgroundTransparency=1;L_b.Text=L_nm;L_b.TextColor3=L_cDim;L_b.TextSize=L_fsS;L_b.Font=L_fS;L_b.TextXAlignment=Enum.TextXAlignment.Left;L_b.AutoButtonColor=false;L_b.Parent=L_181
    Instance.new("UIPadding",L_b).PaddingLeft=UDim.new(0,10)
    local L_bar=Instance.new("Frame")L_bar.Size=UDim2.new(0,2,0,14)L_bar.Position=UDim2.new(0,0,0.5,-7)L_bar.BackgroundColor3=Color3.fromRGB(200,200,210)L_bar.BorderSizePixel=0;L_bar.Visible=false;L_bar.Parent=L_b
    local L_div=Instance.new("Frame")L_div.Size=UDim2.new(1,0,0,1)L_div.Position=UDim2.new(0,0,1,-1)L_div.BackgroundColor3=L_cDiv;L_div.BorderSizePixel=0;L_div.Parent=L_b
    L_b.MouseEnter:Connect(function()if L_curTab~=L_nm then L_2:Create(L_b,TweenInfo.new(0.1),{TextColor3=L_cTxt}):Play()end end)
    L_b.MouseLeave:Connect(function()if L_curTab~=L_nm then L_2:Create(L_b,TweenInfo.new(0.1),{TextColor3=L_cDim}):Play()end end)
    return L_b,L_bar
end
local function L_mkScroll()
    local L_f=Instance.new("ScrollingFrame")L_f.Size=UDim2.new(1,0,1,0)L_f.BackgroundTransparency=1;L_f.BorderSizePixel=0;L_f.ScrollBarThickness=2;L_f.ScrollBarImageColor3=Color3.fromRGB(60,60,75)L_f.AutomaticCanvasSize=Enum.AutomaticSize.Y;L_f.CanvasSize=UDim2.new(0,0,0,0)L_f.Visible=false;L_f.Parent=L_183
    local L_l=Instance.new("UIListLayout",L_f)L_l.Padding=UDim.new(0,0)L_l.SortOrder=Enum.SortOrder.LayoutOrder
    return L_f
end
local L_tabBars={}
for L_i,L_nm in ipairs(L_tabNames)do
    local L_btn,L_bar=L_mkTab(L_nm,L_i)
    L_tabBtns[L_nm]=L_btn;L_tabBars[L_nm]=L_bar
    L_tabFrames[L_nm]=L_mkScroll()
    L_btn.MouseButton1Click:Connect(function()
        if L_curTab==L_nm then return end;L_curTab=L_nm
        for L_k,L_v in pairs(L_tabFrames)do L_v.Visible=L_k==L_nm end
        for L_k,L_v in pairs(L_tabBtns)do
            local L_a=L_k==L_nm
            L_v.TextColor3=L_a and L_cTxt or L_cDim
            L_v.Font=L_a and L_fB or L_fS
        end
        for L_k,L_v in pairs(L_tabBars)do L_v.Visible=L_k==L_nm end
    end)
end
local function L_mkSecHdr(L_par,L_nm,L_ord)
    local L_f=Instance.new("Frame")L_f.Size=UDim2.new(1,0,0,L_6 and 22 or 24)L_f.BackgroundTransparency=1;L_f.LayoutOrder=L_ord;L_f.Parent=L_par
    local L_lb=Instance.new("TextLabel")L_lb.Size=UDim2.new(1,-20,1,0)L_lb.Position=UDim2.new(0,10,0,0)L_lb.BackgroundTransparency=1;L_lb.Text=L_nm;L_lb.TextColor3=L_cDim;L_lb.TextSize=L_6 and 8 or 9;L_lb.Font=L_fB;L_lb.TextXAlignment=Enum.TextXAlignment.Left;L_lb.Parent=L_f
end
local function L_mkRow(L_par,L_nm,L_ord)
    local L_rh=L_6 and 32 or 34
    local L_f=Instance.new("Frame")L_f.Size=UDim2.new(1,0,0,L_rh)L_f.BackgroundTransparency=1;L_f.BorderSizePixel=0;L_f.LayoutOrder=L_ord;L_f.Parent=L_par
    local L_lb=Instance.new("TextLabel")L_lb.Size=UDim2.new(1,-110,1,0)L_lb.Position=UDim2.new(0,10,0,0)L_lb.BackgroundTransparency=1;L_lb.Text=L_nm;L_lb.TextColor3=L_cTxt;L_lb.TextSize=L_fs;L_lb.Font=L_fN;L_lb.TextXAlignment=Enum.TextXAlignment.Left;L_lb.Parent=L_f
    local L_dv=Instance.new("Frame")L_dv.Size=UDim2.new(1,-10,0,1)L_dv.Position=UDim2.new(0,5,1,-1)L_dv.BackgroundColor3=L_cDiv;L_dv.BorderSizePixel=0;L_dv.Parent=L_f
    return L_f
end
local function L_mkTog(L_par,L_nm,L_ord,L_cb)
    local L_f=L_mkRow(L_par,L_nm,L_ord)
    local L_rh=L_f.Size.Y.Offset
    local L_tb=Instance.new("TextButton")L_tb.Size=UDim2.new(0,36,0,18)L_tb.Position=UDim2.new(1,-46,0.5,-9)L_tb.BackgroundColor3=L_cToff;L_tb.Text="";L_tb.AutoButtonColor=false;L_tb.Parent=L_f;Instance.new("UICorner",L_tb).CornerRadius=UDim.new(1,0)
    local L_kn=Instance.new("Frame")L_kn.Size=UDim2.new(0,12,0,12)L_kn.Position=UDim2.new(0,3,0.5,-6)L_kn.BackgroundColor3=Color3.fromRGB(130,130,145)L_kn.BorderSizePixel=0;L_kn.Parent=L_tb;Instance.new("UICorner",L_kn).CornerRadius=UDim.new(1,0)
    local L_on=false
    L_tb.MouseButton1Click:Connect(function()
        L_on=not L_on;local L_ti=TweenInfo.new(0.15,Enum.EasingStyle.Quint)
        L_2:Create(L_tb,L_ti,{BackgroundColor3=L_on and Color3.fromRGB(255,255,255) or L_cToff}):Play()
        L_2:Create(L_kn,L_ti,{Position=L_on and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),BackgroundColor3=L_on and Color3.fromRGB(24,24,30) or Color3.fromRGB(130,130,145)}):Play()
        L_cb(L_on)
    end)
    return L_f
end
local function L_mkInp(L_par,L_nm,L_ord,L_def,L_lo,L_hi,L_cb)
    local L_f=L_mkRow(L_par,L_nm,L_ord)
    local L_box=Instance.new("TextBox")L_box.Size=UDim2.new(0,50,0,22)L_box.Position=UDim2.new(1,-58,0.5,-11)L_box.BackgroundColor3=L_cInpBG;L_box.BorderSizePixel=0;L_box.Text=tostring(L_def)L_box.TextColor3=L_cTxt;L_box.TextSize=L_fsS;L_box.Font=L_fN;L_box.ClearTextOnFocus=false;L_box.Parent=L_f;Instance.new("UICorner",L_box).CornerRadius=UDim.new(0,4)
    local L_sk=Instance.new("UIStroke",L_box)L_sk.Color=L_cInpBd;L_sk.Thickness=1
    L_box.Focused:Connect(function()L_2:Create(L_sk,TweenInfo.new(0.1),{Color=Color3.fromRGB(180,180,200)}):Play()end)
    L_box.FocusLost:Connect(function()
        L_2:Create(L_sk,TweenInfo.new(0.1),{Color=L_cInpBd}):Play()
        local L_v=tonumber(L_box.Text)
        if not L_v then L_box.Text=tostring(L_def);return end
        L_v=math.clamp(math.floor(L_v+0.5),L_lo,L_hi)L_box.Text=tostring(L_v)L_cb(L_v)
    end)
    return L_f
end
local function L_mkDropTog(L_par,L_nm,L_ord,L_opts,L_def,L_cb)
    local L_f=L_mkRow(L_par,L_nm,L_ord)
    local L_tb=Instance.new("TextButton")L_tb.Size=UDim2.new(0,36,0,18)L_tb.Position=UDim2.new(1,-46,0.5,-9)L_tb.BackgroundColor3=L_cToff;L_tb.Text="";L_tb.AutoButtonColor=false;L_tb.Parent=L_f;Instance.new("UICorner",L_tb).CornerRadius=UDim.new(1,0)
    local L_kn=Instance.new("Frame")L_kn.Size=UDim2.new(0,12,0,12)L_kn.Position=UDim2.new(0,3,0.5,-6)L_kn.BackgroundColor3=Color3.fromRGB(130,130,145)L_kn.BorderSizePixel=0;L_kn.Parent=L_tb;Instance.new("UICorner",L_kn).CornerRadius=UDim.new(1,0)
    local L_dd=Instance.new("TextButton")L_dd.Size=UDim2.new(0,54,0,22)L_dd.Position=UDim2.new(1,-104,0.5,-11)L_dd.BackgroundColor3=L_cInpBG;L_dd.Text=L_def;L_dd.TextColor3=L_cTxt;L_dd.TextSize=L_fsS;L_dd.Font=L_fN;L_dd.AutoButtonColor=false;L_dd.Parent=L_f;Instance.new("UICorner",L_dd).CornerRadius=UDim.new(0,4)
    Instance.new("UIStroke",L_dd).Color=L_cInpBd
    local L_ddl=Instance.new("Frame")L_ddl.Size=UDim2.new(0,54,0,0)L_ddl.Position=UDim2.new(1,-104,1,2)L_ddl.BackgroundColor3=Color3.fromRGB(20,20,26)L_ddl.BorderSizePixel=0;L_ddl.Visible=false;L_ddl.ClipsDescendants=true;L_ddl.ZIndex=30;L_ddl.Parent=L_f;Instance.new("UICorner",L_ddl).CornerRadius=UDim.new(0,4)
    Instance.new("UIListLayout",L_ddl).SortOrder=Enum.SortOrder.LayoutOrder
    local L_on=false;local L_cur=L_def;local L_open=false
    for _,L_o in ipairs(L_opts)do
        local L_ob=Instance.new("TextButton")L_ob.Size=UDim2.new(1,0,0,20)L_ob.BackgroundTransparency=1;L_ob.Text=L_o;L_ob.TextColor3=L_cDim;L_ob.TextSize=L_fsS;L_ob.Font=L_fN;L_ob.AutoButtonColor=false;L_ob.ZIndex=31;L_ob.Parent=L_ddl
        L_ob.MouseButton1Click:Connect(function()L_cur=L_o;L_dd.Text=L_o;L_open=false;L_2:Create(L_ddl,TweenInfo.new(0.1),{Size=UDim2.new(0,54,0,0)}):Play()task.delay(0.1,function()L_ddl.Visible=false end)L_cb(L_on,L_cur)end)
        L_ob.MouseEnter:Connect(function()L_2:Create(L_ob,TweenInfo.new(0.08),{TextColor3=L_cTxt}):Play()end)
        L_ob.MouseLeave:Connect(function()L_2:Create(L_ob,TweenInfo.new(0.08),{TextColor3=L_cDim}):Play()end)
    end
    L_dd.MouseButton1Click:Connect(function()L_open=not L_open;if L_open then L_ddl.Visible=true;L_2:Create(L_ddl,TweenInfo.new(0.1),{Size=UDim2.new(0,54,0,#L_opts*20)}):Play()else L_2:Create(L_ddl,TweenInfo.new(0.1),{Size=UDim2.new(0,54,0,0)}):Play()task.delay(0.1,function()L_ddl.Visible=false end)end end)
    L_tb.MouseButton1Click:Connect(function()
        L_on=not L_on;local L_ti=TweenInfo.new(0.15,Enum.EasingStyle.Quint)
        L_2:Create(L_tb,L_ti,{BackgroundColor3=L_on and Color3.fromRGB(255,255,255) or L_cToff}):Play()
        L_2:Create(L_kn,L_ti,{Position=L_on and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),BackgroundColor3=L_on and Color3.fromRGB(24,24,30) or Color3.fromRGB(130,130,145)}):Play()
        L_cb(L_on,L_cur)
    end)
    return L_f
end
local L_pC=L_tabFrames["Player"];local L_bC=L_tabFrames["Ball"];local L_agC=L_tabFrames["Auto Goal"]
L_mkSecHdr(L_pC,"Player Reach",0)
L_mkTog(L_pC,"Reach",1,function(L_s)L_7=L_s;L_39:L_89(L_s)if L_s then L_42(L_39.L_67)else L_41()end end)
L_mkInp(L_pC,"Reach X",2,5,1,1000,function(L_v)L_39:L_87(L_v)L_43(L_v)end)
L_mkInp(L_pC,"Reach Y",3,5,1,1000,function(L_v)L_8=L_v end)
L_mkInp(L_pC,"Reach Z",4,5,1,1000,function(L_v)L_8=L_v end)
L_mkInp(L_pC,"Box Transparency",5,80,0,100,function(L_v)L_23=L_v/100;if L_24 and L_24.Parent then L_24.Transparency=L_23 end end)
L_mkSecHdr(L_pC,"Player",6)
L_mkTog(L_pC,"Infinite Stamina",7,function(L_s)L_9=L_s;if L_s then L_108()else L_111()end end)
L_mkTog(L_pC,"Jump Boost",8,function(L_s)L_11=L_s;if L_s then L_112()else L_119()end end)
L_mkInp(L_pC,"Jump Power",9,50,50,300,function(L_v)L_12=L_v end)
L_mkTog(L_pC,"Speed Boost",10,function(L_s)L_13=L_s;if L_s then L_122()else L_127()end end)
L_mkInp(L_pC,"Speed Multiplier",11,2,1,20,function(L_v)L_14=L_v end)
L_mkSecHdr(L_bC,"Ball",0)
L_mkTog(L_bC,"Break React",1,function(L_s)L_27=L_s;if L_s then L_100()else L_107()end end)
L_mkSecHdr(L_agC,"Auto Goal",0)
L_mkDropTog(L_agC,"Auto Goal",1,{"Home","Away"},"Home",function(L_s,L_o)L_15=L_s;L_16=L_o end)
L_mkInp(L_agC,"Shot Power",2,50,1,300,function(L_v)L_17=L_v end)
local function L_switchTab(L_nm)
    if L_curTab==L_nm then return end;L_curTab=L_nm
    for L_k,L_v in pairs(L_tabFrames)do L_v.Visible=L_k==L_nm end
    for L_k,L_v in pairs(L_tabBtns)do L_v.TextColor3=L_k==L_nm and L_cTxt or L_cDim;L_v.Font=L_k==L_nm and L_fB or L_fS end
    for L_k,L_v in pairs(L_tabBars)do L_v.Visible=L_k==L_nm end
end
L_switchTab("Player")
do local L_281,L_282,L_283,L_284=false,nil,nil,nil;L_176.InputBegan:Connect(function(L_285)if L_285.UserInputType==Enum.UserInputType.MouseButton1 or L_285.UserInputType==Enum.UserInputType.Touch then L_281=true;L_283=L_285.Position;L_284=L_175.Position;L_285.Changed:Connect(function()if L_285.UserInputState==Enum.UserInputState.End then L_281=false end end)end end)L_176.InputChanged:Connect(function(L_286)if L_286.UserInputType==Enum.UserInputType.MouseMovement or L_286.UserInputType==Enum.UserInputType.Touch then L_282=L_286 end end)L_31(L_3.InputChanged:Connect(function(L_287)if L_287==L_282 and L_281 then local L_288=L_287.Position-L_283;L_175.Position=UDim2.new(L_284.X.Scale,L_284.X.Offset+L_288.X,L_284.Y.Scale,L_284.Y.Offset+L_288.Y)end end))end
local function L_201()for _,L_289 in ipairs(L_29)do pcall(function()L_289:Disconnect()end)end;L_29={};L_111();L_119();L_127();L_107();L_39:L_86();L_41()end
L_180.MouseButton1Click:Connect(function()L_175.Visible=false end)
L_179.MouseButton1Click:Connect(function()L_2:Create(L_175,TweenInfo.new(0.13,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,L_cW,0,0)}):Play()task.delay(0.18,function()L_201()pcall(function()L_156:Destroy()end)end)end)
L_175.Size=UDim2.new(0,L_cW,0,0)L_175.BackgroundTransparency=1;L_2:Create(L_175,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(0,L_cW,0,L_cH),BackgroundTransparency=0}):Play()
