-- ====================================================
--    GUI-СКРИПТ: FLY + NOCLIP + FLING
--    С ПЕРЕТАСКИВАНИЕМ ПО ЭКРАНУ (DRAGGABLE)
--    Стиль как у RHub / Infinite Yield
-- ====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ===== ПЕРЕМЕННЫЕ =====
local flyEnabled = false
local noclipEnabled = false
local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil
local dragObject = nil
local dragInput = nil
local dragStart = nil
local startPos = nil

-- ===== СОЗДАНИЕ GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ===== ГЛАВНОЕ ОКНО =====
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 255)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- ===== ЗАГОЛОВОК (для перетаскивания) =====
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
titleBar.BackgroundTransparency = 0.3
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- ===== ЗАГОЛОВОК ТЕКСТ =====
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔹 RHub Control 🔹"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- ===== КНОПКА ЗАКРЫТИЯ =====
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

-- ===== КНОПКА СВЁРТЫВАНИЯ =====
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
        mainFrame:TweenSize(UDim2.new(0, 300, 0, 30), "Out", "Quad", 0.3)
        minimizeBtn.Text = "□"
    else
        mainFrame:TweenSize(UDim2.new(0, 300, 0, 400), "Out", "Quad", 0.3)
        minimizeBtn.Text = "─"
    end
end)

-- ===== ОСНОВНОЙ КОНТЕЙНЕР =====
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.new(0, 10, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
contentLayout.Parent = contentFrame

-- ===== ФУНКЦИЯ СОЗДАНИЯ КНОПКИ =====
local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.AutoButtonColor = false
    btn.Parent = contentFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    -- Эффект наведения
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
-- Кнопка FLY
local flyBtn = createButton("🪁 FLY (ВКЛ)", Color3.fromRGB(0, 120, 255), function()
    toggleFly()
    flyBtn.Text = flyEnabled and "🪁 FLY (ВЫКЛ)" or "🪁 FLY (ВКЛ)"
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 120, 255)
end)

-- Кнопка NOCLIP
local noclipBtn = createButton("🧊 NOCLIP (ВКЛ)", Color3.fromRGB(0, 200, 100), function()
    toggleNoclip()
    noclipBtn.Text = noclipEnabled and "🧊 NOCLIP (ВЫКЛ)" or "🧊 NOCLIP (ВКЛ)"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 200, 100)
end)

-- Кнопка FLING (с текстовым полем для ввода имени)
local flingFrame = Instance.new("Frame")
flingFrame.Size = UDim2.new(1, 0, 0, 40)
flingFrame.BackgroundTransparency = 1
flingFrame.Parent = contentFrame

local flingLayout = Instance.new("UIListLayout")
flingLayout.FillDirection = Enum.FillDirection.Horizontal
flingLayout.Padding = UDim.new(0, 5)
flingLayout.Parent = flingFrame

-- Поле ввода имени
local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.6, 0, 1, 0)
nameBox.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
nameBox.Text = "имя игрока"
nameBox.TextColor3 = Color3.fromRGB(200, 200, 200)
nameBox.TextScaled = true
nameBox.Font = Enum.Font.Gotham
nameBox.ClearTextOnFocus = false
nameBox.Parent = flingFrame

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 8)
nameCorner.Parent = nameBox

-- Кнопка FLING
local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(0.4, 0, 1, 0)
flingBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
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
        SendMessage("[FLING] Игрок не найден!")
    end
end)

-- Кнопка FLING ALL
local flingAllBtn = createButton("💥 FLING ALL (ВСЕХ)", Color3.fromRGB(200, 50, 0), function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            flingPlayer(player)
        end
    end
    SendMessage("[FLING] Все игроки отброшены!")
end)

-- Ползунок скорости
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 30)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = contentFrame

local speedLayout = Instance.new("UIListLayout")
speedLayout.FillDirection = Enum.FillDirection.Horizontal
speedLayout.Padding = UDim.new(0, 5)
speedLayout.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: 50"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham
speedLabel.Parent = speedFrame

local speedSlider = Instance.new("TextBox")
speedSlider.Size = UDim2.new(0.6, 0, 1, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
speedSlider.Text = "50"
speedSlider.TextColor3 = Color3.fromRGB(200, 200, 200)
speedSlider.TextScaled = true
speedSlider.Font = Enum.Font.Gotham
speedSlider.Parent = speedFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 8)
sliderCorner.Parent = speedSlider

speedSlider.FocusLost:Connect(function()
    local newSpeed = tonumber(speedSlider.Text)
    if newSpeed then
        flySpeed = newSpeed
        speedLabel.Text = "Скорость: " .. flySpeed
        SendMessage("[SPEED] Скорость установлена: " .. flySpeed)
    else
        speedSlider.Text = tostring(flySpeed)
    end
end)

-- Кнопка HELP
createButton("❓ HELP", Color3.fromRGB(100, 100, 100), function()
    SendMessage("=== КОМАНДЫ ===")
    SendMessage("fly - вкл/выкл полёт (WASD/Space/Shift)")
    SendMessage("noclip - вкл/выкл проход сквозь стены")
    SendMessage("fling [имя] - отбросить игрока")
    SendMessage("flingall - отбросить всех")
    SendMessage("speed [число] - скорость полёта")
end)

-- ===== ПЕРЕТАСКИВАНИЕ ОКНА =====
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

-- ===== ФУНКЦИИ (FLY, NOCLIP, FLING) =====
function SendMessage(text)
    local chat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
    if chat then
        local sayMessage = chat:FindFirstChild("SayMessageRequest")
        if sayMessage then
            sayMessage:FireServer(text, "All")
        end
    end
end

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
        SendMessage("[FLY] ВКЛЮЧЁН")
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        Humanoid.PlatformStand = false
        SendMessage("[FLY] ВЫКЛЮЧЁН")
    end
end

function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
    SendMessage(noclipEnabled and "[NOCLIP] ВКЛЮЧЁН" or "[NOCLIP] ВЫКЛЮЧЁН")
end

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
    SendMessage("[FLING] " .. targetPlayer.Name .. " отброшен!")
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

-- ===== ОБНОВЛЕНИЕ ПОЛЁТА =====
RunService.Heartbeat:Connect(function()
    if not flyEnabled then return end
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
end)

-- ===== ОБНОВЛЕНИЕ NOCLIP ПРИ ДОБАВЛЕНИИ ЧАСТЕЙ =====
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
        flyBtn.Text = flyEnabled and "🪁 FLY (ВЫКЛ)" or "🪁 FLY (ВКЛ)"
        flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 120, 255)
    elseif command == "noclip" then
        toggleNoclip()
        noclipBtn.Text = noclipEnabled and "🧊 NOCLIP (ВЫКЛ)" or "🧊 NOCLIP (ВКЛ)"
        noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 200, 100)
    elseif command == "fling" and #args >= 2 then
        local target = findPlayer(args[2])
        if target then flingPlayer(target) end
    elseif command == "flingall" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                flingPlayer(player)
            end
        end
    elseif command == "speed" and #args >= 2 then
        local newSpeed = tonumber(args[2])
        if newSpeed then
            flySpeed = newSpeed
            speedLabel.Text = "Скорость: " .. flySpeed
            speedSlider.Text = tostring(flySpeed)
            SendMessage("[SPEED] Скорость: " .. flySpeed)
        end
    end
end)
