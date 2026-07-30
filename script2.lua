-- NKNO$ HUB - Полная версия с Auto Farm Random + UnderMap (Чистый UI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Глобальные переменные
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- Настройки
local AntiFling = false
local AutoGrabGun = false
local FarmCoins = false
local IsFarming = false
local CurrentCoin = nil
local CoinCollected = false
local RandomDelays = false
local RandomMovement = false
local RandomCoinSelection = false
local AntiAFK = false
local MinDelay = 0.1
local MaxDelay = 0.5
local UnderMapActive = false
local UnderMapConnection = nil
local OldFallenHeight = workspace.FallenPartsDestroyHeight

-- ESP
ESP_SETTINGS = { Murderer = false, Sheriff = false, Innocent = false, Hero = false }
NAME_ESP_SETTINGS = { Murderer = false, Sheriff = false, Innocent = false, Hero = false }
ESP_CUSTOMIZATION = { Box2D = false, DisplayName = false, NormalName = true, AvatarDisplay = false }

-- Настройки персонажа
local CustomWalkSpeed = false
local WalkSpeedValue = 16
local CustomJumpPower = false
local JumpPowerValue = 50
local CustomFOV = false
local FOVValue = 70
local ForceFieldMaterial = false

-- Танцы
local AutoDance = false
local DanceID = "127118661424463"
local DanceAnim = nil
local Dances = {
    ["Dance 1"] = "127118661424463",
    ["Dance 2"] = "82682811348660",
    ["Dance 3"] = "10714340543",
    ["Dance 4"] = "15609995579",
}

-- Флинг
local Flinging = false
local SelectedPlayer = nil

-- Переменные для фарма
local Tween = nil
local NoclipConnection = nil
local SavedCollision = {}
local Farming = false

-- ===== UI СОЗДАНИЕ =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NKNO_HUB"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 570, 0, 370)
MainFrame.Position = UDim2.new(0.5, -285, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.2
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "NKNO$ HUB"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainFrame

-- Кнопка минимизации (скрыть/показать)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = MainFrame
MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Контейнер для вкладок (слева)
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 100, 1, -30)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Контейнер для содержимого (справа)
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -110, 1, -40)
ContentContainer.Position = UDim2.new(0, 105, 0, 35)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local ContentScrolling = Instance.new("ScrollingFrame")
ContentScrolling.Size = UDim2.new(1, 0, 1, 0)
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.BorderSizePixel = 0
ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScrolling.ScrollBarThickness = 6
ContentScrolling.Parent = ContentContainer

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentScrolling

-- Хранение вкладок
local Tabs = {}
local CurrentTab = nil

-- Функция создания вкладки
local function CreateTab(name, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, -10, 0, 35)
    tabButton.Position = UDim2.new(0, 5, 0, #Tabs * 40 + 5)
    tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.Parent = TabContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tabButton

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = ContentScrolling

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    table.insert(Tabs, { button = tabButton, content = content, layout = layout })

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in ipairs(Tabs) do
            tab.content.Visible = false
            tab.button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            tab.button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        content.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = name
        -- обновляем CanvasSize
        local totalHeight = 0
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("UIListLayout") then continue end
            totalHeight = totalHeight + child.Size.Y.Offset + 6
        end
        ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
    end)

    -- если первая вкладка, показываем её
    if #Tabs == 1 then
        content.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = name
    end

    return content
end

-- Функции для добавления элементов в содержимое
local function CreateSection(parent, name)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
end

local function CreateButton(parent, title, description, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Text = title
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button

    if description and description ~= "" then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 1, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(150, 150, 150)
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = button
    end

    button.MouseButton1Click:Connect(callback)
end

local function CreateToggle(parent, title, description, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -45, 0.5, -10)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggle

    local state = default
    callback(state)

    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
        callback(state)
    end)

    if description and description ~= "" then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.7, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 1, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(150, 150, 150)
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
end

local function CreateSlider(parent, title, description, min, max, default, decimals, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 6)
    slider.Position = UDim2.new(0, 0, 0.6, 0)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.BorderSizePixel = 0
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 12, 0, 12)
    drag.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    drag.BorderSizePixel = 0
    drag.Text = ""
    drag.Parent = slider

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = drag

    local function updateSlider(val)
        val = math.clamp(val, min, max)
        local percent = (val - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        drag.Position = UDim2.new(percent, -6, 0.5, -6)
        valueLabel.Text = decimals and string.format("%.1f", val) or tostring(math.round(val))
        callback(val)
    end

    drag.MouseButton1Down:Connect(function()
        local move, up
        move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = input.Position.X - slider.AbsolutePosition.X
                local val = min + (pos / slider.AbsoluteSize.X) * (max - min)
                updateSlider(val)
            end
        end)
        up = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                move:Disconnect()
                up:Disconnect()
            end
        end)
    end)

    if description and description ~= "" then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 1, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(150, 150, 150)
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
end

local function CreateDropdown(parent, title, description, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.4, 0, 1, 0)
    dropdown.Position = UDim2.new(0.6, 0, 0, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdown.BorderSizePixel = 0
    dropdown.Text = default or options[1]
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.TextSize = 14
    dropdown.Font = Enum.Font.GothamMedium
    dropdown.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = dropdown

    local listVisible = false
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.4, 0, 0, 100)
    listFrame.Position = UDim2.new(0.6, 0, 1, 2)
    listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = frame

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = listFrame

    local listScrolling = Instance.new("ScrollingFrame")
    listScrolling.Size = UDim2.new(1, 0, 1, 0)
    listScrolling.BackgroundTransparency = 1
    listScrolling.BorderSizePixel = 0
    listScrolling.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
    listScrolling.ScrollBarThickness = 4
    listScrolling.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listScrolling

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.BorderSizePixel = 0
        btn.Text = opt
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = listScrolling
        btn.MouseButton1Click:Connect(function()
            dropdown.Text = opt
            callback(opt)
            listFrame.Visible = false
            listVisible = false
        end)
    end

    dropdown.MouseButton1Click:Connect(function()
        listVisible = not listVisible
        listFrame.Visible = listVisible
        if listVisible then
            listFrame.Size = UDim2.new(0.4, 0, 0, math.min(#options * 30 + 10, 120))
        end
    end)

    if description and description ~= "" then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 1, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(150, 150, 150)
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
end

local function CreateInput(parent, title, description, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.5, 0, 1, 0)
    input.Position = UDim2.new(0.5, 0, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    input.BorderSizePixel = 0
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 14
    input.Font = Enum.Font.GothamMedium
    input.PlaceholderText = "Enter..."
    input.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = input

    input.FocusLost:Connect(function()
        callback(input.Text)
    end)

    if description and description ~= "" then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 1, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(150, 150, 150)
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame
    end
end

local function Notify(title, description, duration)
    duration = duration or 3
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(0.5, -150, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.8
    frame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -20, 0, 25)
    descLabel.Position = UDim2.new(0, 10, 0, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.TextSize = 13
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    game:GetService("TweenService"):Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.2 }):Play()
    task.wait(duration)
    game:GetService("TweenService"):Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
    task.wait(0.3)
    frame:Destroy()
end

-- ===== СОЗДАНИЕ ВКЛАДОК =====
local MainTab = CreateTab("Main")
local VisualsTab = CreateTab("Visuals")
local MiscTab = CreateTab("Misc")
local SettingsTab = CreateTab("Settings")

-- ===== MAIN TAB =====
CreateSection(MainTab, "Murder Functions")
CreateButton(MainTab, "Kill All", "Kill All Innocents", function()
    if not LocalPlayer then return end
    local char = LocalPlayer.Character
    if not char or not char.Parent then return end
    local knife = char:FindFirstChild("Knife")
    if not knife then
        knife = LocalPlayer.Backpack:FindFirstChild("Knife")
        if knife then knife.Parent = char else return end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, part in ipairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    targetRoot.Size = Vector3.new(5, 5, 5)
                    targetRoot.CFrame = root.CFrame + root.CFrame.LookVector * 3
                    targetRoot.Anchored = true
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    end
end)

CreateSection(MainTab, "Sheriff Functions")
local shootButtonActive = false
local shootGui = nil
local shootDrag = false
local shootStartPos = nil
local shootButtonPos = nil

local function createShootButton()
    if shootGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ShootButtonGui"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = UDim2.new(0.5, -40, 0.5, -40)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🔫"
    label.TextSize = 32
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.Parent = btn

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            shootDrag = true
            shootStartPos = input.Position
            shootButtonPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    shootDrag = false
                end
            end)
        end
    end)
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if shootDrag then
                local delta = input.Position - shootStartPos
                btn.Position = UDim2.new(shootButtonPos.X.Scale, shootButtonPos.X.Offset + delta.X, shootButtonPos.Y.Scale, shootButtonPos.Y.Offset + delta.Y)
            end
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if not shootDrag then
            local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
            if not gun then
                gun = LocalPlayer.Backpack:FindFirstChild("Gun")
                if gun then gun.Parent = LocalPlayer.Character else return end
            end
            local murderer = findMurderer()
            if not murderer then return end
            local mChar = murderer.Character
            if not mChar or not mChar:FindFirstChild("HumanoidRootPart") then return end
            local mRoot = mChar.HumanoidRootPart
            local torso = mChar:FindFirstChild("Torso") or mChar:FindFirstChild("UpperTorso")
            local hum = mChar:FindFirstChild("Humanoid")
            if not torso or not hum then return end
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            local pRoot = LocalPlayer.Character.HumanoidRootPart
            local ping = getPing()
            local bulletSpeed = 1.25
            local predict = (ping / 1000) * bulletSpeed
            local targetPos = torso.Position + (mRoot.Velocity * predict)
            local cframe = CFrame.new(pRoot.Position, targetPos)
            local shootEvent = gun:FindFirstChild("ShootEvent") or gun:FindFirstChild("Shoot")
            if shootEvent then
                shootEvent:FireServer(cframe, CFrame.new(targetPos))
            end
        end
    end)

    shootGui = gui
end

local function removeShootButton()
    if shootGui then shootGui:Destroy() shootGui = nil end
end

local magicBullet = false
CreateToggle(MainTab, "Auto Shoot Button", "Creates a draggable button to shoot the murderer", false, function(val)
    if val then createShootButton() else removeShootButton() end
end)
CreateToggle(MainTab, "Magic Bullet", "First argument will be set to murderer position", false, function(val)
    magicBullet = val
end)

CreateSection(MainTab, "Innocent Functions")
CreateToggle(MainTab, "Auto Grab Gun", "Automatically grabbing gun if sheriff died", false, function(val)
    AutoGrabGun = val
end)

CreateSection(MainTab, "Auto Farm")
local function returnCoinContainer()
    for _, child in pairs(workspace:GetChildren()) do
        if child:FindFirstChild("CoinContainer") and child:IsA("Model") then
            return child:FindFirstChild("CoinContainer")
        end
    end
    return nil
end

local function FindNearestCoin(container, useRandom)
    if not container then return nil, math.huge end
    local candidates = {}
    for _, coin in pairs(container:GetChildren()) do
        if coin:GetAttribute("CoinID") == "Coin" and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                table.insert(candidates, { coin = coin, dist = dist })
            end
        end
    end
    if #candidates == 0 then return nil, math.huge end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    if useRandom and #candidates > 2 then
        local index = math.random(1, math.min(3, #candidates))
        return candidates[index].coin, candidates[index].dist
    else
        return candidates[1].coin, candidates[1].dist
    end
end

CreateToggle(MainTab, "Farm Coins", "Automatically farm coins with noclip", false, function(val)
    FarmCoins = val
    if not val then
        Farming = false
        if Tween then Tween:Cancel() Tween = nil end
        if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
    end
end)
CreateToggle(MainTab, "Random Delays", "Add random delays between coin pickups", false, function(val) randomDelays = val end)
CreateToggle(MainTab, "Random Movement", "Add random offsets to movement path", false, function(val) randomMovement = val end)
CreateToggle(MainTab, "Random Coin Selection", "Pick random nearby coin instead of nearest", false, function(val) randomCoinSelection = val end)
CreateToggle(MainTab, "Anti-AFK", "Send random movements to avoid AFK kick", false, function(val)
    AntiAFK = val
    if val then
        task.spawn(function()
            while AntiAFK and task.wait(math.random(30, 60)) do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local hum = LocalPlayer.Character.Humanoid
                    local dir = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
                    hum:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + dir * 5)
                end
            end
        end)
    end
end)
CreateSlider(MainTab, "Min Delay (s)", "Minimum random delay", 0, 1, 0.1, true, function(val) minDelay = val end)
CreateSlider(MainTab, "Max Delay (s)", "Maximum random delay", 0, 2, 0.5, true, function(val) maxDelay = val end)

-- ===== VISUALS TAB =====
CreateSection(VisualsTab, "Chams")
CreateToggle(VisualsTab, "Chams Murderer", "", false, function(val) ESP_SETTINGS.Murderer = val end)
CreateToggle(VisualsTab, "Chams Sheriff", "", false, function(val) ESP_SETTINGS.Sheriff = val end)
CreateToggle(VisualsTab, "Chams Innocent", "", false, function(val) ESP_SETTINGS.Innocent = val end)
CreateToggle(VisualsTab, "Chams Hero", "", false, function(val) ESP_SETTINGS.Hero = val end)

CreateSection(VisualsTab, "ESP")
CreateToggle(VisualsTab, "ESP Murderer", "", false, function(val) NAME_ESP_SETTINGS.Murderer = val end)
CreateToggle(VisualsTab, "ESP Sheriff", "", false, function(val) NAME_ESP_SETTINGS.Sheriff = val end)
CreateToggle(VisualsTab, "ESP Innocent", "", false, function(val) NAME_ESP_SETTINGS.Innocent = val end)
CreateToggle(VisualsTab, "ESP Hero", "", false, function(val) NAME_ESP_SETTINGS.Hero = val end)

CreateSection(VisualsTab, "ESP Customization")
CreateToggle(VisualsTab, "2D Box", "", false, function(val) ESP_CUSTOMIZATION.Box2D = val end)
CreateToggle(VisualsTab, "Display Name", "", false, function(val)
    ESP_CUSTOMIZATION.DisplayName = val
    if val then ESP_CUSTOMIZATION.NormalName = false end
end)
CreateToggle(VisualsTab, "Normal Name", "", true, function(val)
    ESP_CUSTOMIZATION.NormalName = val
    if val then ESP_CUSTOMIZATION.DisplayName = false end
end)
CreateToggle(VisualsTab, "Avatar Display", "", false, function(val) ESP_CUSTOMIZATION.AvatarDisplay = val end)

-- ===== MISC TAB =====
CreateSection(MiscTab, "Anti-Fling")
CreateToggle(MiscTab, "Anti-Fling", "", false, function(val) AntiFling = val end)

CreateSection(MiscTab, "Character Modifiers")
CreateToggle(MiscTab, "Custom WalkSpeed", "", false, function(val)
    CustomWalkSpeed = val
    if val then applyWalkSpeed() else if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 end
    end end
end)
CreateSlider(MiscTab, "WalkSpeed Value", "", 16, 200, 16, false, function(val)
    WalkSpeedValue = val
    if CustomWalkSpeed then applyWalkSpeed() end
end)
CreateToggle(MiscTab, "Custom JumpPower", "", false, function(val)
    CustomJumpPower = val
    if val then applyJumpPower() else if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = 50 end
    end end
end)
CreateSlider(MiscTab, "JumpPower Value", "", 50, 200, 50, false, function(val)
    JumpPowerValue = val
    if CustomJumpPower then applyJumpPower() end
end)
CreateToggle(MiscTab, "Custom FOV", "", false, function(val)
    CustomFOV = val
    if val then applyFOV() else
        if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = 70 end
    end
end)
CreateSlider(MiscTab, "FOV Value", "", 70, 120, 70, false, function(val)
    FOVValue = val
    if CustomFOV then applyFOV() end
end)
CreateToggle(MiscTab, "Force Field Body Parts", "", false, function(val)
    ForceFieldMaterial = val
    if val then
        applyForceField()
        Notify("ForceField Enabled", "Body parts material set to ForceField", 2)
    else
        restoreMaterial()
        Notify("ForceField Disabled", "Body parts material restored", 2)
    end
end)

CreateSection(MiscTab, "Teleports")
CreateButton(MiscTab, "Map TP", "Teleports you in map", function()
    local map = findMap()
    if map and map:FindFirstChild("Spawns") then
        local spawns = map.Spawns:GetChildren()
        if #spawns > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
        end
    end
end)
CreateButton(MiscTab, "Lobby TP", "Teleports you in Lobby", function()
    local lobby = workspace:FindFirstChild("RegularLobby")
    if lobby and lobby:FindFirstChild("Spawns") then
        local spawns = lobby.Spawns:GetChildren()
        if #spawns > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
        end
    end
end)
CreateButton(MiscTab, "Murder TP", "Teleports you to Murder", function()
    local data = getPlayerData()
    if data then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
                local info = data[plr.Name]
                if info and info.Role == "Murderer" and plr.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                    return
                end
            end
        end
    end
end)
CreateButton(MiscTab, "Sheriff TP", "Teleports you to Sheriff", function()
    local data = getPlayerData()
    if data then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
                local info = data[plr.Name]
                if info and info.Role == "Sheriff" and plr.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                    return
                end
            end
        end
    end
end)

CreateSection(MiscTab, "Dance Emotes")
CreateDropdown(MiscTab, "Select Dance", "", {"Dance 1","Dance 2","Dance 3","Dance 4"}, "Dance 1", function(val)
    DanceID = Dances[val]
    if AutoDance then
        stopDance()
        task.wait(0.2)
        playDance()
    end
end)
CreateToggle(MiscTab, "Auto Dance", "", false, function(val)
    AutoDance = val
    if val then playDance() else stopDance() end
end)

CreateSection(MiscTab, "Fling Players")
CreateInput(MiscTab, "Player Search", "Enter player name or part of it", function(text)
    local plr = findPlayerByPartialName(text)
    if plr then
        SelectedPlayer = plr
        Notify("Player Found", "Selected: " .. plr.Name, 2)
    else
        SelectedPlayer = nil
        if text ~= "" then Notify("Not Found", "No player found matching: " .. text, 2) end
    end
end)
CreateButton(MiscTab, "Fling Murderer", "", function()
    if Flinging then return end
    local data = getPlayerData()
    if data then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
                local info = data[plr.Name]
                if info and info.Role == "Murderer" then
                    Flinging = true
                    Notify("Fling Started", "Flinging murderer: " .. plr.Name, 3)
                    task.spawn(function()
                        SkidFling(plr)
                        Flinging = false
                    end)
                    return
                end
            end
        end
    end
end)
CreateButton(MiscTab, "Fling Sheriff", "", function()
    if Flinging then return end
    local data = getPlayerData()
    if data then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
                local info = data[plr.Name]
                if info and info.Role == "Sheriff" then
                    Flinging = true
                    Notify("Fling Started", "Flinging sheriff: " .. plr.Name, 3)
                    task.spawn(function()
                        SkidFling(plr)
                        Flinging = false
                    end)
                    return
                end
            end
        end
    end
end)
CreateButton(MiscTab, "Fling Selected Player", "", function()
    if Flinging then return end
    if not SelectedPlayer or not SelectedPlayer.Parent then
        Notify("Error", "Please select a valid player first!", 3)
        return
    end
    Flinging = true
    Notify("Fling Started", "Flinging: " .. SelectedPlayer.Name, 3)
    task.spawn(function()
        SkidFling(SelectedPlayer)
        Flinging = false
    end)
end)
CreateButton(MiscTab, "Stop Fling", "", function()
    if Flinging then
        Flinging = false
        Notify("Fling Stopped", "Fling operation has been stopped", 3)
    else
        Notify("Info", "No active fling operation", 2)
    end
end)

CreateSection(MiscTab, "UnderMap")
CreateToggle(MiscTab, "UnderMap Mode", "Teleports you under the map, making you invincible", false, function(val)
    UnderMapActive = val
    if val then
        pcall(goUnderMap)
        Notify("UnderMap Activated", "You are now below the map!", 3)
    else
        pcall(returnFromUnderMap)
        Notify("UnderMap Deactivated", "Returned to the map!", 3)
    end
end)

-- ===== SETTINGS TAB =====
CreateSection(SettingsTab, "UI Settings")
CreateButton(SettingsTab, "Minimize Keybind", "Press Left Alt to toggle UI", function()
    Notify("Keybind", "Left Alt", 2)
end)
CreateDropdown(SettingsTab, "Set Theme", "", {"Light Mode","Dark Mode","Extra Dark"}, "Dark Mode", function(val)
    local theme
    if val == "Light Mode" then
        theme = { bg = Color3.fromRGB(240,240,240), text = Color3.fromRGB(0,0,0), btn = Color3.fromRGB(220,220,220) }
    elseif val == "Extra Dark" then
        theme = { bg = Color3.fromRGB(15,15,15), text = Color3.fromRGB(240,240,240), btn = Color3.fromRGB(30,30,30) }
    else
        theme = { bg = Color3.fromRGB(30,30,30), text = Color3.fromRGB(240,240,240), btn = Color3.fromRGB(50,50,50) }
    end
    MainFrame.BackgroundColor3 = theme.bg
    TitleLabel.TextColor3 = theme.text
    for _, tab in ipairs(Tabs) do
        tab.button.BackgroundColor3 = theme.btn
        tab.button.TextColor3 = theme.text
    end
    -- обновить остальные элементы по желанию
end)
CreateToggle(SettingsTab, "UI Blur", "Must have graphics 8+", true, function(val)
    -- реализация блюра через BackgroundTransparency или другие эффекты
end)
CreateSlider(SettingsTab, "UI Transparency", "", 0, 1, 0.2, true, function(val)
    MainFrame.BackgroundTransparency = val
end)

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====
local function applyWalkSpeed()
    if CustomWalkSpeed and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = WalkSpeedValue end
    end
end
local function applyJumpPower()
    if CustomJumpPower and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = JumpPowerValue end
    end
end
local function applyFOV()
    if CustomFOV and workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = FOVValue
    end
end
local function applyForceField()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Material = Enum.Material.ForceField
        end
    end
end
local function restoreMaterial()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Material = Enum.Material.Plastic
        end
    end
end

local function findMap()
    for _, child in pairs(workspace:GetChildren()) do
        if child:GetAttribute("MapID") then
            return child
        end
    end
    return nil
end

local function getPlayerData()
    local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not remote then return nil end
    local success, data = pcall(function() return remote:InvokeServer() end)
    if success then return data else return nil end
end

local function getPing()
    return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end

local function findMurderer()
    local data = getPlayerData()
    if not data then return nil end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
            local info = data[plr.Name]
            if info and info.Role == "Murderer" then return plr end
        end
    end
    return nil
end

local function findPlayerByPartialName(name)
    if not name or name == "" then return nil end
    local lower = string.lower(name)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if string.lower(plr.Name) == lower then return plr end
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if string.sub(string.lower(plr.Name), 1, #lower) == lower then return plr end
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if string.find(string.lower(plr.Name), lower, 1, true) then return plr end
        end
    end
    return nil
end

-- ===== ТАНЦЫ =====
local function playDance()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    if DanceAnim then
        pcall(function() DanceAnim:Stop() end)
        pcall(function() DanceAnim:Destroy() end)
        DanceAnim = nil
    end
    task.wait(0.1)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(DanceID)
    pcall(function()
        DanceAnim = animator:LoadAnimation(anim)
        DanceAnim.Looped = true
        DanceAnim.Priority = Enum.AnimationPriority.Action
        DanceAnim:Play(0.1, 1, 1)
    end)
    anim:Destroy()
end
local function stopDance()
    if DanceAnim then
        pcall(function() DanceAnim:Stop() end)
        pcall(function() DanceAnim:Destroy() end)
        DanceAnim = nil
    end
end

-- ===== ФЛИНГ =====
local function SkidFling(plr)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local root = hum.RootPart
    if not root then return end
    local targetChar = plr.Character
    if not targetChar then return end
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    local targetRoot = targetHum and targetHum.RootPart
    local targetHead = targetChar:FindFirstChild("Head")
    local targetAccessory = targetChar:FindFirstChildOfClass("Accessory")
    local targetHandle = targetAccessory and targetAccessory:FindFirstChild("Handle")
    if targetHum and targetHum.Sit then return end
    if not targetChar:FindFirstChildWhichIsA("BasePart") then return end

    local function teleportTo(part, offset, angles)
        root.CFrame = CFrame.new(part.Position) * offset * angles
        char:SetPrimaryPartCFrame(CFrame.new(part.Position) * offset * angles)
        root.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function flingLoop(part)
        local startTime = tick()
        local angle = 0
        repeat
            if root and part then
                if part.Velocity.Magnitude < 50 then
                    angle = angle + 100
                    teleportTo(part, CFrame.new(0, 1.5, 0) + targetHum.MoveDirection * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, -1.5, 0) + targetHum.MoveDirection * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, 1.5, 0) + targetHum.MoveDirection * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, -1.5, 0) + targetHum.MoveDirection * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, 1.5, 0) + targetHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, -1.5, 0) + targetHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                else
                    teleportTo(part, CFrame.new(0, 1.5, targetHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, -1.5, -targetHum.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, 1.5, targetHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    teleportTo(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            end
        until startTime + 3 < tick() or not Flinging
    end

    workspace.FallenPartsDestroyHeight = 0/0
    local bv = Instance.new("BodyVelocity")
    bv.Parent = root
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    local part = targetRoot or targetHead or targetHandle
    if part then
        flingLoop(part)
    end

    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = hum
    workspace.FallenPartsDestroyHeight = getgenv().FPDH
end

-- ===== UNDERMAP =====
local function goUnderMap()
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    OldFallenHeight = workspace.FallenPartsDestroyHeight
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
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    UnderMapConnection = RunService.Heartbeat:Connect(function()
        if not UnderMapActive or not LocalPlayer.Character or not root then
            if bv then bv:Destroy() end
            if UnderMapConnection then UnderMapConnection:Disconnect() end
            return
        end
        if (root.Position - targetCF.p).Magnitude > 5 then
            root.CFrame = targetCF
        end
        root.Velocity = Vector3.new(0,0,0)
        root.RotVelocity = Vector3.new(0,0,0)
    end)
end

local function returnFromUnderMap()
    if UnderMapConnection then
        UnderMapConnection:Disconnect()
        UnderMapConnection = nil
    end
    workspace.FallenPartsDestroyHeight = OldFallenHeight
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
                    LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
end

-- ===== ESP =====
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
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not head or not root then return end
    local gui = head:FindFirstChild("NameESP")
    if not gui then
        gui = Instance.new("BillboardGui")
        gui.Name = "NameESP"
        gui.AlwaysOnTop = true
        gui.Size = UDim2.new(0, 200, 0, 80)
        gui.StudsOffset = Vector3.new(0, 2, 0)
        gui.Parent = head

        local avatarFrame = Instance.new("Frame")
        avatarFrame.Name = "AvatarFrame"
        avatarFrame.BackgroundColor3 = Color3.new(1,1,1)
        avatarFrame.Size = UDim2.new(0, 40, 0, 40)
        avatarFrame.Position = UDim2.new(0.5, -20, 0, 0)
        avatarFrame.BorderSizePixel = 2
        avatarFrame.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1,0)
        corner.Parent = avatarFrame

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Name = "Avatar"
        avatarImg.BackgroundTransparency = 1
        avatarImg.Size = UDim2.new(1,0,1,0)
        avatarImg.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        avatarImg.Parent = avatarFrame
        local corner2 = Instance.new("UICorner")
        corner2.CornerRadius = UDim.new(1,0)
        corner2.Parent = avatarImg

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
        if ESP_CUSTOMIZATION.DisplayName then
            nameLabel.Text = plr.DisplayName
        elseif ESP_CUSTOMIZATION.NormalName then
            nameLabel.Text = plr.Name
        else
            nameLabel.Text = ""
        end
        nameLabel.TextColor3 = color
    end
    local avatarFrame = gui:FindFirstChild("AvatarFrame")
    if avatarFrame then
        avatarFrame.Visible = ESP_CUSTOMIZATION.AvatarDisplay
        avatarFrame.BorderColor3 = color
    end

    -- 2D Box
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

local Colors = {
    Murderer = Color3.fromRGB(255,0,0),
    Sheriff = Color3.fromRGB(0,0,255),
    Hero = Color3.fromRGB(255,255,0),
    Innocent = Color3.fromRGB(0,255,0)
}

local function UpdateESP()
    local data = getPlayerData()
    if not data then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
            local role = "Innocent"
            local info = data[plr.Name]
            if info and info.Role then role = info.Role end
            local color = Colors[role] or Colors.Innocent
            if ESP_SETTINGS[role] == true then
                CreateESP(plr, color)
            else
                RemoveESP(plr)
            end
            if NAME_ESP_SETTINGS[role] == true then
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

-- ===== АВТО-ГРАБ ПИСТОЛЕТА =====
local function autoGrabGun()
    pcall(function()
        if not AutoGrabGun then return end
        if not LocalPlayer:GetAttribute("Alive") then return end
        local map = findMap()
        if not map then return end
        local gunDrop = map:FindFirstChild("GunDrop")
        if gunDrop then
            gunDrop.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- ===== ФАРМ МОНЕТ =====
local function enableNoclip()
    if NoclipConnection then return end
    NoclipConnection = RunService.Stepped:Connect(function()
        if FarmCoins and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function startFarming()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if LocalPlayer:GetAttribute("Alive") ~= true then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    SavedCollision = {}
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            SavedCollision[part] = { CanCollide = part.CanCollide, Massless = part.Massless }
        end
    end
    root.CFrame = root.CFrame - Vector3.new(0, 2.5, 0)
    root.CFrame = root.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    if hum then
        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
    Farming = true
end

local function stopFarming()
    Farming = false
    if Tween then Tween:Cancel() Tween = nil end
    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
    if LocalPlayer.Character then
        for part, data in pairs(SavedCollision) do
            if part and part.Parent then
                part.CanCollide = data.CanCollide
                part.Massless = data.Massless
            end
        end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
            root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            root.CFrame = root.CFrame + Vector3.new(0, 2.5, 0)
        end
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
    SavedCollision = {}
end

-- События сбора монет
local coinRemote = ReplicatedStorage.Remotes.Gameplay.CoinCollected
coinRemote.OnClientEvent:Connect(function(plr, current, total)
    if plr == LocalPlayer then
        if tonumber(current) == tonumber(total) then
            CoinCollected = true
            if Farming then stopFarming() end
        else
            CoinCollected = false
        end
    end
end)

local roundStart = ReplicatedStorage.Remotes.Gameplay.RoundStart
local roundEnd = ReplicatedStorage.Remotes.Gameplay.RoundEndFade
roundStart.OnClientEvent:Connect(function()
    CoinCollected = false
end)
roundEnd.OnClientEvent:Connect(function()
    CoinCollected = false
    if Farming then stopFarming() end
end)

-- Основной цикл фарма
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Farming and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer:GetAttribute("Alive") == true then
            local root = LocalPlayer.Character.HumanoidRootPart
            local container = returnCoinContainer()
            if container then
                for _, coin in pairs(container:GetChildren()) do
                    if coin:GetAttribute("CoinID") == "Coin" and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 then
                        if (root.Position - coin.Position).Magnitude <= 5 then
                            firetouchinterest(root, coin, 0)
                            firetouchinterest(root, coin, 1)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if FarmCoins and not CoinCollected and LocalPlayer:GetAttribute("Alive") == true and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local container = returnCoinContainer()
            if container then
                local coin, dist = FindNearestCoin(container, RandomCoinSelection)
                if coin and coin.Transparency == 1 and not CoinCollected then
                    if not Farming then startFarming() end
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    root.Velocity = Vector3.new(0,0,0)
                    root.RotVelocity = Vector3.new(0,0,0)
                    local offset = Vector3.new()
                    if RandomMovement then
                        offset = Vector3.new(math.random(-2,2), 0, math.random(-2,2))
                    end
                    local targetPos = coin.Position - Vector3.new(0, 2.5, 0) + offset
                    local targetCF = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)
                    enableNoclip()
                    local duration = (dist / 23) * (RandomMovement and (0.8 + math.random() * 0.4) or 1)
                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    Tween = TweenService:Create(root, tweenInfo, { CFrame = targetCF })
                    Tween:Play()
                    local connection
                    connection = RunService.Heartbeat:Connect(function()
                        if FarmCoins and LocalPlayer:GetAttribute("Alive") == true and root then
                            root.Velocity = Vector3.new(0,0,0)
                            root.RotVelocity = Vector3.new(0,0,0)
                            if hum then hum.PlatformStand = true end
                        else
                            if connection then connection:Disconnect() end
                        end
                    end)
                    while coin and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 and not CoinCollected and FarmCoins and LocalPlayer:GetAttribute("Alive") == true do
                        RunService.Heartbeat:Wait()
                    end
                    if connection then connection:Disconnect() end
                    if Tween then Tween:Cancel() Tween = nil end
                    if root then
                        root.Velocity = Vector3.new(0,0,0)
                        root.RotVelocity = Vector3.new(0,0,0)
                    end
                    if RandomDelays then
                        task.wait(minDelay + math.random() * (maxDelay - minDelay))
                    end
                else
                    if Farming then stopFarming() end
                end
            else
                if Farming then stopFarming() end
            end
        else
            if Farming then stopFarming() end
        end
    end
end)

-- ===== АНТИ-ФЛИНГ =====
local function antiFling()
    -- реализация из оригинального скрипта для всех игроков
    -- уже добавлена в setupCharacterCollision
end

-- ===== ЗАПУСК ESP И АВТО-ГРАБА =====
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        UpdateESP()
        autoGrabGun()
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        UpdateESP()
    end)
end)

-- ===== ИНИЦИАЛИЗАЦИЯ =====
Notify("NKNO$ HUB Loaded!", "Press Left Alt to toggle UI", 5)
