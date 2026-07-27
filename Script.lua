-- ====================================================
--    MM2 ULTRA CHEAT V5 - PULSE HUB STYLE
--    С ЗАМОРОЗКОЙ ТРЕЙДА + ПРОФИЛЬ В УГЛУ
--    ВСЕ ФУНКЦИИ ВЫКЛЮЧЕНЫ ПО УМОЛЧАНИЮ
-- ====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ЖДЁМ ПЕРСОНАЖА
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ===== ПЕРЕМЕННЫЕ (ВСЕ ВЫКЛЮЧЕНЫ) =====
local flyEnabled = false
local noclipEnabled = false
local godModeEnabled = false
local antiFlingEnabled = false
local autoFarmEnabled = false
local autoKillEnabled = false
local espEnabled = false
local tradeFreezeEnabled = false
local flySpeed = 50
local walkSpeed = 16
local bodyVelocity = nil
local bodyGyro = nil
local collectedCoins = 0
local farmConnection = nil
local espObjects = {}
local isMinimized = false
local isDragging = false
local dragStart = nil
local startPos = nil
local currentTab = "Main"

-- ===== СОЗДАНИЕ GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PulseHubGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ===== ПРОФИЛЬ В УГЛУ (УЛУЧШЕННЫЙ) =====
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(0, 130, 0, 170)
profileFrame.Position = UDim2.new(0, 10, 0, 10)
profileFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
profileFrame.BackgroundTransparency = 0.1
profileFrame.BorderSizePixel = 2
profileFrame.BorderColor3 = Color3.fromRGB(100, 100, 255)
profileFrame.ClipsDescendants = true
profileFrame.Parent = screenGui

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0, 12)
profileCorner.Parent = profileFrame

-- Градиент профиля
local profileGradient = Instance.new("UIGradient")
profileGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
})
profileGradient.Parent = profileFrame

-- Аватарка
local profileAvatar = Instance.new("ImageLabel")
profileAvatar.Size = UDim2.new(1, -20, 0.55, -10)
profileAvatar.Position = UDim2.new(0, 10, 0, 8)
profileAvatar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
profileAvatar.BackgroundTransparency = 0.3
profileAvatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
profileAvatar.Parent = profileFrame

local profileAvatarCorner = Instance.new("UICorner")
profileAvatarCorner.CornerRadius = UDim.new(0, 8)
profileAvatarCorner.Parent = profileAvatar

-- Имя игрока
local profileName = Instance.new("TextLabel")
profileName.Size = UDim2.new(1, -10, 0.2, 0)
profileName.Position = UDim2.new(0, 5, 0.58, 0)
profileName.BackgroundTransparency = 1
profileName.Text = LocalPlayer.Name
profileName.TextColor3 = Color3.fromRGB(255, 255, 255)
profileName.TextScaled = true
profileName.Font = Enum.Font.GothamBold
profileName.TextXAlignment = Enum.TextXAlignment.Center
profileName.Parent = profileFrame

-- Роль игрока
local profileRole = Instance.new("TextLabel")
profileRole.Size = UDim2.new(1, -10, 0.18, 0)
profileRole.Position = UDim2.new(0, 5, 0.75, 0)
profileRole.BackgroundTransparency = 1
profileRole.Text = "👤 НЕВИННЫЙ"
profileRole.TextColor3 = Color3.fromRGB(200, 200, 200)
profileRole.TextScaled = true
profileRole.Font = Enum.Font.Gotham
profileRole.TextXAlignment = Enum.TextXAlignment.Center
profileRole.Parent = profileFrame

-- Статус (онлайн/оффлайн)
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 12, 0, 12)
statusDot.Position = UDim2.new(0, 8, 0, 8)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
statusDot.BorderSizePixel = 0
statusDot.Parent = profileFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = statusDot

-- Кнопка сворачивания профиля
local profileMinimize = Instance.new("TextButton")
profileMinimize.Size = UDim2.new(0, 20, 0, 20)
profileMinimize.Position = UDim2.new(1, -25, 0, 5)
profileMinimize.BackgroundTransparency = 1
profileMinimize.Text = "−"
profileMinimize.TextColor3 = Color3.fromRGB(255, 255, 255)
profileMinimize.TextScaled = true
profileMinimize.Font = Enum.Font.GothamBold
profileMinimize.Parent = profileFrame

local profileMinimized = false
profileMinimize.MouseButton1Click:Connect(function()
    profileMinimized = not profileMinimized
    if profileMinimized then
        profileFrame:TweenSize(UDim2.new(0, 130, 0, 35), "Out", "Quad", 0.3)
        profileMinimize.Text = "+"
        profileAvatar.Visible = false
        profileName.Visible = false
        profileRole.Visible = false
    else
        profileFrame:TweenSize(UDim2.new(0, 130, 0, 170), "Out", "Quad", 0.3)
        profileMinimize.Text = "−"
        wait(0.3)
        profileAvatar.Visible = true
        profileName.Visible = true
        profileRole.Visible = true
    end
end)

-- ===== ГЛАВНОЕ МЕНЮ (PULSE HUB СТИЛЬ) =====
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 520)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Glow эффект
local glowBorder = Instance.new("Frame")
glowBorder.Size = UDim2.new(1, 4, 1, 4)
glowBorder.Position = UDim2.new(0, -2, 0, -2)
glowBorder.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
glowBorder.BackgroundTransparency = 0.8
glowBorder.BorderSizePixel = 0
glowBorder.Parent = mainFrame

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 18)
glowCorner.Parent = glowBorder

-- Анимация свечения
RunService.Heartbeat:Connect(function()
    local pulse = (math.sin(tick() * 1.5) + 1) / 2
    glowBorder.BackgroundTransparency = 0.5 + (pulse * 0.3)
    glowBorder.BackgroundColor3 = Color3.fromRGB(
        100 + (pulse * 55),
        100 + (pulse * 30),
        255
    )
end)

-- ===== ЗАГОЛОВОК =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
titleBar.BackgroundTransparency = 0.2
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ PULSE HUB ⚡"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 1, -8)
closeBtn.Position = UDim2.new(1, -42, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Кнопка свёртывания
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 1, -8)
minimizeBtn.Position = UDim2.new(1, -82, 0, 4)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 420, 0, 50), "Out", "Quad", 0.3)
        minimizeBtn.Text = "□"
    else
        mainFrame:TweenSize(UDim2.new(0, 420, 0, 520), "Out", "Quad", 0.3)
        minimizeBtn.Text = "─"
    end
end)

-- ===== ВКЛАДКИ =====
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.Position = UDim2.new(0, 0, 0, 50)
tabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
tabContainer.BackgroundTransparency = 0.1
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 2)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = tabContainer

-- Создание вкладок
local tabs = {}
local tabButtons = {}

local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.BackgroundTransparency = 0.3
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.AutoButtonColor = false
    btn.Parent = tabContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    tabButtons[name] = btn
    tabs[name] = btn
    
    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    
    return btn
end

-- Создаём вкладки
local tabMain = createTab("Main", "🏠")
local tabCombat = createTab("Combat", "⚔️")
local tabMovement = createTab("Movement", "🚀")
local tabVisual = createTab("Visual", "👁️")
local tabTrade = createTab("Trade", "💎")

-- ===== КОНТЕНТ ВКЛАДОК =====
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -110)
contentContainer.Position = UDim2.new(0, 10, 0, 95)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 6)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
contentLayout.Parent = contentContainer

-- Хранилище для контента вкладок
local tabContent = {}

-- ===== ФУНКЦИЯ ПЕРЕКЛЮЧЕНИЯ ВКЛАДОК =====
function switchTab(tabName)
    currentTab = tabName
    
    -- Обновляем кнопки
    for name, btn in pairs(tabButtons) do
        if name == tabName then
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
            btn.BackgroundTransparency = 0.1
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    -- Показываем нужный контент
    for name, container in pairs(tabContent) do
        container.Visible = (name == tabName)
    end
end

-- ===== ФУНКЦИЯ СОЗДАНИЯ КНОПКИ =====
local function createPulseButton(parent, text, color, callback, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.1
    btn.Text = (icon or "") .. " " .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    -- Эффект наведения
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 40)}):Play()
        callback()
    end)
    
    return btn
end

-- ===== СОЗДАНИЕ КОНТЕНТА ВКЛАДОК =====

-- 1. MAIN TAB
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 0, 400)
mainContent.BackgroundTransparency = 1
mainContent.Parent = contentContainer
mainContent.Visible = true
tabContent["Main"] = mainContent

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 6)
mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainLayout.VerticalAlignment = Enum.VerticalAlignment.Top
mainLayout.Parent = mainContent

-- Кнопки MAIN
local farmBtn = createPulseButton(mainContent, "AUTO FARM", Color3.fromRGB(200, 160, 0), function()
    if autoFarmEnabled then
        stopAutoFarm()
        farmBtn.Text = "💰 AUTO FARM OFF"
        farmBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 0)
    else
        startAutoFarm()
        farmBtn.Text = "🛑 AUTO FARM ON"
        farmBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    end
end, "💰")

local killBtn = createPulseButton(mainContent, "AUTO KILL", Color3.fromRGB(200, 40, 40), function()
    autoKillEnabled = not autoKillEnabled
    killBtn.Text = autoKillEnabled and "🛑 AUTO KILL ON" or "🔪 AUTO KILL OFF"
    killBtn.BackgroundColor3 = autoKillEnabled and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
end, "🔪")

local godBtn = createPulseButton(mainContent, "GOD MODE", Color3.fromRGB(200, 50, 200), function()
    godModeEnabled = not godModeEnabled
    godBtn.Text = godModeEnabled and "🛡️ GOD MODE ON" or "⚔️ GOD MODE OFF"
    godBtn.BackgroundColor3 = godModeEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 200)
    
    if godModeEnabled then
        Humanoid.MaxHealth = 1e9
        Humanoid.Health = 1e9
        Humanoid.BreakJointsOnDeath = false
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        sendMessage("🛡️ БЕССМЕРТИЕ ВКЛЮЧЕНО!")
    else
        Humanoid.MaxHealth = 100
        Humanoid.Health = 100
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        Humanoid.BreakJointsOnDeath = true
        sendMessage("⚔️ БЕССМЕРТИЕ ВЫКЛЮЧЕНО!")
    end
end, "🛡️")

-- 2. COMBAT TAB
local combatContent = Instance.new("Frame")
combatContent.Size = UDim2.new(1, 0, 0, 400)
combatContent.BackgroundTransparency = 1
combatContent.Parent = contentContainer
combatContent.Visible = false
tabContent["Combat"] = combatContent

local combatLayout = Instance.new("UIListLayout")
combatLayout.Padding = UDim.new(0, 6)
combatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
combatLayout.VerticalAlignment = Enum.VerticalAlignment.Top
combatLayout.Parent = combatContent

-- FLING
local flingContainer = Instance.new("Frame")
flingContainer.Size = UDim2.new(1, 0, 0, 45)
flingContainer.BackgroundTransparency = 1
flingContainer.Parent = combatContent

local flingLayout = Instance.new("UIListLayout")
flingLayout.FillDirection = Enum.FillDirection.Horizontal
flingLayout.Padding = UDim.new(0, 5)
flingLayout.Parent = flingContainer

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.6, 0, 1, 0)
nameBox.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
nameBox.Text = "имя игрока"
nameBox.TextColor3 = Color3.fromRGB(200, 200, 200)
nameBox.TextScaled = true
nameBox.Font = Enum.Font.Gotham
nameBox.ClearTextOnFocus = false
nameBox.Parent = flingContainer

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 10)
nameCorner.Parent = nameBox

local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(0.4, 0, 1, 0)
flingBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 0)
flingBtn.Text = "💥 FLING"
flingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flingBtn.TextScaled = true
flingBtn.Font = Enum.Font.GothamSemibold
flingBtn.Parent = flingContainer

local flingCorner = Instance.new("UICorner")
flingCorner.CornerRadius = UDim.new(0, 10)
flingCorner.Parent = flingBtn

flingBtn.MouseButton1Click:Connect(function()
    local target = findPlayer(nameBox.Text)
    if target then
        flingPlayer(target)
    else
        sendMessage("[FLING] Игрок не найден!")
    end
end)

local flingAllBtn = createPulseButton(combatContent, "FLING ALL", Color3.fromRGB(180, 30, 0), function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            flingPlayer(player)
        end
    end
    sendMessage("[FLING] Все отброшены!")
end, "💥")

-- 3. MOVEMENT TAB
local movementContent = Instance.new("Frame")
movementContent.Size = UDim2.new(1, 0, 0, 400)
movementContent.BackgroundTransparency = 1
movementContent.Parent = contentContainer
movementContent.Visible = false
tabContent["Movement"] = movementContent

local movementLayout = Instance.new("UIListLayout")
movementLayout.Padding = UDim.new(0, 6)
movementLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
movementLayout.VerticalAlignment = Enum.VerticalAlignment.Top
movementLayout.Parent = movementContent

local flyBtn = createPulseButton(movementContent, "FLY", Color3.fromRGB(40, 80, 200), function()
    flyEnabled = not flyEnabled
    if flyEnabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = RootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.CFrame = RootPart.CFrame
        bodyGyro.Parent = RootPart
        
        Humanoid.PlatformStand = true
        flyBtn.Text = "🛑 FLY ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        Humanoid.PlatformStand = false
        flyBtn.Text = "🪁 FLY OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 200)
    end
end, "🪁")

local noclipBtn = createPulseButton(movementContent, "NOCLIP", Color3.fromRGB(40, 180, 100), function()
    noclipEnabled = not noclipEnabled
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
    noclipBtn.Text = noclipEnabled and "🛑 NOCLIP ON" or "🧊 NOCLIP OFF"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(40, 180, 100)
end, "🧊")

local antiFlingBtn = createPulseButton(movementContent, "ANTI-FLING", Color3.fromRGB(200, 150, 0), function()
    antiFlingEnabled = not antiFlingEnabled
    antiFlingBtn.Text = antiFlingEnabled and "🛡️ ANTI-FLING ON" or "💥 ANTI-FLING OFF"
    antiFlingBtn.BackgroundColor3 = antiFlingEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 150, 0)
    sendMessage(antiFlingEnabled and "🛡️ АНТИ-ФЛИНГ ВКЛЮЧЕН!" or "💥 АНТИ-ФЛИНГ ВЫКЛЮЧЕН!")
end, "🛡️")

-- SPEED SLIDER
local speedContainer = Instance.new("Frame")
speedContainer.Size = UDim2.new(1, 0, 0, 70)
speedContainer.BackgroundTransparency = 1
speedContainer.Parent = movementContent

local speedLayout2 = Instance.new("UIListLayout")
speedLayout2.FillDirection = Enum.FillDirection.Vertical
speedLayout2.Padding = UDim.new(0, 3)
speedLayout2.Parent = speedContainer

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ Speed: 16 | Fly: 50"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.Parent = speedContainer

local speedSlider = Instance.new("TextBox")
speedSlider.Size = UDim2.new(1, 0, 0, 35)
speedSlider.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
speedSlider.Text = "16"
speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSlider.TextScaled = true
speedSlider.Font = Enum.Font.Gotham
speedSlider.Parent = speedContainer

local speedCorner2 = Instance.new("UICorner")
speedCorner2.CornerRadius = UDim.new(0, 10)
speedCorner2.Parent = speedSlider

speedSlider.FocusLost:Connect(function()
    local newSpeed = tonumber(speedSlider.Text)
    if newSpeed and newSpeed >= 10 and newSpeed <= 140 then
        walkSpeed = newSpeed
        Humanoid.WalkSpeed = walkSpeed
        speedLabel.Text = "⚡ Speed: " .. walkSpeed .. " | Fly: " .. flySpeed
    else
        speedSlider.Text = tostring(walkSpeed)
    end
end)

-- FLY SPEED SLIDER
local flySpeedContainer2 = Instance.new("Frame")
flySpeedContainer2.Size = UDim2.new(1, 0, 0, 70)
flySpeedContainer2.BackgroundTransparency = 1
flySpeedContainer2.Parent = movementContent

local flySpeedLayout2 = Instance.new("UIListLayout")
flySpeedLayout2.FillDirection = Enum.FillDirection.Vertical
flySpeedLayout2.Padding = UDim.new(0, 3)
flySpeedLayout2.Parent = flySpeedContainer2

local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(1, 0, 0, 25)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "✈️ Fly Speed: 50"
flySpeedLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
flySpeedLabel.TextScaled = true
flySpeedLabel.Font = Enum.Font.GothamSemibold
flySpeedLabel.Parent = flySpeedContainer2

local flySpeedSlider = Instance.new("TextBox")
flySpeedSlider.Size = UDim2.new(1, 0, 0, 35)
flySpeedSlider.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
flySpeedSlider.Text = "50"
flySpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedSlider.TextScaled = true
flySpeedSlider.Font = Enum.Font.Gotham
flySpeedSlider.Parent = flySpeedContainer2

local flySpeedCorner2 = Instance.new("UICorner")
flySpeedCorner2.CornerRadius = UDim.new(0, 10)
flySpeedCorner2.Parent = flySpeedSlider

flySpeedSlider.FocusLost:Connect(function()
    local newSpeed = tonumber(flySpeedSlider.Text)
    if newSpeed and newSpeed >= 10 and newSpeed <= 140 then
        flySpeed = newSpeed
        flySpeedLabel.Text = "✈️ Fly Speed: " .. flySpeed
        speedLabel.Text = "⚡ Speed: " .. walkSpeed .. " | Fly: " .. flySpeed
    else
        flySpeedSlider.Text = tostring(flySpeed)
    end
end)

-- 4. VISUAL TAB
local visualContent = Instance.new("Frame")
visualContent.Size = UDim2.new(1, 0, 0, 400)
visualContent.BackgroundTransparency = 1
visualContent.Parent = contentContainer
visualContent.Visible = false
tabContent["Visual"] = visualContent

local visualLayout = Instance.new("UIListLayout")
visualLayout.Padding = UDim.new(0, 6)
visualLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
visualLayout.VerticalAlignment = Enum.VerticalAlignment.Top
visualLayout.Parent = visualContent

local espBtn = createPulseButton(visualContent, "ESP", Color3.fromRGB(150, 40, 200), function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "🛑 ESP ON" or "👁️ ESP OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(150, 40, 200)
    if not espEnabled then
        for _, data in pairs(espObjects) do
            if data.Billboard then data.Billboard:Destroy() end
        end
        espObjects = {}
    end
end, "👁️")

-- 5. TRADE TAB
local tradeContent = Instance.new("Frame")
tradeContent.Size = UDim2.new(1, 0, 0, 400)
tradeContent.BackgroundTransparency = 1
tradeContent.Parent = contentContainer
tradeContent.Visible = false
tabContent["Trade"] = tradeContent

local tradeLayout = Instance.new("UIListLayout")
tradeLayout.Padding = UDim.new(0, 6)
tradeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tradeLayout.VerticalAlignment = Enum.VerticalAlignment.Top
tradeLayout.Parent = tradeContent

-- ===== ЗАМОРОЗКА ТРЕЙДА =====
local tradeFreezeBtn = createPulseButton(tradeContent, "FREEZE TRADE", Color3.fromRGB(0, 150, 200), function()
    tradeFreezeEnabled = not tradeFreezeEnabled
    tradeFreezeBtn.Text = tradeFreezeEnabled and "🛑 FREEZE ON" or "❄️ FREEZE OFF"
    tradeFreezeBtn.BackgroundColor3 = tradeFreezeEnabled and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(0, 150, 200)
    
    if tradeFreezeEnabled then
        sendMessage("❄️ ЗАМОРОЗКА ТРЕЙДА ВКЛЮЧЕНА!")
        -- Начинаем заморозку
        startTradeFreeze()
    else
        sendMessage("🔥 ЗАМОРОЗКА ТРЕЙДА ВЫКЛЮЧЕНА!")
        stopTradeFreeze()
    end
end, "❄️")

-- ===== ЛОГИКА ЗАМОРОЗКИ ТРЕЙДА =====
local tradeFreezeConnection = nil
local tradeItems = {}

function startTradeFreeze()
    if tradeFreezeConnection then return end
    
    tradeFreezeConnection = RunService.Heartbeat:Connect(function()
        if not tradeFreezeEnabled then return end
        
        -- Ищем окно трейда
        local tradeGui = LocalPlayer.PlayerGui:FindFirstChild("TradeGui")
        if not tradeGui then return end
        
        -- Ищем ваши предметы в трейде
        local yourItems = tradeGui:FindFirstChild("YourItems")
        if not yourItems then return end
        
        -- Замораживаем каждый предмет (не даём убрать)
        for _, item in pairs(yourItems:GetChildren()) do
            if item:IsA("ImageButton") or item:IsA("TextButton") then                -- Делаем предмет кликабельным только для добавления
                -- Но блокируем удаление
                local originalClick = item.MouseButton1Click
                item.MouseButton1Click:Connect(function()
                    -- Если предмет уже в трейде - блокируем удаление
                    if item.BackgroundColor3 == Color3.fromRGB(100, 200, 100) then
                        sendMessage("❄️ Предмет заморожен! Его нельзя убрать!")
                        return
                    end
                end)
            end
        end
        
        -- Сканируем инвентарь и блокируем удаление предметов
        local inventory = LocalPlayer:FindFirstChild("Inventory")
        if inventory then
            for _, item in pairs(inventory:GetChildren()) do
                if item:IsA("Tool") or item:IsA("Model") then
                    -- Запоминаем все предметы
                    tradeItems[item.Name] = true
                end
            end
        end
    end)
end

function stopTradeFreeze()
    if tradeFreezeConnection then
        tradeFreezeConnection:Disconnect()
        tradeFreezeConnection = nil
    end
    tradeItems = {}
end

-- Альтернативный метод заморозки через ReplicatedStorage
local function alternativeFreeze()
    -- Перехватываем событие удаления предмета из трейда
    local tradeEvents = ReplicatedStorage:FindFirstChild("TradeEvents")
    if tradeEvents then
        local removeEvent = tradeEvents:FindFirstChild("RemoveItem")
        if removeEvent then
            local oldFire = removeEvent.FireServer
            removeEvent.FireServer = function(...)
                if tradeFreezeEnabled then
                    sendMessage("❄️ Заморозка активна! Предмет нельзя убрать!")
                    return
                end
                return oldFire(...)
            end
        end
    end
end

-- ===== ПЕРЕТАСКИВАНИЕ =====
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- ===== ФУНКЦИИ =====
function sendMessage(text)
    local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chat then
        local sayMessage = chat:FindFirstChild("SayMessageRequest")
        if sayMessage then
            sayMessage:FireServer(text, "All")
        end
    end
end

function findPlayer(name)
    local found = nil
    for _, player in pairs(Players:GetPlayers()) do
        if string.lower(player.Name):find(string.lower(name)) then
            found = player
            break
        end
    end
    return found
end

function flingPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    if antiFlingEnabled then
        sendMessage("⚠️ У " .. targetPlayer.Name .. " включён АНТИ-ФЛИНГ!")
        return
    end
    
    local direction = (targetRoot.Position - RootPart.Position).Unit
    local randomOffset = Vector3.new(
        math.random(-10, 10),
        math.random(5, 20),
        math.random(-10, 10)
    )
    local force = (direction + randomOffset) * 5000
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = force
    bv.Parent = targetRoot
    game:GetService("Debris"):AddItem(bv, 0.5)
end

-- ===== АВТОФАРМ =====
function findCoins()
    local coins = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("coin") then
            table.insert(coins, obj)
        end
    end
    return coins
end

function startAutoFarm()
    if farmConnection then farmConnection:Disconnect() end
    
    autoFarmEnabled = true
    
    farmConnection = RunService.Heartbeat:Connect(function()
        if not autoFarmEnabled then return end
        
        local coins = findCoins()
        if #coins == 0 then return end
        
        local nearest = nil
        local nearestDist = 500
        
        for _, coin in pairs(coins) do
            local dist = (RootPart.Position - coin.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = coin
            end
        end
        
        if nearest then
            local targetPos = nearest.Position + Vector3.new(0, 3, 0)
            local direction = (targetPos - RootPart.Position).Unit
            local distance = (targetPos - RootPart.Position).Magnitude
            
            if distance > 5 then
                local speed = math.min(flySpeed, distance * 2)
                RootPart.Velocity = direction * speed
            else
                collectedCoins = collectedCoins + 1
                nearest:Destroy()
            end
        end
    end)
end

function stopAutoFarm()
    autoFarmEnabled = false
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
    RootPart.Velocity = Vector3.new(0, 0, 0)
end

-- ===== ESP =====
function getPlayerRole(player)
    local character = player.Character
    if not character then return "Innocent" end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("murder") or toolName:find("blade") then
                return "Murderer"
            elseif toolName:find("gun") or toolName:find("pistol") or toolName:find("sheriff") then
                return "Sheriff"
            end
        end
    end
    return "Innocent"
end

function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 50, 50)
    elseif role == "Sheriff" then return Color3.fromRGB(50, 150, 255)
    else return Color3.fromRGB(200, 200, 200) end
end

function createESP(player)
    if not player or player == LocalPlayer then return end
    if espObjects[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local role = getPlayerRole(player)
    local color = getRoleColor(role)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.6
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color
    frame.Parent = billboard
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name .. " [" .. role .. "]"
    nameLabel.TextColor3 = color
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = frame
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = frame
    
    espObjects[player] = {
        Billboard = billboard,
        NameLabel = nameLabel,
        DistLabel = distLabel,
        Character = character
    }
end

function updateESP()
    if not espEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not espObjects[player] or espObjects[player].Character ~= player.Character then
                createESP(player)
            end
            
            local data = espObjects[player]
            if data then
                local dist = (RootPart.Position - (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0))).Magnitude
                if data.DistLabel then
                    data.DistLabel.Text = math.floor(dist) .. "m"
                end
                
                local role = getPlayerRole(player)
                local color = getRoleColor(role)
                if data.NameLabel then
                    data.NameLabel.Text = player.Name .. " [" .. role .. "]"
                    data.NameLabel.TextColor3 = color
                end
                if data.Billboard and data.Billboard.Frame then
                    data.Billboard.Frame.BorderColor3 = color
                end
            end
        end
    end
end

-- ===== АНТИ-ФЛИНГ ЛОГИКА =====
RunService.Heartbeat:Connect(function()
    if antiFlingEnabled and RootPart then
        local speed = RootPart.Velocity.Magnitude
        if speed > 200 then
            RootPart.Velocity = Vector3.new(0, 0, 0)
            RootPart.CFrame = RootPart.CFrame
            
            local effect = Instance.new("Part")
            effect.Size = Vector3.new(3, 3, 3)
            effect.Position = RootPart.Position
            effect.Anchored = true
            effect.CanCollide = false
            effect.Material = Enum.Material.Neon
            effect.BrickColor = BrickColor.new("Bright blue")
            effect.Transparency = 0.5
            effect.Parent = Workspace
            game:GetService("Debris"):AddItem(effect, 0.5)
            
            TweenService:Create(effect, TweenInfo.new(0.3), {Size = Vector3.new(10, 10, 10), Transparency = 1}):Play()
        end
    end
end)

-- ===== АВТОКИЛЛ =====
function autoKill()
    if not autoKillEnabled then return end
    
    local myRole = getPlayerRole(LocalPlayer)
    if myRole == "Innocent" then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRole = getPlayerRole(player)
            
            if myRole == "Murderer" and targetRole ~= "Murderer" then
                killPlayer(player)
                return
            end
            
            if myRole == "Sheriff" and targetRole == "Murderer" then
                killPlayer(player)
                return
            end
        end
    end
end

function killPlayer(player)
    if not player or not player.Character then return end
    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    RootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
    
    local weapon = nil
    for _, tool in pairs(Character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("gun")) then
            weapon = tool
            break
        end
    end
    
    if weapon then
        Humanoid:EquipTool(weapon)
        wait(0.1)
        
        local attackEvent = ReplicatedStorage:FindFirstChild("AttackEvent")
        if attackEvent then
            attackEvent:FireServer()
        end
    end
end

-- ===== ОБНОВЛЕНИЕ РОЛИ =====
function updatePlayerRole()
    local role = getPlayerRole(LocalPlayer)
    local roleNames = {
        Murderer = "🔪 УБИЙЦА",
        Sheriff = "🔫 ШЕРИФ",
        Innocent = "👤 НЕВИННЫЙ"
    }
    profileRole.Text = roleNames[role] or "👤 НЕВИННЫЙ"
    profileRole.TextColor3 = getRoleColor(role)
end

-- ===== ОСНОВНОЙ ЦИКЛ =====
RunService.Heartbeat:Connect(function()
    -- Fly
    if flyEnabled then
        if not Character or not Character.Parent then return end
        
        local moveDirection = Vector3.new(0, 0, 0)
        local forward = Character.Head.CFrame.LookVector
        local right = Character.Head.CFrame.RightVector
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * flySpeed
        end
        
        if bodyVelocity then
            bodyVelocity.Velocity = moveDirection
        end
        if bodyGyro then
            bodyGyro.CFrame = RootPart.CFrame
        end
    end
    
    -- ESP
    if espEnabled then
        updateESP()
    end
    
    -- Auto Kill
    if autoKillEnabled then
        autoKill()
    end
    
    -- Update role
    updatePlayerRole()
end)

-- ===== ГОРЯЧИЕ КЛАВИШИ =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        flyBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F2 then
        noclipBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F3 then
        farmBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F4 then
        killBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        godBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F6 then
        antiFlingBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        espBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F8 then
        tradeFreezeBtn.MouseButton1Click:Fire()
    end
end)

-- ===== ЧАТ КОМАНДЫ =====
LocalPlayer.Chatted:Connect(function(message)
    local args = {}
    for word in string.gmatch(message, "%S+") do
        table.insert(args, word)
    end
    
    if #args == 0 then return end
    local command = string.lower(args[1])
    
    if command == "fly" then
        flyBtn.MouseButton1Click:Fire()
    elseif command == "noclip" then
        noclipBtn.MouseButton1Click:Fire()
    elseif command == "farm" or command == "autofarm" then
        farmBtn.MouseButton1Click:Fire()
    elseif command == "kill" or command == "autokill" then
        killBtn.MouseButton1Click:Fire()
    elseif command == "god" or command == "godmode" then
        godBtn.MouseButton1Click:Fire()
    elseif command == "antifling" or command == "af" then
        antiFlingBtn.MouseButton1Click:Fire()
    elseif command == "esp" then
        espBtn.MouseButton1Click:Fire()
    elseif command == "freeze" or command == "tradefreeze" then
        tradeFreezeBtn.MouseButton1Click:Fire()
    elseif command == "fling" and #args >= 2 then
        local target = findPlayer(args[2])
        if target then flingPlayer(target) end
    elseif command == "flingall" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                flingPlayer(player)
            end
        end
    elseif command == "help" then
        sendMessage("=== PULSE HUB V5 ===")
        sendMessage("🏠 Main: farm, kill, god")
        sendMessage("⚔️ Combat: fling, flingall")
        sendMessage("🚀 Movement: fly, noclip, antifling, speed, flyspeed")
        sendMessage("👁️ Visual: esp")
        sendMessage("💎 Trade: freeze")
        sendMessage("=== HOTKEYS: F1-Fly, F2-Noclip, F3-Farm, F4-Kill, F5-God, F6-AntiFling, F7-ESP, F8-Freeze")
    end
end)

-- ===== ИНИЦИАЛИЗАЦИЯ =====
Humanoid.WalkSpeed = walkSpeed
updatePlayerRole()

-- Включаем первую вкладку
switchTab("Main")

sendMessage("⚡ PULSE HUB V5 ЗАГРУЖЕН!")
sendMessage("📌 Все функции выключены по умолчанию")
sendMessage("📌 Напишите 'help' для списка команд")

print("✅ PULSE HUB V5 LOADED!")
print("📌 All features are OFF by default")
print("📌 Commands: help")
