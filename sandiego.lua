--[[
    San Diego & Zentx hub
    Автофарм контрабандных колец для игры San Diego Border Roleplay
    Исполнение через loadstring
]]

-- ==================== НАСТРОЙКИ ====================
local Settings = {
    -- Координаты точек (замените на актуальные)
    BuyPoint = Vector3.new(100, 20, 200),      -- точка покупки колец
    SellPoint = Vector3.new(-150, 20, -100),   -- точка сдачи
    -- Промежуточные точки маршрута (для плавного движения)
    RoutePoints = {
        Vector3.new(50, 20, 150),
        Vector3.new(0, 20, 50),
        Vector3.new(-50, 20, -20),
        Vector3.new(-100, 20, -60),
    },
    -- Задержки
    MinDelay = 0.5,
    MaxDelay = 2.0,
    -- Радиус проверки админов
    AdminCheckRadius = 50,
    -- Список админов (по имени или части тега)
    AdminNames = {"Admin", "Owner", "Developer"}, -- пример
    AdminTags = {"Admin", "Owner"},              -- теги в никнейме
    -- Имена/модели грузовиков для поиска
    TruckKeywords = {"Truck", "грузовик", "Lorry"},
    -- Время ожидания после действий (сек)
    WaitAfterAction = 1,
    -- Количество точек маршрута за один проход
}

-- ==================== СЛУЖЕБНЫЕ ФУНКЦИИ ====================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser") -- для анти-АФК

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local isRunning = false
local currentStage = "Остановлен" -- для GUI
local guiFrame = nil

-- Случайная задержка
local function randomWait()
    local delay = math.random() * (Settings.MaxDelay - Settings.MinDelay) + Settings.MinDelay
    task.wait(delay)
end

-- Безопасное получение объекта
local function safeGet(service, name)
    local success, obj = pcall(function()
        return game:GetService(service)
    end)
    if success and obj then
        return obj
    end
    return nil
end

-- Поиск ближайшего грузовика
local function findNearestTruck(origin)
    local closest = nil
    local minDist = math.huge
    -- Ищем все объекты в Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Vehicle") or obj:IsA("Part") then
            local name = obj.Name:lower()
            local match = false
            for _, keyword in ipairs(Settings.TruckKeywords) do
                if name:find(keyword:lower()) then
                    match = true
                    break
                end
            end
            if match then
                local pos = obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position or 
                            (obj:IsA("Part") and obj.Position)
                if pos then
                    local dist = (pos - origin).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = obj
                    end
                end
            end
        end
    end
    return closest
end

-- Проверка наличия админов рядом
local function isAdminNearby()
    local origin = rootPart.Position
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - origin).Magnitude
                if dist <= Settings.AdminCheckRadius then
                    local name = plr.Name
                    for _, admin in ipairs(Settings.AdminNames) do
                        if name:find(admin) then
                            return true
                        end
                    end
                    for _, tag in ipairs(Settings.AdminTags) do
                        if name:find(tag) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Анти-АФК: имитация движений мыши или нажатий
local function antiAFK()
    pcall(function()
        -- Имитация движения мыши
        if VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(math.random(0, 1920), math.random(0, 1080)))
            VirtualUser:ClickButton2(Vector2.new(math.random(0, 1920), math.random(0, 1080)))
        end
        -- или простое нажатие клавиш
        if UserInputService then
            -- симуляция нажатия W и S (не работает в всех случаях)
        end
    end)
end

-- ==================== ОСНОВНЫЕ ДЕЙСТВИЯ ====================

-- Покупка колец
local function buyRings()
    currentStage = "Покупка колец"
    -- Телепортируемся к точке покупки
    rootPart.CFrame = CFrame.new(Settings.BuyPoint)
    task.wait(0.5)
    -- Здесь можно добавить взаимодействие с NPC (например, нажать E)
    -- Для простоты просто ждём
    randomWait()
    antiAFK()
    return true
end

-- Поиск грузовика и посадка
local function getInTruck()
    currentStage = "Поиск грузовика"
    local truck = findNearestTruck(rootPart.Position)
    if not truck then
        currentStage = "Грузовик не найден"
        return false
    end

    -- Ищем сиденье внутри грузовика
    local seat = nil
    for _, child in pairs(truck:GetDescendants()) do
        if child:IsA("VehicleSeat") or child:IsA("Seat") then
            seat = child
            break
        end
    end

    if not seat then
        currentStage = "Нет сиденья в грузовике"
        return false
    end

    -- Садимся (телепортируем персонажа на сиденье)
    rootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0) -- небольшое смещение
    task.wait(0.5)
    humanoid.Sit = true
    randomWait()
    antiAFK()
    return true
end

-- Движение по маршруту к точке сдачи
local function driveToSell()
    currentStage = "Движение к сдаче"
    local truck = findNearestTruck(rootPart.Position)
    if not truck then
        currentStage = "Грузовик потерян"
        return false
    end

    -- Собираем все точки маршрута (включая финальную)
    local allPoints = {}
    for _, pt in ipairs(Settings.RoutePoints) do
        table.insert(allPoints, pt)
    end
    table.insert(allPoints, Settings.SellPoint)

    -- Перемещаем грузовик по точкам
    for i, target in ipairs(allPoints) do
        if not isRunning then return false end
        -- Проверка админов
        while isAdminNearby() do
            currentStage = "Админ рядом, пауза"
            task.wait(1)
            if not isRunning then return false end
        end

        -- Перемещаем основной часть грузовика (PrimaryPart или находим первую часть)
        local movePart = truck.PrimaryPart
        if not movePart then
            -- если нет PrimaryPart, берём первый найденный Part
            for _, child in pairs(truck:GetDescendants()) do
                if child:IsA("Part") then
                    movePart = child
                    break
                end
            end
        end
        if not movePart then
            currentStage = "Нет части для перемещения"
            return false
        end

        -- Перемещаем грузовик к следующей точке
        movePart.CFrame = CFrame.new(target)
        -- Ждём между точками
        randomWait()
        antiAFK()
        -- Обновляем интерфейс
        currentStage = string.format("Движение %d/%d", i, #allPoints)
    end

    return true
end

-- Сдача колец
local function sellRings()
    currentStage = "Сдача колец"
    -- Телепортируемся к точке сдачи (или просто ждём)
    rootPart.CFrame = CFrame.new(Settings.SellPoint)
    task.wait(0.5)
    randomWait()
    antiAFK()
    return true
end

-- ==================== ОСНОВНОЙ ЦИКЛ ====================
local function mainLoop()
    while isRunning do
        -- Проверка админов перед началом этапа
        while isAdminNearby() do
            currentStage = "Админ рядом, пауза"
            task.wait(1)
            if not isRunning then return end
        end

        -- Этап 1: Покупка
        local success = pcall(buyRings)
        if not success or not isRunning then break end
        randomWait()

        -- Этап 2: Поиск грузовика и посадка
        success = pcall(getInTruck)
        if not success or not isRunning then break end
        randomWait()

        -- Этап 3: Движение
        success = pcall(driveToSell)
        if not success or not isRunning then break end
        randomWait()

        -- Этап 4: Сдача
        success = pcall(sellRings)
        if not success or not isRunning then break end
        randomWait()

        -- Небольшая пауза между циклами
        task.wait(Settings.WaitAfterAction)
    end
    currentStage = "Остановлен"
end

-- ==================== GUI ====================
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SanDiegoZentxHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "San Diego & Zentx hub"
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame

    -- Статус
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 35)
    statusLabel.Text = "Статус: Остановлен"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    -- Этап
    local stageLabel = Instance.new("TextLabel")
    stageLabel.Size = UDim2.new(1, -20, 0, 25)
    stageLabel.Position = UDim2.new(0, 10, 0, 65)
    stageLabel.Text = "Этап: Ожидание"
    stageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    stageLabel.BackgroundTransparency = 1
    stageLabel.Font = Enum.Font.Gotham
    stageLabel.TextSize = 14
    stageLabel.TextXAlignment = Enum.TextXAlignment.Left
    stageLabel.Parent = frame

    -- Кнопка Старт
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0, 100, 0, 30)
    startBtn.Position = UDim2.new(0, 20, 0, 110)
    startBtn.Text = "Старт"
    startBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.Font = Enum.Font.Gotham
    startBtn.TextSize = 16
    startBtn.Parent = frame

    -- Кнопка Стоп
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0, 100, 0, 30)
    stopBtn.Position = UDim2.new(0, 180, 0, 110)
    stopBtn.Text = "Стоп"
    stopBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.Font = Enum.Font.Gotham
    stopBtn.TextSize = 16
    stopBtn.Parent = frame

    -- Функции кнопок
    startBtn.MouseButton1Click:Connect(function()
        if not isRunning then
            isRunning = true
            currentStage = "Запуск..."
            statusLabel.Text = "Статус: Работает"
            -- Запускаем основной цикл в отдельном потоке
            task.spawn(function()
                pcall(mainLoop)
                isRunning = false
                statusLabel.Text = "Статус: Остановлен"
                currentStage = "Остановлен"
                stageLabel.Text = "Этап: Остановлен"
            end)
        end
    end)

    stopBtn.MouseButton1Click:Connect(function()
        isRunning = false
        statusLabel.Text = "Статус: Остановлен"
        currentStage = "Остановлен"
        stageLabel.Text = "Этап: Остановлен"
    end)

    -- Обновление GUI через Heartbeat
    RunService.Heartbeat:Connect(function()
        if statusLabel then
            statusLabel.Text = (isRunning and "Статус: Работает" or "Статус: Остановлен")
        end
        if stageLabel then
            stageLabel.Text = "Этап: " .. currentStage
        end
    end)

    guiFrame = frame
end

-- ==================== ЗАПУСК ====================
-- Создаём GUI при загрузке
pcall(createGUI)

-- Горячая клавиша для остановки (например, F6)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        isRunning = not isRunning
        if not isRunning then
            currentStage = "Остановлен по клавише"
            if guiFrame then
                local status = guiFrame:FindFirstChild("StatusLabel") -- нужно найти
                -- Но проще обновить через глобальные переменные
            end
        end
    end
end)

-- Выводим сообщение в консоль
print("San Diego & Zentx hub загружен. Используйте GUI для управления.")
