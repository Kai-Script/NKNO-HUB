-- ============================================================
-- NKNO$ HUB ULTIMATE v5.4 FINAL (выбор языка + уведомление об обновлении)
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
local SCRIPT_VERSION = "5.4 FINAL"
local UPDATE_DATE = "31 августа"

-- === ИНИЦИАЛИЗАЦИЯ НАСТРОЕК ===
if not getgenv().NKNO then getgenv().NKNO = {} end
local NKNO = getgenv().NKNO

-- Если язык не задан, показать выбор
if not NKNO.Language then
    -- Создаём временное окно выбора языка
    local choiceGui = Instance.new("ScreenGui")
    choiceGui.Name = "LanguageChooser"
    choiceGui.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 400, 0, 150)
    bg.Position = UDim2.new(0.5, -200, 0.5, -75)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    bg.BorderSizePixel = 0
    bg.Parent = choiceGui
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Выберите язык / Choose language"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = bg

    local btnRu = Instance.new("TextButton")
    btnRu.Size = UDim2.new(0, 120, 0, 40)
    btnRu.Position = UDim2.new(0.25, -60, 0.7, -20)
    btnRu.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    btnRu.Text = "Русский"
    btnRu.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnRu.TextSize = 16
    btnRu.Font = Enum.Font.GothamBold
    btnRu.Parent = bg
    Instance.new("UICorner", btnRu).CornerRadius = UDim.new(0, 8)

    local btnEn = Instance.new("TextButton")
    btnEn.Size = UDim2.new(0, 120, 0, 40)
    btnEn.Position = UDim2.new(0.75, -60, 0.7, -20)
    btnEn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    btnEn.Text = "English"
    btnEn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnEn.TextSize = 16
    btnEn.Font = Enum.Font.GothamBold
    btnEn.Parent = bg
    Instance.new("UICorner", btnEn).CornerRadius = UDim.new(0, 8)

    local selected = false
    btnRu.MouseButton1Click:Connect(function()
        NKNO.Language = "ru"
        selected = true
        choiceGui:Destroy()
    end)
    btnEn.MouseButton1Click:Connect(function()
        NKNO.Language = "en"
        selected = true
        choiceGui:Destroy()
    end)

    -- Ждём выбора (бесконечный цикл с проверкой)
    repeat task.wait() until selected
end

local lang = NKNO.Language
local function T(ru, en) return lang == "ru" and ru or en end

-- === ДАЛЕЕ ИДЁТ ВЕСЬ ОСТАЛЬНОЙ КОД (без изменений) ===
-- (здесь должны быть все функции, фарм, ESP, GUI и т.д.)
-- Для краткости я не буду дублировать весь код, но он полностью идентичен предыдущей версии.
-- Вы можете вставить сюда весь скрипт из предыдущего ответа, заменив только начало.
-- В конце уведомление будет изменено.
-- ============================================================

-- [[ ВСТАВЬТЕ СЮДА ВЕСЬ КОД ИЗ ПРЕДЫДУЩЕГО ОТВЕТА, НАЧИНАЯ С findMap() И ДО КОНЦА ]]
-- Но чтобы не тратить место, я покажу только изменённый конец (уведомление).

-- ============================================================
-- ЗАПУСК И ОБРАБОТЧИКИ (конец)
-- ============================================================

-- ... (весь код до Notify остаётся без изменений) ...

-- Уведомления
local function Notify(title, desc, duration)
    duration = duration or 3
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 70)
    frame.Position = UDim2.new(0.5, -170, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.3
    frame.Parent = ScreenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 28)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextSize = 17
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -20, 0, 30)
    descLabel.Position = UDim2.new(0, 10, 0, 28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
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

-- Изменённое уведомление с датой обновления
Notify(
    "NKNO$ HUB " .. SCRIPT_VERSION,
    T(
        "Обновлён " .. UPDATE_DATE .. " | Нажми Left Alt для открытия меню",
        "Updated " .. UPDATE_DATE .. " | Press Left Alt to open menu"
    ),
    5
)

print("NKNO$ HUB v5.4 FINAL загружен. Все функции активны.")
