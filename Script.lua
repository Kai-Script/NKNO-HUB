pcall(function()
    --[[
        nkno$ Hub — улучшенная версия
        Функции:
        - Farm: автоматическое вставание на Admin Treadmill
        - Visuals: Fullbright, No Fog, Player ESP, X-Ray
        - Sounds: смена звуковых пакетов для шагов
        Открытие по клавише Insert.
        Все функции включаются/отключаются тогглами.
    ]]

    -- Подключение сервисов
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer
    local mouse = LocalPlayer:GetMouse()

    -- Переменные состояния
    local isMenuOpen = false
    local isMinimized = false
    local accentColor = Color3.fromRGB(0, 150, 255)

    -- Состояния функций
    local farmTreadmillActive = false
    local fullbrightActive = false
    local noFogActive = false
    local espActive = false
    local xrayActive = false
    local soundPackSelected = "Default"

    -- Хранилище для ESP
    local espHighlights = {}
    local espColor = Color3.fromRGB(255, 0, 0) -- по умолчанию красный

    -- Хранилище для X-Ray (оригинальные прозрачности)
    local originalTransparencies = {}

    -- Список цветов для ESP (для выпадающего списка)
    local espColors = {
        {Name = "Красный", Color = Color3.fromRGB(255, 0, 0)},
        {Name = "Зелёный", Color = Color3.fromRGB(0, 255, 0)},
        {Name = "Синий", Color = Color3.fromRGB(0, 0, 255)},
        {Name = "Жёлтый", Color = Color3.fromRGB(255, 255, 0)},
        {Name = "Фиолетовый", Color = Color3.fromRGB(255, 0, 255)},
        {Name = "Оранжевый", Color = Color3.fromRGB(255, 165, 0)},
        {Name = "Белый", Color = Color3.fromRGB(255, 255, 255)},
    }

    -- Звуковые пакеты (SoundId для шагов)
    -- В реальных играх ID могут отличаться, здесь примеры (заглушки)
    local soundPacks = {
        Default = "rbxassetid://9120373785",
        Candy = "rbxassetid://9120373786",
        Chocolate = "rbxassetid://9120373787",
        Premium = "rbxassetid://9120373788",
        ["bbno$ Pack"] = "rbxassetid://9120373789",
        Water = "rbxassetid://9120373790",
        Bubble = "rbxassetid://9120373791",
    }

    -- Локализация
    local lang = "EN"
    local Locales = {
        RU = {
            Title = "nkno$ hub",
            FarmTab = "Ферма",
            VisualsTab = "Визуалы",
            SoundsTab = "Звуки",
            TreadmillToggle = "Admin Treadmill",
            TreadmillOn = "Включено",
            TreadmillOff = "Выключено",
            FullbrightToggle = "Fullbright",
            NoFogToggle = "No Fog",
            ESPToggle = "Player ESP",
            ESPColor = "Цвет ESP",
            XRayToggle = "X-Ray Walls",
            SoundPackLabel = "Пакет звуков",
            SoundPackDefault = "Обычный",
            SoundPackCandy = "Конфетный",
            SoundPackChocolate = "Шоколадный",
            SoundPackPremium = "Премиум",
            SoundPackBbno = "bbno$ Pack",
            SoundPackWater = "Вода",
            SoundPackBubble = "Пузыри",
            TreadmillNotFound = "Admin Treadmill не найден, ожидание...",
            TreadmillFound = "Admin Treadmill найден, телепортация...",
            TreadmillTeleport = "Телепортация на дорожку",
        },
        EN = {
            Title = "nkno$ hub",
            FarmTab = "Farm",
            VisualsTab = "Visuals",
            SoundsTab = "Sounds",
            TreadmillToggle = "Admin Treadmill",
            TreadmillOn = "On",
            TreadmillOff = "Off",
            FullbrightToggle = "Fullbright",
            NoFogToggle = "No Fog",
            ESPToggle = "Player ESP",
            ESPColor = "ESP Color",
            XRayToggle = "X-Ray Walls",
            SoundPackLabel = "Sound Pack",
            SoundPackDefault = "Default",
            SoundPackCandy = "Candy",
            SoundPackChocolate = "Chocolate",
            SoundPackPremium = "Premium",
            SoundPackBbno = "bbno$ Pack",
            SoundPackWater = "Water",
            SoundPackBubble = "Bubble",
            TreadmillNotFound = "Admin Treadmill not found, waiting...",
            TreadmillFound = "Admin Treadmill found, teleporting...",
            TreadmillTeleport = "Teleport to treadmill",
        }
    }

    local function L(key) return Locales[lang][key] end

    -- Функции для работы с Admin Treadmill
    local function getTreadmill()
        -- Ищем объект с именем "Admin Treadmill" в workspace
        return workspace:FindFirstChild("Admin Treadmill")
    end

    local function teleportToTreadmill()
        local treadmill = getTreadmill()
        if not treadmill then
            warn(L("TreadmillNotFound"))
            return false
        end
        local char = LocalPlayer.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        -- Получаем позицию дорожки (используем её позицию)
        local pos = treadmill.Position
        -- Поднимаем персонажа чуть выше поверхности (+2 по Y)
        pos = pos + Vector3.new(0, 2, 0)
        hrp.CFrame = CFrame.new(pos)
        return true
    end

    -- Цикл для Treadmill (запускается в отдельном потоке)
    local treadmillLoopConnection = nil
    local function startTreadmillLoop()
        if treadmillLoopConnection then return end
        treadmillLoopConnection = RunService.Heartbeat:Connect(function()
            if not farmTreadmillActive then
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local treadmill = getTreadmill()
            if not treadmill then
                -- Если дорожка не найдена, ничего не делаем, ждём
                return
            end

            local dist = (hrp.Position - treadmill.Position).Magnitude
            if dist > 10 then
                -- Если отошли далеко, телепортируем обратно
                teleportToTreadmill()
            end
        end)
    end

    local function stopTreadmillLoop()
        if treadmillLoopConnection then
            treadmillLoopConnection:Disconnect()
            treadmillLoopConnection = nil
        end
    end

    -- Функции Visuals
    -- Fullbright
    local function applyFullbright(state)
        if state then
            Lighting.Brightness = 10
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000 -- чтобы туман не мешал
        else
            -- Восстанавливаем настройки (примерные значения по умолчанию)
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
        end
    end

    -- No Fog
    local function applyNoFog(state)
        if state then
            Lighting.FogEnd = 0
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end
    end

    -- Player ESP
    local function updateESP()
        -- Удаляем старые хайлайты
        for _, highlight in pairs(espHighlights) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
        espHighlights = {}

        if not espActive then return end

        -- Добавляем хайлайты на всех игроков (кроме себя)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = char
                    highlight.FillColor = espColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    table.insert(espHighlights, highlight)
                end
            end
        end
    end

    -- Отслеживаем появление новых игроков для ESP
    local function setupESPWatcher()
        Players.PlayerAdded:Connect(function(player)
            if espActive then
                player.CharacterAdded:Connect(function(char)
                    task.wait(0.5) -- ждём, пока персонаж загрузится
                    if espActive and player ~= LocalPlayer then
                        local highlight = Instance.new("Highlight")
                        highlight.Parent = char
                        highlight.FillColor = espColor
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.3
                        highlight.OutlineTransparency = 0
                        table.insert(espHighlights, highlight)
                    end
                end)
            end
        end)
    end
    setupESPWatcher()

    -- X-Ray Walls
    local function applyXRay(state)
        if state then
            -- Сохраняем текущие прозрачности и устанавливаем 0.5 для всех частей (кроме игроков)
            originalTransparencies = {}
            local parts = workspace:GetDescendants()
            for _, obj in ipairs(parts) do
                if obj:IsA("BasePart") then
                    -- Проверяем, не является ли часть частью персонажа игрока
                    local isPlayerPart = false
                    local char = obj:FindFirstAncestorOfClass("Model")
                    if char and Players:GetPlayerFromCharacter(char) then
                        isPlayerPart = true
                    end
                    if not isPlayerPart then
                        originalTransparencies[obj] = obj.Transparency
                        obj.Transparency = 0.5
                    end
                end
            end
        else
            -- Восстанавливаем прозрачности
            for part, trans in pairs(originalTransparencies) do
                if part and part.Parent then
                    part.Transparency = trans
                end
            end
            originalTransparencies = {}
        end
    end

    -- Отслеживаем добавление новых частей для X-Ray
    local xrayWatcher
    local function setupXRayWatcher()
        if xrayWatcher then xrayWatcher:Disconnect() end
        xrayWatcher = workspace.DescendantAdded:Connect(function(obj)
            if xrayActive and obj:IsA("BasePart") then
                -- Проверяем, не часть ли это игрока
                local isPlayerPart = false
                local char = obj:FindFirstAncestorOfClass("Model")
                if char and Players:GetPlayerFromCharacter(char) then
                    isPlayerPart = true
                end
                if not isPlayerPart then
                    originalTransparencies[obj] = obj.Transparency
                    obj.Transparency = 0.5
                end
            end
        end)
    end
    setupXRayWatcher()

    -- Функции для звуков
    local function applySoundPack(packName)
        soundPackSelected = packName
        local soundId = soundPacks[packName] or soundPacks["Default"]

        -- Ищем все звуки в игре, которые могут быть шагами
        -- Обычно они находятся в Character'ах игроков и имеют имя "Footstep" или подобное
        local allSounds = workspace:GetDescendants()
        for _, obj in ipairs(allSounds) do
            if obj:IsA("Sound") then
                -- Проверяем имя, содержащее "step", "foot", "walk" и т.п.
                local name = obj.Name:lower()
                if name:find("step") or name:find("foot") or name:find("walk") or name:find("run") then
                    obj.SoundId = soundId
                end
            end
        end

        -- Также подписываемся на новые звуки (для вновь появляющихся персонажей)
        -- Отключаем старый обработчик, если есть
        if soundWatcher then soundWatcher:Disconnect() end
        soundWatcher = workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("Sound") then
                local name = obj.Name:lower()
                if name:find("step") or name:find("foot") or name:find("walk") or name:find("run") then
                    obj.SoundId = soundId
                end
            end
        end)
    end
    local soundWatcher = nil

    -- Создание GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "nkno$ hub"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Фоновое затемнение (тень)
    local ShadowFrame = Instance.new("Frame")
    ShadowFrame.Name = "ShadowFrame"
    ShadowFrame.Parent = ScreenGui
    ShadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ShadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ShadowFrame.Position = UDim2.new(0.5, 4, 0.5, 6)
    ShadowFrame.Size = UDim2.new(0, 646, 0, 426)
    ShadowFrame.BackgroundTransparency = 0.45
    ShadowFrame.Visible = false
    Instance.new("UICorner", ShadowFrame).CornerRadius = UDim.new(0, 16)
    local ShadowScale = Instance.new("UIScale", ShadowFrame)
    ShadowScale.Scale = 0.3

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 16)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 640, 0, 420)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Visible = false
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

    local MainScale = Instance.new("UIScale", MainFrame)
    MainScale.Scale = 0.3

    -- Заголовок и кнопки свернуть/закрыть (как в прошлом коде)
    local TopControls = Instance.new("Frame")
    TopControls.Parent = MainFrame
    TopControls.BackgroundTransparency = 1
    TopControls.Position = UDim2.new(1, -75, 0, 14)
    TopControls.Size = UDim2.new(0, 65, 0, 26)
    TopControls.ZIndex = 20

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TopControls
    CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 18, 22)
    CloseBtn.Position = UDim2.new(1, -26, 0, 0)
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(250, 80, 80)
    CloseBtn.TextSize = 18
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(function()
        -- Отключаем все активные функции
        farmTreadmillActive = false
        stopTreadmillLoop()
        if fullbrightActive then fullbrightActive = false; applyFullbright(false) end
        if noFogActive then noFogActive = false; applyNoFog(false) end
        if espActive then espActive = false; updateESP() end
        if xrayActive then xrayActive = false; applyXRay(false) end
        toggleMenu(false)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TopControls
    MinBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    MinBtn.Position = UDim2.new(1, -58, 0, 0)
    MinBtn.Size = UDim2.new(0, 26, 0, 26)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
    MinBtn.TextSize = 18
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 640, 0, 52)}):Play()
            TweenService:Create(ShadowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 646, 0, 58)}):Play()
            MinBtn.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 640, 0, 420)}):Play()
            TweenService:Create(ShadowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 646, 0, 426)}):Play()
            MinBtn.Text = "-"
        end
    end)

    -- Боковая панель с вкладками
    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    Sidebar.BackgroundTransparency = 0.1
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

    local Title = Instance.new("TextLabel")
    Title.Parent = Sidebar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 16)
    Title.Size = UDim2.new(1, 0, 0, 26)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "nkno$ hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
    TitleGradient.Parent = Title

    local SepLine = Instance.new("Frame")
    SepLine.Parent = Sidebar
    SepLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SepLine.Position = UDim2.new(0.1, 0, 0, 52)
    SepLine.Size = UDim2.new(0.8, 0, 0, 1)
    local SepGradient = Instance.new("UIGradient")
    SepGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)), ColorSequenceKeypoint.new(0.5, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))})
    SepGradient.Parent = SepLine

    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 12, 0, 72)
    TabContainer.Size = UDim2.new(1, -24, 1, -85)

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 10)

    -- Контентная область
    local ContentArea = Instance.new("Frame")
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = false
    ContentArea.Position = UDim2.new(0, 185, 0, 15)
    ContentArea.Size = UDim2.new(1, -200, 1, -30)

    -- Создаём страницы вкладок
    local FarmPage = Instance.new("Frame")
    FarmPage.Parent = ContentArea
    FarmPage.BackgroundTransparency = 1
    FarmPage.Size = UDim2.new(1, 0, 1, 0)
    FarmPage.Visible = true

    local VisualsPage = Instance.new("Frame")
    VisualsPage.Parent = ContentArea
    VisualsPage.BackgroundTransparency = 1
    VisualsPage.Size = UDim2.new(1, 0, 1, 0)
    VisualsPage.Visible = false

    local SoundsPage = Instance.new("Frame")
    SoundsPage.Parent = ContentArea
    SoundsPage.BackgroundTransparency = 1
    SoundsPage.Size = UDim2.new(1, 0, 1, 0)
    SoundsPage.Visible = false

    -- Функция создания кнопки вкладки
    local tabButtons = {}
    local function createTabButton(text, page)
        local btn = Instance.new("TextButton")
        btn.Parent = TabContainer
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        btn.BackgroundTransparency = 0.15
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Font = Enum.Font.GothamSemibold
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(150, 150, 170)
        btn.TextSize = 14
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(tabButtons) do
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 28), TextColor3 = Color3.fromRGB(150, 150, 170)}):Play()
            end
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = accentColor, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            FarmPage.Visible = (page == FarmPage)
            VisualsPage.Visible = (page == VisualsPage)
            SoundsPage.Visible = (page == SoundsPage)
        end)
        table.insert(tabButtons, btn)
        return btn
    end

    local farmTabBtn = createTabButton(L("FarmTab"), FarmPage)
    local visualsTabBtn = createTabButton(L("VisualsTab"), VisualsPage)
    local soundsTabBtn = createTabButton(L("SoundsTab"), SoundsPage)

    -- По умолчанию выбираем первую вкладку
    farmTabBtn.BackgroundColor3 = accentColor
    farmTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- ================== Вкладка FARM ==================
    local farmContainer = Instance.new("Frame")
    farmContainer.Parent = FarmPage
    farmContainer.BackgroundTransparency = 1
    farmContainer.Size = UDim2.new(0.96, 0, 1, 0)

    -- Переключатель Admin Treadmill
    local TreadmillFrame = Instance.new("Frame")
    TreadmillFrame.Parent = farmContainer
    TreadmillFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
    TreadmillFrame.BackgroundTransparency = 0.15
    TreadmillFrame.Position = UDim2.new(0, 0, 0, 10)
    TreadmillFrame.Size = UDim2.new(1, 0, 0, 56)
    Instance.new("UICorner", TreadmillFrame).CornerRadius = UDim.new(0, 10)

    local TreadmillLabel = Instance.new("TextLabel")
    TreadmillLabel.Parent = TreadmillFrame
    TreadmillLabel.BackgroundTransparency = 1
    TreadmillLabel.Position = UDim2.new(0, 16, 0, 0)
    TreadmillLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TreadmillLabel.Font = Enum.Font.GothamBold
    TreadmillLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TreadmillLabel.TextSize = 15
    TreadmillLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TreadmillSwitchBG = Instance.new("TextButton")
    TreadmillSwitchBG.Parent = TreadmillFrame
    TreadmillSwitchBG.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    TreadmillSwitchBG.Position = UDim2.new(1, -65, 0.5, -14)
    TreadmillSwitchBG.Size = UDim2.new(0, 50, 0, 28)
    TreadmillSwitchBG.Text = ""
    Instance.new("UICorner", TreadmillSwitchBG).CornerRadius = UDim.new(0, 14)

    local TreadmillSwitchDot = Instance.new("Frame")
    TreadmillSwitchDot.Parent = TreadmillSwitchBG
    TreadmillSwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TreadmillSwitchDot.Position = UDim2.new(0, 3, 0.5, -11)
    TreadmillSwitchDot.Size = UDim2.new(0, 22, 0, 22)
    Instance.new("UICorner", TreadmillSwitchDot).CornerRadius = UDim.new(0, 11)

    TreadmillSwitchBG.MouseButton1Click:Connect(function()
        farmTreadmillActive = not farmTreadmillActive
        if farmTreadmillActive then
            TweenService:Create(TreadmillSwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(34, 197, 94)}):Play()
            TweenService:Create(TreadmillSwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 25, 0.5, -11)}):Play()
            -- Запускаем цикл
            startTreadmillLoop()
            -- Сразу телепортируем, если дорожка есть
            local success = teleportToTreadmill()
            if success then
                print(L("TreadmillFound"))
            else
                warn(L("TreadmillNotFound"))
            end
        else
            TweenService:Create(TreadmillSwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            TweenService:Create(TreadmillSwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -11)}):Play()
            stopTreadmillLoop()
        end
    end)

    -- ================== Вкладка VISUALS ==================
    local visualsContainer = Instance.new("Frame")
    visualsContainer.Parent = VisualsPage
    visualsContainer.BackgroundTransparency = 1
    visualsContainer.Size = UDim2.new(0.96, 0, 1, 0)

    -- Функция создания переключателя в визуалах
    local function createVisualToggle(parent, labelText, yPos, toggleCallback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
        frame.BackgroundTransparency = 0.15
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.Size = UDim2.new(1, 0, 0, 48)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 16, 0, 0)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = labelText

        local switchBG = Instance.new("TextButton")
        switchBG.Parent = frame
        switchBG.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        switchBG.Position = UDim2.new(1, -65, 0.5, -14)
        switchBG.Size = UDim2.new(0, 50, 0, 28)
        switchBG.Text = ""
        Instance.new("UICorner", switchBG).CornerRadius = UDim.new(0, 14)

        local switchDot = Instance.new("Frame")
        switchDot.Parent = switchBG
        switchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        switchDot.Position = UDim2.new(0, 3, 0.5, -11)
        switchDot.Size = UDim2.new(0, 22, 0, 22)
        Instance.new("UICorner", switchDot).CornerRadius = UDim.new(0, 11)

        local state = false
        switchBG.MouseButton1Click:Connect(function()
            state = not state
            if state then
                TweenService:Create(switchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(34, 197, 94)}):Play()
                TweenService:Create(switchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 25, 0.5, -11)}):Play()
            else
                TweenService:Create(switchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
                TweenService:Create(switchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -11)}):Play()
            end
            toggleCallback(state)
        end)

        return {frame = frame, label = label, switchBG = switchBG, switchDot = switchDot, getState = function() return state end}
    end

    -- Fullbright
    local fullbrightToggle = createVisualToggle(visualsContainer, L("FullbrightToggle"), 10, function(state)
        fullbrightActive = state
        applyFullbright(state)
    end)

    -- No Fog
    local noFogToggle = createVisualToggle(visualsContainer, L("NoFogToggle"), 68, function(state)
        noFogActive = state
        applyNoFog(state)
    end)

    -- ESP
    local espToggle = createVisualToggle(visualsContainer, L("ESPToggle"), 126, function(state)
        espActive = state
        updateESP()
    end)

    -- Выпадающий список для цвета ESP
    local espColorFrame = Instance.new("Frame")
    espColorFrame.Parent = visualsContainer
    espColorFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
    espColorFrame.BackgroundTransparency = 0.15
    espColorFrame.Position = UDim2.new(0, 0, 0, 184)
    espColorFrame.Size = UDim2.new(1, 0, 0, 44)
    Instance.new("UICorner", espColorFrame).CornerRadius = UDim.new(0, 10)

    local espColorLabel = Instance.new("TextLabel")
    espColorLabel.Parent = espColorFrame
    espColorLabel.BackgroundTransparency = 1
    espColorLabel.Position = UDim2.new(0, 16, 0, 0)
    espColorLabel.Size = UDim2.new(0.5, 0, 1, 0)
    espColorLabel.Font = Enum.Font.GothamSemibold
    espColorLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    espColorLabel.TextSize = 14
    espColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    espColorLabel.Text = L("ESPColor")

    local espColorDropdown = Instance.new("TextButton")
    espColorDropdown.Parent = espColorFrame
    espColorDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    espColorDropdown.Position = UDim2.new(0.55, 0, 0.5, -14)
    espColorDropdown.Size = UDim2.new(0.4, 0, 0, 28)
    espColorDropdown.Font = Enum.Font.GothamSemibold
    espColorDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    espColorDropdown.TextSize = 13
    espColorDropdown.Text = espColors[1].Name
    Instance.new("UICorner", espColorDropdown).CornerRadius = UDim.new(0, 6)

    local espColorList = Instance.new("ScrollingFrame")
    espColorList.Parent = espColorFrame
    espColorList.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    espColorList.BackgroundTransparency = 0.1
    espColorList.Position = UDim2.new(0.55, 0, 1, 2)
    espColorList.Size = UDim2.new(0.4, 0, 0, 100)
    espColorList.Visible = false
    espColorList.ZIndex = 10
    espColorList.CanvasSize = UDim2.new(0, 0, 0, 0)
    espColorList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    espColorList.ScrollBarThickness = 4
    espColorList.BorderSizePixel = 0
    Instance.new("UICorner", espColorList).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", espColorList).Color = Color3.fromRGB(45, 45, 60)

    local espColorListLayout = Instance.new("UIListLayout")
    espColorListLayout.Parent = espColorList
    espColorListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    espColorListLayout.Padding = UDim.new(0, 4)

    local espColorPadding = Instance.new("UIPadding")
    espColorPadding.Parent = espColorList
    espColorPadding.PaddingTop = UDim.new(0, 4)
    espColorPadding.PaddingLeft = UDim.new(0, 4)
    espColorPadding.PaddingRight = UDim.new(0, 4)

    -- Заполняем список цветов
    for _, colorData in ipairs(espColors) do
        local btn = Instance.new("TextButton")
        btn.Parent = espColorList
        btn.BackgroundColor3 = colorData.Color
        btn.BackgroundTransparency = 0.2
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Text = colorData.Name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamSemibold
        btn.ZIndex = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            espColor = colorData.Color
            espColorDropdown.Text = colorData.Name
            espColorList.Visible = false
            if espActive then updateESP() end
        end)
    end

    espColorDropdown.MouseButton1Click:Connect(function()
        espColorList.Visible = not espColorList.Visible
    end)

    -- X-Ray
    local xrayToggle = createVisualToggle(visualsContainer, L("XRayToggle"), 238, function(state)
        xrayActive = state
        applyXRay(state)
    end)

    -- ================== Вкладка SOUNDS ==================
    local soundsContainer = Instance.new("Frame")
    soundsContainer.Parent = SoundsPage
    soundsContainer.BackgroundTransparency = 1
    soundsContainer.Size = UDim2.new(0.96, 0, 1, 0)

    -- Выпадающий список звуковых пакетов
    local soundPackFrame = Instance.new("Frame")
    soundPackFrame.Parent = soundsContainer
    soundPackFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
    soundPackFrame.BackgroundTransparency = 0.15
    soundPackFrame.Position = UDim2.new(0, 0, 0, 10)
    soundPackFrame.Size = UDim2.new(1, 0, 0, 56)
    Instance.new("UICorner", soundPackFrame).CornerRadius = UDim.new(0, 10)

    local soundPackLabel = Instance.new("TextLabel")
    soundPackLabel.Parent = soundPackFrame
    soundPackLabel.BackgroundTransparency = 1
    soundPackLabel.Position = UDim2.new(0, 16, 0, 0)
    soundPackLabel.Size = UDim2.new(0.5, 0, 1, 0)
    soundPackLabel.Font = Enum.Font.GothamSemibold
    soundPackLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    soundPackLabel.TextSize = 14
    soundPackLabel.TextXAlignment = Enum.TextXAlignment.Left
    soundPackLabel.Text = L("SoundPackLabel")

    local soundPackDropdown = Instance.new("TextButton")
    soundPackDropdown.Parent = soundPackFrame
    soundPackDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    soundPackDropdown.Position = UDim2.new(0.55, 0, 0.5, -14)
    soundPackDropdown.Size = UDim2.new(0.4, 0, 0, 28)
    soundPackDropdown.Font = Enum.Font.GothamSemibold
    soundPackDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    soundPackDropdown.TextSize = 13
    soundPackDropdown.Text = "Default"
    Instance.new("UICorner", soundPackDropdown).CornerRadius = UDim.new(0, 6)

    local soundPackList = Instance.new("ScrollingFrame")
    soundPackList.Parent = soundPackFrame
    soundPackList.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    soundPackList.BackgroundTransparency = 0.1
    soundPackList.Position = UDim2.new(0.55, 0, 1, 2)
    soundPackList.Size = UDim2.new(0.4, 0, 0, 120)
    soundPackList.Visible = false
    soundPackList.ZIndex = 10
    soundPackList.CanvasSize = UDim2.new(0, 0, 0, 0)
    soundPackList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    soundPackList.ScrollBarThickness = 4
    soundPackList.BorderSizePixel = 0
    Instance.new("UICorner", soundPackList).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", soundPackList).Color = Color3.fromRGB(45, 45, 60)

    local soundPackListLayout = Instance.new("UIListLayout")
    soundPackListLayout.Parent = soundPackList
    soundPackListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    soundPackListLayout.Padding = UDim.new(0, 4)

    local soundPackPadding = Instance.new("UIPadding")
    soundPackPadding.Parent = soundPackList
    soundPackPadding.PaddingTop = UDim.new(0, 4)
    soundPackPadding.PaddingLeft = UDim.new(0, 4)
    soundPackPadding.PaddingRight = UDim.new(0, 4)

    -- Список пакетов для отображения
    local packNames = {"Default", "Candy", "Chocolate", "Premium", "bbno$ Pack", "Water", "Bubble"}
    for _, name in ipairs(packNames) do
        local btn = Instance.new("TextButton")
        btn.Parent = soundPackList
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.BackgroundTransparency = 0.2
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamSemibold
        btn.ZIndex = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            soundPackSelected = name
            soundPackDropdown.Text = name
            soundPackList.Visible = false
            applySoundPack(name)
        end)
    end

    soundPackDropdown.MouseButton1Click:Connect(function()
        soundPackList.Visible = not soundPackList.Visible
    end)

    -- Применяем пакет по умолчанию
    applySoundPack("Default")

    -- ================== Обработка открытия/закрытия меню ==================
    local function toggleMenu(forceState)
        if forceState ~= nil then
            isMenuOpen = forceState
        else
            isMenuOpen = not isMenuOpen
        end
        if isMenuOpen then
            MainFrame.Visible = true
            if not isMinimized then ShadowFrame.Visible = true end
            TweenService:Create(MainScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 0.8}):Play()
            TweenService:Create(ShadowScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 0.8}):Play()
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

    -- Кнопка-виджет для вызова меню (появляется после выбора языка)
    local ToggleWidget = Instance.new("Frame")
    ToggleWidget.Name = "ToggleWidget"
    ToggleWidget.Parent = ScreenGui
    ToggleWidget.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    ToggleWidget.BackgroundTransparency = 0.15
    ToggleWidget.Position = UDim2.new(0.5, -80, 0.08, 0)
    ToggleWidget.Size = UDim2.new(0, 160, 0, 44)
    ToggleWidget.Visible = false
    Instance.new("UICorner", ToggleWidget).CornerRadius = UDim.new(0, 10)
    local ToggleScale = Instance.new("UIScale", ToggleWidget)
    ToggleScale.Scale = 0.85
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Parent = ToggleWidget
    ToggleStroke.Color = Color3.fromRGB(45, 45, 65)
    ToggleStroke.Thickness = 1.5

    local ToggleLabelText = Instance.new("TextLabel")
    ToggleLabelText.Parent = ToggleWidget
    ToggleLabelText.BackgroundTransparency = 1
    ToggleLabelText.Size = UDim2.new(1, 0, 1, 0)
    ToggleLabelText.Font = Enum.Font.GothamBold
    ToggleLabelText.Text = "nkno$ hub"
    ToggleLabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabelText.TextSize = 17
    local ToggleGradient = Instance.new("UIGradient")
    ToggleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
    ToggleGradient.Parent = ToggleLabelText

    -- Перетаскивание виджета
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
            ToggleWidget.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y)
        end
    end)
    ToggleWidget.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = false
            if tick() - dragStartTime < 0.25 then toggleMenu() end
        end
    end)

    -- Выбор языка (простой, без лишних окон)
    local LangFrame = Instance.new("Frame")
    LangFrame.Name = "LangFrame"
    LangFrame.Parent = ScreenGui
    LangFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    LangFrame.BackgroundTransparency = 0.15
    LangFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LangFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LangFrame.Size = UDim2.new(0, 380, 0, 230)
    LangFrame.Visible = true
    Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0, 14)
    Instance.new("UIStroke", LangFrame).Color = Color3.fromRGB(45, 45, 60)
    local LangScale = Instance.new("UIScale", LangFrame)
    LangScale.Scale = 0.8

    local LangTitle = Instance.new("TextLabel")
    LangTitle.Parent = LangFrame
    LangTitle.BackgroundTransparency = 1
    LangTitle.Position = UDim2.new(0, 0, 0, 25)
    LangTitle.Size = UDim2.new(1, 0, 0, 30)
    LangTitle.Font = Enum.Font.GothamBold
    LangTitle.Text = "Choose language / Выберите язык"
    LangTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LangTitle.TextSize = 17

    local function buildLangButton(emoji, text, posX, langCode)
        local Btn = Instance.new("TextButton")
        Btn.Parent = LangFrame
        Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        Btn.BackgroundTransparency = 0.15
        Btn.Position = UDim2.new(0, posX, 0, 75)
        Btn.Size = UDim2.new(0, 110, 0, 110)
        Btn.Text = ""
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", Btn).Color = Color3.fromRGB(45, 45, 65)
        local EmojiLabel = Instance.new("TextLabel")
        EmojiLabel.Parent = Btn
        EmojiLabel.BackgroundTransparency = 1
        EmojiLabel.Size = UDim2.new(1, 0, 1, 0)
        EmojiLabel.Font = Enum.Font.Gotham
        EmojiLabel.Text = emoji
        EmojiLabel.TextSize = 55
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Parent = Btn
        TextLabel.BackgroundTransparency = 1
        TextLabel.Position = UDim2.new(0, 0, 1, 10)
        TextLabel.Size = UDim2.new(1, 0, 0, 20)
        TextLabel.Font = Enum.Font.GothamSemibold
        TextLabel.Text = text
        TextLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        TextLabel.TextSize = 15
        Btn.MouseButton1Click:Connect(function()
            lang = langCode
            -- Обновляем все тексты
            applyLanguage()
            TweenService:Create(LangScale, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0}):Play()
            task.wait(0.2)
            LangFrame.Visible = false
            ToggleWidget.Visible = true
            toggleMenu(true)
        end)
    end
    buildLangButton("RU", "Русский", 65, "RU")
    buildLangButton("EN", "English", 205, "EN")

    -- Функция обновления текстов
    function applyLanguage()
        Title.Text = L("Title")
        farmTabBtn.Text = L("FarmTab")
        visualsTabBtn.Text = L("VisualsTab")
        soundsTabBtn.Text = L("SoundsTab")
        TreadmillLabel.Text = L("TreadmillToggle")
        fullbrightToggle.label.Text = L("FullbrightToggle")
        noFogToggle.label.Text = L("NoFogToggle")
        espToggle.label.Text = L("ESPToggle")
        espColorLabel.Text = L("ESPColor")
        xrayToggle.label.Text = L("XRayToggle")
        soundPackLabel.Text = L("SoundPackLabel")
        -- Обновляем тексты в выпадающих списках (они статичны, можно оставить как есть)
    end

    applyLanguage()

    -- Горячая клавиша Insert
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            if LangFrame.Visible then return end
            toggleMenu()
        end
    end)

    -- Защита от вылетов при смене персонажа (переподключение циклов)
    LocalPlayer.CharacterAdded:Connect(function()
        if farmTreadmillActive then
            -- Перезапускаем телепортацию
            task.wait(1)
            teleportToTreadmill()
        end
    end)

    print("nkno$ hub загружен! Нажмите Insert для открытия.")
end) -- pcall
