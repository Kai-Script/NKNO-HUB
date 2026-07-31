--[[
    ⚽ FIFA Super Soccer ULTIMATE SCRIPT
    by nkno$
    Функции:
    - Speed control (WalkSpeed)
    - Remove opponent goalkeeper
    - Remove all opponent players
    - Remove goal barriers
    - Auto goal (instant)
    - Auto goal timer (every X seconds)
    - Teleport to ball
    - Freeze ball
    - GUI with tabs
    - Hotkeys: F (menu), G (auto goal), K (remove GK)
    - Settings saved between sessions (using _G)
]]

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ===== Настройки по умолчанию =====
local defaultSpeed = 16
local currentSpeed = _G.FIFA_Speed or defaultSpeed
local autoGoalInterval = _G.FIFA_AutoInterval or 3  -- секунды
local autoGoalEnabled = _G.FIFA_AutoEnabled or false

-- ===== Вспомогательные функции =====
local function findBall()
    return workspace:FindFirstChild("Ball") or workspace:FindFirstChild("ball") or workspace:FindFirstChild("SoccerBall")
end

local function findOpponentGoal()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("goal") then
            -- Проверяем, что это ворота соперника (по цвету, позиции или названию)
            if v.Name:lower():find("opponent") or v.Name:lower():find("enemy") or v.BrickColor == BrickColor.new("Bright red") or v.BrickColor == BrickColor.new("Really red") then
                return v
            end
            -- Или если ворота синие/красные, а наши зелёные (условно)
            if v.BrickColor == BrickColor.new("Bright blue") or v.BrickColor == BrickColor.new("Navy blue") then
                -- считаем, что синие - вражеские (зависит от игры)
                return v
            end
        end
    end
    -- Если не нашли, возьмём любые ворота с противоположной стороны от игрока
    local playerPos = character and character.PrimaryPart and character.PrimaryPart.Position
    if playerPos then
        local bestDist = math.huge
        local bestGoal = nil
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():find("goal") then
                local dist = (v.Position - playerPos).Magnitude
                if dist > 30 and dist < bestDist then -- дальние ворота
                    bestDist = dist
                    bestGoal = v
                end
            end
        end
        return bestGoal
    end
    return nil
end

local function findGoalkeeper()
    -- Ищем вратаря среди игроков
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            -- Проверяем имя, теги, атрибуты
            if char.Name:lower():find("gk") or char.Name:lower():find("goalkeeper") or char.Name:lower():find("вратарь") then
                return char
            end
            -- Проверяем, есть ли у него Humanoid с ролью (если есть)
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                local role = hum:GetAttribute("Role") or hum:GetAttribute("Position")
                if role and (role:lower():find("gk") or role:lower():find("goalkeeper")) then
                    return char
                end
            end
        end
    end
    -- Если не нашли, ищем по позиции - обычно вратарь стоит на линии ворот
    local goal = findOpponentGoal()
    if goal then
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character.PrimaryPart then
                local dist = (p.Character.PrimaryPart.Position - goal.Position).Magnitude
                if dist < 20 then -- вратарь рядом с воротами
                    return p.Character
                end
            end
        end
    end
    return nil
end

-- ===== Основные функции =====
local function removeGoalkeeper()
    local gk = findGoalkeeper()
    if gk then
        gk:BreakJoints()
        print("✅ Вратарь удалён.")
        return true
    else
        print("⚠️ Вратарь не найден.")
        return false
    end
end

local function removeAllOpponents()
    local count = 0
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            p.Character:BreakJoints()
            count = count + 1
        end
    end
    print("✅ Удалено соперников: " .. count)
end

local function removeBarriers()
    local removed = 0
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("barrier") or v.Name:lower():find("collision") or v.Name:lower():find("wall")) then
            if v.Parent and (v.Parent.Name:lower():find("goal") or v.Parent.Name:lower():find("barrier")) then
                v:Destroy()
                removed = removed + 1
            end
        end
    end
    print("✅ Удалено барьеров: " .. removed)
end

local function autoGoal()
    local ball = findBall()
    local goal = findOpponentGoal()
    if ball and goal then
        ball.Position = goal.Position + Vector3.new(0, 2, 0)
        ball.Velocity = Vector3.new(0, 0, 0)
        print("⚽ Гол забит!")
        return true
    else
        print("⚠️ Мяч или ворота не найдены.")
        return false
    end
end

local function teleportToBall()
    local ball = findBall()
    if ball and character and character.PrimaryPart then
        character.PrimaryPart.CFrame = CFrame.new(ball.Position + Vector3.new(0, 3, 2))
        print("📍 Телепортировались к мячу.")
    else
        print("⚠️ Не удалось телепортироваться.")
    end
end

local function freezeBall()
    local ball = findBall()
    if ball then
        ball.Velocity = Vector3.new(0, 0, 0)
        ball.RotVelocity = Vector3.new(0, 0, 0)
        ball.Anchored = not ball.Anchored
        print(ball.Anchored and "❄️ Мяч заморожен" or "🔥 Мяч разморожен")
    end
end

-- ===== Таймер автогола =====
local autoGoalTimer
local function toggleAutoGoal(state)
    autoGoalEnabled = (state ~= nil) and state or not autoGoalEnabled
    _G.FIFA_AutoEnabled = autoGoalEnabled
    if autoGoalTimer then
        autoGoalTimer:Disconnect()
        autoGoalTimer = nil
    end
    if autoGoalEnabled then
        autoGoalTimer = game:GetService("RunService").Heartbeat:Connect(function()
            -- Проверяем, что прошло интервал
            if not _G.FIFA_AutoLastTime then _G.FIFA_AutoLastTime = tick() end
            if tick() - _G.FIFA_AutoLastTime >= autoGoalInterval then
                autoGoal()
                _G.FIFA_AutoLastTime = tick()
            end
        end)
        print("🔄 Автогол включён, интервал " .. autoGoalInterval .. " сек.")
    else
        print("⏹️ Автогол выключен.")
    end
end

-- ===== Обновление скорости =====
local function setSpeed(speed)
    currentSpeed = math.max(0, speed)
    _G.FIFA_Speed = currentSpeed
    humanoid.WalkSpeed = currentSpeed
    print("🏃 Скорость установлена: " .. currentSpeed)
end

-- Инициализация скорости
setSpeed(currentSpeed)

-- ===== Создание GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "FIFA_Utils"
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Parent = gui
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Size = UDim2.new(0, 360, 0, 460)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -230)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true

local corner = Instance.new("UICorner")
corner.Parent = mainFrame
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Parent = mainFrame
stroke.Color = Color3.fromRGB(45, 45, 70)
stroke.Thickness = 1.5

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.BackgroundTransparency = 1
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)

local title = Instance.new("TextLabel")
title.Parent = titleBar
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "⚽ FIFA ULTIMATE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Вкладки
local tabBar = Instance.new("Frame")
tabBar.Parent = mainFrame
tabBar.BackgroundTransparency = 1
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 35)

local tabs = {"Основные", "Автогол", "Дополнительно"}
local tabButtons = {}
local contentFrames = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Parent = tabBar
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(25, 25, 40)
    btn.Size = UDim2.new(1 / #tabs, -2, 1, -4)
    btn.Position = UDim2.new((i-1) / #tabs, 2, 0, 2)
    btn.Text = tabName
    btn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 180)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.Name = "Tab_" .. tabName
    local cornerBtn = Instance.new("UICorner")
    cornerBtn.Parent = btn
    cornerBtn.CornerRadius = UDim.new(0, 6)
    table.insert(tabButtons, btn)
    
    local content = Instance.new("ScrollingFrame")
    content.Parent = mainFrame
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -20, 1, -85)
    content.Position = UDim2.new(0, 10, 0, 80)
    content.Visible = (i == 1)
    content.ScrollBarThickness = 3
    content.CanvasSize = UDim2.new(0, 0, 0, 400)
    table.insert(contentFrames, content)
    
    btn.MouseButton1Click:Connect(function()
        for j, tb in ipairs(tabButtons) do
            tb.BackgroundColor3 = (j == i) and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(25, 25, 40)
            tb.TextColor3 = (j == i) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 180)
            contentFrames[j].Visible = (j == i)
        end
    end)
end

-- ===== Вкладка 1: Основные =====
local mainContent = contentFrames[1]

-- Скорость
local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = mainContent
speedLabel.BackgroundTransparency = 1
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 5)
speedLabel.Text = "🏃 Скорость бега: " .. currentSpeed
speedLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
speedLabel.TextSize = 15
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedSlider = Instance.new("TextBox")
speedSlider.Parent = mainContent
speedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
speedSlider.Size = UDim2.new(0.7, 0, 0, 30)
speedSlider.Position = UDim2.new(0, 0, 0, 35)
speedSlider.Text = tostring(currentSpeed)
speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSlider.TextSize = 14
speedSlider.ClearTextOnFocus = false
local sliderCorner = Instance.new("UICorner")
sliderCorner.Parent = speedSlider
sliderCorner.CornerRadius = UDim.new(0, 6)

speedSlider.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(speedSlider.Text)
        if val then
            setSpeed(val)
            speedLabel.Text = "🏃 Скорость бега: " .. currentSpeed
        else
            speedSlider.Text = tostring(currentSpeed)
        end
    end
end)

-- Кнопки основных действий
local function createButton(parent, text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = color
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    local cornerBtn = Instance.new("UICorner")
    cornerBtn.Parent = btn
    cornerBtn.CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton(mainContent, "🗑️ Удалить вратаря", 80, Color3.fromRGB(200, 50, 50), function()
    removeGoalkeeper()
end)

createButton(mainContent, "💀 Удалить всех соперников", 125, Color3.fromRGB(180, 40, 40), function()
    removeAllOpponents()
end)

createButton(mainContent, "🧱 Удалить барьеры ворот", 170, Color3.fromRGB(180, 120, 30), function()
    removeBarriers()
end)

createButton(mainContent, "⚡ Автогол (мгновенно)", 215, Color3.fromRGB(50, 150, 50), function()
    autoGoal()
end)

createButton(mainContent, "📍 Телепорт к мячу", 260, Color3.fromRGB(50, 100, 200), function()
    teleportToBall()
end)

createButton(mainContent, "❄️ Заморозить/разморозить мяч", 305, Color3.fromRGB(100, 100, 200), function()
    freezeBall()
end)

-- ===== Вкладка 2: Автогол =====
local autoContent = contentFrames[2]

local autoToggleBtn = Instance.new("TextButton")
autoToggleBtn.Parent = autoContent
autoToggleBtn.BackgroundColor3 = autoGoalEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
autoToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
autoToggleBtn.Position = UDim2.new(0.05, 0, 0, 10)
autoToggleBtn.Text = autoGoalEnabled and "🟢 Автогол ВКЛ" or "🔴 Автогол ВЫКЛ"
autoToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoToggleBtn.TextSize = 16
autoToggleBtn.Font = Enum.Font.GothamBold
local cornerAuto = Instance.new("UICorner")
cornerAuto.Parent = autoToggleBtn
cornerAuto.CornerRadius = UDim.new(0, 8)
autoToggleBtn.MouseButton1Click:Connect(function()
    toggleAutoGoal()
    autoToggleBtn.Text = autoGoalEnabled and "🟢 Автогол ВКЛ" or "🔴 Автогол ВЫКЛ"
    autoToggleBtn.BackgroundColor3 = autoGoalEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

local intervalLabel = Instance.new("TextLabel")
intervalLabel.Parent = autoContent
intervalLabel.BackgroundTransparency = 1
intervalLabel.Size = UDim2.new(1, 0, 0, 25)
intervalLabel.Position = UDim2.new(0, 0, 0, 65)
intervalLabel.Text = "⏱️ Интервал (сек): " .. autoGoalInterval
intervalLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
intervalLabel.TextSize = 15
intervalLabel.Font = Enum.Font.GothamSemibold
intervalLabel.TextXAlignment = Enum.TextXAlignment.Left

local intervalBox = Instance.new("TextBox")
intervalBox.Parent = autoContent
intervalBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
intervalBox.Size = UDim2.new(0.5, 0, 0, 30)
intervalBox.Position = UDim2.new(0, 0, 0, 95)
intervalBox.Text = tostring(autoGoalInterval)
intervalBox.TextColor3 = Color3.fromRGB(255, 255, 255)
intervalBox.TextSize = 14
intervalBox.ClearTextOnFocus = false
local intervalCorner = Instance.new("UICorner")
intervalCorner.Parent = intervalBox
intervalCorner.CornerRadius = UDim.new(0, 6)
intervalBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(intervalBox.Text)
        if val and val > 0 then
            autoGoalInterval = val
            _G.FIFA_AutoInterval = val
            intervalLabel.Text = "⏱️ Интервал (сек): " .. autoGoalInterval
            if autoGoalEnabled then
                toggleAutoGoal(false)
                toggleAutoGoal(true) -- перезапускаем с новым интервалом
            end
        else
            intervalBox.Text = tostring(autoGoalInterval)
        end
    end
end)

-- ===== Вкладка 3: Дополнительно =====
local extraContent = contentFrames[3]

-- Сброс настроек
createButton(extraContent, "🔄 Сбросить скорость (16)", 10, Color3.fromRGB(70, 70, 100), function()
    setSpeed(16)
    speedLabel.Text = "🏃 Скорость бега: 16"
    speedSlider.Text = "16"
end)

createButton(extraContent, "🎯 Респавн мяча (сбросить позицию)", 60, Color3.fromRGB(70, 100, 150), function()
    local ball = findBall()
    if ball then
        ball.Position = Vector3.new(0, 5, 0)
        ball.Velocity = Vector3.new(0, 0, 0)
        print("Мяч сброшен в центр.")
    end
end)

createButton(extraContent, "📋 Вывести ID всех игроков", 110, Color3.fromRGB(100, 70, 150), function()
    for _, p in ipairs(game.Players:GetPlayers()) do
        print(p.Name .. " (ID: " .. p.UserId .. ")")
    end
end)

createButton(extraContent, "❌ Выгрузить скрипт", 160, Color3.fromRGB(150, 50, 50), function()
    gui:Destroy()
    print("Скрипт выгружен. Нажмите F для повторной загрузки (если скрипт ещё активен).")
end)

-- Информация
local infoLabel = Instance.new("TextLabel")
infoLabel.Parent = extraContent
infoLabel.BackgroundTransparency = 1
infoLabel.Size = UDim2.new(1, 0, 0, 60)
infoLabel.Position = UDim2.new(0, 0, 0, 230)
infoLabel.Text = "Горячие клавиши:\nF - меню   |   G - автогол   |   K - удалить вратаря"
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
infoLabel.TextSize = 13
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top

-- ===== Горячие клавиши =====
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        mainFrame.Visible = not mainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.G then
        autoGoal()
    elseif input.KeyCode == Enum.KeyCode.K then
        removeGoalkeeper()
    end
end)

-- ===== Сброс скорости при респавне =====
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    task.wait(0.5)
    setSpeed(currentSpeed)
end)

-- ===== Запуск автогола, если был включён =====
if autoGoalEnabled then
    toggleAutoGoal(true)
end

print("✅ FIFA ULTIMATE скрипт загружен! Нажмите F для открытия меню.")
print("⚡ Используйте на свой страх и риск.")
