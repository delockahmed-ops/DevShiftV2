local MainModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

MainModule.SpeedHack = {
    Enabled = false,
    DefaultSpeed = 16,
    CurrentSpeed = 16,
    MaxSpeed = 150,
    MinSpeed = 16
}

MainModule.Noclip = {
    Enabled = false,
    TransparentParts = {}, -- Для частей, которые мы сделали прозрачными
    OriginalProperties = {}, -- Храним оригинальные свойства
    CheckInterval = 0.05, -- Частая проверка для мгновенного реагирования
    LastCheck = 0,
    SearchRadius = 20, -- Увеличенный радиус поиска
    Connection = nil,
    GroundParts = {}, -- Части, которые являются полом под ногами
    CharacterParts = {}, -- Части персонажа
    FootRayDistance = 5, -- Увеличенная дистанция луча
    FootCheckPoints = 8, -- Количество точек для проверки под ногами
    HeightTolerance = 2 -- Допуск по высоте для определения "под ногами"
}

MainModule.Fly = {
    Enabled = false,
    Speed = 39,
    Connection = nil,
    BodyVelocity = nil,
    IsMobile = UserInputService.TouchEnabled
}

MainModule.AutoNextGameSettings = {
    Enabled = false,
    Connection = nil,
    Timer = 0,
    Cooldown = 2.5, -- Время задержки в секундах между автоматическими запусками
    RemotePath = {
        "ReplicatedStorage",
        "Remotes",
        "TemporaryReachedBindable"
    }
}


MainModule.AutoQTE = {
    AntiStunEnabled = false
}

MainModule.Rebel = {
    Enabled = false,
    Connection = nil,
    LastKillTime = 0,
    KillCooldown = 0.1,
    LastCheckTime = 0,
    CheckCooldown = 0.5
}

MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    LastDamageTime = 0,
    DamageCheckRate = 0.1,
    LastHealth = 100,
    GodModeHeight = 160,
    NormalHeight = 120,
    DamageTeleportPosition = Vector3.new(-903.4, 1184.9, -556),
    StartPosition = Vector3.new(-55.3, 1023.1, -545.8),
    EndPosition = Vector3.new(-214.4, 1023.1, 146.7),
    Connection = nil,
    PocketSandCheck = nil,
    NoPocketSandTimer = 0,
    NoPocketSandCooldown = 3
}

MainModule.Guards = {
    SelectedGuard = "Circle",
    AutoFarm = false,
    RapidFire = false,
    InfiniteAmmo = false,
    HitboxExpander = false,
    OriginalFireRates = {},
    OriginalAmmo = {},
    OriginalHitboxes = {},
    Connections = {}
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

MainModule.GlassBridge = {
    AntiBreakEnabled = false,
    AntiBreakConnection = nil,
    AntiFallEnabled = false,
    GlassPlatforms = {},
    GlassAntiFallPlatform = nil,
    GlassESPEnabled = false,
    GlassESPConnection = nil,
    EndPosition = Vector3.new(-196.372467, 522.192139, -1534.20984),
    BridgeHeight = 520.4,
    PlatformSize = Vector3.new(10000, 1, 10000),
    OriginalColors = {},
    OriginalMaterials = {},
    OriginalTransparency = {}
}

MainModule.TugOfWar = {
    AutoPull = false,
    Connection = nil
}

MainModule.PoleGrab = {
    AutoGrab = false,              -- Включен ли авто-захват столбов
    Connection = nil,              -- Соединение Heartbeat для авто-захвата
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    AntiFallPlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

MainModule.SkySquid = {
    AntiFallPlatform = nil,
    SafePlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

MainModule.SpikesKillFeature = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164",
    SpikesPosition = nil,
    PlatformHeightOffset = 5,
    ReturnDelay = 0.2,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    SafetyCheckConnection = nil,
    OriginalSpikes = {},
    SpikesRemoved = false,
    KnifeCheckConnection = nil,
    LastKnifeCheckTime = 0,
    KnifeCheckCooldown = 0.5,
    HasKnife = false,
    NoKnifeTimer = 0,
    NoKnifeTimeout = 2
}

MainModule.VoidKillFeature = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://107989020363293",
        "rbxassetid://71619354165195"
    },
    ZonePosition = Vector3.new(-95.1, 964.6, 67.6),
    PlatformYOffset = -4,
    PlatformSize = Vector3.new(10, 1, 10),
    ReturnDelay = 1,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    AntiFallEnabled = false,
    AntiFallPlatform = nil,
    AnimationIdsSet = {}
}

MainModule.AntiTimeStop = {
    Enabled = false,
    Connection = nil,
    OriginalProperties = {}
}

MainModule.Hitbox = {
    Size = 150,
    Enabled = false,
    Connection = nil,
    ModifiedParts = {}
}

MainModule.FreeDash = {
    Enabled = false,
    OriginalSprintValue = 4,
    RemoteDestroyed = false
}

MainModule.FreeDashGuards = {
    Enabled = false,
    OriginalSprintValue = 4
}

MainModule.AutoStart = {
    AutoStart = false,     -- Включен ли авто-старт
    Connection = nil,      -- Соединение Heartbeat
}

MainModule.Misc = {
    InstaInteract = false,
    NoCooldownProximity = false,
    ESPEnabled = false,
    ESPPlayers = true,
    ESPHiders = true,
    ESPSeekers = true,
    ESPCandies = false,
    ESPKeys = true,
    ESPDoors = true,
    ESPEscapeDoors = true,
    ESPGuards = true,
    ESPHighlight = true,
    ESPDistance = true,
    ESPNames = true,
    ESPBoxes = true,
    ESPFillTransparency = 0.7,
    ESPOutlineTransparency = 0,
    ESPTextSize = 18,
    BypassRagdollEnabled = false,
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    UnlockDashEnabled = false,
    UnlockPhantomStepEnabled = false,
    LastInjuredNotify = 0,
    LastESPUpdate = 0
}

MainModule.HNS = {
    InfinityStaminaEnabled = false,
    InfinityStaminaConnection = nil
}

MainModule.ESP = {
    Players = {},
    Objects = {},
    Connections = {},
    Folder = nil,
    MainConnection = nil,
    UpdateRate = 0.1
}

for _, id in ipairs(MainModule.VoidKillFeature.AnimationIds) do
    MainModule.VoidKillFeature.AnimationIdsSet[id] = true
end

local speedConnection = nil
local autoFarmConnection = nil
local godModeConnection = nil
local instaInteractConnection = nil
local noCooldownConnection = nil
local antiStunConnection = nil
local rapidFireConnection = nil
local infiniteAmmoConnection = nil
local hitboxConnection = nil
local autoPullConnection = nil
local bypassRagdollConnection = nil

-- Функция для показа уведомлений
local function ShowNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function playerHasKnife(player)
    if not player or not player.Character then return false end
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true, tool
            end
        end
    end
    if player:FindFirstChild("Backpack") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                    return true, tool
                end
            end
        end
    end
    return false, nil
end

local function GetDistance(position1, position2)
    if not position1 or not position2 then return math.huge end
    return (position1 - position2).Magnitude
end

local function IsHider(player)
    if not player then return false end
    return player:GetAttribute("IsHider") == true
end

local function IsSeeker(player)
    if not player then return false end
    return player:GetAttribute("IsHunter") == true
end

local function SafeTeleport(position)
    local character = GetCharacter()
    if not character then return false end
    local rootPart = GetRootPart(character)
    if not rootPart then return false end
    local currentPosition = rootPart.Position
    local currentCFrame = rootPart.CFrame
    local tempPart = Instance.new("Part")
    tempPart.Size = Vector3.new(1, 1, 1)
    tempPart.Transparency = 1
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.Position = currentPosition
    tempPart.Parent = workspace
    Debris:AddItem(tempPart, 0.1)
    local fakeVelocity = Instance.new("BodyVelocity")
    fakeVelocity.Velocity = (position - currentPosition).Unit * 100
    fakeVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    fakeVelocity.Parent = rootPart
    Debris:AddItem(fakeVelocity, 0.1)
    rootPart.CFrame = CFrame.new(position)
    task.delay(0.05, function()
        if fakeVelocity and fakeVelocity.Parent then
            fakeVelocity:Destroy()
        end
    end)
    return true
end

local function GetSafePositionAbove(currentPosition, height)
    local rayOrigin = currentPosition + Vector3.new(0, 5, 0)
    local rayDirection = Vector3.new(0, -1, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = workspace:Raycast(rayOrigin, rayDirection * 100, raycastParams)
    if result and result.Position then
        return result.Position + Vector3.new(0, height, 0)
    else
        return currentPosition + Vector3.new(0, height, 0)
    end
end

local function GetPlayerGun()
    local character = GetCharacter()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    return nil
end

local function GetEnemies()
    local enemies = {}
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then return enemies end
    for _, model in pairs(liveFolder:GetChildren()) do
        if model:IsA("Model") then
            local enemyTag = model:FindFirstChild("Enemy")
            local deadTag = model:FindFirstChild("Dead")
            if enemyTag and not deadTag then
                local isPlayer = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name == model.Name then
                        isPlayer = true
                        break
                    end
                end
                if not isPlayer then
                    table.insert(enemies, model.Name)
                    if #enemies >= 5 then
                        break
                    end
                end
            end
        end
    end
    return enemies
end

local function KillEnemy(enemyName)
    pcall(function()
        local liveFolder = Workspace:FindFirstChild("Live")
        if not liveFolder then return end
        local enemy = liveFolder:FindFirstChild(enemyName)
        if not enemy then return end
        local enemyTag = enemy:FindFirstChild("Enemy")
        local deadTag = enemy:FindFirstChild("Dead")
        if not enemyTag or deadTag then return end
        local gun = GetPlayerGun()
        if not gun then return end
        local args = {
            gun,
            {
                ["ClientRayNormal"] = Vector3.new(-1.1920928955078125e-7, 1.0000001192092896, 0),
                ["FiredGun"] = true,
                ["SecondaryHitTargets"] = {},
                ["ClientRayInstance"] = Workspace:WaitForChild("StairWalkWay"):WaitForChild("Part"),
                ["ClientRayPosition"] = Vector3.new(-220.17489624023438, 183.2957763671875, 301.07257080078125),
                ["bulletCF"] = CFrame.new(-220.5039825439453, 185.22506713867188, 302.133544921875, 0.9551116228103638, 0.2567310333251953, -0.14782091975212097, 7.450581485102248e-9, 0.4989798665046692, 0.8666135668754578, 0.2962462604045868, -0.8277127146720886, 0.4765814542770386),
                ["HitTargets"] = {
                    [enemyName] = "Head"
                },
                ["bulletSizeC"] = Vector3.new(0.009999999776482582, 0.009999999776482582, 4.452499866485596),
                ["NoMuzzleFX"] = false,
                ["FirePosition"] = Vector3.new(-72.88850402832031, -679.4803466796875, -173.31005859375)
            }
        }
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient")
        remote:FireServer(unpack(args))
    end)
end

MainModule.MingleVoidKill = {
    Enabled = false,
    AnimationId = "rbxassetid://71318091779666",
    OriginalPosition = nil,
    OriginalCFrame = nil,
    Platform = nil,
    AnimationTrack = nil,
    Connections = {},
    PlatformHeight = -100,
    ReturnYOffset = 3,
    PlatformSize = Vector3.new(100, 10, 100),
    PlatformColor = Color3.fromRGB(0, 170, 255),
    IsOnPlatform = false,
    AnimationStartTime = 0
}

-- Функция для создания платформы
local function createSafetyPlatformMingleVoidKill(position)
    if MainModule.MingleVoidKill.Platform then
        MainModule.MingleVoidKill.Platform:Destroy()
        MainModule.MingleVoidKill.Platform = nil
    end
    
    local platformPosition = Vector3.new(
        position.X,
        position.Y + MainModule.MingleVoidKill.PlatformHeight,
        position.Z
    )
    
    local platform = Instance.new("Part")
    platform.Name = "MingleVoidKillSafetyPlatform"
    platform.Size = MainModule.MingleVoidKill.PlatformSize
    platform.Position = platformPosition
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.7
    platform.Color = MainModule.MingleVoidKill.PlatformColor
    platform.Material = Enum.Material.Neon
    
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 0.5
    pointLight.Range = 50
    pointLight.Color = Color3.fromRGB(0, 200, 255)
    pointLight.Parent = platform
    
    platform.Transparency = 0.8
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = platform
    selectionBox.Color3 = Color3.fromRGB(0, 255, 255)
    selectionBox.LineThickness = 0.05
    selectionBox.Parent = platform
    
    platform.Parent = workspace
    
    MainModule.MingleVoidKill.Platform = platform
    return platform
end

-- Функция телепортации на платформу
local function teleportToPlatformMingleVoidKill(originalPosition)
    local player = game:GetService("Players").LocalPlayer
    if not player or not player.Character then
        return false
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end
    
    -- Сохраняем точную позицию начала анимации
    MainModule.MingleVoidKill.OriginalPosition = originalPosition
    MainModule.MingleVoidKill.OriginalCFrame = CFrame.new(originalPosition)
    
    local platform = createSafetyPlatformMingleVoidKill(originalPosition)
    
    local teleportPosition = Vector3.new(
        platform.Position.X,
        platform.Position.Y + MainModule.MingleVoidKill.ReturnYOffset,
        platform.Position.Z
    )
    
    humanoidRootPart.CFrame = CFrame.new(teleportPosition)
    MainModule.MingleVoidKill.IsOnPlatform = true
    MainModule.MingleVoidKill.AnimationStartTime = tick()
    
    return true
end

-- Функция возврата на исходную позицию
local function returnToOriginalPositionMingleVoidKill()
    local player = game:GetService("Players").LocalPlayer
    if not player or not player.Character then
        return false
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end
    
    if MainModule.MingleVoidKill.OriginalPosition then
        -- Возвращаемся точно на позицию начала анимации + небольшой offset вверх
        local returnPosition = Vector3.new(
            MainModule.MingleVoidKill.OriginalPosition.X,
            MainModule.MingleVoidKill.OriginalPosition.Y + MainModule.MingleVoidKill.ReturnYOffset,
            MainModule.MingleVoidKill.OriginalPosition.Z
        )
        
        humanoidRootPart.CFrame = CFrame.new(returnPosition)
    end
    
    MainModule.MingleVoidKill.IsOnPlatform = false
    
    if MainModule.MingleVoidKill.Platform then
        MainModule.MingleVoidKill.Platform:Destroy()
        MainModule.MingleVoidKill.Platform = nil
    end
    
    MainModule.MingleVoidKill.OriginalPosition = nil
    MainModule.MingleVoidKill.OriginalCFrame = nil
    MainModule.MingleVoidKill.AnimationTrack = nil
    
    return true
end

-- Обработчик анимаций
local function setupAnimationTrackerMingleVoidKill()
    local player = game:GetService("Players").LocalPlayer
    if not player then return end
    
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid", 1)
        if not humanoid then return end
        
        humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.MingleVoidKill.Enabled then return end
            
            local animId = track.Animation and track.Animation.AnimationId
            if animId == MainModule.MingleVoidKill.AnimationId then
                -- Запоминаем позицию В МОМЕНТ начала анимации
                local currentPosition = nil
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    currentPosition = humanoidRootPart.Position
                else
                    currentPosition = character:GetPivot().Position
                end
                
                -- Телепортируем на платформу
                teleportToPlatformMingleVoidKill(currentPosition)
                MainModule.MingleVoidKill.AnimationTrack = track
                
                -- Ждем окончание анимации
                local connection
                connection = game:GetService("RunService").Heartbeat:Connect(function()
                    if not track or not track.IsPlaying then
                        -- Анимация закончилась - возвращаемся
                        returnToOriginalPositionMingleVoidKill()
                        
                        if connection then
                            connection:Disconnect()
                        end
                    end
                end)
                
                table.insert(MainModule.MingleVoidKill.Connections, connection)
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    
    -- Основной мониторинг через Heartbeat
    local heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not MainModule.MingleVoidKill.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        
        -- Проверяем активные анимации
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                if animId == MainModule.MingleVoidKill.AnimationId then
                    
                    if not MainModule.MingleVoidKill.IsOnPlatform then
                        -- Нашли анимацию, но еще не телепортировались
                        local currentPosition = nil
                        if humanoidRootPart then
                            currentPosition = humanoidRootPart.Position
                        else
                            currentPosition = character:GetPivot().Position
                        end
                        
                        teleportToPlatformMingleVoidKill(currentPosition)
                        MainModule.MingleVoidKill.AnimationTrack = track
                    end
                end
            end
        end
        
        -- Проверяем если анимация закончилась и мы на платформе
        if MainModule.MingleVoidKill.AnimationTrack and MainModule.MingleVoidKill.IsOnPlatform then
            local shouldReturn = false
            
            if MainModule.MingleVoidKill.AnimationTrack then
                if not MainModule.MingleVoidKill.AnimationTrack.IsPlaying then
                    shouldReturn = true
                end
            else
                -- Если трек потерян, проверяем по времени (макс 10 секунд)
                if tick() - MainModule.MingleVoidKill.AnimationStartTime > 10 then
                    shouldReturn = true
                end
            end
            
            if shouldReturn then
                returnToOriginalPositionMingleVoidKill()
            end
        end
        
        -- Автоматический возврат если слишком долго на платформе
        if MainModule.MingleVoidKill.IsOnPlatform and tick() - MainModule.MingleVoidKill.AnimationStartTime > 15 then
            returnToOriginalPositionMingleVoidKill()
        end
    end)
    
    table.insert(MainModule.MingleVoidKill.Connections, heartbeatConnection)
end

-- Основная функция включения/выключения
function MainModule.ToggleMingleVoidKill(enabled)
    -- Отключаем все соединения
    MainModule.MingleVoidKill.Enabled = false
    
    for _, conn in pairs(MainModule.MingleVoidKill.Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.MingleVoidKill.Connections = {}
    
    -- Удаляем платформу
    if MainModule.MingleVoidKill.Platform then
        MainModule.MingleVoidKill.Platform:Destroy()
        MainModule.MingleVoidKill.Platform = nil
    end
    
    -- Сбрасываем все данные
    MainModule.MingleVoidKill.OriginalPosition = nil
    MainModule.MingleVoidKill.OriginalCFrame = nil
    MainModule.MingleVoidKill.AnimationTrack = nil
    MainModule.MingleVoidKill.IsOnPlatform = false
    MainModule.MingleVoidKill.AnimationStartTime = 0
    
    if enabled then
        MainModule.MingleVoidKill.Enabled = true
        setupAnimationTrackerMingleVoidKill()
    end
end

-- Инициализация при запуске
task.spawn(function()
    if MainModule.MingleVoidKill.Enabled then
        MainModule.ToggleMingleVoidKill(true)
    end
end)

function MainModule.AutoNextGame(enabled)
    MainModule.AutoNextGameSettings.Enabled = enabled
    
    if enabled then
        ShowNotification("AutoNextGame", "Enabled", 2)
        
        MainModule.AutoNextGameSettings.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoNextGameSettings.Enabled then return end
            
            MainModule.AutoNextGameSettings.Timer = MainModule.AutoNextGameSettings.Timer + task.wait()
            
            if MainModule.AutoNextGameSettings.Timer >= MainModule.AutoNextGameSettings.Cooldown then
                MainModule.AutoNextGameSettings.Timer = 0
                
                pcall(function()
                    local remote = game:GetService(MainModule.AutoNextGameSettings.RemotePath[1])
                        :WaitForChild(MainModule.AutoNextGameSettings.RemotePath[2])
                        :WaitForChild(MainModule.AutoNextGameSettings.RemotePath[3])
                    remote:FireServer()
                end)
            end
        end)
        
    else
        ShowNotification("AutoNextGame", "Disabled", 2)
        
        if MainModule.AutoNextGameSettings.Connection then
            MainModule.AutoNextGameSettings.Connection:Disconnect()
            MainModule.AutoNextGameSettings.Connection = nil
        end
        
        MainModule.AutoNextGameSettings.Timer = 0
    end
end

function MainModule.ToggleAutoGrab(enabled)
    MainModule.PoleGrab.AutoGrab = enabled
    
    if MainModule.PoleGrab.Connection then
        MainModule.PoleGrab.Connection:Disconnect()
        MainModule.PoleGrab.Connection = nil
    end

    if enabled then
        MainModule.PoleGrab.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.PoleGrab.AutoGrab then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local map = workspace:FindFirstChild("SkySquidGamesMap")
            if not map then return end
            
            local poles = {
                map:FindFirstChild("PoleWeapons") and map.PoleWeapons:FindFirstChild("InkPole1") and map.PoleWeapons.InkPole1:FindFirstChild("Pickup Pole"),
                map:FindFirstChild("PoleWeapons") and map.PoleWeapons:FindFirstChild("InkPole2") and map.PoleWeapons.InkPole2:FindFirstChild("Pickup Pole"),
                map:FindFirstChild("PoleWeapons") and map.PoleWeapons:FindFirstChild("InkPole3") and map.PoleWeapons.InkPole3:FindFirstChild("Pickup Pole")
            }

            for _, polePrompt in ipairs(poles) do
                if not MainModule.PoleGrab.AutoGrab then break end
                if polePrompt and polePrompt:IsA("ProximityPrompt") then
                    fireproximityprompt(polePrompt)
                end
            end
        end)
    end
end

function MainModule.ToggleAutoStart(enabled)
    MainModule.AutoStart.AutoStart = enabled
    
    if MainModule.AutoStart.Connection then
        MainModule.AutoStart.Connection:Disconnect()
        MainModule.AutoStart.Connection = nil
    end

    if enabled then
        MainModule.AutoStart.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoStart.AutoStart then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local map = workspace:FindFirstChild("SkySquidGamesMap")
            if not map then return end
            
            local buttons = {
                map:FindFirstChild("PUSHABLEBUTTONS") and map.PUSHABLEBUTTONS:FindFirstChild("Shape1") and map.PUSHABLEBUTTONS.Shape1:FindFirstChild("Start The Game"),
                map:FindFirstChild("PUSHABLEBUTTONS") and map.PUSHABLEBUTTONS:FindFirstChild("Shape2") and map.PUSHABLEBUTTONS.Shape2:FindFirstChild("Start The Game"),
                map:FindFirstChild("PUSHABLEBUTTONS") and map.PUSHABLEBUTTONS:FindFirstChild("Shape3") and map.PUSHABLEBUTTONS.Shape3:FindFirstChild("Start The Game")
            }

            for _, buttonPrompt in ipairs(buttons) do
                if not MainModule.AutoStart.AutoStart then break end
                if buttonPrompt and buttonPrompt:IsA("ProximityPrompt") then
                    fireproximityprompt(buttonPrompt)
                end
            end
        end)
    end
end

function MainModule.ToggleFreeDash(enabled)
    MainModule.FreeDash.Enabled = enabled
    
    if enabled then
        -- БЛОК 1: Защита и блокировка DashRequest через глубокое удаление
        local function DeepRemoveDashRequest()
            -- Инициализация окружения
            local Environment = (getgenv or function() return _G end)()
            local CoreServices = game:GetService("ReplicatedStorage")

            -- Внутренняя процедура обработки объекта
            local function ProcessTargetObject()
                local RemoteContainer = CoreServices:FindFirstChild("Remotes")
                local TargetRemote = RemoteContainer and RemoteContainer:FindFirstChild("DashRequest")
                
                if TargetRemote then
                    -- Метод 1: Изменение метатаблицы
                    if type(setrawmetatable) == "function" then
                        local SecureTable = {
                            __index = function(self, key)
                                if key == "FireServer" or key == "InvokeServer" then
                                    return function() end
                                end
                                return nil
                            end,
                            __newindex = function() end,
                            __call = function() end,
                            __metatable = "Protected"
                        }
                        setrawmetatable(TargetRemote, SecureTable)
                        MainModule.FreeDash.SecureTable = SecureTable
                    end
                    
                    -- Метод 2: Очистка интерфейса
                    local RemoteMethods = {"FireServer", "InvokeServer", "OnClientEvent", "OnClientInvoke"}
                    for _, MethodName in ipairs(RemoteMethods) do
                        pcall(function()
                            local original = TargetRemote[MethodName]
                            if original then
                                MainModule.FreeDash["Original" .. MethodName] = original
                                -- Заменяем метод на пустую функцию
                                if setrawmetatable then
                                    local mt = debug.getmetatable(TargetRemote)
                                    if mt then
                                        local originalIndex = mt.__index
                                        mt.__index = function(self, key)
                                            if key == MethodName then
                                                return function() end
                                            end
                                            return originalIndex(self, key)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    
                    -- Метод 3: Отключение обработчиков через псевдо-событие
                    if type(getconnections) == "function" then
                        local EventHandlers = {"Changed", "AncestryChanged"}
                        for _, EventName in ipairs(EventHandlers) do
                            local EventSignal = TargetRemote[EventName]
                            if EventSignal then
                                for _, Handler in ipairs(getconnections(EventSignal)) do
                                    Handler:Disconnect()
                                end
                            end
                        end
                    end
                    
                    -- Метод 4: Изменение состояния (самый эффективный)
                    pcall(function()
                        TargetRemote.Archivable = false
                        MainModule.FreeDash.OriginalParent = TargetRemote.Parent
                        -- Альтернатива: создаем клон и подменяем
                        local FakeRemote = Instance.new("RemoteEvent")
                        FakeRemote.Name = "DashRequest"
                        for _, descendant in ipairs(TargetRemote:GetChildren()) do
                            descendant:Clone().Parent = FakeRemote
                        end
                        FakeRemote.Parent = TargetRemote.Parent
                        MainModule.FreeDash.OriginalRemote = TargetRemote
                        TargetRemote.Parent = nil
                        MainModule.FreeDash.FakeRemote = FakeRemote
                    end)
                    
                    -- Метод 5: Модификация доступа через rawset
                    if type(getrawmetatable) == "function" then
                        local ObjectMeta = getrawmetatable(TargetRemote)
                        if ObjectMeta then
                            MainModule.FreeDash.OriginalIndex = ObjectMeta.__index
                            MainModule.FreeDash.OriginalNewIndex = ObjectMeta.__newindex
                            
                            ObjectMeta.__index = function(self, Property)
                                if Property == "FireServer" or Property == "InvokeServer" then
                                    return function() end
                                end
                                return MainModule.FreeDash.OriginalIndex(self, Property)
                            end
                            
                            ObjectMeta.__newindex = function(self, Property, Value)
                                if Property == "Parent" and Value == nil then
                                    return -- Блокируем установку Parent в nil
                                end
                                return MainModule.FreeDash.OriginalNewIndex(self, Property, Value)
                            end
                        end
                    end
                end
            end

            -- Выполнение процедуры
            ProcessTargetObject()
            
            -- Защита от восстановления объекта
            local remoteFolder = CoreServices:WaitForChild("Remotes", 1)
            if remoteFolder then
                MainModule.FreeDash.RemoteAddedConnection = remoteFolder.ChildAdded:Connect(function(child)
                    if child.Name == "DashRequest" then
                        task.wait(0.1)
                        pcall(function()
                            if setrawmetatable then
                                local SecureTable = {
                                    __index = function() return function() end end,
                                    __newindex = function() end,
                                    __metatable = "Protected"
                                }
                                setrawmetatable(child, SecureTable)
                            end
                            child.Archivable = false
                            child.Parent = nil
                        end)
                    end
                end)
            end
        end

        -- БЛОК 2: Защита от создания новых DashRequest через ChildAdded
        local function BlockNewDashRequests()
            local CoreServices = game:GetService("ReplicatedStorage")
            local remoteFolder = CoreServices:WaitForChild("Remotes", 1)
            if remoteFolder then
                -- Перехватываем через ChildAdded вместо __newindex
                MainModule.FreeDash.ChildAddedHook = remoteFolder.ChildAdded:Connect(function(child)
                    if child.Name == "DashRequest" then
                        task.spawn(function()
                            task.wait(0.05) -- Небольшая задержка для безопасности
                            pcall(function()
                                -- Быстрая нейтрализация
                                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                                    if setrawmetatable then
                                        local mt = {
                                            __index = function() return function() end end,
                                            __newindex = function() end
                                        }
                                        setrawmetatable(child, mt)
                                    end
                                    child.Archivable = false
                                    child.Parent = nil
                                end
                            end)
                        end)
                    end
                end)
            end
        end

        -- Запускаем блокировку
        DeepRemoveDashRequest()
        BlockNewDashRequests()

        -- БЛОК 3: Установка Faster Sprint в 9 (вместо 5)
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                MainModule.FreeDash.OriginalSprintValue = fasterSprint.Value
                fasterSprint.Value = 8 -- Изменено с 5 на 10
            end
        end
        
        -- БЛОК 4: Дополнительная защита для remote (на всякий случай)
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            remote = remote:FindFirstChild("DashRequest")
            if remote then
                -- Более безопасный способ отключения
                MainModule.FreeDash.RemoteEventConnection = remote:GetPropertyChangedSignal("Parent"):Connect(function()
                    pcall(function()
                        if remote.Parent == nil then
                            -- Автоматическое восстановление FakeRemote
                            if MainModule.FreeDash.FakeRemote then
                                MainModule.FreeDash.FakeRemote.Parent = MainModule.FreeDash.OriginalParent
                            end
                        end
                    end)
                end)
            end
        end
        
    else
        -- ОТКЛЮЧЕНИЕ: Восстанавливаем всё обратно
        
        -- Отключаем все соединения
        if MainModule.FreeDash.RemoteAddedConnection then
            MainModule.FreeDash.RemoteAddedConnection:Disconnect()
            MainModule.FreeDash.RemoteAddedConnection = nil
        end
        
        if MainModule.FreeDash.ChildAddedHook then
            MainModule.FreeDash.ChildAddedHook:Disconnect()
            MainModule.FreeDash.ChildAddedHook = nil
        end
        
        if MainModule.FreeDash.RemoteEventConnection then
            MainModule.FreeDash.RemoteEventConnection:Disconnect()
            MainModule.FreeDash.RemoteEventConnection = nil
        end
        
        -- Восстанавливаем Faster Sprint
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                fasterSprint.Value = MainModule.FreeDash.OriginalSprintValue
            end
        end
        
        -- Восстанавливаем оригинальный Remote
        if MainModule.FreeDash.OriginalRemote and MainModule.FreeDash.OriginalParent then
            pcall(function()
                MainModule.FreeDash.OriginalRemote.Parent = MainModule.FreeDash.OriginalParent
            end)
        end
        
        -- Удаляем FakeRemote
        if MainModule.FreeDash.FakeRemote then
            pcall(function() MainModule.FreeDash.FakeRemote:Destroy() end)
            MainModule.FreeDash.FakeRemote = nil
        end
        
        -- Восстанавливаем метатаблицы
        if MainModule.FreeDash.OriginalIndex then
            local remote = ReplicatedStorage:FindFirstChild("Remotes")
            if remote then
                remote = remote:FindFirstChild("DashRequest")
                if remote and getrawmetatable then
                    local mt = getrawmetatable(remote)
                    if mt then
                        mt.__index = MainModule.FreeDash.OriginalIndex
                        if MainModule.FreeDash.OriginalNewIndex then
                            mt.__newindex = MainModule.FreeDash.OriginalNewIndex
                        end
                    end
                end
            end
        end
        
        -- Восстанавливаем оригинальные методы
        local methods = {"FireServer", "InvokeServer", "OnClientEvent", "OnClientInvoke"}
        for _, method in ipairs(methods) do
            local original = MainModule.FreeDash["Original" .. method]
            if original then
                local remote = ReplicatedStorage:FindFirstChild("Remotes")
                if remote then
                    remote = remote:FindFirstChild("DashRequest")
                    if remote then
                        pcall(function()
                            remote[method] = original
                        end)
                    end
                end
            end
        end
    end
end

function MainModule.ToggleFreeDashGuards(enabled)
    MainModule.FreeDashGuards.Enabled = enabled
    
    if enabled then
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                MainModule.FreeDashGuards.OriginalSprintValue = fasterSprint.Value
                fasterSprint.Value = 5
            end
        end
    else
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                fasterSprint.Value = MainModule.FreeDashGuards.OriginalSprintValue
            end
        end
    end
end

function MainModule.ToggleAntiTimeStop(enabled)
    MainModule.AntiTimeStop.Enabled = enabled
    if MainModule.AntiTimeStop.Connection then
        MainModule.AntiTimeStop.Connection:Disconnect()
        MainModule.AntiTimeStop.Connection = nil
    end
    if enabled then
        MainModule.AntiTimeStop.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.AntiTimeStop.Enabled then return end
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                local humanoid = GetHumanoid(character)
                if not humanoid then return end
                if not MainModule.AntiTimeStop.OriginalProperties[humanoid] then
                    MainModule.AntiTimeStop.OriginalProperties[humanoid] = {
                        WalkSpeed = humanoid.WalkSpeed,
                        JumpPower = humanoid.JumpPower
                    }
                end
                local isFrozen = false
                local frozenEffects = {
                    "TimeStop", "TimeStopEffect", "TimeStopDebuff", "Frozen", "Freeze", 
                    "Stopped", "TimeLock", "TimeFreeze", "ZaWarudo"
                }
                for _, effectName in ipairs(frozenEffects) do
                    local effect = character:FindFirstChild(effectName)
                    if effect then
                        isFrozen = true
                        break
                    end
                end
                if humanoid:GetAttribute("TimeStopped") or 
                   humanoid:GetAttribute("Frozen") or 
                   humanoid:GetAttribute("Stopped") then
                    isFrozen = true
                end
                if isFrozen then
                    humanoid.WalkSpeed = MainModule.AntiTimeStop.OriginalProperties[humanoid].WalkSpeed
                    humanoid.JumpPower = MainModule.AntiTimeStop.OriginalProperties[humanoid].JumpPower
                    for _, effectName in ipairs(frozenEffects) do
                        local effect = character:FindFirstChild(effectName)
                        if effect then
                            effect:Destroy()
                        end
                    end
                    humanoid:SetAttribute("TimeStopped", false)
                    humanoid:SetAttribute("Frozen", false)
                    humanoid:SetAttribute("Stopped", false)
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    humanoid.PlatformStand = false
                end
            end)
        end)
        local character = GetCharacter()
        if character then
            character.ChildAdded:Connect(function(child)
                if not MainModule.AntiTimeStop.Enabled then return end
                if child.Name:find("TimeStop") or child.Name:find("Freeze") then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                end
            end)
        end
    else
        for humanoid, properties in pairs(MainModule.AntiTimeStop.OriginalProperties) do
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = properties.WalkSpeed
                humanoid.JumpPower = properties.JumpPower
            end
        end
        MainModule.AntiTimeStop.OriginalProperties = {}
    end
end

function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    if enabled then
        MainModule.Rebel.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.Rebel.Enabled then return end
            local currentTime = tick()
            if currentTime - MainModule.Rebel.LastCheckTime < MainModule.Rebel.CheckCooldown then return end
            MainModule.Rebel.LastCheckTime = currentTime
            local enemies = GetEnemies()
            if #enemies == 0 then return end
            for _, enemyName in pairs(enemies) do
                if currentTime - MainModule.Rebel.LastKillTime < MainModule.Rebel.KillCooldown then
                    task.wait(MainModule.Rebel.KillCooldown)
                end
                KillEnemy(enemyName)
                MainModule.Rebel.LastKillTime = tick()
                task.wait(0.05)
            end
        end)
    else
        MainModule.Rebel.LastKillTime = 0
        MainModule.Rebel.LastCheckTime = 0
    end
end

function MainModule.HasCollectSnow()
    local character = GetCharacter()
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name, "Collect Snow") then
                return true
            end
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name, "Collect Snow") then
                return true
            end
        end
    end
    
    return false
end

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.RLGL.CollectSnowCheck then
        MainModule.RLGL.CollectSnowCheck:Disconnect()
        MainModule.RLGL.CollectSnowCheck = nil
    end
    
    if enabled then
        ShowNotification("GodMode", "Enabled", 2)
        
        -- Запоминаем здоровье при включении
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                MainModule.RLGL.InitialHealth = humanoid.Health
            end
            
            -- Поднимаем игрока
            local rootPart = GetRootPart(character)
            if rootPart then
                MainModule.RLGL.OriginalHeight = rootPart.Position.Y
                local targetHeight = rootPart.Position.Y + MainModule.RLGL.GodModeHeight
                local targetPos = Vector3.new(rootPart.Position.X, targetHeight, rootPart.Position.Z)
                SafeTeleport(targetPos)
            end
        end
        
        MainModule.RLGL.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageTime < MainModule.RLGL.DamageCheckRate then return end
            
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                if not (humanoid and rootPart) then return end
                
                -- Проверяем, получили ли урон после включения
                if humanoid.Health < MainModule.RLGL.InitialHealth then
                    MainModule.RLGL.LastDamageTime = currentTime
                    ShowNotification("GodMode", "Safe to Player", 2)
                    SafeTeleport(MainModule.RLGL.DamageTeleportPosition)
                    humanoid.Health = MainModule.RLGL.InitialHealth
                    task.wait(0.1)
                    MainModule.ToggleGodMode(false)
                end
            end)
        end)
        
        -- Проверка Collect Snow каждую секунду
        MainModule.RLGL.CollectSnowCheck = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            MainModule.RLGL.CollectSnowTimer = MainModule.RLGL.CollectSnowTimer + task.wait()
            
            if MainModule.RLGL.CollectSnowTimer >= 1 then
                MainModule.RLGL.CollectSnowTimer = 0
                
                if not MainModule.HasCollectSnow() then
                    MainModule.RLGL.NoCollectSnowTimer = MainModule.RLGL.NoCollectSnowTimer + 1
                    
                    if MainModule.RLGL.NoCollectSnowTimer >= MainModule.RLGL.NoCollectSnowCooldown then
                        ShowNotification("GodMode", "Disabled - No Collect Snow", 2)
                        MainModule.ToggleGodMode(false)
                    end
                else
                    MainModule.RLGL.NoCollectSnowTimer = 0
                end
            end
        end)
        
    else
        ShowNotification("GodMode", "Disabled", 2)
        
        -- Возвращаем на исходную высоту
        if MainModule.RLGL.OriginalHeight then
            local character = GetCharacter()
            if character then
                local rootPart = GetRootPart(character)
                if rootPart then
                    local targetPos = Vector3.new(rootPart.Position.X, MainModule.RLGL.OriginalHeight, rootPart.Position.Z)
                    SafeTeleport(targetPos)
                end
            end
        end
        
        -- Сбрасываем все таймеры
        MainModule.RLGL.InitialHealth = 100
        MainModule.RLGL.OriginalHeight = nil
        MainModule.RLGL.NoCollectSnowTimer = 0
        MainModule.RLGL.CollectSnowTimer = 0
    end
end

function MainModule.TeleportToEnd()
    SafeTeleport(MainModule.RLGL.EndPosition)
end

function MainModule.TeleportToStart()
    SafeTeleport(MainModule.RLGL.StartPosition)
end

-- Запомни Anti Ragdoll 
function MainModule.ToggleBypassRagdoll(enabled)
    if MainModule.Fly.Enabled then
        MainModule.Fly.WasRagdollEnabled = enabled
        return
    end
    
    MainModule.Misc.BypassRagdollEnabled = enabled
    if bypassRagdollConnection then
        bypassRagdollConnection:Disconnect()
        bypassRagdollConnection = nil
    end
    if enabled then
        bypassRagdollConnection = RunService.Stepped:Connect(function()
            if not MainModule.Misc.BypassRagdollEnabled then return end
            pcall(function()
                local Character = GetCharacter()
                if not Character then return end
                local Humanoid = GetHumanoid(Character)
                local HumanoidRootPart = GetRootPart(Character)
                if not (Humanoid and HumanoidRootPart) then return end
                
                for _, child in ipairs(Character:GetChildren()) do
                    if child.Name == "Ragdoll" then
                        task.spawn(function()
                            for i = 1, 10 do
                                if child and child.Parent then
                                    for _, part in pairs(child:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            part.Transparency = part.Transparency + 0.1
                                        end
                                    end
                                    task.wait(0.05)
                                end
                            end
                            pcall(function() child:Destroy() end)
                        end)
                        Humanoid.PlatformStand = false
                        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
                local harmfulFolders = {"RotateDisabled", "RagdollWakeupImmunity"}
                for _, folderName in pairs(harmfulFolders) do
                    local folder = Character:FindFirstChild(folderName)
                    if folder then
                        folder:Destroy()
                    end
                end
                
                -- Сохраняем текущую скорость для дальнейшего анализа
                local currentPlayerVelocity = HumanoidRootPart.Velocity
                local playerMoveDirection = Humanoid.MoveDirection
                local isPlayerMoving = playerMoveDirection.Magnitude > 0
                local playerHorizontalSpeed = Vector3.new(currentPlayerVelocity.X, 0, currentPlayerVelocity.Z).Magnitude
                
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local currentVelocity = part.Velocity
                        local horizontalSpeed = Vector3.new(currentVelocity.X, 0, currentVelocity.Z).Magnitude
                        
                        -- Убираем ограничение скорости для частей тела - это мешает рывку
                        -- Вместо этого удаляем только очень сильные аномальные силы
                        
                        for _, force in pairs(part:GetChildren()) do
                            if force:IsA("BodyForce") then
                                local forceMagnitude = force.Force.Magnitude
                                -- Удаляем только чрезвычайно сильные BodyForce (явно не игровые)
                                if forceMagnitude > 5000 then
                                    force:Destroy()
                                end
                            elseif force:IsA("BodyVelocity") then
                                local velocityMagnitude = force.Velocity.Magnitude
                                local velocityDirection = force.Velocity.Unit
                                local playerVelocityDirection = currentPlayerVelocity.Unit
                                
                                -- Проверяем, является ли это толчком против игрока
                                local isOpposingForce = false
                                if playerHorizontalSpeed > 5 then
                                    local dotProduct = velocityDirection:Dot(playerVelocityDirection)
                                    -- Если сила направлена против движения игрока - это толчок
                                    if dotProduct < -0.7 then
                                        isOpposingForce = true
                                    end
                                end
                                
                                -- Удаляем BodyVelocity только если:
                                -- 1. Очень высокая скорость (явно не игровая)
                                -- 2. Или это толчок против движения игрока
                                -- 3. ИЛИ игрок стоит на месте и его толкают
                                if velocityMagnitude > 100 or isOpposingForce or (not isPlayerMoving and velocityMagnitude > 30) then
                                    force:Destroy()
                                end
                            end
                        end
                    end
                end
                
                -- Анализируем внешние силы на HumanoidRootPart
                local externalForces = {}
                for _, force in pairs(HumanoidRootPart:GetChildren()) do
                    if force:IsA("BodyForce") or force:IsA("BodyVelocity") then
                        table.insert(externalForces, force)
                    end
                end
                
                -- Только если обнаружено несколько внешних сил ИЛИ очень сильная одиночная сила
                if #externalForces > 1 then
                    -- Множественные силы - вероятно, вредоносный эффект
                    for _, force in pairs(externalForces) do
                        task.spawn(function()
                            if force:IsA("BodyVelocity") then
                                pcall(function() force:Destroy() end)
                            elseif force:IsA("BodyForce") then
                                local forceMagnitude = force.Force.Magnitude
                                if forceMagnitude > 1000 then
                                    pcall(function() force:Destroy() end)
                                end
                            end
                        end)
                    end
                elseif #externalForces == 1 then
                    -- Одна сила - проверяем, не мешает ли она игроку
                    local force = externalForces[1]
                    if force:IsA("BodyVelocity") then
                        local velocityMagnitude = force.Velocity.Magnitude
                        local velocityDirection = force.Velocity.Unit
                        local playerVelocityDirection = currentPlayerVelocity.Unit
                        
                        -- Определяем, является ли сила вредоносной
                        local isHarmfulForce = false
                        
                        if isPlayerMoving and playerHorizontalSpeed > 10 then
                            -- Игрок движется - проверяем направление силы
                            local dotProduct = velocityDirection:Dot(playerVelocityDirection)
                            if dotProduct < -0.5 then -- Сила направлена против движения игрока
                                isHarmfulForce = true
                            end
                        elseif not isPlayerMoving then
                            -- Игрок стоит - любая значительная сила считается вредоносной
                            if velocityMagnitude > 30 then
                                isHarmfulForce = true
                            end
                        end
                        
                        -- Удаляем только вредоносные силы
                        if isHarmfulForce then
                            task.spawn(function()
                                for i = 1, 3 do
                                    if force and force.Parent then
                                        force.Velocity = force.Velocity * 0.7
                                        task.wait(0.02)
                                    end
                                end
                                pcall(function() force:Destroy() end)
                            end)
                        end
                    end
                end
            end)
        end)
        local char = GetCharacter()
        if char then
            char.ChildAdded:Connect(function(child)
                if child.Name == "Ragdoll" and MainModule.Misc.BypassRagdollEnabled then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                    local humanoid = GetHumanoid(char)
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end
        task.wait(0.5)
        MainModule.StartEnhancedProtection()
        MainModule.StartJointCleaning()
    else
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                for _, conn in pairs(getconnections(rootPart.ChildAdded)) do
                    conn:Disconnect()
                end
            end
        end
        MainModule.StopEnhancedProtection()
        MainModule.StopJointCleaning()
    end
end

local harmfulEffectsList = {
    "RagdollStun", "Stun", "Stunned", "StunEffect", "StunHit",
    "Knockback", "Knockdown", "Knockout", "KB_Effect",
    "Dazed", "Paralyzed", "Paralyze", "Freeze", "Frozen", 
    "Sleep", "Sleeping", "SleepEffect", "Confusion", "Confused",
    "Slow", "Slowed", "Root", "Rooted", "Immobilized",
    "Bleed", "Bleeding", "Poison", "Poisoned", "Burn", "Burning",
    "Shock", "Shocked", "Electrocuted", "Silence", "Silenced",
    "Disarm", "Disarmed", "Blind", "Blinded", "Fear", "Feared",
    "Taunt", "Taunted", "Charm", "Charmed", "Petrify", "Petrified"
}

local enhancedProtectionConnection = nil
local jointCleaningConnection = nil
local ragdollBlockConnection = nil

local function CleanNegativeEffects(character)
    if not character or not MainModule.Misc.BypassRagdollEnabled then return end
    pcall(function()
        for _, effectName in ipairs(harmfulEffectsList) do
            local effect = character:FindFirstChild(effectName)
            if effect then
                if effect:IsA("BasePart") then
                    task.spawn(function()
                        for i = 1, 5 do
                            if effect and effect.Parent then
                                effect.Transparency = effect.Transparency + 0.2
                                task.wait(0.02)
                            end
                        end
                        pcall(function() effect:Destroy() end)
                    end)
                else
                    pcall(function() effect:Destroy() end)
                end
            end
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local badAttributes = {"Stunned", "Paralyzed", "Frozen", "Asleep", "Confused", 
                                   "Slowed", "Rooted", "Silenced", "Disarmed", "Blinded", "Feared"}
            for _, attr in ipairs(badAttributes) do
                if humanoid:GetAttribute(attr) then
                    humanoid:SetAttribute(attr, false)
                end
            end
        end
    end)
end

local function CleanJointsAndConstraints(character)
    if not character then return end
    pcall(function()
        local Humanoid = character:FindFirstChild("Humanoid")
        local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local Torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if not (Humanoid and HumanoidRootPart and Torso) then return end
        for _, child in ipairs(character:GetChildren()) do
            if child.Name == "Ragdoll" then
                pcall(function() child:Destroy() end)
            end
        end
        for _, folderName in pairs({"Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking"}) do
            local folder = character:FindFirstChild(folderName)
            if folder then
                folder:Destroy()
            end
        end
        for _, obj in pairs(HumanoidRootPart:GetChildren()) do
            if obj:IsA("BallSocketConstraint") or obj.Name:match("^CacheAttachment") then
                obj:Destroy()
            end
        end
        local joints = {"Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder"}
        for _, jointName in pairs(joints) do
            local motor = Torso:FindFirstChild(jointName)
            if motor and motor:IsA("Motor6D") and not motor.Part0 then
                motor.Part0 = Torso
            end
        end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part:FindFirstChild("BoneCustom") then
                part.BoneCustom:Destroy()
            end
        end
    end)
end

local function SetupRagdollListener(character)
    if not character then return end
    if ragdollBlockConnection then
        ragdollBlockConnection:Disconnect()
        ragdollBlockConnection = nil
    end
    local Humanoid = character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    ragdollBlockConnection = character.ChildAdded:Connect(function(child)
        if child.Name == "Ragdoll" then
            pcall(function() child:Destroy() end)
            pcall(function()
                Humanoid.PlatformStand = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end)
        end
    end)
end

function MainModule.StartEnhancedProtection()
    if enhancedProtectionConnection then
        enhancedProtectionConnection:Disconnect()
    end
    enhancedProtectionConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        local character = GetCharacter()
        if character then
            CleanNegativeEffects(character)
        end
    end)
end

function MainModule.StopEnhancedProtection()
    if enhancedProtectionConnection then
        enhancedProtectionConnection:Disconnect()
        enhancedProtectionConnection = nil
    end
end

function MainModule.StartJointCleaning()
    if jointCleaningConnection then
        jointCleaningConnection:Disconnect()
    end
    local character = GetCharacter()
    if character then
        CleanJointsAndConstraints(character)
        SetupRagdollListener(character)
    end
    jointCleaningConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        local character = GetCharacter()
        if character then
            CleanJointsAndConstraints(character)
        end
    end)
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        SetupRagdollListener(newChar)
        CleanJointsAndConstraints(newChar)
    end)
end

function MainModule.StopJointCleaning()
    if jointCleaningConnection then
        jointCleaningConnection:Disconnect()
        jointCleaningConnection = nil
    end
    if ragdollBlockConnection then
        ragdollBlockConnection:Disconnect()
        ragdollBlockConnection = nil
    end
end

function MainModule.FullCleanup()
    local character = GetCharacter()
    if character then
        CleanNegativeEffects(character)
        CleanJointsAndConstraints(character)
        return true
    end
    return false
end

function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
    MainModule.ClearESP()
    if enabled then
        MainModule.ESP.Folder = Instance.new("Folder")
        MainModule.ESP.Folder.Name = "CreonXESP"
        MainModule.ESP.Folder.Parent = CoreGui
        local function UpdatePlayerESP(player)
            if not player or player == LocalPlayer then return end
            local character = player.Character
            if not character then return end
            local humanoid = GetHumanoid(character)
            local rootPart = GetRootPart(character)
            if not (humanoid and rootPart and humanoid.Health > 0) then return end
            local localCharacter = GetCharacter()
            local localRoot = localCharacter and GetRootPart(localCharacter)
            local espData = MainModule.ESP.Players[player]
            if not espData then
                espData = {
                    Player = player,
                    Highlight = nil,
                    Billboard = nil,
                    Label = nil
                }
                MainModule.ESP.Players[player] = espData
            end
            if not espData.Highlight then
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.Name = player.Name .. "_ESP"
                espData.Highlight.Adornee = character
                espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                espData.Highlight.Enabled = MainModule.Misc.ESPHighlight
                espData.Highlight.Parent = MainModule.ESP.Folder
            end
            if IsHider(player) and MainModule.Misc.ESPHiders then
                espData.Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
            elseif IsSeeker(player) and MainModule.Misc.ESPSeekers then
                espData.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
            elseif MainModule.Misc.ESPPlayers then
                espData.Highlight.FillColor = Color3.fromRGB(0, 120, 255)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
            else
                espData.Highlight.Enabled = false
            end
            espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
            espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
            if MainModule.Misc.ESPNames then
                if not espData.Billboard then
                    espData.Billboard = Instance.new("BillboardGui")
                    espData.Billboard.Name = player.Name .. "_Text"
                    espData.Billboard.Adornee = rootPart
                    espData.Billboard.AlwaysOnTop = true
                    espData.Billboard.Size = UDim2.new(0, 200, 0, 50)
                    espData.Billboard.StudsOffset = Vector3.new(0, 3, 0)
                    espData.Billboard.Parent = MainModule.ESP.Folder
                    espData.Label = Instance.new("TextLabel")
                    espData.Label.Size = UDim2.new(1, 0, 1, 0)
                    espData.Label.BackgroundTransparency = 1
                    espData.Label.TextColor3 = espData.Highlight.FillColor
                    espData.Label.TextSize = MainModule.Misc.ESPTextSize
                    espData.Label.Font = Enum.Font.GothamBold
                    espData.Label.TextStrokeColor3 = Color3.new(0, 0, 0)
                    espData.Label.TextStrokeTransparency = 0.5
                    espData.Label.Parent = espData.Billboard
                end
                espData.Billboard.Enabled = true
                local distanceText = ""
                if MainModule.Misc.ESPDistance and localRoot then
                    local distance = math.floor(GetDistance(rootPart.Position, localRoot.Position))
                    distanceText = string.format(" [%dm]", distance)
                end
                local healthText = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                local nameText = player.DisplayName or player.Name
                espData.Label.Text = string.format("%s\n%s%s", nameText, healthText, distanceText)
                espData.Label.TextColor3 = espData.Highlight.FillColor
                espData.Label.TextSize = MainModule.Misc.ESPTextSize
            elseif espData.Billboard then
                espData.Billboard.Enabled = false
            end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdatePlayerESP(player)
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    UpdatePlayerESP(player)
                end)
            end
        end
        MainModule.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            if MainModule.Misc.ESPEnabled and player ~= LocalPlayer then
                task.wait(0.5)
                UpdatePlayerESP(player)
            end
        end)
        MainModule.ESP.MainConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            for player, espData in pairs(MainModule.ESP.Players) do
                if player and player.Parent and player.Character then
                    UpdatePlayerESP(player)
                else
                    if espData.Highlight then
                        SafeDestroy(espData.Highlight)
                    end
                    if espData.Billboard then
                        SafeDestroy(espData.Billboard)
                    end
                    MainModule.ESP.Players[player] = nil
                end
            end
        end)
    end
end

function MainModule.ClearESP()
    for player, espData in pairs(MainModule.ESP.Players) do
        if espData.Highlight then
            SafeDestroy(espData.Highlight)
        end
        if espData.Billboard then
            SafeDestroy(espData.Billboard)
        end
    end
    MainModule.ESP.Players = {}
    if MainModule.ESP.Connections then
        for name, connection in pairs(MainModule.ESP.Connections) do
            if connection then
                pcall(function() connection:Disconnect() end)
                MainModule.ESP.Connections[name] = nil
            end
        end
    end
    if MainModule.ESP.Folder then
        SafeDestroy(MainModule.ESP.Folder)
        MainModule.ESP.Folder = nil
    end
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
end

function MainModule.CheckKnifeInInventory()
    local character = GetCharacter()
    if not character then return false end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true, tool
            end
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                    return true, tool
                end
            end
        end
    end
    
    return false, nil
end

function MainModule.ToggleSpikesKill(enabled)
    if enabled then
        local hasKnife = MainModule.CheckKnifeInInventory()
        if not hasKnife then
            ShowNotification("Spikes Kill", "Knife not found!", 3)
            MainModule.SpikesKillFeature.Enabled = false
            return
        end
        MainModule.SpikesKillFeature.HasKnife = true
    end
    
    MainModule.SpikesKillFeature.Enabled = enabled
    
    if MainModule.SpikesKillFeature.AnimationConnection then
        MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationConnection = nil
    end
    if MainModule.SpikesKillFeature.CharacterAddedConnection then
        MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.SpikesKillFeature.SafetyCheckConnection then
        MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.SafetyCheckConnection = nil
    end
    if MainModule.SpikesKillFeature.AnimationCheckConnection then
        MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationCheckConnection = nil
    end
    if MainModule.SpikesKillFeature.KnifeCheckConnection then
        MainModule.SpikesKillFeature.KnifeCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.KnifeCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKillFeature.AnimationStoppedConnections = {}
    
    MainModule.SpikesKillFeature.SavedCFrame = nil
    MainModule.SpikesKillFeature.ActiveAnimation = false
    MainModule.SpikesKillFeature.AnimationStartTime = 0
    MainModule.SpikesKillFeature.TrackedAnimations = {}
    MainModule.SpikesKillFeature.NoKnifeTimer = 0
    
    if not enabled then
        MainModule.SpikesKillFeature.HasKnife = false
        return
    end
    
    MainModule.DisableSpikes(true)
    
    local function checkAnimations()
        if not MainModule.SpikesKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKillFeature.AnimationId then
                if not MainModule.SpikesKillFeature.TrackedAnimations[track] then
                    MainModule.SpikesKillFeature.TrackedAnimations[track] = true
                    
                    if not MainModule.SpikesKillFeature.ActiveAnimation then
                        MainModule.SpikesKillFeature.ActiveAnimation = true
                        MainModule.SpikesKillFeature.AnimationStartTime = tick()
                        
                        MainModule.SpikesKillFeature.SavedCFrame = character:GetPrimaryPartCFrame()
                        
                        local spikesPosition = MainModule.SpikesKillFeature.SpikesPosition
                        if not spikesPosition then
                            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
                            local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
                            if killingParts and killingParts:FindFirstChildWhichIsA("BasePart") then
                                local firstSpike = killingParts:FindFirstChildWhichIsA("BasePart")
                                if firstSpike then
                                    spikesPosition = firstSpike.Position
                                    MainModule.SpikesKillFeature.SpikesPosition = spikesPosition
                                end
                            end
                        end
                        
                        if spikesPosition then
                            local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                        else
                            local currentPos = character:GetPrimaryPartCFrame().Position
                            local targetPosition = currentPos + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                        end
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.SpikesKillFeature.ReturnDelay)
                            
                            if MainModule.SpikesKillFeature.ActiveAnimation and MainModule.SpikesKillFeature.SavedCFrame then
                                character:SetPrimaryPartCFrame(MainModule.SpikesKillFeature.SavedCFrame)
                                MainModule.SpikesKillFeature.SavedCFrame = nil
                                MainModule.SpikesKillFeature.ActiveAnimation = false
                                MainModule.SpikesKillFeature.TrackedAnimations = {}
                            end
                        end)
                        table.insert(MainModule.SpikesKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid")
        
        MainModule.SpikesKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.SpikesKillFeature.Enabled then return end
            
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKillFeature.AnimationId then
                MainModule.SpikesKillFeature.TrackedAnimations[track] = true
                
                if not MainModule.SpikesKillFeature.ActiveAnimation then
                    MainModule.SpikesKillFeature.ActiveAnimation = true
                    MainModule.SpikesKillFeature.AnimationStartTime = tick()
                    
                    MainModule.SpikesKillFeature.SavedCFrame = char:GetPrimaryPartCFrame()
                    
                    local spikesPosition = MainModule.SpikesKillFeature.SpikesPosition
                    if not spikesPosition then
                        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
                        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
                        if killingParts and killingParts:FindFirstChildWhichIsA("BasePart") then
                            local firstSpike = killingParts:FindFirstChildWhichIsA("BasePart")
                            if firstSpike then
                                spikesPosition = firstSpike.Position
                                MainModule.SpikesKillFeature.SpikesPosition = spikesPosition
                            end
                        end
                    end
                    
                    if spikesPosition then
                        local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                        char:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                    else
                        local currentPos = char:GetPrimaryPartCFrame().Position
                        local targetPosition = currentPos + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                        char:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                    end
                    
                    local stoppedConn = track.Stopped:Connect(function()
                        task.wait(MainModule.SpikesKillFeature.ReturnDelay)
                        
                        if MainModule.SpikesKillFeature.SavedCFrame then
                            char:SetPrimaryPartCFrame(MainModule.SpikesKillFeature.SavedCFrame)
                            MainModule.SpikesKillFeature.SavedCFrame = nil
                            MainModule.SpikesKillFeature.ActiveAnimation = false
                            MainModule.SpikesKillFeature.TrackedAnimations = {}
                        end
                    end)
                    table.insert(MainModule.SpikesKillFeature.AnimationStoppedConnections, stoppedConn)
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    MainModule.SpikesKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        setupCharacter(newChar)
    end)
    
    MainModule.SpikesKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then return end
        checkAnimations()
    end)
    
    MainModule.SpikesKillFeature.SafetyCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.ActiveAnimation then return end
        if tick() - MainModule.SpikesKillFeature.AnimationStartTime >= 10 then
            MainModule.SpikesKillFeature.ActiveAnimation = false
        end
    end)
    
    MainModule.SpikesKillFeature.KnifeCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then return end
        
        local currentTime = tick()
        if currentTime - MainModule.SpikesKillFeature.LastKnifeCheckTime < MainModule.SpikesKillFeature.KnifeCheckCooldown then
            return
        end
        MainModule.SpikesKillFeature.LastKnifeCheckTime = currentTime
        
        local hasKnife = MainModule.CheckKnifeInInventory()
        
        if hasKnife then
            MainModule.SpikesKillFeature.HasKnife = true
            MainModule.SpikesKillFeature.NoKnifeTimer = 0
        else
            MainModule.SpikesKillFeature.NoKnifeTimer = MainModule.SpikesKillFeature.NoKnifeTimer + MainModule.SpikesKillFeature.KnifeCheckCooldown
            
            if MainModule.SpikesKillFeature.NoKnifeTimer >= MainModule.SpikesKillFeature.NoKnifeTimeout then
                ShowNotification("Spikes Kill", "Knife not found!", 3)
                MainModule.ToggleSpikesKill(false)
            end
        end
    end)
end

function MainModule.DisableSpikes(remove)
    pcall(function()
        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
        if not killingParts then
            return false
        end
        if remove then
            MainModule.SpikesKillFeature.OriginalSpikes = {}
            MainModule.SpikesKillFeature.SpikesPosition = nil
            for _, spike in pairs(killingParts:GetChildren()) do
                if spike:IsA("BasePart") then
                    table.insert(MainModule.SpikesKillFeature.OriginalSpikes, spike:Clone())
                    if not MainModule.SpikesKillFeature.SpikesPosition then
                        MainModule.SpikesKillFeature.SpikesPosition = spike.Position
                    end
                    spike:Destroy()
                end
            end
            MainModule.SpikesKillFeature.SpikesRemoved = true
            return true
        else
            return true
        end
    end)
end

function MainModule.ToggleVoidKill(enabled)
    MainModule.VoidKillFeature.Enabled = enabled
    
    if MainModule.VoidKillFeature.AnimationConnection then
        MainModule.VoidKillFeature.AnimationConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationConnection = nil
    end
    if MainModule.VoidKillFeature.CharacterAddedConnection then
        MainModule.VoidKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.VoidKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.VoidKillFeature.AnimationCheckConnection then
        MainModule.VoidKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.VoidKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.VoidKillFeature.AnimationStoppedConnections = {}
    
    MainModule.VoidKillFeature.SavedCFrame = nil
    MainModule.VoidKillFeature.ActiveAnimation = false
    MainModule.VoidKillFeature.AnimationStartTime = 0
    MainModule.VoidKillFeature.TrackedAnimations = {}
    
    if not enabled then
        if MainModule.VoidKillFeature.AntiFallPlatform then
            MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
            MainModule.VoidKillFeature.AntiFallPlatform = nil
        end
        MainModule.VoidKillFeature.AntiFallEnabled = false
        return
    end
    
    local function checkAnimations()
        if not MainModule.VoidKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.VoidKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    if not MainModule.VoidKillFeature.TrackedAnimations[trackKey] then
                        MainModule.VoidKillFeature.TrackedAnimations[trackKey] = true
                        
                        if not MainModule.VoidKillFeature.ActiveAnimation then
                            MainModule.VoidKillFeature.ActiveAnimation = true
                            MainModule.VoidKillFeature.AnimationStartTime = tick()
                            
                            MainModule.VoidKillFeature.SavedCFrame = character:GetPrimaryPartCFrame()
                            
                            local platformPosition = MainModule.VoidKillFeature.ZonePosition + 
                                                    Vector3.new(0, MainModule.VoidKillFeature.PlatformYOffset, 0)
                            
                            MainModule.VoidKillFeature.AntiFallPlatform = Instance.new("Part")
                            MainModule.VoidKillFeature.AntiFallPlatform.Name = "VoidKillAntiFall"
                            MainModule.VoidKillFeature.AntiFallPlatform.Size = MainModule.VoidKillFeature.PlatformSize
                            MainModule.VoidKillFeature.AntiFallPlatform.Anchored = true
                            MainModule.VoidKillFeature.AntiFallPlatform.CanCollide = true
                            MainModule.VoidKillFeature.AntiFallPlatform.Transparency = 1
                            MainModule.VoidKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                            MainModule.VoidKillFeature.AntiFallPlatform.CastShadow = false
                            MainModule.VoidKillFeature.AntiFallPlatform.CanQuery = false
                            MainModule.VoidKillFeature.AntiFallPlatform.Position = platformPosition
                            MainModule.VoidKillFeature.AntiFallPlatform.Parent = workspace
                            
                            character:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidKillFeature.ZonePosition))
                            
                            local stoppedConn = track.Stopped:Connect(function()
                                task.wait(MainModule.VoidKillFeature.ReturnDelay)
                                
                                if MainModule.VoidKillFeature.SavedCFrame then
                                    character:SetPrimaryPartCFrame(MainModule.VoidKillFeature.SavedCFrame)
                                    MainModule.VoidKillFeature.SavedCFrame = nil
                                end
                                
                                MainModule.VoidKillFeature.ActiveAnimation = false
                                MainModule.VoidKillFeature.TrackedAnimations = {}
                                
                                if MainModule.VoidKillFeature.AntiFallPlatform then
                                    MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
                                    MainModule.VoidKillFeature.AntiFallPlatform = nil
                                end
                            end)
                            
                            table.insert(MainModule.VoidKillFeature.AnimationStoppedConnections, stoppedConn)
                        end
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        MainModule.VoidKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.VoidKillFeature.Enabled then return end
            
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.VoidKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    MainModule.VoidKillFeature.TrackedAnimations[trackKey] = true
                    
                    if not MainModule.VoidKillFeature.ActiveAnimation then
                        MainModule.VoidKillFeature.ActiveAnimation = true
                        MainModule.VoidKillFeature.AnimationStartTime = tick()
                        
                        MainModule.VoidKillFeature.SavedCFrame = char:GetPrimaryPartCFrame()
                        
                        local platformPosition = MainModule.VoidKillFeature.ZonePosition + 
                                                Vector3.new(0, MainModule.VoidKillFeature.PlatformYOffset, 0)
                        
                        MainModule.VoidKillFeature.AntiFallPlatform = Instance.new("Part")
                        MainModule.VoidKillFeature.AntiFallPlatform.Name = "VoidKillAntiFall"
                        MainModule.VoidKillFeature.AntiFallPlatform.Size = MainModule.VoidKillFeature.PlatformSize
                        MainModule.VoidKillFeature.AntiFallPlatform.Anchored = true
                        MainModule.VoidKillFeature.AntiFallPlatform.CanCollide = true
                        MainModule.VoidKillFeature.AntiFallPlatform.Transparency = 1
                        MainModule.VoidKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                        MainModule.VoidKillFeature.AntiFallPlatform.CastShadow = false
                        MainModule.VoidKillFeature.AntiFallPlatform.CanQuery = false
                        MainModule.VoidKillFeature.AntiFallPlatform.Position = platformPosition
                        MainModule.VoidKillFeature.AntiFallPlatform.Parent = workspace
                        
                        char:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidKillFeature.ZonePosition))
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.VoidKillFeature.ReturnDelay)
                            
                            if MainModule.VoidKillFeature.SavedCFrame then
                                char:SetPrimaryPartCFrame(MainModule.VoidKillFeature.SavedCFrame)
                                MainModule.VoidKillFeature.SavedCFrame = nil
                            end
                            
                            MainModule.VoidKillFeature.ActiveAnimation = false
                            MainModule.VoidKillFeature.TrackedAnimations = {}
                            
                            if MainModule.VoidKillFeature.AntiFallPlatform then
                                MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
                                MainModule.VoidKillFeature.AntiFallPlatform = nil
                            end
                        end)
                        
                        table.insert(MainModule.VoidKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        task.spawn(setupCharacter, char)
    end
    
    MainModule.VoidKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        if MainModule.VoidKillFeature.Enabled then
            task.spawn(setupCharacter, newChar)
        end
    end)
    
    MainModule.VoidKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.VoidKillFeature.Enabled then return end
        checkAnimations()
    end)
end

MainModule.ZoneKillFeature = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164", -- Та же анимация что и в Spikes Kill
    ZonePosition = Vector3.new(197.7, 54.6, -96.3), -- Новая позиция
    ReturnDelay = 0.6, -- Задержка перед возвратом (как в Spikes Kill)
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {}
}

function MainModule.ToggleZoneKill(enabled)
    MainModule.ZoneKillFeature.Enabled = enabled
    
    -- Очистка всех подключений
    if MainModule.ZoneKillFeature.AnimationConnection then
        MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationConnection = nil
    end
    if MainModule.ZoneKillFeature.CharacterAddedConnection then
        MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.ZoneKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.ZoneKillFeature.AnimationCheckConnection then
        MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationCheckConnection = nil
    end
    
    -- Очистка stopped подключений
    for _, conn in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
    
    -- Сброс состояния
    MainModule.ZoneKillFeature.SavedCFrame = nil
    MainModule.ZoneKillFeature.ActiveAnimation = false
    MainModule.ZoneKillFeature.AnimationStartTime = 0
    MainModule.ZoneKillFeature.TrackedAnimations = {}
    
    if not enabled then
        return
    end
    
    -- Функция проверки анимаций
    local function checkAnimations()
        if not MainModule.ZoneKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track and track.Animation then
                local success, animId = pcall(function()
                    return track.Animation.AnimationId
                end)
                
                if success and animId and animId == MainModule.ZoneKillFeature.AnimationId then
                    if not MainModule.ZoneKillFeature.TrackedAnimations[track] then
                        MainModule.ZoneKillFeature.TrackedAnimations[track] = true
                        
                        if not MainModule.ZoneKillFeature.ActiveAnimation then
                            MainModule.ZoneKillFeature.ActiveAnimation = true
                            MainModule.ZoneKillFeature.AnimationStartTime = tick()
                            
                            -- Сохраняем текущую позицию персонажа
                            local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
                            if primaryPart then
                                MainModule.ZoneKillFeature.SavedCFrame = primaryPart.CFrame
                                
                                -- Телепортируем на позицию зоны
                                character:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                            end
                            
                            -- Подключаемся к событию окончания анимации
                            local stoppedConn = track.Stopped:Connect(function()
                                task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                                
                                if MainModule.ZoneKillFeature.SavedCFrame then
                                    -- Возвращаем на исходную позицию
                                    character:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
                                    MainModule.ZoneKillFeature.SavedCFrame = nil
                                    MainModule.ZoneKillFeature.ActiveAnimation = false
                                    MainModule.ZoneKillFeature.TrackedAnimations = {}
                                end
                            end)
                            table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, stoppedConn)
                        end
                    end
                end
            end
        end
    end
    
    -- Функция настройки персонажа
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        MainModule.ZoneKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.ZoneKillFeature.Enabled then return end
            
            if track and track.Animation then
                local success, animId = pcall(function()
                    return track.Animation.AnimationId
                end)
                
                if success and animId and animId == MainModule.ZoneKillFeature.AnimationId then
                    MainModule.ZoneKillFeature.TrackedAnimations[track] = true
                    
                    if not MainModule.ZoneKillFeature.ActiveAnimation then
                        MainModule.ZoneKillFeature.ActiveAnimation = true
                        MainModule.ZoneKillFeature.AnimationStartTime = tick()
                        
                        -- Сохраняем текущую позицию персонажа
                        local primaryPart = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
                        if primaryPart then
                            MainModule.ZoneKillFeature.SavedCFrame = primaryPart.CFrame
                            
                            -- Телепортируем на позицию зоны
                            char:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                        end
                        
                        -- Подключаемся к событию окончания анимации
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                            
                            if MainModule.ZoneKillFeature.SavedCFrame then
                                -- Возвращаем на исходную позицию
                                char:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
                                MainModule.ZoneKillFeature.SavedCFrame = nil
                                MainModule.ZoneKillFeature.ActiveAnimation = false
                                MainModule.ZoneKillFeature.TrackedAnimations = {}
                            end
                        end)
                        table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end)
    end
    
    -- Настройка текущего персонажа
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    -- Настройка для нового персонажа
    MainModule.ZoneKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        setupCharacter(newChar)
    end)
    
    -- Проверка анимаций каждые Heartbeat
    MainModule.ZoneKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.ZoneKillFeature.Enabled then return end
        checkAnimations()
    end)
end

function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    if enabled then
        speedConnection = RunService.Heartbeat:Connect(function()
            if MainModule.SpeedHack.Enabled then
                local character = GetCharacter()
                if character then
                    local humanoid = GetHumanoid(character)
                    if humanoid then
                        humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                    end
                end
            end
        end)
    else
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                humanoid.WalkSpeed = MainModule.SpeedHack.DefaultSpeed
            end
        end
    end
end

function MainModule.SetSpeed(value)
    if value < MainModule.SpeedHack.MinSpeed then
        value = MainModule.SpeedHack.MinSpeed
    elseif value > MainModule.SpeedHack.MaxSpeed then
        value = MainModule.SpeedHack.MaxSpeed
    end
    MainModule.SpeedHack.CurrentSpeed = value
    if MainModule.SpeedHack.Enabled then
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
    return value
end

function MainModule.TeleportUp100()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, 100, 0)
            SafeTeleport(targetPos)
        end
    end
end

function MainModule.TeleportDown40()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, -40, 0)
            SafeTeleport(targetPos)
        end
    end
end

function MainModule.ToggleAntiStunQTE(enabled)
    MainModule.AutoQTE.AntiStunEnabled = enabled
    if antiStunConnection then
        antiStunConnection:Disconnect()
        antiStunConnection = nil
    end
    if enabled then
        antiStunConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoQTE.AntiStunEnabled then return end
            pcall(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local impactFrames = playerGui:FindFirstChild("ImpactFrames")
                if not impactFrames then return end
                local replicatedStorage = ReplicatedStorage
                local success, hbgModule = pcall(function()
                    return require(replicatedStorage.Modules.HBGQTE)
                end)
                if not success then return end
                for _, child in pairs(impactFrames:GetChildren()) do
                    if child.Name == "OuterRingTemplate" and child:IsA("Frame") then
                        for _, innerChild in pairs(impactFrames:GetChildren()) do
                            if innerChild.Name == "InnerTemplate" and innerChild.Position == child.Position 
                               and not innerChild:GetAttribute("Failed") and not innerChild:GetAttribute("Tweening") then
                                pcall(function()
                                    local qteData = {
                                        Inner = innerChild,
                                        Outer = child,
                                        Duration = 2,
                                        StartedAt = tick()
                                    }
                                    hbgModule.Pressed(false, qteData)
                                end)
                                break
                            end
                        end
                    end
                end
            end)
        end)
    end
end

function MainModule.SetGuardType(guardType)
    if guardType == "Circle" then
        MainModule.Guards.SelectedGuard = "Circle"
    elseif guardType == "Triangle" then
        MainModule.Guards.SelectedGuard = "Triangle"
    elseif guardType == "Square" then
        MainModule.Guards.SelectedGuard = "Square"
    else
        MainModule.Guards.SelectedGuard = "Circle"
    end
end

function MainModule.SpawnAsGuard()
    local args = {
        {
            AttemptToSpawnAsGuard = MainModule.Guards.SelectedGuard
        }
    }
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote"):FireServer(unpack(args))
    end)
end

function MainModule.ToggleAutoFarm(enabled)
    MainModule.Guards.AutoFarm = enabled
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
    if enabled then
        autoFarmConnection = RunService.Heartbeat:Connect(function()
            if MainModule.Guards.AutoFarm then
                local args2 = {
                    "GameOver",
                    4450
                }
                pcall(function()
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VideoGameRemote"):FireServer(unpack(args2))
                end)
            end
        end)
    end
end

function MainModule.ToggleRapidFire(enabled)
    MainModule.Guards.RapidFire = enabled
    if rapidFireConnection then
        rapidFireConnection:Disconnect()
        rapidFireConnection = nil
    end
    if enabled then
        rapidFireConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.RapidFire then return end
            pcall(function()
                local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
                if not weaponsFolder then return end
                local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                if gunsFolder then
                    for _, obj in ipairs(gunsFolder:GetDescendants()) do
                        if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                            if not MainModule.Guards.OriginalFireRates[obj] then
                                MainModule.Guards.OriginalFireRates[obj] = obj.Value
                            end
                            obj.Value = 0
                        end
                    end
                end
                local character = GetCharacter()
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                                    if not MainModule.Guards.OriginalFireRates[obj] then
                                        MainModule.Guards.OriginalFireRates[obj] = obj.Value
                                    end
                                    obj.Value = 0
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        pcall(function()
            for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
            MainModule.Guards.OriginalFireRates = {}
        end)
    end
end

function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    if enabled then
        infiniteAmmoConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.InfiniteAmmo then return end
            task.spawn(function()
                local character = GetCharacter()
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                                    local nameLower = obj.Name:lower()
                                    if nameLower:find("ammo") or 
                                       nameLower:find("bullet") or
                                       nameLower:find("clip") or
                                       nameLower:find("munition") then
                                        if not MainModule.Guards.OriginalAmmo[obj] then
                                            MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                        end
                                        if obj.Value < 999 then
                                            obj.Value = math.huge
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                                    local nameLower = obj.Name:lower()
                                    if nameLower:find("ammo") or 
                                       nameLower:find("bullet") or
                                       nameLower:find("clip") then
                                        if not MainModule.Guards.OriginalAmmo[obj] then
                                            MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                        end
                                        if obj.Value < 999 then
                                            obj.Value = math.huge
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        pcall(function()
            for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
            MainModule.Guards.OriginalAmmo = {}
        end)
    end
end

function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    if enabled then
        print("Hitbox Enabled...")
        hitboxConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.HitboxExpander then return end
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            if not MainModule.Hitbox.ModifiedParts[root] then
                                MainModule.Hitbox.ModifiedParts[root] = root.Size
                                root.Size = Vector3.new(MainModule.Hitbox.Size, MainModule.Hitbox.Size, MainModule.Hitbox.Size)
                                root.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end)
    else
        pcall(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root and MainModule.Hitbox.ModifiedParts[root] then
                        root.Size = MainModule.Hitbox.ModifiedParts[root]
                        root.CanCollide = true
                        MainModule.Hitbox.ModifiedParts[root] = nil
                    end
                end
            end
            MainModule.Hitbox.ModifiedParts = {}
        end)
    end
end

function MainModule.SetHitboxSize(size)
    MainModule.Hitbox.Size = size
    if MainModule.Guards.HitboxExpander then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and MainModule.Hitbox.ModifiedParts[root] then
                    root.Size = Vector3.new(size, size, size)
                end
            end
        end
    end
end

function MainModule.CompleteDalgona()
    task.spawn(function()
        local DalgonaClientModule = ReplicatedStorage:FindFirstChild("Modules") and
                                    ReplicatedStorage.Modules:FindFirstChild("Games") and
                                    ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
        if not DalgonaClientModule then return end
        for _, func in pairs(getreg()) do
            if typeof(func) == "function" and islclosure(func) then
                local info = getinfo(func)
                if info.nups == 76 then
                    setupvalue(func, 33, 9999)
                    setupvalue(func, 34, 9999)
                end
            end
        end
    end)
end

function MainModule.FreeLighter()
    LocalPlayer:SetAttribute("HasLighter", true)
end

function MainModule.ToggleAutoPull(enabled)
    MainModule.TugOfWar.AutoPull = enabled
    
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end

    if enabled then
        MainModule.TugOfWar.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.TugOfWar.AutoPull then return end
            
            -- Anti Miss логика
            local player = Players.LocalPlayer
            local gui = player:FindFirstChild("PlayerGui")
            if gui then
                gui = gui:FindFirstChild("QTEEvents")
                if gui then
                    local progress = gui:FindFirstChild("Progress")
                    if progress then
                        local crossHair = progress:FindFirstChild("CrossHair")
                        local goalDot = progress:FindFirstChild("GoalDot")
                        
                        if crossHair and goalDot and crossHair.Parent and goalDot.Parent then
                            crossHair.Rotation = goalDot.Rotation
                        end
                        
                        -- Авто-нажатие кнопок в Progress
                        local buttons = progress:GetChildren()
                        for _, button in ipairs(buttons) do
                            if button:IsA("TextButton") or button:IsA("ImageButton") then
                                if button.Visible and button.Active then
                                    pcall(function()
                                        -- Симулируем нажатие
                                        button:FireEvent("MouseButton1Click")
                                        button:FireEvent("Activated")
                                    end)
                                end
                            elseif button:IsA("ProximityPrompt") then
                                pcall(function()
                                    fireproximityprompt(button)
                                end)
                            end
                        end
                    end
                end
            end
            
            task.wait(0.01)
        end)
    end
end

function MainModule.DeleteJumpRope()
    local ropeFound = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Rope" then
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                obj:Destroy()
                ropeFound = true
                break
            end
        end
    end
    if not ropeFound then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("rope") and 
               (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                obj:Destroy()
                ropeFound = true
                break
            end
        end
    end
    if not ropeFound then
        local effects = workspace:FindFirstChild("Effects")
        if effects then
            for _, obj in pairs(effects:GetDescendants()) do
                if obj.Name:lower():find("rope") and 
                   (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                    obj:Destroy()
                    ropeFound = true
                    break
                end
            end
        end
    end
    return ropeFound
end

function MainModule.TeleportToJumpRopeEnd()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            SafeTeleport(Vector3.new(720.896057, 198.628311, 921.170654))
        end
    end
end

function MainModule.TeleportToJumpRopeStart()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            SafeTeleport(Vector3.new(615.284424, 192.274277, 920.952515))
        end
    end
end

function MainModule.CreateGlassBridgeAntiFall()
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.GlassBridge.GlassAntiFallPlatform:Destroy()
        MainModule.GlassBridge.GlassAntiFallPlatform = nil
    end
    local character = GetCharacter()
    if not character then return nil end
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    local currentPosition = rootPart.Position
    local platform = Instance.new("Part")
    platform.Name = "GlassBridgeAntiFall"
    platform.Size = MainModule.GlassBridge.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    MainModule.GlassBridge.GlassAntiFallPlatform = platform
    MainModule.GlassBridge.AntiFallEnabled = true
    return platform
end

function MainModule.RemoveGlassBridgeAntiFall()
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.GlassBridge.GlassAntiFallPlatform:Destroy()
        MainModule.GlassBridge.GlassAntiFallPlatform = nil
    end
    MainModule.GlassBridge.AntiFallEnabled = false
    return true
end

function MainModule.CreateSkySquidAntiFall()
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    local character = GetCharacter()
    if not character then return nil end
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    local currentPosition = rootPart.Position
    local platform = Instance.new("Part")
    platform.Name = "SkySquidAntiFall"
    platform.Size = MainModule.SkySquid.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    MainModule.SkySquid.AntiFallPlatform = platform
    return platform
end

function MainModule.RemoveSkySquidAntiFall()
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    return true
end

function MainModule.CreateJumpRopeAntiFall()
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    local character = GetCharacter()
    if not character then return nil end
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    local currentPosition = rootPart.Position
    local platform = Instance.new("Part")
    platform.Name = "JumpRopeAntiFall"
    platform.Size = MainModule.JumpRope.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    MainModule.JumpRope.AntiFallPlatform = platform
    return platform
end

function MainModule.RemoveJumpRopeAntiFall()
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    return true
end

function MainModule.ToggleGlassBridgeAntiFall(enabled)
    if enabled then
        return MainModule.CreateGlassBridgeAntiFall()
    else
        return MainModule.RemoveGlassBridgeAntiFall()
    end
end

function MainModule.ToggleSkySquidAntiFall(enabled)
    if enabled then
        return MainModule.CreateSkySquidAntiFall()
    else
        return MainModule.RemoveSkySquidAntiFall()
    end
end

function MainModule.ToggleJumpRopeAntiFall(enabled)
    if enabled then
        return MainModule.CreateJumpRopeAntiFall()
    else
        return MainModule.RemoveJumpRopeAntiFall()
    end
end

function MainModule.ToggleGlassBridgeAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if not enabled then
        for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
            if platform and platform.Parent then
                platform:Destroy()
            end
        end
        MainModule.GlassBridge.GlassPlatforms = {}
        
        -- Не очищаем BreakableTiles при выключении AntiBreak!
        -- Чтобы Glass ESP мог использовать сохраненные данные
        return
    end
    
    -- Инициализируем таблицу для хранения информации о стеклах
    if not MainModule.GlassBridge.BreakableTiles then
        MainModule.GlassBridge.BreakableTiles = {}
    end
    
    MainModule.GlassBridge.AntiBreakConnection = RunService.Heartbeat:Connect(function()
        local GlassBridge = workspace:FindFirstChild("GlassBridge")
        if not GlassBridge then return end
        local GlassHolder = GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        
        for _, rowFolder in pairs(GlassHolder:GetChildren()) do
            for _, glassModel in pairs(rowFolder:GetChildren()) do
                if glassModel:IsA("Model") and glassModel.PrimaryPart then
                    local primaryPart = glassModel.PrimaryPart
                    local modelName = glassModel.Name
                    
                    -- Проверяем значение атрибута (true/false, а не просто наличие)
                    local attributeValue = primaryPart:GetAttribute("exploitingisevil")
                    
                    -- Сохраняем информацию о стекле ТОЛЬКО если еще не сохранено
                    if MainModule.GlassBridge.BreakableTiles[modelName] == nil then
                        -- Если атрибут существует и его значение не false, то стекло ломаемое
                        if attributeValue ~= nil and attributeValue ~= false then
                            MainModule.GlassBridge.BreakableTiles[modelName] = true
                        else
                            MainModule.GlassBridge.BreakableTiles[modelName] = false
                        end
                    end
                    
                    -- Убираем атрибут ломания, чтобы стекло не ломалось
                    if attributeValue ~= nil then
                        primaryPart:SetAttribute("exploitingisevil", nil)
                    end
                    
                    if glassModel.PrimaryPart:IsA("BasePart") then
                        glassModel.PrimaryPart.CanCollide = true
                        glassModel.PrimaryPart.Anchored = true
                        for _, descendant in pairs(glassModel:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                descendant.CanCollide = true
                                descendant.Anchored = true
                            end
                        end
                    end
                end
            end
        end
    end)
end

function MainModule.ToggleGlassBridgeESP(enabled)
    MainModule.GlassBridge.GlassESPEnabled = enabled
    
    if MainModule.GlassBridge.GlassESPConnection then
        MainModule.GlassBridge.GlassESPConnection:Disconnect()
        MainModule.GlassBridge.GlassESPConnection = nil
    end
    
    if not enabled then
        for part, properties in pairs(MainModule.GlassBridge.OriginalColors) do
            if part and part.Parent then
                pcall(function()
                    part.Color = properties.Color
                    part.Material = properties.Material
                    part.Transparency = properties.Transparency
                end)
            end
        end
        MainModule.GlassBridge.OriginalColors = {}
        return
    end
    
    MainModule.GlassBridge.OriginalColors = {}
    
    MainModule.GlassBridge.GlassESPConnection = RunService.Heartbeat:Connect(function()
        local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        
        for _, tilePair in pairs(GlassHolder:GetChildren()) do
            for _, tileModel in pairs(tilePair:GetChildren()) do
                if tileModel:IsA("Model") and tileModel.PrimaryPart then
                    local primaryPart = tileModel.PrimaryPart
                    local modelName = tileModel.Name
                    
                    for _, child in ipairs(tileModel:GetChildren()) do
                        if child:IsA("Highlight") then
                            child:Destroy()
                        end
                    end
                    
                    -- Определяем, ломаемое ли стекло
                    local isBreakable = false
                    
                    -- Сначала проверяем сохраненные данные
                    if MainModule.GlassBridge.BreakableTiles and MainModule.GlassBridge.BreakableTiles[modelName] ~= nil then
                        isBreakable = MainModule.GlassBridge.BreakableTiles[modelName]
                    else
                        -- Если данных нет, проверяем текущий атрибут
                        local attributeValue = primaryPart:GetAttribute("exploitingisevil")
                        
                        -- Стекло ломаемое если атрибут существует и его значение не false
                        if attributeValue ~= nil and attributeValue ~= false then
                            isBreakable = true
                        else
                            isBreakable = false
                        end
                        
                        -- Сохраняем для будущего использования
                        MainModule.GlassBridge.BreakableTiles = MainModule.GlassBridge.BreakableTiles or {}
                        MainModule.GlassBridge.BreakableTiles[modelName] = isBreakable
                    end
                    
                    local Color = isBreakable and Color3.fromRGB(248, 87, 87) or Color3.fromRGB(28, 235, 87)
                    
                    if not MainModule.GlassBridge.OriginalColors[primaryPart] then
                        MainModule.GlassBridge.OriginalColors[primaryPart] = {
                            Color = primaryPart.Color,
                            Material = primaryPart.Material,
                            Transparency = primaryPart.Transparency
                        }
                    end
                    
                    primaryPart.Color = Color
                    primaryPart.Transparency = 0.3
                    primaryPart.Material = Enum.Material.Neon
                    
                    for _, part in pairs(tileModel:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not MainModule.GlassBridge.OriginalColors[part] then
                                MainModule.GlassBridge.OriginalColors[part] = {
                                    Color = part.Color,
                                    Material = part.Material,
                                    Transparency = part.Transparency
                                }
                            end
                            part.Color = Color
                            part.Transparency = 0.3
                            part.Material = Enum.Material.Neon
                        end
                    end
                end
            end
        end
    end)
    
    local Effects = ReplicatedStorage:FindFirstChild("Modules") and 
                   ReplicatedStorage.Modules:FindFirstChild("Effects")
    if Effects then
        local success, result = pcall(function()
            return require(Effects)
        end)
        if success and result and result.AnnouncementTween then
            result.AnnouncementTween({
                AnnouncementOneLine = true,
                FasterTween = true,
                DisplayTime = 10,
                AnnouncementDisplayText = "[CreonHub]: Glass ESP Activated! Red = Breakable, Green = Safe"
            })
        end
    end
end

function MainModule.TeleportToGlassBridgeEnd()
    SafeTeleport(MainModule.GlassBridge.EndPosition)
end

function MainModule.ToggleHNSInfinityStamina(enabled)
    MainModule.HNS.InfinityStaminaEnabled = enabled
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    if enabled then
        MainModule.HNS.InfinityStaminaConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.InfinityStaminaEnabled then return end
            task.spawn(function()
                if LocalPlayer.Character then
                    local stamina = LocalPlayer.Character:FindFirstChild("StaminaVal")
                    if stamina then
                        stamina.Value = 100
                    end
                end
            end)
        end)
    end
end

function MainModule.ToggleInstaInteract(enabled)
    MainModule.Misc.InstaInteract = enabled
    if instaInteractConnection then
        instaInteractConnection:Disconnect()
        instaInteractConnection = nil
    end
    if enabled then
        local function makePromptInstant(prompt)
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end
        instaInteractConnection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end)
    end
end

function MainModule.ToggleNoCooldownProximity(enabled)
    MainModule.Misc.NoCooldownProximity = enabled
    if noCooldownConnection then
        noCooldownConnection:Disconnect()
        noCooldownConnection = nil
    end
    if enabled then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
        noCooldownConnection = Workspace.DescendantAdded:Connect(function(obj)
            if MainModule.Misc.NoCooldownProximity then
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end
        end)
    end
end

function MainModule.GetPlayerPosition()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local position = rootPart.Position
            return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
        end
    end
    return "Не доступно"
end

MainModule.AutoDodge = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://88451099342711",
        "rbxassetid://79649041083405", 
        "rbxassetid://73242877658272",
        "rbxassetid://114928327045353",
        "rbxassetid://135690448001690", 
        "rbxassetid://103355259844069",
        "rbxassetid://125906547773381",
        "rbxassetid://121147456137931"
    },
    Connections = {},
    LastDodgeTime = 0,
    DodgeCooldown = 0.4, -- Установлен кулдаун 0.4 секунды
    Range = 5,
    RangeSquared = 5 * 5,
    AnimationIdsSet = {},
    PlayersInRange = {},
    
    -- Система перехвата
    CapturedCall = nil,
    LastCapturedCallTime = 0,
    OriginalFireServer = nil,
    Remote = nil,
    
    -- Таблица для отслеживания начавшихся анимаций
    ActiveAnimations = {}
}

-- Заполняем сет анимаций
for _, id in ipairs(MainModule.AutoDodge.AnimationIds) do
    MainModule.AutoDodge.AnimationIdsSet[id] = true
end

-- ============ СИСТЕМА ПЕРЕХВАТА ВЫЗОВОВ ============

local function setupRemoteHook()
    local remote = nil
    local rs = game:GetService("ReplicatedStorage")
    
    if rs:FindFirstChild("Remotes") then
        remote = rs.Remotes:FindFirstChild("UsedTool")
    end
    
    if not remote and rs:FindFirstChild("Events") then
        remote = rs.Events:FindFirstChild("UsedTool")
    end
    
    if not remote then
        local function searchRemote(container)
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("RemoteEvent") and child.Name == "UsedTool" then
                    return child
                end
                local found = searchRemote(child)
                if found then return found end
            end
            return nil
        end
        remote = searchRemote(rs)
    end
    
    if not remote then
        return false
    end
    
    MainModule.AutoDodge.Remote = remote
    
    MainModule.AutoDodge.OriginalFireServer = hookfunction(remote.FireServer, function(self, ...)
        local args = {...}
        
        for i, arg in ipairs(args) do
            if typeof(arg) == "Instance" and arg:IsA("Tool") then
                if arg.Name == "DODGE!" then
                    MainModule.AutoDodge.CapturedCall = {
                        args = {unpack(args)},
                        timestamp = tick(),
                        tool = arg,
                        remote = self
                    }
                    MainModule.AutoDodge.LastCapturedCallTime = tick()
                    break
                end
            elseif typeof(arg) == "table" then
                for _, v in pairs(arg) do
                    if typeof(v) == "Instance" and v:IsA("Tool") then
                        if v.Name == "DODGE!" then
                            MainModule.AutoDodge.CapturedCall = {
                                args = {unpack(args)},
                                timestamp = tick(),
                                tool = v,
                                remote = self
                            }
                            MainModule.AutoDodge.LastCapturedCallTime = tick()
                            break
                        end
                    end
                end
            end
        end
        
        return MainModule.AutoDodge.OriginalFireServer(self, ...)
    end)
    
    return true
end

-- ============ ИСПРАВЛЕННАЯ ФУНКЦИЯ ВЫПОЛНЕНИЯ ДОДЖА ============

local function executeDodge()
    if not MainModule.AutoDodge.Enabled then 
        return false 
    end
    
    local currentTime = tick()
    local autoDodge = MainModule.AutoDodge
    
    if currentTime - autoDodge.LastDodgeTime < autoDodge.DodgeCooldown then
        return false
    end
    
    if not autoDodge.CapturedCall then
        return false
    end
    
    local player = game:GetService("Players").LocalPlayer
    if not player then 
        return false 
    end
    
    local dodgeTool = nil
    local character = player.Character
    
    if character then
        dodgeTool = character:FindFirstChild("DODGE!")
    end
    
    if not dodgeTool and player:FindFirstChild("Backpack") then
        dodgeTool = player.Backpack:FindFirstChild("DODGE!")
    end
    
    if not dodgeTool then
        return false
    end
    
    local modifiedArgs = {}
    for i, arg in ipairs(autoDodge.CapturedCall.args) do
        if typeof(arg) == "Instance" and arg:IsA("Tool") and arg.Name == "DODGE!" then
            modifiedArgs[i] = dodgeTool
        else
            modifiedArgs[i] = arg
        end
    end
    
    autoDodge.LastDodgeTime = currentTime
    
    local success, err = pcall(function()
        autoDodge.Remote:FireServer(unpack(modifiedArgs))
    end)
    
    if success then
        return true
    else
        task.spawn(function()
            pcall(function()
                autoDodge.Remote:FireServer(dodgeTool)
            end)
        end)
        
        return false
    end
end

-- ============ ПРОВЕРКА ВЗГЛЯДА И РАДИУСА ============

local function isPlayerLookingAtMe(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        return false
    end
    
    local localPlayer = game:GetService("Players").LocalPlayer
    if not localPlayer or not localPlayer.Character then
        return false
    end
    
    -- Проверка радиуса
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not (targetRoot and localRoot) then
        return false
    end
    
    local distance = (targetRoot.Position - localRoot.Position).Magnitude
    if distance > MainModule.AutoDodge.Range then
        return false
    end
    
    -- Проверка взгляда
    local targetHead = targetPlayer.Character:FindFirstChild("Head")
    if not targetHead then
        return false
    end
    
    local directionToPlayer = (localRoot.Position - targetRoot.Position).Unit
    local lookVector = targetHead.CFrame.LookVector
    
    -- Угол между взглядом противника и направлением к нам
    local dot = directionToPlayer:Dot(lookVector)
    
    -- Если косинус угла больше 0.5 (угол меньше 60 градусов), значит смотрит примерно в нашу сторону
    if dot > 0.5 then
        return true
    end
    
    return false
end

-- ============ ПРОВЕРКА НАЧАЛА АНИМАЦИИ В РАДИУСЕ С ПРОВЕРКОЙ ВЗГЛЯДА ============

local function setupAnimationTracker()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local function trackPlayerAnimations(player)
        if player == LocalPlayer then return end
        
        local function connectToHumanoid(humanoid)
            humanoid.AnimationPlayed:Connect(function(track)
                if not MainModule.AutoDodge.Enabled then return end
                
                local animId = track.Animation and track.Animation.AnimationId
                if not animId or not MainModule.AutoDodge.AnimationIdsSet[animId] then
                    return
                end
                
                -- Проверяем, что анимация началась именно в нашем радиусе
                if not isPlayerLookingAtMe(player) then
                    return
                end
                
                -- Уникальный ключ для анимации (игрок + ID анимации + timestamp)
                local currentTime = math.floor(tick() * 100)
                local animationKey = tostring(player.UserId) .. "_" .. animId .. "_" .. tostring(currentTime)
                
                -- Всегда считаем это новой анимацией и доджим
                MainModule.AutoDodge.ActiveAnimations[animationKey] = true
                
                -- Запускаем додж
                executeDodge()
                
                -- Чистим через небольшое время
                task.delay(0.5, function()
                    MainModule.AutoDodge.ActiveAnimations[animationKey] = nil
                end)
            end)
        end
        
        player.CharacterAdded:Connect(function(character)
            task.wait(0.05)
            
            local humanoid = character:WaitForChild("Humanoid", 1)
            if humanoid then
                connectToHumanoid(humanoid)
            end
        end)
        
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                connectToHumanoid(humanoid)
            end
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        trackPlayerAnimations(player)
    end
    
    Players.PlayerAdded:Connect(trackPlayerAnimations)
end

-- ============ ОПТИМИЗИРОВАННЫЙ МОНИТОРИНГ ДЛЯ РЕАКЦИИ ============

local function setupInstantReactionMonitor()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    
    local lastCheckTime = 0
    
    local function instantReactionCheck()
        if not MainModule.AutoDodge.Enabled then return end
        
        local currentTime = tick()
        if currentTime - lastCheckTime < 0.01 then
            return
        end
        lastCheckTime = currentTime
        
        if not LocalPlayer or not LocalPlayer.Character then
            return
        end
        
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end
        
        local localPos = localRoot.Position
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character then continue end
            
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if not targetRoot then continue end
            
            -- Быстрая проверка дистанции
            local dx = targetRoot.Position.X - localPos.X
            local dy = targetRoot.Position.Y - localPos.Y
            local dz = targetRoot.Position.Z - localPos.Z
            local distanceSquared = dx * dx + dy * dy + dz * dz
            
            if distanceSquared > MainModule.AutoDodge.RangeSquared then
                continue
            end
            
            -- Проверка взгляда
            local targetHead = player.Character:FindFirstChild("Head")
            if not targetHead then continue end
            
            local directionToPlayer = (localPos - targetRoot.Position).Unit
            local lookVector = targetHead.CFrame.LookVector
            local dot = directionToPlayer:Dot(lookVector)
            
            if dot <= 0.5 then
                continue -- не смотрит на нас
            end
            
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if not humanoid then continue end
            
            -- Проверяем активные анимации
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track and track.Animation and track.IsPlaying then
                    local animId = track.Animation.AnimationId
                    if MainModule.AutoDodge.AnimationIdsSet[animId] then
                        -- Уникальный ключ для анимации
                        local animationKey = tostring(player.UserId) .. "_" .. animId .. "_" .. tostring(math.floor(currentTime * 100))
                        
                        if not MainModule.AutoDodge.ActiveAnimations[animationKey] then
                            MainModule.AutoDodge.ActiveAnimations[animationKey] = true
                            
                            executeDodge()
                            
                            -- Чистим через небольшое время
                            task.delay(0.5, function()
                                MainModule.AutoDodge.ActiveAnimations[animationKey] = nil
                            end)
                            
                            return
                        end
                    end
                end
            end
        end
    end
    
    local renderConn = RunService.RenderStepped:Connect(instantReactionCheck)
    table.insert(MainModule.AutoDodge.Connections, renderConn)
end

-- ============ УПРАВЛЕНИЕ СИСТЕМОЙ ============

function MainModule.ToggleAutoDodge(enabled)
    MainModule.AutoDodge.Enabled = false
    
    for _, conn in pairs(MainModule.AutoDodge.Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.AutoDodge.Connections = {}
    
    MainModule.AutoDodge.LastDodgeTime = 0
    MainModule.AutoDodge.ActiveAnimations = {}
    
    if enabled then
        MainModule.AutoDodge.Enabled = true
        
        setupAnimationTracker()
        setupInstantReactionMonitor()
    end
end

-- ============ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ============

function MainModule.ShowCapturedCall()
    if MainModule.AutoDodge.CapturedCall then
        return MainModule.AutoDodge.CapturedCall
    else
        return nil
    end
end

function MainModule.ClearCapturedCall()
    MainModule.AutoDodge.CapturedCall = nil
end

function MainModule.ForceDodge()
    local result = executeDodge()
    return result
end

-- ============ ИНИЦИАЛИЗАЦИЯ ============

task.wait(0.4)

local hookSuccess = setupRemoteHook()

task.spawn(function()
    if MainModule.AutoDodge.Enabled then
        MainModule.ToggleAutoDodge(true)
    end
end)

-- Включаем/выключаем умный ноклип
function MainModule.ToggleNoclip(enabled)
    ShowNotification("Noclip", "Don't work", 2)
end

-- Простой флай: летим туда, куда смотрим/идем
function MainModule.EnableFlight()
    if MainModule.Fly.Enabled then return end
    
    MainModule.Fly.Enabled = true
    
    local character = GetCharacter()
    if not character then return end
    
    local humanoid = GetHumanoid(character)
    local rootPart = GetRootPart(character)
    if not (humanoid and rootPart) then return end
    
    -- Создаем BodyVelocity только при полете
    local function createFlyBV()
        if MainModule.Fly.BodyVelocity then
            MainModule.Fly.BodyVelocity:Destroy()
        end
        
        local flyBV = Instance.new("BodyVelocity")
        flyBV.Name = "FlyBodyVelocity"
        flyBV.MaxForce = Vector3.new(40000, 40000, 40000)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = rootPart
        
        MainModule.Fly.BodyVelocity = flyBV
        return flyBV
    end
    
    -- Создаем BodyVelocity
    local flyBV = createFlyBV()
    
    -- Функция для получения вектора движения на мобилке
    local function getMobileMoveVector()
        local moveVector = UserInputService:GetMoveVector()
        
        if moveVector.Magnitude > 0 then
            local camera = workspace.CurrentCamera
            if not camera then return Vector3.new(0, 0, 0) end
            
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector
            
            -- Обнуляем Y компоненту у векторов направления для горизонтального движения
            lookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            rightVector = Vector3.new(rightVector.X, 0, rightVector.Z).Unit
            
            -- Комбинируем направление
            local direction = (lookVector * moveVector.Y) + (rightVector * moveVector.X)
            return direction.Unit
        end
        
        return Vector3.new(0, 0, 0)
    end
    
    -- Основной цикл полета
    MainModule.Fly.Connection = RunService.Heartbeat:Connect(function()
        if not MainModule.Fly.Enabled or not character or not character.Parent then 
            if MainModule.Fly.Connection then
                MainModule.Fly.Connection:Disconnect()
                MainModule.Fly.Connection = nil
            end
            return 
        end
        
        rootPart = GetRootPart(character)
        if not rootPart or not flyBV then 
            MainModule.DisableFlight()
            return 
        end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        -- Направление движения
        local moveDirection = Vector3.new(0, 0, 0)
        local lookVector = camera.CFrame.LookVector
        
        if MainModule.Fly.IsMobile then
            -- Для мобильных: летим в направлении виртуального джойстика
            local mobileDirection = getMobileMoveVector()
            if mobileDirection.Magnitude > 0 then
                moveDirection = mobileDirection
            else
                -- Если джойстик не используется, просто висим на месте
                moveDirection = Vector3.new(0, 0, 0)
            end
        else
            -- Для ПК: WASD управление относительно взгляда камеры
            local rightVector = camera.CFrame.RightVector
            
            -- Вперед/назад (W/S)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + lookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - lookVector
            end
            
            -- Влево/вправо (A/D)
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - rightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + rightVector
            end
        end
        
        -- Применяем скорость если есть направление
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * MainModule.Fly.Speed
            flyBV.Velocity = moveDirection
        else
            flyBV.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    -- Обработка смерти персонажа
    local function handleDeath()
        MainModule.DisableFlight()
    end
    
    if humanoid then
        humanoid.Died:Connect(handleDeath)
    end
    
    -- Обработка смены персонажа
    local characterAddedConnection
    characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        task.wait(0.5)
        
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
        
        if MainModule.Fly.Enabled then
            MainModule.DisableFlight()
            task.wait(0.1)
            MainModule.EnableFlight()
        end
    end)
end

function MainModule.DisableFlight()
    if not MainModule.Fly.Enabled then return end
    
    MainModule.Fly.Enabled = false
    
    -- Отключаем соединение
    if MainModule.Fly.Connection then
        MainModule.Fly.Connection:Disconnect()
        MainModule.Fly.Connection = nil
    end
    
    -- Удаляем BodyVelocity
    if MainModule.Fly.BodyVelocity then
        MainModule.Fly.BodyVelocity:Destroy()
        MainModule.Fly.BodyVelocity = nil
    end
    
    -- Возвращаем персонажа в нормальное состояние
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            rootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

function MainModule.ToggleFly(enabled)
    if enabled then
        ShowNotification("Fly", "Enabled", 3)
        MainModule.EnableFlight()
    else
        ShowNotification("Fly", "Disabled", 3)
        MainModule.DisableFlight()
    end
end

function MainModule.SetFlySpeed(speed)
    MainModule.Fly.Speed = math.clamp(speed, 1, 100)
    return MainModule.Fly.Speed
end

-- ULTRA SMOOTH KILLAURA v6 - МАКСИМАЛЬНАЯ СКОРОСТЬ И ПЛАВНОСТЬ
MainModule.Killaura = {
    Enabled = false,
    TeleportAnimations = {
        "79649041083405",
        "73242877658272", 
        "85793691404836",
        "86197206792061",
        "99157505926076"
    },
    Connections = {},
    CurrentTarget = nil,
    IsAttached = false,
    IsLifted = false,
    LiftHeight = 10, -- УВЕЛИЧЕНО С 8 ДО 10
    TargetAnimationsSet = {},
    
    -- УЛЬТРА-БЫСТРЫЕ ПАРАМЕТРЫ
    BehindDistance = 2,  -- Всегда вплотную сзади
    FrontDistance = 17, -- УВЕЛИЧЕНО С 12 ДО 15 БЛОКОВ
    SpeedThreshold = 18, -- Скорость для определения движения вперед
    
    -- МАКСИМАЛЬНАЯ СКОРОСТЬ И ПЛАВНОСТЬ (УВЕЛИЧЕНО НА 300%)
    MovementSpeed = 120, -- 300% УВЕЛИЧЕНИЕ
    RotationSpeed = 30,  -- 300% УВЕЛИЧЕНИЕ
    Smoothness = 0.95,   -- МАКСИМАЛЬНАЯ ПЛАВНОСТЬ
    JumpSyncSmoothness = 0.98,
    
    -- Анти-детект параметры
    MaxVelocity = 350,
    VelocitySmoothness = 0.98,
    HumanizeFactor = 0.001,
    NaturalNoise = 0.001,
    AntiDetectionMode = true,
    
    -- Внутренние переменные
    LastPosition = Vector3.new(),
    TargetLastVelocity = Vector3.new(),
    LastHeight = 0,
    JumpSync = false,
    IsJumping = false,
    JumpStartTime = 0,
    TimeOffset = 0,
    
    -- Переменные для синхронизации прыжков
    JumpData = {
        TargetJumping = false,
        JumpStartY = 0,
        JumpPeakReached = false,
        JumpVelocity = 0,
        JumpGravity = 196.2,
        JumpDuration = 0
    },
    
    -- Переменные для подъема при анимации
    AnimationLiftActive = false,
    AnimationStartTime = 0,
    OriginalGroundHeight = 0,
    WasInFrontBeforeLift = false,
    LastAnimationState = false,
    
    -- Ультра-быстрые переменные
    CurrentVelocity = Vector3.new(),
    TargetVelocity = Vector3.new(),
    LastTargetPosition = Vector3.new(),
    LastTargetVelocity = Vector3.new(),
    LastDirectionCheckTime = 0,
    
    -- Прыжковые переменные
    JumpStartAttachment = "behind",
    JumpStartDistance = 2
}

-- Инициализация анимаций
for _, animId in pairs(MainModule.Killaura.TeleportAnimations) do
    MainModule.Killaura.TargetAnimationsSet[animId] = true
end

-- СУПЕР-БЫСТРЫЙ поиск игрока
local function findClosestPlayer()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    if not localPlayer then return nil end
    
    local character = localPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local myPos = rootPart.Position
    
    -- Ищем Hider
    local hiderCharacter = MainModule.GetHider()
    if hiderCharacter then
        local targetRoot = hiderCharacter:FindFirstChild("HumanoidRootPart")
        local humanoid = hiderCharacter:FindFirstChildOfClass("Humanoid")
        
        if targetRoot and humanoid and humanoid.Health > 0 then
            for _, player in pairs(players:GetPlayers()) do
                if player.Character == hiderCharacter then
                    return player
                end
            end
        end
    end
    
    -- Если Hider не найден, ищем ближайшего игрока
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetChar = player.Character
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and humanoid and humanoid.Health > 0 then
                local distance = (targetRoot.Position - myPos).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- МГНОВЕННАЯ проверка анимаций
local animationCache = {}
local function checkTargetAnimationsInstant(targetPlayer)
    if not targetPlayer then return false end
    
    local character = targetPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local tracks = humanoid:GetPlayingAnimationTracks()
    if not tracks then return false end
    
    for _, track in pairs(tracks) do
        if track and track.Animation then
            local animId = tostring(track.Animation.AnimationId)
            local cleanId = animId:match("%d+")
            
            if cleanId and MainModule.Killaura.TargetAnimationsSet[cleanId] then
                return true
            end
        end
    end
    
    return false
end

-- МГНОВЕННАЯ проверка прыжка цели
local function checkTargetJumping(targetRoot)
    if not targetRoot then return false end
    
    local config = MainModule.Killaura
    local currentTime = tick()
    
    -- Определяем прыжок по вертикальной скорости
    local isJumpingNow = targetRoot.Velocity.Y > 8
    
    if isJumpingNow and not config.JumpData.TargetJumping then
        -- МГНОВЕННОЕ начало прыжка
        config.JumpData.TargetJumping = true
        config.JumpData.JumpStartY = targetRoot.Position.Y
        config.JumpData.JumpPeakReached = false
        config.JumpData.JumpVelocity = targetRoot.Velocity.Y
        config.JumpData.JumpStartTime = currentTime
        config.JumpSync = true
        config.IsJumping = true
        
        -- ФИКС: ПРОВЕРЯЕМ СКОРОСТЬ ТОЛЬКО ПРИ НАЧАЛЕ ПРЫЖКА
        local targetVel = targetRoot.Velocity
        local targetLook = targetRoot.CFrame.LookVector
        local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
        local horizontalSpeed = horizontalVel.Magnitude
        
        if horizontalSpeed > 2 then
            local lookDirection = Vector3.new(targetLook.X, 0, targetLook.Z).Unit
            local moveDirection = horizontalVel.Unit
            local dotProduct = lookDirection:Dot(moveDirection)
            
            -- ИСПРАВЛЕНИЕ: ДЛЯ ПРЫЖКА ВПЕРЕД НУЖНА СКОРОСТЬ >= 18
            if dotProduct > 0.7 and horizontalSpeed >= config.SpeedThreshold then
                config.JumpStartAttachment = "front"
                config.JumpStartDistance = config.FrontDistance
            else
                -- Прыгаем назад/вбок/стоя - сзади вплотную
                config.JumpStartAttachment = "behind"
                config.JumpStartDistance = config.BehindDistance
            end
        else
            -- Стоит на месте - прыгаем сзади
            config.JumpStartAttachment = "behind"
            config.JumpStartDistance = config.BehindDistance
        end
        
    elseif config.JumpData.TargetJumping then
        -- МГНОВЕННОЕ обновление прыжка
        config.JumpData.JumpDuration = currentTime - config.JumpData.JumpStartTime
        
        -- Проверяем пик прыжка
        if targetRoot.Velocity.Y < 0 and not config.JumpData.JumpPeakReached then
            config.JumpData.JumpPeakReached = true
        end
        
        -- Проверяем окончание прыжка
        if targetRoot.Velocity.Y > -2 and targetRoot.Velocity.Y < 2 and 
           math.abs(targetRoot.Position.Y - config.JumpData.JumpStartY) < 1 then
            config.JumpData.TargetJumping = false
            config.JumpSync = false
            config.IsJumping = false
            config.JumpStartAttachment = "behind"
            config.JumpStartDistance = config.BehindDistance
        end
    end
    
    return config.JumpData.TargetJumping
end

-- МГНОВЕННОЕ определение направления движения
local function getTargetMovementDirection(targetRoot)
    if not targetRoot then return "idle" end
    
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    
    local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
    local horizontalSpeed = horizontalVel.Magnitude
    
    if horizontalSpeed < 2 then
        return "idle"
    end
    
    local lookDirection = Vector3.new(targetLook.X, 0, targetLook.Z).Unit
    local moveDirection = horizontalVel.Unit
    
    local dotProduct = lookDirection:Dot(moveDirection)
    
    if dotProduct > 0.7 then
        return "forward"
    elseif dotProduct < -0.7 then
        return "backward"
    elseif math.abs(dotProduct) < 0.3 then
        return "sideways"
    else
        return "diagonal"
    end
end

-- УЛЬТРА-БЫСТРАЯ обработка подъема при анимации
local function handleAnimationLift(localRoot, targetPos, targetLook, targetVel, deltaTime)
    local config = MainModule.Killaura
    
    if not config.CurrentTarget then 
        config.AnimationLiftActive = false
        config.IsLifted = false
        config.LastAnimationState = false
        return false 
    end
    
    -- МГНОВЕННАЯ проверка анимации
    local isAnimating = checkTargetAnimationsInstant(config.CurrentTarget)
    
    local animationStateChanged = isAnimating ~= config.LastAnimationState
    config.LastAnimationState = isAnimating
    
    if isAnimating and not config.AnimationLiftActive then
        -- МГНОВЕННЫЙ подъем
        config.AnimationLiftActive = true
        config.OriginalGroundHeight = localRoot.Position.Y
        
        -- Определяем позиционирование
        local targetRoot = config.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local horizontalSpeed = Vector3.new(targetVel.X, 0, targetVel.Z).Magnitude
            local movementDir = getTargetMovementDirection(targetRoot)
            config.WasInFrontBeforeLift = (movementDir == "forward") and horizontalSpeed >= config.SpeedThreshold
        else
            config.WasInFrontBeforeLift = false
        end
        
        config.IsLifted = true
        
        -- МГНОВЕННЫЙ подъем на 10 блоков
        local targetHeight = config.OriginalGroundHeight + config.LiftHeight
        local currentPos = localRoot.Position
        local newPos = Vector3.new(currentPos.X, targetHeight, currentPos.Z)
        localRoot.CFrame = CFrame.new(newPos, targetPos)
        
        return true
        
    elseif not isAnimating and config.AnimationLiftActive then
        -- МГНОВЕННЫЙ спуск
        config.AnimationLiftActive = false
        
        local currentHeight = localRoot.Position.Y
        local targetGroundHeight = config.OriginalGroundHeight
        
        if currentHeight > targetGroundHeight + 0.1 then
            -- СУПЕР-БЫСТРЫЙ спуск
            local descentSpeed = 100
            local newHeight = currentHeight - descentSpeed * deltaTime
            
            if newHeight < targetGroundHeight then
                newHeight = targetGroundHeight
                config.IsLifted = false
                config.WasInFrontBeforeLift = false
            end
            
            local newPos = Vector3.new(localRoot.Position.X, newHeight, localRoot.Position.Z)
            localRoot.CFrame = CFrame.new(newPos, targetPos)
            return true
        else
            config.IsLifted = false
            config.WasInFrontBeforeLift = false
            return false
        end
    end
    
    -- Поддержание высоты
    if config.AnimationLiftActive and config.IsLifted then
        local targetHeight = config.OriginalGroundHeight + config.LiftHeight
        local currentHeight = localRoot.Position.Y
        
        if math.abs(currentHeight - targetHeight) > 0.1 then
            -- МГНОВЕННАЯ коррекция высоты
            local correctionSpeed = 200
            local heightDiff = targetHeight - currentHeight
            local newHeight = currentHeight + heightDiff * correctionSpeed * deltaTime
            
            local newPos = Vector3.new(localRoot.Position.X, newHeight, localRoot.Position.Z)
            localRoot.CFrame = CFrame.new(newPos, targetPos)
        end
        
        return true
    end
    
    return config.AnimationLiftActive
end

-- СУПЕР-БЫСТРАЯ синхронизация прыжка
local function syncJumpHeight(localRoot, targetRoot, targetPos, deltaTime)
    local config = MainModule.Killaura
    
    if not config.JumpSync or not config.IsJumping then
        return false
    end
    
    local targetHeight = targetRoot.Position.Y
    local myHeight = localRoot.Position.Y
    local heightDiff = targetHeight - myHeight
    
    -- Сохраняем позицию
    if not config.JumpStartPosition then
        config.JumpStartPosition = localRoot.Position
    end
    
    -- МГНОВЕННАЯ синхронизация высоты
    if math.abs(heightDiff) > 0.05 then
        local jumpForce = heightDiff * deltaTime * 200
        
        local newHeight = myHeight + jumpForce
        
        local horizontalPos = Vector3.new(
            localRoot.Position.X,
            newHeight,
            localRoot.Position.Z
        )
        
        localRoot.CFrame = CFrame.new(horizontalPos, Vector3.new(targetPos.X, newHeight, targetPos.Z))
        return true
    end
    
    return false
end

-- МГНОВЕННОЕ определение позиционирования
local function getSmartPositioning(targetRoot)
    local config = MainModule.Killaura
    
    if not targetRoot then 
        return "behind", config.BehindDistance
    end
    
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    
    local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
    local horizontalSpeed = horizontalVel.Magnitude
    
    -- Если прыгаем - используем запомненное позиционирование
    if config.IsJumping then
        return config.JumpStartAttachment, config.JumpStartDistance
    end
    
    -- Если скорость меньше пороговой - всегда сзади
    if horizontalSpeed < config.SpeedThreshold then
        return "behind", config.BehindDistance
    end
    
    -- Определяем направление
    local movementDir = getTargetMovementDirection(targetRoot)
    
    -- ИСПРАВЛЕНИЕ: ТОЛЬКО при движении ВПЕРЕД и скорости >= 18
    if movementDir == "forward" and horizontalSpeed >= config.SpeedThreshold then
        return "front", config.FrontDistance
    else
        -- Все остальные случаи - сзади вплотную
        return "behind", config.BehindDistance
    end
end

-- УЛЬТРА-БЫСТРОЕ движение (300% БЫСТРЕЕ)
local function ultraFastMovement(localRoot, targetPos, targetLook, deltaTime, isAnimationLift)
    local config = MainModule.Killaura
    
    -- Получаем цель для позиционирования
    local targetRoot = nil
    if config.CurrentTarget and config.CurrentTarget.Character then
        targetRoot = config.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
    end
    
    -- УМНОЕ ПОЗИЦИОНИРОВАНИЕ
    local attachmentType, desiredDistance = getSmartPositioning(targetRoot)
    
    -- Если в режиме подъема и мы были впереди - сохраняем это
    if isAnimationLift and config.WasInFrontBeforeLift then
        attachmentType = "front"
        desiredDistance = config.FrontDistance
    end
    
    -- Вычисляем целевую позицию
    local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
    local targetGroundPos = targetPos + desiredOffset
    
    -- Если поднятие при анимации - добавляем 10 блоков высоты
    if isAnimationLift then
        targetGroundPos = Vector3.new(
            targetGroundPos.X,
            config.OriginalGroundHeight + config.LiftHeight,
            targetGroundPos.Z
        )
    end
    
    -- МГНОВЕННОЕ движение
    local currentPos = localRoot.Position
    local direction = targetGroundPos - currentPos
    local distance = direction.Magnitude
    
    if distance > 0.01 then
        -- СУПЕР-БЫСТРОЕ ускорение
        local targetSpeed = math.min(config.MovementSpeed, distance * 100)
        
        -- МГНОВЕННОЕ изменение скорости
        config.CurrentVelocity = direction.Unit * targetSpeed
        
        -- МГНОВЕННОЕ перемещение
        local moveStep = config.CurrentVelocity * deltaTime
        
        if moveStep.Magnitude > distance then
            moveStep = direction
        end
        
        local newPos = currentPos + moveStep
        
        -- Фиксация высоты при подъеме
        if isAnimationLift then
            local targetHeight = config.OriginalGroundHeight + config.LiftHeight
            newPos = Vector3.new(newPos.X, targetHeight, newPos.Z)
        end
        
        -- СУПЕР-БЫСТРЫЙ поворот
        local lookAtPos = Vector3.new(targetPos.X, newPos.Y, targetPos.Z)
        local targetCF = CFrame.new(newPos, lookAtPos)
        
        -- МГНОВЕННАЯ интерполяция
        localRoot.CFrame = localRoot.CFrame:Lerp(targetCF, config.RotationSpeed * deltaTime)
        
        -- МГНОВЕННОЕ обновление скорости
        localRoot.Velocity = config.CurrentVelocity
        
    else
        -- Фиксация позиции
        if isAnimationLift then
            local targetHeight = config.OriginalGroundHeight + config.LiftHeight
            local fixedPos = Vector3.new(targetGroundPos.X, targetHeight, targetGroundPos.Z)
            localRoot.CFrame = CFrame.new(fixedPos, targetPos)
        else
            localRoot.CFrame = CFrame.new(targetGroundPos, targetPos)
        end
        
        -- МГНОВЕННЫЙ останов
        config.CurrentVelocity = Vector3.new(0, 0, 0)
        localRoot.Velocity = config.CurrentVelocity
    end
    
    config.LastTargetPosition = targetPos
end

-- ОСНОВНАЯ ФУНКЦИЯ - МАКСИМАЛЬНАЯ СКОРОСТЬ
local function ultraFastSync(targetRoot, targetHumanoid, localRoot, deltaTime)
    local config = MainModule.Killaura
    
    -- МГНОВЕННЫЕ данные цели
    local targetPos = targetRoot.Position
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    
    -- МГНОВЕННАЯ проверка прыжка
    local isTargetJumping = checkTargetJumping(targetRoot)
    
    -- МГНОВЕННАЯ обработка подъема
    local isAnimationLift = handleAnimationLift(localRoot, targetPos, targetLook, targetVel, deltaTime)
    
    -- МГНОВЕННАЯ синхронизация прыжка
    if isTargetJumping and not isAnimationLift then
        syncJumpHeight(localRoot, targetRoot, targetPos, deltaTime)
    elseif config.IsJumping and not isTargetJumping then
        config.IsJumping = false
        config.JumpSync = false
        config.JumpStartPosition = nil
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = config.BehindDistance
    end
    
    -- ВЫПОЛНЯЕМ УЛЬТРА-БЫСТРОЕ ДВИЖЕНИЕ
    ultraFastMovement(localRoot, targetPos, targetLook, deltaTime, isAnimationLift)
    
    -- Быстрая гравитация
    if not isAnimationLift and not config.IsJumping and not config.IsLifted then
        local rayOrigin = localRoot.Position + Vector3.new(0, 1, 0)
        local ray = Ray.new(rayOrigin, Vector3.new(0, -4, 0))
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {localRoot.Parent})
        
        if hit then
            local heightDiff = localRoot.Position.Y - rayOrigin.Y + 4
            if heightDiff > 3.0 then
                localRoot.Velocity = Vector3.new(0, -80, 0)
            elseif heightDiff < 2.0 then
                localRoot.Velocity = Vector3.new(0, 50, 0)
            end
        end
    end
    
    -- МГНОВЕННОЕ сохранение данных
    config.LastPosition = localRoot.Position
    config.TargetLastVelocity = targetVel
    config.LastDirectionCheckTime = tick()
end

-- МГНОВЕННАЯ проверка цели
local function checkAndSwitchTarget()
    local config = MainModule.Killaura
    
    if not config.Enabled then return false end
    
    local currentTarget = config.CurrentTarget
    
    if currentTarget then
        local targetChar = currentTarget.Character
        if not targetChar then return false end
        
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return false end
        
        local localPlayer = game:GetService("Players").LocalPlayer
        if localPlayer and localPlayer.Character then
            local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            
            if localRoot and targetRoot then
                local distance = (targetRoot.Position - localRoot.Position).Magnitude
                if distance > 250 then return false end
            end
        end
        
        return true
    end
    
    return false
end

-- ГЛАВНЫЙ ЦИКЛ - МАКСИМАЛЬНАЯ ПРОИЗВОДИТЕЛЬНОСТЬ
local function updateUltraFastSync(deltaTime)
    if not MainModule.Killaura.Enabled then return end
    
    local localPlayer = game:GetService("Players").LocalPlayer
    if not localPlayer then return end
    
    local character = localPlayer.Character
    if not character then return end
    
    local localRoot = character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    local config = MainModule.Killaura
    
    -- МГНОВЕННАЯ проверка цели
    if not checkAndSwitchTarget() then
        config.CurrentTarget = nil
        config.IsAttached = false
        config.AnimationLiftActive = false
        config.IsLifted = false
        config.IsJumping = false
        config.JumpSync = false
        config.JumpStartPosition = nil
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = config.BehindDistance
        
        local closestPlayer = findClosestPlayer()
        if closestPlayer then
            config.CurrentTarget = closestPlayer
            config.IsAttached = true
            config.LastAnimationState = false
            
            -- МГНОВЕННАЯ телепортация
            local targetChar = closestPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if localRoot and targetRoot then
                local targetLook = targetRoot.CFrame.LookVector
                local targetVel = targetRoot.Velocity
                local horizontalSpeed = Vector3.new(targetVel.X, 0, targetVel.Z).Magnitude
                
                -- Определяем начальную позицию
                local attachmentType, desiredDistance
                if horizontalSpeed >= config.SpeedThreshold and getTargetMovementDirection(targetRoot) == "forward" then
                    attachmentType = "front"
                    desiredDistance = config.FrontDistance
                else
                    attachmentType = "behind"
                    desiredDistance = config.BehindDistance
                end
                
                local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
                local startPos = targetRoot.Position + desiredOffset
                
                -- МГНОВЕННОЕ перемещение
                localRoot.CFrame = CFrame.new(startPos, targetRoot.Position)
                
                config.LastPosition = startPos
                config.OriginalGroundHeight = startPos.Y
                config.CurrentVelocity = Vector3.new(0, 0, 0)
                config.JumpStartAttachment = attachmentType
                config.JumpStartDistance = desiredDistance
            end
        else
            task.delay(0.05, function()
                if config.Enabled and not config.CurrentTarget then
                    MainModule.ToggleKillaura(false)
                end
            end)
            return
        end
    end
    
    if not config.CurrentTarget or not config.IsAttached then return end
    
    -- МГНОВЕННОЕ получение данных цели
    local targetChar = config.CurrentTarget.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    
    if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
        config.CurrentTarget = nil
        config.IsAttached = false
        return
    end
    
    -- ВЫПОЛНЯЕМ УЛЬТРА-БЫСТРУЮ СИНХРОНИЗАЦИЮ
    ultraFastSync(targetRoot, targetHumanoid, localRoot, deltaTime)
end

-- ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ - МАКСИМАЛЬНАЯ СКОРОСТЬ
function MainModule.ToggleKillaura(enabled)
    local config = MainModule.Killaura
    
    if config.Enabled == enabled then return end
    
    if enabled then
        if not findClosestPlayer() then return end
    end
    
    config.Enabled = enabled
    
    -- Быстрая очистка
    for _, conn in pairs(config.Connections) do
        if conn then conn:Disconnect() end
    end
    config.Connections = {}
    
    if not enabled then
        config.CurrentTarget = nil
        config.IsAttached = false
        config.IsLifted = false
        config.IsJumping = false
        config.AnimationLiftActive = false
        config.LastAnimationState = false
        config.JumpSync = false
        config.JumpStartPosition = nil
        config.CurrentVelocity = Vector3.new(0, 0, 0)
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = config.BehindDistance
        return
    end
    
    -- МГНОВЕННОЕ включение
    local closestPlayer = findClosestPlayer()
    if closestPlayer then
        config.CurrentTarget = closestPlayer
        config.IsAttached = true
        config.LastAnimationState = false
        
        -- Сброс состояний
        config.AnimationLiftActive = false
        config.IsLifted = false
        config.IsJumping = false
        config.JumpSync = false
        config.JumpStartPosition = nil
        config.CurrentVelocity = Vector3.new(0, 0, 0)
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = config.BehindDistance
        
        -- МГНОВЕННАЯ установка позиции
        local localPlayer = game:GetService("Players").LocalPlayer
        if localPlayer and localPlayer.Character then
            local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetChar = closestPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if localRoot and targetRoot then
                local targetLook = targetRoot.CFrame.LookVector
                local targetVel = targetRoot.Velocity
                local horizontalSpeed = Vector3.new(targetVel.X, 0, targetVel.Z).Magnitude
                
                -- Определяем начальную позицию
                local attachmentType, desiredDistance
                if horizontalSpeed >= config.SpeedThreshold and getTargetMovementDirection(targetRoot) == "forward" then
                    attachmentType = "front"
                    desiredDistance = config.FrontDistance
                else
                    attachmentType = "behind"
                    desiredDistance = config.BehindDistance
                end
                
                local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
                local startPos = targetRoot.Position + desiredOffset
                
                -- МГНОВЕННОЕ начало
                localRoot.CFrame = CFrame.new(startPos, targetRoot.Position)
                
                config.LastPosition = startPos
                config.OriginalGroundHeight = startPos.Y
                config.CurrentVelocity = Vector3.new(0, 0, 0)
                config.JumpStartAttachment = attachmentType
                config.JumpStartDistance = desiredDistance
            end
        end
    else
        config.Enabled = false
        return
    end
    
    -- ГЛАВНЫЙ ЦИКЛ - МАКСИМАЛЬНАЯ ПРОИЗВОДИТЕЛЬНОСТЬ
    local heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if not config.Enabled then return end
        updateUltraFastSync(deltaTime)
    end)
    
    table.insert(config.Connections, heartbeatConn)
    
    -- Быстрые обработчики
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    if localPlayer then
        local charConn = localPlayer.CharacterAdded:Connect(function()
            if not config.Enabled then return end
            
            task.wait(0.1)
            
            config.CurrentTarget = nil
            config.IsAttached = false
            config.IsLifted = false
            config.IsJumping = false
            config.AnimationLiftActive = false
            config.LastAnimationState = false
            config.JumpSync = false
            config.JumpStartPosition = nil
            config.CurrentVelocity = Vector3.new(0, 0, 0)
            config.JumpStartAttachment = "behind"
            config.JumpStartDistance = config.BehindDistance
            
            local closestPlayer = findClosestPlayer()
            if closestPlayer then
                config.CurrentTarget = closestPlayer
                config.IsAttached = true
            else
                MainModule.ToggleKillaura(false)
            end
        end)
        table.insert(config.Connections, charConn)
    end
    
    local removeConn = players.PlayerRemoving:Connect(function(player)
        if config.Enabled and config.CurrentTarget == player then
            config.CurrentTarget = nil
            config.IsAttached = false
            config.AnimationLiftActive = false
            config.LastAnimationState = false
            config.JumpSync = false
            config.JumpStartPosition = nil
            config.CurrentVelocity = Vector3.new(0, 0, 0)
            config.JumpStartAttachment = "behind"
            config.JumpStartDistance = config.BehindDistance
            
            local closestPlayer = findClosestPlayer()
            if closestPlayer then
                config.CurrentTarget = closestPlayer
                config.IsAttached = true
            else
                task.delay(0.1, function()
                    if config.Enabled and not config.CurrentTarget then
                        MainModule.ToggleKillaura(false)
                    end
                end)
            end
        end
    end)
    table.insert(config.Connections, removeConn)
end

-- Функции для горячих клавиш
function MainModule.SetFlyHotkey(keyCode)
    MainModule.Fly.CurrentHotkey = keyCode
end

function MainModule.SetNoclipHotkey(keyCode)
    MainModule.Noclip.CurrentHotkey = keyCode
end

function MainModule.SetKillauraHotkey(keyCode)
    MainModule.Killaura.CurrentHotkey = keyCode
end

-- Основные функции телепорта
function MainModule.TeleportToHider()
    local hider = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if IsHider(player) then
                    hider = player
                    break
                end
            end
        end
    end
    
    if hider and hider.Character then
        local rootPart = GetRootPart(hider.Character)
        if rootPart then
            SafeTeleport(rootPart.Position)
            return true
        end
    end
    return false
end

function MainModule.GetHider()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and IsHider(player) then
                return player.Character
            end
        end
    end
    return nil
end

function MainModule.Cleanup()
    -- Отключаем все основные соединения
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, bypassRagdollConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Очищаем ESP
    MainModule.ClearESP()
    
    -- Отключаем RLGL
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.RLGL.PocketSandCheck then
        MainModule.RLGL.PocketSandCheck:Disconnect()
        MainModule.RLGL.PocketSandCheck = nil
    end
    
    -- Отключаем Rebel
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    
    -- Отключаем HNS
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    -- Отключаем SpikesKillFeature
    if MainModule.SpikesKillFeature.AnimationConnection then
        MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationConnection = nil
    end
    
    if MainModule.SpikesKillFeature.CharacterAddedConnection then
        MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKillFeature.CharacterAddedConnection = nil
    end
    
    if MainModule.SpikesKillFeature.SafetyCheckConnection then
        MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.SafetyCheckConnection = nil
    end
    
    if MainModule.SpikesKillFeature.AnimationCheckConnection then
        MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationCheckConnection = nil
    end
    
    if MainModule.SpikesKillFeature.KnifeCheckConnection then
        MainModule.SpikesKillFeature.KnifeCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.KnifeCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKillFeature.AnimationStoppedConnections = {}
    
    -- Отключаем VoidKillFeature
    if MainModule.VoidKillFeature.AnimationConnection then
        MainModule.VoidKillFeature.AnimationConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationConnection = nil
    end
    
    if MainModule.VoidKillFeature.CharacterAddedConnection then
        MainModule.VoidKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.VoidKillFeature.CharacterAddedConnection = nil
    end
    
    if MainModule.VoidKillFeature.AnimationCheckConnection then
        MainModule.VoidKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.VoidKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.VoidKillFeature.AnimationStoppedConnections = {}
    
    -- Отключаем ZoneKillFeature
    if MainModule.ZoneKillFeature.AnimationConnection then
        MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationConnection = nil
    end
    
    if MainModule.ZoneKillFeature.CharacterAddedConnection then
        MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.ZoneKillFeature.CharacterAddedConnection = nil
    end
    
    if MainModule.ZoneKillFeature.AnimationCheckConnection then
        MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationCheckConnection = nil
    end
    
    -- ИСПРАВЛЕНО: ZoneCheckConnection был объявлен, но не создавался в ZoneKillFeature
    -- Добавлен для совместимости с вашим исходным кодом
    if MainModule.ZoneKillFeature.ZoneCheckConnection then
        MainModule.ZoneKillFeature.ZoneCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.ZoneCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
    
    -- Отключаем GlassBridge
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if MainModule.GlassBridge.GlassESPConnection then
        MainModule.GlassBridge.GlassESPConnection:Disconnect()
        MainModule.GlassBridge.GlassESPConnection = nil
    end
    
    -- Отключаем JumpRope (Connection не был объявлен в структуре, но добавлен для совместимости)
    if MainModule.JumpRope.Connection then
        MainModule.JumpRope.Connection:Disconnect()
        MainModule.JumpRope.Connection = nil
    end
    
    -- Отключаем SkySquid (Connection не был объявлен в структуре, но добавлен для совместимости)
    if MainModule.SkySquid.Connection then
        MainModule.SkySquid.Connection:Disconnect()
        MainModule.SkySquid.Connection = nil
    end
    
    -- Отключаем TugOfWar
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end
    
    -- Отключаем Hitbox
    if MainModule.Hitbox.Connection then
        MainModule.Hitbox.Connection:Disconnect()
        MainModule.Hitbox.Connection = nil
    end
    
    -- Отключаем AntiTimeStop
    if MainModule.AntiTimeStop.Connection then
        MainModule.AntiTimeStop.Connection:Disconnect()
        MainModule.AntiTimeStop.Connection = nil
    end
    
    -- Отключаем Killaura
    for _, conn in pairs(MainModule.Killaura.Connections) do
        if conn then conn:Disconnect() end
    end
    MainModule.Killaura.Connections = {}
    
    -- Отключаем AutoDodge
    for _, conn in pairs(MainModule.AutoDodge.Connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    MainModule.AutoDodge.Connections = {}
    
    -- Отключаем Fly
    MainModule.DisableFlight()
    
    -- Сбрасываем состояние Fly
    MainModule.Fly.Enabled = false
    MainModule.Fly.Speed = 39
    MainModule.Fly.Connection = nil
    MainModule.Fly.BodyVelocity = nil
    MainModule.Fly.BodyGyro = nil
    MainModule.Fly.HumanoidDiedConnection = nil
    MainModule.Fly.CharacterAddedConnection = nil
    
    -- ИСПРАВЛЕНО: SpeedChangeConnection не был объявлен в структуре Fly
    if MainModule.Fly.SpeedChangeConnection then
        MainModule.Fly.SpeedChangeConnection:Disconnect()
        MainModule.Fly.SpeedChangeConnection = nil
    end
    
    -- Отключаем Noclip
    if MainModule.Noclip.Connection then
        MainModule.Noclip.Connection:Disconnect()
        MainModule.Noclip.Connection = nil
    end
    
    -- Отключаем защиту от ragdoll
    MainModule.StopEnhancedProtection()
    MainModule.StopJointCleaning()
    
    -- Восстанавливаем коллизии для частей Noclip
    -- ИСПРАВЛЕНО: Используем правильную структуру данных из MainModule.Noclip
    for part, _ in pairs(MainModule.Noclip.OriginalProperties) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = true
            end)
        end
    end
    MainModule.Noclip.OriginalProperties = {}
    MainModule.Noclip.TransparentParts = {}
    
    -- Восстанавливаем хитбоксы игроков
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and MainModule.Hitbox.ModifiedParts[root] then
                root.Size = MainModule.Hitbox.ModifiedParts[root]
                root.CanCollide = true
            end
        end
    end
    MainModule.Hitbox.ModifiedParts = {}
    
    -- Восстанавливаем оригинальные значения патронов
    for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalAmmo = {}
    
    -- Восстанавливаем оригинальные значения скорострельности
    for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalFireRates = {}
    
    -- Восстанавливаем оригинальные свойства для AntiTimeStop
    for humanoid, properties in pairs(MainModule.AntiTimeStop.OriginalProperties) do
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = properties.WalkSpeed
            humanoid.JumpPower = properties.JumpPower
        end
    end
    MainModule.AntiTimeStop.OriginalProperties = {}
    
    -- Удаляем платформы GlassBridge
    for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.GlassPlatforms = {}
    
    -- Восстанавливаем оригинальные цвета GlassBridge
    for part, properties in pairs(MainModule.GlassBridge.OriginalColors) do
        if part and part.Parent then
            pcall(function()
                part.Color = properties.Color
                part.Material = properties.Material
                part.Transparency = properties.Transparency
            end)
        end
    end
    MainModule.GlassBridge.OriginalColors = {}
    MainModule.GlassBridge.OriginalMaterials = {}
    MainModule.GlassBridge.OriginalTransparency = {}
    
    -- Удаляем анти-падение GlassBridge
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.RemoveGlassBridgeAntiFall()
    end
    
    -- Удаляем анти-падение SkySquid
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.RemoveSkySquidAntiFall()
    end
    
    -- Удаляем анти-падение JumpRope
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.RemoveJumpRopeAntiFall()
    end
    
    -- ИСПРАВЛЕНО: VoidKillFeature использует свою собственную платформу
    if MainModule.VoidKillFeature.AntiFallPlatform and MainModule.VoidKillFeature.AntiFallPlatform.Parent then
        MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
        MainModule.VoidKillFeature.AntiFallPlatform = nil
    end
    MainModule.VoidKillFeature.AntiFallEnabled = false
    
    -- Отключаем функции вызовом соответствующих методов
    if MainModule.SpeedHack.Enabled then
        MainModule.ToggleSpeedHack(false)
    end
    
    if MainModule.Noclip.Enabled then
        MainModule.ToggleNoclip(false)
    end
    
    if MainModule.Killaura.Enabled then
        MainModule.ToggleKillaura(false)
    end
    
    if MainModule.AutoDodge.Enabled then
        MainModule.ToggleAutoDodge(false)
    end
    
    if MainModule.Fly.Enabled then
        MainModule.ToggleFly(false)
    end
    
    -- Сбрасываем все флаги состояния
    MainModule.SpeedHack.Enabled = false
    MainModule.SpeedHack.CurrentSpeed = 16
    MainModule.Noclip.Enabled = false
    MainModule.AutoDodge.Enabled = false
    MainModule.Killaura.Enabled = false
    MainModule.Fly.Enabled = false
    MainModule.AutoQTE.AntiStunEnabled = false
    MainModule.Rebel.Enabled = false
    MainModule.RLGL.GodMode = false
    MainModule.Guards.AutoFarm = false
    MainModule.Guards.RapidFire = false
    MainModule.Guards.InfiniteAmmo = false
    MainModule.Guards.HitboxExpander = false
    MainModule.Hitbox.Enabled = false
    MainModule.AntiTimeStop.Enabled = false
    MainModule.HNS.InfinityStaminaEnabled = false
    MainModule.Misc.ESPEnabled = false
    MainModule.Misc.InstaInteract = false
    MainModule.Misc.NoCooldownProximity = false
    MainModule.Misc.BypassRagdollEnabled = false
    MainModule.TugOfWar.AutoPull = false
    MainModule.Dalgona.CompleteEnabled = false
    MainModule.Dalgona.FreeLighterEnabled = false
    MainModule.GlassBridge.AntiBreakEnabled = false
    MainModule.GlassBridge.AntiFallEnabled = false
    MainModule.GlassBridge.GlassESPEnabled = false
    MainModule.SpikesKillFeature.Enabled = false
    MainModule.SpikesKillFeature.TrackedAnimations = {}
    MainModule.SpikesKillFeature.SpikesRemoved = false
    MainModule.SpikesKillFeature.OriginalSpikes = {}
    MainModule.SpikesKillFeature.SpikesPosition = nil
    MainModule.SpikesKillFeature.HasKnife = false
    MainModule.VoidKillFeature.Enabled = false
    MainModule.VoidKillFeature.TrackedAnimations = {}
    MainModule.ZoneKillFeature.Enabled = false
    MainModule.ZoneKillFeature.TrackedAnimations = {}
    MainModule.FreeDash.Enabled = false
    MainModule.FreeDashGuards.Enabled = false
    
    ShowNotification("Cleanup", "All features disabled", 3)
end

LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
