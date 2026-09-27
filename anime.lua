-- ANIME ARENA - SIMPLE FARM + MENU
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local Farm = false
local Range = 200
local Target = nil
local LastAtk = 0
local LastSkill = 0

-- Hàm hỗ trợ click (nhiều cách fallback)
local function DoClick()
    -- Cách 1: dùng mouse1click (nhiều executor hỗ trợ)
    pcall(function()
        if mouse1click then mouse1click() return end
    end)
    -- Cách 2: dùng mouse1press + mouse1release
    pcall(function()
        if mouse1press and mouse1release then
            mouse1press()
            task.wait(0.02)
            mouse1release()
        end
    end)
    -- Cách 3: dùng VirtualInputManager
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- Hàm bấm phím (nhiều cách fallback)
local function DoKey(key)
    pcall(function()
        if keypress then keypress(key) task.wait(0.03) keyrelease(key) return end
    end)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        task.wait(0.03)
        VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

-- Tìm địch gần nhất
local function GetEnemy()
    local myChar = LP.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    local best, bestDist = nil, Range
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if p.Team and LP.Team and p.Team == LP.Team then continue end
        
        local char = p.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end
        
        local d = (hrp.Position - myHRP.Position).Magnitude
        if d < bestDist then
            bestDist = d
            best = {player = p, hrp = hrp}
        end
    end
    return best
end

-- Tạo UI
local gui = Instance.new("ScreenGui")
gui.Name = "AnimeFarm_"..math.random(1000, 9999)
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = LP:WaitForChild("PlayerGui")

-- Nút bật/tắt
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 70, 0, 70)
btn.Position = UDim2.new(0, 20, 0, 100)
btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
btn.Text = "FARM\nOFF"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 13
btn.AutoButtonColor = false
btn.Active = true
btn.Draggable = true
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", btn)
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Thickness = 2

btn.MouseButton1Click:Connect(function()
    Farm = not Farm
    btn.Text = "FARM\n" .. (Farm and "ON" or "OFF")
    btn.BackgroundColor3 = Farm and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 60, 70)
    Target = nil
    print("[Farm]", Farm and "BẬT" or "TẮT")
end)

-- Nút dùng skill
local skillBtn = Instance.new("TextButton", gui)
skillBtn.Size = UDim2.new(0, 70, 0, 70)
skillBtn.Position = UDim2.new(0, 20, 0, 180)
skillBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
skillBtn.Text = "SKILL\nOFF"
skillBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skillBtn.Font = Enum.Font.GothamBold
skillBtn.TextSize = 13
skillBtn.AutoButtonColor = false
skillBtn.Active = true
skillBtn.Draggable = true
Instance.new("UICorner", skillBtn).CornerRadius = UDim.new(1, 0)

local stroke2 = Instance.new("UIStroke", skillBtn)
stroke2.Color = Color3.fromRGB(180, 100, 255)
stroke2.Thickness = 2

local UseSkill = false
skillBtn.MouseButton1Click:Connect(function()
    UseSkill = not UseSkill
    skillBtn.Text = "SKILL\n" .. (UseSkill and "ON" or "OFF")
    skillBtn.BackgroundColor3 = UseSkill and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(60, 60, 70)
    print("[Skill]", UseSkill and "BẬT" or "TẮT")
end)

-- Hiển thị thông tin
local info = Instance.new("TextLabel", gui)
info.Size = UDim2.new(0, 200, 0, 25)
info.Position = UDim2.new(0, 20, 0, 260)
info.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
info.Text = "tungtungtutu - Anime Farm"
info.TextColor3 = Color3.fromRGB(0, 255, 150)
info.Font = Enum.Font.GothamBold
info.TextSize = 12
info.BorderSizePixel = 0
Instance.new("UICorner", info).CornerRadius = UDim.new(0, 6)

-- Vòng lặp farm chính
task.spawn(function()
    while task.wait(0.1) do
        if not Farm then
            Target = nil
            continue
        end
        
        -- Kiểm tra mục tiêu hiện tại
        if Target then
            local hum = Target.player.Character and Target.player.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                Target = nil
            end
        end
        
        -- Tìm mục tiêu mới
        if not Target then
            Target = GetEnemy()
        end
        
        -- Tấn công
        if Target then
            local myChar = LP.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHRP and Target.hrp and Target.hrp.Parent then
                -- Teleport tới địch
                myHRP.CFrame = CFrame.new(Target.hrp.Position - Target.hrp.CFrame.LookVector * 3, Target.hrp.Position)
                
                -- Click đánh
                if tick() - LastAtk > 0.1 then
                    LastAtk = tick()
                    DoClick()
                end
                
                -- Bấm skill
                if UseSkill and tick() - LastSkill > 0.5 then
                    LastSkill = tick()
                    for _, k in ipairs({"Z", "X", "C", "V", "F", "G"}) do
                        DoKey(k)
                    end
                end
            end
        end
    end
end)

print([[
====================================
  ⚔️ tungtungtutu - Anime Farm
  🎯 Bấm nút FARM để bật/tắt
  ⚡ Bấm nút SKILL để dùng chiêu
====================================
]])
