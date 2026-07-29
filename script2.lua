--[[
    NKNO$ HUB
    Версия 2.0 (Многофункциональный)
    Discord: https://discord.gg/vQUM4JapP
]]

local DiscordLink = "https://discord.gg/vQUM4JapP"

-- ========== Службы ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")

-- ========== Переменные состояния ==========
local Settings = {
    GodMode = false,
    SpeedHack = false,
    SpeedMultiplier = 2,
    InfiniteJump = false,
    AntiAFK = false,
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    TeleportToPlayer = nil,
}

-- ========== Создание GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NKNO$HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Затемнение
local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BackgroundTransparency = 0.7
Background.BorderSizePixel = 0
Background.Parent = ScreenGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 420)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NKNO$ HUB"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 8)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.SourceSans
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Линия
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.95, 0, 0, 2)
Line.Position = UDim2.new(0.025, 0, 0, 50)
Line.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- Дискорд ссылка
local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Size = UDim2.new(1, -20, 0, 25)
DiscordLabel.Position = UDim2.new(0, 10, 0, 55)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "Discord: " .. DiscordLink
DiscordLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DiscordLabel.TextSize = 14
DiscordLabel.Font = Enum.Font.SourceSans
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
DiscordLabel.Parent = MainFrame

-- Кнопка копирования
local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(0, 120, 0, 25)
CopyButton.Position = UDim2.new(1, -130, 0, 55)
CopyButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
CopyButton.Text = "Копировать"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextSize = 14
CopyButton.Font = Enum.Font.Gotham
CopyButton.Parent = MainFrame

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyButton

CopyButton.MouseButton1Click:Connect(function()
    setclipboard(DiscordLink)
    CopyButton.Text = "Скопировано!"
    task.wait(1.5)
    CopyButton.Text = "Копировать"
end)

-- ========== Вкладки ==========
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 40)
TabContainer.Position = UDim2.new(0, 10, 0, 85)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local Tabs = {"Игрок", "Визуал", "Телепорт", "Настройки"}
local TabButtons = {}
local CurrentTab = "Игрок"

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -135)
ContentContainer.Position = UDim2.new(0, 10, 0, 130)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Функция создания вкладок
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -2, 1, 0)
    btn.Position = UDim2.new((#TabButtons) * 0.25, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = TabContainer

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = (name == CurrentTab)
    content.Parent = ContentContainer

    -- Скроллинг, если много элементов
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 6
    ScrollingFrame.Parent = content

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollingFrame

    local yOffset = 0

    -- Функция добавления кнопки-переключателя
    local function AddToggle(label, settingKey, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 35)
        frame.BackgroundTransparency = 1
        frame.Parent = ScrollingFrame

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(0.6, 0, 1, 0)
        text.Position = UDim2.new(0, 0, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextColor3 = Color3.fromRGB(220, 220, 220)
        text.TextSize = 16
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Font = Enum.Font.SourceSans
        text.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 80, 0, 30)
        toggle.Position = UDim2.new(1, -90, 0.5, -15)
        toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        toggle.Text = "Вкл"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 14
        toggle.Font = Enum.Font.Gotham
        toggle.Parent = frame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 6)
        toggleCorner.Parent = toggle

        local state = false
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(66, 133, 244) or Color3.fromRGB(60, 60, 70)
            toggle.Text = state and "Вкл" or "Выкл"
            if settingKey then Settings[settingKey] = state end
            if callback then callback(state) end
        end)

        return toggle, frame
    end

    -- Функция добавления слайдера
    local function AddSlider(label, settingKey, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundTransparency = 1
        frame.Parent = ScrollingFrame

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(0.6, 0, 0, 20)
        text.Position = UDim2.new(0, 0, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextColor3 = Color3.fromRGB(220, 220, 220)
        text.TextSize = 16
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Font = Enum.Font.SourceSans
        text.Parent = frame

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        valueLabel.TextSize = 16
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Font = Enum.Font.SourceSans
        valueLabel.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 6)
        slider.Position = UDim2.new(0, 0, 0, 30)
        slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        slider.BorderSizePixel = 0
        slider.Parent = frame

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
        fill.BorderSizePixel = 0
        fill.Parent = slider

        local dragging = false
        local function updateSlider(x)
            local rel = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local val = min + rel * (max - min)
            val = math.round(val)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(val)
            if settingKey then Settings[settingKey] = val end
            if callback then callback(val) end
        end

        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input.Position.X)
            end
        end)
        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
    end

    -- Функция добавления простой кнопки
    local function AddButton(label, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.Text = label
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.Gotham
        btn.Parent = ScrollingFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Заполнение вкладок
    if name == "Игрок" then
        AddToggle("Бессмертие (God Mode)", "GodMode", function(state)
            if state then
                -- Простейший God Mode через изменение Humanoid
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum:BreakJointsOnDeath = false
                        hum.MaxHealth = math.huge
                        hum.Health = math.huge
                    end
                end
                -- Следим за появлением персонажа
                local con
                con = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    task.wait(0.5)
                    local hum = newChar:FindFirstChild("Humanoid")
                    if hum then
                        hum.BreakJointsOnDeath = false
                        hum.MaxHealth = math.huge
                        hum.Health = math.huge
                    end
                end)
                if not Settings._godCon then Settings._godCon = {} end
                Settings._godCon[1] = con
            else
                -- Отключаем
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.BreakJointsOnDeath = true
                        hum.MaxHealth = 100
                        hum.Health = 100
                    end
                end
                if Settings._godCon and Settings._godCon[1] then
                    Settings._godCon[1]:Disconnect()
                    Settings._godCon[1] = nil
                end
            end
        end)

        AddToggle("Бесконечный прыжок", "InfiniteJump", function(state)
            if state then
                local con
                con = UserInputService.JumpRequest:Connect(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
                if not Settings._jumpCon then Settings._jumpCon = {} end
                Settings._jumpCon[1] = con
            else
                if Settings._jumpCon and Settings._jumpCon[1] then
                    Settings._jumpCon[1]:Disconnect()
                    Settings._jumpCon[1] = nil
                end
            end
        end)

        AddSlider("Множитель скорости", "SpeedMultiplier", 1, 10, 2, function(val)
            if Settings.SpeedHack then
                -- Обновляем скорость
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16 * val
                    end
                end
            end
        end)

        AddToggle("Скорость (Speed Hack)", "SpeedHack", function(state)
            Settings.SpeedHack = state
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    if state then
                        hum.WalkSpeed = 16 * Settings.SpeedMultiplier
                    else
                        hum.WalkSpeed = 16
                    end
                end
            end
        end)

        AddToggle("Анти-АФК", "AntiAFK", function(state)
            if state then
                local con
                con = RunService.Heartbeat:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
                if not Settings._afkCon then Settings._afkCon = {} end
                Settings._afkCon[1] = con
            else
                if Settings._afkCon and Settings._afkCon[1] then
                    Settings._afkCon[1]:Disconnect()
                    Settings._afkCon[1] = nil
                end
            end
        end)

        AddButton("Изменить имя в игре (Fake Name)", function()
            local name = game:GetService("TextService"):GetTextSize("Введите новое имя", 16, Enum.Font.SourceSans, Vector2.new(1000, 1000))
            local input = game:GetService("GuiService"):GetGuiObjectAtPosition()
            -- Для простоты используем диалог ввода (в некоторых эксплойтах есть)
            local newName = "NKNO$ Hacker"
            LocalPlayer.Character.Humanoid.DisplayName = newName
        end)
    end

    if name == "Визуал" then
        AddToggle("ESP (Игроки)", "ESPEnabled", function(state)
            Settings.ESPEnabled = state
            if state then
                -- Создаем ESP для всех игроков
                local function createESP(player)
                    if player == LocalPlayer then return end
                    local char = player.Character
                    if not char then return end
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    local esp = Instance.new("BillboardGui")
                    esp.Name = "NKNO$ESP"
                    esp.Size = UDim2.new(0, 60, 0, 60)
                    esp.Adornee = root
                    esp.AlwaysOnTop = true
                    esp.Parent = char

                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundTransparency = 0.5
                    frame.BackgroundColor3 = Settings.ESPColor
                    frame.BorderSizePixel = 0
                    frame.Parent = esp

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 0, 20)
                    nameLabel.Position = UDim2.new(0, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = player.Name
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.TextScaled = true
                    nameLabel.Font = Enum.Font.Gotham
                    nameLabel.Parent = esp

                    local distanceLabel = Instance.new("TextLabel")
                    distanceLabel.Size = UDim2.new(1, 0, 0, 16)
                    distanceLabel.Position = UDim2.new(0, 0, 1, 20)
                    distanceLabel.BackgroundTransparency = 1
                    distanceLabel.Text = "0 м"
                    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    distanceLabel.TextSize = 12
                    distanceLabel.Font = Enum.Font.SourceSans
                    distanceLabel.Parent = esp

                    -- Обновление расстояния
                    local updateDist
                    updateDist = RunService.Heartbeat:Connect(function()
                        if not root or not root.Parent then
                            updateDist:Disconnect()
                            return
                        end
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            local dist = (myRoot.Position - root.Position).Magnitude
                            distanceLabel.Text = string.format("%.1f м", dist)
                        end
                    end)
                    esp:SetAttribute("UpdateDist", updateDist)
                end

                -- Для существующих игроков
                for _, plr in ipairs(Players:GetPlayers()) do
                    createESP(plr)
                end
                -- Для новых
                local newPlayerCon
                newPlayerCon = Players.PlayerAdded:Connect(createESP)
                Settings._espCon = newPlayerCon
                Settings._espCreated = true

                -- Очистка при удалении игрока
                local remCon
                remCon = Players.PlayerRemoving:Connect(function(plr)
                    local char = plr.Character
                    if char then
                        local esp = char:FindFirstChild("NKNO$ESP")
                        if esp then esp:Destroy() end
                    end
                end)
                Settings._espRemCon = remCon
            else
                -- Удаляем ESP
                for _, plr in ipairs(Players:GetPlayers()) do
                    local char = plr.Character
                    if char then
                        local esp = char:FindFirstChild("NKNO$ESP")
                        if esp then esp:Destroy() end
                    end
                end
                if Settings._espCon then Settings._espCon:Disconnect() end
                if Settings._espRemCon then Settings._espRemCon:Disconnect() end
                Settings._espCreated = false
            end
        end)

        AddButton("Изменить цвет ESP", function()
            -- Простой выбор цвета (можно расширить)
            Settings.ESPColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            if Settings.ESPEnabled then
                -- Обновляем цвет существующих ESP
                for _, plr in ipairs(Players:GetPlayers()) do
                    local char = plr.Character
                    if char then
                        local esp = char:FindFirstChild("NKNO$ESP")
                        if esp then
                            local frame = esp:FindFirstChildOfClass("Frame")
                            if frame then frame.BackgroundColor3 = Settings.ESPColor end
                        end
                    end
                end
            end
        end)
    end

    if name == "Телепорт" then
        -- Список игроков
        local function refreshPlayerList()
            -- Очищаем старые кнопки (кроме первой)
            local children = ScrollingFrame:GetChildren()
            for _, child in ipairs(children) do
                if child:IsA("TextButton") and child.Name ~= "RefreshBtn" then
                    child:Destroy()
                end
            end
            local y = 0
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 30)
                    btn.Position = UDim2.new(0, 0, 0, y)
                    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                    btn.Text = plr.Name
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.TextSize = 14
                    btn.Font = Enum.Font.Gotham
                    btn.Parent = ScrollingFrame
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 4)
                    corner.Parent = btn

                    btn.MouseButton1Click:Connect(function()
                        local targetChar = plr.Character
                        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                            local myChar = LocalPlayer.Character
                            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                                myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                    end)
                    y = y + 35
                end
            end
            -- Обновляем CanvasSize
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, y)
        end

        local refreshBtn = Instance.new("TextButton")
        refreshBtn.Name = "RefreshBtn"
        refreshBtn.Size = UDim2.new(1, 0, 0, 30)
        refreshBtn.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
        refreshBtn.Text = "Обновить список"
        refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        refreshBtn.TextSize = 14
        refreshBtn.Font = Enum.Font.Gotham
        refreshBtn.Parent = ScrollingFrame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = refreshBtn

        refreshBtn.MouseButton1Click:Connect(refreshPlayerList)

        -- Инициализация
        refreshPlayerList()

        -- Автообновление при входе/выходе
        local playersCon
        playersCon = Players.PlayerAdded:Connect(refreshPlayerList)
        playersCon = Players.PlayerRemoving:Connect(refreshPlayerList)
        if not Settings._teleportCons then Settings._teleportCons = {} end
        Settings._teleportCons[1] = playersCon
    end

    if name == "Настройки" then
        AddButton("Сбросить все настройки", function()
            Settings.GodMode = false
            Settings.InfiniteJump = false
            Settings.SpeedHack = false
            Settings.SpeedMultiplier = 2
            Settings.AntiAFK = false
            Settings.ESPEnabled = false
            -- Отключаем все активные хуки (просто перезагружаем)
            ScreenGui:Destroy()
            -- Перезапускаем скрипт (загружаем заново)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/script.lua"))()
        end)

        AddButton("Выгрузить GUI", function()
            ScreenGui:Destroy()
        end)

        AddButton("Показать ссылку Discord", function()
            print("Discord: " .. DiscordLink)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "NKNO$ HUB",
                Text = "Discord: " .. DiscordLink,
                Duration = 5,
            })
        end)
    end

    -- Переключение вкладок
    btn.MouseButton1Click:Connect(function()
        for _, tab in ipairs(TabButtons) do
            tab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        btn.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = name
        for _, child in ipairs(ContentContainer:GetChildren()) do
            child.Visible = false
        end
        content.Visible = true
    end)

    table.insert(TabButtons, btn)
    return content
end

-- Создание всех вкладок
for _, tabName in ipairs(Tabs) do
    CreateTab(tabName)
end

-- Активация первой вкладки
TabButtons[1].BackgroundColor3 = Color3.fromRGB(66, 133, 244)
TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ========== Перемещение окна ==========
local dragging = false
local dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ========== Фоновые задачи ==========
-- Автоматическое обновление God Mode при смерти
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Settings.GodMode then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = false
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end
    if Settings.SpeedHack then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16 * Settings.SpeedMultiplier
        end
    end
end)

print("NKNO$ HUB загружен! Discord: " .. DiscordLink)
