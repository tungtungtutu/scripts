-- AUTO RETALIATE FPS - FAST AIM
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local RS = game:GetService("RunService")
local Cam = WS.CurrentCamera
local LP = Players.LocalPlayer

local C = {
    Enabled = false,
    Range = 300,
    Duration = 5,
    AutoShoot = true,
    AutoReload = true,
    TPToAttacker = false
}

local LastHP = 0
local Attacker = nil
local RetaliateUntil = 0
local LastReload = 0

WS:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Cam = WS.CurrentCamera
end)

local function StartShoot()
    pcall(function() if mouse1press then mouse1press() end end)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    end)
end

local function StopShoot()
    pcall(function() if mouse1release then mouse1release() end end)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

local function DoReload()
    if tick() - LastReload < 2 then return end
    LastReload = tick()
    pcall(function()
        if keypress then keypress("R") task.wait(0.05) keyrelease("R") end
    end)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end)
end

local function GetMyHRP()
    local ch = LP.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function GetMyHum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function FindAttacker()
    local myHRP = GetMyHRP()
    if not myHRP then return nil end
    local closest, closestDist = nil, C.Range
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if p.Team and LP.Team and p.Team == LP.Team then continue end
        local ch = p.Character
        if not ch then continue end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        local head = ch:FindFirstChild("Head")
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end
        local d = (hrp.Position - myHRP.Position).Magnitude
        if d < closestDist then
            closestDist = d
            closest = {player = p, hrp = hrp, head = head or hrp, hum = hum}
        end
    end
    return closest
end

local function TPTo(hrp)
    local myHRP = GetMyHRP()
    if not myHRP or not hrp then return end
    myHRP.CFrame = CFrame.new(hrp.Position - hrp.CFrame.LookVector * 8, hrp.Position)
end

local function MakeUI()
    local pg = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
    if not pg then return end
    if pg:FindFirstChild("RetaliateFPS") then pg.RetaliateFPS:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "RetaliateFPS"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.Parent = pg
    
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = UDim2.new(0, 15, 0.4, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.Text = "RETAL\nOFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Draggable = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local s1 = Instance.new("UIStroke", btn)
    s1.Color = Color3.fromRGB(255, 100, 100)
    s1.Thickness = 2
    
    btn.MouseButton1Click:Connect(function()
        C.Enabled = not C.Enabled
        btn.Text = "RETAL\n" .. (C.Enabled and "ON" or "OFF")
        btn.BackgroundColor3 = C.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 60, 70)
    end)
end

MakeUI()

-- Theo dõi máu
task.spawn(function()
    while task.wait(0.03) do
        local hum = GetMyHum()
        if hum then
            if LastHP > 0 and hum.Health < LastHP and C.Enabled then
                local attacker = FindAttacker()
                if attacker then
                    Attacker = attacker
                    RetaliateUntil = tick() + C.Duration
                end
            end
            LastHP = hum.Health
        end
    end
end)

-- Vòng lặp trả đũa - AIM TỨC THÌ
task.spawn(function()
    local isShooting = false
    
    while task.wait(0.005) do  -- Nhanh hơn (0.005s)
        if tick() > RetaliateUntil then
            if isShooting then StopShoot(); isShooting = false end
            Attacker = nil
            continue
        end
        
        if not Attacker or not Attacker.player.Parent or not Attacker.hrp or not Attacker.hrp.Parent then
            Attacker = FindAttacker()
        end
        
        if Attacker and Attacker.hum and Attacker.hum.Health > 0 then
            -- AIM TỨC THÌ
            pcall(function()
                Cam.CFrame = CFrame.new(Cam.CFrame.Position, Attacker.head.Position)
            end)
            
            if C.TPToAttacker then TPTo(Attacker.hrp) end
            
            if C.AutoShoot and not isShooting then
                StartShoot()
                isShooting = true
            end
            
            if C.AutoReload and tick() - LastReload > 3 then
                StopShoot(); isShooting = false
                DoReload()
                task.wait(0.3)
            end
        else
            if isShooting then StopShoot(); isShooting = false end
            Attacker = nil
        end
    end
end)

LP.CharacterAdded:Connect(function()
    LastHP = 0
    Attacker = nil
    RetaliateUntil = 0
    task.wait(1)
    MakeUI()
end)

print("🔫 Auto Retaliate FPS - FAST AIM loaded")
