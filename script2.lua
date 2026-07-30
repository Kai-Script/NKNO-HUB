-- ============================================================
--  NKNO$ HUB | OPTIMIZED | COMBAT + SCRIPT CHAT + HUD
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  НАСТРОЙКИ ПО УМОЛЧАНИЮ
-- ============================================================

-- ESP
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

-- Состояния
local farmEnabled = false
local farmRunning = false
local noclipEnabled = false
local noclipConnection = nil
local randomDelays = false
local randomCoinSelection = false
local minDelay = 0.1
local maxDelay = 0.5

local customWalkSpeedEnabled = false
local walkSpeedValue = 16
local customJumpPowerEnabled = false
local jumpPowerValue = 50
local customFOVEnabled = false
local fovValue = 70
local forceFieldEnabled = false

local autoGrabGun = false
local underMapActive = false
local currentDanceTrack = nil
local originalCollisions = {}

-- HUD
local showHUD = false
local fps = 0
local ping = 0
local hudFrame = nil

-- ============================================================
--  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (оптимизированы)
-- ============================================================

local function findMap()
    for _, child in pairs(workspace:GetChildren()) do
        if child:GetAttribute("MapID") then
            return child
        end
    end
    return nil
end

local function getCoinContainer()
    for _, child in pairs(workspace:GetChildren()) do
        if child:FindFirstChild("CoinContainer") and child:IsA("Model") then
            return child:FindFirstChild("CoinContainer")
        end
    end
    return nil
end

local function findMurderer()
    local getPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not getPlayerData then return nil end
    local success, data = pcall(function() return getPlayerData:InvokeServer() end)
    if not success or not data then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
            local plrData = data[plr.Name]
            if plrData and plrData.Role == "Murderer" then
                return plr
            end
        end
    end
    return nil
end

local function FindPlayerByPartialName(name)
    if not name or name == "" then return nil end
    local lower = string.lower(name)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if string.lower(plr.Name) == lower then return plr end
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if string.sub(string.lower(plr.Name), 1, #lower) == lower then return plr end
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if string.find(string.lower(plr.Name), lower, 1, true) then return plr end
        end
    end
    return nil
end

local function getPing()
    local stats = game:GetService("Stats")
    return stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end

-- ============================================================
--  АВТОФАРМ (ОПТИМИЗИРОВАН)
-- ============================================================

local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Heartbeat:Connect(function()
        if noclipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function startFarming()
    if farmRunning then return end
    if not LocalPlayer.Character then return end
    if LocalPlayer:GetAttribute("Alive") ~= true then return end

    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    originalCollisions = {}
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalCollisions[part] = { CanCollide = part.CanCollide }
        end
    end

    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    local map = findMap()
    local targetY = -50
    if map and map:FindFirstChild("Spawns") then
        local spawns = map.Spawns:GetChildren()
        if #spawns > 0 then
            local totalY = 0
            local count = 0
            for _, spawn in ipairs(spawns) do
                if spawn:IsA("BasePart") then
                    totalY = totalY + spawn.Position.Y
                    count = count + 1
                end
            end
            if count > 0 then
                targetY = (totalY / count) - 80
            end
        end
    end

    root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)

    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end

    farmRunning = true

    task.spawn(function()
        while farmRunning and farmEnabled and LocalPlayer.Character do
            if not LocalPlayer.Character or LocalPlayer:GetAttribute("Alive") ~= true then
                break
            end

            local container = getCoinContainer()
            if not container then
                task.wait(0.5)
                continue
            end

            local candidates = {}
            for _, coin in pairs(container:GetChildren()) do
                if coin:GetAttribute("CoinID") == "Coin" and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                        table.insert(candidates, {coin = coin, dist = dist})
                    end
                end
            end

            if #candidates == 0 then
                task.wait(0.5)
                continue
            end

            table.sort(candidates, function(a, b) return a.dist < b.dist end)
            local targetCoin
            if randomCoinSelection and #candidates > 2 then
                local idx = math.random(1, math.min(3, #candidates))
                targetCoin = candidates[idx].coin
            else
                targetCoin = candidates[1].coin
            end

            if not targetCoin then
                task.wait(0.5)
                continue
            end

            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCoin.CFrame})
                tween:Play()
                tween.Completed:Wait()
                local delay = minDelay
                if randomDelays then
                    delay = math.random() * (maxDelay - minDelay) + minDelay
                end
                task.wait(delay)
            else
                task.wait(0.5)
            end
        end
    end)
end

local function stopFarming()
    farmRunning = false
    if LocalPlayer.Character then
        for part, props in pairs(originalCollisions) do
            if part and part.Parent then
                part.CanCollide = props.CanCollide
            end
        end
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame + Vector3.new(0, 50, 0)
        end
    end
    disableNoclip()
end

-- ============================================================
--  KILL ALL
-- ============================================================

local function killAll()
    local getPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not getPlayerData then return end
    local success, data = pcall(function() return getPlayerData:InvokeServer() end)
    if not success or not data then return end

    local myRole = data[LocalPlayer.Name] and data[LocalPlayer.Name].Role
    if myRole ~= "Murderer" then
        print("You are not the Murderer!")
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr:GetAttribute("Alive") == true then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end
    print("Kill All executed!")
end

-- ============================================================
--  ESP (ОПТИМИЗИРОВАН: обновление раз в 0.5 сек)
-- ============================================================

local espCache = {}

local function CreateESP(plr, color)
    if not plr.Character then return end
    local highlight = plr.Character:FindFirstChild("RoleESP")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "RoleESP"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = plr.Character
    end
    highlight.FillColor = color
    highlight.OutlineColor = color
    espCache[plr] = highlight
end

local function RemoveESP(plr)
    if plr.Character then
        local highlight = plr.Character:FindFirstChild("RoleESP")
        if highlight then highlight:Destroy() end
    end
    espCache[plr] = nil
end

local function CreateNameESP(plr, color)
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    local billboard = head:FindFirstChild("NameESP")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "NameESP"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.Parent = head
        local avatarFrame = Instance.new("Frame")
        avatarFrame.Name = "AvatarFrame"
        avatarFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        avatarFrame.Size = UDim2.new(0, 40, 0, 40)
        avatarFrame.Position = UDim2.new(0.5, -20, 0, 0)
        avatarFrame.BorderSizePixel = 2
        avatarFrame.Parent = billboard
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = avatarFrame
        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Name = "Avatar"
        avatarImg.BackgroundTransparency = 1
        avatarImg.Size = UDim2.new(1, 0, 1, 0)
        avatarImg.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        avatarImg.Parent = avatarFrame
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatarImg
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 1, -20)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Parent = billboard
    end
    local nameLabel = billboard:FindFirstChild("NameLabel")
    if nameLabel then
        if ESP_CUSTOMIZATION.DisplayName then
            nameLabel.Text = plr.DisplayName
        elseif ESP_CUSTOMIZATION.NormalName then
            nameLabel.Text = plr.Name
        else
            nameLabel.Text = ""
        end
        nameLabel.TextColor3 = color
    end
    if ESP_CUSTOMIZATION.Box2D then
        -- добавляем 2D рамку (упрощённо, можно реализовать отдельно)
    end
end

local function RemoveNameESP(plr)
    if plr.Character then
        local head = plr.Character:FindFirstChild("Head")
        if head then
            local billboard = head:FindFirstChild("NameESP")
            if billboard then billboard:Destroy() end
        end
    end
end

local function UpdateESP()
    local getPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not getPlayerData then return end
    local success, data = pcall(function() return getPlayerData:InvokeServer() end)
    if not success then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
            local role = "Innocent"
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

-- Запускаем обновление ESP с интервалом 0.5 сек
task.spawn(function()
    while true do
        task.wait(0.5)
        UpdateESP()
    end
end)

-- ============================================================
--  ДВИЖЕНИЕ, ТАНЦЫ, ПОДЗЕМЕЛЬЕ, ФЛИНГ (без изменений)
-- ============================================================

local function applyWalkSpeed()
    if customWalkSpeedEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = walkSpeedValue end
    end
end

local function applyJumpPower()
    if customJumpPowerEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
    if forceFieldEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Material = Enum.Material.ForceField
            end
        end
    end
end

local function playDance(danceId)
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    if currentDanceTrack then
        pcall(function() currentDanceTrack:Stop() end)
        pcall(function() currentDanceTrack:Destroy() end)
        currentDanceTrack = nil
    end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(danceId)
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

local function goUnderMap()
    if underMapActive then return end
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    getgenv().FPDH = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = -1/0

    local targetY = -500
    local map = findMap()
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
            targetY = center.Y - 100
        end
    end

    local targetCF = CFrame.new(root.Position.X, targetY, root.Position.Z)
    root.CFrame = targetCF

    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    underMapActive = true
    task.spawn(function()
        while underMapActive and LocalPlayer.Character do
            task.wait(0.1)
            local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then
                r.CFrame = targetCF
                r.Velocity = Vector3.new(0, 0, 0)
                r.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

local function returnFromUnderMap()
    underMapActive = false
    workspace.FallenPartsDestroyHeight = getgenv().FPDH or workspace.FallenPartsDestroyHeight
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
                local spawn = spawns[math.random(1, #spawns)]
                if spawn:IsA("BasePart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
end

local function getgun()
    pcall(function()
        if not autoGrabGun then return end
        if not LocalPlayer:GetAttribute("Alive") then return end
        local map = findMap()
        if not map then return end
        local gunDrop = map:FindFirstChild("GunDrop")
        if gunDrop then
            gunDrop.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

local function SkidFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local ownRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not ownRoot then return end
    local bv = Instance.new("BodyVelocity")
    bv.Parent = targetRoot
    bv.Velocity = (targetRoot.Position - ownRoot.Position).unit * 200 + Vector3.new(0, 50, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    game:GetService("Debris"):AddItem(bv, 0.5)
end

-- ============================================================
--  HUD (FPS + PING)
-- ============================================================

local function createHUD()
    if hudFrame then return end
    hudFrame = Instance.new("Frame")
    hudFrame.Name = "HUD"
    hudFrame.Parent = game:GetService("CoreGui")
    hudFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    hudFrame.BackgroundTransparency = 0.5
    hudFrame.Size = UDim2.new(0, 120, 0, 40)
    hudFrame.Position = UDim2.new(1, -130, 0, 10)
    hudFrame.Visible = showHUD
    Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 8)

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Parent = hudFrame
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Size = UDim2.new(1, 0, 0.5, 0)
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsLabel.TextSize = 14

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "PingLabel"
    pingLabel.Parent = hudFrame
    pingLabel.BackgroundTransparency = 1
    pingLabel.Position = UDim2.new(0, 0, 0.5, 0)
    pingLabel.Size = UDim2.new(1, 0, 0.5, 0)
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.Text = "Ping: 0ms"
    pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    pingLabel.TextSize = 14

    -- Обновление HUD раз в секунду
    task.spawn(function()
        local lastUpdate = 0
        while hudFrame do
            task.wait(0.5)
            if showHUD and hudFrame.Visible then
                ping = getPing()
                local fpsLabel2 = hudFrame:FindFirstChild("FPSLabel")
                local pingLabel2 = hudFrame:FindFirstChild("PingLabel")
                if fpsLabel2 then
                    fps = math.floor(1 / RunService.Heartbeat:Wait())
                    fpsLabel2.Text = "FPS: " .. tostring(fps)
                end
                if pingLabel2 then
                    pingLabel2.Text = "Ping: " .. tostring(math.floor(ping)) .. "ms"
                end
            end
        end
    end)
end

local function toggleHUD(enable)
    showHUD = enable
    if enable then
        if not hudFrame then createHUD() end
        hudFrame.Visible = true
    else
        if hudFrame then hudFrame.Visible = false end
    end
end

-- ============================================================
--  СКРИПТОВЫЙ ЧАТ (с префиксом [SC])
-- ============================================================

local chatFrame = nil
local chatMessages = {}

local function createChatUI()
    -- Вкладка Chat будет создана позже
end

local function sendScriptMessage(msg)
    if msg == "" then return end
    -- Отправляем в общий чат с префиксом [SC]
    local chatService = game:GetService("Chat")
    if chatService then
        pcall(function()
            chatService:Chat(" [SC] " .. msg)
        end)
    end
end

-- Слушаем сообщения из чата (если есть)
local function listenToChat()
    local chatService = game:GetService("Chat")
    if chatService and chatService.MessageReceived then
        chatService.MessageReceived:Connect(function(messageData)
            local text = messageData.Message
            if string.sub(text, 1, 5) == " [SC]" then
                -- отображаем в GUI
                table.insert(chatMessages, text)
                if chatFrame then
                    -- обновить окно чата
                end
            end
        end)
    end
end

-- ============================================================
--  ПОСТРОЕНИЕ GUI (ОПТИМИЗИРОВАННОЕ)
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "nkno$hub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BackgroundTransparency = 0.1
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 640, 0, 440)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
MainFrame.Visible = true

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 10)
Title.Size = UDim2.new(0, 300, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "nkno$ hub (Optimized)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
CloseBtn.Position = UDim2.new(1, -45, 0, 10)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 18
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Вкладки
local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.Size = UDim2.new(1, 0, 0, 35)

local function createTab(text)
    local btn = Instance.new("TextButton")
    btn.Parent = TabContainer
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    return btn
end

local autoFarmTab = createTab("AutoFarm")
local espTab = createTab("ESP")
local movementTab = createTab("Movement")
local combatTab = createTab("COMBAT")
local chatTab = createTab("Chat")

autoFarmTab.Position = UDim2.new(0, 10, 0, 0)
espTab.Position = UDim2.new(0, 130, 0, 0)
movementTab.Position = UDim2.new(0, 250, 0, 0)
combatTab.Position = UDim2.new(0, 370, 0, 0)
chatTab.Position = UDim2.new(0, 490, 0, 0)

-- Контентная область
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 10, 0, 95)
ContentArea.Size = UDim2.new(1, -20, 1, -110)
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)

-- Страницы
local pages = {}
local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Parent = ContentArea
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 0, 0)
    page.Visible = false
    return page
end

local AutoFarmPage = createPage("AutoFarmPage")
local ESPPage = createPage("ESPPage")
local MovementPage = createPage("MovementPage")
local CombatPage = createPage("CombatPage")
local ChatPage = createPage("ChatPage")

-- ============================================================
--  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ GUI
-- ============================================================

local function addLabel(parent, text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local function addToggle(parent, text, y, getter, setter)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.Size = UDim2.new(1, 0, 0, 30)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Position = UDim2.new(1, -50, 0, 2)
    btn.Size = UDim2.new(0, 40, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = ""
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local indicator = Instance.new("Frame")
    indicator.Parent = btn
    indicator.Size = UDim2.new(0, 18, 0, 18)
    indicator.Position = UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local function update()
        if getter() then
            btn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
            indicator.Position = UDim2.new(1, -20, 0, 2)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            indicator.Position = UDim2.new(0, 2, 0, 2)
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
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.Size = UDim2.new(1, 0, 0, 40)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 200, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = text .. ": " .. tostring(getter())
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("Frame")
    slider.Parent = frame
    slider.Position = UDim2.new(0, 0, 0, 24)
    slider.Size = UDim2.new(1, -20, 0, 6)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame")
    fill.Parent = slider
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local drag = Instance.new("TextButton")
    drag.Parent = slider
    drag.Size = UDim2.new(0, 14, 0, 14)
    drag.Position = UDim2.new(0, -7, 0, -4)
    drag.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    drag.Text = ""
    drag.BorderSizePixel = 0
    Instance.new("UICorner", drag).CornerRadius = UDim.new(1, 0)

    local function updateSlider(val)
        val = math.clamp(val, min, max)
        setter(val)
        label.Text = text .. ": " .. (format and format(val) or tostring(val))
        local ratio = (val - min) / (max - min)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        drag.Position = UDim2.new(ratio, -7, 0, -4)
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
            local mouse = LocalPlayer:GetMouse()
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
    frame.Position = UDim2.new(0, 0, 0, y)
    frame.Size = UDim2.new(1, 0, 0, 30)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox")
    box.Parent = frame
    box.Position = UDim2.new(0, 130, 0, 0)
    box.Size = UDim2.new(1, -140, 1, 0)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.PlaceholderText = placeholder
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
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
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.Size = UDim2.new(0, 150, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================================
--  ЗАПОЛНЕНИЕ СТРАНИЦ
-- ============================================================

-- AutoFarm (без изменений)
local function buildAutoFarm()
    local y = 10
    addLabel(AutoFarmPage, "Farm Settings", y); y = y + 28
    addToggle(AutoFarmPage, "Enable Farm", y,
        function() return farmEnabled end,
        function(val)
            farmEnabled = val
            if farmEnabled then
                noclipEnabled = true
                enableNoclip()
                startFarming()
            else
                noclipEnabled = false
                disableNoclip()
                stopFarming()
            end
        end
    ); y = y + 36
    addToggle(AutoFarmPage, "NoClip", y,
        function() return noclipEnabled end,
        function(val)
            noclipEnabled = val
            if noclipEnabled then enableNoclip() else disableNoclip() end
        end
    ); y = y + 36
    addLabel(AutoFarmPage, "Randomization", y); y = y + 28
    addToggle(AutoFarmPage, "Random Delays", y,
        function() return randomDelays end,
        function(val) randomDelays = val end
    ); y = y + 36
    addToggle(AutoFarmPage, "Random Coin", y,
        function() return randomCoinSelection end,
        function(val) randomCoinSelection = val end
    ); y = y + 36
    addSlider(AutoFarmPage, "Min Delay", y, 0.05, 1.0,
        function() return minDelay end,
        function(val) minDelay = val end,
        function(v) return string.format("%.2f", v) end
    ); y = y + 46
    addSlider(AutoFarmPage, "Max Delay", y, 0.1, 2.0,
        function() return maxDelay end,
        function(val) maxDelay = val end,
        function(v) return string.format("%.2f", v) end
    ); y = y + 46
    AutoFarmPage.Size = UDim2.new(1, 0, 0, y + 20)
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

-- ESP
local function buildESP()
    local y = 10
    addLabel(ESPPage, "Role Highlights", y); y = y + 28
    addToggle(ESPPage, "Murderer", y,
        function() return ESP_SETTINGS.Murderer end,
        function(val) ESP_SETTINGS.Murderer = val end
    ); y = y + 36
    addToggle(ESPPage, "Sheriff", y,
        function() return ESP_SETTINGS.Sheriff end,
        function(val) ESP_SETTINGS.Sheriff = val end
    ); y = y + 36
    addToggle(ESPPage, "Hero", y,
        function() return ESP_SETTINGS.Hero end,
        function(val) ESP_SETTINGS.Hero = val end
    ); y = y + 36
    addToggle(ESPPage, "Innocent", y,
        function() return ESP_SETTINGS.Innocent end,
        function(val) ESP_SETTINGS.Innocent = val end
    ); y = y + 36
    addLabel(ESPPage, "Name ESP", y); y = y + 28
    addToggle(ESPPage, "Murderer Name", y,
        function() return NAME_ESP_SETTINGS.Murderer end,
        function(val) NAME_ESP_SETTINGS.Murderer = val end
    ); y = y + 36
    addToggle(ESPPage, "Sheriff Name", y,
        function() return NAME_ESP_SETTINGS.Sheriff end,
        function(val) NAME_ESP_SETTINGS.Sheriff = val end
    ); y = y + 36
    addToggle(ESPPage, "Hero Name", y,
        function() return NAME_ESP_SETTINGS.Hero end,
        function(val) NAME_ESP_SETTINGS.Hero = val end
    ); y = y + 36
    addToggle(ESPPage, "Innocent Name", y,
        function() return NAME_ESP_SETTINGS.Innocent end,
        function(val) NAME_ESP_SETTINGS.Innocent = val end
    ); y = y + 36
    addLabel(ESPPage, "Name Display", y); y = y + 28
    addToggle(ESPPage, "Display Name", y,
        function() return ESP_CUSTOMIZATION.DisplayName end,
        function(val) ESP_CUSTOMIZATION.DisplayName = val end
    ); y = y + 36
    addToggle(ESPPage, "Normal Name", y,
        function() return ESP_CUSTOMIZATION.NormalName end,
        function(val) ESP_CUSTOMIZATION.NormalName = val end
    ); y = y + 36
    addToggle(ESPPage, "Avatar", y,
        function() return ESP_CUSTOMIZATION.AvatarDisplay end,
        function(val) ESP_CUSTOMIZATION.AvatarDisplay = val end
    ); y = y + 36
    addToggle(ESPPage, "2D Box", y,
        function() return ESP_CUSTOMIZATION.Box2D end,
        function(val) ESP_CUSTOMIZATION.Box2D = val end
    ); y = y + 36
    ESPPage.Size = UDim2.new(1, 0, 0, y + 20)
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

-- Movement (добавлен HUD)
local function buildMovement()
    local y = 10
    addToggle(MovementPage, "Show FPS & Ping", y,
        function() return showHUD end,
        function(val) toggleHUD(val) end
    ); y = y + 36
    addToggle(MovementPage, "Custom WalkSpeed", y,
        function() return customWalkSpeedEnabled end,
        function(val) customWalkSpeedEnabled = val; applyWalkSpeed() end
    ); y = y + 36
    addSlider(MovementPage, "WalkSpeed", y, 10, 50,
        function() return walkSpeedValue end,
        function(val) walkSpeedValue = val; if customWalkSpeedEnabled then applyWalkSpeed() end end,
        function(v) return tostring(math.floor(v)) end
    ); y = y + 46
    addToggle(MovementPage, "Custom JumpPower", y,
        function() return customJumpPowerEnabled end,
        function(val) customJumpPowerEnabled = val; applyJumpPower() end
    ); y = y + 36
    addSlider(MovementPage, "JumpPower", y, 20, 150,
        function() return jumpPowerValue end,
        function(val) jumpPowerValue = val; if customJumpPowerEnabled then applyJumpPower() end end,
        function(v) return tostring(math.floor(v)) end
    ); y = y + 46
    addToggle(MovementPage, "Custom FOV", y,
        function() return customFOVEnabled end,
        function(val) customFOVEnabled = val; applyFOV() end
    ); y = y + 36
    addSlider(MovementPage, "FOV", y, 40, 120,
        function() return fovValue end,
        function(val) fovValue = val; if customFOVEnabled then applyFOV() end end,
        function(v) return tostring(math.floor(v)) end
    ); y = y + 46
    addToggle(MovementPage, "ForceField Material", y,
        function() return forceFieldEnabled end,
        function(val) forceFieldEnabled = val; applyForceFieldMaterial() end
    ); y = y + 36

    addLabel(MovementPage, "Dance", y); y = y + 28
    local danceBox = addTextBox(MovementPage, "Dance ID", y, "Enter ID", function(val) end)
    y = y + 36
    addButton(MovementPage, "Play Dance", y, function()
        local id = tonumber(danceBox:FindFirstChild("TextBox").Text)
        if id then playDance(id) end
    end); y = y + 36
    addButton(MovementPage, "Stop Dance", y, function() stopDance() end); y = y + 36
    MovementPage.Size = UDim2.new(1, 0, 0, y + 20)
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

-- COMBAT (вместо Admin)
local function buildCombat()
    local y = 10
    addLabel(CombatPage, "Combat Functions", y); y = y + 28
    addButton(CombatPage, "Kill All (if Murderer)", y, function()
        killAll()
    end); y = y + 36
    addButton(CombatPage, "Shoot Murderer", y, function()
        local murderer = findMurderer()
        if murderer then
            print("Shooting", murderer.Name)
        else
            print("No murderer found")
        end
    end); y = y + 36
    addLabel(CombatPage, "UnderMap", y); y = y + 28
    addButton(CombatPage, "Go UnderMap", y, function()
        if not underMapActive then goUnderMap() end
    end); y = y + 36
    addButton(CombatPage, "Return", y, function()
        if underMapActive then returnFromUnderMap() end
    end); y = y + 36
    addToggle(CombatPage, "Auto Grab Gun", y,
        function() return autoGrabGun end,
        function(val)
            autoGrabGun = val
            if autoGrabGun then
                RunService.Heartbeat:Connect(function() getgun() end)
            end
        end
    ); y = y + 36
    addLabel(CombatPage, "Fling", y); y = y + 28
    local targetBox = addTextBox(CombatPage, "Target", y, "Player name", function(val) end)
    y = y + 36
    addButton(CombatPage, "Fling", y, function()
        local name = targetBox:FindFirstChild("TextBox").Text
        local target = FindPlayerByPartialName(name)
        if target then SkidFling(target) else print("Player not found") end
    end); y = y + 36
    CombatPage.Size = UDim2.new(1, 0, 0, y + 20)
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

-- Chat
local function buildChat()
    local y = 10
    addLabel(ChatPage, "Script Chat [SC]", y); y = y + 28

    -- Поле ввода сообщения
    local chatInput = Instance.new("TextBox")
    chatInput.Parent = ChatPage
    chatInput.Position = UDim2.new(0, 0, 0, y)
    chatInput.Size = UDim2.new(1, 0, 0, 30)
    chatInput.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    chatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatInput.Font = Enum.Font.Gotham
    chatInput.TextSize = 14
    chatInput.PlaceholderText = "Type message..."
    chatInput.ClearTextOnFocus = false
    Instance.new("UICorner", chatInput).CornerRadius = UDim.new(0, 6)
    y = y + 36

    local sendBtn = addButton(ChatPage, "Send", y, function()
        sendScriptMessage(chatInput.Text)
        chatInput.Text = ""
    end)
    y = y + 36

    -- Окно сообщений (простой список)
    local msgFrame = Instance.new("Frame")
    msgFrame.Parent = ChatPage
    msgFrame.Position = UDim2.new(0, 0, 0, y)
    msgFrame.Size = UDim2.new(1, 0, 0, 200)
    msgFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    msgFrame.BackgroundTransparency = 0.5
    Instance.new("UICorner", msgFrame).CornerRadius = UDim.new(0, 6)

    local msgList = Instance.new("ScrollingFrame")
    msgList.Parent = msgFrame
    msgList.Size = UDim2.new(1, 0, 1, 0)
    msgList.BackgroundTransparency = 1
    msgList.CanvasSize = UDim2.new(0, 0, 0, 0)
    msgList.ScrollBarThickness = 4

    -- Добавляем сообщение в список
    local function addMessage(text)
        local lbl = Instance.new("TextLabel")
        lbl.Parent = msgList
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
        lbl.TextSize = 13
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        msgList.CanvasSize = UDim2.new(0, 0, 0, msgList.CanvasSize.Y.Offset + 22)
        msgList.CanvasPosition = Vector2.new(0, msgList.CanvasSize.Y.Offset)
    end

    -- Слушаем чат и добавляем сообщения
    local chatService = game:GetService("Chat")
    if chatService and chatService.MessageReceived then
        chatService.MessageReceived:Connect(function(msgData)
            local text = msgData.Message
            if string.sub(text, 1, 5) == " [SC]" then
                addMessage(text)
            end
        end)
    end

    -- В примере добавим тестовое сообщение
    addMessage("Welcome to Script Chat! Use [SC] prefix.")

    ChatPage.Size = UDim2.new(1, 0, 0, y + 220)
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 220)
end

buildAutoFarm()
buildESP()
buildMovement()
buildCombat()
buildChat()

-- По умолчанию показываем AutoFarm
AutoFarmPage.Visible = true

-- Переключение вкладок
local function switchPage(page)
    for _, p in pairs(pages) do
        p.Visible = false
    end
    page.Visible = true
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, page.Size.Y.Offset + 20)
end

pages = {AutoFarmPage, ESPPage, MovementPage, CombatPage, ChatPage}
local tabs = {autoFarmTab, espTab, movementTab, combatTab, chatTab}

for i, tab in ipairs(tabs) do
    tab.MouseButton1Click:Connect(function()
        switchPage(pages[i])
        for _, t in ipairs(tabs) do
            t.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            t.TextColor3 = Color3.fromRGB(200, 200, 220)
        end
        tab.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end
autoFarmTab.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
autoFarmTab.TextColor3 = Color3.fromRGB(255, 255, 255)

-- ============================================================
--  УПРАВЛЕНИЕ МЕНЮ
-- ============================================================

local menuVisible = true

local function toggleMenu()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
end

CloseBtn.MouseButton1Click:Connect(function()
    toggleMenu()
end)

-- Виджет для открытия
local ToggleWidget = Instance.new("Frame")
ToggleWidget.Parent = ScreenGui
ToggleWidget.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
ToggleWidget.BackgroundTransparency = 0.15
ToggleWidget.Position = UDim2.new(0.5, -80, 0.02, 0)
ToggleWidget.Size = UDim2.new(0, 160, 0, 40)
ToggleWidget.Visible = true
Instance.new("UICorner", ToggleWidget).CornerRadius = UDim.new(0, 10)

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Parent = ToggleWidget
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Size = UDim2.new(1, 0, 1, 0)
ToggleLabel.Font = Enum.Font.GothamBold
ToggleLabel.Text = "nkno$ hub"
ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleLabel.TextSize = 17

ToggleWidget.MouseButton1Click:Connect(toggleMenu)

-- Горячая клавиша Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleMenu()
    end
end)

-- ============================================================
--  ИНИЦИАЛИЗАЦИЯ
-- ============================================================

-- Создать HUD при запуске
createHUD()

-- Применить настройки
LocalPlayer.CharacterAdded:Connect(function()
    applyWalkSpeed()
    applyJumpPower()
    applyFOV()
    applyForceFieldMaterial()
    if farmEnabled and LocalPlayer:GetAttribute("Alive") == true then
        noclipEnabled = true
        enableNoclip()
        startFarming()
    end
end)

LocalPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
    if farmEnabled and LocalPlayer:GetAttribute("Alive") == true then
        noclipEnabled = true
        enableNoclip()
        startFarming()
    elseif farmEnabled and LocalPlayer:GetAttribute("Alive") == false then
        stopFarming()
        disableNoclip()
    end
end)

print("nkno$ hub (Optimized) loaded. Press Insert to toggle menu.")
print("New: COMBAT tab, FPS/Ping HUD, Script Chat.")
