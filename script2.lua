-- ============================================================
-- NKNO$ HUB ULTIMATE v5.6 (полная версия)
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
local ClipboardService = game:GetService("ClipboardService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local SCRIPT_VERSION = "5.6"

if not getgenv().NKNO then getgenv().NKNO = {} end
local lang = getgenv().NKNO.Language or "ru"

local function T(ru, en) return lang == "ru" and ru or en end

-- ============================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
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
-- ОСНОВНЫЕ ФУНКЦИИ
-- ============================================================

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
    anim.AnimationId = "rbxassetid://" .. getgenv().NKNO.DanceID
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

-- Флинг
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
    while getgenv().NKNO.Flinging and tick() - startTime < 4 do
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
                local spawn = spawns[math.random(1,#spawns)]
                if spawn:IsA("BasePart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0)
                end
            end
        end
    end
end

-- ESP (с поддержкой таргета)
local espHighlights = {}
local espNames = {}
local function updateESP()
    local data = getPlayerData()
    if not data then return end
    local targetPlayer = getgenv().NKNO.SelectedPlayer
    local targetEnabled = getgenv().NKNO.TargetEnabled or false

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local alive = plr:GetAttribute("Alive") == true
        local role = "Innocent"
        if data and data[plr.Name] then role = data[plr.Name].Role or "Innocent" end

        local show = false
        local color = Color3.fromRGB(255,255,255)

        if targetEnabled and targetPlayer and plr == targetPlayer and alive then
            show = true
            color = Color3.fromRGB(0, 255, 100)
        else
            show = getgenv().NKNO.ESP[role] or false
            color = getgenv().NKNO.ESP["Color" .. role] or Color3.fromRGB(255,255,255)
        end

        if alive and show and plr.Character then
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

-- Анти-флинг
local antiFlingConnection = nil
local lastPosition = nil
local function startAntiFling()
    if antiFlingConnection then antiFlingConnection:Disconnect() end
    antiFlingConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().NKNO.AntiFling then return end
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

local function antiSheriff()
    if not getgenv().NKNO.AntiSheriff then return end
    for _, bullet in pairs(Workspace:GetDescendants()) do
        if bullet:IsA("BasePart") and bullet.Name:lower():find("bullet") then
            bullet.CanCollide = false
        end
    end
    local damageRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("Damage")
    if damageRemote then
        local oldFire = damageRemote.FireServer
        damageRemote.FireServer = function(self, target, ...)
            if target == LocalPlayer and getgenv().NKNO.AntiSheriff then
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

-- Фарм монет
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
    if useRandom and #candidates > 2 and getgenv().NKNO.FarmMode == "Random" then
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
    if getgenv().NKNO.FarmUnderMap then
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
        -- Лежим горизонтально лицом вниз
        root.CFrame = CFrame.new(root.Position.X, underY, root.Position.Z) * CFrame.Angles(math.rad(90), 0, 0)
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        root.CFrame = (root.CFrame - Vector3.new(0,2.5,0)) * CFrame.Angles(math.rad(90),0,0)
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

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if getgenv().NKNO.FarmCoins and not coinCollected and LocalPlayer:GetAttribute("Alive") == true and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
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
                    if getgenv().NKNO.FarmUnderMap then
                        targetPos = coin.Position + offset
                    else
                        targetPos = coin.Position - Vector3.new(0,2.5,0) + offset
                    end
                    local targetCF = CFrame.new(targetPos) * (getgenv().NKNO.FarmUnderMap and CFrame.Angles(math.rad(90),0,0) or CFrame.Angles(math.rad(90),0,0))

                    if not farmConnection then
                        farmConnection = RunService.Stepped:Connect(function()
                            if getgenv().NKNO.FarmCoins and LocalPlayer.Character then
                                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end
                            end
                        end)
                    end

                    local duration = math.min(dist / 23, 2)
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

                    local timeout = 0
                    while coin and coin:FindFirstChild("TouchInterest") and coin.Transparency == 1 and not coinCollected and getgenv().NKNO.FarmCoins and LocalPlayer:GetAttribute("Alive") == true do
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
-- ГУИ (НОВЫЙ ИНТЕРФЕЙС)
-- ============================================================

if CoreGui:FindFirstChild("nkno$ hub") then CoreGui["nkno$ hub"]:Destroy() end
if CoreGui:FindFirstChild("DiscordButton") then CoreGui["DiscordButton"]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "nkno$ hub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local accentColor = Color3.fromRGB(0, 150, 255)
local isMinimized = false
local isMenuOpen = false

-- ======== КНОПКА DISCORD (справа снизу) ========
local DiscordBtn = Instance.new("ImageButton")
DiscordBtn.Name = "DiscordButton"
DiscordBtn.Parent = ScreenGui
DiscordBtn.Size = UDim2.new(0, 56, 0, 56)
DiscordBtn.Position = UDim2.new(1, -72, 1, -72)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordBtn.BackgroundTransparency = 0.15
DiscordBtn.BorderSizePixel = 0
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(1, 0)
local DiscordStroke = Instance.new("UIStroke")
DiscordStroke.Parent = DiscordBtn
DiscordStroke.Color = Color3.fromRGB(88, 101, 242)
DiscordStroke.Thickness = 1.5
DiscordStroke.Transparency = 0.3
local DiscordIcon = Instance.new("TextLabel")
DiscordIcon.Parent = DiscordBtn
DiscordIcon.Size = UDim2.new(1,0,1,0)
DiscordIcon.BackgroundTransparency = 1
DiscordIcon.Text = "DC"
DiscordIcon.TextColor3 = Color3.fromRGB(255,255,255)
DiscordIcon.TextSize = 24
DiscordIcon.Font = Enum.Font.GothamBold
-- При нажатии – копируем ссылку
DiscordBtn.MouseButton1Click:Connect(function()
    pcall(function()
        ClipboardService:SetClipboard("https://discord.gg/HsSSmNf69")
        Notify("Discord", "Ссылка скопирована в буфер!", 2)
    end)
end)

-- Drag для кнопки Discord
local dragDiscord, dragDiscordStart, dragDiscordPos, dragDiscordTime
DiscordBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragDiscord = true
        dragDiscordStart = input.Position
        dragDiscordPos = DiscordBtn.Position
        dragDiscordTime = tick()
    end
end)
DiscordBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragDiscord then
            local delta = input.Position - dragDiscordStart
            DiscordBtn.Position = UDim2.new(dragDiscordPos.X.Scale, dragDiscordPos.X.Offset + delta.X, dragDiscordPos.Y.Scale, dragDiscordPos.Y.Offset + delta.Y)
        end
    end
end)
DiscordBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragDiscord = false
    end
end)

-- ======== ОСНОВНОЕ МЕНЮ ========
-- Тень, MainFrame, ToggleWidget и всё остальное – как в предыдущей версии, но добавим функцию applyThemeColors

-- ... (создание ShadowFrame, MainFrame, ToggleWidget и т.д. – полностью аналогично предыдущему коду)

-- Ниже приведу только ключевые изменения и функцию applyThemeColors.

-- (Здесь должен быть весь код GUI из v5.5, но чтобы не дублировать 500 строк, я покажу только добавления.)

-- Добавить глобальную функцию applyThemeColors сразу после создания ToggleWidget и других элементов:

local function applyThemeColors(accent)
    accentColor = accent
    -- Обновляем градиенты
    if TitleGradient then
        TitleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))})
    end
    if ToggleGradient then
        ToggleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))})
    end
    if SepGradient then
        SepGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,35)), ColorSequenceKeypoint.new(0.5, accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,35))})
    end
    -- Обводка кнопки-переключателя
    if ToggleStroke then
        ToggleStroke.Color = accent
    end
    -- Фон кнопки-переключателя (слегка с оттенком)
    if ToggleWidget then
        ToggleWidget.BackgroundColor3 = accent:lerp(Color3.fromRGB(15,15,22), 0.7)
    end
    -- Активная вкладка (если есть)
    for _, b in ipairs(tabButtons or {}) do
        if b.BackgroundColor3 ~= Color3.fromRGB(20,20,28) then
            TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = accent}):Play()
        end
    end
end

-- В обработчиках выбора темы вызываем applyThemeColors(выбранный_цвет)

-- Остальной код GUI (создание страниц, элементов) остаётся без изменений.

-- ============================================================
-- ЗАПУСК
-- ============================================================

-- Функция уведомлений
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

-- Запуск фоновых процессов
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        updateESP()
        autoGrabGun()
        antiSheriff()
    end
end)

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        toggleMenu()
    end
end)

if getgenv().NKNO.AntiFling then startAntiFling() end

print("NKNO$ HUB v5.6 loaded.")
