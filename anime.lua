-- ANIME ARENA - MENU + ẢNH + FARM
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local C = {
    Farm = false,
    Skill = false,
    Range = 200,
    AtkCD = 0.1,
    SkillCD = 0.5,
    TP = true,
    Keys = {Z=true, X=true, C=true, V=true, F=true, G=true},
    MemeURL = "rbxassetid://13329309365"
}

local Target, LastAtk, LastSkill = nil, 0, 0

-- CLICK (nhiều fallback)
local function DoClick()
    pcall(function() if mouse1click then mouse1click() end end)
    pcall(function()
        if mouse1press and mouse1release then
            mouse1press() task.wait(0.02) mouse1release()
        end
    end)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(0,0,0,true,game,0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0,0,0,false,game,0)
    end)
end

-- BẤM PHÍM (nhiều fallback)
local function DoKey(key)
    pcall(function()
        if keypress then keypress(key) task.wait(0.03) keyrelease(key) end
    end)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        task.wait(0.03)
        VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

-- TÌM ĐỊCH
local function GetEnemy()
    local myChar = LP.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local best, bd = nil, C.Range
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if p.Team and LP.Team and p.Team == LP.Team then continue end
        local ch = p.Character
        if not ch then continue end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end
        local d = (hrp.Position - myHRP.Position).Magnitude
        if d < bd then bd = d; best = {player=p, hrp=hrp} end
    end
    return best
end

-- TẠO MENU
local function MakeUI()
    local pg = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
    if not pg then return end
    if pg:FindFirstChild("AnimeFarmMenu") then pg.AnimeFarmMenu:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "AnimeFarmMenu"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.Parent = pg

    -- Nút mở menu
    local openBtn = Instance.new("TextButton", gui)
    openBtn.Size = UDim2.new(0, 55, 0, 55)
    openBtn.Position = UDim2.new(0, 15, 0, 100)
    openBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    openBtn.Text = "☰"
    openBtn.TextSize = 26
    openBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.AutoButtonColor = false
    openBtn.Active = true
    openBtn.Draggable = true
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    local obs = Instance.new("UIStroke", openBtn)
    obs.Color = Color3.fromRGB(0, 255, 150)
    obs.Thickness = 2

    -- Menu
    local main = Instance.new("Frame", gui)
    main.Name = "Main"
    main.Size = UDim2.new(0, 320, 0, 460)
    main.Position = UDim2.new(0.5, -160, 0.5, -230)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Visible = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local ms = Instance.new("UIStroke", main)
    ms.Color = Color3.fromRGB(0, 255, 150)
    ms.Thickness = 1.5
    ms.Transparency = 0.3

    -- HEADER có ảnh
    local hdr = Instance.new("Frame", main)
    hdr.Size = UDim2.new(1, 0, 0, 100)
    hdr.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    hdr.BorderSizePixel = 0
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 10)
    local hf = Instance.new("Frame", hdr)
    hf.Size = UDim2.new(1, 0, 0, 12)
    hf.Position = UDim2.new(0, 0, 1, -12)
    hf.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    hf.BorderSizePixel = 0

    local img = Instance.new("ImageLabel", hdr)
    img.Size = UDim2.new(0, 70, 0, 70)
    img.Position = UDim2.new(0, 15, 0.5, -35)
    img.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    img.BorderSizePixel = 0
    img.Image = C.MemeURL
    img.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 8)
    local is = Instance.new("UIStroke", img)
    is.Color = Color3.fromRGB(0, 255, 150)
    is.Thickness = 1.5

    local title = Instance.new("TextLabel", hdr)
    title.Size = UDim2.new(1, -120, 0, 30)
    title.Position = UDim2.new(0, 95, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ tungtungtutu"
    title.TextColor3 = Color3.fromRGB(0, 255, 150)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 17
    title.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", hdr)
    sub.Size = UDim2.new(1, -120, 0, 20)
    sub.Position = UDim2.new(0, 95, 0, 55)
    sub.BackgroundTransparency = 1
    sub.Text = "Anime Arena • Auto Farm"
    sub.TextColor3 = Color3.fromRGB(150, 150, 160)
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", hdr)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

    -- SCROLL
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -115)
    scroll.Position = UDim2.new(0, 10, 0, 108)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8)

    -- Toggle
    local function Toggle(text, default, cb)
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -20, 0, 40)
        f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.7, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(230, 230, 230)
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 14
        l.TextXAlignment = Enum.TextXAlignment.Left
        local tb = Instance.new("TextButton", f)
        tb.Size = UDim2.new(0, 55, 0, 30)
        tb.Position = UDim2.new(1, -55, 0.5, -15)
        tb.BackgroundColor3 = default and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 70)
        tb.Text = ""
        tb.AutoButtonColor = false
        Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)
        local k = Instance.new("Frame", tb)
        k.Size = UDim2.new(0, 24, 0, 24)
        k.Position = default and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
        k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        k.BorderSizePixel = 0
        Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
        local s = default
        tb.MouseButton1Click:Connect(function()
            s = not s
            tb.BackgroundColor3 = s and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 70)
            k.Position = s and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
            cb(s)
        end)
    end

    -- Slider
    local function Slider(text, mn, mx, default, cb)
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -20, 0, 55)
        f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.7, 0, 0, 20)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(230, 230, 230)
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 14
        l.TextXAlignment = Enum.TextXAlignment.Left
        local v = Instance.new("TextLabel", f)
        v.Size = UDim2.new(0.3, 0, 0, 20)
        v.Position = UDim2.new(0.7, 0, 0, 0)
        v.BackgroundTransparency = 1
        v.Text = tostring(default)
        v.TextColor3 = Color3.fromRGB(0, 255, 150)
        v.Font = Enum.Font.GothamBold
        v.TextSize = 14
        v.TextXAlignment = Enum.TextXAlignment.Right
        local bar = Instance.new("Frame", f)
        bar.Size = UDim2.new(1, 0, 0, 20)
        bar.Position = UDim2.new(0, 0, 0, 28)
        bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((default - mn) / (mx - mn), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local drag = false
        local function upd(x)
            local r = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(mn + (mx - mn) * r)
            fill.Size = UDim2.new(r, 0, 1, 0)
            v.Text = tostring(val)
            cb(val)
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; upd(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                upd(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
        end)
    end

    -- Nội dung menu
    Toggle("Bật Auto Farm", C.Farm, function(s) C.Farm = s; Target = nil end)
    Toggle("Teleport tới địch", C.TP, function(s) C.TP = s end)
    Slider("Phạm vi", 50, 500, C.Range, function(v) C.Range = v end)
    Slider("Delay đánh (x10ms)", 1, 30, C.AtkCD * 100, function(v) C.AtkCD = v / 100 end)

    Toggle("Tự dùng chiêu", C.Skill, function(s) C.Skill = s end)
    Slider("Delay chiêu (x10ms)", 1, 50, C.SkillCD * 100, function(v) C.SkillCD = v / 100 end)

    local kl = Instance.new("TextLabel", scroll)
    kl.Size = UDim2.new(1, -20, 0, 22)
    kl.BackgroundTransparency = 1
    kl.Text = "Chọn phím chiêu:"
    kl.TextColor3 = Color3.fromRGB(180, 100, 255)
    kl.Font = Enum.Font.GothamBold
    kl.TextSize = 13
    kl.TextXAlignment = Enum.TextXAlignment.Left

    local kf = Instance.new("Frame", scroll)
    kf.Size = UDim2.new(1, -20, 0, 40)
    kf.BackgroundTransparency = 1
    local kfl = Instance.new("UIListLayout", kf)
    kfl.FillDirection = Enum.FillDirection.Horizontal
    kfl.Padding = UDim.new(0, 5)
    kfl.HorizontalAlignment = Enum.HorizontalAlignment.Center

    for _, key in ipairs({"Z","X","C","V","F","G"}) do
        local kb = Instance.new("TextButton", kf)
        kb.Size = UDim2.new(0, 44, 0, 36)
        kb.BackgroundColor3 = C.Keys[key] and Color3.fromRGB(180, 100, 255) or Color3.fromRGB(35, 35, 45)
        kb.Text = key
        kb.TextColor3 = Color3.fromRGB(255, 255, 255)
        kb.Font = Enum.Font.GothamBold
        kb.TextSize = 14
        kb.AutoButtonColor = false
        Instance.new("UICorner", kb).CornerRadius = UDim.new(0, 6)
        kb.MouseButton1Click:Connect(function()
            C.Keys[key] = not C.Keys[key]
            kb.BackgroundColor3 = C.Keys[key] and Color3.fromRGB(180, 100, 255) or Color3.fromRGB(35, 35, 45)
        end)
    end

    openBtn.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)
end

MakeUI()

-- VÒNG LẶP FARM
task.spawn(function()
    while task.wait(0.1) do
        if not C.Farm then Target = nil continue end
        if Target then
            local hum = Target.player.Character and Target.player.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then Target = nil end
        end
        Target = Target or GetEnemy()
        if Target then
            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if myHRP and Target.hrp and Target.hrp.Parent then
                if C.TP then
                    myHRP.CFrame = CFrame.new(Target.hrp.Position - Target.hrp.CFrame.LookVector * 3, Target.hrp.Position)
                end
                if tick() - LastAtk > C.AtkCD then
                    LastAtk = tick()
                    DoClick()
                end
                if C.Skill and tick() - LastSkill > C.SkillCD then
                    LastSkill = tick()
                    for _, k in ipairs({"Z","X","C","V","F","G"}) do
                        if C.Keys[k] then DoKey(k) end
                    end
                end
            end
        end
    end
end)

LP.CharacterAdded:Connect(function() Target = nil end)

print("⚔️ Anime Farm loaded - tungtungtutu")
