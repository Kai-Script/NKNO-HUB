-- NKNO$ HUB - Полная версия с Auto Farm Random + UnderMap
local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = game.Players.LocalPlayer, game:GetService('Players'), game:GetService('RunService'), game:GetService('TweenService'), game:GetService('ReplicatedStorage'), false, false, false, nil, nil, {}, false, 'Coin', false, false, nil

getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- ===== НОВЫЕ ПЕРЕМЕННЫЕ ДЛЯ РАНДОМИЗАЦИИ =====
local randomDelays = false
local randomMovement = false
local antiAFK = false
local minDelay = 0.1
local maxDelay = 0.5
local randomCoinSelection = false

-- ===== ПЕРЕМЕННЫЕ ДЛЯ UNDERMAP =====
local underMapActive = false
local underMapConnection = nil
local oldFallenHeight = workspace.FallenPartsDestroyHeight

local function setupCharacterCollision(q)
    local function disableCollide(r)
        if f and r:IsA('BasePart') then
            r.CanCollide = false
        end
    end

    for r, s in ipairs(q:GetChildren())do
        disableCollide(s)
    end

    local r, s = q.ChildAdded:Connect(disableCollide), c.Stepped:Connect(function(
    )
        if f and q:IsDescendantOf(workspace) then
            for r, s in ipairs(q:GetChildren())do
                if s:IsA('BasePart') and s.CanCollide then
                    s.CanCollide = false
                end
            end
        end
    end)

    q.Destroying:Connect(function()
        r:Disconnect()
        s:Disconnect()
    end)
end
local function trackPlayer(q)
    if q == a then
        return
    end

    q.CharacterAdded:Connect(setupCharacterCollision)

    if q.Character then
        setupCharacterCollision(q.Character)
    end
end

for q, r in ipairs(b:GetPlayers())do
    trackPlayer(r)
end

b.PlayerAdded:Connect(trackPlayer)

local q, r, s = game:GetService('UserInputService'), pcall(function()
    return print("тут был стиллер я его удалил..")
end)

if not r then
    return
end

local t, u = s:CreateWindow({
    Title = '???',
    Theme = 'Dark',
    Size = UDim2.fromOffset(570, 370),
    Transparency = 0.2,
    Blurring = true,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
}), {
    Light = {
        Primary = Color3.fromRGB(232, 232, 232),
        Secondary = Color3.fromRGB(255, 255, 255),
        Component = Color3.fromRGB(245, 245, 245),
        Interactables = Color3.fromRGB(235, 235, 235),
        Tab = Color3.fromRGB(50, 50, 50),
        Title = Color3.fromRGB(0, 0, 0),
        Description = Color3.fromRGB(100, 100, 100),
        Shadow = Color3.fromRGB(255, 255, 255),
        Outline = Color3.fromRGB(210, 210, 210),
        Icon = Color3.fromRGB(100, 100, 100),
    },
    Dark = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(35, 35, 35),
        Component = Color3.fromRGB(40, 40, 40),
        Interactables = Color3.fromRGB(45, 45, 45),
        Tab = Color3.fromRGB(200, 200, 200),
        Title = Color3.fromRGB(240, 240, 240),
        Description = Color3.fromRGB(200, 200, 200),
        Shadow = Color3.fromRGB(0, 0, 0),
        Outline = Color3.fromRGB(40, 40, 40),
        Icon = Color3.fromRGB(220, 220, 220),
    },
    Void = {
        Primary = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(20, 20, 20),
        Component = Color3.fromRGB(25, 25, 25),
        Interactables = Color3.fromRGB(30, 30, 30),
        Tab = Color3.fromRGB(200, 200, 200),
        Title = Color3.fromRGB(240, 240, 240),
        Description = Color3.fromRGB(200, 200, 200),
        Shadow = Color3.fromRGB(0, 0, 0),
        Outline = Color3.fromRGB(40, 40, 40),
        Icon = Color3.fromRGB(220, 220, 220),
    },
}

t:SetTheme(u.Dark)

local v = t:AddTab({
    Title = 'Main',
    Icon = 'rbxassetid://11963373994',
})

t:AddSection({
    Name = 'Murder Functions',
    Tab = v,
})
t:AddButton({
    Title = 'Kill All',
    Description = 'Kill All Innocents',
    Tab = v,
    Callback = function()
        if not a then
            return
        end

        local w = a.Character

        if not w or not w.Parent then
            return
        end

        local x = w:FindFirstChild('Knife')

        if not x then
            x = a.Backpack:FindFirstChild('Knife')

            if x then
                x.Parent = w
            else
                return
            end
        end

        for y, z in pairs(game.Players:GetPlayers())do
            if z ~= game.Players.LocalPlayer and z.Character then
                for A, B in pairs(z.Character:GetDescendants())do
                    if B:IsA('BasePart') then
                        B.CanCollide = false
                    end
                end

                local A = game.Players.LocalPlayer.Character

                if A then
                    local B = A:FindFirstChild('HumanoidRootPart')

                    if B then
                        local C, D = B.CFrame + B.CFrame.LookVector * 3, z.Character:FindFirstChild('HumanoidRootPart')

                        D.Size = Vector3.new(5, 5, 5)

                        if D then
                            D.CFrame = C
                            D.Anchored = true

                            game:GetService('VirtualInputManager'):SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            game:GetService('VirtualInputManager'):SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end
                    end
                end
            end
        end
    end,
})
t:AddSection({
    Name = 'Sheriff Functions',
    Tab = v,
})

local w, x, y, z, A, B, C = false, nil, false, nil, nil, 1.25, false

local function getPing()
    local D = game:GetService('Stats')
    local E = D.Network.ServerStatsItem['Data Ping']:GetValue()

    return E
end
local function findMurderer()
    local D = game:GetService('ReplicatedStorage')
    local E = D:FindFirstChild('GetPlayerData', true)

    if not E then
        return nil
    end

    local F, G = pcall(function()
        return E:InvokeServer()
    end)

    if not F then
        return nil
    end
    if not G then
        return nil
    end

    for H, I in ipairs(b:GetPlayers())do
        if I ~= b.LocalPlayer and I:GetAttribute('Alive') == true then
            local J = G[I.Name]

            if J and J.Role then
                if J.Role == 'Murderer' then
                    return I
                end
            end
        end
    end

    return nil
end
local function createShootButton()
    if x then
        return
    end

    local D = Instance.new('ScreenGui')

    D.Name = 'ShootButtonGui'
    D.ResetOnSpawn = false
    D.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    D.Parent = game:GetService('CoreGui')

    local E = Instance.new('ImageButton')

    E.Name = 'ShootButton'
    E.Size = UDim2.new(0, 80, 0, 80)
    E.Position = UDim2.new(0.5, -40, 0.5, -40)
    E.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    E.BackgroundTransparency = 0.3
    E.BorderSizePixel = 0
    E.Parent = D

    local F = Instance.new('UICorner')

    F.CornerRadius = UDim.new(1, 0)
    F.Parent = E

    local G = Instance.new('TextLabel')

    G.Size = UDim2.new(1, 0, 1, 0)
    G.BackgroundTransparency = 1
    G.Text = '\u{1f52b}'
    G.TextSize = 32
    G.TextColor3 = Color3.fromRGB(255, 255, 255)
    G.Font = Enum.Font.GothamBold
    G.Parent = E

    E.InputBegan:Connect(function(H)
        if H.UserInputType == Enum.UserInputType.MouseButton1 or H.UserInputType == Enum.UserInputType.Touch then
            y = true
            z = H.Position
            A = E.Position

            H.Changed:Connect(function()
                if H.UserInputState == Enum.UserInputState.End then
                    y = false
                end
            end)
        end
    end)
    E.InputChanged:Connect(function(H)
        if H.UserInputType == Enum.UserInputType.MouseMovement or H.UserInputType == Enum.UserInputType.Touch then
            if y then
                local I = H.Position - z

                E.Position = UDim2.new(A.X.Scale, A.X.Offset + I.X, A.Y.Scale, A.Y.Offset + I.Y)
            end
        end
    end)
    E.MouseButton1Click:Connect(function()
        if not y then
            local H = nil

            if a.Character and a.Character:FindFirstChild('Gun') then
                H = a.Character.Gun
            elseif a.Backpack and a.Backpack:FindFirstChild('Gun') then
                H = a.Backpack.Gun
                H.Parent = a.Character
            end
            if not H then
                return
            end

            local I = findMurderer()

            if not I then
                return
            end

            local J = I.Character

            if not J or not J:FindFirstChild('HumanoidRootPart') then
                return
            end

            local K, L, M = J.HumanoidRootPart, J:FindFirstChild('Torso') or J:FindFirstChild('UpperTorso'), J:FindFirstChild('Humanoid')

            if not L or not M then
                return
            end
            if not a.Character or not a.Character:FindFirstChild('HumanoidRootPart') then
                return
            end

            local N, O = a.Character.HumanoidRootPart, getPing()
            local P, Q = (O / 1000) * B, K.Velocity
            local R, S = L.Position + (Q * P), nil

            if C then
                S = CFrame.new(L.Position, R)
            else
                S = CFrame.new(N.Position, R)
            end

            local T, U = CFrame.new(R), H:FindFirstChild('ShootEvent') or H:FindFirstChild('Shoot')

            if U then
                U:FireServer(S, T)
            end
        end
    end)

    x = D
end
local function removeShootButton()
    if x then
        x:Destroy()

        x = nil
    end
end

t:AddToggle({
    Title = 'Auto Shoot Button',
    Description = 'Creates a draggable button to shoot the murderer',
    Default = false,
    Tab = v,
    Callback = function(D)
        w = D

        if D then
            createShootButton()
        else
            removeShootButton()
        end
    end,
})
t:AddToggle({
    Title = 'Magic Bullet',
    Description = 'First argument will be set to murderer position',
    Default = false,
    Tab = v,
    Callback = function(D)
        C = D
    end,
})
t:AddSection({
    Name = 'Innocent Functions',
    Tab = v,
})
t:AddToggle({
    Title = 'Auto Grab Gun',
    Description = 'Automatically grabbing gun if sheriff died',
    Default = false,
    Tab = v,
    Callback = function(D)
        g = D
    end,
})
t:AddSection({
    Name = 'Auto Farm',
    Tab = v,
})

local function returncoincontainer()
    for D, E in pairs(workspace:GetChildren())do
        if E:FindFirstChild('CoinContainer') and E:IsA('Model') then
            return E:FindFirstChild('CoinContainer')
        end
    end

    return nil
end

-- ===== ИЗМЕНЁННАЯ ФУНКЦИЯ С УЧЁТОМ РАНДОМНОГО ВЫБОРА =====
local function FindNearestCoin(container, useRandom)
    if not container then
        return nil, math.huge
    end

    local candidates = {}
    for _, coin in pairs(container:GetChildren()) do
        if coin:GetAttribute('CoinID') == 'Coin' and coin:FindFirstChild('TouchInterest') and coin.Transparency == 1 then
            if a.Character and a.Character:FindFirstChild('HumanoidRootPart') then
                local dist = (a.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                table.insert(candidates, {coin = coin, dist = dist})
            end
        end
    end
    if #candidates == 0 then
        return nil, math.huge
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    if useRandom and #candidates > 2 then
        -- Выбираем случайную монету из трёх ближайших
        local index = math.random(1, math.min(3, #candidates))
        return candidates[index].coin, candidates[index].dist
    else
        return candidates[1].coin, candidates[1].dist
    end
end

t:AddToggle({
    Title = 'Farm Coins',
    Description = 'Automatically farm coins with noclip',
    Default = false,
    Tab = v,
    Callback = function(D)
        h = D
        if not D then
            l = false
        end
    end,
})

-- ===== НОВЫЕ ЭЛЕМЕНТЫ ДЛЯ РАНДОМИЗАЦИИ =====
t:AddToggle({
    Title = 'Random Delays',
    Description = 'Add random delays between coin pickups',
    Default = false,
    Tab = v,
    Callback = function(val)
        randomDelays = val
    end,
})
t:AddToggle({
    Title = 'Random Movement',
    Description = 'Add random offsets to movement path',
    Default = false,
    Tab = v,
    Callback = function(val)
        randomMovement = val
    end,
})
t:AddToggle({
    Title = 'Random Coin Selection',
    Description = 'Pick random nearby coin instead of nearest',
    Default = false,
    Tab = v,
    Callback = function(val)
        randomCoinSelection = val
    end,
})
t:AddToggle({
    Title = 'Anti-AFK',
    Description = 'Send random movements to avoid AFK kick',
    Default = false,
    Tab = v,
    Callback = function(val)
        antiAFK = val
        if val then
            task.spawn(function()
                while antiAFK and task.wait(math.random(30, 60)) do
                    if a.Character and a.Character:FindFirstChild('Humanoid') then
                        local humanoid = a.Character.Humanoid
                        local moveDir = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
                        humanoid:MoveTo(a.Character.HumanoidRootPart.Position + moveDir * 5)
                    end
                end
            end)
        end
    end,
})
t:AddSlider({
    Title = 'Min Delay (s)',
    Description = 'Minimum random delay',
    Tab = v,
    Default = 0.1,
    MinValue = 0,
    MaxValue = 1,
    AllowDecimals = true,
    Callback = function(val)
        minDelay = val
    end,
})
t:AddSlider({
    Title = 'Max Delay (s)',
    Description = 'Maximum random delay',
    Tab = v,
    Default = 0.5,
    MinValue = 0,
    MaxValue = 2,
    AllowDecimals = true,
    Callback = function(val)
        maxDelay = val
    end,
})

local D = t:AddTab({
    Title = 'Visuals',
    Icon = 'rbxassetid://11963373994',
})

t:AddSection({
    Name = 'Chams',
    Tab = D,
})
t:AddToggle({
    Title = 'Chams Murderer',
    Description = 'Enable Chams for Murderer',
    Default = false,
    Tab = D,
    Callback = function(E)
        ESP_SETTINGS.Murderer = E
    end,
})
t:AddToggle({
    Title = 'Chams Sheriff',
    Description = 'Enable Chams for Sheriff',
    Default = false,
    Tab = D,
    Callback = function(E)
        ESP_SETTINGS.Sheriff = E
    end,
})
t:AddToggle({
    Title = 'Chams Innocent',
    Description = 'Enable Chams for Innocent',
    Default = false,
    Tab = D,
    Callback = function(E)
        ESP_SETTINGS.Innocent = E
    end,
})
t:AddToggle({
    Title = 'Chams Hero',
    Description = 'Enable Chams for Hero',
    Default = false,
    Tab = D,
    Callback = function(E)
        ESP_SETTINGS.Hero = E
    end,
})
t:AddSection({
    Name = 'ESP',
    Tab = D,
})
t:AddToggle({
    Title = 'ESP Murderer',
    Description = 'Show Murderer name above head',
    Default = false,
    Tab = D,
    Callback = function(E)
        NAME_ESP_SETTINGS.Murderer = E
    end,
})
t:AddToggle({
    Title = 'ESP Sheriff',
    Description = 'Show Sheriff name above head',
    Default = false,
    Tab = D,
    Callback = function(E)
        NAME_ESP_SETTINGS.Sheriff = E
    end,
})
t:AddToggle({
    Title = 'ESP Innocent',
    Description = 'Show Innocent name above head',
    Default = false,
    Tab = D,
    Callback = function(E)
        NAME_ESP_SETTINGS.Innocent = E
    end,
})
t:AddToggle({
    Title = 'ESP Hero',
    Description = 'Show Hero name above head',
    Default = false,
    Tab = D,
    Callback = function(E)
        NAME_ESP_SETTINGS.Hero = E
    end,
})
t:AddSection({
    Name = 'ESP Customization',
    Tab = D,
})
t:AddToggle({
    Title = '2D Box',
    Description = 'Show 2D box around player',
    Default = false,
    Tab = D,
    Callback = function(E)
        ESP_CUSTOMIZATION.Box2D = E
    end,
})
t:AddToggle({
    Title = 'Display Name',
    Description = 'Show display name instead of username',
    Default = false,
    Tab = D,
    Callback = function(E)
        ESP_CUSTOMIZATION.DisplayName = E

        if E then
            ESP_CUSTOMIZATION.NormalName = false
        end
    end,
})
t:AddToggle({
    Title = 'Normal Name',
    Description = 'Show normal username',
    Default = true,
    Tab = D,
    Callback = function(E)
        ESP_CUSTOMIZATION.NormalName = E

        if E then
            ESP_CUSTOMIZATION.DisplayName = false
        end
    end,
})
t:AddToggle({
    Title = 'Avatar Display',
    Description = 'Show player avatar above name',
    Default = false,
    Tab = D,
    Callback = function(E)
        ESP_CUSTOMIZATION.AvatarDisplay = E
    end,
})

local E = t:AddTab({
    Title = 'Misc',
    Icon = 'rbxassetid://11963373994',
})

t:AddToggle({
    Title = 'Anti-Fling',
    Description = 'Anti-Fling',
    Tab = E,
    Callback = function(F)
        f = F
    end,
})
t:AddSection({
    Name = 'Character Modifiers',
    Tab = E,
})

local F, G, H, I = false, false, 16, 50

local function applyWalkSpeed()
    if F and a.Character then
        local J = a.Character:FindFirstChildOfClass('Humanoid')

        if J then
            J.WalkSpeed = H
        end
    end
end
local function applyJumpPower()
    if G and a.Character then
        local J = a.Character:FindFirstChildOfClass('Humanoid')

        if J then
            J.JumpPower = I
        end
    end
end

task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if F then
            applyWalkSpeed()
        end
        if G then
            applyJumpPower()
        end
    end
end)
a.CharacterAdded:Connect(function(J)
    J:WaitForChild('Humanoid')
    task.wait(0.1)

    if F then
        applyWalkSpeed()
    end
    if G then
        applyJumpPower()
    end
end)
t:AddToggle({
    Title = 'Custom WalkSpeed',
    Description = 'Enable custom walk speed',
    Default = false,
    Tab = E,
    Callback = function(J)
        F = J

        if J then
            applyWalkSpeed()
        else
            if a.Character then
                local K = a.Character:FindFirstChildOfClass('Humanoid')

                if K then
                    K.WalkSpeed = 16
                end
            end
        end
    end,
})
t:AddSlider({
    Title = 'WalkSpeed Value',
    Description = 'Set custom walk speed value',
    Tab = E,
    Default = 16,
    MinValue = 16,
    MaxValue = 200,
    AllowDecimals = false,
    Callback = function(J)
        H = J

        if F then
            applyWalkSpeed()
        end
    end,
})
t:AddToggle({
    Title = 'Custom JumpPower',
    Description = 'Enable custom jump power',
    Default = false,
    Tab = E,
    Callback = function(J)
        G = J

        if J then
            applyJumpPower()
        else
            if a.Character then
                local K = a.Character:FindFirstChildOfClass('Humanoid')

                if K then
                    K.JumpPower = 50
                end
            end
        end
    end,
})
t:AddSlider({
    Title = 'JumpPower Value',
    Description = 'Set custom jump power value',
    Tab = E,
    Default = 50,
    MinValue = 50,
    MaxValue = 200,
    AllowDecimals = false,
    Callback = function(J)
        I = J

        if G then
            applyJumpPower()
        end
    end,
})

local J, K = false, 70

local function applyFOV()
    if J then
        local L = workspace.CurrentCamera

        if L then
            L.FieldOfView = K
        end
    end
end

task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if J then
            applyFOV()
        end
    end
end)
t:AddToggle({
    Title = 'Custom FOV',
    Description = 'Enable custom field of view',
    Default = false,
    Tab = E,
    Callback = function(L)
        J = L

        if L then
            applyFOV()
        else
            local M = workspace.CurrentCamera

            if M then
                M.FieldOfView = 70
            end
        end
    end,
})
t:AddSlider({
    Title = 'FOV Value',
    Description = 'Set custom field of view value',
    Tab = E,
    Default = 70,
    MinValue = 70,
    MaxValue = 120,
    AllowDecimals = false,
    Callback = function(L)
        K = L

        if J then
            applyFOV()
        end
    end,
})

local L = false

local function applyForceFieldMaterial()
    if not L then
        return
    end
    if not a.Character then
        return
    end

    for M, N in pairs(a.Character:GetDescendants())do
        if N:IsA('BasePart') or N:IsA('MeshPart') then
            N.Material = Enum.Material.ForceField
        end
    end
end

task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if L then
            applyForceFieldMaterial()
        end
    end
end)
a.CharacterAdded:Connect(function(M)
    M:WaitForChild('Humanoid')
    task.wait(0.1)

    if L then
        applyForceFieldMaterial()
    end
end)
t:AddToggle({
    Title = 'Force Field Body Parts',
    Description = 'Set all body parts material to ForceField',
    Default = false,
    Tab = E,
    Callback = function(M)
        L = M

        if M then
            applyForceFieldMaterial()
            t:Notify({
                Title = 'ForceField Enabled',
                Description = 'Body parts material set to ForceField',
                Duration = 2,
            })
        else
            if a.Character then
                for N, O in pairs(a.Character:GetDescendants())do
                    if O:IsA('BasePart') or O:IsA('MeshPart') then
                        O.Material = Enum.Material.Plastic
                    end
                end
            end

            t:Notify({
                Title = 'ForceField Disabled',
                Description = 'Body parts material restored',
                Duration = 2,
            })
        end
    end,
})

local M = t:AddTab({
    Title = 'Settings',
    Icon = 'rbxassetid://11293977610',
})

t:AddKeybind({
    Title = 'Minimize Keybind',
    Description = 'Set the keybind for Minimizing',
    Tab = M,
    Callback = function(N)
        t:SetSetting('Keybind', N)
    end,
})
t:AddDropdown({
    Title = 'Set Theme',
    Description = 'Set the theme of the library!',
    Tab = M,
    Options = {
        ['Light Mode'] = 'Light',
        ['Dark Mode'] = 'Dark',
        ['Extra Dark'] = 'Void',
    },
    Callback = function(N)
        t:SetTheme(u[N])
    end,
})
t:AddToggle({
    Title = 'UI Blur',
    Description = 'If enabled, must have your Roblox graphics set to 8+ for it to work',
    Default = true,
    Tab = M,
    Callback = function(N)
        t:SetSetting('Blur', N)
    end,
})
t:AddSlider({
    Title = 'UI Transparency',
    Description = 'Set the transparency of the UI',
    Tab = M,
    AllowDecimals = true,
    MaxValue = 1,
    Callback = function(N)
        t:SetSetting('Transparency', N)
    end,
})
t:Notify({
    Title = 'Hello World!',
    Description = 'Press Left Alt to Minimize and Open the tab!',
    Duration = 10,
})

local N, O = game:GetService('Players'), game:GetService('ReplicatedStorage')
local P = O:FindFirstChild('GetPlayerData', true)

ESP_SETTINGS = {
    Murderer = false,
    Sheriff = false,
    Innocent = false,
    Hero = false,
}
NAME_ESP_SETTINGS = {
    Murderer = false,
    Sheriff = false,
    Innocent = false,
    Hero = false,
}
ESP_CUSTOMIZATION = {
    Box2D = false,
    DisplayName = false,
    NormalName = true,
    AvatarDisplay = false,
}

local Q = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Hero = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(0, 255, 0),
}

local function CreateESP(R, S)
    if not R.Character then
        return
    end

    local T = R.Character:FindFirstChild('RoleESP')

    if not T then
        T = Instance.new('Highlight')
        T.Name = 'RoleESP'
        T.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        T.FillTransparency = 0.5
        T.OutlineTransparency = 0
        T.Parent = R.Character
    end

    T.FillColor = S
    T.OutlineColor = S
end
local function RemoveESP(R)
    if R.Character then
        local S = R.Character:FindFirstChild('RoleESP')

        if S then
            S:Destroy()
        end
    end
end
local function Create2DBox(R, S)
    if not R.Character then
        return
    end

    local T = R.Character:FindFirstChild('HumanoidRootPart')

    if not T then
        return
    end

    local U = T:FindFirstChild('Box2D')

    if ESP_CUSTOMIZATION.Box2D then
        if not U then
            U = Instance.new('BillboardGui')
            U.Name = 'Box2D'
            U.AlwaysOnTop = true
            U.Size = UDim2.new(4, 0, 5, 0)
            U.StudsOffset = Vector3.new(0, 0, 0)
            U.Parent = T

            local V = Instance.new('Frame')

            V.Name = 'BoxFrame'
            V.BackgroundTransparency = 1
            V.Size = UDim2.new(1, 0, 1, 0)
            V.BorderSizePixel = 2
            V.Parent = U

            local W = Instance.new('UIStroke')

            W.Name = 'Stroke'
            W.Thickness = 2
            W.Parent = V
        end

        local V = U:FindFirstChild('BoxFrame')

        if V then
            local W = V:FindFirstChild('Stroke')

            if W then
                W.Color = S
            end
        end
    else
        if U then
            U:Destroy()
        end
    end
end
local function CreateNameESP(R, S)
    if not R.Character then
        return
    end

    local T, U = R.Character:FindFirstChild('Head'), R.Character:FindFirstChild('HumanoidRootPart')

    if not T or not U then
        return
    end

    local V = T:FindFirstChild('NameESP')

    if not V then
        V = Instance.new('BillboardGui')
        V.Name = 'NameESP'
        V.AlwaysOnTop = true
        V.Size = UDim2.new(0, 200, 0, 80)
        V.StudsOffset = Vector3.new(0, 2, 0)
        V.Parent = T

        local W = Instance.new('Frame')

        W.Name = 'AvatarFrame'
        W.BackgroundColor3 = Color3.new(1, 1, 1)
        W.Size = UDim2.new(0, 40, 0, 40)
        W.Position = UDim2.new(0.5, -20, 0, 0)
        W.BorderSizePixel = 2
        W.Parent = V

        local X = Instance.new('UICorner')

        X.CornerRadius = UDim.new(1, 0)
        X.Parent = W

        local Y = Instance.new('ImageLabel')

        Y.Name = 'Avatar'
        Y.BackgroundTransparency = 1
        Y.Size = UDim2.new(1, 0, 1, 0)
        Y.Image = N:GetUserThumbnailAsync(R.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        Y.Parent = W

        local Z = Instance.new('UICorner')

        Z.CornerRadius = UDim.new(1, 0)
        Z.Parent = Y

        local _ = Instance.new('TextLabel')

        _.Name = 'NameLabel'
        _.BackgroundTransparency = 1
        _.Size = UDim2.new(1, 0, 0, 20)
        _.Position = UDim2.new(0, 0, 1, -20)
        _.Font = Enum.Font.GothamBold
        _.TextSize = 14
        _.TextStrokeTransparency = 0
        _.TextStrokeColor3 = Color3.new(0, 0, 0)
        _.Parent = V
    end

    local W, X = V:FindFirstChild('AvatarFrame'), V:FindFirstChild('NameLabel')

    if X then
        if ESP_CUSTOMIZATION.DisplayName then
            X.Text = R.DisplayName
        elseif ESP_CUSTOMIZATION.NormalName then
            X.Text = R.Name
        else
            X.Text = ''
        end

        X.TextColor3 = S
    end
    if W then
        W.Visible = ESP_CUSTOMIZATION.AvatarDisplay
        W.BorderColor3 = S
    end

    Create2DBox(R, S)
end
local function RemoveNameESP(R)
    if R.Character then
        local S = R.Character:FindFirstChild('Head')

        if S then
            local T = S:FindFirstChild('NameESP')

            if T then
                T:Destroy()
            end
        end

        local T = R.Character:FindFirstChild('HumanoidRootPart')

        if T then
            local U = T:FindFirstChild('Box2D')

            if U then
                U:Destroy()
            end
        end
    end
end
local function UpdateESP()
    local R, S = pcall(function()
        return P:InvokeServer()
    end)

    if not R then
        return
    end

    for T, U in ipairs(N:GetPlayers())do
        if U ~= N.LocalPlayer and U:GetAttribute('Alive') == true then
            local V, W = 'Innocent', S[U.Name]

            if W and W.Role then
                V = W.Role
            end

            local X = Q[V] or Q.Innocent

            if ESP_SETTINGS[V] == true then
                CreateESP(U, X)
            else
                RemoveESP(U)
            end
            if NAME_ESP_SETTINGS[V] == true then
                CreateNameESP(U, X)
            else
                RemoveNameESP(U)
            end
        else
            RemoveESP(U)
            RemoveNameESP(U)
        end
    end
end
local function findmap()
    for R, S in (game.Workspace:GetChildren())do
        if S:GetAttribute('MapID') then
            return S
        end
    end
end

t:AddButton({
    Title = 'Map TP',
    Description = 'Teleports you in map',
    Tab = E,
    Callback = function()
        if not a then
            return
        end

        local R = a.Character

        if not R or not R.Parent then
            return
        end

        for S, T in (findmap().Spawns:GetChildren())do
            R.HumanoidRootPart.CFrame = T.CFrame

            return
        end
    end,
})
t:AddButton({
    Title = 'Lobby TP',
    Description = 'Teleports you in Lobby',
    Tab = E,
    Callback = function()
        if not a then
            return
        end

        local R = a.Character

        if not R or not R.Parent then
            return
        end

        for S, T in (workspace.RegularLobby.Spawns:GetChildren())do
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = T.CFrame

            return
        end
    end,
})
t:AddButton({
    Title = 'Murder TP',
    Description = 'Teleports you to Murder',
    Tab = E,
    Callback = function()
        if not a then
            return
        end

        local R = a.Character

        if not R or not R.Parent then
            return
        end

        local S, T = pcall(function()
            return P:InvokeServer()
        end)

        if S and T then
            for U, V in pairs(b:GetPlayers())do
                if V ~= a and V:GetAttribute('Alive') == true then
                    local W = T[V.Name]

                    if W and W.Role == 'Murderer' and V.Character then
                        R.HumanoidRootPart.CFrame = V.Character.HumanoidRootPart.CFrame

                        return
                    end
                end
            end
        end
    end,
})
t:AddButton({
    Title = 'Sheriff TP',
    Description = 'Teleports you to Sheriff',
    Tab = E,
    Callback = function()
        if not a then
            return
        end

        local R = a.Character

        if not R or not R.Parent then
            return
        end

        local S, T = pcall(function()
            return P:InvokeServer()
        end)

        if S and T then
            for U, V in pairs(b:GetPlayers())do
                if V ~= a and V:GetAttribute('Alive') == true then
                    local W = T[V.Name]

                    if W and W.Role == 'Sheriff' and V.Character then
                        R.HumanoidRootPart.CFrame = V.Character.HumanoidRootPart.CFrame

                        return
                    end
                end
            end
        end
    end,
})
t:AddSection({
    Name = 'Dance Emotes',
    Tab = E,
})

local R, S, T, U = false, '127118661424463', nil, {
    ['Dance 1'] = '127118661424463',
    ['Dance 2'] = '82682811348660',
    ['Dance 3'] = '10714340543',
    ['Dance 4'] = '15609995579',
}

local function playDance()
    if not a.Character then
        return
    end
    if not S then
        return
    end

    local V = a.Character:FindFirstChildOfClass('Humanoid')

    if not V then
        return
    end

    local W = V:FindFirstChildOfClass('Animator')

    if not W then
        W = Instance.new('Animator')
        W.Parent = V
    end
    if T then
        pcall(function()
            T:Stop()
        end)
        task.wait(0.1)
        pcall(function()
            T:Destroy()
        end)

        T = nil
    end

    task.wait(0.1)

    local X = Instance.new('Animation')

    X.AnimationId = 'rbxassetid://' .. tostring(S)

    pcall(function()
        T = W:LoadAnimation(X)
        T.Looped = true
        T.Priority = Enum.AnimationPriority.Action

        T:Play(0.1, 1, 1)
    end)
    X:Destroy()
end
local function stopDance()
    if T then
        pcall(function()
            T:Stop()
            T:Destroy()
        end)

        T = nil
    end
end

a.CharacterAdded:Connect(function(V)
    V:WaitForChild('Humanoid')
    task.wait(0.5)

    if R then
        playDance()
    end
end)
t:AddDropdown({
    Title = 'Select Dance',
    Description = 'Choose a dance emote',
    Tab = E,
    Options = U,
    Callback = function(V)
        if V then
            S = V

            if R then
                stopDance()
                task.wait(0.2)
                playDance()
                t:Notify({
                    Title = 'Dance Changed',
                    Description = 'Dance ID: ' .. tostring(S),
                    Duration = 2,
                })
            end
        end
    end,
})
t:AddToggle({
    Title = 'Auto Dance',
    Description = 'Automatically play selected dance',
    Default = false,
    Tab = E,
    Callback = function(V)
        R = V

        if V then
            playDance()
            t:Notify({
                Title = 'Dance Started',
                Description = 'Now dancing!',
                Duration = 2,
            })
        else
            stopDance()
            t:Notify({
                Title = 'Dance Stopped',
                Description = 'Dance disabled',
                Duration = 2,
            })
        end
    end,
})
t:AddSection({
    Name = 'Fling Players',
    Tab = E,
})

local function SkidFling(V)
    local W = a.Character
    local X = W and W:FindFirstChildOfClass('Humanoid')
    local Y, Z = X and X.RootPart, V.Character

    if not Z then
        return
    end

    local _, aa, ab, ac, ad

    if Z:FindFirstChildOfClass('Humanoid') then
        _ = Z:FindFirstChildOfClass('Humanoid')
    end
    if _ and _.RootPart then
        aa = _.RootPart
    end
    if Z:FindFirstChild('Head') then
        ab = Z.Head
    end
    if Z:FindFirstChildOfClass('Accessory') then
        ac = Z:FindFirstChildOfClass('Accessory')
    end
    if ac and ac:FindFirstChild('Handle') then
        ad = ac.Handle
    end
    if W and X and Y then
        if Y.Velocity.Magnitude < 50 then
            getgenv().OldPos = Y.CFrame
        end
        if _ and _.Sit then
            return
        end
        if ab then
            workspace.CurrentCamera.CameraSubject = ab
        elseif ad then
            workspace.CurrentCamera.CameraSubject = ad
        elseif _ and aa then
            workspace.CurrentCamera.CameraSubject = _
        end
        if not Z:FindFirstChildWhichIsA('BasePart') then
            return
        end

        local ae = function(ae, af, ag)
            Y.CFrame = CFrame.new(ae.Position) * af * ag

            W:SetPrimaryPartCFrame(CFrame.new(ae.Position) * af * ag)

            Y.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            Y.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local af = function(af)
            local ag, ah, ai = 2, tick(), 0

            repeat
                if Y and _ then
                    if af.Velocity.Magnitude < 50 then
                        ai = ai + 100

                        ae(af, CFrame.new(0, 1.5, 0) + _.MoveDirection * af.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ai), 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, -1.5, 0) + _.MoveDirection * af.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ai), 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, 1.5, 0) + _.MoveDirection * af.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ai), 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, -1.5, 0) + _.MoveDirection * af.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ai), 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, 1.5, 0) + _.MoveDirection, CFrame.Angles(math.rad(ai), 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, -1.5, 0) + _.MoveDirection, CFrame.Angles(math.rad(ai), 0, 0))
                        task.wait()
                    else
                        ae(af, CFrame.new(0, 1.5, _.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, -1.5, -_.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, 1.5, _.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        ae(af, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until ah + ag < tick() or not o
        end

        workspace.FallenPartsDestroyHeight = 0 / 0

        local ag = Instance.new('BodyVelocity')

        ag.Parent = Y
        ag.Velocity = Vector3.new(0, 0, 0)
        ag.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        X:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if aa then
            af(aa)
        elseif ab then
            af(ab)
        elseif ad then
            af(ad)
        end

        ag:Destroy()
        X:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

        workspace.CurrentCamera.CameraSubject = X

        if getgenv().OldPos then
            repeat
                Y.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)

                W:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                X:ChangeState('GettingUp')

                for ah, ai in pairs(W:GetChildren())do
                    if ai:IsA('BasePart') then
                        ai.Velocity, ai.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end

                task.wait()
            until (Y.Position - getgenv().OldPos.p).Magnitude < 25

            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
end
local function FindPlayerByPartialName(aa)
    if not aa or aa == '' then
        return nil
    end

    local ab = string.lower(aa)

    for ac, ad in pairs(b:GetPlayers())do
        if ad ~= a and string.lower(ad.Name) == ab then
            return ad
        end
    end
    for ac, ad in pairs(b:GetPlayers())do
        if ad ~= a and string.sub(string.lower(ad.Name), 1, #ab) == ab then
            return ad
        end
    end
    for ac, ad in pairs(b:GetPlayers())do
        if ad ~= a and string.find(string.lower(ad.Name), ab, 1, true) then
            return ad
        end
    end

    return nil
end

t:AddInput({
    Title = 'Player Search',
    Description = 'Enter player name or part of it',
    Tab = E,
    Callback = function(aa)
        local ab = FindPlayerByPartialName(aa)

        if ab then
            p = ab

            t:Notify({
                Title = 'Player Found',
                Description = 'Selected: ' .. ab.Name,
                Duration = 2,
            })
        else
            p = nil

            if aa ~= '' then
                t:Notify({
                    Title = 'Not Found',
                    Description = 'No player found matching: ' .. aa,
                    Duration = 2,
                })
            end
        end
    end,
})
t:AddButton({
    Title = 'Fling Murderer',
    Description = 'Automatically fling the murderer',
    Tab = E,
    Callback = function()
        if o then
            return
        end

        local aa, ab, ac = nil, pcall(function()
            return P:InvokeServer()
        end)

        if ab and ac then
            for ad, ae in pairs(b:GetPlayers())do
                if ae ~= a and ae:GetAttribute('Alive') == true then
                    local af = ac[ae.Name]

                    if af and af.Role == 'Murderer' then
                        aa = ae

                        break
                    end
                end
            end
        end
        if aa then
            o = true

            t:Notify({
                Title = 'Fling Started',
                Description = 'Flinging murderer: ' .. aa.Name,
                Duration = 3,
            })
            task.spawn(function()
                SkidFling(aa)

                o = false
            end)
        end
    end,
})
t:AddButton({
    Title = 'Fling Sheriff',
    Description = 'Automatically fling the sheriff',
    Tab = E,
    Callback = function()
        if o then
            return
        end

        local aa, ab, ac = nil, pcall(function()
            return P:InvokeServer()
        end)

        if ab and ac then
            for ad, ae in pairs(b:GetPlayers())do
                if ae ~= a and ae:GetAttribute('Alive') == true then
                    local af = ac[ae.Name]

                    if af and af.Role == 'Sheriff' then
                        aa = ae

                        break
                    end
                end
            end
        end
        if aa then
            o = true

            t:Notify({
                Title = 'Fling Started',
                Description = 'Flinging sheriff: ' .. aa.Name,
                Duration = 3,
            })
            task.spawn(function()
                SkidFling(aa)

                o = false
            end)
        end
    end,
})
t:AddButton({
    Title = 'Fling Selected Player',
    Description = 'Fling the player selected in dropdown',
    Tab = E,
    Callback = function()
        if o then
            return
        end
        if not p or not p.Parent then
            t:Notify({
                Title = 'Error',
                Description = 'Please select a valid player first!',
                Duration = 3,
            })

            return
        end

        o = true

        t:Notify({
            Title = 'Fling Started',
            Description = 'Flinging: ' .. p.Name,
            Duration = 3,
        })
        task.spawn(function()
            SkidFling(p)

            o = false
        end)
    end,
})
t:AddButton({
    Title = 'Stop Fling',
    Description = 'Stop current fling operation',
    Tab = E,
    Callback = function()
        if o then
            o = false

            t:Notify({
                Title = 'Fling Stopped',
                Description = 'Fling operation has been stopped',
                Duration = 3,
            })
        else
            t:Notify({
                Title = 'Info',
                Description = 'No active fling operation',
                Duration = 2,
            })
        end
    end,
})

-- ===== ФУНКЦИЯ ДЛЯ АВТО-ГРАБА ПИСТОЛЕТА =====
local function getgun()
    pcall(function()
        if not g then
            return
        end
        if not a:GetAttribute('Alive') then
            return
        end

        local aa, ab = findmap(), nil

        if not aa then
            return
        end

        ab = a.Character.HumanoidRootPart.CFrame

        if aa:FindFirstChild('GunDrop') then
            aa:FindFirstChild('GunDrop').CFrame = a.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- ===== ФУНКЦИИ ДЛЯ ФАРМА =====
local function enableNoclip()
    if i then
        return
    end

    i = c.Stepped:Connect(function()
        if h and a.Character then
            for aa, ab in pairs(a.Character:GetDescendants())do
                if ab:IsA('BasePart') then
                    ab.CanCollide = false
                end
            end
        end
    end)
end

local function startFarming()
    if not a.Character or not a.Character:FindFirstChild('HumanoidRootPart') then
        return
    end
    if a:GetAttribute('Alive') ~= true then
        return
    end

    local aa, ab = a.Character.HumanoidRootPart, a.Character:FindFirstChild('Humanoid')

    k = {}

    for ac, ad in pairs(a.Character:GetDescendants())do
        if ad:IsA('BasePart') then
            k[ad] = {
                CanCollide = ad.CanCollide,
                Massless = ad.Massless,
            }
        end
    end

    aa.CFrame = aa.CFrame - Vector3.new(0, 2.5, 0)
    aa.CFrame = aa.CFrame * CFrame.Angles(math.rad(90), 0, 0)

    if ab then
        ab.PlatformStand = true

        ab:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        ab:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end

    l = true
end

local function stopFarming()
    l = false

    if j then
        j:Cancel()

        j = nil
    end
    if i then
        i:Disconnect()

        i = nil
    end
    if a.Character then
        for aa, ab in pairs(k)do
            if aa and aa.Parent then
                aa.CanCollide = ab.CanCollide
                aa.Massless = ab.Massless
            end
        end

        local aa = a.Character:FindFirstChild('HumanoidRootPart')

        if aa then
            aa.Velocity = Vector3.new(0, 0, 0)
            aa.RotVelocity = Vector3.new(0, 0, 0)
            aa.CFrame = aa.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            aa.CFrame = aa.CFrame + Vector3.new(0, 2.5, 0)
        end

        local ab = a.Character:FindFirstChild('Humanoid')

        if ab then
            ab.PlatformStand = false

            ab:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            ab:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end

    k = {}
end

local aa = O.Remotes.Gameplay.CoinCollected

aa.OnClientEvent:Connect(function(ab, ac, ad)
    if ab == m then
        if tonumber(ac) == tonumber(ad) then
            n = true

            if l then
                stopFarming()
            end
        else
            n = false
        end
    end
end)

local ab, ac = O.Remotes.Gameplay.RoundStart, O.Remotes.Gameplay.RoundEndFade

ab.OnClientEvent:Connect(function()
    n = false
end)
ac.OnClientEvent:Connect(function()
    n = false

    if l then
        stopFarming()
    end
end)

-- ===== ОСНОВНОЙ ЦИКЛ ФАРМА С РАНДОМИЗАЦИЕЙ =====
task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if l and a.Character and a.Character:FindFirstChild('HumanoidRootPart') and a:GetAttribute('Alive') == true then
            local ad, ae = a.Character.HumanoidRootPart, returncoincontainer()

            if ae then
                for af, ag in pairs(ae:GetChildren())do
                    if ag:GetAttribute('CoinID') == 'Coin' and ag:FindFirstChild('TouchInterest') and ag.Transparency == 1 then
                        local ah = (ad.Position - ag.Position).Magnitude

                        if ah <= 5 then
                            firetouchinterest(ad, ag, 0)
                            firetouchinterest(ad, ag, 1)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        c.Heartbeat:Wait()

        if h and not n and a:GetAttribute('Alive') == true and a.Character and a.Character:FindFirstChild('HumanoidRootPart') then
            local ad = returncoincontainer()

            if ad then
                local ae, af = FindNearestCoin(ad, randomCoinSelection)

                if ae and ae.Transparency == 1 and not n then
                    if not l then
                        startFarming()
                    end

                    local ag, ah = a.Character.HumanoidRootPart, a.Character:FindFirstChild('Humanoid')

                    ag.Velocity = Vector3.new(0, 0, 0)
                    ag.RotVelocity = Vector3.new(0, 0, 0)

                    -- Случайное смещение
                    local offset = Vector3.new()
                    if randomMovement then
                        offset = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
                    end

                    local ai = ae.Position - Vector3.new(0, 2.5, 0) + offset
                    local targetCF = CFrame.new(ai) * CFrame.Angles(math.rad(90), 0, 0)

                    enableNoclip()

                    -- Случайная длительность
                    local duration = (af / 23) * (randomMovement and (0.8 + math.random() * 0.4) or 1)
                    local W = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                    j = d:Create(ag, W, {CFrame = targetCF})
                    j:Play()

                    local X
                    X = c.Heartbeat:Connect(function()
                        if h and a:GetAttribute('Alive') == true and ag then
                            ag.Velocity = Vector3.new(0, 0, 0)
                            ag.RotVelocity = Vector3.new(0, 0, 0)

                            if ah then
                                ah.PlatformStand = true
                            end
                        else
                            if X then
                                X:Disconnect()
                            end
                        end
                    end)

                    while ae and ae:FindFirstChild('TouchInterest') and ae.Transparency == 1 and not n and h and a:GetAttribute('Alive') == true do
                        c.Heartbeat:Wait()
                    end

                    if X then
                        X:Disconnect()
                    end
                    if j then
                        j:Cancel()
                    end
                    if ag then
                        ag.Velocity = Vector3.new(0, 0, 0)
                        ag.RotVelocity = Vector3.new(0, 0, 0)
                    end

                    -- Случайная задержка после сбора
                    if randomDelays then
                        task.wait(minDelay + math.random() * (maxDelay - minDelay))
                    end
                else
                    if l then
                        stopFarming()
                    end
                end
            else
                if l then
                    stopFarming()
                end
            end
        else
            if l then
                stopFarming()
            end
        end
    end
end)

task.spawn(function()
    while true do
        c.Heartbeat:Wait()
        UpdateESP()
        getgun()
    end
end)

N.PlayerAdded:Connect(function(ad)
    ad.CharacterAdded:Connect(function()
        UpdateESP()
    end)
end)

-- ===== РЕЖИМ UNDERMAP =====
local function goUnderMap()
    if not a.Character then return end
    local root = a.Character:FindFirstChild('HumanoidRootPart')
    if not root then return end
    
    oldFallenHeight = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = -1/0
    
    local map = findmap()
    local underY = -500
    if map and map:FindFirstChild('Spawns') then
        local total = Vector3.new()
        local count = 0
        for _, spawn in pairs(map.Spawns:GetChildren()) do
            if spawn:IsA('BasePart') then
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
    
    for _, part in pairs(a.Character:GetDescendants()) do
        if part:IsA('BasePart') then
            part.CanCollide = false
        end
    end
    
    local bodyVel = Instance.new('BodyVelocity')
    bodyVel.Parent = root
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    underMapConnection = game:GetService('RunService').Heartbeat:Connect(function()
        if not underMapActive or not a.Character or not root then
            if bodyVel then bodyVel:Destroy() end
            if underMapConnection then underMapConnection:Disconnect() end
            return
        end
        if (root.Position - targetCF.p).Magnitude > 5 then
            root.CFrame = targetCF
        end
        root.Velocity = Vector3.new(0, 0, 0)
        root.RotVelocity = Vector3.new(0, 0, 0)
    end)
end

local function returnFromUnderMap()
    if underMapConnection then
        underMapConnection:Disconnect()
        underMapConnection = nil
    end
    workspace.FallenPartsDestroyHeight = oldFallenHeight
    if a.Character then
        local root = a.Character:FindFirstChild('HumanoidRootPart')
        if root then
            local bv = root:FindFirstChildOfClass('BodyVelocity')
            if bv then bv:Destroy() end
        end
        local map = findmap()
        if map and map:FindFirstChild('Spawns') then
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 then
                local spawn = spawns[math.random(1, #spawns)]
                if spawn:IsA('BasePart') then
                    a.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
end

t:AddToggle({
    Title = 'UnderMap Mode',
    Description = 'Teleports you under the map, making you invincible',
    Default = false,
    Tab = E,
    Callback = function(val)
        underMapActive = val
        if val then
            pcall(goUnderMap)
            t:Notify({
                Title = 'UnderMap Activated',
                Description = 'You are now below the map!',
                Duration = 3,
            })
        else
            pcall(returnFromUnderMap)
            t:Notify({
                Title = 'UnderMap Deactivated',
                Description = 'Returned to the map!',
                Duration = 3,
            })
        end
    end,
})

q.InputBegan:Connect(function(ad)
    if ad == Keybind then
    end
end)
