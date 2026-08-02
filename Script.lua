local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local function CreateHub()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NKNO_HUB"
    ScreenGui.Parent = Player.PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderColor3 = Color3.fromRGB(40, 60, 90)
    MainFrame.BorderSizePixel = 2
    MainFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    Title.Text = "NKNO$ HUB"
    Title.TextColor3 = Color3.fromRGB(180, 230, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.Code
    Title.Parent = MainFrame

    local Hint = Instance.new("TextLabel")
    Hint.Size = UDim2.new(1, 0, 0, 30)
    Hint.Position = UDim2.new(0, 0, 0, 50)
    Hint.BackgroundTransparency = 1
    Hint.Text = "ESC → запустить выбранный  |  клик по карточке → выбрать"
    Hint.TextColor3 = Color3.fromRGB(100, 150, 200)
    Hint.TextScaled = true
    Hint.Font = Enum.Font.SourceSans
    Hint.Parent = MainFrame

    local Scripts = {
        {
            Name = "+1 speed keyboard escape",
            Run = function()
                ScreenGui:Destroy()
                task.wait(0.3)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Kai-Script/NKNO-HUB/refs/heads/main/script3.lua"))()
            end
        },
        {
            Name = "Murder Mystery 2",
            Run = function()
                ScreenGui:Destroy()
                task.wait(0.3)
                getgenv().NKNO = nil  -- сбрасываем старые настройки
                local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Kai-Script/NKNO-HUB/refs/heads/main/script2.lua"))()
                end)
                if not success then
                    warn("[NKNO$ ERROR] Murder Mystery 2: " .. tostring(err))
                end
            end
        }
    }

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -100)
    Container.Position = UDim2.new(0, 10, 0, 85)
    Container.BackgroundTransparency = 1
    Container.CanvasSize = UDim2.new(0, 0, 0, #Scripts * 120)
    Container.ScrollBarThickness = 6
    Container.Parent = MainFrame

    local activeIndex = 1
    local cards = {}

    for i, scriptData in ipairs(Scripts) do
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, -10, 0, 90)
        Card.Position = UDim2.new(0, 0, 0, (i-1)*100 + 10)
        Card.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
        Card.BorderColor3 = (i == activeIndex) and Color3.fromRGB(0, 230, 180) or Color3.fromRGB(40, 60, 90)
        Card.BorderSizePixel = 2
        Card.Parent = Container

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -20, 0, 30)
        NameLabel.Position = UDim2.new(0, 10, 0, 5)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = scriptData.Name
        NameLabel.TextColor3 = Color3.fromRGB(200, 230, 255)
        NameLabel.TextScaled = true
        NameLabel.Font = Enum.Font.Code
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = Card

        local RunBtn = Instance.new("TextButton")
        RunBtn.Size = UDim2.new(0, 100, 0, 30)
        RunBtn.Position = UDim2.new(1, -110, 0, 50)
        RunBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
        RunBtn.BorderColor3 = Color3.fromRGB(60, 100, 150)
        RunBtn.Text = "▶ ЗАПУСТИТЬ"
        RunBtn.TextColor3 = Color3.fromRGB(180, 230, 255)
        RunBtn.TextScaled = true
        RunBtn.Font = Enum.Font.SourceSans
        RunBtn.Parent = Card

        Card.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                activeIndex = i
                for j, c in ipairs(cards) do
                    c.BorderColor3 = (j == i) and Color3.fromRGB(0, 230, 180) or Color3.fromRGB(40, 60, 90)
                end
            end
        end)

        RunBtn.MouseButton1Click:Connect(function()
            activeIndex = i
            for j, c in ipairs(cards) do
                c.BorderColor3 = (j == i) and Color3.fromRGB(0, 230, 180) or Color3.fromRGB(40, 60, 90)
            end
            scriptData.Run()
        end)

        cards[i] = Card
    end

    Mouse.KeyDown:Connect(function(key)
        if key == "Escape" then
            local scriptData = Scripts[activeIndex]
            if scriptData then
                scriptData.Run()
            end
        end
    end)

    Mouse.KeyDown:Connect(function(key)
        if key == "p" then
            ScreenGui:Destroy()
        end
    end)
end

CreateHub()
