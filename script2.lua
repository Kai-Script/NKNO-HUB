-- NKNO$ HUB - Ultimate Edition v2.2 (исправленный)
-- Языки: Русский, English, Українська
-- Discord: https://discord.gg/HsSSmNf69

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Clipboard = game:GetService("Clipboard")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- =====================================================
-- ЯЗЫКИ (только 3)
-- =====================================================
local Languages = {
    ru = "Русский",
    en = "English (USA)",
    uk = "Українська"
}
local lang = "ru"

-- =====================================================
-- ПЕРЕВОДЫ
-- =====================================================
local L = {}

-- Русский
L.ru = {
    tab_main = "Основное",
    tab_visuals = "Визуал",
    tab_misc = "Разное",
    tab_settings = "Настройки",
    tab_lang = "Язык",
    tab_changelog = "📢 Обновления",

    sec_murder = "Функции убийцы",
    sec_sheriff = "Функции шерифа",
    sec_innocent = "Функции невиновного",
    sec_autofarm = "Авто-фарм",
    sec_chams = "Чамы",
    sec_esp = "ESP",
    sec_esp_custom = "Настройки ESP",
    sec_char_mod = "Модификаторы персонажа",
    sec_dance = "Танцы",
    sec_fling = "Флинг игроков",
    sec_discord = "Discord",
    sec_nkno = "NKNO$",

    btn_killall = "Убить всех",
    btn_killall_desc = "Убивает всех невиновных",
    btn_shoot = "Выстрелить в убийцу (сквозь стены)",
    btn_shoot_desc = "Мгновенно убивает убийцу, игнорируя стены",
    btn_copydiscord = "📢 Копировать Discord",
    btn_copydiscord_desc = "Копирует ссылку на наш Discord сервер",
    btn_fling_murder = "Флинг убийцы",
    btn_fling_sheriff = "Флинг шерифа",
    btn_fling_sel = "Флинг выбранного",
    btn_stop_fling = "Остановить флинг",
    btn_map_tp = "ТП на карту",
    btn_lobby_tp = "ТП в лобби",
    btn_murder_tp = "ТП к убийце",
    btn_sheriff_tp = "ТП к шерифу",

    tog_autoshoot = "Авто-кнопка выстрела",
    tog_autoshoot_desc = "Создаёт перетаскиваемую кнопку для стрельбы",
    tog_magicbullet = "Магическая пуля",
    tog_magicbullet_desc = "Пуля летит прямо в убийцу",
    tog_autogun = "Авто-подбор пистолета",
    tog_autogun_desc = "Автоматически поднимает пистолет, если шериф погиб",
    tog_farm = "Фарм монет",
    tog_farm_desc = "Автоматический сбор монет с ноклипом",
    tog_random_delays = "Случайные задержки",
    tog_random_delays_desc = "Добавляет случайные паузы между сборами",
    tog_random_move = "Случайное движение",
    tog_random_move_desc = "Добавляет случайные отклонения при движении",
    tog_random_coin = "Случайный выбор монеты",
    tog_random_coin_desc = "Выбирает случайную монету, а не ближайшую",
    tog_antiafk = "Анти-AFK",
    tog_antiafk_desc = "Отправляет случайные движения, чтобы не выкинуло",
    tog_chams_murder = "Чамы убийцы",
    tog_chams_sheriff = "Чамы шерифа",
    tog_chams_innocent = "Чамы невиновного",
    tog_chams_hero = "Чамы героя",
    tog_esp_murder = "ESP убийцы",
    tog_esp_sheriff = "ESP шерифа",
    tog_esp_innocent = "ESP невиновного",
    tog_esp_hero = "ESP героя",
    tog_box2d = "2D рамка",
    tog_box2d_desc = "Показывает рамку вокруг игрока",
    tog_displayname = "Отображать DisplayName",
    tog_normalname = "Отображать обычное имя",
    tog_avatar = "Аватар над головой",
    tog_antifling = "Анти-флинг",
    tog_customws = "Своя скорость",
    tog_customjp = "Своя сила прыжка",
    tog_customfov = "Свой FOV",
    tog_forcefield = "ForceField материал",
    tog_forcefield_desc = "Все части тела становятся как ForceField",
    tog_autodance = "Авто-танец",
    tog_undermap = "Под картой",
    tog_undermap_desc = "Телепортирует под карту (неуязвимость)",
    tog_tag = "Показать тег NKNO$",
    tog_tag_desc = "Над вашим персонажем появится корона с надписью NKNO$",
    tog_pingfps = "Пинг / FPS",
    tog_pingfps_desc = "Показывает пинг и FPS на экране",

    slider_mindelay = "Мин. задержка (сек)",
    slider_maxdelay = "Макс. задержка (сек)",
    slider_ws = "Значение скорости",
    slider_jp = "Значение прыжка",
    slider_fov = "Значение FOV",

    dropdown_dance = "Выберите танец",
    dropdown_theme = "Тема",
    dropdown_lang = "Выберите язык",

    input_player = "Поиск игрока",
    keybind_minimize = "Клавиша сворачивания",

    notify_hello = "Привет! Нажми Left Alt для сворачивания",
    notify_copied = "Ссылка скопирована!",
    notify_error = "Ошибка",
    notify_fling_start = "Флинг запущен",
    notify_fling_stop = "Флинг остановлен",
    notify_undermap_on = "Режим под картой включён",
    notify_undermap_off = "Режим под картой выключен",
    notify_tag_on = "Тег NKNO$ включён",
    notify_tag_off = "Тег NKNO$ выключен",
    notify_kill = "Все убиты!",
    notify_nomurder = "Убийца не найден",

    changelog_title = "Что нового в NKNO$ HUB",
    changelog_text = [[🆕 Версия 2.2 – Убраны лишние языки!
✅ Оставлены: Русский, English, Українська.
✅ Авто-фарм монет в любых играх.
✅ Поддержка +1 Speed Keyboard.
✅ Wallbang – убийца сквозь стены.
✅ Custom Tag с короной 👑 NKNO$.
✅ Ping/FPS на экране.
✅ Закрытие Ctrl+Z.
🎯 NKNO$ HUB – мощнее с каждым обновлением!]]
}

-- Английский
L.en = {
    tab_main = "Main", tab_visuals = "Visuals", tab_misc = "Misc", tab_settings = "Settings", tab_lang = "Language", tab_changelog = "📢 Changelog",
    sec_murder = "Murder Functions", sec_sheriff = "Sheriff Functions", sec_innocent = "Innocent Functions", sec_autofarm = "Auto Farm",
    sec_chams = "Chams", sec_esp = "ESP", sec_esp_custom = "ESP Customization", sec_char_mod = "Character Modifiers", sec_dance = "Dance Emotes",
    sec_fling = "Fling Players", sec_discord = "Discord", sec_nkno = "NKNO$",
    btn_killall = "Kill All", btn_killall_desc = "Kill All Innocents",
    btn_shoot = "Shoot Murderer (Wallbang)", btn_shoot_desc = "Instantly kills murderer through walls",
    btn_copydiscord = "📢 Copy Discord", btn_copydiscord_desc = "Copy our Discord server link",
    btn_fling_murder = "Fling Murderer", btn_fling_sheriff = "Fling Sheriff", btn_fling_sel = "Fling Selected", btn_stop_fling = "Stop Fling",
    btn_map_tp = "TP to Map", btn_lobby_tp = "TP to Lobby", btn_murder_tp = "TP to Murderer", btn_sheriff_tp = "TP to Sheriff",
    tog_autoshoot = "Auto Shoot Button", tog_autoshoot_desc = "Creates a draggable button to shoot",
    tog_magicbullet = "Magic Bullet", tog_magicbullet_desc = "Bullet flies directly to murderer",
    tog_autogun = "Auto Grab Gun", tog_autogun_desc = "Automatically grabs gun if sheriff died",
    tog_farm = "Farm Coins", tog_farm_desc = "Automatically farm coins with noclip",
    tog_random_delays = "Random Delays", tog_random_delays_desc = "Add random pauses between pickups",
    tog_random_move = "Random Movement", tog_random_move_desc = "Add random offsets to movement",
    tog_random_coin = "Random Coin Selection", tog_random_coin_desc = "Pick random coin instead of nearest",
    tog_antiafk = "Anti-AFK", tog_antiafk_desc = "Send random movements to avoid AFK",
    tog_chams_murder = "Chams Murderer", tog_chams_sheriff = "Chams Sheriff", tog_chams_innocent = "Chams Innocent", tog_chams_hero = "Chams Hero",
    tog_esp_murder = "ESP Murderer", tog_esp_sheriff = "ESP Sheriff", tog_esp_innocent = "ESP Innocent", tog_esp_hero = "ESP Hero",
    tog_box2d = "2D Box", tog_box2d_desc = "Show 2D box around player",
    tog_displayname = "Display Name", tog_normalname = "Normal Name", tog_avatar = "Avatar above head",
    tog_antifling = "Anti-Fling", tog_customws = "Custom WalkSpeed", tog_customjp = "Custom JumpPower", tog_customfov = "Custom FOV",
    tog_forcefield = "ForceField Material", tog_forcefield_desc = "All body parts become ForceField",
    tog_autodance = "Auto Dance", tog_undermap = "UnderMap Mode", tog_undermap_desc = "Teleports you under the map (invincibility)",
    tog_tag = "Show NKNO$ Tag", tog_tag_desc = "A crown with NKNO$ appears above your character",
    tog_pingfps = "Ping / FPS", tog_pingfps_desc = "Show ping and FPS on screen",
    slider_mindelay = "Min Delay (s)", slider_maxdelay = "Max Delay (s)", slider_ws = "WalkSpeed Value", slider_jp = "JumpPower Value", slider_fov = "FOV Value",
    dropdown_dance = "Select Dance", dropdown_theme = "Set Theme", dropdown_lang = "Select Language",
    input_player = "Player Search", keybind_minimize = "Minimize Keybind",
    notify_hello = "Hello! Press Left Alt to Minimize", notify_copied = "Link copied!", notify_error = "Error",
    notify_fling_start = "Fling started", notify_fling_stop = "Fling stopped",
    notify_undermap_on = "UnderMap activated", notify_undermap_off = "UnderMap deactivated",
    notify_tag_on = "NKNO$ Tag enabled", notify_tag_off = "NKNO$ Tag disabled",
    notify_kill = "All killed!", notify_nomurder = "Murderer not found",
    changelog_title = "What's new in NKNO$ HUB",
    changelog_text = [[🆕 Version 2.2 – Extra languages removed!
✅ Left: Russian, English, Ukrainian.
✅ Auto coin farming in any game.
✅ Support for +1 Speed Keyboard.
✅ Wallbang – murderer through walls.
✅ Custom Tag with crown 👑 NKNO$.
✅ Ping/FPS on screen.
✅ Close with Ctrl+Z.
🎯 NKNO$ HUB – more powerful with every update!]]
}

-- Украинский
L.uk = {
    tab_main = "Головне", tab_visuals = "Візуал", tab_misc = "Різне", tab_settings = "Налаштування", tab_lang = "Мова", tab_changelog = "📢 Оновлення",
    sec_murder = "Функції вбивці", sec_sheriff = "Функції шерифа", sec_innocent = "Функції невинного", sec_autofarm = "Авто-фарм",
    sec_chams = "Чами", sec_esp = "ESP", sec_esp_custom = "Налаштування ESP", sec_char_mod = "Модифікатори персонажа", sec_dance = "Танці",
    sec_fling = "Флінг гравців", sec_discord = "Discord", sec_nkno = "NKNO$",
    btn_killall = "Вбити всіх", btn_killall_desc = "Вбиває всіх невинних",
    btn_shoot = "Вистрелити у вбивцю (крізь стіни)", btn_shoot_desc = "Миттєво вбиває вбивцю, ігноруючи стіни",
    btn_copydiscord = "📢 Копіювати Discord", btn_copydiscord_desc = "Копіює посилання на наш Discord сервер",
    btn_fling_murder = "Флінг вбивці", btn_fling_sheriff = "Флінг шерифа", btn_fling_sel = "Флінг вибраного", btn_stop_fling = "Зупинити флінг",
    btn_map_tp = "ТП на карту", btn_lobby_tp = "ТП в лобі", btn_murder_tp = "ТП до вбивці", btn_sheriff_tp = "ТП до шерифа",
    tog_autoshoot = "Авто-кнопка пострілу", tog_autoshoot_desc = "Створює перетягувану кнопку для стрільби",
    tog_magicbullet = "Магічна куля", tog_magicbullet_desc = "Куля летить прямо у вбивцю",
    tog_autogun = "Авто-підбір пістолета", tog_autogun_desc = "Автоматично піднімає пістолет, якщо шериф загинув",
    tog_farm = "Фарм монет", tog_farm_desc = "Автоматичний збір монет з нокліпом",
    tog_random_delays = "Випадкові затримки", tog_random_delays_desc = "Додає випадкові паузи між зборами",
    tog_random_move = "Випадковий рух", tog_random_move_desc = "Додає випадкові відхилення при русі",
    tog_random_coin = "Випадковий вибір монети", tog_random_coin_desc = "Вибирає випадкову монету, а не найближчу",
    tog_antiafk = "Анти-AFK", tog_antiafk_desc = "Відправляє випадкові рухи, щоб не викинуло",
    tog_chams_murder = "Чами вбивці", tog_chams_sheriff = "Чами шерифа", tog_chams_innocent = "Чами невинного", tog_chams_hero = "Чами героя",
    tog_esp_murder = "ESP вбивці", tog_esp_sheriff = "ESP шерифа", tog_esp_innocent = "ESP невинного", tog_esp_hero = "ESP героя",
    tog_box2d = "2D рамка", tog_box2d_desc = "Показує рамку навколо гравця",
    tog_displayname = "Відображати DisplayName", tog_normalname = "Відображати звичайне ім'я", tog_avatar = "Аватар над головою",
    tog_antifling = "Анти-флінг", tog_customws = "Своя швидкість", tog_customjp = "Своя сила стрибка", tog_customfov = "Свій FOV",
    tog_forcefield = "Матеріал ForceField", tog_forcefield_desc = "Всі частини тіла стають як ForceField",
    tog_autodance = "Авто-танець", tog_undermap = "Під картою", tog_undermap_desc = "Телепортує під карту (неуразливість)",
    tog_tag = "Показати тег NKNO$", tog_tag_desc = "Над вашим персонажем з'явиться корона з написом NKNO$",
    tog_pingfps = "Пінг / FPS", tog_pingfps_desc = "Показує пінг і FPS на екрані",
    slider_mindelay = "Мін. затримка (сек)", slider_maxdelay = "Макс. затримка (сек)", slider_ws = "Значення швидкості", slider_jp = "Значення стрибка", slider_fov = "Значення FOV",
    dropdown_dance = "Виберіть танець", dropdown_theme = "Тема", dropdown_lang = "Виберіть мову",
    input_player = "Пошук гравця", keybind_minimize = "Клавіша згортання",
    notify_hello = "Привіт! Натисніть Left Alt для згортання", notify_copied = "Посилання скопійовано!", notify_error = "Помилка",
    notify_fling_start = "Флінг запущено", notify_fling_stop = "Флінг зупинено",
    notify_undermap_on = "Режим під картою увімкнено", notify_undermap_off = "Режим під картою вимкнено",
    notify_tag_on = "Тег NKNO$ увімкнено", notify_tag_off = "Тег NKNO$ вимкнено",
    notify_kill = "Всі вбиті!", notify_nomurder = "Вбивцю не знайдено",
    changelog_title = "Що нового в NKNO$ HUB",
    changelog_text = [[🆕 Версія 2.2 – Видалено зайві мови!
✅ Залишено: Українська, Англійська, Російська.
✅ Авто-фарм монет у будь-яких іграх.
✅ Підтримка +1 Speed Keyboard.
✅ Wallbang – вбивця крізь стіни.
✅ Custom Tag з короною 👑 NKNO$.
✅ Пінг/FPS на екрані.
✅ Закриття Ctrl+Z.
🎯 NKNO$ HUB – потужніший з кожним оновленням!]]
}

local function T(key) return L[lang] and L[lang][key] or key end

-- =====================================================
-- ЗАКРЫТИЕ ПО CTRL+Z
-- =====================================================
local function closeScript()
    if windowGui then windowGui:Destroy() end
    if miniGui then miniGui:Destroy() end
    if fpsGui then fpsGui:Destroy() end
    if tagGui then tagGui:Destroy() end
    if shootButtonGui then shootButtonGui:Destroy() end
    for _, conn in pairs(connections) do pcall(conn.Disconnect, conn) end
    getgenv().ScriptClosed = true
    print("NKNO$ HUB закрыт.")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        closeScript()
    end
end)

-- =====================================================
-- ЗАГРУЗКА UI БИБЛИОТЕКИ
-- =====================================================
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/UI-Libraries/UiLibs/VapeUiLib.lua"))()
local window = library:CreateWindow({
    Title = "NKNO$ HUB",
    Theme = "Dark",
    Size = UDim2.fromOffset(570, 370),
    Transparency = 0.2,
    Blurring = true,
    MinimizeKeybind = Enum.KeyCode.LeftAlt
})
windowGui = window.Gui
toggles = {}
connections = {}

-- Создаём мини-панель для свёрнутого состояния
local miniGui = Instance.new("ScreenGui")
miniGui.Name = "NKNO_Mini"
miniGui.ResetOnSpawn = false
miniGui.Parent = CoreGui
miniGui.Enabled = false  -- скрыта по умолчанию

local miniFrame = Instance.new("Frame")
miniFrame.Size = UDim2.new(0, 120, 0, 30)
miniFrame.Position = UDim2.new(1, -130, 0, 10)  -- правый верхний угол
miniFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniFrame.BackgroundTransparency = 0.1
miniFrame.BorderSizePixel = 0
miniFrame.Parent = miniGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = miniFrame

local miniLabel = Instance.new("TextLabel")
miniLabel.Size = UDim2.new(1, 0, 1, 0)
miniLabel.BackgroundTransparency = 1
miniLabel.Text = "NKNO$ HUB"
miniLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
miniLabel.TextSize = 14
miniLabel.Font = Enum.Font.GothamBold
miniLabel.Parent = miniFrame

-- Перетаскивание мини-панели
local dragging = false
local dragStart, startPos
miniFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = miniFrame.Position
    end
end)
miniFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            miniFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)
miniFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Клик по мини-панели разворачивает окно
miniFrame.MouseButton1Click:Connect(function()
    windowGui.Visible = true
    miniGui.Enabled = false
end)

-- =====================================================
-- Переопределяем сворачивание (Left Alt)
-- =====================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        if windowGui.Visible then
            -- Сворачиваем: прячем основное окно, показываем мини-панель
            windowGui.Visible = false
            miniGui.Enabled = true
        else
            -- Разворачиваем: прячем мини-панель, показываем окно
            miniGui.Enabled = false
            windowGui.Visible = true
        end
    end
end)

-- Также реагируем на событие минимизации от библиотеки (если оно есть)
-- Но мы уже перехватили клавишу сами.

-- =====================================================
-- ВКЛАДКИ и всё остальное (без изменений)
-- =====================================================
local tabMain = window:AddTab({ Title = T("tab_main") })
local tabVisuals = window:AddTab({ Title = T("tab_visuals") })
local tabMisc = window:AddTab({ Title = T("tab_misc") })
local tabSettings = window:AddTab({ Title = T("tab_settings") })
local tabLang = window:AddTab({ Title = T("tab_lang") })
local tabChangelog = window:AddTab({ Title = T("tab_changelog") })

-- Changelog
window:AddSection({ Name = T("changelog_title"), Tab = tabChangelog })
local changelogFrame = Instance.new("Frame")
changelogFrame.Size = UDim2.new(1, 0, 1, 0)
changelogFrame.BackgroundTransparency = 1
changelogFrame.Parent = tabChangelog.Tab
local changelogLabel = Instance.new("TextLabel")
changelogLabel.Size = UDim2.new(1, -20, 1, -20)
changelogLabel.Position = UDim2.new(0, 10, 0, 10)
changelogLabel.BackgroundTransparency = 1
changelogLabel.Text = T("changelog_text")
changelogLabel.TextColor3 = Color3.fromRGB(255,255,255)
changelogLabel.TextSize = 16
changelogLabel.TextWrapped = true
changelogLabel.TextXAlignment = Enum.TextXAlignment.Left
changelogLabel.TextYAlignment = Enum.TextYAlignment.Top
changelogLabel.Font = Enum.Font.Gotham
changelogLabel.Parent = changelogFrame

-- Язык
window:AddSection({ Name = T("dropdown_lang"), Tab = tabLang })
window:AddDropdown({
    Title = T("dropdown_lang"),
    Options = Languages,
    Default = "ru",
    Tab = tabLang,
    Callback = function(opt)
        lang = opt
        tabMain:SetTitle(T("tab_main"))
        tabVisuals:SetTitle(T("tab_visuals"))
        tabMisc:SetTitle(T("tab_misc"))
        tabSettings:SetTitle(T("tab_settings"))
        tabLang:SetTitle(T("tab_lang"))
        tabChangelog:SetTitle(T("tab_changelog"))
        changelogLabel.Text = T("changelog_text")
        window:Notify({ Title = "Язык / Language", Description = "Выбран: " .. Languages[opt], Duration = 2 })
        window:Notify({ Title = "📢 Обновление!", Description = "В этой обнове добавили фарм и весь скрипт NKNO$ HUB есть не только на MM2, но и на +1 Speed Keyboard!", Duration = 5 })
    end
})

-- =====================================================
-- ПЕРЕМЕННЫЕ И ФУНКЦИИ (без изменений)
-- =====================================================
local farm = false
local noclipConnection = nil
local farmRunning = false
local randomDelays = false
local randomMovement = false
local randomCoinSelection = false
local antiAFK = false
local minDelay = 0.1
local maxDelay = 0.5
local underMapActive = false
local underMapConnection = nil
local oldFallenHeight = Workspace.FallenPartsDestroyHeight
local customTagActive = false
local tagGui = nil
local pingFpsActive = false
local fpsGui = nil
local autoShootActive = false
local shootButtonGui = nil
local magicBullet = false
local grabGun = false
local antiFling = false
local customWalkSpeed = false
local walkSpeedValue = 16
local customJumpPower = false
local jumpPowerValue = 50
local customFOV = false
local fovValue = 70
local forceFieldMat = false
local autoDance = false
local danceId = "127118661424463"
local flingActive = false
local selectedPlayer = nil

local espSettings = { Murderer = false, Sheriff = false, Innocent = false, Hero = false }
local nameEspSettings = { Murderer = false, Sheriff = false, Innocent = false, Hero = false }
local espCustom = { Box2D = false, DisplayName = false, NormalName = true, AvatarDisplay = false }

local function findMap()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:GetAttribute("MapID") then return obj end
    end
    return nil
end

local function returnCoinContainer()
    local map = findMap()
    if map and map:FindFirstChild("CoinContainer") then
        return map.CoinContainer
    end
    return nil
end

local function getPing()
    return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end

local function findMurderer()
    local dataEvent = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not dataEvent then return nil end
    local success, data = pcall(function() return dataEvent:InvokeServer() end)
    if not success or not data then return nil end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr:GetAttribute("Alive") == true then
            local info = data[plr.Name]
            if info and info.Role == "Murderer" then
                return plr
            end
        end
    end
    return nil
end

local function FindNearestCoin(container, useRandom)
    if not container then return nil, math.huge end
    local candidates = {}
    for _, coin in pairs(container:GetChildren()) do
        if coin:GetAttribute("CoinID") == "Coin" and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (player.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                table.insert(candidates, {coin = coin, dist = dist})
            end
        end
    end
    if #candidates == 0 then return nil, math.huge end
    table.sort(candidates, function(a,b) return a.dist < b.dist end)
    if useRandom and #candidates > 2 then
        local index = math.random(1, math.min(3, #candidates))
        return candidates[index].coin, candidates[index].dist
    else
        return candidates[1].coin, candidates[1].dist
    end
end

-- =====================================================
-- АВТОФАРМ (без изменений)
-- =====================================================
local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        if farm and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function startFarming()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if player:GetAttribute("Alive") ~= true then return end
    local root = player.Character.HumanoidRootPart
    local humanoid = player.Character:FindFirstChild("Humanoid")
    root.CFrame = root.CFrame - Vector3.new(0, 2.5, 0)
    root.CFrame = root.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    if humanoid then
        humanoid.PlatformStand = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
    farmRunning = true
    enableNoclip()
end

local function stopFarming()
    farmRunning = false
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if root then
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
            root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            root.CFrame = root.CFrame + Vector3.new(0, 2.5, 0)
        end
        if humanoid then
            humanoid.PlatformStand = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
end

local coinEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay")
if coinEvent then
    coinEvent = coinEvent:FindFirstChild("CoinCollected")
end
if coinEvent then
    coinEvent.OnClientEvent:Connect(function(plr, id, total)
        if plr == player then
            if id == total then
                if farmRunning then stopFarming() end
            end
        end
    end)
end

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if farm and not farmRunning and player:GetAttribute("Alive") == true and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local container = returnCoinContainer()
            if container then
                local coin, dist = FindNearestCoin(container, randomCoinSelection)
                if coin and coin.Transparency == 1 then
                    if not farmRunning then startFarming() end
                    local root = player.Character.HumanoidRootPart
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    root.Velocity = Vector3.new(0,0,0)
                    root.RotVelocity = Vector3.new(0,0,0)
                    local offset = Vector3.new()
                    if randomMovement then
                        offset = Vector3.new(math.random(-2,2), 0, math.random(-2,2))
                    end
                    local targetPos = coin.Position - Vector3.new(0, 2.5, 0) + offset
                    local targetCF = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)
                    local duration = (dist / 23) * (randomMovement and (0.8 + math.random()*0.4) or 1)
                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCF})
                    tween:Play()
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if farm and player:GetAttribute("Alive") == true and root then
                            root.Velocity = Vector3.new(0,0,0)
                            root.RotVelocity = Vector3.new(0,0,0)
                            if humanoid then humanoid.PlatformStand = true end
                        else
                            if conn then conn:Disconnect() end
                        end
                    end)
                    while coin and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 and farm and player:GetAttribute("Alive") == true do
                        RunService.Heartbeat:Wait()
                    end
                    if conn then conn:Disconnect() end
                    tween:Cancel()
                    if root then
                        root.Velocity = Vector3.new(0,0,0)
                        root.RotVelocity = Vector3.new(0,0,0)
                    end
                    if randomDelays then
                        task.wait(minDelay + math.random() * (maxDelay - minDelay))
                    end
                else
                    if farmRunning then stopFarming() end
                end
            else
                if farmRunning then stopFarming() end
            end
        elseif farmRunning then
            stopFarming()
        end
    end
end)

-- =====================================================
-- ESP и Chams (без изменений)
-- =====================================================
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
end

local function RemoveESP(plr)
    if plr.Character then
        local h = plr.Character:FindFirstChild("RoleESP")
        if h then h:Destroy() end
    end
end

local function CreateNameESP(plr, color)
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
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
        local uic = Instance.new("UICorner")
        uic.CornerRadius = UDim.new(1,0)
        uic.Parent = avatarFrame
        local avatar = Instance.new("ImageLabel")
        avatar.Name = "Avatar"
        avatar.BackgroundTransparency = 1
        avatar.Size = UDim2.new(1,0,1,0)
        avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        avatar.Parent = avatarFrame
        local uic2 = Instance.new("UICorner")
        uic2.CornerRadius = UDim.new(1,0)
        uic2.Parent = avatar
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
    local avatarFrame = gui:FindFirstChild("AvatarFrame")
    local nameLabel = gui:FindFirstChild("NameLabel")
    if nameLabel then
        if espCustom.DisplayName then
            nameLabel.Text = plr.DisplayName
        elseif espCustom.NormalName then
            nameLabel.Text = plr.Name
        else
            nameLabel.Text = ""
        end
        nameLabel.TextColor3 = color
    end
    if avatarFrame then
        avatarFrame.Visible = espCustom.AvatarDisplay
        avatarFrame.BorderColor3 = color
    end
    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local box = rootPart:FindFirstChild("Box2D")
        if espCustom.Box2D then
            if not box then
                box = Instance.new("BillboardGui")
                box.Name = "Box2D"
                box.AlwaysOnTop = true
                box.Size = UDim2.new(4,0,5,0)
                box.StudsOffset = Vector3.new(0,0,0)
                box.Parent = rootPart
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
            if box then box:Destroy() end
        end
    end
end

local function RemoveNameESP(plr)
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

local function UpdateESP()
    local dataEvent = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not dataEvent then return end
    local success, data = pcall(function() return dataEvent:InvokeServer() end)
    if not success or not data then return end
    local colorMap = {
        Murderer = Color3.fromRGB(255,0,0),
        Sheriff = Color3.fromRGB(0,0,255),
        Hero = Color3.fromRGB(255,255,0),
        Innocent = Color3.fromRGB(0,255,0)
    }
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr:GetAttribute("Alive") == true then
            local role = "Innocent"
            local info = data[plr.Name]
            if info and info.Role then role = info.Role end
            local color = colorMap[role] or colorMap.Innocent
            if espSettings[role] == true then
                CreateESP(plr, color)
            else
                RemoveESP(plr)
            end
            if nameEspSettings[role] == true then
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

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        UpdateESP()
    end
end)

-- =====================================================
-- ВКЛАДКА MAIN
-- =====================================================
window:AddSection({ Name = T("sec_murder"), Tab = tabMain })
window:AddButton({
    Title = T("btn_killall"),
    Description = T("btn_killall_desc"),
    Tab = tabMain,
    Callback = function()
        if not player.Character then return end
        local knife = player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
        if not knife then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                local root = player.Character.HumanoidRootPart
                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    targetRoot.Size = Vector3.new(5,5,5)
                    targetRoot.CFrame = root.CFrame + root.CFrame.LookVector * 3
                    targetRoot.Anchored = true
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                end
            end
        end
        window:Notify({ Title = T("notify_kill"), Duration = 2 })
    end
})

window:AddButton({
    Title = T("btn_shoot"),
    Description = T("btn_shoot_desc"),
    Tab = tabMain,
    Callback = function()
        local murderer = findMurderer()
        if not murderer then
            window:Notify({ Title = T("notify_nomurder"), Duration = 2 })
            return
        end
        local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
        if not gun then
            window:Notify({ Title = T("notify_error"), Description = "No gun!", Duration = 2 })
            return
        end
        if gun.Parent ~= player.Character then gun.Parent = player.Character end
        local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        local shootEvent = gun:FindFirstChild("ShootEvent") or gun:FindFirstChild("Shoot")
        if shootEvent then
            local head = murderer.Character:FindFirstChild("Head") or targetRoot
            local origin = player.Character.HumanoidRootPart.Position
            local direction = (head.Position - origin).unit * 500
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {player.Character, murderer.Character}
            local result = Workspace:Raycast(origin, direction, raycastParams)
            local targetPos = result and result.Position or head.Position
            shootEvent:FireServer(CFrame.new(origin, targetPos), CFrame.new(targetPos))
            window:Notify({ Title = "Wallbang!", Description = "Shot through walls!", Duration = 2 })
        end
    end
})

window:AddToggle({
    Title = T("tog_autoshoot"),
    Description = T("tog_autoshoot_desc"),
    Default = false,
    Tab = tabMain,
    Callback = function(val)
        autoShootActive = val
        if val then
            if not shootButtonGui then
                shootButtonGui = Instance.new("ScreenGui")
                shootButtonGui.Name = "ShootButtonGui"
                shootButtonGui.ResetOnSpawn = false
                shootButtonGui.Parent = CoreGui
                local btn = Instance.new("ImageButton")
                btn.Name = "ShootButton"
                btn.Size = UDim2.new(0,80,0,80)
                btn.Position = UDim2.new(0.5,-40,0.5,-40)
                btn.BackgroundColor3 = Color3.fromRGB(255,50,50)
                btn.BackgroundTransparency = 0.3
                btn.BorderSizePixel = 0
                btn.Parent = shootButtonGui
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(1,0)
                corner.Parent = btn
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = "🔫"
                label.TextSize = 32
                label.TextColor3 = Color3.new(1,1,1)
                label.Font = Enum.Font.GothamBold
                label.Parent = btn
                local dragging, dragStart, startPos
                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = btn.Position
                    end
                end)
                btn.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if dragging then
                            local delta = input.Position - dragStart
                            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                        end
                    end
                end)
                btn.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                btn.MouseButton1Click:Connect(function()
                    local murderer = findMurderer()
                    if not murderer then return end
                    local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
                    if not gun then return end
                    if gun.Parent ~= player.Character then gun.Parent = player.Character end
                    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then return end
                    local shootEvent = gun:FindFirstChild("ShootEvent") or gun:FindFirstChild("Shoot")
                    if shootEvent then
                        local origin = player.Character.HumanoidRootPart.Position
                        local targetPos = targetRoot.Position
                        shootEvent:FireServer(CFrame.new(origin, targetPos), CFrame.new(targetPos))
                    end
                end)
            end
        else
            if shootButtonGui then shootButtonGui:Destroy(); shootButtonGui = nil end
        end
    end
})

window:AddToggle({
    Title = T("tog_magicbullet"),
    Description = T("tog_magicbullet_desc"),
    Default = false,
    Tab = tabMain,
    Callback = function(val) magicBullet = val end
})

window:AddToggle({
    Title = T("tog_autogun"),
    Description = T("tog_autogun_desc"),
    Default = false,
    Tab = tabMain,
    Callback = function(val)
        grabGun = val
        if val then
            task.spawn(function()
                while grabGun and player:GetAttribute("Alive") == true do
                    local map = findMap()
                    if map and map:FindFirstChild("GunDrop") then
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            map.GunDrop.CFrame = root.CFrame
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- =====================================================
-- АВТОФАРМ (UI)
-- =====================================================
window:AddSection({ Name = T("sec_autofarm"), Tab = tabMain })
window:AddToggle({
    Title = T("tog_farm"),
    Description = T("tog_farm_desc"),
    Default = false,
    Tab = tabMain,
    Callback = function(val)
        farm = val
        if not val then stopFarming() end
    end
})
window:AddToggle({
    Title = T("tog_random_delays"),
    Description = T("tog_random_delays_desc"),
    Default = false,
    Tab = tabMain,
    Callback = function(val) randomDelays = val end
})
window:AddToggle({
    Title = T("tog_random_move"),
    Description = T("tog_random_move_desc"),
    Default = false,
    Tab = tabMain,
    Callback = function(val) randomMovement = val end
})
window:AddToggle({
    Title = T("tog_random_coin"),
    Description = T("tog_random_coin_desc"),
    Default = false,
    Tab = tabMain,
    Callback = function(val) randomCoinSelection = val end
})
window:AddToggle({
    Title = T("tog_antiafk"),
    Description = T("tog_antiafk_desc"),
    Default = false,
    Tab = tabMain,
    Callback = function(val)
        antiAFK = val
        if val then
            task.spawn(function()
                while antiAFK and task.wait(math.random(30, 60)) do
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        local humanoid = player.Character.Humanoid
                        humanoid:MoveTo(player.Character.HumanoidRootPart.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
                    end
                end
            end)
        end
    end
})
window:AddSlider({
    Title = T("slider_mindelay"),
    Tab = tabMain,
    Default = 0.1,
    MinValue = 0,
    MaxValue = 1,
    AllowDecimals = true,
    Callback = function(val) minDelay = val end
})
window:AddSlider({
    Title = T("slider_maxdelay"),
    Tab = tabMain,
    Default = 0.5,
    MinValue = 0,
    MaxValue = 2,
    AllowDecimals = true,
    Callback = function(val) maxDelay = val end
})

-- =====================================================
-- VISUALS
-- =====================================================
window:AddSection({ Name = T("sec_chams"), Tab = tabVisuals })
window:AddToggle({ Title = T("tog_chams_murder"), Default = false, Tab = tabVisuals, Callback = function(v) espSettings.Murderer = v end })
window:AddToggle({ Title = T("tog_chams_sheriff"), Default = false, Tab = tabVisuals, Callback = function(v) espSettings.Sheriff = v end })
window:AddToggle({ Title = T("tog_chams_innocent"), Default = false, Tab = tabVisuals, Callback = function(v) espSettings.Innocent = v end })
window:AddToggle({ Title = T("tog_chams_hero"), Default = false, Tab = tabVisuals, Callback = function(v) espSettings.Hero = v end })

window:AddSection({ Name = T("sec_esp"), Tab = tabVisuals })
window:AddToggle({ Title = T("tog_esp_murder"), Default = false, Tab = tabVisuals, Callback = function(v) nameEspSettings.Murderer = v end })
window:AddToggle({ Title = T("tog_esp_sheriff"), Default = false, Tab = tabVisuals, Callback = function(v) nameEspSettings.Sheriff = v end })
window:AddToggle({ Title = T("tog_esp_innocent"), Default = false, Tab = tabVisuals, Callback = function(v) nameEspSettings.Innocent = v end })
window:AddToggle({ Title = T("tog_esp_hero"), Default = false, Tab = tabVisuals, Callback = function(v) nameEspSettings.Hero = v end })

window:AddSection({ Name = T("sec_esp_custom"), Tab = tabVisuals })
window:AddToggle({ Title = T("tog_box2d"), Description = T("tog_box2d_desc"), Default = false, Tab = tabVisuals, Callback = function(v) espCustom.Box2D = v end })
window:AddToggle({ Title = T("tog_displayname"), Default = false, Tab = tabVisuals, Callback = function(v) espCustom.DisplayName = v; if v then espCustom.NormalName = false end end })
window:AddToggle({ Title = T("tog_normalname"), Default = true, Tab = tabVisuals, Callback = function(v) espCustom.NormalName = v; if v then espCustom.DisplayName = false end end })
window:AddToggle({ Title = T("tog_avatar"), Default = false, Tab = tabVisuals, Callback = function(v) espCustom.AvatarDisplay = v end })

-- =====================================================
-- MISC
-- =====================================================
window:AddSection({ Name = T("sec_discord"), Tab = tabMisc })
window:AddButton({
    Title = T("btn_copydiscord"),
    Description = T("btn_copydiscord_desc"),
    Tab = tabMisc,
    Callback = function()
        Clipboard:set("https://discord.gg/HsSSmNf69")
        window:Notify({ Title = T("notify_copied"), Description = "https://discord.gg/HsSSmNf69", Duration = 3 })
    end
})

window:AddSection({ Name = T("sec_nkno"), Tab = tabMisc })
window:AddToggle({
    Title = T("tog_tag"),
    Description = T("tog_tag_desc"),
    Default = false,
    Tab = tabMisc,
    Callback = function(val)
        customTagActive = val
        if val then
            if tagGui then tagGui:Destroy() end
            local head = player.Character and player.Character:FindFirstChild("Head")
            if head then
                tagGui = Instance.new("BillboardGui")
                tagGui.Name = "NKNO_Tag"
                tagGui.AlwaysOnTop = true
                tagGui.Size = UDim2.new(0,200,0,50)
                tagGui.StudsOffset = Vector3.new(0,2.5,0)
                tagGui.Parent = head
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = "👑 NKNO$"
                label.TextColor3 = Color3.fromRGB(255,0,0)
                label.TextSize = 24
                label.Font = Enum.Font.GothamBold
                label.TextStrokeColor3 = Color3.new(0,0,0)
                label.TextStrokeTransparency = 0.3
                label.Parent = tagGui
            end
            window:Notify({ Title = T("notify_tag_on"), Duration = 2 })
        else
            if tagGui then tagGui:Destroy(); tagGui = nil end
            window:Notify({ Title = T("notify_tag_off"), Duration = 2 })
        end
    end
})

window:AddToggle({
    Title = T("tog_pingfps"),
    Description = T("tog_pingfps_desc"),
    Default = false,
    Tab = tabMisc,
    Callback = function(val)
        pingFpsActive = val
        if val then
            if fpsGui then fpsGui:Destroy() end
            fpsGui = Instance.new("ScreenGui")
            fpsGui.Name = "PingFPS"
            fpsGui.Parent = CoreGui
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0,150,0,40)
            frame.Position = UDim2.new(0,10,0,10)
            frame.BackgroundTransparency = 0.5
            frame.BackgroundColor3 = Color3.new(0,0,0)
            frame.BorderSizePixel = 0
            frame.Parent = fpsGui
            local pingLabel = Instance.new("TextLabel")
            pingLabel.Size = UDim2.new(1,0,0.5,0)
            pingLabel.Position = UDim2.new(0,0,0,0)
            pingLabel.BackgroundTransparency = 1
            pingLabel.Text = "Ping: 0ms"
            pingLabel.TextColor3 = Color3.new(1,1,1)
            pingLabel.TextSize = 14
            pingLabel.Font = Enum.Font.Gotham
            pingLabel.Parent = frame
            local fpsLabel = Instance.new("TextLabel")
            fpsLabel.Size = UDim2.new(1,0,0.5,0)
            fpsLabel.Position = UDim2.new(0,0,0.5,0)
            fpsLabel.BackgroundTransparency = 1
            fpsLabel.Text = "FPS: 0"
            fpsLabel.TextColor3 = Color3.new(1,1,1)
            fpsLabel.TextSize = 14
            fpsLabel.Font = Enum.Font.Gotham
            fpsLabel.Parent = frame
            local lastUpdate = tick()
            local frameCount = 0
            local conn = RunService.RenderStepped:Connect(function(dt)
                frameCount = frameCount + 1
                if tick() - lastUpdate >= 1 then
                    fpsLabel.Text = "FPS: " .. frameCount
                    frameCount = 0
                    lastUpdate = tick()
                end
                pingLabel.Text = "Ping: " .. getPing() .. "ms"
            end)
            table.insert(connections, conn)
        else
            if fpsGui then fpsGui:Destroy(); fpsGui = nil end
        end
    end
})

window:AddButton({
    Title = T("btn_map_tp"),
    Tab = tabMisc,
    Callback = function()
        local map = findMap()
        if map and map:FindFirstChild("Spawns") then
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 then
                local spawn = spawns[math.random(1, #spawns)]
                if spawn:IsA("BasePart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = spawn.CFrame
                end
            end
        end
    end
})

window:AddButton({
    Title = T("btn_lobby_tp"),
    Tab = tabMisc,
    Callback = function()
        local lobby = Workspace:FindFirstChild("RegularLobby")
        if lobby and lobby:FindFirstChild("Spawns") then
            local spawns = lobby.Spawns:GetChildren()
            if #spawns > 0 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
            end
        end
    end
})

window:AddButton({
    Title = T("btn_murder_tp"),
    Tab = tabMisc,
    Callback = function()
        local murderer = findMurderer()
        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame
        end
    end
})

window:AddButton({
    Title = T("btn_sheriff_tp"),
    Tab = tabMisc,
    Callback = function()
        local dataEvent = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if not dataEvent then return end
        local success, data = pcall(function() return dataEvent:InvokeServer() end)
        if not success or not data then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr:GetAttribute("Alive") == true then
                local info = data[plr.Name]
                if info and info.Role == "Sheriff" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                    break
                end
            end
        end
    end
})

-- =====================================================
-- ФЛИНГ
-- =====================================================
local function SkidFling(target)
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    local tChar = target.Character
    if not tChar then return end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart")
    local tHead = tChar:FindFirstChild("Head")
    if not tRoot then return end
    getgenv().OldPos = root.CFrame
    for _, part in pairs(tChar:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    Workspace.CurrentCamera.CameraSubject = tRoot
    local bv = Instance.new("BodyVelocity")
    bv.Parent = root
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    local startTime = tick()
    while flingActive and (tick() - startTime) < 10 do
        if not root or not tRoot then break end
        root.CFrame = CFrame.new(tRoot.Position) * CFrame.new(0,1.5,0) * CFrame.Angles(math.rad(90),0,0)
        root.Velocity = Vector3.new(9e7, 9e7*10, 9e7)
        root.RotVelocity = Vector3.new(9e8,9e8,9e8)
        task.wait()
        root.CFrame = CFrame.new(tRoot.Position) * CFrame.new(0,-1.5,0) * CFrame.Angles(math.rad(90),0,0)
        root.Velocity = Vector3.new(9e7, 9e7*10, 9e7)
        root.RotVelocity = Vector3.new(9e8,9e8,9e8)
        task.wait()
    end
    bv:Destroy()
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Workspace.CurrentCamera.CameraSubject = humanoid
    if getgenv().OldPos then
        root.CFrame = getgenv().OldPos
    end
end

window:AddSection({ Name = T("sec_fling"), Tab = tabMisc })
window:AddButton({
    Title = T("btn_fling_murder"),
    Tab = tabMisc,
    Callback = function()
        if flingActive then return end
        local murderer = findMurderer()
        if murderer then
            flingActive = true
            window:Notify({ Title = T("notify_fling_start"), Description = murderer.Name, Duration = 2 })
            task.spawn(function()
                SkidFling(murderer)
                flingActive = false
            end)
        end
    end
})
window:AddButton({
    Title = T("btn_fling_sheriff"),
    Tab = tabMisc,
    Callback = function()
        if flingActive then return end
        local dataEvent = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if not dataEvent then return end
        local success, data = pcall(function() return dataEvent:InvokeServer() end)
        if not success or not data then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr:GetAttribute("Alive") == true then
                local info = data[plr.Name]
                if info and info.Role == "Sheriff" then
                    flingActive = true
                    window:Notify({ Title = T("notify_fling_start"), Description = plr.Name, Duration = 2 })
                    task.spawn(function()
                        SkidFling(plr)
                        flingActive = false
                    end)
                    break
                end
            end
        end
    end
})
window:AddButton({
    Title = T("btn_fling_sel"),
    Tab = tabMisc,
    Callback = function()
        if flingActive or not selectedPlayer then return end
        flingActive = true
        window:Notify({ Title = T("notify_fling_start"), Description = selectedPlayer.Name, Duration = 2 })
        task.spawn(function()
            SkidFling(selectedPlayer)
            flingActive = false
        end)
    end
})
window:AddButton({
    Title = T("btn_stop_fling"),
    Tab = tabMisc,
    Callback = function()
        if flingActive then
            flingActive = false
            window:Notify({ Title = T("notify_fling_stop"), Duration = 2 })
        end
    end
})
window:AddInput({
    Title = T("input_player"),
    Tab = tabMisc,
    Callback = function(text)
        if text and text ~= "" then
            for _, plr in pairs(Players:GetPlayers()) do
                if string.lower(plr.Name):find(string.lower(text)) then
                    selectedPlayer = plr
                    window:Notify({ Title = "Player selected", Description = plr.Name, Duration = 2 })
                    return
                end
            end
            selectedPlayer = nil
            window:Notify({ Title = T("notify_error"), Description = "Player not found", Duration = 2 })
        end
    end
})

-- UNDERMAP
window:AddToggle({
    Title = T("tog_undermap"),
    Description = T("tog_undermap_desc"),
    Default = false,
    Tab = tabMisc,
    Callback = function(val)
        underMapActive = val
        if val then
            oldFallenHeight = Workspace.FallenPartsDestroyHeight
            Workspace.FallenPartsDestroyHeight = -1/0
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local underY = -500
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
                        underY = (total / count).Y - 100
                    end
                end
                root.CFrame = CFrame.new(root.Position.X, underY, root.Position.Z)
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                local bv = Instance.new("BodyVelocity")
                bv.Parent = root
                bv.Velocity = Vector3.new(0,0,0)
                bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                if underMapConnection then underMapConnection:Disconnect() end
                underMapConnection = RunService.Heartbeat:Connect(function()
                    if not underMapActive or not player.Character or not root then
                        if bv then bv:Destroy() end
                        if underMapConnection then underMapConnection:Disconnect() end
                        return
                    end
                    root.Velocity = Vector3.new(0,0,0)
                    root.RotVelocity = Vector3.new(0,0,0)
                end)
            end
            window:Notify({ Title = T("notify_undermap_on"), Duration = 2 })
        else
            Workspace.FallenPartsDestroyHeight = oldFallenHeight
            if underMapConnection then underMapConnection:Disconnect(); underMapConnection = nil end
            if player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local bv = root:FindFirstChildOfClass("BodyVelocity")
                    if bv then bv:Destroy() end
                end
                local map = findMap()
                if map and map:FindFirstChild("Spawns") then
                    local spawns = map.Spawns:GetChildren()
                    if #spawns > 0 then
                        local spawn = spawns[math.random(1, #spawns)]
                        if spawn:IsA("BasePart") and root then
                            root.CFrame = spawn.CFrame + Vector3.new(0,5,0)
                        end
                    end
                end
            end
            window:Notify({ Title = T("notify_undermap_off"), Duration = 2 })
        end
    end
})

-- =====================================================
-- МОДИФИКАТОРЫ ПЕРСОНАЖА
-- =====================================================
window:AddSection({ Name = T("sec_char_mod"), Tab = tabMisc })
window:AddToggle({
    Title = T("tog_antifling"),
    Default = false,
    Tab = tabMisc,
    Callback = function(val)
        antiFling = val
        if val and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
})

window:AddToggle({
    Title = T("tog_customws"),
    Default = false,
    Tab = tabMisc,
    Callback = function(val)
        customWalkSpeed = val
        if val then
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = walkSpeedValue end
        else
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
        end
    end
})
window:AddSlider({
    Title = T("slider_ws"),
    Tab = tabMisc,
    Default = 16,
    MinValue = 16,
    MaxValue = 200,
    AllowDecimals = false,
    Callback = function(val)
        walkSpeedValue = val
        if customWalkSpeed and player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = val end
        end
    end
})
window:AddToggle({
    Title = T("tog_customjp"),
    Default = false,
    Tab = tabMisc,
    Callback = function(val)
        customJumpPower = val
        if val then
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower = jumpPowerValue end
        else
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower = 50 end
        end
    end
})
window:AddSlider({
    Title = T("slider_jp"),
    Tab = tabMisc,
    Default = 50,
    MinValue = 50,
    MaxValue = 200,
    AllowDecimals = false,
    Callback = function(val)
        jumpPowerValue = val
        if customJumpPower and player.Character then
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower = val end
        end
    end
})
window:AddToggle({
    Title = T("tog_customfov"),
    Default = false,
    Tab = tabMisc,
    Callback = function(val)
        customFOV = val
        if val then
            Workspace.CurrentCamera.FieldOfView = fovValue
        else
            Workspace.CurrentCamera.FieldOfView = 70
        end
    end
})
window:AddSlider({
    Title = T("slider_fov"),
    Tab = tabMisc,
    Default = 70,
    MinValue = 70,
    MaxValue = 120,
    AllowDecimals = false,
    Callback = function(val)
        fovValue = val
        if customFOV then Workspace.CurrentCamera.FieldOfView = val end
    end
})
window:AddToggle({
    Title = T("tog_forcefield"),
    Description = T("tog_forcefield_desc"),
    Default = false,
    Tab = tabMisc,
    Callback = function(val)
        forceFieldMat = val
        if val and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.Material = Enum.Material.ForceField
                end
            end
        elseif not val and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.Material = Enum.Material.Plastic
                end
            end
        end
    end
})

-- =====================================================
-- ТАНЦЫ
-- =====================================================
local function playDance()
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    if animator then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. danceId
        local track = animator:LoadAnimation(anim)
        track.Looped = true
        track.Priority = Enum.AnimationPriority.Action
        track:Play(0.1, 1, 1)
        task.wait(0.1)
        anim:Destroy()
    end
end

window:AddSection({ Name = T("sec_dance"), Tab = tabMisc })
window:AddDropdown({
    Title = T("dropdown_dance"),
    Options = {
        ["Dance 1"] = "127118661424463",
        ["Dance 2"] = "82682811348660",
        ["Dance 3"] = "10714340543",
        ["Dance 4"] = "15609995579"
    },
    Tab = tabMisc,
    Callback = function(val) if val then danceId = val end end
})
window:AddToggle({
    Title = T("tog_autodance"),
    Default = false,
    Tab = tabMisc,
    Callback = function(val)
        autoDance = val
        if val then playDance()
        else
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        track:Stop()
                    end
                end
            end
        end
    end
})

-- =====================================================
-- НАСТРОЙКИ
-- =====================================================
window:AddKeybind({
    Title = T("keybind_minimize"),
    Tab = tabSettings,
    Callback = function(key)
        window:SetSetting("Keybind", key)
    end
})
window:AddDropdown({
    Title = T("dropdown_theme"),
    Options = { ["Light Mode"] = "Light", ["Dark Mode"] = "Dark", ["Extra Dark"] = "Void" },
    Tab = tabSettings,
    Callback = function(val) window:SetTheme(val) end
})
window:AddToggle({
    Title = "UI Blur",
    Description = "If enabled, must have your Roblox graphics set to 8+ for it to work",
    Default = true,
    Tab = tabSettings,
    Callback = function(val) window:SetSetting("Blur", val) end
})
window:AddSlider({
    Title = "UI Transparency",
    Tab = tabSettings,
    AllowDecimals = true,
    MaxValue = 1,
    Callback = function(val) window:SetSetting("Transparency", val) end
})

-- =====================================================
-- ПРИВЕТСТВИЕ
-- =====================================================
window:Notify({ Title = "NKNO$ HUB", Description = T("notify_hello"), Duration = 5 })
print("NKNO$ HUB загружен! Язык: " .. Languages[lang])
