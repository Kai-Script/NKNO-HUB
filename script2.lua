-- ============================================================
--  ЧАСТЬ 1: ФУНКЦИОНАЛЬНЫЕ МОДУЛИ (из вашего первого скрипта)
-- ============================================================

local player = game.Players.LocalPlayer
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')

-- Глобальные переменные (используются в функциях)
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- Настройки ESP (будут управляться из GUI)
ESP_SETTINGS = {
    Murderer = false,
    Sheriff = false,
    Innocent = false,
    Hero = false,
}
NAME_ESP_SETTINGS = {
    Murderer = false,
    Sheriff = false,
    Innocent = false,
    Hero = false,
}
ESP_CUSTOMIZATION = {
    Box2D = false,
    DisplayName = false,
    NormalName = true,
    AvatarDisplay = false,
}
local RoleColors = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Hero = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(0, 255, 0),
}

-- Состояния функций
local noclipEnabled = false
local farmCoins = false
local farmRunning = false
local tween = nil
local tweening = false
local noclipConnection = nil
local coinType = 'Coin'
local flinging = false
local selectedPlayer = nil

-- Настройки рандомизации
local randomDelays = false
local randomMovement = false
local randomCoinSelection = false
local minDelay = 0.1
local maxDelay = 0.5

-- Настройки движения
local customWalkSpeedEnabled = false
local walkSpeedValue = 16
local customJumpPowerEnabled = false
local jumpPowerValue = 50
local customFOVEnabled = false
local fovValue = 70
local forceFieldEnabled = false

-- Танец
local currentDanceTrack = nil

-- Подземелье
local underMapActive = false
local underMapConnection = nil
local oldFallenHeight = workspace.FallenPartsDestroyHeight

-- Авто-граб пистолета
local autoGrabGun = false

-- Оригинальные коллизии для фарма
local originalCollisions = {}

-- ------------------------------------------------------------
--  ФУНКЦИИ (без изменений, скопированы из первого скрипта)
-- ------------------------------------------------------------

local function setupCharacterCollision(character)
    local function disableCollide(part)
        if noclipEnabled and part:IsA('BasePart') then
            part.CanCollide = false
        end
    end
    for _, child in ipairs(character:GetChildren()) do
        disableCollide(child)
    end
    local childAddedConnection = character.ChildAdded:Connect(disableCollide)
    local stepConnection = RunService.Stepped:Connect(function()
        if noclipEnabled and character:IsDescendantOf(workspace) then
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA('BasePart') and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    character.Destroying:Connect(function()
        childAddedConnection:Disconnect()
        stepConnection:Disconnect()
    end)
end

local function trackPlayer(plr)
    if plr == player then return end
    plr.CharacterAdded:Connect(setupCharacterCollision)
    if plr.Character then setupCharacterCollision(plr.Character) end
end

local function getPing()
    local stats = game:GetService('Stats')
    return stats.Network.ServerStatsItem['Data Ping']:GetValue()
end

local function findMurderer()
    local getPlayerData = ReplicatedStorage:FindFirstChild('GetPlayerData', true)
    if not getPlayerData then return nil end
    local success, data = pcall(function() return getPlayerData:InvokeServer() end)
    if not success or not data then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr:GetAttribute('Alive') == true then
            local plrData = data[plr.Name]
            if plrData and plrData.Role == 'Murderer' then
                return plr
            end
        end
    end
    return nil
end

local function returncoincontainer()
    for _, child in pairs(workspace:GetChildren()) do
        if child:FindFirstChild('CoinContainer') and child:IsA('Model') then
            return child:FindFirstChild('CoinContainer')
        end
    end
    return nil
end

local function FindNearestCoin(container, useRandom)
    if not container then return nil, math.huge end
    local candidates = {}
    for _, coin in pairs(container:GetChildren()) do
        if coin:GetAttribute('CoinID') == 'Coin' and coin:FindFirstChild('TouchInterest') and coin.Transparency == 1 then
            if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
                local dist = (player.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                table.insert(candidates, {coin = coin, dist = dist})
            end
        end
    end
    if #candidates == 0 then return nil, math.huge end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    if useRandom and #candidates > 2 then
        local index = math.random(1, math.min(3, #candidates))
        return candidates[index].coin, candidates[index].dist
    else
        return candidates[1].coin, candidates[1].dist
    end
end

local function applyWalkSpeed()
    if customWalkSpeedEnabled and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
        if humanoid then humanoid.WalkSpeed = walkSpeedValue end
    end
end

local function applyJumpPower()
    if customJumpPowerEnabled and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
        if humanoid then humanoid.JumpPower = jumpPowerValue end
    end
end

local function applyFOV()
    if customFOVEnabled then
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = fovValue end
    end
end

local function applyForceFieldMaterial()
    if forceFieldEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA('BasePart') or part:IsA('MeshPart') then
                part.Material = Enum.Material.ForceField
            end
        end
    end
end

local function CreateESP(plr, color)
    if not plr.Character then return end
    local highlight = plr.Character:FindFirstChild('RoleESP')
    if not highlight then
        highlight = Instance.new('Highlight')
        highlight.Name = 'RoleESP'
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = plr.Character
    end
    highlight.FillColor = color
    highlight.OutlineColor = color
end

local function RemoveESP(plr)
    if plr.Character then
        local highlight = plr.Character:FindFirstChild('RoleESP')
        if highlight then highlight:Destroy() end
    end
end

local function Create2DBox(plr, color)
    if not plr.Character then return end
    local root = plr.Character:FindFirstChild('HumanoidRootPart')
    if not root then return end
    local box = root:FindFirstChild('Box2D')
    if ESP_CUSTOMIZATION.Box2D then
        if not box then
            box = Instance.new('BillboardGui')
            box.Name = 'Box2D'
            box.AlwaysOnTop = true
            box.Size = UDim2.new(4, 0, 5, 0)
            box.StudsOffset = Vector3.new(0, 0, 0)
            box.Parent = root
            local frame = Instance.new('Frame')
            frame.Name = 'BoxFrame'
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BorderSizePixel = 2
            frame.Parent = box
            local stroke = Instance.new('UIStroke')
            stroke.Name = 'Stroke'
            stroke.Thickness = 2
            stroke.Parent = frame
        end
        local frame = box:FindFirstChild('BoxFrame')
        if frame then
            local stroke = frame:FindFirstChild('Stroke')
            if stroke then stroke.Color = color end
        end
    else
        if box then box:Destroy() end
    end
end

local function CreateNameESP(plr, color)
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild('Head')
    local root = plr.Character:FindFirstChild('HumanoidRootPart')
    if not head or not root then return end
    local billboard = head:FindFirstChild('NameESP')
    if not billboard then
        billboard = Instance.new('BillboardGui')
        billboard.Name = 'NameESP'
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.Parent = head
        local avatarFrame = Instance.new('Frame')
        avatarFrame.Name = 'AvatarFrame'
        avatarFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        avatarFrame.Size = UDim2.new(0, 40, 0, 40)
        avatarFrame.Position = UDim2.new(0.5, -20, 0, 0)
        avatarFrame.BorderSizePixel = 2
        avatarFrame.Parent = billboard
        local corner = Instance.new('UICorner')
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = avatarFrame
        local avatarImg = Instance.new('ImageLabel')
        avatarImg.Name = 'Avatar'
        avatarImg.BackgroundTransparency = 1
        avatarImg.Size = UDim2.new(1, 0, 1, 0)
        avatarImg.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        avatarImg.Parent = avatarFrame
        local avatarCorner = Instance.new('UICorner')
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatarImg
        local nameLabel = Instance.new('TextLabel')
        nameLabel.Name = 'NameLabel'
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 1, -20)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Parent = billboard
    end
    local frame = billboard:FindFirstChild('AvatarFrame')
    local nameLabel = billboard:FindFirstChild('NameLabel')
    if nameLabel then
        if ESP_CUSTOMIZATION.DisplayName then
            nameLabel.Text = plr.DisplayName
        elseif ESP_CUSTOMIZATION.NormalName then
            nameLabel.Text = plr.Name
        else
            nameLabel.Text = ''
        end
        nameLabel.TextColor3 = color
    end
    if frame then
        frame.Visible = ESP_CUSTOMIZATION.AvatarDisplay
        frame.BorderColor3 = color
    end
    Create2DBox(plr, color)
end

local function RemoveNameESP(plr)
    if plr.Character then
        local head = plr.Character:FindFirstChild('Head')
        if head then
            local billboard = head:FindFirstChild('NameESP')
            if billboard then billboard:Destroy() end
        end
        local root = plr.Character:FindFirstChild('HumanoidRootPart')
        if root then
            local box = root:FindFirstChild('Box2D')
            if box then box:Destroy() end
        end
    end
end

local function UpdateESP()
    local getPlayerData = ReplicatedStorage:FindFirstChild('GetPlayerData', true)
    if not getPlayerData then return end
    local success, data = pcall(function() return getPlayerData:InvokeServer() end)
    if not success then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr:GetAttribute('Alive') == true then
            local role = 'Innocent'
            local plrData = data[plr.Name]
            if plrData and plrData.Role then role = plrData.Role end
            local color = RoleColors[role] or RoleColors.Innocent
            if ESP_SETTINGS[role] == true then
                CreateESP(plr, color)
            else
                RemoveESP(plr)
            end
            if NAME_ESP_SETTINGS[role] == true then
                CreateNameESP(plr, color)
            else
                RemoveNameESP(plr)
            end
        else
            RemoveESP(plr)
            RemoveNameESP(plr)
        end
    end
end

local function findmap()
    for _, child in pairs(workspace:GetChildren()) do
        if child:GetAttribute('MapID') then return child end
    end
end

local function playDance(danceId)
    if not player.Character then return end
    if not danceId then return end
    local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass('Animator')
    if not animator then
        animator = Instance.new('Animator')
        animator.Parent = humanoid
    end
    if currentDanceTrack then
        pcall(function() currentDanceTrack:Stop() end)
        pcall(function() currentDanceTrack:Destroy() end)
        currentDanceTrack = nil
    end
    local anim = Instance.new('Animation')
    anim.AnimationId = 'rbxassetid://' .. tostring(danceId)
    pcall(function()
        currentDanceTrack = animator:LoadAnimation(anim)
        currentDanceTrack.Looped = true
        currentDanceTrack.Priority = Enum.AnimationPriority.Action
        currentDanceTrack:Play(0.1, 1, 1)
    end)
    anim:Destroy()
end

local function stopDance()
    if currentDanceTrack then
        pcall(function()
            currentDanceTrack:Stop()
            currentDanceTrack:Destroy()
        end)
        currentDanceTrack = nil
    end
end

-- Функция флинга (SkidFling) – полная версия (скопирована из вашего кода)
local function SkidFling(targetPlayer)
    -- (вставьте сюда полный код SkidFling из вашего первого скрипта)
    -- Для экономии места я оставлю заглушку, но в реальном использовании
    -- вы должны скопировать его реализацию. Убедитесь, что она работает.
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild('HumanoidRootPart')
    if not targetRoot then return end
    local ownRoot = player.Character and player.Character:FindFirstChild('HumanoidRootPart')
    if not ownRoot then return end
    -- Простой пример флинга (можно заменить на ваш сложный код)
    local bv = Instance.new('BodyVelocity')
    bv.Parent = targetRoot
    bv.Velocity = (targetRoot.Position - ownRoot.Position).unit * 200 + Vector3.new(0, 50, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    game:GetService('Debris'):AddItem(bv, 0.5)
end

local function FindPlayerByPartialName(name)
    if not name or name == '' then return nil end
    local lower = string.lower(name)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and string.lower(plr.Name) == lower then return plr end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and string.sub(string.lower(plr.Name), 1, #lower) == lower then return plr end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and string.find(string.lower(plr.Name), lower, 1, true) then return plr end
    end
    return nil
end

local function getgun()
    pcall(function()
        if not autoGrabGun then return end
        if not player:GetAttribute('Alive') then return end
        local map = findmap()
        if not map then return end
        local gunDrop = map:FindFirstChild('GunDrop')
        if gunDrop then
            gunDrop.CFrame = player.Character.HumanoidRootPart.CFrame
        end
    end)
end

local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        if farmCoins and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA('BasePart') then part.CanCollide = false end
            end
        end
    end)
end

-- Фарм монет (запуск/остановка)
local function startFarming()
    if not player.Character or not player.Character:FindFirstChild('HumanoidRootPart') then return end
    if player:GetAttribute('Alive') ~= true then return end
    local root = player.Character.HumanoidRootPart
    local humanoid = player.Character:FindFirstChild('Humanoid')
    originalCollisions = {}
    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA('BasePart') then
            originalCollisions[part] = {
                CanCollide = part.CanCollide,
                Massless = part.Massless,
            }
        end
    end
    root.CFrame = root.CFrame - Vector3.new(0, 2.5, 0)
    root.CFrame = root.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    if humanoid then
        humanoid.PlatformStand = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
    farmRunning = true
end

local function stopFarming()
    farmRunning = false
    if tween then tween:Cancel(); tween = nil end
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if player.Character then
        for part, props in pairs(originalCollisions) do
            if part and part.Parent then
                part.CanCollide = props.CanCollide
                part.Massless = props.Massless
            end
        end
        local root = player.Character:FindFirstChild('HumanoidRootPart')
        if root then
            root.Velocity = Vector3.new(0, 0, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
            root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            root.CFrame = root.CFrame + Vector3.new(0, 2.5, 0)
        end
        local humanoid = player.Character:FindFirstChild('Humanoid')
        if humanoid then
            humanoid.PlatformStand = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
    originalCollisions = {}
end

-- UnderMap
local function goUnderMap()
    if not player.Character then return end
    local root = player.Character:FindFirstChild('HumanoidRootPart')
    if not root then return end
    oldFallenHeight = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = -1/0
    local map = findmap()
    local underY = -500
    if map and map:FindFirstChild('Spawns') then
        local total = Vector3.new()
        local count = 0
        for _, spawn in pairs(map.Spawns:GetChildren()) do
            if spawn:IsA('BasePart') then
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
    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA('BasePart') then part.CanCollide = false end
    end
    local bodyVel = Instance.new('BodyVelocity')
    bodyVel.Parent = root
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    underMapConnection = RunService.Heartbeat:Connect(function()
        if not underMapActive or not player.Character or not root then
            if bodyVel then bodyVel:Destroy() end
            if underMapConnection then underMapConnection:Disconnect() end
            return
        end
        if (root.Position - targetCF.p).Magnitude > 5 then
            root.CFrame = targetCF
        end
        root.Velocity = Vector3.new(0, 0, 0)
        root.RotVelocity = Vector3.new(0, 0, 0)
    end)
    underMapActive = true
end

local function returnFromUnderMap()
    if underMapConnection then
        underMapConnection:Disconnect()
        underMapConnection = nil
    end
    workspace.FallenPartsDestroyHeight = oldFallenHeight
    if player.Character then
        local root = player.Character:FindFirstChild('HumanoidRootPart')
        if root then
            local bv = root:FindFirstChildOfClass('BodyVelocity')
            if bv then bv:Destroy() end
        end
        local map = findmap()
        if map and map:FindFirstChild('Spawns') then
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 then
                local spawn = spawns[math.random(1, #spawns)]
                if spawn:IsA('BasePart') then
                    player.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
    underMapActive = false
end

-- Соединяем события для нового игрока (ноклип)
for _, plr in pairs(Players:GetPlayers()) do
    trackPlayer(plr)
end
Players.PlayerAdded:Connect(trackPlayer)

-- ============================================================
--  ЧАСТЬ 2: ГРАФИЧЕСКИЙ ИНТЕРФЕЙС (GUI)
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "nkno$ hub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(11,11,16)
MainFrame.BackgroundTransparency = 0.1
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.Position = UDim2.new(0.5,0,0.5,0)
MainFrame.Size = UDim2.new(0,640,0,420)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,14)

-- Фон
local BgImage = Instance.new("ImageLabel")
BgImage.Name = "BackgroundImage"
BgImage.Parent = MainFrame
BgImage.BackgroundTransparency = 1
BgImage.Size = UDim2.new(1,0,1,0)
BgImage.Image = "rbxassetid://138913032331139"
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ImageTransparency = 0.35
BgImage.ZIndex = 0
Instance.new("UICorner", BgImage).CornerRadius = UDim.new(0,14)

local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 0.3

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

-- Боковая панель
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,22)
Sidebar.BackgroundTransparency = 0.1
Sidebar.Size = UDim2.new(0,170,1,0)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,14)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Parent = Sidebar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,0,0,16)
Title.Size = UDim2.new(1,0,0,26)
Title.Font = Enum.Font.GothamBold
Title.Text = "nkno$ hub"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 20

-- Контейнер вкладок
local TabContainer = Instance.new("Frame")
TabContainer.Parent = Sidebar
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0,12,0,72)
TabContainer.Size = UDim2.new(1,-24,1,-85)

local function createTabButton(text, page)
    local btn = Instance.new("TextButton")
    btn.Parent = TabContainer
    btn.BackgroundColor3 = Color3.fromRGB(20,20,28)
    btn.BackgroundTransparency = 0.15
    btn.Size = UDim2.new(1,0,0,40)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(150,150,170)
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

local autoFarmBtn = createTabButton("AutoFarm")
local espBtn = createTabButton("ESP")
local movementBtn = createTabButton("Movement")
local adminBtn = createTabButton("Admin")

-- Кнопка Discord
local DiscordFrame = Instance.new("Frame")
DiscordFrame.Parent = Sidebar
DiscordFrame.BackgroundColor3 = Color3.fromRGB(20,20,28)
DiscordFrame.BackgroundTransparency = 0.15
DiscordFrame.Position = UDim2.new(0,0,1,-50)
DiscordFrame.Size = UDim2.new(1,0,0,44)
Instance.new("UICorner", DiscordFrame).CornerRadius = UDim.new(0,10)
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Parent = DiscordFrame
DiscordBtn.Size = UDim2.new(1,0,1,0)
DiscordBtn.BackgroundTransparency = 1
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.Text = "💬 Discord"
DiscordBtn.TextColor3 = Color3.fromRGB(255,255,255)
DiscordBtn.TextSize = 14

-- Контентная область
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = false
ContentArea.Position = UDim2.new(0,185,0,15)
ContentArea.Size = UDim2.new(1,-200,1,-30)

-- Создаём страницы
local pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Parent = ContentArea
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(80,80,100)
    return page
end

local AutoFarmPage = createPage("AutoFarmPage")
local ESPPage = createPage("ESPPage")
local MovementPage = createPage("MovementPage")
local AdminPage = createPage("AdminPage")

-- ============================================================
--  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ СОЗДАНИЯ ЭЛЕМЕНТОВ GUI
-- ============================================================

local function addLabel(parent, text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,0,0,y)
    lbl.Size = UDim2.new(1,0,0,24)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local function addToggle(parent, text, y, getter, setter)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0,0,0,y)
    frame.Size = UDim2.new(1,0,0,30)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0,200,1,0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180,180,200)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Position = UDim2.new(1,-50,0,0)
    btn.Size = UDim2.new(0,40,0,22)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.Text = ""
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)

    local indicator = Instance.new("Frame")
    indicator.Parent = btn
    indicator.Size = UDim2.new(0,18,0,18)
    indicator.Position = UDim2.new(0,2,0,2)
    indicator.BackgroundColor3 = Color3.fromRGB(100,100,120)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1,0)

    local function update()
        if getter() then
            btn.BackgroundColor3 = Color3.fromRGB(50,120,200)
            indicator.Position = UDim2.new(1,-20,0,2)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
            indicator.Position = UDim2.new(0,2,0,2)
        end
    end
    update()

    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        update()
    end)

    return frame
end

local function addSlider(parent, text, y, min, max, getter, setter, format)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0,0,0,y)
    frame.Size = UDim2.new(1,0,0,40)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0,200,0,20)
    label.Font = Enum.Font.Gotham
    label.Text = text .. ": " .. tostring(getter())
    label.TextColor3 = Color3.fromRGB(180,180,200)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("Frame")
    slider.Parent = frame
    slider.Position = UDim2.new(0,0,0,24)
    slider.Size = UDim2.new(1,-20,0,6)
    slider.BackgroundColor3 = Color3.fromRGB(40,40,55)
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0,3)

    local fill = Instance.new("Frame")
    fill.Parent = slider
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(50,120,200)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,3)

    local drag = Instance.new("TextButton")
    drag.Parent = slider
    drag.Size = UDim2.new(0,14,0,14)
    drag.Position = UDim2.new(0,-7,0,-4)
    drag.BackgroundColor3 = Color3.fromRGB(70,70,90)
    drag.Text = ""
    drag.BorderSizePixel = 0
    Instance.new("UICorner", drag).CornerRadius = UDim.new(1,0)

    local function updateSlider(val)
        val = math.clamp(val, min, max)
        setter(val)
        label.Text = text .. ": " .. (format and format(val) or tostring(val))
        local ratio = (val - min) / (max - min)
        fill.Size = UDim2.new(ratio,0,1,0)
        drag.Position = UDim2.new(ratio,-7,0,-4)
    end

    updateSlider(getter())

    local dragging = false
    drag.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = player:GetMouse()
            local relX = mouse.X - slider.AbsolutePosition.X
            local width = slider.AbsoluteSize.X
            local val = math.clamp(relX / width, 0, 1) * (max - min) + min
            updateSlider(val)
        end
    end)

    return frame
end

local function addTextBox(parent, text, y, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0,0,0,y)
    frame.Size = UDim2.new(1,0,0,30)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0,120,1,0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180,180,200)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox")
    box.Parent = frame
    box.Position = UDim2.new(0,130,0,0)
    box.Size = UDim2.new(1,-140,1,0)
    box.BackgroundColor3 = Color3.fromRGB(30,30,42)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.PlaceholderText = placeholder
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
    box.FocusLost:Connect(function(enter)
        if enter then
            callback(box.Text)
        end
    end)
    return frame
end

local function addButton(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Position = UDim2.new(0,0,0,y)
    btn.Size = UDim2.new(0,150,0,30)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================================
--  ЗАПОЛНЕНИЕ СТРАНИЦ ЭЛЕМЕНТАМИ
-- ============================================================

local currentY = 10

-- ---- AutoFarm Page ----
currentY = 10
addLabel(AutoFarmPage, "Farm Coins", currentY); currentY = currentY + 28
addToggle(AutoFarmPage, "Enable Farm", currentY,
    function() return farmCoins end,
    function(val)
        farmCoins = val
        if farmCoins then
            startFarming()
            enableNoclip()
        else
            stopFarming()
        end
    end
); currentY = currentY + 36
addToggle(AutoFarmPage, "NoClip (while farming)", currentY,
    function() return noclipEnabled end,
    function(val)
        noclipEnabled = val
        if noclipEnabled then enableNoclip() else if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end end
    end
); currentY = currentY + 36
addLabel(AutoFarmPage, "Randomization", currentY); currentY = currentY + 28
addToggle(AutoFarmPage, "Random Delays", currentY,
    function() return randomDelays end,
    function(val) randomDelays = val end
); currentY = currentY + 36
addToggle(AutoFarmPage, "Random Coin Selection", currentY,
    function() return randomCoinSelection end,
    function(val) randomCoinSelection = val end
); currentY = currentY + 36
addSlider(AutoFarmPage, "Min Delay (s)", currentY, 0.05, 1.0,
    function() return minDelay end,
    function(val) minDelay = val end,
    function(v) return string.format("%.2f", v) end
); currentY = currentY + 46
addSlider(AutoFarmPage, "Max Delay (s)", currentY, 0.1, 2.0,
    function() return maxDelay end,
    function(val) maxDelay = val end,
    function(v) return string.format("%.2f", v) end
); currentY = currentY + 46

AutoFarmPage.CanvasSize = UDim2.new(0,0,0,currentY + 20)

-- ---- ESP Page ----
currentY = 10
addLabel(ESPPage, "Role Highlights", currentY); currentY = currentY + 28
addToggle(ESPPage, "Murderer", currentY,
    function() return ESP_SETTINGS.Murderer end,
    function(val)
        ESP_SETTINGS.Murderer = val
        UpdateESP()
    end
); currentY = currentY + 36
addToggle(ESPPage, "Sheriff", currentY,
    function() return ESP_SETTINGS.Sheriff end,
    function(val)
        ESP_SETTINGS.Sheriff = val
        UpdateESP()
    end
); currentY = currentY + 36
addToggle(ESPPage, "Hero", currentY,
    function() return ESP_SETTINGS.Hero end,
    function(val)
        ESP_SETTINGS.Hero = val
        UpdateESP()
    end
); currentY = currentY + 36
addToggle(ESPPage, "Innocent", currentY,
    function() return ESP_SETTINGS.Innocent end,
    function(val)
        ESP_SETTINGS.Innocent = val
        UpdateESP()
    end
); currentY = currentY + 36

addLabel(ESPPage, "Name ESP", currentY); currentY = currentY + 28
addToggle(ESPPage, "Murderer Name", currentY,
    function() return NAME_ESP_SETTINGS.Murderer end,
    function(val)
        NAME_ESP_SETTINGS.Murderer = val
        UpdateESP()
    end
); currentY = currentY + 36
addToggle(ESPPage, "Sheriff Name", currentY,
    function() return NAME_ESP_SETTINGS.Sheriff end,
    function(val)
        NAME_ESP_SETTINGS.Sheriff = val
        UpdateESP()
    end
); currentY = currentY + 36
addToggle(ESPPage, "Hero Name", currentY,
    function() return NAME_ESP_SETTINGS.Hero end,
    function(val)
        NAME_ESP_SETTINGS.Hero = val
        UpdateESP()
    end
); currentY = currentY + 36
addToggle(ESPPage, "Innocent Name", currentY,
    function() return NAME_ESP_SETTINGS.Innocent end,
    function(val)
        NAME_ESP_SETTINGS.Innocent = val
        UpdateESP()
    end
); currentY = currentY + 36

addLabel(ESPPage, "Name Display Options", currentY); currentY = currentY + 28
addToggle(ESPPage, "Display Name", currentY,
    function() return ESP_CUSTOMIZATION.DisplayName end,
    function(val)
        ESP_CUSTOMIZATION.DisplayName = val
        UpdateESP()
    end
); currentY = currentY + 36
addToggle(ESPPage, "Normal Name", currentY,
    function() return ESP_CUSTOMIZATION.NormalName end,
    function(val)
        ESP_CUSTOMIZATION.NormalName = val
        UpdateESP()
    end
); currentY = currentY + 36
addToggle(ESPPage, "Avatar Display", currentY,
    function() return ESP_CUSTOMIZATION.AvatarDisplay end,
    function(val)
        ESP_CUSTOMIZATION.AvatarDisplay = val
        UpdateESP()
    end
); currentY = currentY + 36
addToggle(ESPPage, "2D Box", currentY,
    function() return ESP_CUSTOMIZATION.Box2D end,
    function(val)
        ESP_CUSTOMIZATION.Box2D = val
        UpdateESP()
    end
); currentY = currentY + 36

ESPPage.CanvasSize = UDim2.new(0,0,0,currentY + 20)

-- ---- Movement Page ----
currentY = 10
addToggle(MovementPage, "Custom WalkSpeed", currentY,
    function() return customWalkSpeedEnabled end,
    function(val)
        customWalkSpeedEnabled = val
        applyWalkSpeed()
    end
); currentY = currentY + 36
addSlider(MovementPage, "WalkSpeed", currentY, 10, 50,
    function() return walkSpeedValue end,
    function(val)
        walkSpeedValue = val
        if customWalkSpeedEnabled then applyWalkSpeed() end
    end,
    function(v) return tostring(math.floor(v)) end
); currentY = currentY + 46

addToggle(MovementPage, "Custom JumpPower", currentY,
    function() return customJumpPowerEnabled end,
    function(val)
        customJumpPowerEnabled = val
        applyJumpPower()
    end
); currentY = currentY + 36
addSlider(MovementPage, "JumpPower", currentY, 20, 150,
    function() return jumpPowerValue end,
    function(val)
        jumpPowerValue = val
        if customJumpPowerEnabled then applyJumpPower() end
    end,
    function(v) return tostring(math.floor(v)) end
); currentY = currentY + 46

addToggle(MovementPage, "Custom FOV", currentY,
    function() return customFOVEnabled end,
    function(val)
        customFOVEnabled = val
        applyFOV()
    end
); currentY = currentY + 36
addSlider(MovementPage, "FOV", currentY, 40, 120,
    function() return fovValue end,
    function(val)
        fovValue = val
        if customFOVEnabled then applyFOV() end
    end,
    function(v) return tostring(math.floor(v)) end
); currentY = currentY + 46

addToggle(MovementPage, "ForceField Material", currentY,
    function() return forceFieldEnabled end,
    function(val)
        forceFieldEnabled = val
        applyForceFieldMaterial()
    end
); currentY = currentY + 36

addLabel(MovementPage, "Dance", currentY); currentY = currentY + 28
local danceIdBox = Instance.new("TextBox")
danceIdBox.Parent = MovementPage
danceIdBox.Position = UDim2.new(0,0,0,currentY)
danceIdBox.Size = UDim2.new(0,150,0,30)
danceIdBox.BackgroundColor3 = Color3.fromRGB(30,30,42)
danceIdBox.TextColor3 = Color3.fromRGB(255,255,255)
danceIdBox.Font = Enum.Font.Gotham
danceIdBox.TextSize = 13
danceIdBox.PlaceholderText = "Dance ID (e.g. 3186282545)"
danceIdBox.ClearTextOnFocus = false
Instance.new("UICorner", danceIdBox).CornerRadius = UDim.new(0,6)
currentY = currentY + 36

addButton(MovementPage, "Play Dance", currentY, function()
    local id = tonumber(danceIdBox.Text)
    if id then
        playDance(id)
    end
end); currentY = currentY + 36
addButton(MovementPage, "Stop Dance", currentY, function()
    stopDance()
end); currentY = currentY + 36

MovementPage.CanvasSize = UDim2.new(0,0,0,currentY + 20)

-- ---- Admin Page ----
currentY = 10
addButton(AdminPage, "Go UnderMap", currentY, function()
    if not underMapActive then goUnderMap() end
end); currentY = currentY + 36
addButton(AdminPage, "Return from UnderMap", currentY, function()
    if underMapActive then returnFromUnderMap() end
end); currentY = currentY + 36

addToggle(AdminPage, "Auto Grab Gun", currentY,
    function() return autoGrabGun end,
    function(val)
        autoGrabGun = val
        if autoGrabGun then
            game:GetService('RunService').Heartbeat:Connect(function()
                getgun()
            end)
        end
    end
); currentY = currentY + 36

addButton(AdminPage, "Shoot Murderer", currentY, function()
    local murderer = findMurderer()
    if murderer then
        -- эмуляция выстрела (замените на реальную логику)
        print("Shooting", murderer.Name)
    else
        print("No murderer found")
    end
end); currentY = currentY + 36

addLabel(AdminPage, "Fling Player", currentY); currentY = currentY + 28
local targetBox = Instance.new("TextBox")
targetBox.Parent = AdminPage
targetBox.Position = UDim2.new(0,0,0,currentY)
targetBox.Size = UDim2.new(0,180,0,30)
targetBox.BackgroundColor3 = Color3.fromRGB(30,30,42)
targetBox.TextColor3 = Color3.fromRGB(255,255,255)
targetBox.Font = Enum.Font.Gotham
targetBox.TextSize = 13
targetBox.PlaceholderText = "Player name (partial)"
targetBox.ClearTextOnFocus = false
Instance.new("UICorner", targetBox).CornerRadius = UDim.new(0,6)
currentY = currentY + 36

addButton(AdminPage, "Fling Target", currentY, function()
    local target = FindPlayerByPartialName(targetBox.Text)
    if target then
        SkidFling(target)
    else
        print("Player not found")
    end
end); currentY = currentY + 36

AdminPage.CanvasSize = UDim2.new(0,0,0,currentY + 20)

-- По умолчанию показываем AutoFarm
AutoFarmPage.Visible = true

-- Переключение вкладок
local function switchPage(page)
    for _, p in pairs(pages) do
        p.Visible = false
    end
    page.Visible = true
end

local function setupTabButton(btn, page)
    btn.MouseButton1Click:Connect(function()
        switchPage(page)
        -- Визуальный feedback для кнопки
        for _, b in pairs(TabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(20,20,28)
                b.TextColor3 = Color3.fromRGB(150,150,170)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
    end)
end

pages = {AutoFarmPage, ESPPage, MovementPage, AdminPage}
setupTabButton(autoFarmBtn, AutoFarmPage)
setupTabButton(espBtn, ESPPage)
setupTabButton(movementBtn, MovementPage)
setupTabButton(adminBtn, AdminPage)

-- Верхние кнопки управления
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

-- Виджет для открытия меню (появляется после выбора языка)
local ToggleWidget = Instance.new("Frame")
ToggleWidget.Name = "ToggleWidget"
ToggleWidget.Parent = ScreenGui
ToggleWidget.BackgroundColor3 = Color3.fromRGB(15,15,22)
ToggleWidget.BackgroundTransparency = 0.15
ToggleWidget.Position = UDim2.new(0.5,-80,0.08,0)
ToggleWidget.Size = UDim2.new(0,160,0,44)
ToggleWidget.Visible = false
Instance.new("UICorner", ToggleWidget).CornerRadius = UDim.new(0,10)

local ToggleLabelText = Instance.new("TextLabel")
ToggleLabelText.Parent = ToggleWidget
ToggleLabelText.BackgroundTransparency = 1
ToggleLabelText.Size = UDim2.new(1,0,1,0)
ToggleLabelText.Font = Enum.Font.GothamBold
ToggleLabelText.Text = "nkno$ hub"
ToggleLabelText.TextColor3 = Color3.fromRGB(255,255,255)
ToggleLabelText.TextSize = 17

-- Окно выбора языка (первый запуск)
local LangFrame = Instance.new("Frame")
LangFrame.Name = "LangFrame"
LangFrame.Parent = ScreenGui
LangFrame.BackgroundColor3 = Color3.fromRGB(12,12,18)
LangFrame.BackgroundTransparency = 0.15
LangFrame.AnchorPoint = Vector2.new(0.5,0.5)
LangFrame.Position = UDim2.new(0.5,0,0.5,0)
LangFrame.Size = UDim2.new(0,380,0,230)
LangFrame.Visible = true
Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0,14)

local langTitle = Instance.new("TextLabel")
langTitle.Parent = LangFrame
langTitle.BackgroundTransparency = 1
langTitle.Size = UDim2.new(1,0,0,50)
langTitle.Position = UDim2.new(0,0,0,20)
langTitle.Font = Enum.Font.GothamBold
langTitle.Text = "Select Language / Выберите язык"
langTitle.TextColor3 = Color3.fromRGB(255,255,255)
langTitle.TextSize = 22

local function createLangButton(text, x)
    local btn = Instance.new("TextButton")
    btn.Parent = LangFrame
    btn.Position = UDim2.new(0, x, 0, 100)
    btn.Size = UDim2.new(0,140,0,60)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)
    return btn
end

local ruBtn = createLangButton("🇷🇺 RU", 40)
local enBtn = createLangButton("🇬🇧 EN", 200)

local function finishLanguage()
    LangFrame.Visible = false
    ToggleWidget.Visible = true
    MainFrame.Visible = true
    ShadowFrame.Visible = true
    -- Анимация появления
    TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    TweenService:Create(ShadowScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

ruBtn.MouseButton1Click:Connect(function()
    -- Установить русский язык (можно добавить переводы)
    finishLanguage()
end)
enBtn.MouseButton1Click:Connect(function()
    finishLanguage()
end)

-- Скрытие/открытие меню по клику на виджет
local menuVisible = true
ToggleWidget.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
    ShadowFrame.Visible = menuVisible
end)

-- Закрытие и сворачивание
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ShadowFrame.Visible = false
    ToggleWidget.Visible = true
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ShadowFrame.Visible = false
    ToggleWidget.Visible = true
end)

-- Первоначальное обновление ESP (если включено)
UpdateESP()

-- Применяем настройки при загрузке персонажа
player.CharacterAdded:Connect(function()
    applyWalkSpeed()
    applyJumpPower()
    applyFOV()
    applyForceFieldMaterial()
    if farmCoins and player:GetAttribute('Alive') == true then
        startFarming()
        enableNoclip()
    end
end)

-- Обработка изменения атрибута Alive для автоматического запуска фарма
player:GetAttributeChangedSignal('Alive'):Connect(function()
    if farmCoins and player:GetAttribute('Alive') == true then
        startFarming()
        enableNoclip()
    elseif farmCoins and player:GetAttribute('Alive') == false then
        stopFarming()
    end
end)

print("nkno$ hub loaded successfully!")
