--[[
    NKNO$ HUB — финальная полная версия с категориями
]]

do
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    if game.CoreGui:FindFirstChild("NknoHub") then game.CoreGui.NknoHub:Destroy() end

    local lang = "RU"
    local Locales = {
        RU = {
            MainTab = "Главная",
            VisualsTab = "Визуал",
            MiscTab = "Разное",
            SettingsTab = "Настройки",
            MurderFunc = "Функции убийцы",
            KillAll = "Убить всех",
            KillAllDesc = "Убить всех невиновных",
            SheriffFunc = "Функции шерифа",
            AutoShoot = "Авто-выстрел",
            AutoShootDesc = "Создать кнопку для стрельбы в убийцу",
            MagicBullet = "Магическая пуля",
            MagicBulletDesc = "Первый аргумент – позиция убийцы",
            InnocentFunc = "Функции невиновного",
            AutoGrab = "Авто-подбор пистолета",
            AutoGrabDesc = "Автоматически подбирать пистолет, если шериф умер",
            FlingSection = "Флинг игроков",
            PlayerSearch = "Поиск игрока",
            FlingMurderer = "Флинг убийцы",
            FlingSheriff = "Флинг шерифа",
            FlingSelected = "Флинг выбранного",
            StopFling = "Остановить флинг",
            FarmSection = "Автофарм",
            FarmToggle = "Фарм монет",
            FarmDesc = "Автоматический сбор монет с noclip",
            RandomDelays = "Случайные задержки",
            RandomDelaysDesc = "Задержки между сборами",
            RandomMovement = "Случайное движение",
            RandomMovementDesc = "Смещения при движении к монете",
            RandomCoin = "Случайный выбор монеты",
            RandomCoinDesc = "Выбирать случайную из ближайших",
            AntiAFK = "Anti-AFK",
            AntiAFKDesc = "Имитация движения",
            MinDelay = "Мин. задержка (с)",
            MaxDelay = "Макс. задержка (с)",
            ChamsSection = "Чаксы",
            ChamsMurderer = "Чаксы убийцы",
            ChamsSheriff = "Чаксы шерифа",
            ChamsInnocent = "Чаксы невиновного",
            ChamsHero = "Чаксы героя",
            ESPSection = "ESP",
            ESPMurderer = "ESP убийцы",
            ESPSheriff = "ESP шерифа",
            ESPInnocent = "ESP невиновного",
            ESPHero = "ESP героя",
            ESPCustom = "Настройки ESP",
            Box2D = "2D Box",
            DisplayName = "Отображать ник",
            NormalName = "Обычное имя",
            AvatarDisplay = "Аватар",
            Teleports = "Телепорты",
            MapTP = "На карту",
            LobbyTP = "В лобби",
            MurderTP = "К убийце",
            SheriffTP = "К шерифу",
            Dances = "Танцы",
            SelectDance = "Выбрать танец",
            AutoDance = "Авто-танец",
            UnderMap = "UnderMap",
            UnderMapDesc = "Телепорт под карту (неуязвимость)",
            CharMods = "Модификаторы персонажа",
            WalkSpeed = "Скорость ходьбы",
            JumpPower = "Сила прыжка",
            FOV = "Поле зрения (FOV)",
            ForceField = "ForceField на теле",
            LangSelect = "Язык",
            ThemeSelect = "Тема",
            UISettings = "Настройки UI",
            UIBlur = "Размытие фона",
            UITransparency = "Прозрачность",
            Copied = "Скопировано!",
        },
        EN = {
            MainTab = "Main",
            VisualsTab = "Visuals",
            MiscTab = "Misc",
            SettingsTab = "Settings",
            MurderFunc = "Murder Functions",
            KillAll = "Kill All",
            KillAllDesc = "Kill all innocents",
            SheriffFunc = "Sheriff Functions",
            AutoShoot = "Auto Shoot Button",
            AutoShootDesc = "Create a draggable shoot button",
            MagicBullet = "Magic Bullet",
            MagicBulletDesc = "First argument set to murderer position",
            InnocentFunc = "Innocent Functions",
            AutoGrab = "Auto Grab Gun",
            AutoGrabDesc = "Automatically grab gun if sheriff died",
            FlingSection = "Fling Players",
            PlayerSearch = "Player Search",
            FlingMurderer = "Fling Murderer",
            FlingSheriff = "Fling Sheriff",
            FlingSelected = "Fling Selected",
            StopFling = "Stop Fling",
            FarmSection = "Auto Farm",
            FarmToggle = "Farm Coins",
            FarmDesc = "Automatically farm coins with noclip",
            RandomDelays = "Random Delays",
            RandomDelaysDesc = "Add random delays between pickups",
            RandomMovement = "Random Movement",
            RandomMovementDesc = "Add random offsets to movement",
            RandomCoin = "Random Coin Selection",
            RandomCoinDesc = "Pick random nearby coin",
            AntiAFK = "Anti-AFK",
            AntiAFKDesc = "Send random movements to avoid kick",
            MinDelay = "Min Delay (s)",
            MaxDelay = "Max Delay (s)",
            ChamsSection = "Chams",
            ChamsMurderer = "Chams Murderer",
            ChamsSheriff = "Chams Sheriff",
            ChamsInnocent = "Chams Innocent",
            ChamsHero = "Chams Hero",
            ESPSection = "ESP",
            ESPMurderer = "ESP Murderer",
            ESPSheriff = "ESP Sheriff",
            ESPInnocent = "ESP Innocent",
            ESPHero = "ESP Hero",
            ESPCustom = "ESP Customization",
            Box2D = "2D Box",
            DisplayName = "Display Name",
            NormalName = "Normal Name",
            AvatarDisplay = "Avatar Display",
            Teleports = "Teleports",
            MapTP = "Map TP",
            LobbyTP = "Lobby TP",
            MurderTP = "Murder TP",
            SheriffTP = "Sheriff TP",
            Dances = "Dance Emotes",
            SelectDance = "Select Dance",
            AutoDance = "Auto Dance",
            UnderMap = "UnderMap Mode",
            UnderMapDesc = "Teleport under the map (invincible)",
            CharMods = "Character Modifiers",
            WalkSpeed = "WalkSpeed",
            JumpPower = "JumpPower",
            FOV = "FOV",
            ForceField = "ForceField Body",
            LangSelect = "Language",
            ThemeSelect = "Theme",
            UISettings = "UI Settings",
            UIBlur = "UI Blur",
            UITransparency = "Transparency",
            Copied = "Copied!",
        }
    }

    local function L(key) return Locales[lang][key] end

    -- Переменные настроек
    local farming = false
    local farmingActive = false
    local autoGrabGun = false
    local isFlinging = false
    local selectedPlayer = nil
    local randomDelays = false
    local randomMovement = false
    local antiAFK = false
    local minDelay = 0.1
    local maxDelay = 0.5
    local randomCoinSelection = false
    local underMapActive = false
    local underMapConnection = nil
    local oldFallenHeight = workspace.FallenPartsDestroyHeight
    local customWalkSpeed = false
    local customJumpPower = false
    local walkSpeedValue = 16
    local jumpPowerValue = 50
    local customFOV = false
    local fovValue = 70
    local forceFieldMaterial = false
    local danceActive = false
    local currentDanceID = "127118661424463"
    local danceAnim = nil
    local autoShootActive = false
    local shootButtonGui = nil
    local isDragging = false
    local dragStart = nil
    local buttonStartPos = nil
    local magicBullet = false
    local bulletVelocity = 1.25
    local ESP_SETTINGS = { Murderer = false, Sheriff = false, Innocent = false, Hero = false }
    local NAME_ESP_SETTINGS = { Murderer = false, Sheriff = false, Innocent = false, Hero = false }
    local ESP_CUSTOMIZATION = { Box2D = false, DisplayName = false, NormalName = true, AvatarDisplay = false }
    local accentColor = Color3.fromRGB(0, 150, 255)

    -- Вспомогательные функции
    local function findMap()
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:GetAttribute("MapID") then return obj end
        end
        return nil
    end

    local coinContainerCache = nil
    local coinContainerCacheTime = 0
    local function returnCoinContainer()
        if coinContainerCache and (tick() - coinContainerCacheTime < 0.5) then
            return coinContainerCache
        end
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:FindFirstChild("CoinContainer") and obj:IsA("Model") then
                coinContainerCache = obj:FindFirstChild("CoinContainer")
                coinContainerCacheTime = tick()
                return coinContainerCache
            end
        end
        return nil
    end

    local function getPing()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end

    local murdererCache = nil
    local murdererCacheTime = 0
    local function findMurderer()
        if murdererCache and (tick() - murdererCacheTime < 0.5) then return murdererCache end
        local dataEvent = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if not dataEvent then return nil end
        local success, data = pcall(function() return dataEvent:InvokeServer() end)
        if not success or not data then return nil end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
                local info = data[plr.Name]
                if info and info.Role == "Murderer" then
                    murdererCache = plr
                    murdererCacheTime = tick()
                    return plr
                end
            end
        end
        murdererCache = nil
        return nil
    end

    local function FindNearestCoin(container, useRandom)
        if not container then return nil, math.huge end
        local candidates = {}
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return nil, math.huge end
        local pos = root.Position
        for _, coin in pairs(container:GetChildren()) do
            if coin:GetAttribute("CoinID") == "Coin" and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 then
                local dist = (pos - coin.Position).Magnitude
                table.insert(candidates, {coin = coin, dist = dist})
            end
        end
        if #candidates == 0 then return nil, math.huge end
        table.sort(candidates, function(a,b) return a.dist < b.dist end)
        if useRandom and #candidates > 2 then
            local idx = math.random(1, math.min(3, #candidates))
            return candidates[idx].coin, candidates[idx].dist
        else
            return candidates[1].coin, candidates[1].dist
        end
    end

    local function FindPlayerByPartialName(name)
        if not name or name == "" then return nil end
        name = string.lower(name)
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and string.lower(plr.Name) == name then return plr end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and string.sub(string.lower(plr.Name), 1, #name) == name then return plr end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and string.find(string.lower(plr.Name), name, 1, true) then return plr end
        end
        return nil
    end

    -- ===== ПОСТРОЕНИЕ GUI =====
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NknoHub"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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

    local BgImage = Instance.new("ImageLabel")
    BgImage.Name = "BackgroundImage"
    BgImage.Parent = MainFrame
    BgImage.BackgroundTransparency = 1
    BgImage.Size = UDim2.new(1, 0, 1, 0)
    BgImage.Image = "rbxassetid://121149051147413"
    BgImage.ScaleType = Enum.ScaleType.Crop
    BgImage.ImageTransparency = 0.35
    BgImage.ZIndex = 0
    Instance.new("UICorner", BgImage).CornerRadius = UDim.new(0, 14)

    local MainScale = Instance.new("UIScale", MainFrame)
    MainScale.Scale = 0.3
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Rotation = 90
    MainGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 0.5) })
    MainGradient.Parent = MainFrame
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = Color3.fromRGB(35, 35, 50)
    MainStroke.Thickness = 1.5

    local isMenuOpen = false
    local function toggleMenu(forceState)
        if forceState ~= nil then isMenuOpen = forceState else isMenuOpen = not isMenuOpen end
        if isMenuOpen then
            MainFrame.Visible = true
            ShadowFrame.Visible = true
            TweenService:Create(MainScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 0.8 }):Play()
            TweenService:Create(ShadowScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 0.8 }):Play()
        else
            local closeTween = TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Scale = 0.2 })
            TweenService:Create(ShadowScale, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Scale = 0.2 }):Play()
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if not isMenuOpen then
                    MainFrame.Visible = false
                    ShadowFrame.Visible = false
                end
            end)
        end
    end

    local ToggleWidget = Instance.new("Frame")
    ToggleWidget.Name = "ToggleWidget"
    ToggleWidget.Parent = ScreenGui
    ToggleWidget.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    ToggleWidget.BackgroundTransparency = 0.15
    ToggleWidget.Position = UDim2.new(0.5, -80, 0.08, 0)
    ToggleWidget.Size = UDim2.new(0, 160, 0, 44)
    ToggleWidget.Visible = true
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
    ToggleLabelText.Text = "Nkno$ hub"
    ToggleLabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabelText.TextSize = 17
    local ToggleGradient = Instance.new("UIGradient")
    ToggleGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) })
    ToggleGradient.Parent = ToggleLabelText

    local dragToggle, dragInputT, dragStartT, startPosT, dragStartTime = false
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
    local isMinimized = false
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 640, 0, 52) }):Play()
            TweenService:Create(ShadowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 646, 0, 58) }):Play()
            MinBtn.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 640, 0, 420) }):Play()
            TweenService:Create(ShadowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 646, 0, 426) }):Play()
            MinBtn.Text = "-"
        end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    Sidebar.BackgroundTransparency = 0.1
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)
    local SidebarGradient = Instance.new("UIGradient")
    SidebarGradient.Rotation = 90
    SidebarGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.4) })
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
    SidebarFixGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.4) })
    SidebarFixGradient.Parent = SidebarFix

    local Title = Instance.new("TextLabel")
    Title.Parent = Sidebar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 16)
    Title.Size = UDim2.new(1, 0, 0, 26)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Nkno$ hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) })
    TitleGradient.Parent = Title
    local SepLine = Instance.new("Frame")
    SepLine.Parent = Sidebar
    SepLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SepLine.Position = UDim2.new(0.1, 0, 0, 52)
    SepLine.Size = UDim2.new(0.8, 0, 0, 1)
    local SepGradient = Instance.new("UIGradient")
    SepGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)), ColorSequenceKeypoint.new(0.5, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35)) })
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

    local ContentArea = Instance.new("Frame")
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = false
    ContentArea.Position = UDim2.new(0, 185, 0, 15)
    ContentArea.Size = UDim2.new(1, -200, 1, -30)

    -- Страницы
    local mainPage = Instance.new("ScrollingFrame")
    mainPage.Parent = ContentArea
    mainPage.BackgroundTransparency = 1
    mainPage.Size = UDim2.new(1, 0, 1, 0)
    mainPage.ScrollBarThickness = 0
    mainPage.Visible = true
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.Parent = mainPage
    mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainLayout.Padding = UDim.new(0, 8)

    local visualsPage = Instance.new("ScrollingFrame")
    visualsPage.Parent = ContentArea
    visualsPage.BackgroundTransparency = 1
    visualsPage.Size = UDim2.new(1, 0, 1, 0)
    visualsPage.ScrollBarThickness = 0
    visualsPage.Visible = false
    local visLayout = Instance.new("UIListLayout")
    visLayout.Parent = visualsPage
    visLayout.SortOrder = Enum.SortOrder.LayoutOrder
    visLayout.Padding = UDim.new(0, 8)

    local miscPage = Instance.new("ScrollingFrame")
    miscPage.Parent = ContentArea
    miscPage.BackgroundTransparency = 1
    miscPage.Size = UDim2.new(1, 0, 1, 0)
    miscPage.ScrollBarThickness = 0
    miscPage.Visible = false
    local miscLayout = Instance.new("UIListLayout")
    miscLayout.Parent = miscPage
    miscLayout.SortOrder = Enum.SortOrder.LayoutOrder
    miscLayout.Padding = UDim.new(0, 8)

    local settingsPage = Instance.new("ScrollingFrame")
    settingsPage.Parent = ContentArea
    settingsPage.BackgroundTransparency = 1
    settingsPage.Size = UDim2.new(1, 0, 1, 0)
    settingsPage.ScrollBarThickness = 0
    settingsPage.Visible = false
    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.Parent = settingsPage
    settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    settingsLayout.Padding = UDim.new(0, 8)

    -- Функции добавления элементов
    local languageElements = {}
    local function addSection(parent, key)
        local label = Instance.new("TextLabel")
        label.Parent = parent
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -10, 0, 24)
        label.Font = Enum.Font.GothamBold
        label.Text = L(key)
        label.TextColor3 = Color3.fromRGB(180, 180, 200)
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(languageElements, {obj = label, key = key})
        return label
    end

    local function addButton(parent, key, descKey, callback)
        local btn = Instance.new("TextButton")
        btn.Parent = parent
        btn.Size = UDim2.new(1, -10, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        btn.BackgroundTransparency = 0.1
        btn.BorderSizePixel = 0
        btn.Text = L(key)
        btn.TextColor3 = Color3.fromRGB(230, 230, 240)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamSemibold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(callback)
        table.insert(languageElements, {obj = btn, key = key})
        if descKey and descKey ~= "" then
            local tip = Instance.new("TextLabel")
            tip.Parent = btn
            tip.Size = UDim2.new(1, 0, 0, 14)
            tip.Position = UDim2.new(0, 8, 1, -16)
            tip.BackgroundTransparency = 1
            tip.Text = L(descKey)
            tip.TextColor3 = Color3.fromRGB(150, 150, 170)
            tip.TextSize = 11
            tip.Font = Enum.Font.Gotham
            tip.TextXAlignment = Enum.TextXAlignment.Left
            tip.TextTruncate = Enum.TextTruncate.AtEnd
            table.insert(languageElements, {obj = tip, key = descKey})
        end
        return btn
    end

    local function addToggle(parent, key, descKey, default, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -10, 0, 34)
        frame.BackgroundTransparency = 1
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = L(key)
        label.TextColor3 = Color3.fromRGB(230, 230, 240)
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd
        table.insert(languageElements, {obj = label, key = key})
        if descKey and descKey ~= "" then
            local dlab = Instance.new("TextLabel")
            dlab.Parent = frame
            dlab.Size = UDim2.new(0.65, 0, 0, 14)
            dlab.Position = UDim2.new(0, 0, 1, -16)
            dlab.BackgroundTransparency = 1
            dlab.Text = L(descKey)
            dlab.TextColor3 = Color3.fromRGB(150, 150, 170)
            dlab.TextSize = 10
            dlab.Font = Enum.Font.Gotham
            dlab.TextXAlignment = Enum.TextXAlignment.Left
            dlab.TextTruncate = Enum.TextTruncate.AtEnd
            table.insert(languageElements, {obj = dlab, key = descKey})
        end
        local toggle = Instance.new("TextButton")
        toggle.Parent = frame
        toggle.Size = UDim2.new(0, 50, 0, 24)
        toggle.Position = UDim2.new(1, -56, 0.5, -12)
        toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(60, 60, 70)
        toggle.BorderSizePixel = 0
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 13
        toggle.Font = Enum.Font.GothamBold
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)
        local state = default
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(60, 60, 70)
            toggle.Text = state and "ON" or "OFF"
            if callback then callback(state) end
        end)
        if callback then callback(default) end
        return frame
    end

    local function addSlider(parent, key, descKey, default, min, max, decimals, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -10, 0, 44)
        frame.BackgroundTransparency = 1
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.6, 0, 0.5, 0)
        label.BackgroundTransparency = 1
        label.Text = L(key) .. " (" .. tostring(default) .. ")"
        label.TextColor3 = Color3.fromRGB(230, 230, 240)
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(languageElements, {obj = label, key = key})
        if descKey and descKey ~= "" then
            local dlab = Instance.new("TextLabel")
            dlab.Parent = frame
            dlab.Size = UDim2.new(0.6, 0, 0.5, 0)
            dlab.Position = UDim2.new(0, 0, 0.5, 0)
            dlab.BackgroundTransparency = 1
            dlab.Text = L(descKey)
            dlab.TextColor3 = Color3.fromRGB(150, 150, 170)
            dlab.TextSize = 10
            dlab.Font = Enum.Font.Gotham
            dlab.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(languageElements, {obj = dlab, key = descKey})
        end
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Parent = frame
        sliderFrame.Size = UDim2.new(0.35, 0, 0.3, 0)
        sliderFrame.Position = UDim2.new(0.6, 0, 0.35, 0)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        sliderFrame.BorderSizePixel = 0
        Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 4)
        local fill = Instance.new("Frame")
        fill.Parent = sliderFrame
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = accentColor
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
        local value = default
        local function updateSlider(val)
            val = math.clamp(val, min, max)
            if decimals then
                local mult = 10^decimals
                val = math.round(val * mult) / mult
            else
                val = math.round(val)
            end
            value = val
            fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
            label.Text = L(key) .. " (" .. tostring(val) .. ")"
            if callback then callback(val) end
        end
        sliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local x = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
                local val = min + (max - min) * math.clamp(x, 0, 1)
                updateSlider(val)
            end
        end)
        sliderFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local x = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
                    local val = min + (max - min) * math.clamp(x, 0, 1)
                    updateSlider(val)
                end
            end
        end)
        return frame
    end

    local function addDropdown(parent, key, options, default, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -10, 0, 34)
        frame.BackgroundTransparency = 1
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = L(key)
        label.TextColor3 = Color3.fromRGB(230, 230, 240)
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(languageElements, {obj = label, key = key})
        local dropBtn = Instance.new("TextButton")
        dropBtn.Parent = frame
        dropBtn.Size = UDim2.new(0.4, 0, 1, 0)
        dropBtn.Position = UDim2.new(0.6, 0, 0, 0)
        dropBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        dropBtn.BackgroundTransparency = 0.1
        dropBtn.BorderSizePixel = 0
        dropBtn.Text = default or "Select"
        dropBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
        dropBtn.TextSize = 14
        dropBtn.Font = Enum.Font.GothamMedium
        Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 6)
        local dropList = Instance.new("Frame")
        dropList.Parent = frame
        dropList.Size = UDim2.new(0.4, 0, 0, 0)
        dropList.Position = UDim2.new(0.6, 0, 1, 0)
        dropList.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        dropList.BorderSizePixel = 0
        dropList.ClipsDescendants = true
        Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 6)
        local visible = false
        local current = default
        local function updateDropdown(selected)
            current = selected
            dropBtn.Text = selected
            if callback then callback(selected) end
            visible = false
            dropList.Size = UDim2.new(0.4, 0, 0, 0)
        end
        dropBtn.MouseButton1Click:Connect(function()
            visible = not visible
            if visible then
                local count = 0
                for _,_ in pairs(options) do count = count + 1 end
                dropList.Size = UDim2.new(0.4, 0, 0, math.min(count * 26, 150))
            else
                dropList.Size = UDim2.new(0.4, 0, 0, 0)
            end
        end)
        local y = 0
        for keyOpt, valOpt in pairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Parent = dropList
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.Position = UDim2.new(0, 0, 0, y)
            optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            optBtn.BorderSizePixel = 0
            optBtn.Text = keyOpt
            optBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
            optBtn.TextSize = 14
            optBtn.Font = Enum.Font.GothamMedium
            optBtn.MouseButton1Click:Connect(function()
                updateDropdown(keyOpt)
            end)
            y = y + 26
        end
        if default then updateDropdown(default) end
        return frame
    end

    local function addInput(parent, key, descKey, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -10, 0, 34)
        frame.BackgroundTransparency = 1
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = L(key)
        label.TextColor3 = Color3.fromRGB(230, 230, 240)
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(languageElements, {obj = label, key = key})
        if descKey and descKey ~= "" then
            local dlab = Instance.new("TextLabel")
            dlab.Parent = frame
            dlab.Size = UDim2.new(0.4, 0, 0.5, 0)
            dlab.Position = UDim2.new(0, 0, 0.5, 0)
            dlab.BackgroundTransparency = 1
            dlab.Text = L(descKey)
            dlab.TextColor3 = Color3.fromRGB(150, 150, 170)
            dlab.TextSize = 10
            dlab.Font = Enum.Font.Gotham
            dlab.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(languageElements, {obj = dlab, key = descKey})
        end
        local box = Instance.new("TextBox")
        box.Parent = frame
        box.Size = UDim2.new(0.5, 0, 1, 0)
        box.Position = UDim2.new(0.5, 0, 0, 0)
        box.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        box.BackgroundTransparency = 0.1
        box.BorderSizePixel = 0
        box.Text = ""
        box.TextColor3 = Color3.fromRGB(230, 230, 240)
        box.TextSize = 14
        box.Font = Enum.Font.GothamMedium
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        box.FocusLost:Connect(function()
            if callback then callback(box.Text) end
        end)
        return frame
    end

    -- ===== НАПОЛНЕНИЕ СТРАНИЦ =====

    -- MAIN PAGE
    addSection(mainPage, "MurderFunc")
    addButton(mainPage, "KillAll", "KillAllDesc", function()
        if not LocalPlayer then return end
        local char = LocalPlayer.Character
        if not char or not char.Parent then return end
        local knife = char:FindFirstChild("Knife")
        if not knife then
            knife = LocalPlayer.Backpack:FindFirstChild("Knife")
            if knife then knife.Parent = char else return end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        tRoot.Size = Vector3.new(5,5,5)
                        tRoot.CFrame = root.CFrame + root.CFrame.LookVector * 3
                        tRoot.Anchored = true
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,true,game,0)
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,false,game,0)
                    end
                end
            end
        end
    end)

    addSection(mainPage, "SheriffFunc")
    addToggle(mainPage, "AutoShoot", "AutoShootDesc", autoShootActive, function(val)
        autoShootActive = val
        if val then
            if not shootButtonGui then
                local gui = Instance.new("ScreenGui")
                gui.Name = "ShootButtonGui"
                gui.ResetOnSpawn = false
                gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                gui.Parent = game:GetService("CoreGui")
                local btn = Instance.new("ImageButton")
                btn.Name = "ShootButton"
                btn.Size = UDim2.new(0,80,0,80)
                btn.Position = UDim2.new(0.5,-40,0.5,-40)
                btn.BackgroundColor3 = Color3.fromRGB(255,50,50)
                btn.BackgroundTransparency = 0.3
                btn.BorderSizePixel = 0
                btn.Parent = gui
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(1,0)
                corner.Parent = btn
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = "🔫"
                label.TextSize = 32
                label.TextColor3 = Color3.fromRGB(255,255,255)
                label.Font = Enum.Font.GothamBold
                label.Parent = btn
                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDragging = true
                        dragStart = input.Position
                        buttonStartPos = btn.Position
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                isDragging = false
                            end
                        end)
                    end
                end)
                btn.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if isDragging then
                            local delta = input.Position - dragStart
                            btn.Position = UDim2.new(buttonStartPos.X.Scale, buttonStartPos.X.Offset + delta.X, buttonStartPos.Y.Scale, buttonStartPos.Y.Offset + delta.Y)
                        end
                    end
                end)
                btn.MouseButton1Click:Connect(function()
                    if isDragging then return end
                    local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
                    if not gun then
                        gun = LocalPlayer.Backpack:FindFirstChild("Gun")
                        if gun then gun.Parent = LocalPlayer.Character end
                    end
                    if not gun then return end
                    local murderer = findMurderer()
                    if not murderer then return end
                    local mChar = murderer.Character
                    if not mChar or not mChar:FindFirstChild("HumanoidRootPart") then return end
                    local mRoot = mChar.HumanoidRootPart
                    local torso = mChar:FindFirstChild("Torso") or mChar:FindFirstChild("UpperTorso")
                    local hum = mChar:FindFirstChild("Humanoid")
                    if not torso or not hum then return end
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not myRoot then return end
                    local ping = getPing()
                    local pred = (ping/1000) * bulletVelocity
                    local targetPos = torso.Position + (mRoot.Velocity * pred)
                    local shootCFrame
                    if magicBullet then
                        shootCFrame = CFrame.new(torso.Position, targetPos)
                    else
                        shootCFrame = CFrame.new(myRoot.Position, targetPos)
                    end
                    local targetCF = CFrame.new(targetPos)
                    local shootEvent = gun:FindFirstChild("ShootEvent") or gun:FindFirstChild("Shoot")
                    if shootEvent then shootEvent:FireServer(shootCFrame, targetCF) end
                end)
                shootButtonGui = gui
            end
        else
            if shootButtonGui then shootButtonGui:Destroy() shootButtonGui = nil end
        end
    end)
    addToggle(mainPage, "MagicBullet", "MagicBulletDesc", magicBullet, function(val) magicBullet = val end)

    addSection(mainPage, "InnocentFunc")
    addToggle(mainPage, "AutoGrab", "AutoGrabDesc", autoGrabGun, function(val) autoGrabGun = val end)

    addSection(mainPage, "FlingSection")
    addInput(mainPage, "PlayerSearch", "", function(input)
        local found = FindPlayerByPartialName(input)
        if found then
            selectedPlayer = found
            local notif = Instance.new("TextLabel")
            notif.Size = UDim2.new(0.5, 0, 0, 28)
            notif.Position = UDim2.new(0.25, 0, 0.1, 0)
            notif.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            notif.Text = L("Copied") .. " " .. found.Name
            notif.TextColor3 = Color3.fromRGB(255,255,255)
            notif.TextSize = 14
            notif.Font = Enum.Font.GothamBold
            notif.ZIndex = 10
            notif.Parent = MainFrame
            task.delay(2, function() notif:Destroy() end)
        else
            selectedPlayer = nil
            if input ~= "" then
                local notif = Instance.new("TextLabel")
                notif.Size = UDim2.new(0.5, 0, 0, 28)
                notif.Position = UDim2.new(0.25, 0, 0.1, 0)
                notif.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
                notif.Text = "Not found: " .. input
                notif.TextColor3 = Color3.fromRGB(255,255,255)
                notif.TextSize = 14
                notif.Font = Enum.Font.GothamBold
                notif.ZIndex = 10
                notif.Parent = MainFrame
                task.delay(2, function() notif:Destroy() end)
            end
        end
    end)

    local function SkidFling(target)
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
        if not myHumanoid then return end
        local myRoot = myHumanoid.RootPart
        if not myRoot then return end
        local tChar = target.Character
        if not tChar then return end
        local tHumanoid = tChar:FindFirstChildOfClass("Humanoid")
        if not tHumanoid then return end
        local tRoot = tHumanoid.RootPart
        if not tRoot then return end
        local tHead = tChar:FindFirstChild("Head")
        local tAccessory = tChar:FindFirstChildOfClass("Accessory")
        local tHandle = tAccessory and tAccessory:FindFirstChild("Handle")
        if myRoot.Velocity.Magnitude < 50 then
            getgenv().OldPos = myRoot.CFrame
        end
        if tHumanoid.Sit then return end
        if tHead then
            workspace.CurrentCamera.CameraSubject = tHead
        elseif tHandle then
            workspace.CurrentCamera.CameraSubject = tHandle
        else
            workspace.CurrentCamera.CameraSubject = tHumanoid
        end
        local function setPos(part, offset, angle)
            myRoot.CFrame = CFrame.new(part.Position) * offset * angle
            myChar:SetPrimaryPartCFrame(CFrame.new(part.Position) * offset * angle)
            myRoot.Velocity = Vector3.new(9e7, 9e7*10, 9e7)
            myRoot.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local flingLoop
        flingLoop = function(part)
            local startTime = tick()
            local duration = 5
            local count = 0
            while isFlinging and tick() - startTime < duration do
                if myRoot and part then
                    if part.Velocity.Magnitude < 50 then
                        count = count + 100
                        setPos(part, CFrame.new(0, 1.5, 0) + tHumanoid.MoveDirection * part.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(count),0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, -1.5, 0) + tHumanoid.MoveDirection * part.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(count),0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, 1.5, 0) + tHumanoid.MoveDirection * part.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(count),0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, -1.5, 0) + tHumanoid.MoveDirection * part.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(count),0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, 1.5, 0) + tHumanoid.MoveDirection, CFrame.Angles(math.rad(count),0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, -1.5, 0) + tHumanoid.MoveDirection, CFrame.Angles(math.rad(count),0,0))
                        task.wait()
                    else
                        setPos(part, CFrame.new(0, 1.5, tHumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, -1.5, -tHumanoid.WalkSpeed), CFrame.Angles(0,0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, 1.5, tHumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0,0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        setPos(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0,0,0))
                        task.wait()
                    end
                end
            end
        end
        workspace.FallenPartsDestroyHeight = 0/0
        local bv = Instance.new("BodyVelocity")
        bv.Parent = myRoot
        bv.Velocity = Vector3.new(0,0,0)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        myHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if tRoot then flingLoop(tRoot) elseif tHead then flingLoop(tHead) elseif tHandle then flingLoop(tHandle) end
        bv:Destroy()
        myHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = myHumanoid
        if getgenv().OldPos then
            repeat
                myRoot.CFrame = getgenv().OldPos * CFrame.new(0,0.5,0)
                myChar:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0,0.5,0))
                myHumanoid:ChangeState("GettingUp")
                for _, part in pairs(myChar:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.new()
                        part.RotVelocity = Vector3.new()
                    end
                end
                task.wait()
            until (myRoot.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end

    addButton(mainPage, "FlingMurderer", "", function()
        if isFlinging then return end
        local murderer = findMurderer()
        if murderer then
            isFlinging = true
            task.spawn(function()
                SkidFling(murderer)
                isFlinging = false
            end)
        end
    end)
    addButton(mainPage, "FlingSheriff", "", function()
        if isFlinging then return end
        local dataEvent = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if not dataEvent then return end
        local success, data = pcall(function() return dataEvent:InvokeServer() end)
        if success and data then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
                    local info = data[plr.Name]
                    if info and info.Role == "Sheriff" then
                        isFlinging = true
                        task.spawn(function()
                            SkidFling(plr)
                            isFlinging = false
                        end)
                        break
                    end
                end
            end
        end
    end)
    addButton(mainPage, "FlingSelected", "", function()
        if isFlinging then return end
        if not selectedPlayer or not selectedPlayer.Parent then
            local notif = Instance.new("TextLabel")
            notif.Size = UDim2.new(0.5, 0, 0, 28)
            notif.Position = UDim2.new(0.25, 0, 0.1, 0)
            notif.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            notif.Text = "Select a player first!"
            notif.TextColor3 = Color3.fromRGB(255,255,255)
            notif.TextSize = 14
            notif.Font = Enum.Font.GothamBold
            notif.ZIndex = 10
            notif.Parent = MainFrame
            task.delay(2, function() notif:Destroy() end)
            return
        end
        isFlinging = true
        task.spawn(function()
            SkidFling(selectedPlayer)
            isFlinging = false
        end)
    end)
    addButton(mainPage, "StopFling", "", function()
        if isFlinging then isFlinging = false end
    end)

    addSection(mainPage, "FarmSection")
    addToggle(mainPage, "FarmToggle", "FarmDesc", farming, function(val)
        farming = val
        if not val then farmingActive = false end
    end)
    addToggle(mainPage, "RandomDelays", "RandomDelaysDesc", randomDelays, function(val) randomDelays = val end)
    addToggle(mainPage, "RandomMovement", "RandomMovementDesc", randomMovement, function(val) randomMovement = val end)
    addToggle(mainPage, "RandomCoin", "RandomCoinDesc", randomCoinSelection, function(val) randomCoinSelection = val end)
    addToggle(mainPage, "AntiAFK", "AntiAFKDesc", antiAFK, function(val) antiAFK = val end)
    addSlider(mainPage, "MinDelay", "", minDelay, 0, 1, 2, function(val) minDelay = val end)
    addSlider(mainPage, "MaxDelay", "", maxDelay, 0, 2, 2, function(val) maxDelay = val end)

    -- VISUALS PAGE
    addSection(visualsPage, "ChamsSection")
    addToggle(visualsPage, "ChamsMurderer", "", ESP_SETTINGS.Murderer, function(v) ESP_SETTINGS.Murderer = v end)
    addToggle(visualsPage, "ChamsSheriff", "", ESP_SETTINGS.Sheriff, function(v) ESP_SETTINGS.Sheriff = v end)
    addToggle(visualsPage, "ChamsInnocent", "", ESP_SETTINGS.Innocent, function(v) ESP_SETTINGS.Innocent = v end)
    addToggle(visualsPage, "ChamsHero", "", ESP_SETTINGS.Hero, function(v) ESP_SETTINGS.Hero = v end)

    addSection(visualsPage, "ESPSection")
    addToggle(visualsPage, "ESPMurderer", "", NAME_ESP_SETTINGS.Murderer, function(v) NAME_ESP_SETTINGS.Murderer = v end)
    addToggle(visualsPage, "ESPSheriff", "", NAME_ESP_SETTINGS.Sheriff, function(v) NAME_ESP_SETTINGS.Sheriff = v end)
    addToggle(visualsPage, "ESPInnocent", "", NAME_ESP_SETTINGS.Innocent, function(v) NAME_ESP_SETTINGS.Innocent = v end)
    addToggle(visualsPage, "ESPHero", "", NAME_ESP_SETTINGS.Hero, function(v) NAME_ESP_SETTINGS.Hero = v end)

    addSection(visualsPage, "ESPCustom")
    addToggle(visualsPage, "Box2D", "", ESP_CUSTOMIZATION.Box2D, function(v) ESP_CUSTOMIZATION.Box2D = v end)
    addToggle(visualsPage, "DisplayName", "", ESP_CUSTOMIZATION.DisplayName, function(v)
        ESP_CUSTOMIZATION.DisplayName = v
        if v then ESP_CUSTOMIZATION.NormalName = false end
    end)
    addToggle(visualsPage, "NormalName", "", ESP_CUSTOMIZATION.NormalName, function(v)
        ESP_CUSTOMIZATION.NormalName = v
        if v then ESP_CUSTOMIZATION.DisplayName = false end
    end)
    addToggle(visualsPage, "AvatarDisplay", "", ESP_CUSTOMIZATION.AvatarDisplay, function(v) ESP_CUSTOMIZATION.AvatarDisplay = v end)

    -- MISC PAGE
    addSection(miscPage, "Teleports")
    addButton(miscPage, "MapTP", "", function()
        local map = findMap()
        if map and map:FindFirstChild("Spawns") then
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 and LocalPlayer.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
            end
        end
    end)
    addButton(miscPage, "LobbyTP", "", function()
        local lobby = workspace:FindFirstChild("RegularLobby")
        if lobby and lobby:FindFirstChild("Spawns") then
            local spawns = lobby.Spawns:GetChildren()
            if #spawns > 0 and LocalPlayer.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
            end
        end
    end)
    addButton(miscPage, "MurderTP", "", function()
        local murderer = findMurderer()
        if murderer and murderer.Character and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame
        end
    end)
    addButton(miscPage, "SheriffTP", "", function()
        local dataEvent = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if not dataEvent then return end
        local success, data = pcall(function() return dataEvent:InvokeServer() end)
        if success and data then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
                    local info = data[plr.Name]
                    if info and info.Role == "Sheriff" and plr.Character and LocalPlayer.Character then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                        break
                    end
                end
            end
        end
    end)

    addSection(miscPage, "Dances")
    addDropdown(miscPage, "SelectDance", {["Dance 1"]="127118661424463", ["Dance 2"]="82682811348660", ["Dance 3"]="10714340543", ["Dance 4"]="15609995579"}, "Dance 1", function(val)
        if val then
            currentDanceID = val
            if danceActive then
                if danceAnim then
                    pcall(function() danceAnim:Stop() danceAnim:Destroy() end)
                    danceAnim = nil
                end
                task.wait(0.1)
                if LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local animator = hum:FindFirstChildOfClass("Animator")
                        if not animator then
                            animator = Instance.new("Animator")
                            animator.Parent = hum
                        end
                        local anim = Instance.new("Animation")
                        anim.AnimationId = "rbxassetid://" .. currentDanceID
                        danceAnim = animator:LoadAnimation(anim)
                        danceAnim.Looped = true
                        danceAnim.Priority = Enum.AnimationPriority.Action
                        danceAnim:Play(0.1,1,1)
                        anim:Destroy()
                    end
                end
            end
        end
    end)
    addToggle(miscPage, "AutoDance", "", danceActive, function(val)
        danceActive = val
        if val then
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    local animator = hum:FindFirstChildOfClass("Animator")
                    if not animator then
                        animator = Instance.new("Animator")
                        animator.Parent = hum
                    end
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://" .. currentDanceID
                    danceAnim = animator:LoadAnimation(anim)
                    danceAnim.Looped = true
                    danceAnim.Priority = Enum.AnimationPriority.Action
                    danceAnim:Play(0.1,1,1)
                    anim:Destroy()
                end
            end
        else
            if danceAnim then
                pcall(function() danceAnim:Stop() danceAnim:Destroy() end)
                danceAnim = nil
            end
        end
    end)

    addSection(miscPage, "UnderMap")
    addToggle(miscPage, "UnderMap", "UnderMapDesc", underMapActive, function(val)
        underMapActive = val
        if val then
            if not LocalPlayer.Character then return end
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            oldFallenHeight = workspace.FallenPartsDestroyHeight
            workspace.FallenPartsDestroyHeight = -1/0
            local map = findMap()
            local underY = -500
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
                    underY = center.Y - 100
                end
            end
            local targetCF = CFrame.new(root.Position.X, underY, root.Position.Z)
            root.CFrame = targetCF
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            local bv = Instance.new("BodyVelocity")
            bv.Parent = root
            bv.Velocity = Vector3.new(0,0,0)
            bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            underMapConnection = RunService.Heartbeat:Connect(function()
                if not underMapActive or not LocalPlayer.Character or not root then
                    if bv then bv:Destroy() end
                    if underMapConnection then underMapConnection:Disconnect() end
                    return
                end
                if (root.Position - targetCF.p).Magnitude > 5 then
                    root.CFrame = targetCF
                end
                root.Velocity = Vector3.new(0,0,0)
                root.RotVelocity = Vector3.new(0,0,0)
            end)
        else
            if underMapConnection then
                underMapConnection:Disconnect()
                underMapConnection = nil
            end
            workspace.FallenPartsDestroyHeight = oldFallenHeight
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
                            LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0)
                        end
                    end
                end
            end
        end
    end)

    addSection(miscPage, "CharMods")
    addToggle(miscPage, "WalkSpeed", "", customWalkSpeed, function(val)
        customWalkSpeed = val
        if not val and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end)
    addSlider(miscPage, "", "", walkSpeedValue, 16, 200, 0, function(val)
        walkSpeedValue = val
        if customWalkSpeed and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end)
    addToggle(miscPage, "JumpPower", "", customJumpPower, function(val)
        customJumpPower = val
        if not val and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end)
    addSlider(miscPage, "", "", jumpPowerValue, 50, 200, 0, function(val)
        jumpPowerValue = val
        if customJumpPower and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end)
    addToggle(miscPage, "FOV", "", customFOV, function(val)
        customFOV = val
        if not val then
            local cam = workspace.CurrentCamera
            if cam then cam.FieldOfView = 70 end
        end
    end)
    addSlider(miscPage, "", "", fovValue, 70, 120, 0, function(val)
        fovValue = val
        if customFOV then
            local cam = workspace.CurrentCamera
            if cam then cam.FieldOfView = val end
        end
    end)
    addToggle(miscPage, "ForceField", "", forceFieldMaterial, function(val)
        forceFieldMaterial = val
        if val then
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        part.Material = Enum.Material.ForceField
                    end
                end
            end
        else
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        part.Material = Enum.Material.Plastic
                    end
                end
            end
        end
    end)

    -- SETTINGS PAGE
    addSection(settingsPage, "LangSelect")
    addDropdown(settingsPage, "LangSelect", {["Русский"]="RU", ["English"]="EN"}, lang, function(val)
        lang = val
        applyLanguage()
    end)

    addSection(settingsPage, "ThemeSelect")
    local themeOptions = {}
    for i, name in ipairs({"Blue Space", "Purple Cyber", "Acid Lime", "Fiery Rose", "Amber Neon", "White Phantom"}) do
        themeOptions[name] = i
    end
    local themeColors = {
        [1] = Color3.fromRGB(0, 150, 255),
        [2] = Color3.fromRGB(168, 85, 247),
        [3] = Color3.fromRGB(34, 197, 94),
        [4] = Color3.fromRGB(236, 72, 153),
        [5] = Color3.fromRGB(245, 158, 11),
        [6] = Color3.fromRGB(220, 220, 230),
    }
    addDropdown(settingsPage, "ThemeSelect", themeOptions, "Blue Space", function(val)
        local idx = themeOptions[val]
        if idx then
            accentColor = themeColors[idx]
            TitleGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) })
            ToggleGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) })
            SepGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)), ColorSequenceKeypoint.new(0.5, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35)) })
            for _, frame in pairs(mainPage:GetChildren()) do
                local fill = frame:FindFirstChild("Fill")
                if fill then fill.BackgroundColor3 = accentColor end
            end
            for _, frame in pairs(visualsPage:GetChildren()) do
                local fill = frame:FindFirstChild("Fill")
                if fill then fill.BackgroundColor3 = accentColor end
            end
            for _, frame in pairs(miscPage:GetChildren()) do
                local fill = frame:FindFirstChild("Fill")
                if fill then fill.BackgroundColor3 = accentColor end
            end
            for _, frame in pairs(settingsPage:GetChildren()) do
                local fill = frame:FindFirstChild("Fill")
                if fill then fill.BackgroundColor3 = accentColor end
            end
        end
    end)

    addSection(settingsPage, "UISettings")
    addToggle(settingsPage, "UIBlur", "", true, function(val)
        if val then
            if not game.Lighting:FindFirstChild("Blur") then
                local blur = Instance.new("BlurEffect")
                blur.Name = "Blur"
                blur.Size = 8
                blur.Parent = game.Lighting
            end
        else
            local blur = game.Lighting:FindFirstChild("Blur")
            if blur then blur:Destroy() end
        end
    end)
    addSlider(settingsPage, "UITransparency", "", MainFrame.BackgroundTransparency, 0, 1, 2, function(val)
        MainFrame.BackgroundTransparency = val
    end)

    -- ===== ПРИМЕНЕНИЕ ЯЗЫКА =====
    function applyLanguage()
        for _, item in ipairs(languageElements) do
            local obj = item.obj
            local key = item.key
            if obj and (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
                obj.Text = L(key)
            end
        end
        local names = { L("MainTab"), L("VisualsTab"), L("MiscTab"), L("SettingsTab") }
        for i, btn in ipairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.Text = names[i] or btn.Text
            end
        end
    end

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
            for _, b in ipairs(TabContainer:GetChildren()) do
                if b:IsA("TextButton") then
                    TweenService:Create(b, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(20, 20, 28), TextColor3 = Color3.fromRGB(150, 150, 170) }):Play()
                end
            end
            TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = accentColor, TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            mainPage.Visible = page == mainPage
            visualsPage.Visible = page == visualsPage
            miscPage.Visible = page == miscPage
            settingsPage.Visible = page == settingsPage
        end)
        return btn
    end

    createTabButton(L("MainTab"), mainPage)
    createTabButton(L("VisualsTab"), visualsPage)
    createTabButton(L("MiscTab"), miscPage)
    createTabButton(L("SettingsTab"), settingsPage)

    local firstBtn = TabContainer:GetChildren()[1]
    if firstBtn and firstBtn:IsA("TextButton") then
        firstBtn.BackgroundColor3 = accentColor
        firstBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    applyLanguage()

    -- ===== ОПТИМИЗИРОВАННЫЙ ЦИКЛ =====
    local espTimer = 0
    local farmTimer = 0
    local tween = nil
    local noclipConnection = nil
    local savedCollision = {}

    RunService.Heartbeat:Connect(function(dt)
        espTimer = espTimer + dt
        if espTimer >= 0.5 then
            espTimer = 0
            local dataEvent = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
            if dataEvent then
                local success, data = pcall(function() return dataEvent:InvokeServer() end)
                if success and data then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
                            local role = "Innocent"
                            local info = data[plr.Name]
                            if info and info.Role then role = info.Role end
                            local color = ({ Murderer = Color3.fromRGB(255,0,0), Sheriff = Color3.fromRGB(0,0,255), Hero = Color3.fromRGB(255,255,0), Innocent = Color3.fromRGB(0,255,0) })[role] or Color3.fromRGB(0,255,0)
                            if ESP_SETTINGS[role] then
                                if not plr.Character then return end
                                local h = plr.Character:FindFirstChild("RoleESP")
                                if not h then
                                    h = Instance.new("Highlight")
                                    h.Name = "RoleESP"
                                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    h.FillTransparency = 0.5
                                    h.OutlineTransparency = 0
                                    h.Parent = plr.Character
                                end
                                h.FillColor = color
                                h.OutlineColor = color
                            else
                                if plr.Character then
                                    local h = plr.Character:FindFirstChild("RoleESP")
                                    if h then h:Destroy() end
                                end
                            end
                            if NAME_ESP_SETTINGS[role] then
                                if not plr.Character then return end
                                local head = plr.Character:FindFirstChild("Head")
                                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                                if head and root then
                                    local gui = head:FindFirstChild("NameESP")
                                    if not gui then
                                        gui = Instance.new("BillboardGui")
                                        gui.Name = "NameESP"
                                        gui.AlwaysOnTop = true
                                        gui.Size = UDim2.new(0,200,0,80)
                                        gui.StudsOffset = Vector3.new(0,2,0)
                                        gui.Parent = head
                                        local avatarFrame = Instance.new("Frame")
                                        avatarFrame.Name = "AvatarFrame"
                                        avatarFrame.BackgroundColor3 = Color3.new(1,1,1)
                                        avatarFrame.Size = UDim2.new(0,40,0,40)
                                        avatarFrame.Position = UDim2.new(0.5,-20,0,0)
                                        avatarFrame.BorderSizePixel = 2
                                        avatarFrame.Parent = gui
                                        local corner1 = Instance.new("UICorner")
                                        corner1.CornerRadius = UDim.new(1,0)
                                        corner1.Parent = avatarFrame
                                        local avatar = Instance.new("ImageLabel")
                                        avatar.Name = "Avatar"
                                        avatar.BackgroundTransparency = 1
                                        avatar.Size = UDim2.new(1,0,1,0)
                                        avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                                        avatar.Parent = avatarFrame
                                        local corner2 = Instance.new("UICorner")
                                        corner2.CornerRadius = UDim.new(1,0)
                                        corner2.Parent = avatar
                                        local nameLabel = Instance.new("TextLabel")
                                        nameLabel.Name = "NameLabel"
                                        nameLabel.BackgroundTransparency = 1
                                        nameLabel.Size = UDim2.new(1,0,0,20)
                                        nameLabel.Position = UDim2.new(0,0,1,-20)
                                        nameLabel.Font = Enum.Font.GothamBold
                                        nameLabel.TextSize = 14
                                        nameLabel.TextStrokeTransparency = 0
                                        nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
                                        nameLabel.Parent = gui
                                    end
                                    local nameLabel = gui:FindFirstChild("NameLabel")
                                    if nameLabel then
                                        if ESP_CUSTOMIZATION.DisplayName then nameLabel.Text = plr.DisplayName
                                        elseif ESP_CUSTOMIZATION.NormalName then nameLabel.Text = plr.Name
                                        else nameLabel.Text = "" end
                                        nameLabel.TextColor3 = color
                                    end
                                    local avatarFrame = gui:FindFirstChild("AvatarFrame")
                                    if avatarFrame then
                                        avatarFrame.Visible = ESP_CUSTOMIZATION.AvatarDisplay
                                        avatarFrame.BorderColor3 = color
                                    end
                                    if ESP_CUSTOMIZATION.Box2D then
                                        local box = root:FindFirstChild("Box2D")
                                        if not box then
                                            box = Instance.new("BillboardGui")
                                            box.Name = "Box2D"
                                            box.AlwaysOnTop = true
                                            box.Size = UDim2.new(4,0,5,0)
                                            box.StudsOffset = Vector3.new(0,0,0)
                                            box.Parent = root
                                            local frame = Instance.new("Frame")
                                            frame.Name = "BoxFrame"
                                            frame.BackgroundTransparency = 1
                                            frame.Size = UDim2.new(1,0,1,0)
                                            frame.BorderSizePixel = 2
                                            frame.Parent = box
                                            local stroke = Instance.new("UIStroke")
                                            stroke.Name = "Stroke"
                                            stroke.Thickness = 2
                                            stroke.Parent = frame
                                        end
                                        local frame = box:FindFirstChild("BoxFrame")
                                        if frame then
                                            local stroke = frame:FindFirstChild("Stroke")
                                            if stroke then stroke.Color = color end
                                        end
                                    else
                                        local box = root:FindFirstChild("Box2D")
                                        if box then box:Destroy() end
                                    end
                                end
                            else
                                if plr.Character then
                                    local head = plr.Character:FindFirstChild("Head")
                                    if head then
                                        local gui = head:FindFirstChild("NameESP")
                                        if gui then gui:Destroy() end
                                    end
                                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                                    if root then
                                        local box = root:FindFirstChild("Box2D")
                                        if box then box:Destroy() end
                                    end
                                end
                            end
                        else
                            if plr.Character then
                                local h = plr.Character:FindFirstChild("RoleESP")
                                if h then h:Destroy() end
                                local head = plr.Character:FindFirstChild("Head")
                                if head then
                                    local gui = head:FindFirstChild("NameESP")
                                    if gui then gui:Destroy() end
                                end
                                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local box = root:FindFirstChild("Box2D")
                                    if box then box:Destroy() end
                                end
                            end
                        end
                    end
                end
            end

            if autoGrabGun and LocalPlayer:GetAttribute("Alive") then
                local map = findMap()
                if map and map:FindFirstChild("GunDrop") and LocalPlayer.Character then
                    map.GunDrop.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end

        farmTimer = farmTimer + dt
        if farmTimer >= 0.3 then
            farmTimer = 0
            if farming and not collected and LocalPlayer:GetAttribute("Alive") == true and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local container = returnCoinContainer()
                if container then
                    local nearest, dist = FindNearestCoin(container, randomCoinSelection)
                    if nearest and nearest.Transparency == 1 and not collected then
                        if not farmingActive then
                            local root = LocalPlayer.Character.HumanoidRootPart
                            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                            savedCollision = {}
                            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    savedCollision[part] = { CanCollide = part.CanCollide, Massless = part.Massless }
                                end
                            end
                            root.CFrame = root.CFrame - Vector3.new(0,2.5,0)
                            root.CFrame = root.CFrame * CFrame.Angles(math.rad(90),0,0)
                            if hum then
                                hum.PlatformStand = true
                                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                            end
                            farmingActive = true
                        end
                        local root = LocalPlayer.Character.HumanoidRootPart
                        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                        root.Velocity = Vector3.new(0,0,0)
                        root.RotVelocity = Vector3.new(0,0,0)
                        local offset = Vector3.new()
                        if randomMovement then
                            offset = Vector3.new(math.random(-2,2), 0, math.random(-2,2))
                        end
                        local targetPos = nearest.Position - Vector3.new(0,2.5,0) + offset
                        local targetCF = CFrame.new(targetPos) * CFrame.Angles(math.rad(90),0,0)
                        if not noclipConnection then
                            noclipConnection = RunService.Stepped:Connect(function()
                                if farming and LocalPlayer.Character then
                                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                                        if part:IsA("BasePart") then part.CanCollide = false end
                                    end
                                end
                            end)
                        end
                        local duration = (dist / 23) * (randomMovement and (0.8 + math.random()*0.4) or 1)
                        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                        tween = TweenService:Create(root, info, { CFrame = targetCF })
                        tween:Play()
                        local heartbeatConnection
                        heartbeatConnection = RunService.Heartbeat:Connect(function()
                            if farming and LocalPlayer:GetAttribute("Alive") == true and root then
                                root.Velocity = Vector3.new(0,0,0)
                                root.RotVelocity = Vector3.new(0,0,0)
                                if hum then hum.PlatformStand = true end
                            else
                                if heartbeatConnection then heartbeatConnection:Disconnect() end
                            end
                        end)
                        while nearest and nearest:FindFirstChild("TouchInterest") and nearest.Transparency == 1 and not collected and farming and LocalPlayer:GetAttribute("Alive") == true do
                            task.wait(0.05)
                        end
                        if heartbeatConnection then heartbeatConnection:Disconnect() end
                        if tween then tween:Cancel() tween = nil end
                        if root then
                            root.Velocity = Vector3.new(0,0,0)
                            root.RotVelocity = Vector3.new(0,0,0)
                        end
                        if randomDelays then
                            task.wait(minDelay + math.random() * (maxDelay - minDelay))
                        end
                    else
                        if farmingActive then
                            farmingActive = false
                            if tween then tween:Cancel() tween = nil end
                            if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
                            if LocalPlayer.Character then
                                for part, data in pairs(savedCollision) do
                                    if part and part.Parent then
                                        part.CanCollide = data.CanCollide
                                        part.Massless = data.Massless
                                    end
                                end
                                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    root.Velocity = Vector3.new(0,0,0)
                                    root.RotVelocity = Vector3.new(0,0,0)
                                    root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90),0,0)
                                    root.CFrame = root.CFrame + Vector3.new(0,2.5,0)
                                end
                                local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                                if hum then
                                    hum.PlatformStand = false
                                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                                end
                            end
                            savedCollision = {}
                        end
                    end
                else
                    if farmingActive then
                        farmingActive = false
                        if tween then tween:Cancel() tween = nil end
                        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
                        if LocalPlayer.Character then
                            for part, data in pairs(savedCollision) do
                                if part and part.Parent then
                                    part.CanCollide = data.CanCollide
                                    part.Massless = data.Massless
                                end
                            end
                            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                root.Velocity = Vector3.new(0,0,0)
                                root.RotVelocity = Vector3.new(0,0,0)
                                root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90),0,0)
                                root.CFrame = root.CFrame + Vector3.new(0,2.5,0)
                            end
                            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                            if hum then
                                hum.PlatformStand = false
                                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                            end
                        end
                        savedCollision = {}
                    end
                end
            else
                if farmingActive then
                    farmingActive = false
                    if tween then tween:Cancel() tween = nil end
                    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
                    if LocalPlayer.Character then
                        for part, data in pairs(savedCollision) do
                            if part and part.Parent then
                                part.CanCollide = data.CanCollide
                                part.Massless = data.Massless
                            end
                        end
                        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Velocity = Vector3.new(0,0,0)
                            root.RotVelocity = Vector3.new(0,0,0)
                            root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90),0,0)
                            root.CFrame = root.CFrame + Vector3.new(0,2.5,0)
                        end
                        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                        if hum then
                            hum.PlatformStand = false
                            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                        end
                    end
                    savedCollision = {}
                end
            end
        end

        if antiAFK and tick() % 10 < dt then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                local dir = Vector3.new(math.random(-1,1), 0, math.random(-1,1))
                hum:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + dir * 5)
            end
        end
    end)

    -- ===== СОБЫТИЯ =====
    local collected = false
    local coinCollectedEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.Gameplay and ReplicatedStorage.Remotes.Gameplay.CoinCollected
    if coinCollectedEvent then
        coinCollectedEvent.OnClientEvent:Connect(function(plr, got, total)
            if plr == LocalPlayer then
                if tonumber(got) == tonumber(total) then
                    collected = true
                else
                    collected = false
                end
            end
        end)
    end
    local roundStart = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.Gameplay and ReplicatedStorage.Remotes.Gameplay.RoundStart
    local roundEnd = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.Gameplay and ReplicatedStorage.Remotes.Gameplay.RoundEndFade
    if roundStart then
        roundStart.OnClientEvent:Connect(function() collected = false end)
    end
    if roundEnd then
        roundEnd.OnClientEvent:Connect(function()
            collected = false
        end)
    end

    -- ===== ОТКРЫТИЕ МЕНЮ =====
    toggleMenu(true)

    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0.5, 0, 0, 36)
    notif.Position = UDim2.new(0.25, 0, 0.08, 0)
    notif.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    notif.Text = "NKNO$ HUB loaded! Press Left Alt"
    notif.TextColor3 = Color3.fromRGB(255,255,255)
    notif.TextSize = 16
    notif.Font = Enum.Font.GothamBold
    notif.ZIndex = 10
    notif.Parent = MainFrame
    task.delay(4, function() notif:Destroy() end)

    print("[NKNO$ HUB] Final version loaded.")
end
