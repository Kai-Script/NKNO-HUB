-- ============================================================
--  NKNO$ HUB ULTIMATE v4.0
--  Киберпанк-дизайн · Загрузочный HUB 15 сек · Перетаскивание
-- ============================================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- ===== КОНФИГ =====
local CONFIG = {
    HubName = "✦ NKNO$ HUB ✦",
    Colors = {
        Background = Color3.fromRGB(8, 8, 20),
        Frame = Color3.fromRGB(18, 22, 40),
        Accent = Color3.fromRGB(0, 255, 210),
        Accent2 = Color3.fromRGB(180, 0, 255),
        Text = Color3.fromRGB(230, 240, 255),
        SubText = Color3.fromRGB(160, 190, 220),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    Size = UDim2.new(0, 600, 0, 540),
    CardHeight = 120,
    LoadDuration = 15, -- секунд
}

-- ===== СОСТОЯНИЕ =====
local Hub = {
    Gui = nil,
    MainFrame = nil,
    Container = nil,
    SearchBox = nil,
    StatusLabel = nil,
    ActiveIndex = 1,
    Scripts = {},
    Cards = {},
    FilteredScripts = {},
    IsDragging = false,
    DragStart = nil,
    DragOffset = nil,
    LoadOverlay = nil,
    IsLoading = false,
}

-- ===== УТИЛИТЫ =====
local function MakeRounded(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function Tween(obj, props, duration, style)
    local t = TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle[style or "Quad"], Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function CreateShadow(instance, size, color, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, size*2, 1, size*2)
    shadow.Position = UDim2.new(0, -size, 0, -size)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045719"
    shadow.ImageColor3 = color or Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = transparency or 0.6
    shadow.Parent = instance
    return shadow
end

-- ===== СПИСОК СКРИПТОВ =====
local Scripts = {
    {
        Name = "⚡ +1 speed keyboard escape",
        Category = "Скорость",
        Description = "Увеличивает скорость персонажа",
        Icon = "⚡",
        Run = function()
            Hub:RunWithLoading("https://raw.githubusercontent.com/Kai-Script/NKNO-HUB/refs/heads/main/script3.lua")
        end
    },
    {
        Name = "🔪 Murder Mystery 2",
        Category = "Игры",
        Description = "Читы для MM2 (авто-аим, ESP и др.)",
        Icon = "🔪",
        Run = function()
            Hub:RunWithLoading("https://raw.githubusercontent.com/Kai-Script/NKNO-HUB/refs/heads/main/script2.lua", true)
        end
    },
    -- Добавляйте свои скрипты сюда
}

-- ===== ОСНОВНЫЕ ФУНКЦИИ =====

function Hub:Init()
    if self.Gui then self.Gui:Destroy() end
    self.Scripts = Scripts
    self.FilteredScripts = {}
    for i = 1, #self.Scripts do table.insert(self.FilteredScripts, i) end
    self.ActiveIndex = 1
    self.Cards = {}
    self.IsLoading = false
    self:CreateGUI()
    self:SetupEvents()
    self:RenderCards()
    self:UpdateStatus("Готов к работе")
end

function Hub:CreateGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NKNO_HUB_ULTIMATE"
    gui.Parent = Player.PlayerGui
    self.Gui = gui

    -- Основное окно
    local main = Instance.new("Frame")
    main.Size = CONFIG.Size
    main.Position = UDim2.new(0.5, -CONFIG.Size.X.Offset/2, 0.5, -CONFIG.Size.Y.Offset/2)
    main.BackgroundColor3 = CONFIG.Colors.Background
    main.BackgroundTransparency = 0.2
    main.BorderColor3 = CONFIG.Colors.Accent
    main.BorderSizePixel = 2
    main.Parent = gui
    MakeRounded(main, 18)
    self.MainFrame = main

    -- Тень
    CreateShadow(main, 30, Color3.fromRGB(0,0,0), 0.8)

    -- Внутренняя подсветка (градиент)
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.BackgroundColor3 = CONFIG.Colors.Accent
    glow.BackgroundTransparency = 0.9
    glow.BorderSizePixel = 0
    glow.Parent = main
    MakeRounded(glow, 18)

    -- ===== ЗАГОЛОВОК (перетаскиваемый) =====
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 55)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main
    self.TitleBar = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.HubName
    title.TextColor3 = CONFIG.Colors.Text
    title.TextScaled = true
    title.Font = Enum.Font.Code
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.4
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSans
    closeBtn.Parent = titleBar
    MakeRounded(closeBtn, 18)
    closeBtn.MouseButton1Click:Connect(function() self:Close() end)
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0.1}, 0.2) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0.4}, 0.2) end)

    -- Подсказка
    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, 0, 0, 25)
    hint.Position = UDim2.new(0, 0, 0, 55)
    hint.BackgroundTransparency = 1
    hint.Text = "ESC → запустить  |  клик → выбрать  |  P → закрыть  |  R → обновить"
    hint.TextColor3 = CONFIG.Colors.SubText
    hint.TextScaled = true
    hint.Font = Enum.Font.SourceSans
    hint.Parent = main

    -- Поиск
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.65, -10, 0, 32)
    searchBox.Position = UDim2.new(0.05, 0, 0.17, 0)
    searchBox.BackgroundColor3 = CONFIG.Colors.Frame
    searchBox.BackgroundTransparency = 0.4
    searchBox.Text = "🔍 Поиск..."
    searchBox.TextColor3 = CONFIG.Colors.Text
    searchBox.TextScaled = true
    searchBox.Font = Enum.Font.SourceSans
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = main
    MakeRounded(searchBox, 8)
    self.SearchBox = searchBox

    -- Кнопка обновления
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 95, 0, 32)
    refreshBtn.Position = UDim2.new(0.75, 0, 0.17, 0)
    refreshBtn.BackgroundColor3 = CONFIG.Colors.Frame
    refreshBtn.BackgroundTransparency = 0.3
    refreshBtn.Text = "⟳ Обновить"
    refreshBtn.TextColor3 = CONFIG.Colors.Text
    refreshBtn.TextScaled = true
    refreshBtn.Font = Enum.Font.SourceSans
    refreshBtn.Parent = main
    MakeRounded(refreshBtn, 8)
    refreshBtn.MouseButton1Click:Connect(function() self:Refresh() end)
    refreshBtn.MouseEnter:Connect(function() Tween(refreshBtn, {BackgroundTransparency = 0.1}, 0.2) end)
    refreshBtn.MouseLeave:Connect(function() Tween(refreshBtn, {BackgroundTransparency = 0.3}, 0.2) end)

    -- Контейнер для списка
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -150)
    container.Position = UDim2.new(0, 10, 0, 130)
    container.BackgroundTransparency = 1
    container.CanvasSize = UDim2.new(0, 0, 0, #self.Scripts * CONFIG.CardHeight + 20)
    container.ScrollBarThickness = 6
    container.Parent = main
    self.Container = container

    -- Строка статуса
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 25)
    status.Position = UDim2.new(0, 10, 1, -35)
    status.BackgroundTransparency = 1
    status.Text = "Готов"
    status.TextColor3 = CONFIG.Colors.SubText
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main
    self.StatusLabel = status

    -- Создаём загрузочный оверлей (скрыт по умолчанию)
    self:CreateLoadOverlay()
end

-- ===== КРАСИВЫЙ ЗАГРУЗОЧНЫЙ ЭКРАН =====
function Hub:CreateLoadOverlay()
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.85
    overlay.Visible = false
    overlay.Parent = self.MainFrame
    MakeRounded(overlay, 18)
    self.LoadOverlay = overlay

    -- Фоновые звёзды (мелкие точки)
    for i = 1, 50 do
        local star = Instance.new("Frame")
        star.Size = UDim2.new(0, math.random(2,4), 0, math.random(2,4))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255,255,255)
        star.BackgroundTransparency = 0.5 + math.random()*0.4
        star.BorderSizePixel = 0
        star.Parent = overlay
        MakeRounded(star, 2)
        -- анимация мерцания
        local tw = TweenService:Create(star, TweenInfo.new(1 + math.random()*2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
            {BackgroundTransparency = 0.1})
        tw:Play()
    end

    -- Основное кольцо (спиннер)
    local spinner = Instance.new("Frame")
    spinner.Size = UDim2.new(0, 100, 0, 100)
    spinner.Position = UDim2.new(0.5, -50, 0.35, -50)
    spinner.BackgroundTransparency = 1
    spinner.Parent = overlay

    -- Вращающаяся дуга (круг с прогрессом)
    local arc = Instance.new("ImageLabel")
    arc.Size = UDim2.new(1, 0, 1, 0)
    arc.BackgroundTransparency = 1
    arc.Image = "rbxassetid://1523411435" -- круговой индикатор (можно использовать rbxassetid для пустого круга, но мы сделаем свой)
    arc.ImageColor3 = CONFIG.Colors.Accent
    arc.ImageTransparency = 0.2
    arc.Parent = spinner
    -- Для красоты добавим второй слой с другим цветом
    local arc2 = arc:Clone()
    arc2.ImageColor3 = CONFIG.Colors.Accent2
    arc2.ImageTransparency = 0.6
    arc2.Parent = spinner
    arc2.Rotation = 30

    -- Анимация вращения
    local spinTween = TweenService:Create(spinner, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), {Rotation = 360})
    spinTween:Play()

    -- Текст "LOADING"
    local loadText = Instance.new("TextLabel")
    loadText.Size = UDim2.new(1, 0, 0, 50)
    loadText.Position = UDim2.new(0, 0, 0.55, 0)
    loadText.BackgroundTransparency = 1
    loadText.Text = "LOADING..."
    loadText.TextColor3 = CONFIG.Colors.Text
    loadText.TextScaled = true
    loadText.Font = Enum.Font.Code
    loadText.Parent = overlay
    self.LoadText = loadText

    -- Обратный отсчёт
    local countdown = Instance.new("TextLabel")
    countdown.Size = UDim2.new(1, 0, 0, 40)
    countdown.Position = UDim2.new(0, 0, 0.65, 0)
    countdown.BackgroundTransparency = 1
    countdown.Text = "15"
    countdown.TextColor3 = CONFIG.Colors.Accent
    countdown.TextScaled = true
    countdown.Font = Enum.Font.Code
    countdown.Parent = overlay
    self.CountdownLabel = countdown

    -- Прогресс-бар (заполняющаяся линия)
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.6, 0, 0, 8)
    progressBg.Position = UDim2.new(0.2, 0, 0.75, 0)
    progressBg.BackgroundColor3 = Color3.fromRGB(40,40,60)
    progressBg.BackgroundTransparency = 0.3
    progressBg.Parent = overlay
    MakeRounded(progressBg, 4)

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = CONFIG.Colors.Accent
    progressFill.BackgroundTransparency = 0.2
    progressFill.Parent = progressBg
    MakeRounded(progressFill, 4)
    self.ProgressFill = progressFill
end

-- ===== ЗАПУСК С ЗАГРУЗОЧНЫМ ЭКРАНОМ =====
function Hub:RunWithLoading(url, resetGlobals)
    if self.IsLoading then return end
    self.IsLoading = true

    -- Показываем оверлей
    self.LoadOverlay.Visible = true
    self.LoadOverlay.BackgroundTransparency = 0.85
    self.CountdownLabel.Text = tostring(CONFIG.LoadDuration)
    self.ProgressFill.Size = UDim2.new(0, 0, 1, 0)

    -- Анимируем появление
    Tween(self.LoadOverlay, {BackgroundTransparency = 0.7}, 0.5)

    local startTime = tick()
    local duration = CONFIG.LoadDuration

    -- Обновляем прогресс каждую секунду
    while tick() - startTime < duration do
        local elapsed = tick() - startTime
        local progress = elapsed / duration
        local remaining = math.ceil(duration - elapsed)
        self.CountdownLabel.Text = tostring(remaining)
        self.ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
        -- Анимация текста
        local colors = {CONFIG.Colors.Accent, CONFIG.Colors.Accent2, CONFIG.Colors.Text}
        local idx = math.floor(elapsed * 2) % 3 + 1
        self.LoadText.TextColor3 = colors[idx]
        RunService.Heartbeat:Wait()
    end

    -- Завершаем анимацию
    self.CountdownLabel.Text = "0"
    self.ProgressFill.Size = UDim2.new(1, 0, 1, 0)

    -- Скрываем оверлей с анимацией
    Tween(self.LoadOverlay, {BackgroundTransparency = 1}, 0.4)
    task.wait(0.5)
    self.LoadOverlay.Visible = false

    -- Загружаем и выполняем скрипт
    if resetGlobals then getgenv().NKNO = nil end
    local success, result = pcall(function()
        local content = game:HttpGet(url)
        if not content or content == "" then error("Пустой ответ от сервера") end
        return loadstring(content)
    end)

    self.IsLoading = false

    if not success or type(result) ~= "function" then
        self:UpdateStatus("Ошибка загрузки")
        self:Notify("Ошибка: " .. tostring(result), Color3.fromRGB(255,80,80))
        return
    end

    self:UpdateStatus("Выполнение...")
    self:Close() -- закрываем хаб
    local execSuccess, execErr = pcall(result)
    if not execSuccess then
        self:Notify("Ошибка выполнения: " .. tostring(execErr), Color3.fromRGB(255,80,80), 5)
    else
        self:Notify("Скрипт выполнен!", Color3.fromRGB(80,255,120))
    end
end

-- ===== ОТОБРАЖЕНИЕ КАРТОЧЕК =====
function Hub:RenderCards()
    for _, c in ipairs(self.Cards) do c:Destroy() end
    self.Cards = {}
    local container = self.Container
    local filtered = self.FilteredScripts
    local total = #filtered
    container.CanvasSize = UDim2.new(0, 0, 0, total * CONFIG.CardHeight + 20)

    for pos, scriptIndex in ipairs(filtered) do
        local scriptData = self.Scripts[scriptIndex]
        local isActive = (scriptIndex == self.ActiveIndex)

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, CONFIG.CardHeight - 10)
        card.Position = UDim2.new(0, 0, 0, (pos-1)*CONFIG.CardHeight + 5)
        card.BackgroundColor3 = CONFIG.Colors.Frame
        card.BackgroundTransparency = 0.3
        card.BorderColor3 = isActive and CONFIG.Colors.Accent or Color3.fromRGB(40,60,90)
        card.BorderSizePixel = isActive and 3 or 1
        card.Parent = container
        MakeRounded(card, 12)
        table.insert(self.Cards, card)

        -- Тень у карточки
        CreateShadow(card, 10, Color3.fromRGB(0,0,0), 0.5)

        -- Иконка
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 45, 0, 45)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Text = scriptData.Icon or "📦"
        icon.TextColor3 = CONFIG.Colors.Text
        icon.TextScaled = true
        icon.Font = Enum.Font.SourceSans
        icon.Parent = card

        -- Название
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(0.6, -20, 0, 30)
        name.Position = UDim2.new(0, 65, 0, 5)
        name.BackgroundTransparency = 1
        name.Text = scriptData.Name
        name.TextColor3 = isActive and CONFIG.Colors.Accent or CONFIG.Colors.Text
        name.TextScaled = true
        name.Font = Enum.Font.Code
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card

        -- Категория
        local cat = Instance.new("TextLabel")
        cat.Size = UDim2.new(0.3, -10, 0, 20)
        cat.Position = UDim2.new(0.6, 0, 0, 5)
        cat.BackgroundTransparency = 1
        cat.Text = "[" .. scriptData.Category .. "]"
        cat.TextColor3 = CONFIG.Colors.SubText
        cat.TextScaled = true
        cat.Font = Enum.Font.SourceSans
        cat.TextXAlignment = Enum.TextXAlignment.Right
        cat.Parent = card

        -- Описание
        if scriptData.Description then
            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(0.7, -20, 0, 25)
            desc.Position = UDim2.new(0, 65, 0, 40)
            desc.BackgroundTransparency = 1
            desc.Text = scriptData.Description
            desc.TextColor3 = CONFIG.Colors.SubText
            desc.TextScaled = true
            desc.Font = Enum.Font.SourceSans
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Parent = card
        end

        -- Кнопка запуска
        local runBtn = Instance.new("TextButton")
        runBtn.Size = UDim2.new(0, 120, 0, 38)
        runBtn.Position = UDim2.new(1, -130, 0, 60)
        runBtn.BackgroundColor3 = CONFIG.Colors.Accent
        runBtn.BackgroundTransparency = 0.15
        runBtn.Text = "▶ ЗАПУСТИТЬ"
        runBtn.TextColor3 = CONFIG.Colors.Text
        runBtn.TextScaled = true
        runBtn.Font = Enum.Font.SourceSans
        runBtn.Parent = card
        MakeRounded(runBtn, 8)

        runBtn.MouseEnter:Connect(function()
            Tween(runBtn, {BackgroundTransparency = 0.05, Size = UDim2.new(0, 130, 0, 42)}, 0.2)
        end)
        runBtn.MouseLeave:Connect(function()
            Tween(runBtn, {BackgroundTransparency = 0.15, Size = UDim2.new(0, 120, 0, 38)}, 0.2)
        end)

        -- Выбор по клику на карточку
        card.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:SelectScript(scriptIndex)
            end
        end)

        -- Запуск по кнопке
        runBtn.MouseButton1Click:Connect(function()
            self:SelectScript(scriptIndex)
            self:RunActiveScript()
        end)
    end
end

-- ===== ВЗАИМОДЕЙСТВИЕ =====
function Hub:SelectScript(index)
    if self.IsLoading then return end
    self.ActiveIndex = index
    self:RenderCards()
    self:UpdateStatus("Выбран: " .. self.Scripts[index].Name)
end

function Hub:Navigate(step)
    local filtered = self.FilteredScripts
    if #filtered == 0 then return end
    local pos
    for i, idx in ipairs(filtered) do if idx == self.ActiveIndex then pos = i break end end
    if not pos then pos = 1 else pos = pos + step; if pos < 1 then pos = #filtered end; if pos > #filtered then pos = 1 end end
    self:SelectScript(filtered[pos])
end

function Hub:RunActiveScript()
    if self.IsLoading then return end
    local scriptData = self.Scripts[self.ActiveIndex]
    if scriptData and scriptData.Run then scriptData.Run() end
end

function Hub:Notify(text, color, duration)
    if not self.Gui then return end
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 0, 40)
    label.Position = UDim2.new(0.1, 0, 0.9, -50)
    label.BackgroundColor3 = color or CONFIG.Colors.Frame
    label.BackgroundTransparency = 0.3
    label.Text = text
    label.TextColor3 = CONFIG.Colors.Text
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Parent = self.Gui
    MakeRounded(label, 8)
    task.delay(duration or 3, function() label:Destroy() end)
end

function Hub:UpdateStatus(text)
    if self.StatusLabel then self.StatusLabel.Text = text end
end

function Hub:Refresh()
    self:FilterScripts(self.SearchBox.Text or "")
    self:RenderCards()
    self:Notify("Список обновлён", CONFIG.Colors.Accent)
end

function Hub:FilterScripts(query)
    query = query:lower()
    local filtered = {}
    for i, script in ipairs(self.Scripts) do
        if query == "" or script.Name:lower():find(query) or script.Category:lower():find(query) then
            table.insert(filtered, i)
        end
    end
    self.FilteredScripts = filtered
    self:RenderCards()
    local found = false
    for _, idx in ipairs(filtered) do if idx == self.ActiveIndex then found = true break end end
    if not found and #filtered > 0 then self.ActiveIndex = filtered[1] end
    self:UpdateStatus("Найдено: " .. #filtered .. " скриптов")
end

function Hub:Close()
    if self.Gui then self.Gui:Destroy() self.Gui = nil end
    self.IsLoading = false
end

-- ===== ПЕРЕТАСКИВАНИЕ ОКНА =====
function Hub:SetupDrag()
    local titleBar = self.TitleBar
    local main = self.MainFrame

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            self.DragStart = input.Position
            self.DragOffset = main.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
        end
    end)

    Mouse.Move:Connect(function()
        if self.IsDragging and self.DragStart and self.DragOffset then
            local delta = Mouse.X - self.DragStart.X
            local deltaY = Mouse.Y - self.DragStart.Y
            local newPos = UDim2.new(
                self.DragOffset.X.Scale,
                self.DragOffset.X.Offset + delta,
                self.DragOffset.Y.Scale,
                self.DragOffset.Y.Offset + deltaY
            )
            main.Position = newPos
        end
    end)
end

-- ===== СОБЫТИЯ =====
function Hub:SetupEvents()
    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:FilterScripts(self.SearchBox.Text)
    end)

    Mouse.KeyDown:Connect(function(key)
        if key == "Escape" then
            self:RunActiveScript()
        elseif key == "p" then
            self:Close()
        elseif key == "r" then
            self:Refresh()
        elseif key == "Up" then
            self:Navigate(-1)
        elseif key == "Down" then
            self:Navigate(1)
        end
    end)

    self:SetupDrag()
end

-- ===== ЗАПУСК =====
Hub:Init()
