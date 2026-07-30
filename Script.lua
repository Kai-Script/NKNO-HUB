-- Контейнер для визуалов
local VisualsContainer = Instance.new("Frame")
VisualsContainer.Parent = VisualsPage
VisualsContainer.BackgroundTransparency = 1
VisualsContainer.Size = UDim2.new(0.96,0,1,0)

local VisualsTitleLabel = Instance.new("TextLabel")
VisualsTitleLabel.Parent = VisualsContainer
VisualsTitleLabel.BackgroundTransparency = 1
VisualsTitleLabel.Size = UDim2.new(1,0,0,30)
VisualsTitleLabel.Font = Enum.Font.GothamBold
VisualsTitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
VisualsTitleLabel.TextSize = 18
VisualsTitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Переменные состояния
local currentVisualStyle = "Default"  -- "Default", "BBNO", "Premium"
local clickSoundEnabled = true

-- Функция проигрывания звука
local function PlayClickSound()
    if not clickSoundEnabled then return end
    local soundId = "rbxassetid://9120373785"  -- стандартный
    if currentVisualStyle == "BBNO" then
        soundId = "rbxassetid://9120373786"    -- бас
    elseif currentVisualStyle == "Premium" then
        soundId = "rbxassetid://9120373787"    -- элегантный
    end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.5
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 1)
end

-- Функция применения стиля ко всем кнопкам в хабе
local function ApplyVisualStyle(style)
    currentVisualStyle = style
    local color1, color2, textColor
    if style == "Default" then
        color1 = Color3.fromRGB(20,20,28)
        color2 = Color3.fromRGB(40,40,55)
        textColor = Color3.fromRGB(255,255,255)
    elseif style == "BBNO" then
        color1 = Color3.fromRGB(0,60,40)
        color2 = Color3.fromRGB(0,100,70)
        textColor = Color3.fromRGB(0,255,200)
    elseif style == "Premium" then
        color1 = Color3.fromRGB(80,60,20)
        color2 = Color3.fromRGB(180,140,40)
        textColor = Color3.fromRGB(255,215,0)
    end
    -- Обходим все кнопки (можно пройти по всем текстовым кнопкам в MainFrame)
    for _, btn in ipairs(MainFrame:GetDescendants()) do
        if btn:IsA("TextButton") then
            if btn.Name ~= "CloseBtn" and btn.Name ~= "MinBtn" then
                btn.BackgroundColor3 = color1
                btn.TextColor3 = textColor
            end
        end
    end
    -- Дополнительно можно менять и другие элементы
end

-- Кнопки выбора стиля
local styleButtons = {}
local styleNames = {"Default", "BBNO", "Premium"}
local styleLabels = {L("StyleDefault"), L("StyleBBNO"), L("StylePremium")}

for i, style in ipairs(styleNames) do
    local btn = Instance.new("TextButton")
    btn.Parent = VisualsContainer
    btn.Name = style
    btn.BackgroundColor3 = Color3.fromRGB(16,16,23)
    btn.BackgroundTransparency = 0.15
    btn.Position = UDim2.new(0, (i-1)*120 + 10, 0, 50)
    btn.Size = UDim2.new(0, 100, 0, 44)
    btn.Font = Enum.Font.GothamBold
    btn.Text = styleLabels[i]
    btn.TextColor3 = Color3.fromRGB(200,200,220)
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    table.insert(styleButtons, btn)

    btn.MouseButton1Click:Connect(function()
        PlayClickSound()
        ApplyVisualStyle(style)
        -- подсветка выбранной кнопки
        for _, b in ipairs(styleButtons) do
            b.BackgroundColor3 = Color3.fromRGB(16,16,23)
            b.TextColor3 = Color3.fromRGB(200,200,220)
        end
        btn.BackgroundColor3 = accentColor
        btn.TextColor3 = Color3.fromRGB(255,255,255)
    end)
end

-- Переключатель звука
local SoundToggleFrame = Instance.new("Frame")
SoundToggleFrame.Parent = VisualsContainer
SoundToggleFrame.BackgroundColor3 = Color3.fromRGB(16,16,23)
SoundToggleFrame.BackgroundTransparency = 0.15
SoundToggleFrame.Position = UDim2.new(0,0,0,120)
SoundToggleFrame.Size = UDim2.new(1,0,0,56)
Instance.new("UICorner", SoundToggleFrame).CornerRadius = UDim.new(0,10)

local SoundLabel = Instance.new("TextLabel")
SoundLabel.Parent = SoundToggleFrame
SoundLabel.BackgroundTransparency = 1
SoundLabel.Position = UDim2.new(0,16,0,0)
SoundLabel.Size = UDim2.new(0.7,0,1,0)
SoundLabel.Font = Enum.Font.GothamBold
SoundLabel.TextColor3 = Color3.fromRGB(255,255,255)
SoundLabel.TextSize = 15
SoundLabel.TextXAlignment = Enum.TextXAlignment.Left

local SoundSwitchBG = Instance.new("TextButton")
SoundSwitchBG.Parent = SoundToggleFrame
SoundSwitchBG.BackgroundColor3 = Color3.fromRGB(40,40,55)
SoundSwitchBG.Position = UDim2.new(1, -65,0.5, -14)
SoundSwitchBG.Size = UDim2.new(0,50,0,28)
SoundSwitchBG.Text = ""
Instance.new("UICorner", SoundSwitchBG).CornerRadius = UDim.new(0,14)

local SoundSwitchDot = Instance.new("Frame")
SoundSwitchDot.Parent = SoundSwitchBG
SoundSwitchDot.BackgroundColor3 = Color3.fromRGB(255,255,255)
SoundSwitchDot.Position = UDim2.new(0,25,0.5, -11)  -- по умолчанию включено
SoundSwitchDot.Size = UDim2.new(0,22,0,22)
Instance.new("UICorner", SoundSwitchDot).CornerRadius = UDim.new(0,11)

SoundSwitchBG.BackgroundColor3 = Color3.fromRGB(34,197,94) -- включено

SoundSwitchBG.MouseButton1Click:Connect(function()
    clickSoundEnabled = not clickSoundEnabled
    if clickSoundEnabled then
        TweenService:Create(SoundSwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(34,197,94)}):Play()
        TweenService:Create(SoundSwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0,25,0.5, -11)}):Play()
    else
        TweenService:Create(SoundSwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,55)}):Play()
        TweenService:Create(SoundSwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0.5, -11)}):Play()
    end
end)

-- Обновляем тексты при смене языка
local function UpdateVisualsTexts()
    VisualsTitleLabel.Text = L("VisualsTitle")
    SoundLabel.Text = L("ClickSoundToggle")
    for i, btn in ipairs(styleButtons) do
        btn.Text = styleLabels[i]  -- styleLabels уже обновлены в _G.ApplyLanguage
    end
end

-- Интеграция с _G.ApplyLanguage
local oldApply = _G.ApplyLanguage
_G.ApplyLanguage = function()
    oldApply()
    UpdateVisualsTexts()
end

-- Инициализация
VisualsTitleLabel.Text = L("VisualsTitle")
SoundLabel.Text = L("ClickSoundToggle")
for i, btn in ipairs(styleButtons) do
    btn.Text = styleLabels[i]
end

-- По умолчанию выбираем Default
ApplyVisualStyle("Default")
styleButtons[1].BackgroundColor3 = accentColor
styleButtons[1].TextColor3 = Color3.fromRGB(255,255,255)

-- Подключаем звук ко всем кнопкам (добавляем к уже существующим)
local function AddSoundToAllButtons()
    for _, btn in ipairs(MainFrame:GetDescendants()) do
        if btn:IsA("TextButton") then
            if not btn:GetAttribute("HasSound") then
                btn:SetAttribute("HasSound", true)
                local oldClick = btn.MouseButton1Click
                btn.MouseButton1Click:Connect(function()
                    PlayClickSound()
                end)
            end
        end
    end
end
-- Вызываем после создания всех кнопок
task.wait(0.5)
AddSoundToAllButtons()
