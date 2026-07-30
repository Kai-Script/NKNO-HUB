-- Упрощённое меню "nkno$ hub" (только интерфейс)
do
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- Если GUI уже существует, удаляем
    if game.CoreGui:FindFirstChild("nkno$ hub") then
        game.CoreGui["nkno$ hub"]:Destroy()
    end

    -- Язык и локализация (оставлено для выбора)
    local lang = "EN"
    local Locales = {
        RU = {
            ChooseLang = "Выберите язык",
            ThemeTitle = "Цветовая палитра интерфейса",
            WorldLabel = "Мир: [ %s ]",
            AutoFarmTab = "Авто Фарм",
            ThemeTab = "Темы",
            MovementTab = "Движение",
            AdminTab = "Админка",
            PointPrefix = "ТОЧКА",
            Themes = {"Синий Космос", "Фиолетовый Кибер", "Кислотный Лайм", "Пылкая Роза", "Янтарный Неон", "Белый Фантом"},
        },
        EN = {
            ChooseLang = "Choose language",
            ThemeTitle = "Interface Color Palette",
            WorldLabel = "World: [ %s ]",
            AutoFarmTab = "Auto Farm",
            ThemeTab = "Themes",
            MovementTab = "Movement",
            AdminTab = "Admin",
            PointPrefix = "POINT",
            Themes = {"Blue Space", "Purple Cyber", "Acid Lime", "Fiery Rose", "Amber Neon", "White Phantom"},
        }
    }
    local function L(key) return Locales[lang][key] end

    -- Глобальные переменные для интерфейса
    local accentColor = Color3.fromRGB(0, 150, 255)
    local isMinimized = false
    local isMenuOpen = false

    -- Создание GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "nkno$ hub"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Тень
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

    -- Основное окно
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
    local BgImage = Instance.new("ImageLabel")
    BgImage.Name = "BackgroundImage"
    BgImage.Parent = MainFrame
    BgImage.BackgroundTransparency = 1
    BgImage.Size = UDim2.new(1, 0, 1, 0)
    BgImage.Image = "rbxassetid://138913032331139"
    BgImage.ScaleType = Enum.ScaleType.Crop
    BgImage.ImageTransparency = 0.35
    BgImage.ZIndex = 0
    Instance.new("UICorner", BgImage).CornerRadius = UDim.new(0, 14)
    local MainScale = Instance.new("UIScale", MainFrame)
    MainScale.Scale = 0.3
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Rotation = 90
    MainGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 0.5)})
    MainGradient.Parent = MainFrame
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = Color3.fromRGB(35, 35, 50)
    MainStroke.Thickness = 1.5

    -- Функция открытия/закрытия меню
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

    -- Кнопка-переключатель (для открытия меню)
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

    -- Drag для ToggleWidget
    local dragToggle, dragInputT, dragStartT, startPosT, dragStartTime
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

    -- Окно выбора языка (появляется при первом запуске)
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
            _G.ApplyLanguage()
            TweenService:Create(LangScale, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0}):Play()
            task.wait(0.2)
            LangFrame.Visible = false
            ToggleWidget.Visible = true
            toggleMenu(true)
        end)
    end
    buildLangButton("RU", "Русский", 65, "RU")
    buildLangButton("EN", "English", 205, "EN")

    -- Drag для MainFrame
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainFrame.Position = targetPos
            ShadowFrame.Position = UDim2.new(targetPos.X.Scale, targetPos.X.Offset + 4, targetPos.Y.Scale, targetPos.Y.Offset + 6)
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Верхние кнопки (закрыть, свернуть)
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

    -- Боковая панель (вкладки)
    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    Sidebar.BackgroundTransparency = 0.1
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)
    local SidebarGradient = Instance.new("UIGradient")
    SidebarGradient.Rotation = 90
    SidebarGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.4)})
    SidebarGradient.Parent = Sidebar
    local SidebarFix = Instance.new("Frame")
    SidebarFix.Parent = Sidebar
    SidebarFix.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    SidebarFix.BackgroundTransparency = 0.1
    SidebarFix.Position = UDim2.new(1, -12, 0, 0)
    SidebarFix.Size = UDim2.new(0, 12, 1, 0)
    SidebarFix.BorderSizePixel = 0
    local SidebarFixGradient = Instance.new("UIGradient")
    SidebarFixGradient.Rotation = 90
    SidebarFixGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.4)})
    SidebarFixGradient.Parent = SidebarFix

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

    -- Область контента
    local ContentArea = Instance.new("Frame")
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = false
    ContentArea.Position = UDim2.new(0, 185, 0, 15)
    ContentArea.Size = UDim2.new(1, -200, 1, -30)

    -- Страницы (только ThemePage будет содержать элементы)
    local AutoFarmPage = Instance.new("Frame")
    AutoFarmPage.Parent = ContentArea
    AutoFarmPage.BackgroundTransparency = 1
    AutoFarmPage.Size = UDim2.new(1, 0, 1, 0)
    AutoFarmPage.Visible = true

    local MovementPage = Instance.new("Frame")
    MovementPage.Parent = ContentArea
    MovementPage.BackgroundTransparency = 1
    MovementPage.Size = UDim2.new(1, 0, 1, 0)
    MovementPage.Visible = false

    local ThemePage = Instance.new("Frame")
    ThemePage.Parent = ContentArea
    ThemePage.BackgroundTransparency = 1
    ThemePage.Size = UDim2.new(1, 0, 1, 0)
    ThemePage.Visible = false

    local AdminPage = Instance.new("Frame")
    AdminPage.Parent = ContentArea
    AdminPage.BackgroundTransparency = 1
    AdminPage.Size = UDim2.new(1, 0, 1, 0)
    AdminPage.Visible = false

    -- Создание кнопок вкладок
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
            AutoFarmPage.Visible = (page == AutoFarmPage)
            MovementPage.Visible = (page == MovementPage)
            ThemePage.Visible = (page == ThemePage)
            AdminPage.Visible = (page == AdminPage)
        end)
        table.insert(tabButtons, btn)
        return btn
    end

    local autoFarmTabBtn = createTabButton(L("AutoFarmTab"), AutoFarmPage)
    local movementTabBtn = createTabButton(L("MovementTab"), MovementPage)
    local themeTabBtn = createTabButton(L("ThemeTab"), ThemePage)
    local adminTabBtn = createTabButton(L("AdminTab"), AdminPage)

    -- По умолчанию выбрана вкладка AutoFarm (можно изменить на Theme)
    autoFarmTabBtn.BackgroundColor3 = accentColor
    autoFarmTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Заполнение ThemePage (выбор цветовой темы)
    local ThemeScroll = Instance.new("ScrollingFrame")
    ThemeScroll.Parent = ThemePage
    ThemeScroll.BackgroundTransparency = 1
    ThemeScroll.Size = UDim2.new(1, 0, 1, 0)
    ThemeScroll.ScrollBarThickness = 0
    local ThemeList = Instance.new("UIListLayout")
    ThemeList.Parent = ThemeScroll
    ThemeList.SortOrder = Enum.SortOrder.LayoutOrder
    ThemeList.Padding = UDim.new(0, 10)

    local ThemeTitleLabel = Instance.new("TextLabel")
    ThemeTitleLabel.Parent = ThemeScroll
    ThemeTitleLabel.BackgroundTransparency = 1
    ThemeTitleLabel.Size = UDim2.new(1, 0, 0, 32)
    ThemeTitleLabel.Font = Enum.Font.GothamBold
    ThemeTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ThemeTitleLabel.TextSize = 16
    ThemeTitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ThemeRows = {}
    local function createThemeRow(color1, color2)
        local RowBtn = Instance.new("TextButton")
        RowBtn.Parent = ThemeScroll
        RowBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 23)
        RowBtn.BackgroundTransparency = 0.15
        RowBtn.Size = UDim2.new(1, -10, 0, 52)
        RowBtn.Text = ""
        Instance.new("UICorner", RowBtn).CornerRadius = UDim.new(0, 10)

        local CirclePreview = Instance.new("Frame")
        CirclePreview.Parent = RowBtn
        CirclePreview.Size = UDim2.new(0, 26, 0, 26)
        CirclePreview.Position = UDim2.new(0, 16, 0.5, -13)
        Instance.new("UICorner", CirclePreview).CornerRadius = UDim.new(1, 0)
        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, color2)})
        Gradient.Parent = CirclePreview

        local ThemeText = Instance.new("TextLabel")
        ThemeText.Parent = RowBtn
        ThemeText.BackgroundTransparency = 1
        ThemeText.Position = UDim2.new(0, 56, 0, 0)
        ThemeText.Size = UDim2.new(1, -70, 1, 0)
        ThemeText.Font = Enum.Font.GothamSemibold
        ThemeText.TextColor3 = Color3.fromRGB(190, 190, 210)
        ThemeText.TextSize = 15
        ThemeText.TextXAlignment = Enum.TextXAlignment.Left

        RowBtn.MouseButton1Click:Connect(function()
            accentColor = color1
            -- Обновляем элементы интерфейса, использующие accentColor
            TitleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
            ToggleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
            SepGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)), ColorSequenceKeypoint.new(0.5, color1), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))})
            -- Обновляем выделенную вкладку
            for _, b in ipairs(tabButtons) do
                if b.BackgroundColor3 ~= Color3.fromRGB(20, 20, 28) then
                    TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = color1}):Play()
                end
            end
        end)
        table.insert(ThemeRows, ThemeText)
    end

    -- Цветовые схемы
    createThemeRow(Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 70, 200))
    createThemeRow(Color3.fromRGB(168, 85, 247), Color3.fromRGB(100, 30, 180))
    createThemeRow(Color3.fromRGB(34, 197, 94), Color3.fromRGB(20, 100, 50))
    createThemeRow(Color3.fromRGB(236, 72, 153), Color3.fromRGB(150, 20, 80))
    createThemeRow(Color3.fromRGB(245, 158, 11), Color3.fromRGB(160, 80, 0))
    createThemeRow(Color3.fromRGB(220, 220, 230), Color3.fromRGB(100, 100, 110))

    -- Обновление размеров скролла
    ThemeScroll.CanvasSize = UDim2.new(0, 0, 0, ThemeList.AbsoluteContentSize.Y + 40)

    -- Заглушки для других страниц (можно добавить текст или оставить пустыми)
    local function addPlaceholderText(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Parent = parent
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextColor3 = Color3.fromRGB(150, 150, 170)
        lbl.TextSize = 18
        lbl.Text = text
        lbl.TextWrapped = true
        return lbl
    end
    addPlaceholderText(AutoFarmPage, "Страница AutoFarm (функции удалены)")
    addPlaceholderText(MovementPage, "Страница Movement (функции удалены)")
    addPlaceholderText(AdminPage, "Страница Admin (функции удалены)")

    -- Глобальная функция обновления языка (вызывается после выбора)
    _G.ApplyLanguage = function()
        ThemeTitleLabel.Text = L("ThemeTitle")
        autoFarmTabBtn.Text = L("AutoFarmTab")
        themeTabBtn.Text = L("ThemeTab")
        movementTabBtn.Text = L("MovementTab")
        adminTabBtn.Text = L("AdminTab")
        for i, rowText in ipairs(ThemeRows) do
            if L("Themes")[i] then rowText.Text = L("Themes")[i] end
        end
    end

    -- Применяем язык по умолчанию
    _G.ApplyLanguage()

    -- Убираем лишние глобальные переменные (чистота)
    _G.UpdateColors = nil
    _G.ApplyLanguage = nil -- но она нам нужна для смены языка, оставим, но можно удалить после применения

    print("Меню загружено (только интерфейс).")
end
