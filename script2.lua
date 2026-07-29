--[[
    NKNO$ HUB - Полное управление через GUI
    Discord: https://discord.gg/vQUM4JapP
]]

local DiscordLink = "https://discord.gg/vQUM4JapP"
local HubName = "NKNO$ HUB"

-- Сервисы
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

-- Состояния функций
local Features = {
    GodMode = false,
    InfiniteJump = false,
    SpeedHack = false,
    AntiAFK = false,
    ESP = false,
    Fly = false,
    NoClip = false,
    AutoFarm = false,
    Teleport = false,
}

local Settings = {
    SpeedMultiplier = 2,
    ESPColor = Color3.fromRGB(255, 0, 0),
    TeleportTarget = nil,
}

-- Хранилище для подключений
local Connections = {}

-- Функция для уведомлений
local function Notify(text, duration)
    duration = duration or 3
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = HubName,
        Text = text,
        Duration = duration,
    })
end

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NKNO$HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BackgroundTransparency = 0.6
Background.BorderSizePixel = 0
Background.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 500)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = HubName
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Закрытие
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.SourceSans
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.95, 0, 0, 2)
Line.Position = UDim2.new(0.025, 0, 0, 50)
Line.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- Дискорд
local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Size = UDim2.new(0.7, 0, 0, 25)
DiscordLabel.Position = UDim2.new(0, 10, 0, 55)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "Discord: " .. DiscordLink
DiscordLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DiscordLabel.TextSize = 14
DiscordLabel.Font = Enum.Font.SourceSans
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
DiscordLabel.Parent = MainFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 100, 0, 25)
CopyBtn.Position = UDim2.new(1, -110, 0, 55)
CopyBtn.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
CopyBtn.Text = "Копировать"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 14
CopyBtn.Font = Enum.Font.Gotham
CopyBtn.Parent = MainFrame
local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyBtn
CopyBtn.MouseButton1Click:Connect(function()
    setclipboard(DiscordLink)
    CopyBtn.Text = "Скопировано!"
    task.wait(1.5)
    CopyBtn.Text = "Копировать"
end)

-- Вкладки
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 40)
TabContainer.Position = UDim2.new(0, 10, 0, 85)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabNames = {"Основные", "Визуал", "Телепорт", "Настройки"}
local TabButtons = {}
local CurrentTab = "Основные"

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -135)
ContentContainer.Position = UDim2.new(0, 10, 0, 130)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Функция создания вкладки
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -2, 1, 0)
    btn.Position = UDim2.new(#TabButtons * 0.25, 0, 0, 0)
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

    -- Функция создания тогла
    local function AddToggle(label, featureKey, description)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
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

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(0.6, 0, 0, 16)
            desc.Position = UDim2.new(0, 0, 1, -16)
            desc.BackgroundTransparency = 1
            desc.Text = description
            desc.TextColor3 = Color3.fromRGB(150, 150, 150)
            desc.TextSize = 12
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Font = Enum.Font.SourceSans
            desc.Parent = frame
        end

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 80, 0, 30)
        toggle.Position = UDim2.new(1, -90, 0.5, -15)
        toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        toggle.Text = "Выкл"
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
            Features[featureKey] = state
            toggle.BackgroundColor3 = state and Color3.fromRGB(66, 133, 244) or Color3.fromRGB(60, 60, 70)
            toggle.Text = state and "Вкл" or "Выкл"
            Notify(label .. (state and " включена" or " выключена"), 2)
        end)

        return toggle
    end

    -- Функция создания слайдера
    local function AddSlider(label, settingKey, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 55)
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
        slider.Position = UDim2.new(0, 0, 0, 35)
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
            Settings[settingKey] = val
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
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
    end

    -- Функция создания кнопки
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
    if name == "Основные" then
        AddToggle("Бессмертие (God Mode)", "GodMode", "Защита от смерти")
        AddToggle("Бесконечный прыжок", "InfiniteJump", "Прыгайте без ограничений")
        AddToggle("Скорость (Speed Hack)", "SpeedHack", "Ускоренное передвижение")
        AddSlider("Множитель скорости", "SpeedMultiplier", 1, 10, 2, function(val)
            if Features.SpeedHack then
                local char = LP.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16 * val
                    end
                end
            end
        end)
        AddToggle("Анти-АФК", "AntiAFK", "Не даёт выкинуть из игры")
        AddToggle("Полёт (Fly)", "Fly", "Свободное перемещение в воздухе")
        AddToggle("Ноклип (NoClip)", "NoClip", "Проход сквозь стены")
        AddToggle("Авто-фарм (AutoFarm)", "AutoFarm", "Автоматический фарм (для некоторых игр)")
    end

    if name == "Визуал" then
        AddToggle("ESP (Игроки)", "ESP", "Показывает игроков через стены")
        AddButton("Изменить цвет ESP", function()
            Settings.ESPColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            Notify("Цвет ESP изменён", 2)
            if Features.ESP then
                -- Обновить существующие ESP
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
        AddButton("Показать всех игроков на карте", function()
            -- Просто пример, можно добавить функцию
            Notify("Функция в разработке", 2)
        end)
    end

    if name == "Телепорт" then
        local function refreshPlayers()
            -- Удаляем старые кнопки (кроме кнопки обновления)
            local children = ScrollingFrame:GetChildren()
            for _, child in ipairs(children) do
                if child:IsA("TextButton") and child.Name ~= "RefreshBtn" then
                    child:Destroy()
                end
            end
            local y = 0
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP then
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
                            local myChar = LP.Character
                            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                                myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                                Notify("Телепорт к " .. plr.Name, 2)
                            end
                        end
                    end)
                    y = y + 35
                end
            end
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, y)
        end

        local refreshBtn = Instance.new("TextButton")
        refreshBtn.Name = "RefreshBtn"
        refreshBtn.Size = UDim2.new(1, 0, 0, 30)
        refreshBtn.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
        refreshBtn.Text = "Обновить список игроков"
        refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        refreshBtn.TextSize = 14
        refreshBtn.Font = Enum.Font.Gotham
        refreshBtn.Parent = ScrollingFrame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = refreshBtn
        refreshBtn.MouseButton1Click:Connect(refreshPlayers)

        refreshPlayers()
        Players.PlayerAdded:Connect(refreshPlayers)
        Players.PlayerRemoving:Connect(refreshPlayers)
    end

    if name == "Настройки" then
        AddButton("Включить все функции", function()
            for key, _ in pairs(Features) do
                Features[key] = true
            end
            -- Обновить все тогглы
            for _, child in ipairs(ScrollingFrame:GetChildren()) do
                if child:IsA("Frame") then
                    local toggle = child:FindFirstChildOfClass("TextButton")
                    if toggle and toggle.Text == "Выкл" then
                        toggle.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
                        toggle.Text = "Вкл"
                    end
                end
            end
            Notify("Все функции включены", 3)
        end)

        AddButton("Выключить все функции", function()
            for key, _ in pairs(Features) do
                Features[key] = false
            end
            for _, child in ipairs(ScrollingFrame:GetChildren()) do
                if child:IsA("Frame") then
                    local toggle = child:FindFirstChildOfClass("TextButton")
                    if toggle and toggle.Text == "Вкл" then
                        toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                        toggle.Text = "Выкл"
                    end
                end
            end
            Notify("Все функции выключены", 3)
        end)

        AddButton("Выгрузить GUI", function()
            ScreenGui:Destroy()
        end)

        AddButton("Показать Discord ссылку", function()
            Notify("Discord: " .. DiscordLink, 5)
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

-- Создание вкладок
for _, tabName in ipairs(TabNames) do
    CreateTab(tabName)
end

-- Активация первой вкладки
if #TabButtons > 0 then
    TabButtons[1].BackgroundColor3 = Color3.fromRGB(66, 133, 244)
    TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- ===== Реализация функций =====

-- God Mode
local function updateGodMode(state)
    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if state then
                hum.BreakJointsOnDeath = false
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            else
                hum.BreakJointsOnDeath = true
                hum.MaxHealth = 100
                hum.Health = 100
            end
        end
    end
end

-- Следим за перерождением
LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Features.GodMode then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = false
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end
    if Features.SpeedHack then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16 * Settings.SpeedMultiplier
        end
    end
    if Features.Fly then
        -- Fly будет включен отдельно
    end
end)

-- Бесконечный прыжок
local function updateInfiniteJump(state)
    if state then
        local con
        con = UIS.JumpRequest:Connect(function()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        Connections.InfiniteJump = con
    else
        if Connections.InfiniteJump then
            Connections.InfiniteJump:Disconnect()
            Connections.InfiniteJump = nil
        end
    end
end

-- Скорость
local function updateSpeed(state)
    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = state and (16 * Settings.SpeedMultiplier) or 16
        end
    end
end

-- Анти-АФК
local function updateAntiAFK(state)
    if state then
        local con
        con = RunService.Heartbeat:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        Connections.AntiAFK = con
    else
        if Connections.AntiAFK then
            Connections.AntiAFK:Disconnect()
            Connections.AntiAFK = nil
        end
    end
end

-- ESP
local function updateESP(state)
    if state then
        local function createESP(plr)
            if plr == LP then return end
            local char = plr.Character
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
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.Parent = esp

            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(1, 0, 0, 16)
            distLabel.Position = UDim2.new(0, 0, 1, 20)
            distLabel.BackgroundTransparency = 1
            distLabel.Text = "0 м"
            distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            distLabel.TextSize = 12
            distLabel.Font = Enum.Font.SourceSans
            distLabel.Parent = esp

            local updateDist
            updateDist = RunService.Heartbeat:Connect(function()
                if not root or not root.Parent then
                    updateDist:Disconnect()
                    return
                end
                local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    distLabel.Text = string.format("%.1f м", dist)
                end
            end)
            esp:SetAttribute("UpdateDist", updateDist)
        end

        -- Создаём для всех игроков
        for _, plr in ipairs(Players:GetPlayers()) do
            createESP(plr)
        end

        -- Для новых
        local plrAddedCon = Players.PlayerAdded:Connect(createESP)
        Connections.ESP_Add = plrAddedCon

        -- Удаление при выходе
        local plrRemovedCon = Players.PlayerRemoving:Connect(function(plr)
            local char = plr.Character
            if char then
                local esp = char:FindFirstChild("NKNO$ESP")
                if esp then esp:Destroy() end
            end
        end)
        Connections.ESP_Rem = plrRemovedCon

    else
        -- Удалить все ESP
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            if char then
                local esp = char:FindFirstChild("NKNO$ESP")
                if esp then esp:Destroy() end
            end
        end
        if Connections.ESP_Add then Connections.ESP_Add:Disconnect() end
        if Connections.ESP_Rem then Connections.ESP_Rem:Disconnect() end
        Connections.ESP_Add = nil
        Connections.ESP_Rem = nil
    end
end

-- Полёт
local flying = false
local flySpeed = 50
local function updateFly(state)
    if state then
        flying = true
        local char = LP.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = root
                Connections.FlyBV = bodyVelocity

                local bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
                bodyGyro.Parent = root
                Connections.FlyGyro = bodyGyro

                local con
                con = RunService.Heartbeat:Connect(function()
                    if not flying then
                        con:Disconnect()
                        return
                    end
                    local moveVector = Vector3.new(0, 0, 0)
                    local forward = root.CFrame.LookVector
                    local right = root.CFrame.RightVector
                    local up = Vector3.new(0, 1, 0)

                    if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + forward end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - forward end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - right end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + right end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + up end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - up end

                    if moveVector.Magnitude > 0 then
                        moveVector = moveVector.Unit * flySpeed
                    end

                    bodyVelocity.Velocity = moveVector
                    bodyGyro.CFrame = root.CFrame
                end)
                Connections.FlyLoop = con
            end
        end
    else
        flying = false
        if Connections.FlyBV then Connections.FlyBV:Destroy() end
        if Connections.FlyGyro then Connections.FlyGyro:Destroy() end
        if Connections.FlyLoop then Connections.FlyLoop:Disconnect() end
        Connections.FlyBV = nil
        Connections.FlyGyro = nil
        Connections.FlyLoop = nil
    end
end

-- Ноклип
local function updateNoClip(state)
    if state then
        local con
        con = RunService.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Connections.NoClip = con
    else
        if Connections.NoClip then
            Connections.NoClip:Disconnect()
            Connections.NoClip = nil
        end
        -- Восстановить коллизию
        local char = LP.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Авто-фарм (простой пример - автоматическое нажатие кнопок)
local function updateAutoFarm(state)
    if state then
        local con
        con = RunService.Heartbeat:Connect(function()
            -- Здесь можно написать логику для конкретной игры, например, клик по объектам
            -- Для примера просто имитируем нажатие клавиши E
            UIS:SetKeyDown(Enum.KeyCode.E)
            task.wait(0.1)
            UIS:SetKeyUp(Enum.KeyCode.E)
        end)
        Connections.AutoFarm = con
    else
        if Connections.AutoFarm then
            Connections.AutoFarm:Disconnect()
            Connections.AutoFarm = nil
        end
    end
end

-- ===== Отслеживание изменений тогглов =====
-- Используем функцию, которая будет вызываться при изменении Features
-- Можно использовать метатаблицу для автоматического вызова при изменении
local featureMetatable = {
    __index = Features,
    __newindex = function(t, key, value)
        rawset(t, key, value)
        -- Вызываем соответствующую функцию
        if key == "GodMode" then updateGodMode(value) end
        if key == "InfiniteJump" then updateInfiniteJump(value) end
        if key == "SpeedHack" then updateSpeed(value) end
        if key == "AntiAFK" then updateAntiAFK(value) end
        if key == "ESP" then updateESP(value) end
        if key == "Fly" then updateFly(value) end
        if key == "NoClip" then updateNoClip(value) end
        if key == "AutoFarm" then updateAutoFarm(value) end
    end
}

setmetatable(Features, featureMetatable)

-- ===== Перемещение окна =====
local dragging = false
local dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ===== Загрузка завершена =====
Notify("NKNO$ HUB загружен! Discord: " .. DiscordLink, 5)
print("NKNO$ HUB загружен! Discord: " .. DiscordLink)
