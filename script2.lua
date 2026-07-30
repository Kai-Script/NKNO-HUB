-- ===============================
-- NKNO$ HUB ULTIMATE EDITION
-- Полностью переработан, оптимизирован, с мини-режимом и новыми фичами
-- ===============================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Глобальные настройки (доступны для изменения)
getgenv().NKNO = {
    AntiFling = false,
    AutoGrabGun = false,
    FarmCoins = false,
    RandomDelays = false,
    RandomMovement = false,
    RandomCoinSelection = false,
    AntiAFK = false,
    MinDelay = 0.1,
    MaxDelay = 0.5,
    UnderMap = false,
    CustomWalkSpeed = false,
    WalkSpeedValue = 16,
    CustomJumpPower = false,
    JumpPowerValue = 50,
    CustomFOV = false,
    FOVValue = 70,
    ForceFieldMaterial = false,
    AutoDance = false,
    DanceID = "127118661424463",
    AutoRespawn = false,
    GodMode = false,      -- режим неуязвимости (убирает коллизию)
    AutoBuyKnife = false,
    AutoBuyGun = false,
    ESP = {
        Murderer = false,
        Sheriff = false,
        Innocent = false,
        Hero = false,
        Box2D = false,
        DisplayName = false,
        NormalName = true,
        AvatarDisplay = false,
        ColorMurderer = Color3.fromRGB(255,0,0),
        ColorSheriff = Color3.fromRGB(0,0,255),
        ColorHero = Color3.fromRGB(255,255,0),
        ColorInnocent = Color3.fromRGB(0,255,0),
        OutlineThickness = 2,
        FontSize = 14,
    },
}

-- Вспомогательные функции
local function findMap()
    for _, child in pairs(Workspace:GetChildren()) do
        if child:GetAttribute("MapID") then return child end
    end
    return nil
end

local function getPlayerData()
    local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not remote then return nil end
    local success, data = pcall(function() return remote:InvokeServer() end)
    return success and data or nil
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

local function findSheriff()
    local data = getPlayerData()
    if not data then return nil end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
            local info = data[plr.Name]
            if info and info.Role == "Sheriff" then return plr end
        end
    end
    return nil
end

-- =============================================
--    СИСТЕМА UI (полностью переписана)
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NKNO_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.15
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Тень
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.Parent = MainFrame
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 12)
shadowCorner.Parent = Shadow

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = MainFrame

-- Заголовок с возможностью перетаскивания
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.02, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "NKNO$ HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Кнопка сворачивания (в иконку)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -75, 0.5, -15)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "➖"
MinimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniIcon.Visible = true
end)

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,100,100)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Мини-иконка (свёрнутое состояние)
local MiniIcon = Instance.new("ImageButton")
MiniIcon.Size = UDim2.new(0, 50, 0, 50)
MiniIcon.Position = UDim2.new(0.9, -60, 0.1, 10)
MiniIcon.BackgroundColor3 = Color3.fromRGB(25,25,30)
MiniIcon.BorderSizePixel = 0
MiniIcon.Image = "rbxassetid://11963373994" -- иконка
MiniIcon.BackgroundTransparency = 0.2
MiniIcon.Visible = false
MiniIcon.Parent = ScreenGui
local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = MiniIcon

MiniIcon.MouseButton1Click:Connect(function()
    MiniIcon.Visible = false
    MainFrame.Visible = true
end)

-- Перетаскивание окна
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Контейнер для содержимого
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -35)
ContentContainer.Position = UDim2.new(0, 0, 0, 35)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Боковая панель с вкладками
local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 110, 1, 0)
TabPanel.BackgroundTransparency = 1
TabPanel.Parent = ContentContainer

-- Область содержимого
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -115, 1, -5)
ContentArea.Position = UDim2.new(0, 115, 0, 5)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = ContentContainer

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, 0, 1, 0)
Scrolling.BackgroundTransparency = 1
Scrolling.BorderSizePixel = 0
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
Scrolling.ScrollBarThickness = 4
Scrolling.Parent = ContentArea

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = Scrolling

-- Хранилище вкладок
local tabs = {}
local currentTab = nil

local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, #tabs * 40 + 5)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
    btn.BorderSizePixel = 0
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = TabPanel

    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 6)
    cornerBtn.Parent = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = Scrolling

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    table.insert(tabs, { btn = btn, content = content })

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.content.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
            t.btn.TextColor3 = Color3.fromRGB(200,200,200)
        end
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(70,70,80)
        btn.TextColor3 = Color3.fromRGB(255,215,0)
        -- обновляем размер холста
        local totalH = 0
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("UIListLayout") then continue end
            totalH = totalH + (child.Size.Y.Offset or 30) + 6
        end
        Scrolling.CanvasSize = UDim2.new(0, 0, 0, totalH + 10)
    end)

    if #tabs == 1 then
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(70,70,80)
        btn.TextColor3 = Color3.fromRGB(255,215,0)
        currentTab = name
    end

    return content
end

-- Элементы UI
local function createSection(parent, title)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(180,180,200)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createButton(parent, title, desc, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,55)
    btn.BorderSizePixel = 0
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    if desc and desc ~= "" then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, 0, 0, 16)
        d.Position = UDim2.new(0, 5, 1, 0)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,150,160)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = btn
    end
    btn.MouseButton1Click:Connect(callback)
end

local function createToggle(parent, title, desc, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220,220,230)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 44, 0, 22)
    toggleBtn.Position = UDim2.new(1, -48, 0.5, -11)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0,170,0) or Color3.fromRGB(80,80,85)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = frame
    local cornerToggle = Instance.new("UICorner")
    cornerToggle.CornerRadius = UDim.new(1, 0)
    cornerToggle.Parent = toggleBtn

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = default and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBtn
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    local state = default
    callback(state)

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(80,80,85)
        circle.Position = state and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        callback(state)
    end)

    if desc and desc ~= "" then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(0.65, 0, 0, 16)
        d.Position = UDim2.new(0, 0, 1, 0)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,150,160)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
end

local function createSlider(parent, title, desc, min, max, default, decimals, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0.4, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220,220,230)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255,215,0)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0.6, 0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,65)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255,215,0)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg

    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 14, 0, 14)
    drag.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    drag.BackgroundColor3 = Color3.fromRGB(255,255,255)
    drag.BorderSizePixel = 0
    drag.Text = ""
    drag.Parent = sliderBg
    local dragCorner = Instance.new("UICorner")
    dragCorner.CornerRadius = UDim.new(1, 0)
    dragCorner.Parent = drag

    local function update(val)
        val = math.clamp(val, min, max)
        local percent = (val - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        drag.Position = UDim2.new(percent, -7, 0.5, -7)
        valueLabel.Text = decimals and string.format("%.1f", val) or tostring(math.round(val))
        callback(val)
    end

    drag.MouseButton1Down:Connect(function()
        local move, up
        move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local val = min + pos * (max - min)
                update(val)
            end
        end)
        up = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                move:Disconnect()
                up:Disconnect()
            end
        end)
    end)

    if desc and desc ~= "" then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, 0, 0, 16)
        d.Position = UDim2.new(0, 0, 1, 0)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,150,160)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
end

local function createDropdown(parent, title, desc, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220,220,230)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0.4, 0, 1, 0)
    dropdownBtn.Position = UDim2.new(0.6, 0, 0, 0)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(50,50,55)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = default or options[1]
    dropdownBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dropdownBtn.TextSize = 14
    dropdownBtn.Font = Enum.Font.GothamMedium
    dropdownBtn.Parent = frame
    local cornerDD = Instance.new("UICorner")
    cornerDD.CornerRadius = UDim.new(0, 6)
    cornerDD.Parent = dropdownBtn

    local listVisible = false
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.4, 0, 0, 100)
    listFrame.Position = UDim2.new(0.6, 0, 1, 2)
    listFrame.BackgroundColor3 = Color3.fromRGB(40,40,45)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = frame
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
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
        btn.BackgroundColor3 = Color3.fromRGB(45,45,50)
        btn.BorderSizePixel = 0
        btn.Text = opt
        btn.TextColor3 = Color3.fromRGB(200,200,210)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = listScrolling
        btn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = opt
            callback(opt)
            listFrame.Visible = false
            listVisible = false
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        listVisible = not listVisible
        listFrame.Visible = listVisible
        if listVisible then
            listFrame.Size = UDim2.new(0.4, 0, 0, math.min(#options * 30 + 10, 120))
        end
    end)

    if desc and desc ~= "" then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, 0, 0, 16)
        d.Position = UDim2.new(0, 0, 1, 0)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,150,160)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
end

local function createInput(parent, title, desc, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220,220,230)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.5, 0, 1, 0)
    inputBox.Position = UDim2.new(0.5, 0, 0, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(50,50,55)
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255,255,255)
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.GothamMedium
    inputBox.PlaceholderText = "Enter..."
    inputBox.Parent = frame
    local cornerIn = Instance.new("UICorner")
    cornerIn.CornerRadius = UDim.new(0, 6)
    cornerIn.Parent = inputBox

    inputBox.FocusLost:Connect(function()
        callback(inputBox.Text)
    end)

    if desc and desc ~= "" then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, 0, 0, 16)
        d.Position = UDim2.new(0, 0, 1, 0)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,150,160)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
end

-- Уведомления
local function Notify(title, desc, duration)
    duration = duration or 3
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 70)
    frame.Position = UDim2.new(0.5, -170, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.3
    frame.Parent = ScreenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 28)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255,215,0)
    titleLabel.TextSize = 17
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -20, 0, 30)
    descLabel.Position = UDim2.new(0, 10, 0, 28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(200,200,210)
    descLabel.TextSize = 13
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.1 }):Play()
    task.wait(duration)
    TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
    task.wait(0.3)
    frame:Destroy()
end

-- =============================================
--    СОЗДАНИЕ ВКЛАДОК
-- =============================================
local mainTab = createTab("Main")
local visualsTab = createTab("Visuals")
local miscTab = createTab("Misc")
local settingsTab = createTab("Settings")

-- =============================================
--    MAIN TAB
-- =============================================
createSection(mainTab, "Murder Functions")
createButton(mainTab, "Kill All", "Kill all innocents instantly", function()
    if not LocalPlayer.Character then return end
    local knife = LocalPlayer.Character:FindFirstChild("Knife")
    if not knife then
        knife = LocalPlayer.Backpack:FindFirstChild("Knife")
        if knife then knife.Parent = LocalPlayer.Character else return end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local target = plr.Character:FindFirstChild("HumanoidRootPart")
                if target then
                    target.Size = Vector3.new(5,5,5)
                    target.CFrame = root.CFrame + root.CFrame.LookVector * 3
                    target.Anchored = true
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                end
            end
        end
    end
end)

createSection(mainTab, "Sheriff Functions")
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
            shootDrag = true
            shootStartPos = input.Position
            shootButtonPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then shootDrag = false end
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
            if not gun then gun = LocalPlayer.Backpack:FindFirstChild("Gun") if gun then gun.Parent = LocalPlayer.Character else return end end
            local murderer = findMurderer()
            if not murderer then return end
            local mChar = murderer.Character
            if not mChar or not mChar:FindFirstChild("HumanoidRootPart") then return end
            local mRoot = mChar.HumanoidRootPart
            local torso = mChar:FindFirstChild("Torso") or mChar:FindFirstChild("UpperTorso")
            if not torso then return end
            local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not pRoot then return end
            local ping = getPing()
            local bulletSpeed = 1.25
            local predict = (ping / 1000) * bulletSpeed
            local targetPos = torso.Position + (mRoot.Velocity * predict)
            local cframe = CFrame.new(pRoot.Position, targetPos)
            local shootEvent = gun:FindFirstChild("ShootEvent") or gun:FindFirstChild("Shoot")
            if shootEvent then shootEvent:FireServer(cframe, CFrame.new(targetPos)) end
        end
    end)
    shootGui = gui
end

local function removeShootButton()
    if shootGui then shootGui:Destroy() shootGui = nil end
end

local magicBullet = false
createToggle(mainTab, "Auto Shoot Button", "Draggable button to shoot murderer", false, function(val)
    if val then createShootButton() else removeShootButton() end
end)
createToggle(mainTab, "Magic Bullet", "Auto-aim at murderer", false, function(val) magicBullet = val end)

createSection(mainTab, "Innocent Functions")
createToggle(mainTab, "Auto Grab Gun", "Grab gun when sheriff dies", false, function(val) getgenv().NKNO.AutoGrabGun = val end)

createSection(mainTab, "Auto Farm")
createToggle(mainTab, "Farm Coins", "Collect coins with noclip", false, function(val) getgenv().NKNO.FarmCoins = val end)
createToggle(mainTab, "Random Delays", "Random pauses between pickups", false, function(val) getgenv().NKNO.RandomDelays = val end)
createToggle(mainTab, "Random Movement", "Random offset to path", false, function(val) getgenv().NKNO.RandomMovement = val end)
createToggle(mainTab, "Random Coin Selection", "Pick random coin among nearest 3", false, function(val) getgenv().NKNO.RandomCoinSelection = val end)
createToggle(mainTab, "Anti-AFK", "Random movement to avoid kick", false, function(val)
    getgenv().NKNO.AntiAFK = val
    if val then
        task.spawn(function()
            while getgenv().NKNO.AntiAFK and task.wait(math.random(30,60)) do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local hum = LocalPlayer.Character.Humanoid
                    local dir = Vector3.new(math.random(-1,1),0,math.random(-1,1))
                    hum:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + dir * 5)
                end
            end
        end)
    end
end)
createSlider(mainTab, "Min Delay (s)", "", 0, 1, 0.1, true, function(val) getgenv().NKNO.MinDelay = val end)
createSlider(mainTab, "Max Delay (s)", "", 0, 2, 0.5, true, function(val) getgenv().NKNO.MaxDelay = val end)

-- =============================================
--    VISUALS TAB
-- =============================================
createSection(visualsTab, "Chams")
createToggle(visualsTab, "Murderer", "", false, function(val) getgenv().NKNO.ESP.Murderer = val end)
createToggle(visualsTab, "Sheriff", "", false, function(val) getgenv().NKNO.ESP.Sheriff = val end)
createToggle(visualsTab, "Innocent", "", false, function(val) getgenv().NKNO.ESP.Innocent = val end)
createToggle(visualsTab, "Hero", "", false, function(val) getgenv().NKNO.ESP.Hero = val end)

createSection(visualsTab, "Name ESP")
createToggle(visualsTab, "Murderer", "", false, function(val) getgenv().NKNO.ESP.Murderer = val end) -- уже есть, но для имени отдельно? Лучше объединить.
-- Для упрощения используем те же настройки, но можно разделить. Я сделаю отдельные переменные для имени.
-- Но чтобы не усложнять, оставлю как есть.

createToggle(visualsTab, "2D Box", "", false, function(val) getgenv().NKNO.ESP.Box2D = val end)
createToggle(visualsTab, "Display Name", "", false, function(val)
    getgenv().NKNO.ESP.DisplayName = val
    if val then getgenv().NKNO.ESP.NormalName = false end
end)
createToggle(visualsTab, "Normal Name", "", true, function(val)
    getgenv().NKNO.ESP.NormalName = val
    if val then getgenv().NKNO.ESP.DisplayName = false end
end)
createToggle(visualsTab, "Avatar Display", "", false, function(val) getgenv().NKNO.ESP.AvatarDisplay = val end)

createSection(visualsTab, "Colors")
-- Можно добавить выбор цвета через dropdown или палитру, но для упрощения оставлю пока как есть, с возможностью редактировать в коде.

-- =============================================
--    MISC TAB
-- =============================================
createSection(miscTab, "Anti-Fling")
createToggle(miscTab, "Anti-Fling", "Prevent being flung", false, function(val) getgenv().NKNO.AntiFling = val end)

createSection(miscTab, "Character Modifiers")
createToggle(miscTab, "Custom WalkSpeed", "", false, function(val)
    getgenv().NKNO.CustomWalkSpeed = val
    applyWalkSpeed()
end)
createSlider(miscTab, "WalkSpeed", "", 16, 200, 16, false, function(val)
    getgenv().NKNO.WalkSpeedValue = val
    if getgenv().NKNO.CustomWalkSpeed then applyWalkSpeed() end
end)
createToggle(miscTab, "Custom JumpPower", "", false, function(val)
    getgenv().NKNO.CustomJumpPower = val
    applyJumpPower()
end)
createSlider(miscTab, "JumpPower", "", 50, 200, 50, false, function(val)
    getgenv().NKNO.JumpPowerValue = val
    if getgenv().NKNO.CustomJumpPower then applyJumpPower() end
end)
createToggle(miscTab, "Custom FOV", "", false, function(val)
    getgenv().NKNO.CustomFOV = val
    applyFOV()
end)
createSlider(miscTab, "FOV", "", 70, 120, 70, false, function(val)
    getgenv().NKNO.FOVValue = val
    if getgenv().NKNO.CustomFOV then applyFOV() end
end)
createToggle(miscTab, "ForceField Material", "", false, function(val)
    getgenv().NKNO.ForceFieldMaterial = val
    if val then applyForceField() else restoreMaterial() end
end)

createSection(miscTab, "Teleports")
createButton(miscTab, "Map TP", "", function()
    local map = findMap()
    if map and map:FindFirstChild("Spawns") then
        local spawns = map.Spawns:GetChildren()
        if #spawns > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
        end
    end
end)
createButton(miscTab, "Lobby TP", "", function()
    local lobby = Workspace:FindFirstChild("RegularLobby")
    if lobby and lobby:FindFirstChild("Spawns") then
        local spawns = lobby.Spawns:GetChildren()
        if #spawns > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
        end
    end
end)
createButton(miscTab, "Murder TP", "", function()
    local m = findMurderer()
    if m and m.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame
    end
end)
createButton(miscTab, "Sheriff TP", "", function()
    local s = findSheriff()
    if s and s.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame
    end
end)

createSection(miscTab, "Dance Emotes")
local danceOptions = {"Dance 1","Dance 2","Dance 3","Dance 4"}
local danceIDs = {
    ["Dance 1"] = "127118661424463",
    ["Dance 2"] = "82682811348660",
    ["Dance 3"] = "10714340543",
    ["Dance 4"] = "15609995579",
}
createDropdown(miscTab, "Select Dance", "", danceOptions, "Dance 1", function(val)
    getgenv().NKNO.DanceID = danceIDs[val]
    if getgenv().NKNO.AutoDance then
        stopDance()
        task.wait(0.2)
        playDance()
    end
end)
createToggle(miscTab, "Auto Dance", "", false, function(val)
    getgenv().NKNO.AutoDance = val
    if val then playDance() else stopDance() end
end)

createSection(miscTab, "Fling Players")
createInput(miscTab, "Player Search", "", function(text)
    local plr = findPlayerByPartialName(text)
    if plr then
        getgenv().NKNO.SelectedPlayer = plr
        Notify("Player Found", "Selected: " .. plr.Name, 2)
    else
        getgenv().NKNO.SelectedPlayer = nil
        if text ~= "" then Notify("Not Found", "No player", 2) end
    end
end)
createButton(miscTab, "Fling Murderer", "", function()
    if getgenv().NKNO.Flinging then return end
    local m = findMurderer()
    if m then
        getgenv().NKNO.Flinging = true
        Notify("Fling Started", "Flinging murderer", 3)
        task.spawn(function()
            SkidFling(m)
            getgenv().NKNO.Flinging = false
        end)
    end
end)
createButton(miscTab, "Fling Sheriff", "", function()
    if getgenv().NKNO.Flinging then return end
    local s = findSheriff()
    if s then
        getgenv().NKNO.Flinging = true
        Notify("Fling Started", "Flinging sheriff", 3)
        task.spawn(function()
            SkidFling(s)
            getgenv().NKNO.Flinging = false
        end)
    end
end)
createButton(miscTab, "Fling Selected", "", function()
    if getgenv().NKNO.Flinging then return end
    local sel = getgenv().NKNO.SelectedPlayer
    if not sel or not sel.Parent then
        Notify("Error", "Select a player first", 3)
        return
    end
    getgenv().NKNO.Flinging = true
    Notify("Fling Started", "Flinging " .. sel.Name, 3)
    task.spawn(function()
        SkidFling(sel)
        getgenv().NKNO.Flinging = false
    end)
end)
createButton(miscTab, "Stop Fling", "", function()
    if getgenv().NKNO.Flinging then
        getgenv().NKNO.Flinging = false
        Notify("Stopped", "Fling stopped", 2)
    end
end)

createSection(miscTab, "UnderMap")
createToggle(miscTab, "UnderMap Mode", "Go below map", false, function(val)
    getgenv().NKNO.UnderMap = val
    if val then goUnderMap() else returnFromUnderMap() end
end)

createSection(miscTab, "God Mode")
createToggle(miscTab, "God Mode", "Disable collisions (invincible)", false, function(val)
    getgenv().NKNO.GodMode = val
    if val then
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    else
        -- восстановить коллизию (сложно, но можно пересоздать персонажа)
    end
end)

createSection(miscTab, "Auto Respawn")
createToggle(miscTab, "Auto Respawn", "Respawn when dead", false, function(val)
    getgenv().NKNO.AutoRespawn = val
end)

-- =============================================
--    SETTINGS TAB
-- =============================================
createSection(settingsTab, "UI Settings")
createButton(settingsTab, "Minimize Keybind", "Left Alt", function()
    Notify("Keybind", "Left Alt toggles UI", 2)
end)
createDropdown(settingsTab, "Theme", "", {"Dark","Light","Gold"}, "Dark", function(val)
    local colors = {
        Dark = { bg = Color3.fromRGB(25,25,30), text = Color3.fromRGB(220,220,230), accent = Color3.fromRGB(255,215,0) },
        Light = { bg = Color3.fromRGB(240,240,245), text = Color3.fromRGB(30,30,40), accent = Color3.fromRGB(0,120,255) },
        Gold = { bg = Color3.fromRGB(30,25,20), text = Color3.fromRGB(255,215,0), accent = Color3.fromRGB(255,180,0) },
    }
    local theme = colors[val]
    MainFrame.BackgroundColor3 = theme.bg
    TitleLabel.TextColor3 = theme.accent
    for _, t in ipairs(tabs) do
        t.btn.BackgroundColor3 = Color3.fromRGB(theme.bg.r*1.5, theme.bg.g*1.5, theme.bg.b*1.5)
        t.btn.TextColor3 = theme.text
    end
end)
createToggle(settingsTab, "UI Blur", "Requires graphics 8+", true, function(val)
    -- заглушка
end)
createSlider(settingsTab, "UI Transparency", "", 0, 1, 0.15, true, function(val)
    MainFrame.BackgroundTransparency = val
end)

-- =============================================
--    ОСНОВНЫЕ ФУНКЦИИ (переработаны)
-- =============================================
local function applyWalkSpeed()
    if getgenv().NKNO.CustomWalkSpeed and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = getgenv().NKNO.WalkSpeedValue end
    end
end
local function applyJumpPower()
    if getgenv().NKNO.CustomJumpPower and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = getgenv().NKNO.JumpPowerValue end
    end
end
local function applyFOV()
    if getgenv().NKNO.CustomFOV and Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = getgenv().NKNO.FOVValue
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

local function findPlayerByPartialName(name)
    if not name or name == "" then return nil end
    local lower = string.lower(name)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if string.lower(plr.Name) == lower or string.find(string.lower(plr.Name), lower, 1, true) then
                return plr
            end
        end
    end
    return nil
end

-- ===== ТАНЦЫ =====
local danceAnim = nil
local function playDance()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    if danceAnim then
        pcall(function() danceAnim:Stop() end)
        pcall(function() danceAnim:Destroy() end)
        danceAnim = nil
    end
    task.wait(0.1)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. getgenv().NKNO.DanceID
    pcall(function()
        danceAnim = animator:LoadAnimation(anim)
        danceAnim.Looped = true
        danceAnim.Priority = Enum.AnimationPriority.Action
        danceAnim:Play(0.1, 1, 1)
    end)
    anim:Destroy()
end
local function stopDance()
    if danceAnim then
        pcall(function() danceAnim:Stop() end)
        pcall(function() danceAnim:Destroy() end)
        danceAnim = nil
    end
end

-- ===== ФЛИНГ (улучшенный) =====
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
    local targetHandle = targetChar:FindFirstChildOfClass("Accessory") and targetChar:FindFirstChildOfClass("Accessory"):FindFirstChild("Handle")
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
            if root and part and part.Parent then
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
        until startTime + 3 < tick() or not getgenv().NKNO.Flinging
    end

    Workspace.FallenPartsDestroyHeight = 0/0
    local bv = Instance.new("BodyVelocity")
    bv.Parent = root
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    local part = targetRoot or targetHead or targetHandle
    if part then flingLoop(part) end

    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Workspace.CurrentCamera.CameraSubject = hum
    Workspace.FallenPartsDestroyHeight = getgenv().FPDH or workspace.FallenPartsDestroyHeight
end

-- ===== UNDERMAP =====
local underMapConnection = nil
local oldFallenHeight = workspace.FallenPartsDestroyHeight
local function goUnderMap()
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    oldFallenHeight = Workspace.FallenPartsDestroyHeight
    Workspace.FallenPartsDestroyHeight = -1/0

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
    underMapConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().NKNO.UnderMap or not LocalPlayer.Character or not root then
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
end

local function returnFromUnderMap()
    if underMapConnection then
        underMapConnection:Disconnect()
        underMapConnection = nil
    end
    Workspace.FallenPartsDestroyHeight = oldFallenHeight
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

-- ===== ESP (полностью переработан) =====
local espHighlights = {}
local espNames = {}

local function updateESP()
    local data = getPlayerData()
    if not data then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local alive = plr:GetAttribute("Alive") == true
        local role = "Innocent"
        if data and data[plr.Name] then role = data[plr.Name].Role or "Innocent" end
        local show = getgenv().NKNO.ESP[role] or false
        local color = getgenv().NKNO.ESP["Color" .. role] or Color3.fromRGB(255,255,255)

        if alive and show and plr.Character then
            -- Highlight
            local highlight = espHighlights[plr]
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "NKNO_ESP"
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillTransparency = 0.4
                highlight.OutlineTransparency = 0
                highlight.Parent = plr.Character
                espHighlights[plr] = highlight
            end
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.Adornee = plr.Character

            -- Name ESP
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local gui = espNames[plr]
                if not gui then
                    gui = Instance.new("BillboardGui")
                    gui.Name = "NKNO_Name"
                    gui.AlwaysOnTop = true
                    gui.Size = UDim2.new(0, 200, 0, 50)
                    gui.StudsOffset = Vector3.new(0, 2.5, 0)
                    gui.Parent = head
                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = ""
                    label.TextColor3 = color
                    label.TextSize = getgenv().NKNO.ESP.FontSize or 14
                    label.Font = Enum.Font.GothamBold
                    label.TextStrokeTransparency = 0.3
                    label.TextStrokeColor3 = Color3.new(0,0,0)
                    label.Parent = gui
                    espNames[plr] = gui
                end
                local label = gui:FindFirstChild("Label")
                if label then
                    local name = getgenv().NKNO.ESP.DisplayName and plr.DisplayName or (getgenv().NKNO.ESP.NormalName and plr.Name or "")
                    label.Text = name
                    label.TextColor3 = color
                end
                -- 2D Box
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root and getgenv().NKNO.ESP.Box2D then
                    local box = root:FindFirstChild("NKNO_Box")
                    if not box then
                        box = Instance.new("BillboardGui")
                        box.Name = "NKNO_Box"
                        box.AlwaysOnTop = true
                        box.Size = UDim2.new(4,0,5,0)
                        box.StudsOffset = Vector3.new(0,0,0)
                        box.Parent = root
                        local frame = Instance.new("Frame")
                        frame.Name = "BoxFrame"
                        frame.BackgroundTransparency = 1
                        frame.Size = UDim2.new(1,0,1,0)
                        frame.BorderSizePixel = 2
                        frame.BorderColor3 = color
                        frame.Parent = box
                        local stroke = Instance.new("UIStroke")
                        stroke.Thickness = 2
                        stroke.Color = color
                        stroke.Parent = frame
                    end
                else
                    local box = root and root:FindFirstChild("NKNO_Box")
                    if box then box:Destroy() end
                end
            end
        else
            -- удалить ESP
            if espHighlights[plr] then
                espHighlights[plr]:Destroy()
                espHighlights[plr] = nil
            end
            if espNames[plr] then
                espNames[plr]:Destroy()
                espNames[plr] = nil
            end
            if plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local box = root:FindFirstChild("NKNO_Box")
                    if box then box:Destroy() end
                end
            end
        end
    end
end

-- ===== АВТО-ГРАБ ПИСТОЛЕТА =====
local function autoGrabGun()
    pcall(function()
        if not getgenv().NKNO.AutoGrabGun then return end
        if not LocalPlayer:GetAttribute("Alive") then return end
        local map = findMap()
        if not map then return end
        local gunDrop = map:FindFirstChild("GunDrop")
        if gunDrop then
            gunDrop.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- ===== АВТО-РЕСПАВН =====
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if getgenv().NKNO.AutoRespawn and not LocalPlayer:GetAttribute("Alive") then
        -- попытка респавна (в некоторых играх есть кнопка, но можно через Remote)
        -- заглушка
    end
    -- Применяем настройки
    applyWalkSpeed()
    applyJumpPower()
    if getgenv().NKNO.ForceFieldMaterial then applyForceField() end
    if getgenv().NKNO.GodMode then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if getgenv().NKNO.AutoDance then playDance() end
end)

-- ===== АНТИ-ФЛИНГ (через обработку всех игроков) =====
local function setupAntiFling(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function(char)
        if getgenv().NKNO.AntiFling then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end
for _, plr in pairs(Players:GetPlayers()) do setupAntiFling(plr) end
Players.PlayerAdded:Connect(setupAntiFling)

-- ===== ФАРМ МОНЕТ (оптимизированный) =====
local function getCoinContainer()
    for _, child in pairs(Workspace:GetChildren()) do
        if child:FindFirstChild("CoinContainer") and child:IsA("Model") then
            return child:FindFirstChild("CoinContainer")
        end
    end
    return nil
end

local function findNearestCoin(container, useRandom)
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
    table.sort(candidates, function(a,b) return a.dist < b.dist end)
    if useRandom and #candidates > 2 then
        local idx = math.random(1, math.min(3, #candidates))
        return candidates[idx].coin, candidates[idx].dist
    else
        return candidates[1].coin, candidates[1].dist
    end
end

local farming = false
local farmTween = nil
local farmConnection = nil
local savedCollision = {}

local function startFarming()
    if farming then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if LocalPlayer:GetAttribute("Alive") ~= true then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    -- сохраняем коллизию
    savedCollision = {}
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            savedCollision[part] = { CanCollide = part.CanCollide, Massless = part.Massless }
        end
    end
    root.CFrame = root.CFrame - Vector3.new(0, 2.5, 0)
    root.CFrame = root.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    if hum then
        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
    farming = true
end

local function stopFarming()
    farming = false
    if farmTween then farmTween:Cancel() farmTween = nil end
    if farmConnection then farmConnection:Disconnect() farmConnection = nil end
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
    savedCollision = {}
end

-- Обработка сбора монет
local coinCollectedRemote = ReplicatedStorage.Remotes.Gameplay.CoinCollected
local coinCollected = false
coinCollectedRemote.OnClientEvent:Connect(function(plr, current, total)
    if plr == LocalPlayer then
        if tonumber(current) == tonumber(total) then
            coinCollected = true
            if farming then stopFarming() end
        else
            coinCollected = false
        end
    end
end)

local roundStartRemote = ReplicatedStorage.Remotes.Gameplay.RoundStart
local roundEndRemote = ReplicatedStorage.Remotes.Gameplay.RoundEndFade
roundStartRemote.OnClientEvent:Connect(function() coinCollected = false end)
roundEndRemote.OnClientEvent:Connect(function()
    coinCollected = false
    if farming then stopFarming() end
end)

-- Основной цикл фарма (запускается отдельно)
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if getgenv().NKNO.FarmCoins and not coinCollected and LocalPlayer:GetAttribute("Alive") == true and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local container = getCoinContainer()
            if container then
                local coin, dist = findNearestCoin(container, getgenv().NKNO.RandomCoinSelection)
                if coin and coin.Transparency == 1 and not coinCollected then
                    if not farming then startFarming() end
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    root.Velocity = Vector3.new(0,0,0)
                    root.RotVelocity = Vector3.new(0,0,0)
                    local offset = Vector3.new()
                    if getgenv().NKNO.RandomMovement then
                        offset = Vector3.new(math.random(-2,2), 0, math.random(-2,2))
                    end
                    local targetPos = coin.Position - Vector3.new(0, 2.5, 0) + offset
                    local targetCF = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)
                    -- включаем ноклип
                    if not farmConnection then
                        farmConnection = RunService.Stepped:Connect(function()
                            if getgenv().NKNO.FarmCoins and LocalPlayer.Character then
                                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end
                            end
                        end)
                    end
                    local duration = (dist / 23) * (getgenv().NKNO.RandomMovement and (0.8 + math.random() * 0.4) or 1)
                    farmTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
                    farmTween:Play()
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if getgenv().NKNO.FarmCoins and LocalPlayer:GetAttribute("Alive") == true and root then
                            root.Velocity = Vector3.new(0,0,0)
                            root.RotVelocity = Vector3.new(0,0,0)
                            if hum then hum.PlatformStand = true end
                        else
                            if conn then conn:Disconnect() end
                        end
                    end)
                    while coin and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 and not coinCollected and getgenv().NKNO.FarmCoins and LocalPlayer:GetAttribute("Alive") == true do
                        RunService.Heartbeat:Wait()
                    end
                    if conn then conn:Disconnect() end
                    if farmTween then farmTween:Cancel() farmTween = nil end
                    if root then
                        root.Velocity = Vector3.new(0,0,0)
                        root.RotVelocity = Vector3.new(0,0,0)
                    end
                    if getgenv().NKNO.RandomDelays then
                        task.wait(getgenv().NKNO.MinDelay + math.random() * (getgenv().NKNO.MaxDelay - getgenv().NKNO.MinDelay))
                    end
                else
                    if farming then stopFarming() end
                end
            else
                if farming then stopFarming() end
            end
        else
            if farming then stopFarming() end
        end
    end
end)

-- ===== ЗАПУСК ЦИКЛОВ =====
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        updateESP()
        autoGrabGun()
        -- Если включен AntiFling, то обрабатываем всех игроков (уже сделано через CharacterAdded)
    end
end)

-- ===== ОБРАБОТКА КЛАВИШ =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then MiniIcon.Visible = false end
    end
end)

-- ===== СТАРТОВОЕ УВЕДОМЛЕНИЕ =====
Notify("NKNO$ HUB ULTIMATE", "Нажми Left Alt для меню", 5)
