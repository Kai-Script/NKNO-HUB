-- ============================================================
--  ZENTX HUB ULTIMATE v4.1
--  Переливающийся дизайн · Все цвета в стиле интерфейса
-- ============================================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ===== КОНФИГ =====
local CONFIG = {
    HubName = "✦ ZENTX HUB ✦",
    Colors = {
        Background = Color3.fromRGB(10, 8, 25),
        Frame = Color3.fromRGB(22, 18, 45),
        Accent = Color3.fromRGB(0, 255, 255),
        Accent2 = Color3.fromRGB(200, 0, 255),
        Pulse = Color3.fromRGB(255, 0, 200),
        Text = Color3.fromRGB(240, 245, 255),
        SubText = Color3.fromRGB(170, 190, 220),
        CardBg = Color3.fromRGB(30, 28, 55),
    },
    Size = UDim2.new(0, 700, 0, 620),
    CardHeight = 115,
    LoadDuration = 15,
}

-- ===== ЛОКАЛИЗАЦИЯ =====
local LANG = {
    RU = {
        Welcome = "Добро пожаловать, @USER!",
        StatusReady = "Готов к работе",
        StatusLoading = "Загрузка...",
        StatusError = "Ошибка загрузки",
        StatusRunning = "Выполнение...",
        SearchPlaceholder = "🔍 Поиск...",
        RefreshBtn = "⟳ Обновить",
        RunBtn = "▶ ЗАПУСТИТЬ",
        Hint = "ESC → запустить  |  клик → выбрать  |  P → закрыть  |  R → обновить",
        NotifyScriptExecuted = "Скрипт выполнен!",
        NotifyScriptError = "Ошибка выполнения: ",
        NotifyLoadError = "Ошибка: ",
        NotifyRefresh = "Список обновлён",
        SelectLangTitle = "Выберите язык",
        SelectLangBtnRU = "Русский",
        SelectLangBtnEN = "English",
        FoundScripts = "Найдено: @COUNT скриптов",
        Selected = "Выбран: ",
        PlayerInfo = "Игрок: @USER",
    },
    EN = {
        Welcome = "Welcome, @USER!",
        StatusReady = "Ready",
        StatusLoading = "Loading...",
        StatusError = "Load error",
        StatusRunning = "Running...",
        SearchPlaceholder = "🔍 Search...",
        RefreshBtn = "⟳ Refresh",
        RunBtn = "▶ RUN",
        Hint = "ESC → run  |  click → select  |  P → close  |  R → refresh",
        NotifyScriptExecuted = "Script executed!",
        NotifyScriptError = "Execution error: ",
        NotifyLoadError = "Error: ",
        NotifyRefresh = "List updated",
        SelectLangTitle = "Select language",
        SelectLangBtnRU = "Русский",
        SelectLangBtnEN = "English",
        FoundScripts = "Found: @COUNT scripts",
        Selected = "Selected: ",
        PlayerInfo = "Player: @USER",
    }
}

-- ===== СОСТОЯНИЕ =====
local Hub = {
    Gui = nil,
    MainFrame = nil,
    Container = nil,
    SearchBox = nil,
    StatusLabel = nil,
    PlayerLabel = nil,
    ActiveIndex = 1,
    Scripts = {},
    Cards = {},
    FilteredScripts = {},
    IsDragging = false,
    DragStart = nil,
    DragOffset = nil,
    LoadOverlay = nil,
    IsLoading = false,
    Language = "RU",
    LangData = nil,
}

-- ===== УТИЛИТЫ =====
local function MakeRounded(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function Tween(obj, props, duration, style, delay)
    local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle[style or "Quad"], Enum.EasingDirection.Out, delay or 0)
    local t = TweenService:Create(obj, info, props)
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

-- Функция для создания градиента с анимацией (вращение)
local function CreateAnimatedGradient(obj, colors, speed)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(colors)
    grad.Rotation = 0
    grad.Parent = obj
    local rotationTween = TweenService:Create(grad, TweenInfo.new(speed or 10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), {Rotation = 360})
    rotationTween:Play()
    return grad
end

-- ===== СПИСОК СКРИПТОВ =====
local Scripts = {
    {
        Name = "⚡ +1 speed keyboard escape",
        Category = "Скорость",
        Description = nil,
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
            Hub:RunWithLoading("https://raw.githubusercontent.com/Kai-Script/NKNO-HUB/refs/heads/main/zentx.hub.mm2.lua", true)
        end
    },
}

-- ===== ВЫБОР ЯЗЫКА (ЭКРАН ПРИВЕТСТВИЯ) =====
function Hub:ShowLanguageSelector()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LangSelector"
    screenGui.Parent = Player.PlayerGui
    self.Gui = screenGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.7
    overlay.Parent = screenGui

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 450, 0, 280)
    container.Position = UDim2.new(0.5, -225, 0.5, -140)
    container.BackgroundColor3 = CONFIG.Colors.Background
    container.BackgroundTransparency = 0.1
    container.BorderColor3 = CONFIG.Colors.Accent
    container.BorderSizePixel = 2
    container.Parent = overlay
    MakeRounded(container, 22)
    CreateShadow(container, 30, Color3.fromRGB(0,0,0), 0.8)

    -- Переливающийся фон контейнера
    local bgGrad = Instance.new("Frame")
    bgGrad.Size = UDim2.new(1, 0, 1, 0)
    bgGrad.BackgroundColor3 = CONFIG.Colors.Background
    bgGrad.BackgroundTransparency = 0.3
    bgGrad.BorderSizePixel = 0
    bgGrad.Parent = container
    MakeRounded(bgGrad, 22)
    local colors = {
        ColorSequenceKeypoint.new(0, CONFIG.Colors.Accent),
        ColorSequenceKeypoint.new(0.33, CONFIG.Colors.Accent2),
        ColorSequenceKeypoint.new(0.66, CONFIG.Colors.Pulse),
        ColorSequenceKeypoint.new(1, CONFIG.Colors.Accent),
    }
    CreateAnimatedGradient(bgGrad, colors, 8)

    -- Приветствие
    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Size = UDim2.new(1, -40, 0, 50)
    welcomeLabel.Position = UDim2.new(0, 20, 0, 20)
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.Text = "Добро пожаловать, " .. Player.Name .. "!"
    welcomeLabel.TextColor3 = CONFIG.Colors.Text
    welcomeLabel.TextScaled = true
    welcomeLabel.Font = Enum.Font.GothamBold
    welcomeLabel.Parent = container

    -- Заголовок выбора языка
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 35)
    title.Position = UDim2.new(0, 20, 0, 80)
    title.BackgroundTransparency = 1
    title.Text = "Выберите язык"
    title.TextColor3 = CONFIG.Colors.SubText
    title.TextScaled = true
    title.Font = Enum.Font.SourceSans
    title.Parent = container

    -- Кнопка РУССКИЙ
    local ruBtn = Instance.new("TextButton")
    ruBtn.Size = UDim2.new(0, 160, 0, 45)
    ruBtn.Position = UDim2.new(0.5, -180, 0, 140)
    ruBtn.BackgroundColor3 = CONFIG.Colors.Frame
    ruBtn.BackgroundTransparency = 0.4
    ruBtn.BorderColor3 = CONFIG.Colors.Accent
    ruBtn.BorderSizePixel = 2
    ruBtn.Text = "Русский"
    ruBtn.TextColor3 = CONFIG.Colors.Text
    ruBtn.TextScaled = true
    ruBtn.Font = Enum.Font.Gotham
    ruBtn.Parent = container
    MakeRounded(ruBtn, 12)

    ruBtn.MouseEnter:Connect(function()
        Tween(ruBtn, {BackgroundTransparency = 0.2, BorderSizePixel = 3}, 0.2)
    end)
    ruBtn.MouseLeave:Connect(function()
        Tween(ruBtn, {BackgroundTransparency = 0.4, BorderSizePixel = 2}, 0.2)
    end)

    -- Кнопка ENGLISH
    local enBtn = Instance.new("TextButton")
    enBtn.Size = UDim2.new(0, 160, 0, 45)
    enBtn.Position = UDim2.new(0.5, 20, 0, 140)
    enBtn.BackgroundColor3 = CONFIG.Colors.Frame
    enBtn.BackgroundTransparency = 0.4
    enBtn.BorderColor3 = CONFIG.Colors.Accent2
    enBtn.BorderSizePixel = 2
    enBtn.Text = "English"
    enBtn.TextColor3 = CONFIG.Colors.Text
    enBtn.TextScaled = true
    enBtn.Font = Enum.Font.Gotham
    enBtn.Parent = container
    MakeRounded(enBtn, 12)

    enBtn.MouseEnter:Connect(function()
        Tween(enBtn, {BackgroundTransparency = 0.2, BorderSizePixel = 3}, 0.2)
    end)
    enBtn.MouseLeave:Connect(function()
        Tween(enBtn, {BackgroundTransparency = 0.4, BorderSizePixel = 2}, 0.2)
    end)

    -- Анимация пульсации кнопок
    local function PulseButtons()
        Tween(ruBtn, {BorderColor3 = CONFIG.Colors.Pulse}, 1.5, "Sine", 0)
        Tween(enBtn, {BorderColor3 = CONFIG.Colors.Pulse}, 1.5, "Sine", 0.2)
    end
    PulseButtons()

    ruBtn.MouseButton1Click:Connect(function()
        CONFIG.Language = "RU"
        self.Language = "RU"
        self.LangData = LANG.RU
        screenGui:Destroy()
        self:Init()
    end)

    enBtn.MouseButton1Click:Connect(function()
        CONFIG.Language = "EN"
        self.Language = "EN"
        self.LangData = LANG.EN
        screenGui:Destroy()
        self:Init()
    end)
end

-- ===== ОСНОВНАЯ ИНИЦИАЛИЗАЦИЯ =====
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
    self:UpdateStatus(self.LangData.StatusReady)
end

function Hub:CreateGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZENTX_HUB"
    gui.Parent = Player.PlayerGui
    self.Gui = gui

    -- Основное окно с переливающимся фоном
    local main = Instance.new("Frame")
    main.Size = CONFIG.Size
    main.Position = UDim2.new(0.5, -CONFIG.Size.X.Offset/2, 0.5, -CONFIG.Size.Y.Offset/2)
    main.BackgroundColor3 = CONFIG.Colors.Background
    main.BackgroundTransparency = 0.1
    main.BorderSizePixel = 2
    main.BorderColor3 = CONFIG.Colors.Accent
    main.Parent = gui
    MakeRounded(main, 24)
    self.MainFrame = main

    -- Переливающийся градиентный фон окна
    local bgGrad = Instance.new("Frame")
    bgGrad.Size = UDim2.new(1, 0, 1, 0)
    bgGrad.BackgroundColor3 = CONFIG.Colors.Background
    bgGrad.BackgroundTransparency = 0.2
    bgGrad.BorderSizePixel = 0
    bgGrad.Parent = main
    MakeRounded(bgGrad, 24)
    local colors = {
        ColorSequenceKeypoint.new(0, CONFIG.Colors.Accent),
        ColorSequenceKeypoint.new(0.33, CONFIG.Colors.Accent2),
        ColorSequenceKeypoint.new(0.66, CONFIG.Colors.Pulse),
        ColorSequenceKeypoint.new(1, CONFIG.Colors.Accent),
    }
    CreateAnimatedGradient(bgGrad, colors, 8)

    -- Тень
    CreateShadow(main, 40, Color3.fromRGB(0,0,0), 0.9)

    -- Анимированная рамка (пульсирующая обводка)
    local borderGlow = Instance.new("Frame")
    borderGlow.Size = UDim2.new(1, 10, 1, 10)
    borderGlow.Position = UDim2.new(0, -5, 0, -5)
    borderGlow.BackgroundColor3 = CONFIG.Colors.Accent
    borderGlow.BackgroundTransparency = 0.8
    borderGlow.BorderSizePixel = 0
    borderGlow.Parent = main
    MakeRounded(borderGlow, 28)
    local pulseBorder = TweenService:Create(borderGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {BackgroundTransparency = 0.5, BorderSizePixel = 4})
    pulseBorder:Play()

    -- Фоновые звёзды (цвета интерфейса)
    for i = 1, 40 do
        local star = Instance.new("Frame")
        star.Size = UDim2.new(0, math.random(2,5), 0, math.random(2,5))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = CONFIG.Colors.Accent  -- вместо белого
        star.BackgroundTransparency = 0.5 + math.random()*0.4
        star.BorderSizePixel = 0
        star.Parent = main
        MakeRounded(star, 3)
        local tw = TweenService:Create(star, TweenInfo.new(2 + math.random()*3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {BackgroundTransparency = 0.1, Position = UDim2.new(star.Position.X.Scale + 0.02, 0, star.Position.Y.Scale + 0.02, 0)})
        tw:Play()
    end

    -- ===== ЗАГОЛОВОК =====
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 65)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main
    self.TitleBar = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 25, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.HubName
    title.TextColor3 = CONFIG.Colors.Text
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Переливающийся эффект заголовка (изменение цвета)
    local titleColors = {CONFIG.Colors.Accent, CONFIG.Colors.Accent2, CONFIG.Colors.Pulse}
    local idx = 1
    local function cycleTitle()
        idx = idx % 3 + 1
        Tween(title, {TextColor3 = titleColors[idx]}, 2.5, "Linear")
    end
    -- Запускаем цикл
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not title.Parent then connection:Disconnect() return end
        if idx == 1 then
            Tween(title, {TextColor3 = titleColors[2]}, 2.5, "Linear")
            idx = 2
        elseif idx == 2 then
            Tween(title, {TextColor3 = titleColors[3]}, 2.5, "Linear")
            idx = 3
        else
            Tween(title, {TextColor3 = titleColors[1]}, 2.5, "Linear")
            idx = 1
        end
    end)

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0, 12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.4
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSans
    closeBtn.Parent = titleBar
    MakeRounded(closeBtn, 20)
    closeBtn.MouseButton1Click:Connect(function() self:Close() end)
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0.1}, 0.2) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0.4}, 0.2) end)

    -- Подсказка
    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, 0, 0, 28)
    hint.Position = UDim2.new(0, 0, 0, 65)
    hint.BackgroundTransparency = 1
    hint.Text = self.LangData.Hint
    hint.TextColor3 = CONFIG.Colors.SubText
    hint.TextScaled = true
    hint.Font = Enum.Font.SourceSans
    hint.Parent = main

    -- Поиск
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.6, -10, 0, 36)
    searchBox.Position = UDim2.new(0.05, 0, 0.19, 0)
    searchBox.BackgroundColor3 = CONFIG.Colors.Frame
    searchBox.BackgroundTransparency = 0.5
    searchBox.Text = self.LangData.SearchPlaceholder
    searchBox.TextColor3 = CONFIG.Colors.Text
    searchBox.TextScaled = true
    searchBox.Font = Enum.Font.SourceSans
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = main
    MakeRounded(searchBox, 12)
    self.SearchBox = searchBox

    -- Кнопка обновления
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 110, 0, 36)
    refreshBtn.Position = UDim2.new(0.73, 0, 0.19, 0)
    refreshBtn.BackgroundColor3 = CONFIG.Colors.Frame
    refreshBtn.BackgroundTransparency = 0.5
    refreshBtn.Text = self.LangData.RefreshBtn
    refreshBtn.TextColor3 = CONFIG.Colors.Text
    refreshBtn.TextScaled = true
    refreshBtn.Font = Enum.Font.SourceSans
    refreshBtn.Parent = main
    MakeRounded(refreshBtn, 12)
    refreshBtn.MouseButton1Click:Connect(function() self:Refresh() end)
    refreshBtn.MouseEnter:Connect(function() Tween(refreshBtn, {BackgroundTransparency = 0.3}, 0.2) end)
    refreshBtn.MouseLeave:Connect(function() Tween(refreshBtn, {BackgroundTransparency = 0.5}, 0.2) end)

    -- Контейнер для списка
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -195)
    container.Position = UDim2.new(0, 10, 0, 145)
    container.BackgroundTransparency = 1
    container.CanvasSize = UDim2.new(0, 0, 0, #self.Scripts * CONFIG.CardHeight + 20)
    container.ScrollBarThickness = 6
    container.Parent = main
    self.Container = container

    -- Строка статуса
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.6, -10, 0, 28)
    status.Position = UDim2.new(0, 10, 1, -38)
    status.BackgroundTransparency = 1
    status.Text = self.LangData.StatusReady
    status.TextColor3 = CONFIG.Colors.SubText
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main
    self.StatusLabel = status

    -- Информация об игроке (ник + аватар)
    local playerFrame = Instance.new("Frame")
    playerFrame.Size = UDim2.new(0.35, 0, 0, 50)
    playerFrame.Position = UDim2.new(0.65, 10, 1, -48)
    playerFrame.BackgroundColor3 = CONFIG.Colors.Frame
    playerFrame.BackgroundTransparency = 0.4
    playerFrame.BorderColor3 = CONFIG.Colors.Accent
    playerFrame.BorderSizePixel = 1
    playerFrame.Parent = main
    MakeRounded(playerFrame, 12)

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 40, 0, 40)
    avatar.Position = UDim2.new(0, 5, 0, 5)
    avatar.BackgroundTransparency = 1
    avatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
    avatar.Parent = playerFrame
    MakeRounded(avatar, 20)

    local playerName = Instance.new("TextLabel")
    playerName.Size = UDim2.new(1, -55, 1, 0)
    playerName.Position = UDim2.new(0, 50, 0, 0)
    playerName.BackgroundTransparency = 1
    playerName.Text = self.LangData.PlayerInfo:gsub("@USER", Player.Name)
    playerName.TextColor3 = CONFIG.Colors.Text
    playerName.TextScaled = true
    playerName.Font = Enum.Font.Gotham
    playerName.TextXAlignment = Enum.TextXAlignment.Left
    playerName.Parent = playerFrame

    -- Загрузочный оверлей
    self:CreateLoadOverlay()
end

-- ===== ЗАГРУЗОЧНЫЙ ЭКРАН =====
function Hub:CreateLoadOverlay()
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.9
    overlay.Visible = false
    overlay.Parent = self.MainFrame
    MakeRounded(overlay, 24)
    self.LoadOverlay = overlay

    for i = 1, 60 do
        local star = Instance.new("Frame")
        star.Size = UDim2.new(0, math.random(2,5), 0, math.random(2,5))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = CONFIG.Colors.Accent  -- вместо белого
        star.BackgroundTransparency = 0.4 + math.random()*0.5
        star.BorderSizePixel = 0
        star.Parent = overlay
        MakeRounded(star, 3)
        local tw = TweenService:Create(star, TweenInfo.new(1 + math.random()*3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {BackgroundTransparency = 0.1})
        tw:Play()
    end

    local spinner = Instance.new("Frame")
    spinner.Size = UDim2.new(0, 120, 0, 120)
    spinner.Position = UDim2.new(0.5, -60, 0.35, -60)
    spinner.BackgroundTransparency = 1
    spinner.Parent = overlay

    local arc1 = Instance.new("ImageLabel")
    arc1.Size = UDim2.new(1, 0, 1, 0)
    arc1.BackgroundTransparency = 1
    arc1.Image = "rbxassetid://1523411435"
    arc1.ImageColor3 = CONFIG.Colors.Accent
    arc1.ImageTransparency = 0.2
    arc1.Parent = spinner
    local arc2 = arc1:Clone()
    arc2.ImageColor3 = CONFIG.Colors.Accent2
    arc2.ImageTransparency = 0.6
    arc2.Parent = spinner
    arc2.Rotation = 30

    local spinTween = TweenService:Create(spinner, TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), {Rotation = 360})
    spinTween:Play()

    local loadText = Instance.new("TextLabel")
    loadText.Size = UDim2.new(1, 0, 0, 50)
    loadText.Position = UDim2.new(0, 0, 0.58, 0)
    loadText.BackgroundTransparency = 1
    loadText.Text = self.LangData.StatusLoading
    loadText.TextColor3 = CONFIG.Colors.Text
    loadText.TextScaled = true
    loadText.Font = Enum.Font.GothamBold
    loadText.Parent = overlay
    self.LoadText = loadText

    local countdown = Instance.new("TextLabel")
    countdown.Size = UDim2.new(1, 0, 0, 45)
    countdown.Position = UDim2.new(0, 0, 0.68, 0)
    countdown.BackgroundTransparency = 1
    countdown.Text = "15"
    countdown.TextColor3 = CONFIG.Colors.Accent2
    countdown.TextScaled = true
    countdown.Font = Enum.Font.GothamBold
    countdown.Parent = overlay
    self.CountdownLabel = countdown

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.6, 0, 0, 10)
    progressBg.Position = UDim2.new(0.2, 0, 0.78, 0)
    progressBg.BackgroundColor3 = Color3.fromRGB(40,40,60)
    progressBg.BackgroundTransparency = 0.3
    progressBg.Parent = overlay
    MakeRounded(progressBg, 5)

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = CONFIG.Colors.Accent
    progressFill.BackgroundTransparency = 0.2
    progressFill.Parent = progressBg
    MakeRounded(progressFill, 5)
    self.ProgressFill = progressFill
end

function Hub:RunWithLoading(url, resetGlobals)
    if self.IsLoading then return end
    self.IsLoading = true

    self.LoadOverlay.Visible = true
    self.LoadOverlay.BackgroundTransparency = 0.9
    self.CountdownLabel.Text = tostring(CONFIG.LoadDuration)
    self.ProgressFill.Size = UDim2.new(0, 0, 1, 0)

    Tween(self.LoadOverlay, {BackgroundTransparency = 0.7}, 0.6)

    local startTime = tick()
    local duration = CONFIG.LoadDuration

    while tick() - startTime < duration do
        local elapsed = tick() - startTime
        local progress = elapsed / duration
        local remaining = math.ceil(duration - elapsed)
        self.CountdownLabel.Text = tostring(remaining)
        self.ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
        local colors = {CONFIG.Colors.Accent, CONFIG.Colors.Accent2, CONFIG.Colors.Pulse}
        local idx = math.floor(elapsed * 2) % 3 + 1
        self.LoadText.TextColor3 = colors[idx]
        RunService.Heartbeat:Wait()
    end

    self.CountdownLabel.Text = "0"
    self.ProgressFill.Size = UDim2.new(1, 0, 1, 0)

    Tween(self.LoadOverlay, {BackgroundTransparency = 1}, 0.5)
    task.wait(0.5)
    self.LoadOverlay.Visible = false

    if resetGlobals then getgenv().NKNO = nil end
    local success, result = pcall(function()
        local content = game:HttpGet(url)
        if not content or content == "" then error("Пустой ответ от сервера") end
        return loadstring(content)
    end)

    self.IsLoading = false

    if not success or type(result) ~= "function" then
        self:UpdateStatus(self.LangData.StatusError)
        self:Notify(self.LangData.NotifyLoadError .. tostring(result), Color3.fromRGB(255,80,80))
        return
    end

    self:UpdateStatus(self.LangData.StatusRunning)
    self:Close()
    local execSuccess, execErr = pcall(result)
    if not execSuccess then
        self:Notify(self.LangData.NotifyScriptError .. tostring(execErr), Color3.fromRGB(255,80,80), 5)
    else
        self:Notify(self.LangData.NotifyScriptExecuted, Color3.fromRGB(80,255,120))
    end
end

-- ===== ОТОБРАЖЕНИЕ КАРТОЧЕК (с переливающимся фоном) =====
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
        card.BackgroundColor3 = CONFIG.Colors.CardBg
        card.BackgroundTransparency = 0.3
        card.BorderColor3 = isActive and CONFIG.Colors.Accent or Color3.fromRGB(50,50,80)
        card.BorderSizePixel = isActive and 2 or 1
        card.Parent = container
        MakeRounded(card, 16)
        table.insert(self.Cards, card)

        -- Переливающийся градиентный фон для карточки (если активна, то более яркий)
        local cardGrad = Instance.new("Frame")
        cardGrad.Size = UDim2.new(1, 0, 1, 0)
        cardGrad.BackgroundColor3 = CONFIG.Colors.CardBg
        cardGrad.BackgroundTransparency = 0.4
        cardGrad.BorderSizePixel = 0
        cardGrad.Parent = card
        MakeRounded(cardGrad, 16)
        local colors = {
            ColorSequenceKeypoint.new(0, isActive and CONFIG.Colors.Accent or CONFIG.Colors.Frame),
            ColorSequenceKeypoint.new(0.5, isActive and CONFIG.Colors.Accent2 or CONFIG.Colors.Frame),
            ColorSequenceKeypoint.new(1, isActive and CONFIG.Colors.Pulse or CONFIG.Colors.Frame),
        }
        local grad = CreateAnimatedGradient(cardGrad, colors, 10)
        -- Уменьшаем прозрачность для неактивных
        if not isActive then
            grad.Rotation = 0
            grad:Destroy()
            cardGrad.BackgroundTransparency = 0.8
        end

        -- Убираем белый "эффект стекла" – оставляем только прозрачный слой
        local glass = Instance.new("Frame")
        glass.Size = UDim2.new(1, 0, 1, 0)
        glass.BackgroundColor3 = CONFIG.Colors.Frame  -- вместо белого
        glass.BackgroundTransparency = 0.1           -- почти прозрачный
        glass.BorderSizePixel = 0
        glass.Parent = card
        MakeRounded(glass, 16)

        CreateShadow(card, 14, Color3.fromRGB(0,0,0), 0.6)

        -- Иконка
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 50, 0, 50)
        icon.Position = UDim2.new(0, 15, 0, 12)
        icon.BackgroundTransparency = 1
        icon.Text = scriptData.Icon or "📦"
        icon.TextColor3 = isActive and CONFIG.Colors.Accent or CONFIG.Colors.Text
        icon.TextScaled = true
        icon.Font = Enum.Font.SourceSans
        icon.Parent = card

        if isActive then
            local pulseIcon = TweenService:Create(icon, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {TextColor3 = CONFIG.Colors.Pulse})
            pulseIcon:Play()
        end

        -- Название
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(0.5, -20, 0, 30)
        name.Position = UDim2.new(0, 75, 0, 8)
        name.BackgroundTransparency = 1
        name.Text = scriptData.Name
        name.TextColor3 = isActive and CONFIG.Colors.Accent or CONFIG.Colors.Text
        name.TextScaled = true
        name.Font = Enum.Font.Gotham
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card

        -- Категория
        local cat = Instance.new("TextLabel")
        cat.Size = UDim2.new(0.3, -10, 0, 20)
        cat.Position = UDim2.new(0.6, 0, 0, 8)
        cat.BackgroundTransparency = 1
        cat.Text = "[" .. scriptData.Category .. "]"
        cat.TextColor3 = CONFIG.Colors.SubText
        cat.TextScaled = true
        cat.Font = Enum.Font.SourceSans
        cat.TextXAlignment = Enum.TextXAlignment.Right
        cat.Parent = card

        -- Описание
        if scriptData.Description and scriptData.Description ~= "" then
            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(0.6, -20, 0, 25)
            desc.Position = UDim2.new(0, 75, 0, 42)
            desc.BackgroundTransparency = 1
            desc.Text = scriptData.Description
            desc.TextColor3 = CONFIG.Colors.SubText
            desc.TextScaled = true
            desc.Font = Enum.Font.SourceSans
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Parent = card
        end

        -- Иконка игрока (запуск)
        local playerBtn = Instance.new("TextButton")
        playerBtn.Size = UDim2.new(0, 42, 0, 42)
        playerBtn.Position = UDim2.new(1, -170, 0, 10)
        playerBtn.BackgroundTransparency = 1
        playerBtn.Text = "👤"
        playerBtn.TextColor3 = CONFIG.Colors.Accent
        playerBtn.TextScaled = true
        playerBtn.Font = Enum.Font.SourceSans
        playerBtn.Parent = card

        playerBtn.MouseEnter:Connect(function()
            Tween(playerBtn, {TextColor3 = Color3.fromRGB(255,255,255), TextStrokeColor3 = CONFIG.Colors.Pulse, TextStrokeTransparency = 0.3}, 0.3)
        end)
        playerBtn.MouseLeave:Connect(function()
            Tween(playerBtn, {TextColor3 = CONFIG.Colors.Accent, TextStrokeTransparency = 1}, 0.3)
        end)
        playerBtn.MouseButton1Click:Connect(function()
            self:SelectScript(scriptIndex)
            self:RunActiveScript()
        end)

        -- Кнопка запуска
        local runBtn = Instance.new("TextButton")
        runBtn.Size = UDim2.new(0, 120, 0, 40)
        runBtn.Position = UDim2.new(1, -135, 0, 60)
        runBtn.BackgroundColor3 = CONFIG.Colors.Accent
        runBtn.BackgroundTransparency = 0.2
        runBtn.Text = self.LangData.RunBtn
        runBtn.TextColor3 = CONFIG.Colors.Text
        runBtn.TextScaled = true
        runBtn.Font = Enum.Font.Gotham
        runBtn.Parent = card
        MakeRounded(runBtn, 12)

        local pulseBtn = TweenService:Create(runBtn, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {BackgroundTransparency = 0.1})
        pulseBtn:Play()

        runBtn.MouseEnter:Connect(function()
            Tween(runBtn, {BackgroundTransparency = 0.05, Size = UDim2.new(0, 128, 0, 44)}, 0.2)
        end)
        runBtn.MouseLeave:Connect(function()
            Tween(runBtn, {BackgroundTransparency = 0.2, Size = UDim2.new(0, 120, 0, 40)}, 0.2)
        end)

        card.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:SelectScript(scriptIndex)
            end
        end)

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
    self:UpdateStatus(self.LangData.Selected .. self.Scripts[index].Name)
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
    self:FilterScripts(self.SearchBox.Text:gsub(self.LangData.SearchPlaceholder, ""):gsub("🔍", ""):gsub("%s+", " "):match("^%s*(.-)%s*$") or "")
    self:RenderCards()
    self:Notify(self.LangData.NotifyRefresh, CONFIG.Colors.Accent)
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
    self:UpdateStatus(self.LangData.FoundScripts:gsub("@COUNT", #filtered))
end

function Hub:Close()
    if self.Gui then self.Gui:Destroy() self.Gui = nil end
    self.IsLoading = false
end

-- ===== ПЕРЕТАСКИВАНИЕ =====
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
        local query = self.SearchBox.Text
        if query == self.LangData.SearchPlaceholder then query = "" end
        self:FilterScripts(query)
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
local function Start()
    local hub = Hub
    hub.Language = "RU"
    hub.LangData = LANG.RU
    hub:ShowLanguageSelector()
end

Start()
