-- NKNO$ HUB ULTIMATE v5.4 FINAL (исправлен + скорость фарма)
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

-- === ИНИЦИАЛИЗАЦИЯ ВСЕХ НАСТРОЕК ПО УМОЛЧАНИЮ ===
if not getgenv().NKNO then getgenv().NKNO = {} end
local NKNO = getgenv().NKNO

NKNO.Language = NKNO.Language or "ru"
NKNO.FarmCoins = NKNO.FarmCoins or false
NKNO.FarmUnderMap = NKNO.FarmUnderMap or false
NKNO.FarmMode = NKNO.FarmMode or "Nearest"
NKNO.FarmSpeed = NKNO.FarmSpeed or 23          -- базовая скорость (чем выше, тем быстрее)
NKNO.AutoGrabGun = NKNO.AutoGrabGun or false
NKNO.ESP = NKNO.ESP or {}
NKNO.ESP.Murderer = NKNO.ESP.Murderer or false
NKNO.ESP.Sheriff = NKNO.ESP.Sheriff or false
NKNO.ESP.Innocent = NKNO.ESP.Innocent or false
NKNO.ESP.Hero = NKNO.ESP.Hero or false
NKNO.ESP.Box2D = NKNO.ESP.Box2D or false
NKNO.ESP.DisplayName = NKNO.ESP.DisplayName or false
NKNO.ESP.NormalName = NKNO.ESP.NormalName or true
NKNO.ESP.FontSize = NKNO.ESP.FontSize or 14
NKNO.ForceFieldMaterial = NKNO.ForceFieldMaterial or false
NKNO.CustomFOV = NKNO.CustomFOV or false
NKNO.FOVValue = NKNO.FOVValue or 70
NKNO.GodMode = NKNO.GodMode or false
NKNO.AntiFling = NKNO.AntiFling or false
NKNO.AntiSheriff = NKNO.AntiSheriff or false
NKNO.UnderMap = NKNO.UnderMap or false
NKNO.AutoRespawn = NKNO.AutoRespawn or false
NKNO.CustomWalkSpeed = NKNO.CustomWalkSpeed or false
NKNO.WalkSpeedValue = NKNO.WalkSpeedValue or 16
NKNO.CustomJumpPower = NKNO.CustomJumpPower or false
NKNO.JumpPowerValue = NKNO.JumpPowerValue or 50
NKNO.AntiAFK = NKNO.AntiAFK or false
NKNO.ScamTrade = NKNO.ScamTrade or false
NKNO.ScamTarget = NKNO.ScamTarget or nil
NKNO.SelectedPlayer = NKNO.SelectedPlayer or nil
NKNO.SelectedPlayerName = NKNO.SelectedPlayerName or ""
NKNO.Flinging = NKNO.Flinging or false
NKNO.DanceID = NKNO.DanceID or "507771464"

local lang = NKNO.Language

local function T(ru, en) return lang == "ru" and ru or en end

-- ============================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (улучшенные)
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
    if success and data then return data end
    return nil
end

local function getPing()
    return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end

local function findMurderer()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
            local role = plr:GetAttribute("Role")
            if role == "Murderer" then return plr end
        end
    end
    return nil
end

local function findSheriff()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:GetAttribute("Alive") == true then
            local role = plr:GetAttribute("Role")
            if role == "Sheriff" then return plr end
        end
    end
    return nil
end

-- ============================================================
-- ОСНОВНЫЕ ФУНКЦИИ (с исправлениями)
-- ============================================================

local function applyWalkSpeed()
    if NKNO.CustomWalkSpeed and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = NKNO.WalkSpeedValue end
    end
end
local function applyJumpPower()
    if NKNO.CustomJumpPower and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = NKNO.JumpPowerValue end
    end
end
local function applyFOV()
    if NKNO.CustomFOV and Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = NKNO.FOVValue
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

-- Танцы
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
    anim.AnimationId = "rbxassetid://" .. NKNO.DanceID
    pcall(function()
        danceAnim = animator:LoadAnimation(anim)
        danceAnim.Looped = true
        danceAnim.Priority = Enum.AnimationPriority.Action
        danceAnim:Play(0.1,1,1)
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

-- Флинг (агрессивный) с защитой от ошибок
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
    if not targetRoot then return end
    if targetHum and targetHum.Sit then return end

    Workspace.FallenPartsDestroyHeight = 0/0
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.P = 9e9
    bv.Parent = root

    local startTime = tick()
    while NKNO.Flinging and tick() - startTime < 4 do
        local targetPos = targetRoot.Position
        local dir = (targetPos - root.Position).Unit
        for i = 1, 10 do
            local offset = Vector3.new(math.random(-20,20), math.random(5,30), math.random(-20,20))
            root.CFrame = CFrame.new(targetPos + offset)
            root.Velocity = dir * 9e7 + Vector3.new(0, 5e6, 0)
            bv.Velocity = dir * 9e7 + Vector3.new(0, 5e6, 0)
            task.wait(0.01)
        end
        for i = 1, 5 do
            root.CFrame = CFrame.new(targetPos + dir * (5 + i*2))
            root.Velocity = dir * 9e7
            bv.Velocity = dir * 9e7
            task.wait(0.01)
        end
        task.wait()
    end

    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Workspace.FallenPartsDestroyHeight = getgenv().FPDH or Workspace.FallenPartsDestroyHeight
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    root.Velocity = Vector3.new(0,0,0)
    root.RotVelocity = Vector3.new(0,0,0)
end

-- Подкарта
local underMapConnection = nil
local oldFallenHeight = Workspace.FallenPartsDestroyHeight
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
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    underMapConnection = RunService.Heartbeat:Connect(function()
        if not NKNO.UnderMap or not LocalPlayer.Character or not root then
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
                local spawn = spawns[math.random(1,#spawns)]
                if spawn:IsA("BasePart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0)
                end
            end
        end
    end
end

-- ESP (исправлен)
local espHighlights = {}
local espNames = {}
local function updateESP()
    pcall(function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            local alive = plr:GetAttribute("Alive") == true
            local role = plr:GetAttribute("Role") or "Innocent"
            local show = NKNO.ESP[role] or false
            local color = Color3.fromRGB(255,255,255)
            if role == "Murderer" then color = Color3.fromRGB(255,0,0)
            elseif role == "Sheriff" then color = Color3.fromRGB(0,0,255)
            elseif role == "Hero" then color = Color3.fromRGB(0,255,0)
            else color = Color3.fromRGB(255,255,255) end

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

                -- Имя
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local gui = espNames[plr]
                    if not gui then
                        gui = Instance.new("BillboardGui")
                        gui.Name = "NKNO_Name"
                        gui.AlwaysOnTop = true
                        gui.Size = UDim2.new(0,200,0,50)
                        gui.StudsOffset = Vector3.new(0,2.5,0)
                        gui.Parent = head
                        local label = Instance.new("TextLabel")
                        label.Name = "Label"
                        label.Size = UDim2.new(1,0,1,0)
                        label.BackgroundTransparency = 1
                        label.Text = ""
                        label.TextColor3 = color
                        label.TextSize = NKNO.ESP.FontSize or 14
                        label.Font = Enum.Font.GothamBold
                        label.TextStrokeTransparency = 0.3
                        label.TextStrokeColor3 = Color3.new(0,0,0)
                        label.Parent = gui
                        espNames[plr] = gui
                    end
                    local label = gui:FindFirstChild("Label")
                    if label then
                        local name = NKNO.ESP.DisplayName and plr.DisplayName or (NKNO.ESP.NormalName and plr.Name or "")
                        label.Text = name
                        label.TextColor3 = color
                    end
                    -- Box2D
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root and NKNO.ESP.Box2D then
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
    end)
end

-- Авто-граб пистолета
local function autoGrabGun()
    pcall(function()
        if not NKNO.AutoGrabGun then return end
        if not LocalPlayer:GetAttribute("Alive") then return end
        local map = findMap()
        if not map then return end
        local gunDrop = map:FindFirstChild("GunDrop")
        if gunDrop then
            gunDrop.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end)
end

-- Анти-флинг
local antiFlingConnection = nil
local lastPosition = nil
local function startAntiFling()
    if antiFlingConnection then antiFlingConnection:Disconnect() end
    antiFlingConnection = RunService.Heartbeat:Connect(function()
        if not NKNO.AntiFling then return end
        if not LocalPlayer.Character then return end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        if lastPosition then
            local dist = (root.Position - lastPosition).Magnitude
            if dist > 10 then
                root.Velocity = Vector3.new(0,0,0)
                root.RotVelocity = Vector3.new(0,0,0)
                root.CFrame = CFrame.new(lastPosition) * root.CFrame.Rotation
                local bp = root:FindFirstChildOfClass("BodyPosition")
                if not bp then
                    bp = Instance.new("BodyPosition")
                    bp.MaxForce = Vector3.new(9e9,9e9,9e9)
                    bp.P = 10000
                    bp.D = 1000
                    bp.Parent = root
                end
                bp.Position = lastPosition
                task.wait(0.1)
                bp:Destroy()
            end
        end
        lastPosition = root.Position
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end
local function stopAntiFling()
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    lastPosition = nil
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Анти-шериф
local function antiSheriff()
    if not NKNO.AntiSheriff then return end
    for _, bullet in pairs(Workspace:GetDescendants()) do
        if bullet:IsA("BasePart") and bullet.Name:lower():find("bullet") then
            bullet.CanCollide = false
        end
    end
    local damageRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("Damage")
    if damageRemote then
        local oldFire = damageRemote.FireServer
        damageRemote.FireServer = function(self, target, ...)
            if target == LocalPlayer and NKNO.AntiSheriff then
                return
            end
            return oldFire(self, target, ...)
        end
    end
end

-- Scam Trade
local scamActive = false
local scamTarget = nil
local scamConnection = nil
local function startScamTrade(target)
    scamTarget = target
    scamActive = true
    if scamConnection then scamConnection:Disconnect() end
    scamConnection = LocalPlayer.Character.ChildRemoved:Connect(function(child)
        if not scamActive then return end
        if not scamTarget or not scamTarget.Character then return end
        if child:IsA("Tool") and child.Parent == LocalPlayer.Character then
            task.wait(0.1)
            local clone = child:Clone()
            clone.Parent = scamTarget.Character
            child.Parent = LocalPlayer.Character
        end
    end)
end
local function stopScamTrade()
    scamActive = false
    scamTarget = nil
    if scamConnection then scamConnection:Disconnect() scamConnection = nil end
end

-- Add Weapons
local function spawnWeapon(weaponId)
    if not weaponId or weaponId == "" then return end
    local model = nil
    local function findModel(id)
        for _, item in pairs(ReplicatedStorage:GetDescendants()) do
            if item:IsA("Model") and item:FindFirstChild("Handle") then
                if item.Name:lower():find(id:lower()) or item:GetAttribute("WeaponID") == id then
                    return item
                end
            end
        end
        for _, item in pairs(Workspace:GetDescendants()) do
            if item:IsA("Model") and item:FindFirstChild("Handle") then
                if item.Name:lower():find(id:lower()) or item:GetAttribute("WeaponID") == id then
                    return item
                end
            end
        end
        return nil
    end
    model = findModel(weaponId)
    if not model then
        local idNum = tonumber(weaponId)
        if idNum then
            local success, result = pcall(function()
                return game:GetService("InsertService"):LoadAsset(idNum)
            end)
            if success and result then model = result end
        end
    end
    if model then
        local clone = model:Clone()
        clone.Parent = LocalPlayer.Character or LocalPlayer.Backpack
        clone:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame)
    end
end

-- ============================================================
-- ФАРМ МОНЕТ (с регулировкой скорости)
-- ============================================================
local farming = false
local farmTween = nil
local farmConnection = nil
local savedCollision = {}
local underMapModeForFarm = false

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
    if useRandom and #candidates > 2 and NKNO.FarmMode == "Random" then
        local idx = math.random(1, math.min(3, #candidates))
        return candidates[idx].coin, candidates[idx].dist
    else
        return candidates[1].coin, candidates[1].dist
    end
end

local function startFarming()
    if farming then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if LocalPlayer:GetAttribute("Alive") ~= true then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    savedCollision = {}
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            savedCollision[part] = { CanCollide = part.CanCollide, Massless = part.Massless }
        end
    end
    if NKNO.FarmUnderMap then
        underMapModeForFarm = true
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
        root.CFrame = CFrame.new(root.Position.X, underY, root.Position.Z)
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        root.CFrame = root.CFrame - Vector3.new(0,2.5,0)
        root.CFrame = root.CFrame * CFrame.Angles(math.rad(90),0,0)
    end
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
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if root then
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
            if underMapModeForFarm then
                Workspace.FallenPartsDestroyHeight = oldFallenHeight
                local map = findMap()
                if map and map:FindFirstChild("Spawns") then
                    local spawns = map.Spawns:GetChildren()
                    if #spawns > 0 then
                        local spawn = spawns[math.random(1,#spawns)]
                        if spawn:IsA("BasePart") then
                            root.CFrame = spawn.CFrame + Vector3.new(0,5,0)
                        end
                    end
                end
                underMapModeForFarm = false
            else
                root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90),0,0)
                root.CFrame = root.CFrame + Vector3.new(0,2.5,0)
            end
        end
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
    savedCollision = {}
end

-- Предупреждение о высокой скорости фарма
local function warnHighSpeed()
    if NKNO.FarmSpeed > 40 then
        Notify("⚠️ Внимание!", T("Высокая скорость фарма может вызвать кик античита. Рекомендуем ≤ 40.", "High farm speed may trigger anti-cheat kick. Recommend ≤ 40."), 5)
    end
end

coinCollectedRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("CoinCollected")
if coinCollectedRemote then
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
end

local roundStartRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("RoundStart")
local roundEndRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("RoundEndFade")
if roundStartRemote then
    roundStartRemote.OnClientEvent:Connect(function() coinCollected = false end)
end
if roundEndRemote then
    roundEndRemote.OnClientEvent:Connect(function()
        coinCollected = false
        if farming then stopFarming() end
    end)
end

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if NKNO.FarmCoins and not coinCollected and LocalPlayer:GetAttribute("Alive") == true and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local container = getCoinContainer()
            if container then
                local coin, dist = findNearestCoin(container, true)
                if coin and coin.Transparency == 1 and not coinCollected then
                    if not farming then startFarming() end
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    root.Velocity = Vector3.new(0,0,0)
                    root.RotVelocity = Vector3.new(0,0,0)
                    local offset = Vector3.new()
                    local targetPos
                    if NKNO.FarmUnderMap then
                        targetPos = coin.Position + offset
                    else
                        targetPos = coin.Position - Vector3.new(0,2.5,0) + offset
                    end
                    local targetCF = CFrame.new(targetPos) * (NKNO.FarmUnderMap and CFrame.new() or CFrame.Angles(math.rad(90),0,0))

                    if not farmConnection then
                        farmConnection = RunService.Stepped:Connect(function()
                            if NKNO.FarmCoins and LocalPlayer.Character then
                                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end
                            end
                        end)
                    end

                    -- Используем настраиваемую скорость
                    local speed = NKNO.FarmSpeed or 23
                    local duration = math.min(dist / speed, 2)
                    farmTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
                    farmTween:Play()

                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if NKNO.FarmCoins and LocalPlayer:GetAttribute("Alive") == true and root then
                            root.Velocity = Vector3.new(0,0,0)
                            root.RotVelocity = Vector3.new(0,0,0)
                            if hum then hum.PlatformStand = true end
                        else
                            if conn then conn:Disconnect() end
                        end
                    end)

                    local timeout = 0
                    while coin and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 and not coinCollected and NKNO.FarmCoins and LocalPlayer:GetAttribute("Alive") == true do
                        RunService.Heartbeat:Wait()
                        timeout = timeout + 1
                        if timeout > 200 then break end
                    end

                    if conn then conn:Disconnect() end
                    if farmTween then farmTween:Cancel() farmTween = nil end
                    if root then
                        root.Velocity = Vector3.new(0,0,0)
                        root.RotVelocity = Vector3.new(0,0,0)
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

-- ============================================================
-- НОВЫЙ GUI (УПРОЩЁННЫЙ С ВКЛАДКАМИ) – без изменений
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

-- Кнопка-переключатель
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

-- Drag MainFrame
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

-- Боковая панель
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
ContentArea.Size = UDim2.new(1,-200,1,-45)

-- Нижняя панель
local BottomBar = Instance.new("Frame")
BottomBar.Parent = MainFrame
BottomBar.BackgroundColor3 = Color3.fromRGB(15,15,22)
BottomBar.BackgroundTransparency = 0.2
BottomBar.Position = UDim2.new(0,185,1,-40)
BottomBar.Size = UDim2.new(1,-200,0,35)
BottomBar.BorderSizePixel = 0
Instance.new("UICorner", BottomBar).CornerRadius = UDim.new(0,8)

local UserInfoLabel = Instance.new("TextLabel")
UserInfoLabel.Parent = BottomBar
UserInfoLabel.BackgroundTransparency = 1
UserInfoLabel.Size = UDim2.new(0.7,0,1,0)
UserInfoLabel.Font = Enum.Font.Gotham
UserInfoLabel.TextColor3 = Color3.fromRGB(200,200,220)
UserInfoLabel.TextSize = 13
UserInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
UserInfoLabel.Text = ""

local function updateUserInfo()
    local skinName = "Unknown"
    if LocalPlayer.Character then
        for _, child in pairs(LocalPlayer.Character:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("Handle") then
                skinName = child.Name
                break
            end
        end
        if skinName == "Unknown" and LocalPlayer.Character.Name then
            skinName = LocalPlayer.Character.Name
        end
    end
    local displayName = LocalPlayer.DisplayName or LocalPlayer.Name
    UserInfoLabel.Text = string.format("User: %s (%s)  |  Skin: %s", LocalPlayer.Name, displayName, skinName)
end
updateUserInfo()
LocalPlayer.CharacterAdded:Connect(updateUserInfo)
Players.PlayerAdded:Connect(updateUserInfo)

local DiscordBtn = Instance.new("ImageButton")
DiscordBtn.Parent = BottomBar
DiscordBtn.Size = UDim2.new(0,30,0,30)
DiscordBtn.Position = UDim2.new(1,-35,0.5,-15)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88,101,242)
DiscordBtn.BackgroundTransparency = 0.2
DiscordBtn.BorderSizePixel = 0
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(1,0)
local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Parent = DiscordBtn
DiscordLabel.Size = UDim2.new(1,0,1,0)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "DC"
DiscordLabel.TextColor3 = Color3.fromRGB(255,255,255)
DiscordLabel.TextSize = 16
DiscordLabel.Font = Enum.Font.GothamBold
DiscordBtn.MouseButton1Click:Connect(function()
    GuiService:OpenBrowserWindow("https://discord.gg/vQUM4JapP")
end)

-- ============================================================
-- СТРАНИЦЫ (вкладки) и элементы GUI
-- ============================================================

local pages = {}
local function createPage(name)
    local page = Instance.new("Frame")
    page.Parent = ContentArea
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    pages[name] = page
    return page
end

local AutoFarmPage = createPage("AutoFarm")
local VisualsPage = createPage("Visuals")
local TargetPage = createPage("Target")
local FlingPage = createPage("Fling")
local SettingsPage = createPage("Settings")

-- Вспомогательные функции для элементов GUI
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
    local function rebuildOptions(newOptions)
        for _, btn in pairs(optionButtons) do btn:Destroy() end
        optionButtons = {}
        listScrolling.CanvasSize = UDim2.new(0,0,0,#newOptions * 30)
        for _, opt in ipairs(newOptions) do
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
        if #optionButtons > 0 then
            dropdownBtn.Text = newOptions[1] or "Нет игроков"
        end
    end

    rebuildOptions(options)

    dropdownBtn.MouseButton1Click:Connect(function()
        listVisible = not listVisible
        listFrame.Visible = listVisible
        if listVisible then
            listFrame.Size = UDim2.new(0.4,0,0,math.min(#optionButtons * 30 + 10, 120))
        end
    end)

    -- Обновление списка при добавлении игроков
    Players.PlayerAdded:Connect(function()
        local newNames = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then table.insert(newNames, plr.Name) end
        end
        if #newNames == 0 then newNames = {"Нет игроков"} end
        rebuildOptions(newNames)
        if not NKNO.SelectedPlayerName or not table.find(newNames, NKNO.SelectedPlayerName) then
            dropdownBtn.Text = newNames[1]
        end
    end)

    return frame
end

-- ============================================================
-- ЗАПОЛНЕНИЕ СТРАНИЦ
-- ============================================================

local function setupPage(page)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = page
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    return scroll, layout
end

-- === Auto Farm ===
local afScroll, afLayout = setupPage(AutoFarmPage)
createSection(afScroll, T("Авто Фарм", "Auto Farm"))
createToggle(afScroll, T("Фарм монет", "Farm Coins"), T("Автосбор монет", "Auto-collect coins"), NKNO.FarmCoins, function(val)
    NKNO.FarmCoins = val
    if not val and farming then stopFarming() end
end)
createToggle(afScroll, T("Фарм под картой", "Farm UnderMap"), T("Сбор под картой", "Farm under map"), NKNO.FarmUnderMap, function(val)
    NKNO.FarmUnderMap = val
end)
createDropdown(afScroll, T("Режим сбора", "Collect Mode"), {"Nearest", "Random"}, NKNO.FarmMode, function(val)
    NKNO.FarmMode = val
end)
-- НОВЫЙ СЛАЙДЕР СКОРОСТИ ФАРМА
createSlider(afScroll, T("Скорость фарма", "Farm Speed"), T("Чем выше, тем быстрее (осторожно, античит)", "Higher = faster (anti-cheat risk)"), 10, 100, NKNO.FarmSpeed, false, function(val)
    NKNO.FarmSpeed = val
    if val > 40 then
        warnHighSpeed()
    end
end)
createSection(afScroll, T("Авто-граб", "Auto Grab"))
createToggle(afScroll, T("Авто-граб пистолета", "Auto Grab Gun"), T("Забрать пистолет, если шериф умер", "Grab gun when sheriff dies"), NKNO.AutoGrabGun, function(val)
    NKNO.AutoGrabGun = val
end)

-- === Visuals ===
local visScroll, visLayout = setupPage(VisualsPage)
createSection(visScroll, T("Визуал", "Visuals"))
createToggle(visScroll, T("ESP убийцы", "Murderer ESP"), "", NKNO.ESP.Murderer, function(val) NKNO.ESP.Murderer = val end)
createToggle(visScroll, T("ESP шерифа", "Sheriff ESP"), "", NKNO.ESP.Sheriff, function(val) NKNO.ESP.Sheriff = val end)
createToggle(visScroll, T("ESP мирных", "Innocent ESP"), "", NKNO.ESP.Innocent, function(val) NKNO.ESP.Innocent = val end)
createToggle(visScroll, T("ESP героя", "Hero ESP"), "", NKNO.ESP.Hero, function(val) NKNO.ESP.Hero = val end)
createToggle(visScroll, T("2D рамка", "2D Box"), T("Рамка вокруг игрока", "Box around player"), NKNO.ESP.Box2D, function(val) NKNO.ESP.Box2D = val end)
createToggle(visScroll, T("Показывать DisplayName", "Display Name"), "", NKNO.ESP.DisplayName, function(val)
    NKNO.ESP.DisplayName = val
    if val then NKNO.ESP.NormalName = false end
end)
createToggle(visScroll, T("Показывать ник", "Normal Name"), "", NKNO.ESP.NormalName, function(val)
    NKNO.ESP.NormalName = val
    if val then NKNO.ESP.DisplayName = false end
end)
createToggle(visScroll, T("ForceField материал", "ForceField Material"), T("Материал ForceField на себе", "ForceField material on self"), NKNO.ForceFieldMaterial, function(val)
    NKNO.ForceFieldMaterial = val
    if val then applyForceField() else restoreMaterial() end
end)
createToggle(visScroll, T("Кастомный FOV", "Custom FOV"), "", NKNO.CustomFOV, function(val)
    NKNO.CustomFOV = val
    applyFOV()
end)
createSlider(visScroll, T("FOV", "FOV"), "", 70, 120, NKNO.FOVValue, false, function(val)
    NKNO.FOVValue = val
    if NKNO.CustomFOV then applyFOV() end
end)

-- Темы
createSection(visScroll, T("Цветовая палитра интерфейса", "Interface Color Palette"))
local themeColors = {
    {Color3.fromRGB(0,150,255), Color3.fromRGB(0,70,200), T("Синий Космос", "Blue Space")},
    {Color3.fromRGB(168,85,247), Color3.fromRGB(100,30,180), T("Фиолетовый Кибер", "Purple Cyber")},
    {Color3.fromRGB(34,197,94), Color3.fromRGB(20,100,50), T("Кислотный Лайм", "Acid Lime")},
    {Color3.fromRGB(236,72,153), Color3.fromRGB(150,20,80), T("Пылкая Роза", "Fiery Rose")},
    {Color3.fromRGB(245,158,11), Color3.fromRGB(160,80,0), T("Янтарный Неон", "Amber Neon")},
    {Color3.fromRGB(220,220,230), Color3.fromRGB(100,100,110), T("Белый Фантом", "White Phantom")},
}
for _, t in ipairs(themeColors) do
    local row = Instance.new("TextButton")
    row.Parent = visScroll
    row.BackgroundColor3 = Color3.fromRGB(16,16,23)
    row.BackgroundTransparency = 0.15
    row.Size = UDim2.new(1,-10,0,40)
    row.Text = ""
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)

    local circle = Instance.new("Frame")
    circle.Parent = row
    circle.Size = UDim2.new(0,22,0,22)
    circle.Position = UDim2.new(0,10,0.5,-11)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, t[1]), ColorSequenceKeypoint.new(1, t[2])})
    grad.Parent = circle

    local text = Instance.new("TextLabel")
    text.Parent = row
    text.BackgroundTransparency = 1
    text.Position = UDim2.new(0,45,0,0)
    text.Size = UDim2.new(1,-55,1,0)
    text.Font = Enum.Font.GothamSemibold
    text.TextColor3 = Color3.fromRGB(190,190,210)
    text.TextSize = 14
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Text = t[3]

    row.MouseButton1Click:Connect(function()
        accentColor = t[1]
        TitleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))})
        ToggleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))})
        SepGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,35)), ColorSequenceKeypoint.new(0.5, accentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,35))})
        for _, b in ipairs(tabButtons) do
            if b.BackgroundColor3 ~= Color3.fromRGB(20,20,28) then
                TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = accentColor}):Play()
            end
        end
    end)
end

-- === Target ===
local targetScroll, targetLayout = setupPage(TargetPage)
createSection(targetScroll, T("Выбор цели", "Target Selection"))
local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    if #names == 0 then names = {"Нет игроков"} end
    return names
end
local playerOptions = getPlayerNames()
local targetDropdown = createDropdown(targetScroll, T("Выбрать игрока", "Select Player"), playerOptions, NKNO.SelectedPlayerName or playerOptions[1], function(val)
    local plr = Players:FindFirstChild(val)
    if plr then
        NKNO.SelectedPlayer = plr
        NKNO.SelectedPlayerName = val
    else
        NKNO.SelectedPlayer = nil
        NKNO.SelectedPlayerName = nil
    end
end)

-- === Fling ===
local flingScroll, flingLayout = setupPage(FlingPage)
createSection(flingScroll, T("Флинг", "Fling"))
createButton(flingScroll, T("Флинг убийцы", "Fling Murderer"), T("Зафлингует убийцу", "Fling the murderer"), function()
    if NKNO.Flinging then return end
    local m = findMurderer()
    if m then
        NKNO.Flinging = true
        task.spawn(function()
            SkidFling(m)
            NKNO.Flinging = false
        end)
    end
end)
createButton(flingScroll, T("Флинг шерифа", "Fling Sheriff"), T("Зафлингует шерифа", "Fling the sheriff"), function()
    if NKNO.Flinging then return end
    local s = findSheriff()
    if s then
        NKNO.Flinging = true
        task.spawn(function()
            SkidFling(s)
            NKNO.Flinging = false
        end)
    end
end)
createButton(flingScroll, T("Флинг выбранного", "Fling Selected"), T("Флинг выбранного игрока", "Fling selected player"), function()
    if NKNO.Flinging then return end
    local sel = NKNO.SelectedPlayer
    if not sel or not sel.Parent then return end
    NKNO.Flinging = true
    task.spawn(function()
        SkidFling(sel)
        NKNO.Flinging = false
    end)
end)
createButton(flingScroll, T("Остановить флинг", "Stop Fling"), T("Остановить флинг", "Stop fling"), function()
    NKNO.Flinging = false
end)

-- === Settings ===
local setScroll, setLayout = setupPage(SettingsPage)
createSection(setScroll, T("Настройки", "Settings"))
createToggle(setScroll, T("Режим Бога", "God Mode"), T("Отключить коллизии", "Disable collisions"), NKNO.GodMode, function(val)
    NKNO.GodMode = val
    if val then
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)
createToggle(setScroll, T("Анти-флинг (защита)", "Anti-Fling"), T("Защита от флинга", "Anti-fling"), NKNO.AntiFling, function(val)
    NKNO.AntiFling = val
    if val then startAntiFling() else stopAntiFling() end
end)
createToggle(setScroll, T("Anti Sheriff", "Anti Sheriff"), T("Защита от шерифа", "Protection from sheriff"), NKNO.AntiSheriff, function(val)
    NKNO.AntiSheriff = val
    if val then antiSheriff() end
end)
createToggle(setScroll, T("Под картой (ручной)", "UnderMap Mode"), T("Уйти под карту", "Go under map"), NKNO.UnderMap, function(val)
    NKNO.UnderMap = val
    if val then goUnderMap() else returnFromUnderMap() end
end)
createToggle(setScroll, T("Авто-респавн", "Auto Respawn"), T("Респавниться при смерти", "Respawn when dead"), NKNO.AutoRespawn, function(val)
    NKNO.AutoRespawn = val
end)
createSection(setScroll, T("Движение", "Movement"))
createToggle(setScroll, T("Кастомная скорость", "Custom WalkSpeed"), "", NKNO.CustomWalkSpeed, function(val)
    NKNO.CustomWalkSpeed = val
    applyWalkSpeed()
end)
createSlider(setScroll, T("WalkSpeed", "WalkSpeed"), "", 16, 200, NKNO.WalkSpeedValue, false, function(val)
    NKNO.WalkSpeedValue = val
    if NKNO.CustomWalkSpeed then applyWalkSpeed() end
end)
createToggle(setScroll, T("Кастомный прыжок", "Custom JumpPower"), "", NKNO.CustomJumpPower, function(val)
    NKNO.CustomJumpPower = val
    applyJumpPower()
end)
createSlider(setScroll, T("JumpPower", "JumpPower"), "", 50, 200, NKNO.JumpPowerValue, false, function(val)
    NKNO.JumpPowerValue = val
    if NKNO.CustomJumpPower then applyJumpPower() end
end)
createToggle(setScroll, T("Анти-AFK", "Anti-AFK"), T("Движение для избегания кика", "Movement to avoid kick"), NKNO.AntiAFK, function(val)
    NKNO.AntiAFK = val
    if val then
        task.spawn(function()
            while NKNO.AntiAFK and task.wait(math.random(30,60)) do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local hum = LocalPlayer.Character.Humanoid
                    local dir = Vector3.new(math.random(-1,1),0,math.random(-1,1))
                    hum:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + dir * 5)
                end
            end
        end)
    end
end)

createSection(setScroll, T("Scam Trade", "Scam Trade"))
local scamPlayerOptions = getPlayerNames()
createDropdown(setScroll, T("Цель", "Target"), scamPlayerOptions, NKNO.ScamTarget and NKNO.ScamTarget.Name or scamPlayerOptions[1], function(val)
    local plr = Players:FindFirstChild(val)
    if plr then NKNO.ScamTarget = plr end
end)
createButton(setScroll, T("Включить заморозку", "Enable Freeze"), T("При броске оружия копируется цели", "Weapon copies to target"), function()
    if not NKNO.ScamTarget then return end
    startScamTrade(NKNO.ScamTarget)
end)
createButton(setScroll, T("Выключить заморозку", "Disable Freeze"), "", function()
    stopScamTrade()
end)
createToggle(setScroll, T("Активна", "Active"), "", NKNO.ScamTrade, function(val)
    NKNO.ScamTrade = val
    if val then
        if not NKNO.ScamTarget then return end
        startScamTrade(NKNO.ScamTarget)
    else
        stopScamTrade()
    end
end)

createSection(setScroll, T("Add Weapons", "Add Weapons"))
local presetWeapons = {"Knife", "Gun", "Golden Knife", "Sword", "Axe", "Candy Cane", "Laser Gun"}
local selectedWeapon = presetWeapons[1]
createDropdown(setScroll, T("Выберите оружие", "Select Weapon"), presetWeapons, selectedWeapon, function(val)
    selectedWeapon = val
end)
createButton(setScroll, T("Спавн выбранного", "Spawn Selected"), T("Создать оружие в руках", "Spawn in hands"), function()
    spawnWeapon(selectedWeapon)
end)
createButton(setScroll, T("Убить всех", "Kill All"), T("Убить всех мирных (только убийца)", "Kill all innocents (murderer only)"), function()
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
        for name, pageFrame in pairs(pages) do
            pageFrame.Visible = (pageFrame == page)
        end
    end)
    table.insert(tabButtons, btn)
    return btn
end

local tabAutoFarm = createTabButton(T("Auto Farm", "Auto Farm"), AutoFarmPage)
local tabVisuals = createTabButton(T("Visuals", "Visuals"), VisualsPage)
local tabTarget = createTabButton(T("Target", "Target"), TargetPage)
local tabFling = createTabButton(T("Fling", "Fling"), FlingPage)
local tabSettings = createTabButton(T("Settings", "Settings"), SettingsPage)

-- По умолчанию выбрана AutoFarm
tabAutoFarm.BackgroundColor3 = accentColor
tabAutoFarm.TextColor3 = Color3.fromRGB(255,255,255)
AutoFarmPage.Visible = true

-- ============================================================
-- ЗАПУСК И ОБРАБОТЧИКИ
-- ============================================================

-- Обновление ESP в фоне
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
    if NKNO.ForceFieldMaterial then applyForceField() end
    if NKNO.GodMode then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if NKNO.AntiFling then
        stopAntiFling()
        startAntiFling()
    end
    updateUserInfo()
end)

-- Открытие по LeftAlt
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        toggleMenu()
    end
end)

-- Если AntiFling включён при старте
if NKNO.AntiFling then startAntiFling() end

-- Уведомления
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

print("NKNO$ HUB v5.4 FINAL загружен. Все функции активны.")
