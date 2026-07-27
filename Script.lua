-- ====================================================
--    MM2 MEGA-ЧИТ: АВТОФАРМ + ESP + SPEED + FLY + NOCLIP + FLING
--    С ПЕРЕТАСКИВАЕМЫМ GUI
-- ====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ===== ПЕРЕМЕННЫЕ =====
local flyEnabled = false
local noclipEnabled = false
local flingEnabled = false
local flySpeed = 50
local walkSpeed = 16
local bodyVelocity = nil
local bodyGyro = nil
local dragObject = nil
local dragStart = nil
local startPos = nil

-- ===== ESP ПЕРЕМЕННЫЕ =====
local espEnabled = false
local espObjects = {}
local espColorMurderer = Color3.fromRGB(255, 0, 0)    -- Красный
local espColorSheriff = Color3.fromRGB(0, 100, 255)   -- Синий
local espColorHero = Color3.fromRGB(0, 255, 0)        -- Зелёный
local espColorInnocent = Color3.fromRGB(255, 255, 255) -- Белый

-- ===== АВТОФАРМ ПЕРЕМЕННЫЕ =====
local autoFarmEnabled = false
local autoFarmRange = 50
local collectedCoins = 0

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2CheatGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ===== ГЛАВНОЕ ОКНО =====
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 550)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- ===== ЗАГОЛОВОК =====
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(60, 20, 30)
titleBar.BackgroundTransparency = 0.2
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -70, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔪 MM2 ULTRA CHEAT 🔪"
titleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
titleLabel.TextScaled = true
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, -4)
closeBtn.Position = UDim2.new(1, -35, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Кнопка свёртывания
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 1, -4)
minimizeBtn.Position = UDim2.new(1, -70, 0, 2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 350, 0, 35), "Out", "Quad", 0.3)
        minimizeBtn.Text = "□"
    else
        mainFrame:TweenSize(UDim2.new(0, 350, 0, 550), "Out", "Quad", 0.3)
        minimizeBtn.Text = "─"
    end
end)

-- ===== СКРОЛЛИНГ КОНТЕЙНЕР =====
local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Size = UDim2.new(1, -20, 1, -55)
scrollContainer.Position = UDim2.new(0, 10, 0, 45)
scrollContainer.BackgroundTransparency = 1
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollContainer.ScrollBarThickness = 6
scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
scrollContainer.Parent = mainFrame

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 6)
scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
scrollLayout.VerticalAlignment = Enum.VerticalAlignment.Top
scrollLayout.Parent = scrollContainer

-- ===== ФУНКЦИЯ СОЗДАНИЯ КНОПКИ =====
local function createButton(text, color, callback, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(width or 1, 0, 0, 38)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.AutoButtonColor = false
    btn.Parent = scrollContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ===== СОЗДАНИЕ КНОПОК =====

-- FLY
local flyBtn = createButton("🪁 FLY", Color3.fromRGB(0, 120, 255), function()
    toggleFly()
    flyBtn.Text = flyEnabled and "🪁 FLY (ON)" or "🪁 FLY (OFF)"
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 120, 255)
end)

-- NOCLIP
local noclipBtn = createButton("🧊 NOCLIP", Color3.fromRGB(0, 200, 100), function()
    toggleNoclip()
    noclipBtn.Text = noclipEnabled and "🧊 NOCLIP (ON)" or "🧊 NOCLIP (OFF)"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 200, 100)
end)

-- ESP
local espBtn = createButton("👁️ ESP", Color3.fromRGB(150, 0, 200), function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "👁️ ESP (ON)" or "👁️ ESP (OFF)"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(150, 0, 200)
    if not espEnabled then
        clearESP()
    end
end)

-- АВТОФАРМ
local farmBtn = createButton("💰 AUTO FARM", Color3.fromRGB(255, 180, 0), function()
    autoFarmEnabled = not autoFarmEnabled
    farmBtn.Text = autoFarmEnabled and "💰 AUTO FARM (ON)" or "💰 AUTO FARM (OFF)"
    farmBtn.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 180, 0)
end)

-- ===== SPEED CONTROL =====
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 50)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = scrollContainer

local speedLayout = Instance.new("UIListLayout")
speedLayout.FillDirection = Enum.FillDirection.Vertical
speedLayout.Padding = UDim.new(0, 2)
speedLayout.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ Speed: 16 (Walk) | Fly: 50"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham
speedLabel.Parent = speedFrame

local speedSlider = Instance.new("TextBox")
speedSlider.Size = UDim2.new(1, 0, 0, 25)
speedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
speedSlider.Text = "16"
speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSlider.TextScaled = true
speedSlider.Font = Enum.Font.Gotham
speedSlider.Parent = speedFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 8)
sliderCorner.Parent = speedSlider

speedSlider.FocusLost:Connect(function()
    local newSpeed = tonumber(speedSlider.Text)
    if newSpeed and newSpeed >= 10 and newSpeed <= 140 then
        walkSpeed = newSpeed
        Humanoid.WalkSpeed = walkSpeed
        speedLabel.Text = "⚡ Speed: " .. walkSpeed .. " | Fly: " .. flySpeed
        sendMessage("[SPEED] Скорость ходьбы: " .. walkSpeed)
    else
        speedSlider.Text = tostring(walkSpeed)
        sendMessage("[SPEED] Введите число от 10 до 140!")
    end
end)

-- ===== FLY SPEED CONTROL =====
local flySpeedFrame = Instance.new("Frame")
flySpeedFrame.Size = UDim2.new(1, 0, 0, 50)
flySpeedFrame.BackgroundTransparency = 1
flySpeedFrame.Parent = scrollContainer

local flySpeedLayout = Instance.new("UIListLayout")
flySpeedLayout.FillDirection = Enum.FillDirection.Vertical
flySpeedLayout.Padding = UDim.new(0, 2)
flySpeedLayout.Parent = flySpeedFrame

local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(1, 0, 0, 20)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "✈️ Fly Speed: 50"
flySpeedLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
flySpeedLabel.TextScaled = true
flySpeedLabel.Font = Enum.Font.Gotham
flySpeedLabel.Parent = flySpeedFrame

local flySpeedSlider = Instance.new("TextBox")
flySpeedSlider.Size = UDim2.new(1, 0, 0, 25)
flySpeedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
flySpeedSlider.Text = "50"
flySpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedSlider.TextScaled = true
flySpeedSlider.Font = Enum.Font.Gotham
flySpeedSlider.Parent = flySpeedFrame

local flySliderCorner = Instance.new("UICorner")
flySliderCorner.CornerRadius = UDim.new(0, 8)
flySliderCorner.Parent = flySpeedSlider

flySpeedSlider.FocusLost:Connect(function()
    local newSpeed = tonumber(flySpeedSlider.Text)
    if newSpeed and newSpeed >= 10 and newSpeed <= 140 then
        flySpeed = newSpeed
        flySpeedLabel.Text = "✈️ Fly Speed: " .. flySpeed
        speedLabel.Text = "⚡ Speed: " .. walkSpeed .. " | Fly: " .. flySpeed
        sendMessage("[FLY SPEED] Скорость полёта: " .. flySpeed)
    else
        flySpeedSlider.Text = tostring(flySpeed)
        sendMessage("[FLY SPEED] Введите число от 10 до 140!")
    end
end)

-- ===== FLING =====
local flingFrame = Instance.new("Frame")
flingFrame.Size = UDim2.new(1, 0, 0, 40)
flingFrame.BackgroundTransparency = 1
flingFrame.Parent = scrollContainer

local flingLayout = Instance.new("UIListLayout")
flingLayout.FillDirection = Enum.FillDirection.Horizontal
flingLayout.Padding = UDim.new(0, 5)
flingLayout.Parent = flingFrame

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.6, 0, 1, 0)
nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
nameBox.Text = "имя игрока"
nameBox.TextColor3 = Color3.fromRGB(200, 200, 200)
nameBox.TextScaled = true
nameBox.Font = Enum.Font.Gotham
nameBox.ClearTextOnFocus = false
nameBox.Parent = flingFrame

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 8)
nameCorner.Parent = nameBox

local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(0.4, 0, 1, 0)
flingBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
flingBtn.Text = "💥 FLING"
flingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flingBtn.TextScaled = true
flingBtn.Font = Enum.Font.GothamSemibold
flingBtn.Parent = flingFrame

local flingCorner = Instance.new("UICorner")
flingCorner.CornerRadius = UDim.new(0, 8)
flingCorner.Parent = flingBtn

flingBtn.MouseButton1Click:Connect(function()
    local target = findPlayer(nameBox.Text)
    if target then
        flingPlayer(target)
    else
        sendMessage("[FLING] Игрок не найден!")
    end
end)

-- FLING ALL
createButton("💥 FLING ALL", Color3.fromRGB(200, 50, 0), function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            flingPlayer(player)
        end
    end
    sendMessage("[FLING] Все отброшены!")
end)

-- Статистика монет
local coinLabel = Instance.new("TextLabel")
coinLabel.Size = UDim2.new(1, 0, 0, 25)
coinLabel.BackgroundTransparency = 1
coinLabel.Text = "🪙 Собрано монет: 0"
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.TextScaled = true
coinLabel.Font = Enum.Font.GothamBold
coinLabel.Parent = scrollContainer

-- ===== ПЕРЕТАСКИВАНИЕ =====
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = mainFrame.Position
        dragObject = mainFrame
        dragObject.Parent:SetTopLevel(true)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragObject then
        local delta = input.Position - dragStart
        dragObject.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and dragObject then
        dragObject.Parent:SetTopLevel(false)
        dragObject = nil
    end
end)

-- ===== ФУНКЦИИ =====

function sendMessage(text)
    local chat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
    if chat then
        local sayMessage = chat:FindFirstChild("SayMessageRequest")
        if sayMessage then
            sayMessage:FireServer(text, "All")
        end
    end
end

-- ===== FLY =====
function toggleFly()
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
        sendMessage("[FLY] ON")
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        Humanoid.PlatformStand = false
        sendMessage("[FLY] OFF")
    end
end

-- ===== NOCLIP =====
function toggleNoclip()
    noclipEnabled = not noclipEnabled
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
    sendMessage(noclipEnabled and "[NOCLIP] ON" or "[NOCLIP] OFF")
end

-- ===== FLING =====
function flingPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
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
    sendMessage("[FLING] " .. targetPlayer.Name .. " отброшен!")
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

-- ===== ESP =====
function getPlayerRole(player)
    -- Проверяем наличие инструментов (нож у убийцы, пистолет у шерифа)
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
    
    -- Проверяем наличие специальных эффектов (Hero)
    for _, effect in pairs(character:GetChildren()) do
        if effect.Name:lower():find("hero") or effect.Name:lower():find("glow") then
            return "Hero"
        end
    end
    
    return "Innocent"
end

function getRoleColor(role)
    if role == "Murderer" then return espColorMurderer
    elseif role == "Sheriff" then return espColorSheriff
    elseif role == "Hero" then return espColorHero
    else return espColorInnocent end
end

function createESP(player)
    if not player or player == LocalPlayer then return end
    if espObjects[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local role = getPlayerRole(player)
    local color = getRoleColor(role)
    
    -- Создаём BillboardGui над головой игрока
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    
    -- Фон
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color
    frame.Parent = billboard
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    -- Имя игрока
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name .. " [" .. role .. "]"
    nameLabel.TextColor3 = color
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = frame
    
    -- Расстояние
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = frame
    
    -- Линия к игроку (через часть)
    local linePart = Instance.new("Part")
    linePart.Size = Vector3.new(0.1, 0.1, 0.1)
    linePart.Anchored = true
    linePart.CanCollide = false
    linePart.Transparency = 0.5
    linePart.BrickColor = BrickColor.new(color)
    linePart.Material = Enum.Material.Neon
    linePart.Parent = character
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = linePart
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    beam.Color = ColorSequence.new(color)
    beam.Transparency = NumberSequence.new(0.5)
    beam.Parent = linePart
    
    espObjects[player] = {
        Billboard = billboard,
        NameLabel = nameLabel,
        DistLabel = distLabel,
        LinePart = linePart,
        Beam = beam,
        Character = character
    }
end

function clearESP()
    for player, data in pairs(espObjects) do
        if data.Billboard then data.Billboard:Destroy() end
        if data.LinePart then data.LinePart:Destroy() end
    end
    espObjects = {}
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
                -- Обновляем расстояние
                local dist = (RootPart.Position - (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0))).Magnitude
                if data.DistLabel then
                    data.DistLabel.Text = math.floor(dist) .. "m"
                end
                
                -- Обновляем роль
                local role = getPlayerRole(player)
                local color = getRoleColor(role)
                if data.NameLabel then
                    data.NameLabel.Text = player.Name .. " [" .. role .. "]"
                    data.NameLabel.TextColor3 = color
                end
                if data.Billboard and data.Billboard.Frame then
                    data.Billboard.Frame.BorderColor3 = color
                end
                if data.Beam then
                    data.Beam.Color = ColorSequence.new(color)
                end
            end
        end
    end
end

-- ===== АВТОФАРМ МОНЕТ =====
function findCoins()
    local coins = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():find("coin") then
            table.insert(coins, obj)
        end
    end
    return coins
end

function autoFarmCoins()
    if not autoFarmEnabled then return end
    
    local coins = findCoins()
    local nearest = nil
    local nearestDist = autoFarmRange
    
    for _, coin in pairs(coins) do
        local dist = (RootPart.Position - coin.Position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = coin
        end
    end
    
    if nearest then
        -- Телепортируемся к монете
        RootPart.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
        collectedCoins = collectedCoins + 1
        coinLabel.Text = "🪙 Собрано монет: " .. collectedCoins
    end
end

-- ===== ОБНОВЛЕНИЕ ПОЛЁТА =====
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
    
    -- Auto Farm
    if autoFarmEnabled then
        autoFarmCoins()
    end
    
    -- ESP
    if espEnabled then
        updateESP()
    end
end)

-- ===== ОБНОВЛЕНИЕ NOCLIP =====
Character.ChildAdded:Connect(function(child)
    if noclipEnabled and child:IsA("BasePart") then
        child.CanCollide = false
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
        toggleFly()
        flyBtn.Text = flyEnabled and "🪁 FLY (ON)" or "🪁 FLY (OFF)"
        flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 120, 255)
    elseif command == "noclip" then
        toggleNoclip()
        noclipBtn.Text = noclipEnabled and "🧊 NOCLIP (ON)" or "🧊 NOCLIP (OFF)"
        noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 200, 100)
    elseif command == "esp" then
        espEnabled = not espEnabled
        espBtn.Text = espEnabled and "👁️ ESP (ON)" or "👁️ ESP (OFF)"
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(150, 0, 200)
        if not espEnabled then clearESP() end
    elseif command == "farm" then
        autoFarmEnabled = not autoFarmEnabled
        farmBtn.Text = autoFarmEnabled and "💰 AUTO FARM (ON)" or "💰 AUTO FARM (OFF)"
        farmBtn.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 180, 0)
    elseif command == "speed" and #args >= 2 then
        local newSpeed = tonumber(args[2])
        if newSpeed and newSpeed >= 10 and newSpeed <= 140 then
            walkSpeed = newSpeed
            Humanoid.WalkSpeed = walkSpeed
            speedSlider.Text = tostring(walkSpeed)
            speedLabel.Text = "⚡ Speed: " .. walkSpeed .. " | Fly: " .. flySpeed
            sendMessage("[SPEED] Скорость: " .. walkSpeed)
        end
    elseif command == "flyspeed" and #args >= 2 then
        local newSpeed = tonumber(args[2])
        if newSpeed and newSpeed >= 10 and newSpeed <= 140 then
            flySpeed = newSpeed
            flySpeedSlider.Text = tostring(flySpeed)
            flySpeedLabel.Text = "✈️ Fly Speed: " .. flySpeed
            speedLabel.Text = "⚡ Speed: " .. walkSpeed .. " | Fly: " .. flySpeed
            sendMessage("[FLY SPEED] Скорость полёта: " .. flySpeed)
        end
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
        sendMessage("=== MM2 ULTRA CHEAT ===")
        sendMessage("fly - полёт | noclip - проход сквозь стены")
        sendMessage("esp - ESP игроков | farm - автофарм монет")
        sendMessage("speed [10-140] - скорость ходьбы")
        sendMessage("flyspeed [10-140] - скорость полёта")
        sendMessage("fling [имя] - отбросить | flingall - всех")
    end
end)

-- ===== ИНИЦИАЛИЗАЦИЯ =====
sendMessage("🔪 MM2 ULTRA CHEAT загружен! Напишите 'help' в чат")
print("✅ MM2 Cheat loaded! Commands: fly, noclip, esp, farm, speed, flyspeed, fling, flingall")
