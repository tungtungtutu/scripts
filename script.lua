-- AUTO RETALIATE - GAME BẮN SÚNG (FPS/TPS)
-- Chạy trên Delta, Fluxus, Solara, Xeno
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local Cam = WS.CurrentCamera
local LP = Players.LocalPlayer

local C = {
    Enabled = false,
    Range = 300,          -- Phạm vi tìm địch (studs)
    Duration = 5,         -- Thời gian trả đũa
    AimSmooth = 0.3,      -- Độ mượt khi aim (0.1 = tức thì)
    AutoShoot = true,     -- Tự bắn khi aim
    AutoReload = true,    -- Tự reload khi hết đạn
    ShootDuration = 0.3,  -- Thời gian bắn mỗi lần
    TPToAttacker = false  -- Teleport tới kẻ đánh
}

local LastHP = 0
local Attacker = nil
local RetaliateUntil = 0
local LastShoot = 0
local LastReload = 0

-- ============ HÀM HỖ TRỢ ============
-- Bắn súng (giữ chuột trái)
local function StartShoot()
    pcall(function()
        if mouse1press then mouse1press() end
    end)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    end)
end

local function StopShoot()
    pcall(function()
        if mouse1release then mouse1release() end
    end)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- Reload (phím R)
local function DoReload()
    if tick() - LastReload < 2 then return end  -- Chờ 2s giữa các lần reload
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

-- ============ AIM VÀO ĐỊCH ============
local function AimAt(hrp)
    if not hrp then return end
    local target = hrp.Position
    local current = Cam.CFrame
    local look = CFrame.new(current.Position, target)
    
    if C.AimSmooth >= 1 then
        Cam.CFrame = look
    else
        Cam.CFrame = current:Lerp(look, C.AimSmooth)
    end
end

-- ============ TÌM ĐỊCH ============
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

-- Teleport tới địch (nếu bật)
local function TPTo(hrp)
    local myHRP = GetMyHRP()
    if not myHRP or not hrp then return end
    myHRP.CFrame = CFrame.new(hrp.Position - hrp.CFrame.LookVector * 8, hrp.Position)
end

-- ============ UI ============
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
    
    -- Nút RETAL
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
        print("[Retaliate FPS]", C.Enabled and "BẬT" or "TẮT")
    end)
    
    -- Nút AUTO SHOOT
    local shootBtn = Instance.new("TextButton", gui)
    shootBtn.Size = UDim2.new(0, 80, 0, 80)
    shootBtn.Position = UDim2.new(0, 15, 0.4, 90)
    shootBtn.BackgroundColor3 = C.AutoShoot and Color3.fromRGB(200, 100, 50) or Color3.fromRGB(60, 60, 70)
    shootBtn.Text = "SHOOT\n" .. (C.AutoShoot and "ON" or "OFF")
    shootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    shootBtn.Font = Enum.Font.GothamBold
    shootBtn.TextSize = 13
    shootBtn.AutoButtonColor = false
    shootBtn.Active = true
    shootBtn.Draggable = true
    Instance.new("UICorner", shootBtn).CornerRadius = UDim.new(1, 0)
    
    local s2 = Instance.new("UIStroke", shootBtn)
    s2.Color = Color3.fromRGB(255, 150, 50)
    s2.Thickness = 2
    
    shootBtn.MouseButton1Click:Connect(function()
        C.AutoShoot = not C.AutoShoot
        shootBtn.Text = "SHOOT\n" .. (C.AutoShoot and "ON" or "OFF")
        shootBtn.BackgroundColor3 = C.AutoShoot and Color3.fromRGB(200, 100, 50) or Color3.fromRGB(60, 60, 70)
    end)
    
    -- Nút RELOAD
    local reloadBtn = Instance.new("TextButton", gui)
    reloadBtn.Size = UDim2.new(0, 80, 0, 80)
    reloadBtn.Position = UDim2.new(0, 15, 0.4, 180)
    reloadBtn.BackgroundColor3 = C.AutoReload and Color3.fromRGB(50, 150, 200) or Color3.fromRGB(60, 60, 70)
    reloadBtn.Text = "RELOAD\n" .. (C.AutoReload and "ON" or "OFF")
    reloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    reloadBtn.Font = Enum.Font.GothamBold
    reloadBtn.TextSize = 13
    reloadBtn.AutoButtonColor = false
    reloadBtn.Active = true
    reloadBtn.Draggable = true
    Instance.new("UICorner", reloadBtn).CornerRadius = UDim.new(1, 0)
    
    local s3 = Instance.new("UIStroke", reloadBtn)
    s3.Color = Color3.fromRGB(50, 200, 255)
    s3.Thickness = 2
    
    reloadBtn.MouseButton1Click:Connect(function()
        C.AutoReload = not C.AutoReload
        reloadBtn.Text = "RELOAD\n" .. (C.AutoReload and "ON" or "OFF")
        reloadBtn.BackgroundColor3 = C.AutoReload and Color3.fromRGB(50, 150, 200) or Color3.fromRGB(60, 60, 70)
    end)
    
    -- Info
    local info = Instance.new("TextLabel", gui)
    info.Size = UDim2.new(0, 200, 0, 25)
    info.Position = UDim2.new(0, 15, 0.4, 270)
    info.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    info.Text = "Retaliate FPS - Chờ..."
    info.TextColor3 = Color3.fromRGB(255, 100, 100)
    info.Font = Enum.Font.GothamBold
    info.TextSize = 11
    info.BorderSizePixel = 0
    Instance.new("UICorner", info).CornerRadius = UDim.new(0, 6)
end

MakeUI()

-- ============ THEO DÕI MÁU ============
task.spawn(function()
    while task.wait(0.05) do
        local hum = GetMyHum()
        if hum then
            if LastHP > 0 and hum.Health < LastHP and C.Enabled then
                local dmg = LastHP - hum.Health
                print("[Retaliate] Bị bắn! Mất", math.floor(dmg), "máu")
                local attacker = FindAttacker()
                if attacker then
                    Attacker = attacker
                    RetaliateUntil = tick() + C.Duration
                    print("[Retaliate] Trả đũa:", attacker.player.Name)
                end
            end
            LastHP = hum.Health
        end
    end
end)

-- ============ VÒNG LẶP TRẢ ĐŨA ============
task.spawn(function()
    local isShooting = false
    
    while task.wait(0.02) do
        -- Hết thời gian trả đũa
        if tick() > RetaliateUntil then
            if isShooting then
                StopShoot()
                isShooting = false
            end
            Attacker = nil
            continue
        end
        
        -- Tìm lại kẻ địch
        if not Attacker or not Attacker.player.Parent or not Attacker.hrp or not Attacker.hrp.Parent then
            Attacker = FindAttacker()
        end
        
        if Attacker then
            local hum = Attacker.hum
            if hum and hum.Health > 0 then
                -- Aim vào đầu
                AimAt(Attacker.head)
                
                -- TP tới địch (nếu bật)
                if C.TPToAttacker then
                    TPTo(Attacker.hrp)
                end
                
                -- Bắn
                if C.AutoShoot then
                    if not isShooting then
                        StartShoot()
                        isShooting = true
                    end
                    -- Tự reload mỗi 3s
                    if C.AutoReload and tick() - LastReload > 3 then
                        StopShoot()
                        isShooting = false
                        DoReload()
                        task.wait(0.5)
                    end
                end
            else
                if isShooting then
                    StopShoot()
                    isShooting = false
                end
                Attacker = nil
                RetaliateUntil = 0
            end
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

print([[
====================================
  🔫 AUTO RETALIATE - FPS/TPS
====================================
  🎯 RETAL: Tự bắn trả khi bị đánh
  🔫 SHOOT: Tự bắn (giữ chuột)
  🔄 RELOAD: Tự reload
====================================
]])
