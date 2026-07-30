-- ============================================================
-- NKNO$ HUB ULTIMATE v5.2
-- Исправлен флинг, автофарм, добавлены категории Scam Trade и Add Weapons
-- Прозрачные категории, выбор языка, заморозка трейда, спавн оружия
-- ============================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Версия
local SCRIPT_VERSION = "5.2"
local UPDATE_MESSAGE = {
    ru = "Обновление v5.2:\n- Прозрачные категории\n- Исправлен флинг\n- Автофарм починен\n- Scam Trade (заморозка трейда)\n- Add Weapons (спавн оружия)",
    en = "Update v5.2:\n- Transparent categories\n- Fling fixed\n- Auto-farm fixed\n- Scam Trade (freeze trade)\n- Add Weapons (spawn weapons)"
}

-- Настройки языка
if not getgenv().NKNO then getgenv().NKNO = {} end

local function selectLanguage()
    if getgenv().NKNO.Language then return end
    local LangGui = Instance.new("ScreenGui")
    LangGui.Name = "LanguageSelector"
    LangGui.Parent = CoreGui
    LangGui.ResetOnSpawn = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
    frame.BorderSizePixel = 0
    frame.Parent = LangGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60,60,80)
    stroke.Thickness = 1.5
    stroke.Parent = frame
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,50)
    title.BackgroundTransparency = 1
    title.Text = "Select Language / Выберите язык"
    title.TextColor3 = Color3.fromRGB(255,215,0)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    local btnRu = Instance.new("TextButton")
    btnRu.Size = UDim2.new(0.4,0,0,40)
    btnRu.Position = UDim2.new(0.05,0,0.6,0)
    btnRu.BackgroundColor3 = Color3.fromRGB(50,50,70)
    btnRu.Text = "Русский"
    btnRu.TextColor3 = Color3.fromRGB(255,255,255)
    btnRu.TextSize = 18
    btnRu.Font = Enum.Font.GothamBold
    btnRu.Parent = frame
    Instance.new("UICorner", btnRu).CornerRadius = UDim.new(0,8)
    btnRu.MouseButton1Click:Connect(function()
        getgenv().NKNO.Language = "ru"
        LangGui:Destroy()
        Notify("Язык выбран", "Русский", 3)
        showUpdateNotice()
        rebuildGUI()
    end)
    local btnEn = Instance.new("TextButton")
    btnEn.Size = UDim2.new(0.4,0,0,40)
    btnEn.Position = UDim2.new(0.55,0,0.6,0)
    btnEn.BackgroundColor3 = Color3.fromRGB(50,50,70)
    btnEn.Text = "English"
    btnEn.TextColor3 = Color3.fromRGB(255,255,255)
    btnEn.TextSize = 18
    btnEn.Font = Enum.Font.GothamBold
    btnEn.Parent = frame
    Instance.new("UICorner", btnEn).CornerRadius = UDim.new(0,8)
    btnEn.MouseButton1Click:Connect(function()
        getgenv().NKNO.Language = "en"
        LangGui:Destroy()
        Notify("Language selected", "English", 3)
        showUpdateNotice()
        rebuildGUI()
    end)
end

local function showUpdateNotice()
    local lang = getgenv().NKNO.Language or "ru"
    local msg = UPDATE_MESSAGE[lang] or UPDATE_MESSAGE.ru
    Notify("NKNO$ HUB " .. SCRIPT_VERSION, msg, 8)
end

-- Discord кнопка
local function createDiscordButton()
    if CoreGui:FindFirstChild("DiscordButton") then return end
    local btnGui = Instance.new("ScreenGui")
    btnGui.Name = "DiscordButton"
    btnGui.Parent = CoreGui
    btnGui.ResetOnSpawn = false
    btnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0, 10, 1, -70)
    btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Parent = btnGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = "DC"
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextSize = 24
    label.Font = Enum.Font.GothamBold
    label.Parent = btn
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0, 80, 0, 20)
    text.Position = UDim2.new(0, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "Discord"
    text.TextColor3 = Color3.fromRGB(200,200,220)
    text.TextSize = 12
    text.Font = Enum.Font.GothamMedium
    text.Parent = btn
    btn.MouseButton1Click:Connect(function()
        GuiService:OpenBrowserWindow("https://discord.gg/vQUM4JapP")
    end)
    local drag, startPos, startMouse
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            startPos = btn.Position
            startMouse = input.Position
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ============================================================
-- НАСТРОЙКИ ПО УМОЛЧАНИЮ
-- ============================================================

if not getgenv().NKNO.Language then getgenv().NKNO.Language = "ru" end
getgenv().NKNO.AntiFling = getgenv().NKNO.AntiFling or false
getgenv().NKNO.AutoGrabGun = getgenv().NKNO.AutoGrabGun or false
getgenv().NKNO.FarmCoins = getgenv().NKNO.FarmCoins or false
getgenv().NKNO.FarmUnderMap = getgenv().NKNO.FarmUnderMap ~= false
getgenv().NKNO.FarmMode = getgenv().NKNO.FarmMode or "Nearest"
getgenv().NKNO.AntiAFK = getgenv().NKNO.AntiAFK or false
getgenv().NKNO.UnderMap = getgenv().NKNO.UnderMap or false
getgenv().NKNO.CustomWalkSpeed = getgenv().NKNO.CustomWalkSpeed or false
getgenv().NKNO.WalkSpeedValue = getgenv().NKNO.WalkSpeedValue or 16
getgenv().NKNO.CustomJumpPower = getgenv().NKNO.CustomJumpPower or false
getgenv().NKNO.JumpPowerValue = getgenv().NKNO.JumpPowerValue or 50
getgenv().NKNO.CustomFOV = getgenv().NKNO.CustomFOV or false
getgenv().NKNO.FOVValue = getgenv().NKNO.FOVValue or 70
getgenv().NKNO.ForceFieldMaterial = getgenv().NKNO.ForceFieldMaterial or false
getgenv().NKNO.AutoDance = getgenv().NKNO.AutoDance or false
getgenv().NKNO.DanceID = getgenv().NKNO.DanceID or "127118661424463"
getgenv().NKNO.AutoRespawn = getgenv().NKNO.AutoRespawn or false
getgenv().NKNO.GodMode = getgenv().NKNO.GodMode or false
getgenv().NKNO.Theme = getgenv().NKNO.Theme or "Dark"
getgenv().NKNO.AntiSheriff = getgenv().NKNO.AntiSheriff or false
getgenv().NKNO.ScamTrade = getgenv().NKNO.ScamTrade or false  -- заморозка трейда
getgenv().NKNO.ScamTarget = nil
getgenv().NKNO.ESP = getgenv().NKNO.ESP or {
    Murderer = false, Sheriff = false, Innocent = false, Hero = false,
    Box2D = false, DisplayName = false, NormalName = true,
    ColorMurderer = Color3.fromRGB(255,0,0),
    ColorSheriff = Color3.fromRGB(0,0,255),
    ColorHero = Color3.fromRGB(255,255,0),
    ColorInnocent = Color3.fromRGB(0,255,0),
    FontSize = 14,
}
getgenv().NKNO.Flinging = false
getgenv().NKNO.SelectedPlayer = nil
getgenv().NKNO.SelectedPlayerName = nil

-- ============================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================

local function findMap()
    for _, child in pairs(Workspace:GetChildren()) do
        if child:GetAttribute("MapID") then return child end
    end
    return nil
end

local function getPlayerData()
    local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not remote then return nil end
    local success, data = pcall(function() return remote:InvokeServer() end)
    return success and data or nil
end

local function getPing()
    return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end

local function findMurderer()
    local data = getPlayerData()
    if not data then return nil end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
            local info = data[plr.Name]
            if info and info.Role == "Murderer" then return plr end
        end
    end
    return nil
end

local function findSheriff()
    local data = getPlayerData()
    if not data then return nil end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
            local info = data[plr.Name]
            if info and info.Role == "Sheriff" then return plr end
        end
    end
    return nil
end

-- ============================================================
-- ОСНОВНЫЕ ФУНКЦИИ
-- ============================================================

local function applyWalkSpeed()
    if getgenv().NKNO.CustomWalkSpeed and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = getgenv().NKNO.WalkSpeedValue end
    end
end
local function applyJumpPower()
    if getgenv().NKNO.CustomJumpPower and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = getgenv().NKNO.JumpPowerValue end
    end
end
local function applyFOV()
    if getgenv().NKNO.CustomFOV and Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = getgenv().NKNO.FOVValue
    end
end
local function applyForceField()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Material = Enum.Material.ForceField
        end
    end
end
local function restoreMaterial()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Material = Enum.Material.Plastic
        end
    end
end

-- Танцы
local danceAnim = nil
local function playDance()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    if danceAnim then
        pcall(function() danceAnim:Stop() end)
        pcall(function() danceAnim:Destroy() end)
        danceAnim = nil
    end
    task.wait(0.1)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. getgenv().NKNO.DanceID
    pcall(function()
        danceAnim = animator:LoadAnimation(anim)
        danceAnim.Looped = true
        danceAnim.Priority = Enum.AnimationPriority.Action
        danceAnim:Play(0.1,1,1)
    end)
    anim:Destroy()
end
local function stopDance()
    if danceAnim then
        pcall(function() danceAnim:Stop() end)
        pcall(function() danceAnim:Destroy() end)
        danceAnim = nil
    end
end

-- ============================================================
-- ФЛИНГ (АГРЕССИВНЫЙ, ИСПРАВЛЕННЫЙ)
-- ============================================================
local function SkidFling(plr)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local root = hum.RootPart
    if not root then return end
    local targetChar = plr.Character
    if not targetChar then return end
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    local targetRoot = targetHum and targetHum.RootPart
    if not targetRoot then return end
    if targetHum and targetHum.Sit then return end

    Workspace.FallenPartsDestroyHeight = 0/0
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    -- Создаём BodyVelocity для постоянного движения
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.P = 9e9
    bv.Parent = root

    local startTime = tick()
    while getgenv().NKNO.Flinging and tick() - startTime < 4 do
        local targetPos = targetRoot.Position
        local dir = (targetPos - root.Position).Unit
        -- Резкие телепортации в разные стороны относительно цели
        for i = 1, 10 do
            local offset = Vector3.new(math.random(-20,20), math.random(5,30), math.random(-20,20))
            root.CFrame = CFrame.new(targetPos + offset)
            root.Velocity = dir * 9e7 + Vector3.new(0, 5e6, 0)
            bv.Velocity = dir * 9e7 + Vector3.new(0, 5e6, 0)
            task.wait(0.01)
        end
        -- Пролёт сквозь цель
        for i = 1, 5 do
            root.CFrame = CFrame.new(targetPos + dir * (5 + i*2))
            root.Velocity = dir * 9e7
            bv.Velocity = dir * 9e7
            task.wait(0.01)
        end
        task.wait()
    end

    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Workspace.FallenPartsDestroyHeight = getgenv().FPDH or Workspace.FallenPartsDestroyHeight
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    root.Velocity = Vector3.new(0,0,0)
    root.RotVelocity = Vector3.new(0,0,0)
end

-- Подкарта
local underMapConnection = nil
local oldFallenHeight = Workspace.FallenPartsDestroyHeight
local function goUnderMap()
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    oldFallenHeight = Workspace.FallenPartsDestroyHeight
    Workspace.FallenPartsDestroyHeight = -1/0
    local map = findMap()
    local underY = -500
    if map and map:FindFirstChild("Spawns") then
        local total = Vector3.new()
        local count = 0
        for _, spawn in pairs(map.Spawns:GetChildren()) do
            if spawn:IsA("BasePart") then
                total = total + spawn.Position
                count = count + 1
            end
        end
        if count > 0 then
            local center = total / count
            underY = center.Y - 100
        end
    end
    local targetCF = CFrame.new(root.Position.X, underY, root.Position.Z)
    root.CFrame = targetCF
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    local bv = Instance.new("BodyVelocity")
    bv.Parent = root
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    underMapConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().NKNO.UnderMap or not LocalPlayer.Character or not root then
            if bv then bv:Destroy() end
            if underMapConnection then underMapConnection:Disconnect() end
            return
        end
        if (root.Position - targetCF.p).Magnitude > 5 then
            root.CFrame = targetCF
        end
        root.Velocity = Vector3.new(0,0,0)
        root.RotVelocity = Vector3.new(0,0,0)
    end)
end

local function returnFromUnderMap()
    if underMapConnection then
        underMapConnection:Disconnect()
        underMapConnection = nil
    end
    Workspace.FallenPartsDestroyHeight = oldFallenHeight
    if LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = root:FindFirstChildOfClass("BodyVelocity")
            if bv then bv:Destroy() end
        end
        local map = findMap()
        if map and map:FindFirstChild("Spawns") then
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 then
                local spawn = spawns[math.random(1,#spawns)]
                if spawn:IsA("BasePart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0)
                end
            end
        end
    end
end

-- ESP
local espHighlights = {}
local espNames = {}
local function updateESP()
    local data = getPlayerData()
    if not data then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local alive = plr:GetAttribute("Alive") == true
        local role = "Innocent"
        if data and data[plr.Name] then role = data[plr.Name].Role or "Innocent" end
        local show = getgenv().NKNO.ESP[role] or false
        local color = getgenv().NKNO.ESP["Color" .. role] or Color3.fromRGB(255,255,255)

        if alive and show and plr.Character then
            local highlight = espHighlights[plr]
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "NKNO_ESP"
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillTransparency = 0.4
                highlight.OutlineTransparency = 0
                highlight.Parent = plr.Character
                espHighlights[plr] = highlight
            end
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.Adornee = plr.Character

            local head = plr.Character:FindFirstChild("Head")
            if head then
                local gui = espNames[plr]
                if not gui then
                    gui = Instance.new("BillboardGui")
                    gui.Name = "NKNO_Name"
                    gui.AlwaysOnTop = true
                    gui.Size = UDim2.new(0,200,0,50)
                    gui.StudsOffset = Vector3.new(0,2.5,0)
                    gui.Parent = head
                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = ""
                    label.TextColor3 = color
                    label.TextSize = getgenv().NKNO.ESP.FontSize or 14
                    label.Font = Enum.Font.GothamBold
                    label.TextStrokeTransparency = 0.3
                    label.TextStrokeColor3 = Color3.new(0,0,0)
                    label.Parent = gui
                    espNames[plr] = gui
                end
                local label = gui:FindFirstChild("Label")
                if label then
                    local name = getgenv().NKNO.ESP.DisplayName and plr.DisplayName or (getgenv().NKNO.ESP.NormalName and plr.Name or "")
                    label.Text = name
                    label.TextColor3 = color
                end
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root and getgenv().NKNO.ESP.Box2D then
                    local box = root:FindFirstChild("NKNO_Box")
                    if not box then
                        box = Instance.new("BillboardGui")
                        box.Name = "NKNO_Box"
                        box.AlwaysOnTop = true
                        box.Size = UDim2.new(4,0,5,0)
                        box.StudsOffset = Vector3.new(0,0,0)
                        box.Parent = root
                        local frame = Instance.new("Frame")
                        frame.Name = "BoxFrame"
                        frame.BackgroundTransparency = 1
                        frame.Size = UDim2.new(1,0,1,0)
                        frame.BorderSizePixel = 2
                        frame.BorderColor3 = color
                        frame.Parent = box
                        local stroke = Instance.new("UIStroke")
                        stroke.Thickness = 2
                        stroke.Color = color
                        stroke.Parent = frame
                    end
                else
                    local box = root and root:FindFirstChild("NKNO_Box")
                    if box then box:Destroy() end
                end
            end
        else
            if espHighlights[plr] then
                espHighlights[plr]:Destroy()
                espHighlights[plr] = nil
            end
            if espNames[plr] then
                espNames[plr]:Destroy()
                espNames[plr] = nil
            end
            if plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local box = root:FindFirstChild("NKNO_Box")
                    if box then box:Destroy() end
                end
            end
        end
    end
end

-- Авто-граб пистолета
local function autoGrabGun()
    pcall(function()
        if not getgenv().NKNO.AutoGrabGun then return end
        if not LocalPlayer:GetAttribute("Alive") then return end
        local map = findMap()
        if not map then return end
        local gunDrop = map:FindFirstChild("GunDrop")
        if gunDrop then
            gunDrop.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- ============================================================
-- АНТИ-ФЛИНГ
-- ============================================================
local antiFlingConnection = nil
local lastPosition = nil
local function startAntiFling()
    if antiFlingConnection then antiFlingConnection:Disconnect() end
    antiFlingConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().NKNO.AntiFling then return end
        if not LocalPlayer.Character then return end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        if lastPosition then
            local dist = (root.Position - lastPosition).Magnitude
            if dist > 10 then
                root.Velocity = Vector3.new(0,0,0)
                root.RotVelocity = Vector3.new(0,0,0)
                root.CFrame = CFrame.new(lastPosition) * root.CFrame.Rotation
                local bp = root:FindFirstChildOfClass("BodyPosition")
                if not bp then
                    bp = Instance.new("BodyPosition")
                    bp.MaxForce = Vector3.new(9e9,9e9,9e9)
                    bp.P = 10000
                    bp.D = 1000
                    bp.Parent = root
                end
                bp.Position = lastPosition
                task.wait(0.1)
                bp:Destroy()
            end
        end
        lastPosition = root.Position
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopAntiFling()
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    lastPosition = nil
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ============================================================
-- АНТИ ШЕРИФ
-- ============================================================
local function antiSheriff()
    if not getgenv().NKNO.AntiSheriff then return end
    for _, bullet in pairs(Workspace:GetDescendants()) do
        if bullet:IsA("BasePart") and bullet.Name:lower():find("bullet") then
            bullet.CanCollide = false
        end
    end
    local damageRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("Damage")
    if damageRemote then
        local oldFire = damageRemote.FireServer
        damageRemote.FireServer = function(self, target, ...)
            if target == LocalPlayer and getgenv().NKNO.AntiSheriff then
                return
            end
            return oldFire(self, target, ...)
        end
    end
end

-- ============================================================
-- SCAM TRADE (ЗАМОРОЗКА ТРЕЙДА)
-- ============================================================
local scamActive = false
local scamTarget = nil
local function startScamTrade(target)
    scamTarget = target
    scamActive = true
    Notify("Scam Trade", "Активирована для " .. target.Name, 2)
    -- Перехват удаления инструментов из Character
    local function onChildRemoved(child)
        if not scamActive then return end
        if not scamTarget or not scamTarget.Character then return end
        if child:IsA("Tool") and child.Parent == LocalPlayer.Character then
            -- Оружие было удалено (брошено)
            task.wait(0.1)
            -- Создаём копию у цели
            local clone = child:Clone()
            clone.Parent = scamTarget.Character
            -- Возвращаем оригинал себе
            child.Parent = LocalPlayer.Character
            Notify("Scam", "Оружие скопировано " .. scamTarget.Name, 2)
        end
    end
    LocalPlayer.Character.ChildRemoved:Connect(onChildRemoved)
    -- Сохраняем соединение для отключения
    getgenv()._scamConnection = onChildRemoved
end

local function stopScamTrade()
    scamActive = false
    scamTarget = nil
    Notify("Scam Trade", "Отключена", 2)
end

-- ============================================================
-- ADD WEAPONS (СПАВН ОРУЖИЯ)
-- ============================================================
local function spawnWeapon(weaponId)
    if not weaponId or weaponId == "" then return end
    local model = nil
    -- Ищем в ReplicatedStorage или Workspace
    local function findModel(id)
        for _, item in pairs(ReplicatedStorage:GetDescendants()) do
            if item:IsA("Model") and item:FindFirstChild("Handle") then
                if item.Name:lower():find(id:lower()) or item:GetAttribute("WeaponID") == id then
                    return item
                end
            end
        end
        for _, item in pairs(Workspace:GetDescendants()) do
            if item:IsA("Model") and item:FindFirstChild("Handle") then
                if item.Name:lower():find(id:lower()) or item:GetAttribute("WeaponID") == id then
                    return item
                end
            end
        end
        return nil
    end
    
    model = findModel(weaponId)
    if not model then
        -- Пробуем как число
        local idNum = tonumber(weaponId)
        if idNum then
            -- Можно попробовать загрузить из Roblox
            local success, result = pcall(function()
                return game:GetService("InsertService"):LoadAsset(idNum)
            end)
            if success and result then
                model = result
            end
        end
    end
    
    if model then
        local clone = model:Clone()
        clone.Parent = LocalPlayer.Character or LocalPlayer.Backpack
        clone:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame)
        Notify("Weapon", "Оружие заспавнено: " .. model.Name, 2)
    else
        Notify("Error", "Оружие не найдено", 2)
    end
end

-- ============================================================
-- АВТОФАРМ (ИСПРАВЛЕННЫЙ)
-- ============================================================

local function getCoinContainer()
    for _, child in pairs(Workspace:GetChildren()) do
        if child:FindFirstChild("CoinContainer") and child:IsA("Model") then
            return child:FindFirstChild("CoinContainer")
        end
    end
    return nil
end

local function findNearestCoin(container, useRandom)
    if not container then return nil, math.huge end
    local candidates = {}
    for _, coin in pairs(container:GetChildren()) do
        if coin:GetAttribute("CoinID") == "Coin" and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                table.insert(candidates, { coin = coin, dist = dist })
            end
        end
    end
    if #candidates == 0 then return nil, math.huge end
    table.sort(candidates, function(a,b) return a.dist < b.dist end)
    if useRandom and #candidates > 2 and getgenv().NKNO.FarmMode == "Random" then
        local idx = math.random(1, math.min(3, #candidates))
        return candidates[idx].coin, candidates[idx].dist
    else
        return candidates[1].coin, candidates[1].dist
    end
end

local farming = false
local farmTween = nil
local farmConnection = nil
local savedCollision = {}
local underMapModeForFarm = false

local function startFarming()
    if farming then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if LocalPlayer:GetAttribute("Alive") ~= true then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    savedCollision = {}
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            savedCollision[part] = { CanCollide = part.CanCollide, Massless = part.Massless }
        end
    end
    if getgenv().NKNO.FarmUnderMap then
        underMapModeForFarm = true
        oldFallenHeight = Workspace.FallenPartsDestroyHeight
        Workspace.FallenPartsDestroyHeight = -1/0
        local map = findMap()
        local underY = -500
        if map and map:FindFirstChild("Spawns") then
            local total = Vector3.new()
            local count = 0
            for _, spawn in pairs(map.Spawns:GetChildren()) do
                if spawn:IsA("BasePart") then
                    total = total + spawn.Position
                    count = count + 1
                end
            end
            if count > 0 then
                local center = total / count
                underY = center.Y - 100
            end
        end
        root.CFrame = CFrame.new(root.Position.X, underY, root.Position.Z)
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        root.CFrame = root.CFrame - Vector3.new(0,2.5,0)
        root.CFrame = root.CFrame * CFrame.Angles(math.rad(90),0,0)
    end
    if hum then
        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
    farming = true
end

local function stopFarming()
    farming = false
    if farmTween then farmTween:Cancel() farmTween = nil end
    if farmConnection then farmConnection:Disconnect() farmConnection = nil end
    if LocalPlayer.Character then
        for part, data in pairs(savedCollision) do
            if part and part.Parent then
                part.CanCollide = data.CanCollide
                part.Massless = data.Massless
            end
        end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if root then
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
            if underMapModeForFarm then
                Workspace.FallenPartsDestroyHeight = oldFallenHeight
                local map = findMap()
                if map and map:FindFirstChild("Spawns") then
                    local spawns = map.Spawns:GetChildren()
                    if #spawns > 0 then
                        local spawn = spawns[math.random(1,#spawns)]
                        if spawn:IsA("BasePart") then
                            root.CFrame = spawn.CFrame + Vector3.new(0,5,0)
                        end
                    end
                end
                underMapModeForFarm = false
            else
                root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90),0,0)
                root.CFrame = root.CFrame + Vector3.new(0,2.5,0)
            end
        end
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
    savedCollision = {}
end

local coinCollectedRemote = ReplicatedStorage.Remotes.Gameplay.CoinCollected
local coinCollected = false
coinCollectedRemote.OnClientEvent:Connect(function(plr, current, total)
    if plr == LocalPlayer then
        if tonumber(current) == tonumber(total) then
            coinCollected = true
            if farming then stopFarming() end
        else
            coinCollected = false
        end
    end
end)

local roundStartRemote = ReplicatedStorage.Remotes.Gameplay.RoundStart
local roundEndRemote = ReplicatedStorage.Remotes.Gameplay.RoundEndFade
roundStartRemote.OnClientEvent:Connect(function() coinCollected = false end)
roundEndRemote.OnClientEvent:Connect(function()
    coinCollected = false
    if farming then stopFarming() end
end)

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if getgenv().NKNO.FarmCoins and not coinCollected and LocalPlayer:GetAttribute("Alive") == true and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local container = getCoinContainer()
            if container then
                local coin, dist = findNearestCoin(container, true)
                if coin and coin.Transparency == 1 and not coinCollected then
                    if not farming then startFarming() end
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    root.Velocity = Vector3.new(0,0,0)
                    root.RotVelocity = Vector3.new(0,0,0)
                    local offset = Vector3.new()
                    local targetPos
                    if getgenv().NKNO.FarmUnderMap then
                        targetPos = coin.Position + offset
                    else
                        targetPos = coin.Position - Vector3.new(0,2.5,0) + offset
                    end
                    local targetCF = CFrame.new(targetPos) * (getgenv().NKNO.FarmUnderMap and CFrame.new() or CFrame.Angles(math.rad(90),0,0))

                    if not farmConnection then
                        farmConnection = RunService.Stepped:Connect(function()
                            if getgenv().NKNO.FarmCoins and LocalPlayer.Character then
                                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end
                            end
                        end)
                    end

                    local duration = math.min(dist / 23, 2) -- ограничим время, чтобы не зависало
                    farmTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
                    farmTween:Play()

                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if getgenv().NKNO.FarmCoins and LocalPlayer:GetAttribute("Alive") == true and root then
                            root.Velocity = Vector3.new(0,0,0)
                            root.RotVelocity = Vector3.new(0,0,0)
                            if hum then hum.PlatformStand = true end
                        else
                            if conn then conn:Disconnect() end
                        end
                    end)

                    local timeout = 0
                    while coin and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 and not coinCollected and getgenv().NKNO.FarmCoins and LocalPlayer:GetAttribute("Alive") == true do
                        RunService.Heartbeat:Wait()
                        timeout = timeout + 1
                        if timeout > 200 then break end -- защита от зависания
                    end

                    if conn then conn:Disconnect() end
                    if farmTween then farmTween:Cancel() farmTween = nil end
                    if root then
                        root.Velocity = Vector3.new(0,0,0)
                        root.RotVelocity = Vector3.new(0,0,0)
                    end
                else
                    if farming then stopFarming() end
                end
            else
                if farming then stopFarming() end
            end
        else
            if farming then stopFarming() end
        end
    end
end)

-- ============================================================
-- ПОСТРОЕНИЕ GUI
-- ============================================================

if CoreGui:FindFirstChild("NKNO_HUB") then CoreGui["NKNO_HUB"]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NKNO_HUB"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local isMinimized = false
local isMenuOpen = false
local UI_SCALE = 0.8

-- Тень
local ShadowFrame = Instance.new("Frame")
ShadowFrame.Name = "ShadowFrame"
ShadowFrame.Parent = ScreenGui
ShadowFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
ShadowFrame.AnchorPoint = Vector2.new(0.5,0.5)
ShadowFrame.Position = UDim2.new(0.5,4,0.5,6)
ShadowFrame.Size = UDim2.new(0,646,0,426)
ShadowFrame.BackgroundTransparency = 0.45
ShadowFrame.Visible = false
Instance.new("UICorner", ShadowFrame).CornerRadius = UDim.new(0,16)
local ShadowScale = Instance.new("UIScale", ShadowFrame)
ShadowScale.Scale = 0.3

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(11,11,16)
MainFrame.BackgroundTransparency = 0.25
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.Position = UDim2.new(0.5,0,0.5,0)
MainFrame.Size = UDim2.new(0,640,0,420)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,14)
local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 0.3
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(60,60,80)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.5

local BgGradient = Instance.new("ImageLabel")
BgGradient.Name = "BgGradient"
BgGradient.Parent = MainFrame
BgGradient.BackgroundTransparency = 1
BgGradient.Size = UDim2.new(1,0,1,0)
BgGradient.Image = "rbxassetid://138913032331139"
BgGradient.ScaleType = Enum.ScaleType.Crop
BgGradient.ImageTransparency = 0.3
BgGradient.ZIndex = 0
Instance.new("UICorner", BgGradient).CornerRadius = UDim.new(0,14)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,20,0,14)
Title.Size = UDim2.new(0,200,0,26)
Title.Font = Enum.Font.GothamBold
Title.Text = "NKNO$ HUB"
Title.TextColor3 = Color3.fromRGB(255,215,0)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопки управления
local TopControls = Instance.new("Frame")
TopControls.Parent = MainFrame
TopControls.BackgroundTransparency = 1
TopControls.Position = UDim2.new(1,-75,0,14)
TopControls.Size = UDim2.new(0,65,0,26)
TopControls.ZIndex = 20

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopControls
CloseBtn.BackgroundColor3 = Color3.fromRGB(25,18,22)
CloseBtn.Position = UDim2.new(1,-26,0,0)
CloseBtn.Size = UDim2.new(0,26,0,26)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(250,80,80)
CloseBtn.TextSize = 18
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)
CloseBtn.MouseButton1Click:Connect(function()
    toggleMenu(false)
    task.wait(0.3)
    ScreenGui:Destroy()
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopControls
MinBtn.BackgroundColor3 = Color3.fromRGB(18,18,26)
MinBtn.Position = UDim2.new(1,-58,0,0)
MinBtn.Size = UDim2.new(0,26,0,26)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(160,160,180)
MinBtn.TextSize = 18
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,6)
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0,640,0,52)}):Play()
        TweenService:Create(ShadowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0,646,0,58)}):Play()
        MinBtn.Text = "+"
        LeftPanel.Visible = false
        RightContainer.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0,640,0,420)}):Play()
        TweenService:Create(ShadowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0,646,0,426)}):Play()
        MinBtn.Text = "-"
        LeftPanel.Visible = true
        RightContainer.Visible = true
    end
end)

-- ============================================================
-- ЛЕВАЯ ПАНЕЛЬ КАТЕГОРИЙ (ПРОЗРАЧНАЯ)
-- ============================================================
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Parent = MainFrame
LeftPanel.BackgroundColor3 = Color3.fromRGB(18,18,26)
LeftPanel.BackgroundTransparency = 0.6
LeftPanel.Position = UDim2.new(0,0,0,55)
LeftPanel.Size = UDim2.new(0,150,1,-70)
LeftPanel.BorderSizePixel = 0
LeftPanel.ClipsDescendants = true

local CategoryList = Instance.new("ScrollingFrame")
CategoryList.Parent = LeftPanel
CategoryList.BackgroundTransparency = 1
CategoryList.Size = UDim2.new(1,0,1,0)
CategoryList.CanvasSize = UDim2.new(0,0,0,0)
CategoryList.ScrollBarThickness = 0
CategoryList.BorderSizePixel = 0

local CategoryLayout = Instance.new("UIListLayout")
CategoryLayout.Padding = UDim.new(0,4)
CategoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
CategoryLayout.Parent = CategoryList

-- Добавляем новые категории
local categories = {"MAIN", "COMBAT", "FARM", "VISUALS", "MOVEMENT", "TELEPORTS", "FLING", "SCAM TRADE", "ADD WEAPONS", "MISC"}
local currentCategory = "MAIN"

local function updateCategoryCanvas()
    local total = 0
    for _, child in ipairs(CategoryList:GetChildren()) do
        if child:IsA("UIListLayout") then continue end
        total = total + child.Size.Y.Offset + 4
    end
    CategoryList.CanvasSize = UDim2.new(0,0,0,total + 10)
end

local function createCategoryButton(cat)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,32)
    btn.BackgroundTransparency = 0.5   -- прозрачная
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.BorderSizePixel = 0
    btn.Text = cat
    btn.TextColor3 = Color3.fromRGB(200,200,220)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = CategoryList
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        currentCategory = cat
        populateCategory(cat)
        for _, b in pairs(CategoryList:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = (b == btn) and Color3.fromRGB(60,60,80) or Color3.fromRGB(40,40,55)
                b.TextColor3 = (b == btn) and Color3.fromRGB(255,215,0) or Color3.fromRGB(200,200,220)
            end
        end
    end)
    updateCategoryCanvas()
    return btn
end

for _, cat in ipairs(categories) do
    createCategoryButton(cat)
end

-- ============================================================
-- ПРАВАЯ ОБЛАСТЬ
-- ============================================================
local RightContainer = Instance.new("ScrollingFrame")
RightContainer.Name = "RightContainer"
RightContainer.Parent = MainFrame
RightContainer.BackgroundTransparency = 1
RightContainer.Position = UDim2.new(0,155,0,55)
RightContainer.Size = UDim2.new(1,-165,1,-70)
RightContainer.CanvasSize = UDim2.new(0,0,0,0)
RightContainer.ScrollBarThickness = 6
RightContainer.BorderSizePixel = 0

local RightLayout = Instance.new("UIListLayout")
RightLayout.Padding = UDim.new(0,6)
RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightLayout.Parent = RightContainer

local function updateRightCanvas()
    local total = 0
    for _, child in ipairs(RightContainer:GetChildren()) do
        if child:IsA("UIListLayout") then continue end
        if child:IsA("Frame") then
            total = total + child.Size.Y.Offset + 6
        end
    end
    RightContainer.CanvasSize = UDim2.new(0,0,0,total + 20)
end

local lang = getgenv().NKNO.Language or "ru"
local function T(ru, en)
    return lang == "ru" and ru or en
end

local function createSection(parent, titleRu, titleEn)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,24)
    label.BackgroundTransparency = 1
    label.Text = T(titleRu, titleEn)
    label.TextColor3 = Color3.fromRGB(200,200,220)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    updateRightCanvas()
    return label
end

local function createButton(parent, titleRu, titleEn, descRu, descEn, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    btn.BorderSizePixel = 0
    btn.Text = T(titleRu, titleEn)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    if descRu or descEn then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1,0,0,16)
        d.Position = UDim2.new(0,5,1,0)
        d.BackgroundTransparency = 1
        d.Text = T(descRu or "", descEn or "")
        d.TextColor3 = Color3.fromRGB(150,150,170)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = btn
    end
    btn.MouseButton1Click:Connect(callback)
    updateRightCanvas()
    return btn
end

local function createToggle(parent, titleRu, titleEn, descRu, descEn, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = T(titleRu, titleEn)
    label.TextColor3 = Color3.fromRGB(220,220,235)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0,44,0,22)
    toggleBtn.Position = UDim2.new(1,-48,0.5,-11)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0,170,0) or Color3.fromRGB(80,80,90)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0,18,0,18)
    circle.Position = default and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBtn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

    local state = default
    callback(state)

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(80,80,90)
        circle.Position = state and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9)
        callback(state)
    end)

    if descRu or descEn then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(0.65,0,0,16)
        d.Position = UDim2.new(0,0,1,0)
        d.BackgroundTransparency = 1
        d.Text = T(descRu or "", descEn or "")
        d.TextColor3 = Color3.fromRGB(150,150,170)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
    updateRightCanvas()
    return frame
end

local function createSlider(parent, titleRu, titleEn, descRu, descEn, min, max, default, decimals, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,44)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,0.4,0)
    label.BackgroundTransparency = 1
    label.Text = T(titleRu, titleEn)
    label.TextColor3 = Color3.fromRGB(220,220,235)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3,0,0.4,0)
    valueLabel.Position = UDim2.new(0.7,0,0,0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255,215,0)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1,0,0,6)
    sliderBg.Position = UDim2.new(0,0,0.6,0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,70)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,215,0)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg

    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0,14,0,14)
    drag.Position = UDim2.new((default-min)/(max-min),-7,0.5,-7)
    drag.BackgroundColor3 = Color3.fromRGB(255,255,255)
    drag.BorderSizePixel = 0
    drag.Text = ""
    drag.Parent = sliderBg
    Instance.new("UICorner", drag).CornerRadius = UDim.new(1,0)

    local function update(val)
        val = math.clamp(val, min, max)
        local percent = (val-min)/(max-min)
        fill.Size = UDim2.new(percent,0,1,0)
        drag.Position = UDim2.new(percent,-7,0.5,-7)
        valueLabel.Text = decimals and string.format("%.1f", val) or tostring(math.round(val))
        callback(val)
    end

    drag.MouseButton1Down:Connect(function()
        local move, up
        move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local val = min + pos * (max - min)
                update(val)
            end
        end)
        up = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                move:Disconnect()
                up:Disconnect()
            end
        end)
    end)

    if descRu or descEn then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1,0,0,16)
        d.Position = UDim2.new(0,0,1,0)
        d.BackgroundTransparency = 1
        d.Text = T(descRu or "", descEn or "")
        d.TextColor3 = Color3.fromRGB(150,150,170)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
    updateRightCanvas()
    return frame
end

-- Улучшенный dropdown
local dropdownObjects = {}
local function createDropdown(parent, titleRu, titleEn, descRu, descEn, options, default, callback, dynamic)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = T(titleRu, titleEn)
    label.TextColor3 = Color3.fromRGB(220,220,235)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0.4,0,1,0)
    dropdownBtn.Position = UDim2.new(0.6,0,0,0)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = default or options[1]
    dropdownBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dropdownBtn.TextSize = 14
    dropdownBtn.Font = Enum.Font.GothamMedium
    dropdownBtn.Parent = frame
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0,6)

    local listVisible = false
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.4,0,0,100)
    listFrame.Position = UDim2.new(0.6,0,1,2)
    listFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = frame
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,6)

    local listScrolling = Instance.new("ScrollingFrame")
    listScrolling.Size = UDim2.new(1,0,1,0)
    listScrolling.BackgroundTransparency = 1
    listScrolling.BorderSizePixel = 0
    listScrolling.CanvasSize = UDim2.new(0,0,0,#options * 30)
    listScrolling.ScrollBarThickness = 4
    listScrolling.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0,2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listScrolling

    local optionButtons = {}
    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,25)
        btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
        btn.BorderSizePixel = 0
        btn.Text = opt
        btn.TextColor3 = Color3.fromRGB(200,200,210)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = listScrolling
        btn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = opt
            callback(opt)
            listFrame.Visible = false
            listVisible = false
        end)
        table.insert(optionButtons, btn)
    end

    local function updateOptions(newOptions)
        for _, btn in ipairs(optionButtons) do
            btn:Destroy()
        end
        optionButtons = {}
        for _, opt in ipairs(newOptions) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,25)
            btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
            btn.BorderSizePixel = 0
            btn.Text = opt
            btn.TextColor3 = Color3.fromRGB(200,200,210)
            btn.TextSize = 13
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = listScrolling
            btn.MouseButton1Click:Connect(function()
                dropdownBtn.Text = opt
                callback(opt)
                listFrame.Visible = false
                listVisible = false
            end)
            table.insert(optionButtons, btn)
        end
        listScrolling.CanvasSize = UDim2.new(0,0,0,#newOptions * 30)
        if #newOptions > 0 then
            dropdownBtn.Text = newOptions[1]
            callback(newOptions[1])
        end
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        listVisible = not listVisible
        listFrame.Visible = listVisible
        if listVisible then
            listFrame.Size = UDim2.new(0.4,0,0,math.min(#optionButtons * 30 + 10, 120))
        end
    end)

    if descRu or descEn then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1,0,0,16)
        d.Position = UDim2.new(0,0,1,0)
        d.BackgroundTransparency = 1
        d.Text = T(descRu or "", descEn or "")
        d.TextColor3 = Color3.fromRGB(150,150,170)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
    updateRightCanvas()
    local dropdownObj = {
        frame = frame,
        updateOptions = updateOptions,
        dropdownBtn = dropdownBtn
    }
    return dropdownObj
end

local function createInput(parent, titleRu, titleEn, descRu, descEn, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = T(titleRu, titleEn)
    label.TextColor3 = Color3.fromRGB(220,220,235)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.5,0,1,0)
    inputBox.Position = UDim2.new(0.5,0,0,0)
    inputBox.BackgroundColor3 = Color3.fromRGB(40,40,50)
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255,255,255)
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.GothamMedium
    inputBox.PlaceholderText = T("Введите...", "Enter...")
    inputBox.Parent = frame
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,6)

    inputBox.FocusLost:Connect(function()
        callback(inputBox.Text)
    end)

    if descRu or descEn then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1,0,0,16)
        d.Position = UDim2.new(0,0,1,0)
        d.BackgroundTransparency = 1
        d.Text = T(descRu or "", descEn or "")
        d.TextColor3 = Color3.fromRGB(150,150,170)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
    updateRightCanvas()
    return frame
end

-- ============================================================
-- ФУНКЦИИ ЗАПОЛНЕНИЯ КАТЕГОРИЙ
-- ============================================================

local function clearRightContainer()
    for _, child in ipairs(RightContainer:GetChildren()) do
        if child ~= RightLayout then child:Destroy() end
    end
    RightContainer.CanvasSize = UDim2.new(0,0,0,0)
end

local playerDropdownObj = nil
local scamDropdownObj = nil
local weaponDropdownObj = nil

function populateCategory(cat)
    clearRightContainer()
    if cat == "MAIN" then
        createSection(RightContainer, "Основное", "Main")
        createButton(RightContainer, "Убить всех", "Kill All", "Убить всех мирных (только убийца)", "Kill all innocents (murderer only)", function()
            if not LocalPlayer.Character then return end
            local knife = LocalPlayer.Character:FindFirstChild("Knife")
            if not knife then
                knife = LocalPlayer.Backpack:FindFirstChild("Knife")
                if knife then knife.Parent = LocalPlayer.Character else return end
            end
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    for _, part in pairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local target = plr.Character:FindFirstChild("HumanoidRootPart")
                        if target then
                            target.Size = Vector3.new(5,5,5)
                            target.CFrame = root.CFrame + root.CFrame.LookVector * 3
                            target.Anchored = true
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                        end
                    end
                end
            end
        end)
        createToggle(RightContainer, "Авто-граб пистолета", "Auto Grab Gun", "Забрать пистолет, если шериф умер", "Grab gun when sheriff dies", getgenv().NKNO.AutoGrabGun, function(val)
            getgenv().NKNO.AutoGrabGun = val
        end)
        createToggle(RightContainer, "Режим Бога", "God Mode", "Отключить коллизии (неуязвимость)", "Disable collisions (invincible)", getgenv().NKNO.GodMode, function(val)
            getgenv().NKNO.GodMode = val
            if val then
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
        createToggle(RightContainer, "Под картой (ручной)", "UnderMap Mode", "Уйти под карту вручную", "Go under map manually", getgenv().NKNO.UnderMap, function(val)
            getgenv().NKNO.UnderMap = val
            if val then goUnderMap() else returnFromUnderMap() end
        end)
        createToggle(RightContainer, "Авто-респавн", "Auto Respawn", "Респавниться при смерти", "Respawn when dead", getgenv().NKNO.AutoRespawn, function(val)
            getgenv().NKNO.AutoRespawn = val
        end)
        createToggle(RightContainer, "Anti Sheriff", "Anti Sheriff", "Защита от выстрелов шерифа", "Protection from sheriff", getgenv().NKNO.AntiSheriff or false, function(val)
            getgenv().NKNO.AntiSheriff = val
            if val then antiSheriff() end
        end)

    elseif cat == "COMBAT" then
        createSection(RightContainer, "Бой", "Combat")
        createToggle(RightContainer, "Кнопка выстрела", "Auto Shoot Button", "Кнопка для стрельбы в убийцу (шериф)", "Button to shoot murderer (sheriff)", false, function(val)
            local function createShootButton()
                if CoreGui:FindFirstChild("ShootButtonGui") then return end
                local gui = Instance.new("ScreenGui")
                gui.Name = "ShootButtonGui"
                gui.ResetOnSpawn = false
                gui.Parent = CoreGui
                local btn = Instance.new("ImageButton")
                btn.Size = UDim2.new(0,80,0,80)
                btn.Position = UDim2.new(0.5,-40,0.5,-40)
                btn.BackgroundColor3 = Color3.fromRGB(255,50,50)
                btn.BackgroundTransparency = 0.3
                btn.BorderSizePixel = 0
                btn.Parent = gui
                Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = "🔫"
                label.TextSize = 32
                label.TextColor3 = Color3.fromRGB(255,255,255)
                label.Font = Enum.Font.GothamBold
                label.Parent = btn
                local shootDrag = false
                local shootStartPos, shootButtonPos
                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        shootDrag = true
                        shootStartPos = input.Position
                        shootButtonPos = btn.Position
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then shootDrag = false end
                        end)
                    end
                end)
                btn.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if shootDrag then
                            local delta = input.Position - shootStartPos
                            btn.Position = UDim2.new(shootButtonPos.X.Scale, shootButtonPos.X.Offset + delta.X, shootButtonPos.Y.Scale, shootButtonPos.Y.Offset + delta.Y)
                        end
                    end
                end)
                btn.MouseButton1Click:Connect(function()
                    if not shootDrag then
                        local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
                        if not gun then gun = LocalPlayer.Backpack:FindFirstChild("Gun") if gun then gun.Parent = LocalPlayer.Character else return end end
                        local murderer = findMurderer()
                        if not murderer then return end
                        local mChar = murderer.Character
                        if not mChar or not mChar:FindFirstChild("HumanoidRootPart") then return end
                        local mRoot = mChar.HumanoidRootPart
                        local torso = mChar:FindFirstChild("Torso") or mChar:FindFirstChild("UpperTorso")
                        if not torso then return end
                        local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if not pRoot then return end
                        local ping = getPing()
                        local bulletSpeed = 1.25
                        local predict = (ping / 1000) * bulletSpeed
                        local targetPos = torso.Position + (mRoot.Velocity * predict)
                        local cframe = CFrame.new(pRoot.Position, targetPos)
                        local shootEvent = gun:FindFirstChild("ShootEvent") or gun:FindFirstChild("Shoot")
                        if shootEvent then shootEvent:FireServer(cframe, CFrame.new(targetPos)) end
                    end
                end)
            end
            if val then createShootButton() else 
                local gui = CoreGui:FindFirstChild("ShootButtonGui")
                if gui then gui:Destroy() end
            end
        end)
        createToggle(RightContainer, "Магическая пуля", "Magic Bullet", "Авто-прицел в убийцу", "Auto-aim at murderer", false, function(val) end)

    elseif cat == "FARM" then
        createSection(RightContainer, "Фарм", "Farm")
        createToggle(RightContainer, "Фарм монет", "Farm Coins", "Автосбор монет", "Auto-collect coins", getgenv().NKNO.FarmCoins, function(val)
            getgenv().NKNO.FarmCoins = val
            if not val and farming then stopFarming() end
        end)
        createToggle(RightContainer, "Фарм под картой", "Farm UnderMap", "Сбор под картой (недосягаем)", "Farm under map (unreachable)", getgenv().NKNO.FarmUnderMap, function(val)
            getgenv().NKNO.FarmUnderMap = val
        end)
        createDropdown(RightContainer, "Режим сбора", "Collect Mode", "Nearest – ближайшая, Random – случайная", "Nearest or Random", {"Nearest", "Random"}, getgenv().NKNO.FarmMode or "Nearest", function(val)
            getgenv().NKNO.FarmMode = val
        end)

    elseif cat == "VISUALS" then
        createSection(RightContainer, "Визуал", "Visuals")
        createToggle(RightContainer, "ESP убийцы", "Murderer ESP", "", "", getgenv().NKNO.ESP.Murderer, function(val) getgenv().NKNO.ESP.Murderer = val end)
        createToggle(RightContainer, "ESP шерифа", "Sheriff ESP", "", "", getgenv().NKNO.ESP.Sheriff, function(val) getgenv().NKNO.ESP.Sheriff = val end)
        createToggle(RightContainer, "ESP мирных", "Innocent ESP", "", "", getgenv().NKNO.ESP.Innocent, function(val) getgenv().NKNO.ESP.Innocent = val end)
        createToggle(RightContainer, "ESP героя", "Hero ESP", "", "", getgenv().NKNO.ESP.Hero, function(val) getgenv().NKNO.ESP.Hero = val end)
        createToggle(RightContainer, "2D рамка", "2D Box", "Рамка вокруг игрока", "Box around player", getgenv().NKNO.ESP.Box2D, function(val) getgenv().NKNO.ESP.Box2D = val end)
        createToggle(RightContainer, "Показывать DisplayName", "Display Name", "", "", getgenv().NKNO.ESP.DisplayName, function(val)
            getgenv().NKNO.ESP.DisplayName = val
            if val then getgenv().NKNO.ESP.NormalName = false end
        end)
        createToggle(RightContainer, "Показывать ник", "Normal Name", "", "", getgenv().NKNO.ESP.NormalName, function(val)
            getgenv().NKNO.ESP.NormalName = val
            if val then getgenv().NKNO.ESP.DisplayName = false end
        end)
        createToggle(RightContainer, "ForceField материал", "ForceField Material", "Материал ForceField на себе", "ForceField material on self", getgenv().NKNO.ForceFieldMaterial, function(val)
            getgenv().NKNO.ForceFieldMaterial = val
            if val then applyForceField() else restoreMaterial() end
        end)
        createToggle(RightContainer, "Кастомный FOV", "Custom FOV", "", "", getgenv().NKNO.CustomFOV, function(val)
            getgenv().NKNO.CustomFOV = val
            applyFOV()
        end)
        createSlider(RightContainer, "FOV", "FOV", "", "", 70, 120, getgenv().NKNO.FOVValue, false, function(val)
            getgenv().NKNO.FOVValue = val
            if getgenv().NKNO.CustomFOV then applyFOV() end
        end)

    elseif cat == "MOVEMENT" then
        createSection(RightContainer, "Движение", "Movement")
        createToggle(RightContainer, "Кастомная скорость", "Custom WalkSpeed", "", "", getgenv().NKNO.CustomWalkSpeed, function(val)
            getgenv().NKNO.CustomWalkSpeed = val
            applyWalkSpeed()
        end)
        createSlider(RightContainer, "WalkSpeed", "WalkSpeed", "", "", 16, 200, getgenv().NKNO.WalkSpeedValue, false, function(val)
            getgenv().NKNO.WalkSpeedValue = val
            if getgenv().NKNO.CustomWalkSpeed then applyWalkSpeed() end
        end)
        createToggle(RightContainer, "Кастомный прыжок", "Custom JumpPower", "", "", getgenv().NKNO.CustomJumpPower, function(val)
            getgenv().NKNO.CustomJumpPower = val
            applyJumpPower()
        end)
        createSlider(RightContainer, "JumpPower", "JumpPower", "", "", 50, 200, getgenv().NKNO.JumpPowerValue, false, function(val)
            getgenv().NKNO.JumpPowerValue = val
            if getgenv().NKNO.CustomJumpPower then applyJumpPower() end
        end)
        createToggle(RightContainer, "Анти-AFK", "Anti-AFK", "Движение для избегания кика", "Movement to avoid kick", getgenv().NKNO.AntiAFK, function(val)
            getgenv().NKNO.AntiAFK = val
            if val then
                task.spawn(function()
                    while getgenv().NKNO.AntiAFK and task.wait(math.random(30,60)) do
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            local hum = LocalPlayer.Character.Humanoid
                            local dir = Vector3.new(math.random(-1,1),0,math.random(-1,1))
                            hum:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + dir * 5)
                        end
                    end
                end)
            end
        end)

    elseif cat == "TELEPORTS" then
        createSection(RightContainer, "Телепорты", "Teleports")
        createButton(RightContainer, "На карту", "Map TP", "Телепорт на текущую карту", "Teleport to current map", function()
            local map = findMap()
            if map and map:FindFirstChild("Spawns") then
                local spawns = map.Spawns:GetChildren()
                if #spawns > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
                end
            end
        end)
        createButton(RightContainer, "В лобби", "Lobby TP", "Телепорт в лобби", "Teleport to lobby", function()
            local lobby = Workspace:FindFirstChild("RegularLobby")
            if lobby and lobby:FindFirstChild("Spawns") then
                local spawns = lobby.Spawns:GetChildren()
                if #spawns > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
                end
            end
        end)
        createButton(RightContainer, "К убийце", "Murder TP", "Телепорт к убийце", "Teleport to murderer", function()
            local m = findMurderer()
            if m and m.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame
            end
        end)
        createButton(RightContainer, "К шерифу", "Sheriff TP", "Телепорт к шерифу", "Teleport to sheriff", function()
            local s = findSheriff()
            if s and s.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame
            end
        end)

    elseif cat == "FLING" then
        createSection(RightContainer, "Флинг", "Fling")
        createButton(RightContainer, "Флинг убийцы", "Fling Murderer", "Зафлингует убийцу", "Fling the murderer", function()
            if getgenv().NKNO.Flinging then return end
            local m = findMurderer()
            if m then
                getgenv().NKNO.Flinging = true
                Notify(T("Флинг", "Fling"), T("Флингуем убийцу", "Flinging murderer"), 3)
                task.spawn(function()
                    SkidFling(m)
                    getgenv().NKNO.Flinging = false
                end)
            end
        end)
        createButton(RightContainer, "Флинг шерифа", "Fling Sheriff", "Зафлингует шерифа", "Fling the sheriff", function()
            if getgenv().NKNO.Flinging then return end
            local s = findSheriff()
            if s then
                getgenv().NKNO.Flinging = true
                Notify(T("Флинг", "Fling"), T("Флингуем шерифа", "Flinging sheriff"), 3)
                task.spawn(function()
                    SkidFling(s)
                    getgenv().NKNO.Flinging = false
                end)
            end
        end)

        local function getPlayerNames()
            local names = {}
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    table.insert(names, plr.Name)
                end
            end
            return names
        end

        local options = getPlayerNames()
        if #options == 0 then options = {"Нет игроков"} end
        local defaultName = getgenv().NKNO.SelectedPlayerName or options[1]
        playerDropdownObj = createDropdown(RightContainer, "Выбор игрока", "Select Player", "Выберите из списка", "Choose from list", options, defaultName, function(val)
            local plr = Players:FindFirstChild(val)
            if plr then
                getgenv().NKNO.SelectedPlayer = plr
                getgenv().NKNO.SelectedPlayerName = val
                Notify("Выбран", val, 2)
            else
                getgenv().NKNO.SelectedPlayer = nil
                getgenv().NKNO.SelectedPlayerName = nil
            end
        end)

        local function refreshPlayerDropdown()
            local newOptions = getPlayerNames()
            if #newOptions == 0 then newOptions = {"Нет игроков"} end
            if playerDropdownObj then
                playerDropdownObj.updateOptions(newOptions)
                if getgenv().NKNO.SelectedPlayerName and not Players:FindFirstChild(getgenv().NKNO.SelectedPlayerName) then
                    getgenv().NKNO.SelectedPlayer = nil
                    getgenv().NKNO.SelectedPlayerName = nil
                    playerDropdownObj.dropdownBtn.Text = newOptions[1]
                end
            end
        end

        if not getgenv()._playerListConnected then
            getgenv()._playerListConnected = true
            Players.PlayerAdded:Connect(refreshPlayerDropdown)
            Players.PlayerRemoving:Connect(refreshPlayerDropdown)
        end

        createButton(RightContainer, "Флинг выбранного", "Fling Selected", "Флинг выбранного игрока", "Fling selected player", function()
            if getgenv().NKNO.Flinging then return end
            local sel = getgenv().NKNO.SelectedPlayer
            if not sel or not sel.Parent then
                Notify(T("Ошибка", "Error"), T("Сначала выберите игрока", "Select a player first"), 3)
                return
            end
            getgenv().NKNO.Flinging = true
            Notify(T("Флинг", "Fling"), T("Флингуем " .. sel.Name, "Flinging " .. sel.Name), 3)
            task.spawn(function()
                SkidFling(sel)
                getgenv().NKNO.Flinging = false
            end)
        end)
        createButton(RightContainer, "Остановить флинг", "Stop Fling", "Остановить флинг", "Stop fling", function()
            if getgenv().NKNO.Flinging then
                getgenv().NKNO.Flinging = false
                Notify(T("Остановлено", "Stopped"), T("Флинг прекращён", "Fling stopped"), 2)
            end
        end)

    elseif cat == "SCAM TRADE" then
        createSection(RightContainer, "Scam Trade", "Scam Trade")
        createSection(RightContainer, "Заморозка трейда", "Freeze Trade")
        -- Выбор цели
        local function getPlayerNames()
            local names = {}
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    table.insert(names, plr.Name)
                end
            end
            return names
        end
        local opts = getPlayerNames()
        if #opts == 0 then opts = {"Нет игроков"} end
        scamDropdownObj = createDropdown(RightContainer, "Цель", "Target", "Игрок, которому будет скопировано оружие", "Player to copy weapon to", opts, opts[1], function(val)
            local plr = Players:FindFirstChild(val)
            if plr then
                getgenv().NKNO.ScamTarget = plr
            else
                getgenv().NKNO.ScamTarget = nil
            end
        end)

        createButton(RightContainer, "Включить заморозку", "Enable Freeze", "При броске оружия оно остаётся у вас и копируется цели", "On throw, weapon stays and copies to target", function()
            if not getgenv().NKNO.ScamTarget then
                Notify("Ошибка", "Выберите цель", 2)
                return
            end
            startScamTrade(getgenv().NKNO.ScamTarget)
        end)
        createButton(RightContainer, "Выключить заморозку", "Disable Freeze", "Отключить", "Disable", function()
            stopScamTrade()
        end)
        createToggle(RightContainer, "Активна", "Active", "", "", getgenv().NKNO.ScamTrade or false, function(val)
            getgenv().NKNO.ScamTrade = val
            if val then
                if not getgenv().NKNO.ScamTarget then
                    Notify("Ошибка", "Сначала выберите цель", 2)
                    return
                end
                startScamTrade(getgenv().NKNO.ScamTarget)
            else
                stopScamTrade()
            end
        end)

    elseif cat == "ADD WEAPONS" then
        createSection(RightContainer, "Add Weapons", "Add Weapons")
        createSection(RightContainer, "Спавн оружия", "Spawn Weapon")
        -- Предустановленные оружия
        local presetWeapons = {"Knife", "Gun", "Golden Knife", "Sword", "Axe", "Candy Cane", "Laser Gun"}
        weaponDropdownObj = createDropdown(RightContainer, "Выберите оружие", "Select Weapon", "Известные модели", "Known models", presetWeapons, presetWeapons[1], function(val)
            getgenv().NKNO._selectedWeapon = val
        end)
        createInput(RightContainer, "ID или имя", "ID or Name", "Можно ввести ID модели или название", "Enter model ID or name", function(text)
            spawnWeapon(text)
        end)
        createButton(RightContainer, "Спавн выбранного", "Spawn Selected", "Создать оружие в руках", "Spawn in hands", function()
            local name = getgenv().NKNO._selectedWeapon or "Knife"
            spawnWeapon(name)
        end)

    elseif cat == "MISC" then
        createSection(RightContainer, "Разное", "Misc")
        createToggle(RightContainer, "Анти-флинг (защита)", "Anti-Fling", "Защита от флинга (отключает коллизию и стабилизирует позицию)", "Anti-fling (disables collision and stabilizes position)", getgenv().NKNO.AntiFling, function(val)
            getgenv().NKNO.AntiFling = val
            if val then startAntiFling() else stopAntiFling() end
        end)
        createSection(RightContainer, "Танцы", "Dance Emotes")
        local danceOptions = {"Dance 1","Dance 2","Dance 3","Dance 4"}
        local danceIDs = {
            ["Dance 1"] = "127118661424463",
            ["Dance 2"] = "82682811348660",
            ["Dance 3"] = "10714340543",
            ["Dance 4"] = "15609995579",
        }
        createDropdown(RightContainer, "Выбрать танец", "Select Dance", "", "", danceOptions, "Dance 1", function(val)
            getgenv().NKNO.DanceID = danceIDs[val]
            if getgenv().NKNO.AutoDance then
                stopDance()
                task.wait(0.2)
                playDance()
            end
        end)
        createToggle(RightContainer, "Авто-танец", "Auto Dance", "Автоматический танец", "Auto dance", getgenv().NKNO.AutoDance, function(val)
            getgenv().NKNO.AutoDance = val
            if val then playDance() else stopDance() end
        end)
        createSection(RightContainer, "Настройки UI", "UI Settings")
        local themes = {"Dark","Light","Gold","Purple","Green","Blue","Red"}
        createDropdown(RightContainer, "Тема", "Theme", "Выберите цветовую схему", "Choose color scheme", themes, getgenv().NKNO.Theme or "Dark", function(val)
            getgenv().NKNO.Theme = val
            local colors = {
                Dark = { bg = Color3.fromRGB(11,11,16), text = Color3.fromRGB(220,220,235), accent = Color3.fromRGB(255,215,0), panel = Color3.fromRGB(18,18,26) },
                Light = { bg = Color3.fromRGB(240,240,245), text = Color3.fromRGB(30,30,40), accent = Color3.fromRGB(0,120,255), panel = Color3.fromRGB(220,220,230) },
                Gold = { bg = Color3.fromRGB(30,25,20), text = Color3.fromRGB(255,215,0), accent = Color3.fromRGB(255,180,0), panel = Color3.fromRGB(40,35,30) },
                Purple = { bg = Color3.fromRGB(20,10,30), text = Color3.fromRGB(200,180,255), accent = Color3.fromRGB(180,100,255), panel = Color3.fromRGB(30,20,40) },
                Green = { bg = Color3.fromRGB(10,25,15), text = Color3.fromRGB(180,255,200), accent = Color3.fromRGB(100,255,100), panel = Color3.fromRGB(20,35,25) },
                Blue = { bg = Color3.fromRGB(10,15,30), text = Color3.fromRGB(180,200,255), accent = Color3.fromRGB(100,150,255), panel = Color3.fromRGB(20,25,40) },
                Red = { bg = Color3.fromRGB(30,10,10), text = Color3.fromRGB(255,180,180), accent = Color3.fromRGB(255,80,80), panel = Color3.fromRGB(40,20,20) },
            }
            local theme = colors[val]
            if theme then
                MainFrame.BackgroundColor3 = theme.bg
                Title.TextColor3 = theme.accent
                LeftPanel.BackgroundColor3 = theme.panel
                for _, b in pairs(CategoryList:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = (b.Text == currentCategory) and theme.accent or Color3.fromRGB(40,40,55)
                        b.TextColor3 = (b.Text == currentCategory) and Color3.fromRGB(255,255,255) or theme.text
                    end
                end
                MainStroke.Color = theme.accent
                MainStroke.Transparency = 0.3
            end
        end)
        createSlider(RightContainer, "Прозрачность UI", "UI Transparency", "Прозрачность окна", "Window transparency", 0, 1, 0.25, true, function(val)
            MainFrame.BackgroundTransparency = val
        end)
    end
end

-- ============================================================
-- УВЕДОМЛЕНИЯ И ОСТАЛЬНОЕ
-- ============================================================

local function Notify(title, desc, duration)
    duration = duration or 3
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,340,0,70)
    frame.Position = UDim2.new(0.5,-170,0.85,0)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,28)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.3
    frame.Parent = ScreenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,-20,0,28)
    titleLabel.Position = UDim2.new(0,10,0,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255,215,0)
    titleLabel.TextSize = 17
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1,-20,0,30)
    descLabel.Position = UDim2.new(0,10,0,28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(200,200,210)
    descLabel.TextSize = 13
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame
    TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.1 }):Play()
    task.wait(duration)
    TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
    task.wait(0.3)
    frame:Destroy()
end

-- Плавающая кнопка
local ToggleWidget = Instance.new("Frame")
ToggleWidget.Name = "ToggleWidget"
ToggleWidget.Parent = ScreenGui
ToggleWidget.BackgroundColor3 = Color3.fromRGB(15,15,22)
ToggleWidget.BackgroundTransparency = 0.15
ToggleWidget.Position = UDim2.new(0.5,-80,0.08,0)
ToggleWidget.Size = UDim2.new(0,160,0,44)
ToggleWidget.Visible = true
Instance.new("UICorner", ToggleWidget).CornerRadius = UDim.new(0,10)
local ToggleScale = Instance.new("UIScale", ToggleWidget)
ToggleScale.Scale = 0.85
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleWidget
ToggleStroke.Color = Color3.fromRGB(45,45,65)
ToggleStroke.Thickness = 1.5
local ToggleLabelText = Instance.new("TextLabel")
ToggleLabelText.Parent = ToggleWidget
ToggleLabelText.BackgroundTransparency = 1
ToggleLabelText.Size = UDim2.new(1,0,1,0)
ToggleLabelText.Font = Enum.Font.GothamBold
ToggleLabelText.Text = "☰ NKNO$ HUB"
ToggleLabelText.TextColor3 = Color3.fromRGB(255,215,0)
ToggleLabelText.TextSize = 17

ToggleWidget.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(ToggleScale, TweenInfo.new(0.15), {Scale = 0.78}):Play()
    end
end)
ToggleWidget.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(ToggleScale, TweenInfo.new(0.15), {Scale = 0.85}):Play()
    end
end)

local dragToggle, dragInputT, dragStartT, startPosT
local dragStartTime = 0
ToggleWidget.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStartT = input.Position
        startPosT = ToggleWidget.Position
        dragStartTime = tick()
    end
end)
ToggleWidget.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputT = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInputT and dragToggle then
        local delta = input.Position - dragStartT
        ToggleWidget.Position = UDim2.new(
            startPosT.X.Scale, startPosT.X.Offset + delta.X,
            startPosT.Y.Scale, startPosT.Y.Offset + delta.Y
        )
    end
end)
ToggleWidget.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
        if tick() - dragStartTime < 0.25 then
            toggleMenu()
        end
    end
end)

function toggleMenu(forceState)
    if forceState ~= nil then isMenuOpen = forceState else isMenuOpen = not isMenuOpen end
    if isMenuOpen then
        MainFrame.Visible = true
        if not isMinimized then
            ShadowFrame.Visible = true
            LeftPanel.Visible = true
            RightContainer.Visible = true
        end
        TweenService:Create(MainScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = UI_SCALE}):Play()
        TweenService:Create(ShadowScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = UI_SCALE}):Play()
    else
        local closeTween = TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0.2})
        TweenService:Create(ShadowScale, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0.2}):Play()
        closeTween:Play()
        closeTween.Completed:Connect(function()
            if not isMenuOpen then
                MainFrame.Visible = false
                ShadowFrame.Visible = false
            end
        end)
    end
end

-- Перетаскивание окна
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        MainFrame.Position = targetPos
        ShadowFrame.Position = UDim2.new(
            targetPos.X.Scale, targetPos.X.Offset + 4,
            targetPos.Y.Scale, targetPos.Y.Offset + 6
        )
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
-- ЗАПУСК
-- ============================================================

selectLanguage()
createDiscordButton()

if getgenv().NKNO.Language then
    showUpdateNotice()
end

local startMsg = {
    ru = "Нажми Left Alt для открытия меню",
    en = "Press Left Alt to open menu"
}
Notify("NKNO$ HUB", T(startMsg.ru, startMsg.en), 4)

populateCategory("MAIN")
for _, b in pairs(CategoryList:GetChildren()) do
    if b:IsA("TextButton") and b.Text == "MAIN" then
        b.BackgroundColor3 = Color3.fromRGB(60,60,80)
        b.TextColor3 = Color3.fromRGB(255,215,0)
    end
end

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        updateESP()
        autoGrabGun()
        antiSheriff()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applyWalkSpeed()
    applyJumpPower()
    if getgenv().NKNO.ForceFieldMaterial then applyForceField() end
    if getgenv().NKNO.GodMode then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if getgenv().NKNO.AutoDance then playDance() end
    if getgenv().NKNO.AntiFling then
        stopAntiFling()
        startAntiFling()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        toggleMenu()
    end
end)

if getgenv().NKNO.AntiFling then
    startAntiFling()
end
