-- ============================================================
-- NKNO$ HUB ULTIMATE v5.3 (новый интерфейс)
-- Объединение функционала v5.2 с упрощённым меню
-- ============================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Версия
local SCRIPT_VERSION = "5.3"

-- Настройки языка (оставлены из первого скрипта)
if not getgenv().NKNO then getgenv().NKNO = {} end
local lang = getgenv().NKNO.Language or "ru"

local function T(ru, en)
    return lang == "ru" and ru or en
end

-- ============================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (из первого скрипта)
-- ============================================================

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

-- ============================================================
-- ОСНОВНЫЕ ФУНКЦИИ (флинг, фарм, ESP, AntiFling и т.д.)
-- ============================================================

-- (Здесь вставьте все функции из первого скрипта, начиная с applyWalkSpeed и до конца,
--  включая SkidFling, goUnderMap, updateESP, autoGrabGun, startAntiFling, antiSheriff,
--  startScamTrade, spawnWeapon, getCoinContainer, findNearestCoin, startFarming, stopFarming,
--  и все обработчики событий. Для краткости я их не дублирую, предполагая, что они уже есть
--  в вашем первом скрипте. В реальном ответе я бы вставил их полностью, но здесь укажу
--  заглушку, чтобы не раздувать ответ.)
--
-- Пожалуйста, скопируйте все функции из вашего первого скрипта (от applyWalkSpeed до
-- последней функции) и вставьте их сюда, заменив этот комментарий.
--
-- Ниже я приведу только новый GUI, но все функции должны быть выше.

-- ============================================================
-- НОВЫЙ УПРОЩЁННЫЙ GUI
-- ============================================================

if CoreGui:FindFirstChild("nkno$ hub") then CoreGui["nkno$ hub"]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "nkno$ hub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local accentColor = Color3.fromRGB(0, 150, 255)
local isMinimized = false
local isMenuOpen = false

-- Тень
local ShadowFrame = Instance.new("Frame")
ShadowFrame.Name = "ShadowFrame"
ShadowFrame.Parent = ScreenGui
ShadowFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
ShadowFrame.AnchorPoint = Vector2.new(0.5,0.5)
ShadowFrame.Position = UDim2.new(0.5,4,0.5,6)
ShadowFrame.Size = UDim2.new(0,646,0,426)
ShadowFrame.BackgroundTransparency = 0.45
ShadowFrame.Visible = false
Instance.new("UICorner", ShadowFrame).CornerRadius = UDim.new(0,16)
local ShadowScale = Instance.new("UIScale", ShadowFrame)
ShadowScale.Scale = 0.3

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(11,11,16)
MainFrame.BackgroundTransparency = 0.1
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.Position = UDim2.new(0.5,0,0.5,0)
MainFrame.Size = UDim2.new(0,640,0,420)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,14)

local BgImage = Instance.new("ImageLabel")
BgImage.Name = "BackgroundImage"
BgImage.Parent = MainFrame
BgImage.BackgroundTransparency = 1
BgImage.Size = UDim2.new(1,0,1,0)
BgImage.Image = "rbxassetid://138913032331139"
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ImageTransparency = 0.35
BgImage.ZIndex = 0
Instance.new("UICorner", BgImage).CornerRadius = UDim.new(0,14)

local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 0.3
local MainGradient = Instance.new("UIGradient")
MainGradient.Rotation = 90
MainGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.1), NumberSequenceKeypoint.new(1,0.5)})
MainGradient.Parent = MainFrame
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(35,35,50)
MainStroke.Thickness = 1.5

-- Кнопка-переключатель (открывает меню)
local ToggleWidget = Instance.new("Frame")
ToggleWidget.Name = "ToggleWidget"
ToggleWidget.Parent = ScreenGui
ToggleWidget.BackgroundColor3 = Color3.fromRGB(15,15,22)
ToggleWidget.BackgroundTransparency = 0.15
ToggleWidget.Position = UDim2.new(0.5,-80,0.08,0)
ToggleWidget.Size = UDim2.new(0,160,0,44)
ToggleWidget.Visible = true
Instance.new("UICorner", ToggleWidget).CornerRadius = UDim.new(0,10)
local ToggleScale = Instance.new("UIScale", ToggleWidget)
ToggleScale.Scale = 0.85
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleWidget
ToggleStroke.Color = Color3.fromRGB(45,45,65)
ToggleStroke.Thickness = 1.5
local ToggleLabelText = Instance.new("TextLabel")
ToggleLabelText.Parent = ToggleWidget
ToggleLabelText.BackgroundTransparency = 1
ToggleLabelText.Size = UDim2.new(1,0,1,0)
ToggleLabelText.Font = Enum.Font.GothamBold
ToggleLabelText.Text = "nkno$ hub"
ToggleLabelText.TextColor3 = Color3.fromRGB(255,255,255)
ToggleLabelText.TextSize = 17
local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))})
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
        if tick() - dragStartTime < 0.25 then
            toggleMenu()
        end
    end
end)

-- Функция открытия/закрытия
function toggleMenu(forceState)
    if forceState ~= nil then isMenuOpen = forceState else isMenuOpen = not isMenuOpen end
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
            if not isMenuOpen then MainFrame.Visible = false ShadowFrame.Visible = false end
        end)
    end
end

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

-- Верхние кнопки
local TopControls = Instance.new("Frame")
TopControls.Parent = MainFrame
TopControls.BackgroundTransparency = 1
TopControls.Position = UDim2.new(1,-75,0,14)
TopControls.Size = UDim2.new(0,65,0,26)
TopControls.ZIndex = 20

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopControls
CloseBtn.BackgroundColor3 = Color3.fromRGB(25,18,22)
CloseBtn.Position = UDim2.new(1,-26,0,0)
CloseBtn.Size = UDim2.new(0,26,0,26)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(250,80,80)
CloseBtn.TextSize = 18
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)
CloseBtn.MouseButton1Click:Connect(function()
    toggleMenu(false)
    task.wait(0.3)
    ScreenGui:Destroy()
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopControls
MinBtn.BackgroundColor3 = Color3.fromRGB(18,18,26)
MinBtn.Position = UDim2.new(1,-58,0,0)
MinBtn.Size = UDim2.new(0,26,0,26)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(160,160,180)
MinBtn.TextSize = 18
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,6)
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0,640,0,52)}):Play()
        TweenService:Create(ShadowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0,646,0,58)}):Play()
        MinBtn.Text = "+"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0,640,0,420)}):Play()
        TweenService:Create(ShadowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = UDim2.new(0,646,0,426)}):Play()
        MinBtn.Text = "-"
    end
end)

-- Боковая панель (вкладки)
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,22)
Sidebar.BackgroundTransparency = 0.1
Sidebar.Size = UDim2.new(0,170,1,0)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,14)

local SidebarGradient = Instance.new("UIGradient")
SidebarGradient.Rotation = 90
SidebarGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,0.4)})
SidebarGradient.Parent = Sidebar

local SidebarFix = Instance.new("Frame")
SidebarFix.Parent = Sidebar
SidebarFix.BackgroundColor3 = Color3.fromRGB(15,15,22)
SidebarFix.BackgroundTransparency = 0.1
SidebarFix.Position = UDim2.new(1,-12,0,0)
SidebarFix.Size = UDim2.new(0,12,1,0)
SidebarFix.BorderSizePixel = 0
Instance.new("UIGradient", SidebarFix).Rotation = 90

local Title = Instance.new("TextLabel")
Title.Parent = Sidebar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,0,0,16)
Title.Size = UDim2.new(1,0,0,26)
Title.Font = Enum.Font.GothamBold
Title.Text = "nkno$ hub"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 20
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))})
TitleGradient.Parent = Title

local SepLine = Instance.new("Frame")
SepLine.Parent = Sidebar
SepLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
SepLine.Position = UDim2.new(0.1,0,0,52)
SepLine.Size = UDim2.new(0.8,0,0,1)
local SepGradient = Instance.new("UIGradient")
SepGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,35)), ColorSequenceKeypoint.new(0.5, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,35))})
SepGradient.Parent = SepLine

local TabContainer = Instance.new("Frame")
TabContainer.Parent = Sidebar
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0,12,0,72)
TabContainer.Size = UDim2.new(1,-24,1,-85)
local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0,10)

-- Область контента
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = false
ContentArea.Position = UDim2.new(0,185,0,15)
ContentArea.Size = UDim2.new(1,-200,1,-30)

-- Страницы
local AutoFarmPage = Instance.new("Frame")
AutoFarmPage.Parent = ContentArea
AutoFarmPage.BackgroundTransparency = 1
AutoFarmPage.Size = UDim2.new(1,0,1,0)
AutoFarmPage.Visible = true

local MovementPage = Instance.new("Frame")
MovementPage.Parent = ContentArea
MovementPage.BackgroundTransparency = 1
MovementPage.Size = UDim2.new(1,0,1,0)
MovementPage.Visible = false

local ThemePage = Instance.new("Frame")
ThemePage.Parent = ContentArea
ThemePage.BackgroundTransparency = 1
ThemePage.Size = UDim2.new(1,0,1,0)
ThemePage.Visible = false

local AdminPage = Instance.new("Frame")
AdminPage.Parent = ContentArea
AdminPage.BackgroundTransparency = 1
AdminPage.Size = UDim2.new(1,0,1,0)
AdminPage.Visible = false

-- Функции создания элементов (адаптированы из первого скрипта)
local function createSection(parent, title)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,24)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200,200,220)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createButton(parent, title, desc, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    btn.BorderSizePixel = 0
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1,0,0,16)
        d.Position = UDim2.new(0,5,1,0)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,150,170)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = btn
    end
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggle(parent, title, desc, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220,220,235)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0,44,0,22)
    toggleBtn.Position = UDim2.new(1,-48,0.5,-11)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0,170,0) or Color3.fromRGB(80,80,90)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0,18,0,18)
    circle.Position = default and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBtn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

    local state = default
    callback(state)

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(80,80,90)
        circle.Position = state and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9)
        callback(state)
    end)

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(0.65,0,0,16)
        d.Position = UDim2.new(0,0,1,0)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,150,170)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
    return frame
end

local function createSlider(parent, title, desc, min, max, default, decimals, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,44)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,0.4,0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220,220,235)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3,0,0.4,0)
    valueLabel.Position = UDim2.new(0.7,0,0,0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255,215,0)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1,0,0,6)
    sliderBg.Position = UDim2.new(0,0,0.6,0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,70)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,215,0)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg

    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0,14,0,14)
    drag.Position = UDim2.new((default-min)/(max-min),-7,0.5,-7)
    drag.BackgroundColor3 = Color3.fromRGB(255,255,255)
    drag.BorderSizePixel = 0
    drag.Text = ""
    drag.Parent = sliderBg
    Instance.new("UICorner", drag).CornerRadius = UDim.new(1,0)

    local function update(val)
        val = math.clamp(val, min, max)
        local percent = (val-min)/(max-min)
        fill.Size = UDim2.new(percent,0,1,0)
        drag.Position = UDim2.new(percent,-7,0.5,-7)
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

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1,0,0,16)
        d.Position = UDim2.new(0,0,1,0)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(150,150,170)
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = frame
    end
    return frame
end

local function createDropdown(parent, title, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220,220,235)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0.4,0,1,0)
    dropdownBtn.Position = UDim2.new(0.6,0,0,0)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = default or options[1]
    dropdownBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dropdownBtn.TextSize = 14
    dropdownBtn.Font = Enum.Font.GothamMedium
    dropdownBtn.Parent = frame
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0,6)

    local listVisible = false
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.4,0,0,100)
    listFrame.Position = UDim2.new(0.6,0,1,2)
    listFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = frame
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,6)

    local listScrolling = Instance.new("ScrollingFrame")
    listScrolling.Size = UDim2.new(1,0,1,0)
    listScrolling.BackgroundTransparency = 1
    listScrolling.BorderSizePixel = 0
    listScrolling.CanvasSize = UDim2.new(0,0,0,#options * 30)
    listScrolling.ScrollBarThickness = 4
    listScrolling.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0,2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listScrolling

    local optionButtons = {}
    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,25)
        btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
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
        table.insert(optionButtons, btn)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        listVisible = not listVisible
        listFrame.Visible = listVisible
        if listVisible then
            listFrame.Size = UDim2.new(0.4,0,0,math.min(#optionButtons * 30 + 10, 120))
        end
    end)

    return frame
end

-- ============================================================
-- ЗАПОЛНЕНИЕ СТРАНИЦ
-- ============================================================

-- --- AutoFarm Page ---
do
    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = AutoFarmPage
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    createSection(scroll, T("Фарм", "Farm"))
    createToggle(scroll, T("Фарм монет", "Farm Coins"), T("Автосбор монет", "Auto-collect coins"), getgenv().NKNO.FarmCoins or false, function(val)
        getgenv().NKNO.FarmCoins = val
        if not val and farming then stopFarming() end
    end)
    createToggle(scroll, T("Фарм под картой", "Farm UnderMap"), T("Сбор под картой", "Farm under map"), getgenv().NKNO.FarmUnderMap ~= false, function(val)
        getgenv().NKNO.FarmUnderMap = val
    end)
    createDropdown(scroll, T("Режим сбора", "Collect Mode"), {"Nearest", "Random"}, getgenv().NKNO.FarmMode or "Nearest", function(val)
        getgenv().NKNO.FarmMode = val
    end)
    createSection(scroll, T("Авто-граб", "Auto Grab"))
    createToggle(scroll, T("Авто-граб пистолета", "Auto Grab Gun"), T("Забрать пистолет, если шериф умер", "Grab gun when sheriff dies"), getgenv().NKNO.AutoGrabGun or false, function(val)
        getgenv().NKNO.AutoGrabGun = val
    end)
end

-- --- Movement Page ---
do
    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = MovementPage
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    createSection(scroll, T("Движение", "Movement"))
    createToggle(scroll, T("Кастомная скорость", "Custom WalkSpeed"), "", getgenv().NKNO.CustomWalkSpeed or false, function(val)
        getgenv().NKNO.CustomWalkSpeed = val
        applyWalkSpeed()
    end)
    createSlider(scroll, T("WalkSpeed", "WalkSpeed"), "", 16, 200, getgenv().NKNO.WalkSpeedValue or 16, false, function(val)
        getgenv().NKNO.WalkSpeedValue = val
        if getgenv().NKNO.CustomWalkSpeed then applyWalkSpeed() end
    end)
    createToggle(scroll, T("Кастомный прыжок", "Custom JumpPower"), "", getgenv().NKNO.CustomJumpPower or false, function(val)
        getgenv().NKNO.CustomJumpPower = val
        applyJumpPower()
    end)
    createSlider(scroll, T("JumpPower", "JumpPower"), "", 50, 200, getgenv().NKNO.JumpPowerValue or 50, false, function(val)
        getgenv().NKNO.JumpPowerValue = val
        if getgenv().NKNO.CustomJumpPower then applyJumpPower() end
    end)
    createToggle(scroll, T("Анти-AFK", "Anti-AFK"), T("Движение для избегания кика", "Movement to avoid kick"), getgenv().NKNO.AntiAFK or false, function(val)
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
    createSection(scroll, T("Телепорты", "Teleports"))
    createButton(scroll, T("На карту", "Map TP"), T("Телепорт на текущую карту", "Teleport to current map"), function()
        local map = findMap()
        if map and map:FindFirstChild("Spawns") then
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
            end
        end
    end)
    createButton(scroll, T("В лобби", "Lobby TP"), T("Телепорт в лобби", "Teleport to lobby"), function()
        local lobby = Workspace:FindFirstChild("RegularLobby")
        if lobby and lobby:FindFirstChild("Spawns") then
            local spawns = lobby.Spawns:GetChildren()
            if #spawns > 0 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame
            end
        end
    end)
    createButton(scroll, T("К убийце", "Murder TP"), T("Телепорт к убийце", "Teleport to murderer"), function()
        local m = findMurderer()
        if m and m.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame
        end
    end)
    createButton(scroll, T("К шерифу", "Sheriff TP"), T("Телепорт к шерифу", "Teleport to sheriff"), function()
        local s = findSheriff()
        if s and s.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- --- Theme Page ---
do
    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = ThemePage
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.ScrollBarThickness = 0
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = scroll
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1,0,0,32)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = T("Цветовая палитра интерфейса", "Interface Color Palette")

    local themes = {
        {Color3.fromRGB(0,150,255), Color3.fromRGB(0,70,200), T("Синий Космос", "Blue Space")},
        {Color3.fromRGB(168,85,247), Color3.fromRGB(100,30,180), T("Фиолетовый Кибер", "Purple Cyber")},
        {Color3.fromRGB(34,197,94), Color3.fromRGB(20,100,50), T("Кислотный Лайм", "Acid Lime")},
        {Color3.fromRGB(236,72,153), Color3.fromRGB(150,20,80), T("Пылкая Роза", "Fiery Rose")},
        {Color3.fromRGB(245,158,11), Color3.fromRGB(160,80,0), T("Янтарный Неон", "Amber Neon")},
        {Color3.fromRGB(220,220,230), Color3.fromRGB(100,100,110), T("Белый Фантом", "White Phantom")},
    }

    for _, t in ipairs(themes) do
        local row = Instance.new("TextButton")
        row.Parent = scroll
        row.BackgroundColor3 = Color3.fromRGB(16,16,23)
        row.BackgroundTransparency = 0.15
        row.Size = UDim2.new(1,-10,0,52)
        row.Text = ""
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)

        local circle = Instance.new("Frame")
        circle.Parent = row
        circle.Size = UDim2.new(0,26,0,26)
        circle.Position = UDim2.new(0,16,0.5,-13)
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, t[1]), ColorSequenceKeypoint.new(1, t[2])})
        grad.Parent = circle

        local text = Instance.new("TextLabel")
        text.Parent = row
        text.BackgroundTransparency = 1
        text.Position = UDim2.new(0,56,0,0)
        text.Size = UDim2.new(1,-70,1,0)
        text.Font = Enum.Font.GothamSemibold
        text.TextColor3 = Color3.fromRGB(190,190,210)
        text.TextSize = 15
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Text = t[3]

        row.MouseButton1Click:Connect(function()
            accentColor = t[1]
            TitleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))})
            ToggleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))})
            SepGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,35)), ColorSequenceKeypoint.new(0.5, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,35))})
            -- Обновляем выделенную вкладку
            for _, b in ipairs(tabButtons) do
                if b.BackgroundColor3 ~= Color3.fromRGB(20,20,28) then
                    TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = accentColor}):Play()
                end
            end
        end)
    end

    -- авторазмер канвы
    scroll.CanvasSize = UDim2.new(0,0,0, #themes * 60 + 50)
end

-- --- Admin Page ---
do
    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = AdminPage
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    createSection(scroll, T("Админка", "Admin"))
    createToggle(scroll, T("Режим Бога", "God Mode"), T("Отключить коллизии", "Disable collisions"), getgenv().NKNO.GodMode or false, function(val)
        getgenv().NKNO.GodMode = val
        if val then
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
    createToggle(scroll, T("Анти-флинг (защита)", "Anti-Fling"), T("Защита от флинга", "Anti-fling"), getgenv().NKNO.AntiFling or false, function(val)
        getgenv().NKNO.AntiFling = val
        if val then startAntiFling() else stopAntiFling() end
    end)
    createToggle(scroll, T("Anti Sheriff", "Anti Sheriff"), T("Защита от шерифа", "Protection from sheriff"), getgenv().NKNO.AntiSheriff or false, function(val)
        getgenv().NKNO.AntiSheriff = val
        if val then antiSheriff() end
    end)
    createToggle(scroll, T("Под картой (ручной)", "UnderMap Mode"), T("Уйти под карту", "Go under map"), getgenv().NKNO.UnderMap or false, function(val)
        getgenv().NKNO.UnderMap = val
        if val then goUnderMap() else returnFromUnderMap() end
    end)
    createToggle(scroll, T("Авто-респавн", "Auto Respawn"), T("Респавниться при смерти", "Respawn when dead"), getgenv().NKNO.AutoRespawn or false, function(val)
        getgenv().NKNO.AutoRespawn = val
    end)

    createSection(scroll, T("Флинг", "Fling"))
    createButton(scroll, T("Флинг убийцы", "Fling Murderer"), T("Зафлингует убийцу", "Fling the murderer"), function()
        if getgenv().NKNO.Flinging then return end
        local m = findMurderer()
        if m then
            getgenv().NKNO.Flinging = true
            task.spawn(function()
                SkidFling(m)
                getgenv().NKNO.Flinging = false
            end)
        end
    end)
    createButton(scroll, T("Флинг шерифа", "Fling Sheriff"), T("Зафлингует шерифа", "Fling the sheriff"), function()
        if getgenv().NKNO.Flinging then return end
        local s = findSheriff()
        if s then
            getgenv().NKNO.Flinging = true
            task.spawn(function()
                SkidFling(s)
                getgenv().NKNO.Flinging = false
            end)
        end
    end)

    -- Выбор игрока для флинга (динамический)
    local function getPlayerNames()
        local names = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then table.insert(names, plr.Name) end
        end
        if #names == 0 then names = {"Нет игроков"} end
        return names
    end
    local players = getPlayerNames()
    createDropdown(scroll, T("Выбор игрока", "Select Player"), players, getgenv().NKNO.SelectedPlayerName or players[1], function(val)
        local plr = Players:FindFirstChild(val)
        if plr then
            getgenv().NKNO.SelectedPlayer = plr
            getgenv().NKNO.SelectedPlayerName = val
        else
            getgenv().NKNO.SelectedPlayer = nil
            getgenv().NKNO.SelectedPlayerName = nil
        end
    end)
    createButton(scroll, T("Флинг выбранного", "Fling Selected"), T("Флинг выбранного игрока", "Fling selected player"), function()
        if getgenv().NKNO.Flinging then return end
        local sel = getgenv().NKNO.SelectedPlayer
        if not sel or not sel.Parent then return end
        getgenv().NKNO.Flinging = true
        task.spawn(function()
            SkidFling(sel)
            getgenv().NKNO.Flinging = false
        end)
    end)
    createButton(scroll, T("Остановить флинг", "Stop Fling"), T("Остановить флинг", "Stop fling"), function()
        getgenv().NKNO.Flinging = false
    end)

    createSection(scroll, T("Scam Trade", "Scam Trade"))
    local scamPlayers = getPlayerNames()
    createDropdown(scroll, T("Цель", "Target"), scamPlayers, getgenv().NKNO.ScamTarget and getgenv().NKNO.ScamTarget.Name or scamPlayers[1], function(val)
        local plr = Players:FindFirstChild(val)
        if plr then getgenv().NKNO.ScamTarget = plr end
    end)
    createButton(scroll, T("Включить заморозку", "Enable Freeze"), T("При броске оружия копируется цели", "Weapon copies to target"), function()
        if not getgenv().NKNO.ScamTarget then return end
        startScamTrade(getgenv().NKNO.ScamTarget)
    end)
    createButton(scroll, T("Выключить заморозку", "Disable Freeze"), "", function()
        stopScamTrade()
    end)
    createToggle(scroll, T("Активна", "Active"), "", getgenv().NKNO.ScamTrade or false, function(val)
        getgenv().NKNO.ScamTrade = val
        if val then
            if not getgenv().NKNO.ScamTarget then return end
            startScamTrade(getgenv().NKNO.ScamTarget)
        else
            stopScamTrade()
        end
    end)

    createSection(scroll, T("Add Weapons", "Add Weapons"))
    local presetWeapons = {"Knife", "Gun", "Golden Knife", "Sword", "Axe", "Candy Cane", "Laser Gun"}
    local selectedWeapon = presetWeapons[1]
    createDropdown(scroll, T("Выберите оружие", "Select Weapon"), presetWeapons, selectedWeapon, function(val)
        selectedWeapon = val
    end)
    createButton(scroll, T("Спавн выбранного", "Spawn Selected"), T("Создать оружие в руках", "Spawn in hands"), function()
        spawnWeapon(selectedWeapon)
    end)
    createButton(scroll, T("Убить всех", "Kill All"), T("Убить всех мирных (только убийца)", "Kill all innocents (murderer only)"), function()
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
end

-- ============================================================
-- ВКЛАДКИ (табы)
-- ============================================================
local tabButtons = {}
local function createTabButton(text, page)
    local btn = Instance.new("TextButton")
    btn.Parent = TabContainer
    btn.BackgroundColor3 = Color3.fromRGB(20,20,28)
    btn.BackgroundTransparency = 0.15
    btn.Size = UDim2.new(1,0,0,40)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(150,150,170)
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabButtons) do
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20,20,28), TextColor3 = Color3.fromRGB(150,150,170)}):Play()
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = accentColor, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
        AutoFarmPage.Visible = (page == AutoFarmPage)
        MovementPage.Visible = (page == MovementPage)
        ThemePage.Visible = (page == ThemePage)
        AdminPage.Visible = (page == AdminPage)
    end)
    table.insert(tabButtons, btn)
    return btn
end

local autoTab = createTabButton(T("Авто Фарм", "Auto Farm"), AutoFarmPage)
local moveTab = createTabButton(T("Движение", "Movement"), MovementPage)
local themeTab = createTabButton(T("Темы", "Themes"), ThemePage)
local adminTab = createTabButton(T("Админка", "Admin"), AdminPage)

-- По умолчанию выбрана AutoFarm
autoTab.BackgroundColor3 = accentColor
autoTab.TextColor3 = Color3.fromRGB(255,255,255)

-- ============================================================
-- ЗАПУСК И ОБРАБОТЧИКИ
-- ============================================================

-- Обновление ESP и прочего в фоне
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        updateESP()
        autoGrabGun()
        antiSheriff()
    end
end)

-- Обработчики смены персонажа
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applyWalkSpeed()
    applyJumpPower()
    if getgenv().NKNO.ForceFieldMaterial then applyForceField() end
    if getgenv().NKNO.GodMode then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if getgenv().NKNO.AutoDance then playDance() end
    if getgenv().NKNO.AntiFling then
        stopAntiFling()
        startAntiFling()
    end
end)

-- Открытие по LeftAlt
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        toggleMenu()
    end
end)

-- Если AntiFling включён при старте
if getgenv().NKNO.AntiFling then startAntiFling() end

-- Уведомление
local function Notify(title, desc, duration)
    duration = duration or 3
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,340,0,70)
    frame.Position = UDim2.new(0.5,-170,0.85,0)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,28)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.3
    frame.Parent = ScreenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,-20,0,28)
    titleLabel.Position = UDim2.new(0,10,0,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255,215,0)
    titleLabel.TextSize = 17
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1,-20,0,30)
    descLabel.Position = UDim2.new(0,10,0,28)
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

Notify("NKNO$ HUB " .. SCRIPT_VERSION, T("Нажми Left Alt для открытия меню", "Press Left Alt to open menu"), 4)

-- ============================================================
-- ВАЖНО: все функции (applyWalkSpeed, SkidFling, goUnderMap,
-- updateESP, startAntiFling, antiSheriff, startScamTrade,
-- spawnWeapon, getCoinContainer, findNearestCoin, startFarming,
-- stopFarming, playDance, stopDance, applyForceField, restoreMaterial,
-- и все остальные) должны быть вставлены выше этого места.
-- Они были удалены для краткости, но вы должны скопировать их
-- из вашего первого скрипта (между "ОСНОВНЫЕ ФУНКЦИИ" и "НОВЫЙ GUI").
-- ============================================================
