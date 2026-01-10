local MainModule = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

function MainModule.ShowNotification(title, text, duration)
    duration = duration or 3
    task.spawn(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "NotificationGui"
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.ResetOnSpawn = false
        gui.Parent = game:GetService("CoreGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 320, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.Position = UDim2.new(1, 400, 0.05, 0)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        frame.BorderSizePixel = 0
        frame.ZIndex = 99999
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(60, 60, 60)
        stroke.Thickness = 2
        stroke.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -20, 0, 25)
        titleLabel.Position = UDim2.new(0, 10, 0, 10)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 100000
        titleLabel.Parent = frame

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -20, 0, 0)
        textLabel.Position = UDim2.new(0, 10, 0, 35)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        textLabel.TextSize = 13
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.TextWrapped = true
        textLabel.AutomaticSize = Enum.AutomaticSize.Y
        textLabel.ZIndex = 100000
        textLabel.Parent = frame

        frame.Size = UDim2.new(0, 320, 0, textLabel.TextBounds.Y + 45)

        -- Анимация выезда
        local slideIn = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -340, 0.05, 0)
        })
        slideIn:Play()

        task.wait(duration)

        -- Анимация выезда обратно
        local slideOut = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 400, 0.05, 0)
        })
        slideOut:Play()

        task.wait(0.4)
        gui:Destroy()
    end)
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

local function IsGameActive(gameName)
    local values = Workspace:FindFirstChild("Values")
    if not values then return false end
    local currentGame = values:FindFirstChild("CurrentGame")
    if not currentGame then return false end
    return currentGame.Value == gameName
end

local function SafeTeleport(position)
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            rootPart.CFrame = CFrame.new(position)
            return true
        end
    end
    return false
end

local function GetEnemies()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(enemies, player.Name)
        end
    end
    return enemies
end

local function KillEnemy(enemyName)
    local enemy = Players:FindFirstChild(enemyName)
    if enemy and enemy.Character then
        local humanoid = enemy.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(100)
        end
    end
end

MainModule.Fly = {
    Enabled = false,
    Speed = 39,
    Connection = nil,
    BodyVelocity = nil,
    IsMobile = UserInputService.TouchEnabled
}

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

-- Функции для горячих клавиш
function MainModule.SetFlyHotkey(keyCode)
    MainModule.Fly.CurrentHotkey = keyCode
end

-- Функции проверки ролей для HideAndSeek
local function IsSeeker(player)
    if not player then return false end
    return player:GetAttribute("IsHunter") == true
end

local function IsHider(player)
    if not player then return false end
    return player:GetAttribute("IsHider") == true
end

-- Функция проверки активной игры
local function GetCurrentGame()
    local workspace = game:GetService("Workspace")
    
    -- Проверка HideAndSeek
    if workspace:FindFirstChild("HideAndSeek") then
        return "HideAndSeek"
    end
    
    -- Проверка LightsOut / LightOut
    if workspace:FindFirstChild("LightsOut") or workspace:FindFirstChild("LightOut") then
        return "LightsOut"
    end
    
    -- Проверка других игр по дополнительным признакам
    if workspace:FindFirstChild("SquidGame") then
        return "SquidGame"
    end
    
    -- Если нет явных признаков, возвращаем nil (любая другая игра)
    return nil
end

function MainModule.GetHider()
    local players = game:GetService("Players")
    local LocalPlayer = players.LocalPlayer
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if player:GetAttribute("IsHider") == true then
                    return player.Character
                end
            end
        end
    end
    return nil
end

-- ULTRA SMOOTH KILLAURA v6.3 - СИНХРОННАЯ ВЕРСИЯ (ИСПРАВЛЕНА ПОТЕРЯ ЦЕЛИ)
MainModule.Killaura = {
    Enabled = false,
    TeleportAnimations = {
        "79649041083405",
        "73242877658272", 
        "85793691404836",
        "86197206792061",
        "99157505926076"
    },
    -- НОВАЯ АНИМАЦИЯ ДЛЯ ОТКЛЮЧЕНИЯ КИЛЛАУРЫ
    DisableAnimationId = "105341857343164",
    Connections = {},
    CurrentTarget = nil,
    IsAttached = false,
    IsLifted = false,
    LiftHeight = 10,
    TargetAnimationsSet = {},
    
    -- НОВЫЕ ПЕРЕМЕННЫЕ ДЛЯ ОТКЛЮЧЕНИЯ ПО АНИМАЦИИ
    ShouldDisableForAnimation = false,
    IsDisabledByAnimation = false,
    LastDisableTime = 0,
    DisableAnimationCooldown = 0.5,
    WasEnabledBeforeAnimation = false,
    
    -- ОПТИМИЗИРОВАННЫЕ ПАРАМЕТРЫ ДЛЯ СИНХРОННОСТИ
    BehindDistance = 2,
    FrontDistance = 18,
    SpeedThreshold = 18,
    
    -- ИСПРАВЛЕННЫЕ ПАРАМЕТРЫ ДЛЯ УДЕРЖАНИЯ ЦЕЛИ
    MaxDistance = 350,  -- Увеличенный диапазон
    TeleportSearchRange = 500,  -- Диапазон поиска для телепортации
    LostTargetDelay = 0.3,  -- Задержка перед потерей цели
    
    -- ПАРАМЕТРЫ ДВИЖЕНИЯ - РАЗНЫЕ ДЛЯ РАЗНЫХ ИГР
    -- Для LightsOut - более плавные настройки
    MovementSpeed = 160,
    RotationSpeed = 50,
    Smoothness = 0.85,
    JumpSyncSmoothness = 0.92,
    
    -- АНТИЧИТ ПАРАМЕТРЫ
    MaxVelocity = 280,
    VelocitySmoothness = 0.88,
    HumanizeFactor = 0.005,
    NaturalNoise = 0.003,
    AntiDetectionMode = true,
    
    -- ПАРАМЕТРЫ ТЕЛЕПОРТАЦИИ (отключается для LightsOut)
    SyncMovement = true,
    MaxSyncDistance = 30,  -- Увеличено
    TeleportThreshold = 20,  -- Увеличено
    MovementStyle = "sync",
    InstantTeleportCooldown = 1.0,  -- Кулдаун на телепорт
    
    -- ВНУТРЕННИЕ ПЕРЕМЕННЫЕ
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
    JumpStartDistance = 2,
    
    -- Новые переменные для фиксов
    JumpStartPosition = nil,
    
    -- ПАРАМЕТРЫ ДЛЯ LightsOut (более плавные)
    LightsOutSettings = {
        MovementSpeed = 120,
        MaxVelocity = 180,
        Smoothness = 0.95,
        TeleportThreshold = 100,
        FrontDistance = 15,
        BehindDistance = 3,
        MaxDistance = 400,  -- Увеличен для LightsOut
    },
    
    -- УЛУЧШЕННЫЕ ПЕРЕМЕННЫЕ ДЛЯ СТАБИЛЬНОСТИ
    TargetStabilityCounter = 0,
    MaxStabilityCount = 35,  -- Увеличен
    LastTargetDistance = 0,
    LostTargetFrames = 0,
    MaxLostFrames = 20,  -- Увеличен
    ShouldMaintainTarget = true,
    TeleportCooldown = 0,
    LastTargetUpdateTime = 0,
    TargetUpdateInterval = 0.1,
    
    -- Переменные для синхронного движения
    SyncPosition = Vector3.new(),
    SyncVelocity = Vector3.new(),
    IsInSyncMode = false,
    LastSyncTime = 0,
    
    -- НОВЫЕ ПЕРЕМЕННЫЕ ДЛЯ УДЕРЖАНИЯ ЦЕЛИ
    TargetRetentionTime = 0,
    MaxRetentionTime = 2.0,  -- Максимальное время удержания цели
    LastValidTargetPosition = Vector3.new(),
    IsTeleportingToTarget = false,
    TeleportInProgress = false,
    
    -- Параметры для плавного восстановления
    LastMovementDirection = "idle",
    LastSpeedCheck = 0,
    MinSpeedForFront = 18,
    RequiredDirection = "forward"
}

-- Инициализация анимаций
for _, animId in pairs(MainModule.Killaura.TeleportAnimations) do
    MainModule.Killaura.TargetAnimationsSet[animId] = true
end

-- ФУНКЦИЯ ДЛЯ ПОЛУЧЕНИЯ НАСТРОЕК В ЗАВИСИМОСТИ ОТ ИГРЫ
local function getGameSettings()
    local config = MainModule.Killaura
    local currentGame = GetCurrentGame()
    
    if currentGame == "LightsOut" then
        return {
            MovementSpeed = config.LightsOutSettings.MovementSpeed,
            MaxVelocity = config.LightsOutSettings.MaxVelocity,
            Smoothness = config.LightsOutSettings.Smoothness,
            TeleportThreshold = config.LightsOutSettings.TeleportThreshold,
            FrontDistance = config.LightsOutSettings.FrontDistance,
            BehindDistance = config.LightsOutSettings.BehindDistance,
            SpeedThreshold = config.SpeedThreshold,
            RotationSpeed = config.RotationSpeed,
            JumpSyncSmoothness = config.JumpSyncSmoothness,
            MaxDistance = config.LightsOutSettings.MaxDistance or config.MaxDistance
        }
    else
        return {
            MovementSpeed = config.MovementSpeed,
            MaxVelocity = config.MaxVelocity,
            Smoothness = config.Smoothness,
            TeleportThreshold = config.TeleportThreshold,
            FrontDistance = config.FrontDistance,
            BehindDistance = config.BehindDistance,
            SpeedThreshold = config.SpeedThreshold,
            RotationSpeed = config.RotationSpeed,
            JumpSyncSmoothness = config.JumpSyncSmoothness,
            MaxDistance = config.MaxDistance
        }
    end
end

-- НОВАЯ ФУНКЦИЯ: Проверка анимации отключения
local function checkDisableAnimation(targetPlayer)
    if not targetPlayer then return false end
    
    local character = targetPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local animator = character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
    if not animator then return false end
    
    local tracks = humanoid:GetPlayingAnimationTracks()
    if not tracks then return false end
    
    for _, track in pairs(tracks) do
        if track and track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId)
            local cleanId = animId:match("%d+")
            
            if cleanId and cleanId == MainModule.Killaura.DisableAnimationId then
                return true
            end
        end
    end
    
    return false
end

-- УЛУЧШЕННЫЙ поиск игрока с учетом HideAndSeek
local function findClosestPlayer(forceNewTarget, maxDistance)
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    if not localPlayer then return nil end
    
    local character = localPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local myPos = rootPart.Position
    local config = MainModule.Killaura
    
    -- Если у нас уже есть цель и не требуется новая
    if not forceNewTarget and config.CurrentTarget then
        local targetChar = config.CurrentTarget.Character
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and humanoid and humanoid.Health > 0 then
                local distance = (targetRoot.Position - myPos).Magnitude
                if distance <= (maxDistance or config.MaxDistance) then
                    return config.CurrentTarget
                end
            end
        end
    end
    
    -- Получаем текущую игру
    local currentGame = GetCurrentGame()
    
    -- ЛОГИКА ДЛЯ HIDE AND SEEK
    if currentGame == "HideAndSeek" then
        local isLocalSeeker = IsSeeker(localPlayer)
        local isLocalHider = IsHider(localPlayer)
        
        if isLocalSeeker then
            local closestPlayer = nil
            local closestDistance = math.huge
            
            for _, player in pairs(players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    if IsHider(player) then
                        local targetChar = player.Character
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and humanoid and humanoid.Health > 0 then
                            local distance = (targetRoot.Position - myPos).Magnitude
                            local maxDist = maxDistance or config.MaxDistance
                            if distance < closestDistance and distance <= maxDist then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
            
            return closestPlayer
            
        elseif isLocalHider then
            local closestPlayer = nil
            local closestDistance = math.huge
            
            for _, player in pairs(players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    if IsSeeker(player) then
                        local targetChar = player.Character
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and humanoid and humanoid.Health > 0 then
                            local distance = (targetRoot.Position - myPos).Magnitude
                            local maxDist = maxDistance or config.MaxDistance
                            if distance < closestDistance and distance <= maxDist then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
            
            return closestPlayer
        end
        
        return nil
    end
    
    -- ДЛЯ ВСЕХ ДРУГИХ ИГР
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetChar = player.Character
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and humanoid and humanoid.Health > 0 then
                local distance = (targetRoot.Position - myPos).Magnitude
                local maxDist = maxDistance or config.MaxDistance
                if distance < closestDistance and distance <= maxDist then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- УЛУЧШЕННАЯ проверка цели (МЕНЬШЕ СБРОСОВ)
local function checkAndSwitchTarget()
    local config = MainModule.Killaura
    
    if not config.Enabled or config.ShouldDisableForAnimation then 
        config.LostTargetFrames = 0
        config.TargetRetentionTime = 0
        return false 
    end
    
    local currentTarget = config.CurrentTarget
    
    if currentTarget then
        local targetChar = currentTarget.Character
        if not targetChar then 
            config.LostTargetFrames = config.LostTargetFrames + 1
            -- Даем больше времени на восстановление
            return config.LostTargetFrames < config.MaxLostFrames * 2
        end
        
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then 
            config.LostTargetFrames = config.LostTargetFrames + 1
            return config.LostTargetFrames < config.MaxLostFrames * 1.5
        end
        
        local localPlayer = game:GetService("Players").LocalPlayer
        if localPlayer and localPlayer.Character then
            local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            
            if localRoot and targetRoot then
                local distance = (targetRoot.Position - localRoot.Position).Magnitude
                local settings = getGameSettings()
                
                -- УВЕЛИЧЕННЫЙ ДИАПАЗОН ДЛЯ УДЕРЖАНИЯ ЦЕЛИ
                if distance > settings.MaxDistance then 
                    config.LostTargetFrames = config.LostTargetFrames + 1
                    
                    -- Пытаемся телепортироваться к далекой цели
                    if distance > settings.MaxDistance and distance < config.TeleportSearchRange then
                        if not config.IsTeleportingToTarget and tick() - config.LastTargetUpdateTime > 1.0 then
                            config.IsTeleportingToTarget = true
                            config.LastValidTargetPosition = targetRoot.Position
                            
                            -- Телепорт к далекой цели
                            local targetLook = targetRoot.CFrame.LookVector
                            local attachmentType, desiredDistance = getSmartPositioning(targetRoot)
                            local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
                            local teleportPos = targetRoot.Position + desiredOffset
                            
                            localRoot.CFrame = CFrame.new(teleportPos, targetRoot.Position)
                            config.CurrentVelocity = Vector3.new(0, 0, 0)
                            config.LastTargetUpdateTime = tick()
                            config.IsTeleportingToTarget = false
                            
                            print("Телепорт к далекой цели: " .. distance .. " studs")
                            return true
                        end
                    end
                    
                    return config.LostTargetFrames < config.MaxLostFrames
                end
                
                -- Цель валидна
                config.LostTargetFrames = 0
                config.TargetRetentionTime = math.min(config.TargetRetentionTime + 0.1, config.MaxRetentionTime)
                config.TargetStabilityCounter = math.min(config.TargetStabilityCounter + 1, config.MaxStabilityCount)
                config.LastTargetDistance = distance
                config.LastValidTargetPosition = targetRoot.Position
            end
        end
        
        return true
    end
    
    config.LostTargetFrames = config.LostTargetFrames + 1
    return config.LostTargetFrames < config.MaxLostFrames
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

-- ИСПРАВЛЕННАЯ проверка прыжка цели
local function checkTargetJumping(targetRoot)
    if not targetRoot then return false end
    
    local config = MainModule.Killaura
    local currentTime = tick()
    
    local isJumpingNow = targetRoot.Velocity.Y > 10
    
    if isJumpingNow and not config.JumpData.TargetJumping then
        config.JumpData.TargetJumping = true
        config.JumpData.JumpStartY = targetRoot.Position.Y
        config.JumpData.JumpPeakReached = false
        config.JumpData.JumpVelocity = targetRoot.Velocity.Y
        config.JumpData.JumpStartTime = currentTime
        config.JumpSync = true
        config.IsJumping = true
        
        config.JumpStartPosition = targetRoot.Position
        
    elseif config.JumpData.TargetJumping then
        config.JumpData.JumpDuration = currentTime - config.JumpData.JumpStartTime
        
        if targetRoot.Velocity.Y < 2 and not config.JumpData.JumpPeakReached then
            config.JumpData.JumpPeakReached = true
        end
        
        if math.abs(targetRoot.Velocity.Y) < 2 and 
           math.abs(targetRoot.Position.Y - config.JumpData.JumpStartY) < 3 then
            config.JumpData.TargetJumping = false
            config.JumpSync = false
            config.IsJumping = false
            config.JumpStartPosition = nil
        end
    end
    
    return config.JumpData.TargetJumping
end

-- ИСПРАВЛЕННАЯ функция определения направления движения
local function getTargetMovementDirection(targetRoot)
    if not targetRoot then return "idle" end
    
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    
    local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
    local horizontalSpeed = horizontalVel.Magnitude
    
    MainModule.Killaura.LastSpeedCheck = horizontalSpeed
    
    if horizontalSpeed < 2.5 then
        MainModule.Killaura.LastMovementDirection = "idle"
        return "idle"
    end
    
    local lookDirection = Vector3.new(targetLook.X, 0, targetLook.Z).Unit
    local moveDirection = horizontalVel.Unit
    
    local dotProduct = lookDirection:Dot(moveDirection)
    
    local direction
    
    if dotProduct > 0.7 then
        direction = "forward"
    elseif dotProduct < -0.7 then
        direction = "backward"
    elseif math.abs(dotProduct) < 0.3 then
        local crossProduct = lookDirection:Cross(moveDirection)
        if crossProduct.Y > 0 then
            direction = "right"
        else
            direction = "left"
        end
    else
        direction = "diagonal"
    end
    
    MainModule.Killaura.LastMovementDirection = direction
    return direction
end

-- ИСПРАВЛЕННАЯ функция определения позиционирования
local function getSmartPositioning(targetRoot)
    local config = MainModule.Killaura
    
    if not targetRoot then 
        return config.JumpStartAttachment or "behind", config.JumpStartDistance or config.BehindDistance
    end
    
    local settings = getGameSettings()
    
    local targetVel = targetRoot.Velocity
    local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
    local horizontalSpeed = horizontalVel.Magnitude
    
    config.LastSpeedCheck = horizontalSpeed
    
    if config.IsJumping then
        return config.JumpStartAttachment, config.JumpStartDistance
    end
    
    if config.AnimationLiftActive and config.WasInFrontBeforeLift then
        return "front", settings.FrontDistance
    end
    
    local movementDir = getTargetMovementDirection(targetRoot)
    
    if horizontalSpeed >= config.MinSpeedForFront and movementDir == "forward" then
        config.JumpStartAttachment = "front"
        config.JumpStartDistance = settings.FrontDistance
        return "front", settings.FrontDistance
    else
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = settings.BehindDistance
        return "behind", settings.BehindDistance
    end
end

-- ОБРАБОТКА ОТКЛЮЧЕНИЯ ПО АНИМАЦИИ
local function handleDisableAnimation(targetPlayer)
    local config = MainModule.Killaura
    
    if not config.Enabled then
        config.ShouldDisableForAnimation = false
        config.IsDisabledByAnimation = false
        return false
    end
    
    if not targetPlayer then return false end
    
    local currentTime = tick()
    local shouldDisable = checkDisableAnimation(targetPlayer)
    
    if currentTime - config.LastDisableTime < config.DisableAnimationCooldown then
        return config.IsDisabledByAnimation
    end
    
    if shouldDisable and config.Enabled and not config.IsDisabledByAnimation then
        print("Обнаружена анимация отключения! Отключаем киллауру...")
        config.WasEnabledBeforeAnimation = true
        config.IsDisabledByAnimation = true
        config.ShouldDisableForAnimation = true
        config.LastDisableTime = currentTime
        
        config.CurrentTarget = nil
        config.IsAttached = false
        
        return true
    end
    
    if not shouldDisable and config.IsDisabledByAnimation and config.WasEnabledBeforeAnimation then
        print("Анимация отключения закончилась! Восстанавливаем киллауру...")
        
        config.IsDisabledByAnimation = false
        config.ShouldDisableForAnimation = false
        config.LastDisableTime = currentTime
        
        task.delay(config.LostTargetDelay, function()
            if config.Enabled then
                local closestPlayer = findClosestPlayer(true)
                if closestPlayer then
                    config.CurrentTarget = closestPlayer
                    config.IsAttached = true
                    print("Цель восстановлена после анимации: " .. closestPlayer.Name)
                end
            end
        end)
        
        config.WasEnabledBeforeAnimation = false
        return false
    end
    
    return config.IsDisabledByAnimation
end

-- УЛУЧШЕННАЯ функция синхронного движения (С ЛУЧШИМ УДЕРЖАНИЕМ ЦЕЛИ)
local function syncMovement(localRoot, targetPos, targetLook, deltaTime, isAnimationLift)
    local config = MainModule.Killaura
    
    if config.ShouldDisableForAnimation then
        config.CurrentVelocity = Vector3.new(0, 0, 0)
        localRoot.Velocity = config.CurrentVelocity
        return
    end
    
    local targetRoot = nil
    if config.CurrentTarget and config.CurrentTarget.Character then
        targetRoot = config.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
    end
    
    local settings = getGameSettings()
    local currentGame = GetCurrentGame()
    
    local attachmentType, desiredDistance = getSmartPositioning(targetRoot)
    
    if isAnimationLift and config.WasInFrontBeforeLift then
        attachmentType = "front"
        desiredDistance = settings.FrontDistance
    end
    
    local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
    local targetGroundPos = targetPos + desiredOffset
    
    if isAnimationLift then
        targetGroundPos = Vector3.new(
            targetGroundPos.X,
            config.OriginalGroundHeight + config.LiftHeight,
            targetGroundPos.Z
        )
    end
    
    if config.IsJumping and targetRoot then
        targetGroundPos = Vector3.new(
            targetGroundPos.X,
            targetRoot.Position.Y,
            targetGroundPos.Z
        )
    end
    
    local currentPos = localRoot.Position
    local direction = targetGroundPos - currentPos
    local distance = direction.Magnitude
    
    -- УЛУЧШЕННАЯ ТЕЛЕПОРТАЦИЯ ДЛЯ ДАЛЕКИХ ЦЕЛЕЙ
    if distance > settings.TeleportThreshold * 2 then
        if config.TeleportCooldown <= 0 then
            localRoot.CFrame = CFrame.new(targetGroundPos, targetPos)
            config.CurrentVelocity = Vector3.new(0, 0, 0)
            config.TeleportCooldown = 1.5
            config.LastTargetUpdateTime = tick()
            print("Экстренный телепорт к цели: " .. distance .. " studs")
            return
        end
    end
    
    -- БЫСТРОЕ ПРИБЛИЖЕНИЕ К ДАЛЕКИМ ЦЕЛЯМ
    if distance > settings.MaxDistance * 0.7 then
        local targetSpeed = settings.MovementSpeed * 1.5
        local targetVelocity = direction.Unit * targetSpeed
        config.CurrentVelocity = targetVelocity:Lerp(targetVelocity, 0.9)
        
        if config.CurrentVelocity.Magnitude > settings.MaxVelocity * 1.2 then
            config.CurrentVelocity = config.CurrentVelocity.Unit * settings.MaxVelocity * 1.2
        end
        
        local moveStep = config.CurrentVelocity * deltaTime
        
        if moveStep.Magnitude > distance then
            moveStep = direction
        end
        
        local newPos = currentPos + moveStep
        
        if isAnimationLift then
            local targetHeight = config.OriginalGroundHeight + config.LiftHeight
            newPos = Vector3.new(newPos.X, targetHeight, newPos.Z)
        end
        
        local lookAtPos = Vector3.new(targetPos.X, newPos.Y, targetPos.Z)
        local targetCF = CFrame.new(newPos, lookAtPos)
        
        localRoot.CFrame = localRoot.CFrame:Lerp(targetCF, 0.8)
        localRoot.Velocity = config.CurrentVelocity
        
    -- НОРМАЛЬНОЕ ПРИБЛИЖЕНИЕ
    elseif distance > 2 then
        local targetSpeed = math.min(settings.MovementSpeed, distance * 10)
        local smoothnessFactor = settings.Smoothness
        
        local targetVelocity = direction.Unit * targetSpeed
        config.CurrentVelocity = config.CurrentVelocity:Lerp(targetVelocity, 0.7)
        
        if config.CurrentVelocity.Magnitude > settings.MaxVelocity then
            config.CurrentVelocity = config.CurrentVelocity.Unit * settings.MaxVelocity
        end
        
        local moveStep = config.CurrentVelocity * deltaTime
        
        if moveStep.Magnitude > distance then
            moveStep = direction
        end
        
        local newPos = currentPos + moveStep
        
        if isAnimationLift then
            local targetHeight = config.OriginalGroundHeight + config.LiftHeight
            newPos = Vector3.new(newPos.X, targetHeight, newPos.Z)
        end
        
        local lookAtPos = Vector3.new(targetPos.X, newPos.Y, targetPos.Z)
        local targetCF = CFrame.new(newPos, lookAtPos)
        
        localRoot.CFrame = localRoot.CFrame:Lerp(targetCF, 0.7)
        localRoot.Velocity = config.CurrentVelocity
        
    else
        if attachmentType == "front" then
            local exactPos = targetPos + (targetLook * settings.FrontDistance)
            if isAnimationLift then
                exactPos = Vector3.new(exactPos.X, config.OriginalGroundHeight + config.LiftHeight, exactPos.Z)
            end
            localRoot.CFrame = CFrame.new(exactPos, targetPos)
        else
            local exactPos = targetPos + (-targetLook * settings.BehindDistance)
            localRoot.CFrame = CFrame.new(exactPos, targetPos)
        end
        
        config.CurrentVelocity = Vector3.new(0, 0, 0)
        localRoot.Velocity = config.CurrentVelocity
    end
    
    config.LastTargetPosition = targetPos
    
    if config.TeleportCooldown > 0 then
        config.TeleportCooldown = math.max(0, config.TeleportCooldown - deltaTime)
    end
end

-- УЛУЧШЕННАЯ ГРАВИТАЦИЯ
local function handleGravity(localRoot, targetRoot)
    local config = MainModule.Killaura
    
    if config.AnimationLiftActive or config.IsJumping or config.IsLifted or config.ShouldDisableForAnimation then
        return
    end
    
    local rayOrigin = localRoot.Position + Vector3.new(0, 1, 0)
    local ray = Ray.new(rayOrigin, Vector3.new(0, -5, 0))
    local hit, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, {localRoot.Parent})
    
    if hit then
        local heightDiff = localRoot.Position.Y - hitPosition.Y
        
        if heightDiff > 4 then
            local fallSpeed = math.min(120, (heightDiff - 3) * 30)
            localRoot.Velocity = Vector3.new(localRoot.Velocity.X, -fallSpeed, localRoot.Velocity.Z)
        elseif heightDiff < 1.5 then
            local liftSpeed = math.min(80, (2 - heightDiff) * 40)
            localRoot.Velocity = Vector3.new(localRoot.Velocity.X, liftSpeed, localRoot.Velocity.Z)
        end
    end
end

-- ГЛАВНЫЙ ЦИКЛ - УЛУЧШЕННАЯ ВЕРСИЯ
local function updateSyncMovement(deltaTime)
    if not MainModule.Killaura.Enabled then return end
    
    local localPlayer = game:GetService("Players").LocalPlayer
    if not localPlayer then return end
    
    local character = localPlayer.Character
    if not character then return end
    
    local localRoot = character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    local config = MainModule.Killaura
    
    -- ПРОВЕРКА ЦЕЛИ С УЛУЧШЕННОЙ ЛОГИКОЙ
    local shouldKeepTarget = checkAndSwitchTarget()
    
    if not shouldKeepTarget then
        -- Пытаемся найти новую цель с увеличенным диапазоном
        local closestPlayer = findClosestPlayer(true, config.TeleportSearchRange)
        
        if closestPlayer then
            config.CurrentTarget = closestPlayer
            config.IsAttached = true
            config.LostTargetFrames = 0
            config.TargetStabilityCounter = 0
            
            -- Быстрый телепорт к новой цели
            local targetChar = closestPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if localRoot and targetRoot then
                local targetLook = targetRoot.CFrame.LookVector
                local attachmentType, desiredDistance = getSmartPositioning(targetRoot)
                
                local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
                local startPos = targetRoot.Position + desiredOffset
                
                localRoot.CFrame = CFrame.new(startPos, targetRoot.Position)
                
                config.LastPosition = startPos
                config.OriginalGroundHeight = startPos.Y
                config.CurrentVelocity = Vector3.new(0, 0, 0)
                config.JumpStartAttachment = attachmentType
                config.JumpStartDistance = desiredDistance
                config.LastTargetUpdateTime = tick()
            end
        else
            config.TargetRetentionTime = math.max(0, config.TargetRetentionTime - 0.5)
            
            if config.TargetRetentionTime <= 0 then
                task.delay(1.0, function()
                    if config.Enabled and not config.CurrentTarget then
                        MainModule.ToggleKillaura(false)
                        MainModule.DisableFlight()
                    end
                end)
            end
            return
        end
    end
    
    if not config.CurrentTarget or not config.IsAttached then return end
    
    local isDisableAnimation = handleDisableAnimation(config.CurrentTarget)
    
    if isDisableAnimation then
        return
    end
    
    local targetChar = config.CurrentTarget.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    
    if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
        config.LostTargetFrames = config.MaxLostFrames
        return
    end
    
    -- Данные цели
    local targetPos = targetRoot.Position
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    
    -- Проверка прыжка
    local isTargetJumping = checkTargetJumping(targetRoot)
    
    -- Синхронизация прыжка
    if isTargetJumping and not config.AnimationLiftActive then
        local targetHeight = targetRoot.Position.Y
        local myHeight = localRoot.Position.Y
        local heightDiff = targetHeight - myHeight
        
        if math.abs(heightDiff) > 0.5 then
            local jumpForce = heightDiff * deltaTime * 100
            localRoot.Velocity = Vector3.new(localRoot.Velocity.X, localRoot.Velocity.Y + jumpForce, localRoot.Velocity.Z)
        end
    elseif config.IsJumping and not isTargetJumping then
        config.IsJumping = false
        config.JumpSync = false
        config.JumpStartPosition = nil
    end
    
    -- Обработка подъема
    local isAnimationLift = false
    if config.AnimationLiftActive then
        isAnimationLift = true
    end
    
    -- СИНХРОННОЕ ДВИЖЕНИЕ
    syncMovement(localRoot, targetPos, targetLook, deltaTime, isAnimationLift)
    
    -- ГРАВИТАЦИЯ
    handleGravity(localRoot, targetRoot)
    
    -- Сохранение данных
    config.LastPosition = localRoot.Position
    config.TargetLastVelocity = targetVel
    config.LastDirectionCheckTime = tick()
    config.LastTargetUpdateTime = tick()
end

function MainModule.ToggleKillaura(enabled)
    local config = MainModule.Killaura
    
    if config.Enabled == enabled then return end
    
    -- Автоматическое управление флаем
    if enabled then
        MainModule.EnableFlight()
    else
        MainModule.DisableFlight()
    end
    
    if enabled then
        if not findClosestPlayer(true, config.TeleportSearchRange) then 
            MainModule.DisableFlight()
            MainModule.ShowNotification("Killaura", "No target found", 3)
            return 
        end
    end
    
    config.Enabled = enabled
    
    -- Сброс состояний отключения по анимации
    config.ShouldDisableForAnimation = false
    config.IsDisabledByAnimation = false
    config.WasEnabledBeforeAnimation = false
    
    -- Уведомления
    if enabled then
        MainModule.ShowNotification("Killaura", "Enabled", 1)
    else
        MainModule.ShowNotification("Killaura", "Disabled", 2)
    end
    
    -- Очистка соединений
    for _, conn in pairs(config.Connections) do
        if conn then conn:Disconnect() end
    end
    config.Connections = {}
    
    if not enabled then
        -- Сброс всех состояний
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
        config.JumpStartDistance = getGameSettings().BehindDistance
        config.LostTargetFrames = 0
        config.TargetStabilityCounter = 0
        config.TeleportCooldown = 0
        config.ShouldDisableForAnimation = false
        config.IsDisabledByAnimation = false
        config.WasEnabledBeforeAnimation = false
        config.TargetRetentionTime = 0
        config.IsTeleportingToTarget = false
        config.LastTargetUpdateTime = 0
        
        return
    end
    
    -- Включение с поиском цели
    local closestPlayer = findClosestPlayer(true, config.TeleportSearchRange)
    if closestPlayer then
        config.CurrentTarget = closestPlayer
        config.IsAttached = true
        
        -- Сброс состояний
        config.AnimationLiftActive = false
        config.IsLifted = false
        config.IsJumping = false
        config.JumpSync = false
        config.JumpStartPosition = nil
        config.CurrentVelocity = Vector3.new(0, 0, 0)
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = getGameSettings().BehindDistance
        config.LostTargetFrames = 0
        config.TargetStabilityCounter = 0
        config.TeleportCooldown = 0
        config.ShouldDisableForAnimation = false
        config.IsDisabledByAnimation = false
        config.WasEnabledBeforeAnimation = false
        config.TargetRetentionTime = config.MaxRetentionTime / 2
        config.IsTeleportingToTarget = false
        
        -- НАЧАЛЬНАЯ ТЕЛЕПОРТАЦИЯ
        local localPlayer = game:GetService("Players").LocalPlayer
        if localPlayer and localPlayer.Character then
            local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetChar = closestPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if localRoot and targetRoot then
                local targetLook = targetRoot.CFrame.LookVector
                
                local attachmentType, desiredDistance = getSmartPositioning(targetRoot)
                
                local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
                local startPos = targetRoot.Position + desiredOffset
                
                localRoot.CFrame = CFrame.new(startPos, targetRoot.Position)
                
                config.LastPosition = startPos
                config.OriginalGroundHeight = startPos.Y
                config.CurrentVelocity = Vector3.new(0, 0, 0)
                config.JumpStartAttachment = attachmentType
                config.JumpStartDistance = desiredDistance
                config.LastTargetUpdateTime = tick()
            end
        end
    else
        config.Enabled = false
        MainModule.DisableFlight()
        MainModule.ShowNotification("Killaura", "No target found", 3)
        return
    end
    
    -- ГЛАВНЫЙ ЦИКЛ СИНХРОННОГО ДВИЖЕНИЯ
    local heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if not config.Enabled then return end
        updateSyncMovement(deltaTime)
    end)
    
    table.insert(config.Connections, heartbeatConn)
    
    -- Обработчики событий
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    if localPlayer then
        local charConn = localPlayer.CharacterAdded:Connect(function()
            if not config.Enabled then return end
            
            task.wait(0.2)
            
            -- Сброс при смене персонажа
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
            config.JumpStartDistance = getGameSettings().BehindDistance
            config.LostTargetFrames = 0
            config.TargetStabilityCounter = 0
            config.TeleportCooldown = 0
            config.ShouldDisableForAnimation = false
            config.IsDisabledByAnimation = false
            config.WasEnabledBeforeAnimation = false
            config.TargetRetentionTime = 0
            config.IsTeleportingToTarget = false
            config.LastTargetUpdateTime = 0
            
            local closestPlayer = findClosestPlayer(true, config.TeleportSearchRange)
            if closestPlayer then
                config.CurrentTarget = closestPlayer
                config.IsAttached = true
                config.TargetRetentionTime = config.MaxRetentionTime / 2
            else
                MainModule.ToggleKillaura(false)
                MainModule.DisableFlight()
            end
        end)
        table.insert(config.Connections, charConn)
    end
    
    local removeConn = players.PlayerRemoving:Connect(function(player)
        if config.Enabled and config.CurrentTarget == player then
            config.LostTargetFrames = config.MaxLostFrames * 2
        end
    end)
    table.insert(config.Connections, removeConn)
end

-- Функция для установки горячей клавиши Killaura
function MainModule.SetKillauraHotkey(keyCode)
    MainModule.Killaura.CurrentHotkey = keyCode
end

-- Функция для проверки активности Killaura
function MainModule.IsKillauraActive()
    return MainModule.Killaura.Enabled
end

-- Функция для получения текущей цели
function MainModule.GetKillauraTarget()
    if MainModule.Killaura.Enabled and MainModule.Killaura.CurrentTarget then
        return MainModule.Killaura.CurrentTarget.Name
    end
    return "No target"
end

MainModule.AutoNextGameSettings = {
    Enabled = false,
    Connection = nil,
    Timer = 0,
    Cooldown = 3.40, -- задержка между вызовами
    OutsideCooldown = 25, -- время вызова после выхода из радиуса
    TargetPosition = Vector3.new(-214.30, 186.86, 242.64),
    Radius = 80,
    IsInRadius = false,
    OutsideTimer = 0,
    RemotePath = {
        "ReplicatedStorage",
        "Remotes",
        "TemporaryReachedBindable"
    }
}

function MainModule.AutoNextGame(enabled)
    MainModule.AutoNextGameSettings.Enabled = enabled
    
    if enabled then
        MainModule.ShowNotification("Auto Next Game", "Enabled", 2)
        
        MainModule.AutoNextGameSettings.Connection = RunService.Heartbeat:Connect(function(deltaTime)
            if not MainModule.AutoNextGameSettings.Enabled then 
                if MainModule.AutoNextGameSettings.Connection then
                    MainModule.AutoNextGameSettings.Connection:Disconnect()
                    MainModule.AutoNextGameSettings.Connection = nil
                end
                return 
            end
            
            -- Получаем позицию персонажа
            local character = LocalPlayer.Character
            local playerPosition = character and character.PrimaryPart and character.PrimaryPart.Position
            
            if playerPosition then
                -- Проверяем, находится ли игрок в радиусе
                local distance = (playerPosition - MainModule.AutoNextGameSettings.TargetPosition).Magnitude
                local isNowInRadius = distance <= MainModule.AutoNextGameSettings.Radius
                
                -- Если игрок только что вошел в радиус
                if isNowInRadius and not MainModule.AutoNextGameSettings.IsInRadius then
                    MainModule.AutoNextGameSettings.IsInRadius = true
                    MainModule.AutoNextGameSettings.Timer = 0
                    MainModule.AutoNextGameSettings.OutsideTimer = 0
                end
                
                -- Если игрок только что вышел из радиуса
                if not isNowInRadius and MainModule.AutoNextGameSettings.IsInRadius then
                    MainModule.AutoNextGameSettings.IsInRadius = false
                    MainModule.AutoNextGameSettings.OutsideTimer = 0
                end
                
                MainModule.AutoNextGameSettings.IsInRadius = isNowInRadius
                
                -- Обновляем таймеры
                if MainModule.AutoNextGameSettings.IsInRadius then
                    -- В радиусе: обновляем обычный таймер
                    MainModule.AutoNextGameSettings.Timer = MainModule.AutoNextGameSettings.Timer + deltaTime
                    MainModule.AutoNextGameSettings.OutsideTimer = 0
                else
                    -- Вне радиуса: обновляем таймер для вызовов после выхода
                    MainModule.AutoNextGameSettings.OutsideTimer = MainModule.AutoNextGameSettings.OutsideTimer + deltaTime
                    MainModule.AutoNextGameSettings.Timer = 0
                end
                
                -- Проверяем условия для вызова remote
                local shouldCallRemote = false
                
                if MainModule.AutoNextGameSettings.IsInRadius then
                    -- В радиусе: вызываем каждые 1.25 секунд
                    if MainModule.AutoNextGameSettings.Timer >= MainModule.AutoNextGameSettings.Cooldown then
                        shouldCallRemote = true
                        MainModule.AutoNextGameSettings.Timer = 0
                    end
                else
                    -- Вне радиуса: вызываем только если прошло меньше 20 секунд после выхода
                    if MainModule.AutoNextGameSettings.OutsideTimer <= MainModule.AutoNextGameSettings.OutsideCooldown then
                        if MainModule.AutoNextGameSettings.OutsideTimer >= MainModule.AutoNextGameSettings.Cooldown then
                            shouldCallRemote = true
                            -- Не сбрасываем OutsideTimer, чтобы отслеживать общее время после выхода
                        end
                    end
                end
                
                -- Вызываем remote если нужно
                if shouldCallRemote then
                    pcall(function()
                        local remote = game:GetService(MainModule.AutoNextGameSettings.RemotePath[1])
                            :WaitForChild(MainModule.AutoNextGameSettings.RemotePath[2])
                            :WaitForChild(MainModule.AutoNextGameSettings.RemotePath[3])
                        remote:FireServer()
                    end)
                end
            end
        end)
        
    else
        MainModule.ShowNotification("Auto Next Game", "Disabled", 2)
        
        if MainModule.AutoNextGameSettings.Connection then
            MainModule.AutoNextGameSettings.Connection:Disconnect()
            MainModule.AutoNextGameSettings.Connection = nil
        end
        
        MainModule.AutoNextGameSettings.Timer = 0
        MainModule.AutoNextGameSettings.OutsideTimer = 0
        MainModule.AutoNextGameSettings.IsInRadius = false
    end
end

MainModule.FreeGuardSettings = {
    Enabled = false,
    MaxCycles = 5,
    ButtonWaitTime = 0.6
}

function MainModule.FreeGuard(enabled)
    MainModule.FreeGuardSettings.Enabled = enabled
    
    if enabled then
        MainModule.ShowNotification("Free Guard", "Enabled", 2)
        
        local LocalPlayer = Players.LocalPlayer
        
        -- Устанавливаем атрибут
        LocalPlayer:SetAttribute("__OwnsPermGuard", true)
        
        -- Локальные функции
        local function shouldIgnoreButton(button)
            if not button then return true end
            
            local buttonName = button.Name:lower()
            local buttonText = ""
            if button:IsA("TextButton") and button.Text then
                buttonText = button.Text:lower()
            end
            
            local fullText = buttonName .. " " .. buttonText
            
            local forbiddenWords = {
                "buy", "playable", "one.time", "onetime", "temporary", 
                "onetim", "time.playable", "time.guard", "playable.guard",
                "one.time.guard", "temporary.guard", "playable.one.time"
            }
            
            for _, word in ipairs(forbiddenWords) do
                if string.find(fullText, word) then
                    return true
                end
            end
            
            return false
        end
        
        local function findButtonByCriteria(criteria)
            local playerGui = LocalPlayer.PlayerGui
            
            local function searchInGui(guiObject)
                local foundButtons = {}
                
                for _, child in pairs(guiObject:GetChildren()) do
                    if child:IsA("TextButton") or child:IsA("ImageButton") then
                        local matches = true
                        
                        if criteria.skipBuy then
                            local btnName = child.Name:lower()
                            local hasBuy = string.find(btnName, "buy")
                            
                            if child:IsA("TextButton") and child.Text then
                                local btnText = child.Text:lower()
                                hasBuy = hasBuy or string.find(btnText, "buy")
                            end
                            
                            if hasBuy then
                                matches = false
                            end
                        end
                        
                        if criteria.name and child.Name ~= criteria.name then
                            matches = false
                        end
                        
                        if criteria.text and child:IsA("TextButton") and child.Text then
                            local btnText = child.Text:lower()
                            if not string.find(btnText, criteria.text:lower()) then
                                matches = false
                            end
                        end
                        
                        if criteria.color and child.BackgroundColor3 ~= criteria.color then
                            matches = false
                        end
                        
                        if matches then
                            table.insert(foundButtons, child)
                        end
                    end
                    
                    if #child:GetChildren() > 0 then
                        local nestedResults = searchInGui(child)
                        for _, btn in ipairs(nestedResults) do
                            table.insert(foundButtons, btn)
                        end
                    end
                end
                
                return foundButtons
            end
            
            return searchInGui(playerGui)
        end
        
        local function findButtonByPartialPath(pathParts, skipBuy)
            local playerGui = LocalPlayer.PlayerGui
            
            local function deepSearch(parent, depth)
                if depth > #pathParts then
                    return nil
                end
                
                local targetName = pathParts[depth]
                
                for _, child in pairs(parent:GetChildren()) do
                    if skipBuy and string.find(child.Name:lower(), "buy") then
                        continue
                    end
                    
                    if string.find(child.Name:lower(), targetName:lower()) then
                        if depth == #pathParts then
                            return child
                        else
                            local found = deepSearch(child, depth + 1)
                            if found then
                                return found
                            end
                        end
                    elseif #child:GetChildren() > 0 then
                        local found = deepSearch(child, depth)
                        if found then
                            return found
                        end
                    end
                end
                
                return nil
            end
            
            return deepSearch(playerGui, 1)
        end
        
        local function clickButton(button)
            if not button then return false end
            
            local buttonName = button.Name:lower()
            local buttonText = ""
            if button:IsA("TextButton") and button.Text then
                buttonText = button.Text:lower()
            end
            
            local fullText = buttonName .. " " .. buttonText
            
            if string.find(fullText, "buy") or
               string.find(fullText, "playable") or
               string.find(fullText, "one.time") or
               string.find(fullText, "onetime") or
               string.find(fullText, "temporary") or
               string.find(fullText, "onetim") or
               string.find(fullText, "time.playable") or
               string.find(fullText, "time.guard") or
               string.find(fullText, "playable.guard") then
                return false
            end
            
            if button:IsA("ImageLabel") or button:IsA("Frame") then
                local childButton = button:FindFirstChildWhichIsA("TextButton") or 
                                    button:FindFirstChildWhichIsA("ImageButton")
                if childButton then
                    button = childButton
                else
                    local parent = button.Parent
                    if parent and (parent:IsA("TextButton") or parent:IsA("ImageButton")) then
                        button = parent
                    else
                        return false
                    end
                end
            end
            
            if not (button:IsA("TextButton") or button:IsA("ImageButton")) then
                return false
            end
            
            local success = false
            
            if getconnections then
                local connections = getconnections(button.MouseButton1Click)
                if #connections > 0 then
                    for _, conn in pairs(connections) do
                        pcall(function()
                            conn:Fire()
                            success = true
                        end)
                    end
                end
            end
            
            if not success then
                pcall(function()
                    button.MouseButton1Click:Fire()
                    success = true
                end)
            end
            
            if not success and button:IsA("GuiButton") then
                pcall(function()
                    button:Activate()
                    success = true
                end)
            end
            
            return success
        end
        
        local function executeGuardCycle()
            local successCount = 0
            
            -- Поиск зеленых кнопок (1-я кнопка)
            local greenButtons = findButtonByCriteria({
                color = Color3.fromRGB(0, 255, 0),
                skipBuy = true
            })
            
            local filteredGreenButtons = {}
            for _, btn in ipairs(greenButtons) do
                if not shouldIgnoreButton(btn) then
                    table.insert(filteredGreenButtons, btn)
                end
            end
            
            if #filteredGreenButtons == 0 then
                local acceptButtons = findButtonByCriteria({
                    text = "accept",
                    skipBuy = true
                })
                
                for _, btn in ipairs(acceptButtons) do
                    if not shouldIgnoreButton(btn) then
                        table.insert(filteredGreenButtons, btn)
                    end
                end
            end
            
            if #filteredGreenButtons == 0 then
                local nameGreenButtons = findButtonByCriteria({
                    name = "Green",
                    skipBuy = true
                })
                
                for _, btn in ipairs(nameGreenButtons) do
                    if not shouldIgnoreButton(btn) then
                        table.insert(filteredGreenButtons, btn)
                    end
                end
            end
            
            local button1 = findButtonByPartialPath({"HeaderPrompt", "Green"}, true)
            if button1 and not shouldIgnoreButton(button1) then
                table.insert(filteredGreenButtons, button1) 
            end
            
            -- Клик по зеленой кнопке (1-я кнопка)
            if #filteredGreenButtons > 0 then
                for _, btn in ipairs(filteredGreenButtons) do
                    if clickButton(btn) then
                        successCount = successCount + 1
                        break
                    end
                end
            end
            
            if successCount == 0 then
                return false
            end
            
            -- Задержка 0.6 секунды
            task.wait(MainModule.FreeGuardSettings.ButtonWaitTime)
            
            -- Поиск кнопок Tier1 (2-я кнопка)
            local tierButtons = findButtonByCriteria({
                name = "EquipTier1",
                skipBuy = true
            })
            
            local filteredTierButtons = {}
            for _, btn in ipairs(tierButtons) do
                if not shouldIgnoreButton(btn) then
                    table.insert(filteredTierButtons, btn)
                end
            end
            
            if #filteredTierButtons == 0 then
                local button2 = findButtonByPartialPath({"RankSelection", "EquipTier1"}, true)
                if button2 and not shouldIgnoreButton(button2) then
                    table.insert(filteredTierButtons, button2) 
                end
            end
            
            if #filteredTierButtons == 0 then
                local tier1Buttons = findButtonByCriteria({
                    text = "tier1",
                    skipBuy = true
                })
                
                for _, btn in ipairs(tier1Buttons) do
                    if not shouldIgnoreButton(btn) then
                        table.insert(filteredTierButtons, btn)
                    end
                end
            end
            
            if #filteredTierButtons == 0 then
                local allButtons = findButtonByCriteria({skipBuy = true})
                for _, btn in ipairs(allButtons) do
                    local btnName = btn.Name:lower()
                    local btnText = ""
                    if btn:IsA("TextButton") and btn.Text then
                        btnText = btn.Text:lower()
                    end
                    
                    local hasTier1 = string.find(btnName, "tier1") or 
                                    string.find(btnText, "tier1")
                    
                    if hasTier1 and not shouldIgnoreButton(btn) then
                        table.insert(filteredTierButtons, btn)
                    end
                end
            end
            
            -- Клик по Tier1 кнопке (2-я кнопка)
            if #filteredTierButtons > 0 then
                for _, tierBtn in ipairs(filteredTierButtons) do
                    if clickButton(tierBtn) then
                        successCount = successCount + 1
                        break
                    end
                end
            end
            
            if successCount < 2 then
                return false
            end
            
            -- Задержка 0.6 секунды
            task.wait(MainModule.FreeGuardSettings.ButtonWaitTime)
            
            -- Поиск кнопок подтверждения (3-я кнопка)
            local confirmButtons = findButtonByCriteria({
                color = Color3.fromRGB(0, 255, 0),
                skipBuy = true
            })
            
            local filteredConfirmButtons = {}
            for _, btn in ipairs(confirmButtons) do
                if not shouldIgnoreButton(btn) then
                    table.insert(filteredConfirmButtons, btn)
                end
            end
            
            local playerGui = LocalPlayer.PlayerGui
            local function findGreenImageLabel(parent)
                for _, child in pairs(parent:GetChildren()) do
                    local childName = child.Name:lower()
                    if child:IsA("ImageLabel") and 
                       (string.find(childName, "green") or child.Name == "Green") and
                       not shouldIgnoreButton(child) then
                        return child
                    end
                    if #child:GetChildren() > 0 then
                        local found = findGreenImageLabel(child)
                        if found then return found end
                    end
                end
                return nil
            end
            
            local greenImageLabel = findGreenImageLabel(playerGui)
            if greenImageLabel and clickButton(greenImageLabel) then
                successCount = successCount + 1
                return true
            end
            
            local confirmButton3 = findButtonByPartialPath({"RankConfirmation", "Green"}, true)
            if confirmButton3 and not shouldIgnoreButton(confirmButton3) and clickButton(confirmButton3) then
                successCount = successCount + 1
                return true
            end
            
            local confirmTextButtons = findButtonByCriteria({
                text = "confirm",
                skipBuy = true
            })
            
            for _, cbtn in ipairs(confirmTextButtons) do
                if not shouldIgnoreButton(cbtn) and clickButton(cbtn) then
                    successCount = successCount + 1
                    return true
                end
            end
            
            return successCount > 2
        end
        
        -- Функция для мгновенного выполнения 5 циклов
        local function executeAllCyclesInstantly()
            local cyclesCompleted = 0
            local totalCycles = MainModule.FreeGuardSettings.MaxCycles
            
            for i = 1, totalCycles do
                if MainModule.FreeGuardSettings.Enabled then
                    if executeGuardCycle() then
                        cyclesCompleted = cyclesCompleted + 1
                    end
                    -- Нет задержки между циклами, только 0.6 секунды внутри цикла
                else
                    break
                end
            end
            
            -- Показываем простое уведомление "Completed"
            MainModule.ShowNotification("Free Guard", "Completed", 2)
            
            -- Ждем 2 секунды и выключаем
            task.wait(2)
            
            -- Выключаем функцию
            MainModule.FreeGuardSettings.Enabled = false
        end
        
        -- Запускаем мгновенное выполнение
        spawn(executeAllCyclesInstantly)
        
    else
        MainModule.ShowNotification("Free Guard", "Disabled", 2)
        MainModule.FreeGuardSettings.Enabled = false
    end
end



MainModule.InstantInteractSettings = {
    Enabled = false,
    Connection = nil,
    ProximityPrompts = {}
}

MainModule.NoCooldownProximitySettings = {
    Enabled = false,
    Connection = nil,
    Cooldowns = {}
}

local function setPromptInstant(prompt)
    if prompt:IsA("ProximityPrompt") then
        if MainModule.NoCooldownProximitySettings.Enabled and not MainModule.NoCooldownProximitySettings.Cooldowns[prompt] then
            MainModule.NoCooldownProximitySettings.Cooldowns[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0
    end
end

local function restorePromptCooldown(prompt)
    if prompt:IsA("ProximityPrompt") and MainModule.NoCooldownProximitySettings.Cooldowns[prompt] then
        prompt.HoldDuration = MainModule.NoCooldownProximitySettings.Cooldowns[prompt]
        MainModule.NoCooldownProximitySettings.Cooldowns[prompt] = nil
    end
end

function MainModule.ToggleInstantInteract(enabled)
    MainModule.InstantInteractSettings.Enabled = enabled
    MainModule.Misc.InstantInteract = enabled
    
    if enabled then
        MainModule.ShowNotification("Instant Interact", "Enabled", 2)
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                setPromptInstant(obj)
                table.insert(MainModule.InstantInteractSettings.ProximityPrompts, obj)
            end
        end
        
        MainModule.InstantInteractSettings.Connection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                setPromptInstant(obj)
                table.insert(MainModule.InstantInteractSettings.ProximityPrompts, obj)
            end
        end)
        
    else
        MainModule.ShowNotification("Instant Interact", "Disabled", 2)
        
        if MainModule.InstantInteractSettings.Connection then
            MainModule.InstantInteractSettings.Connection:Disconnect()
            MainModule.InstantInteractSettings.Connection = nil
        end
        
        MainModule.InstantInteractSettings.ProximityPrompts = {}
    end
end

function MainModule.ToggleNoCooldownProximity(enabled)
    MainModule.NoCooldownProximitySettings.Enabled = enabled
    MainModule.Misc.NoCooldownProximity = enabled
    
    if enabled then
        MainModule.ShowNotification("No Cooldown Proximity", "Enabled", 2)
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                setPromptInstant(obj)
            end
        end
        
        MainModule.NoCooldownProximitySettings.Connection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                setPromptInstant(obj)
            end
        end)
        
    else
        MainModule.ShowNotification("No Cooldown Proximity", "Disabled", 2)
        
        if MainModule.NoCooldownProximitySettings.Connection then
            MainModule.NoCooldownProximitySettings.Connection:Disconnect()
            MainModule.NoCooldownProximitySettings.Connection = nil
        end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                restorePromptCooldown(obj)
            end
        end
        
        for prompt, originalCooldown in pairs(MainModule.NoCooldownProximitySettings.Cooldowns) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = originalCooldown
            end
        end
        
        MainModule.NoCooldownProximitySettings.Cooldowns = {}
    end
end

MainModule.Hitbox = {
    Size = 50,
    Enabled = false,
    Connection = nil,
    ModifiedParts = {}
}

MainModule.RapidFire = {
    Enabled = false,
    Connection = nil,
    OriginalFireRates = {}
}

MainModule.InfiniteAmmo = {
    Enabled = false,
    Connection = nil,
    OriginalAmmo = {}
}

function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Hitbox.Enabled = enabled
    
    if enabled then
        MainModule.ShowNotification("HitboxExpander", "Enabled", 2)
        
        MainModule.Hitbox.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.Hitbox.Enabled then 
                if MainModule.Hitbox.Connection then
                    MainModule.Hitbox.Connection:Disconnect()
                    MainModule.Hitbox.Connection = nil
                end
                return 
            end
            
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            if not MainModule.Hitbox.ModifiedParts[root] then
                                -- Сохраняем оригинальные свойства
                                MainModule.Hitbox.ModifiedParts[root] = {
                                    Size = root.Size,
                                    CanCollide = root.CanCollide,
                                    Transparency = root.Transparency,
                                    CanTouch = root.CanTouch
                                }
                                
                                -- Делаем полностью невидимым и непересекаемым
                                root.Size = Vector3.new(MainModule.Hitbox.Size, MainModule.Hitbox.Size, MainModule.Hitbox.Size)
                                root.CanCollide = false
                                root.Transparency = 1  -- Полная прозрачность
                                root.CanTouch = false  -- Не может касаться других объектов
                            end
                        end
                    end
                end
            end)
        end)
        
    else
        MainModule.ShowNotification("HitboxExpander", "Disabled", 2)
        
        if MainModule.Hitbox.Connection then
            MainModule.Hitbox.Connection:Disconnect()
            MainModule.Hitbox.Connection = nil
        end
        
        -- Восстанавливаем оригинальные свойства
        pcall(function()
            for part, originalProps in pairs(MainModule.Hitbox.ModifiedParts) do
                if part and part.Parent then
                    part.Size = originalProps.Size
                    part.CanCollide = originalProps.CanCollide
                    part.Transparency = originalProps.Transparency
                    part.CanTouch = originalProps.CanTouch
                end
            end
            MainModule.Hitbox.ModifiedParts = {}
        end)
    end
end

function MainModule.SetHitboxSize(size)
    MainModule.Hitbox.Size = size
    if MainModule.Hitbox.Enabled then
        pcall(function()
            for part, _ in pairs(MainModule.Hitbox.ModifiedParts) do
                if part and part.Parent then
                    part.Size = Vector3.new(size, size, size)
                end
            end
        end)
    end
end

function MainModule.ToggleRapidFire(enabled)
    MainModule.RapidFire.Enabled = enabled
    
    if enabled then
        MainModule.ShowNotification("RapidFire", "Enabled", 2)
        
        MainModule.RapidFire.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.RapidFire.Enabled then 
                if MainModule.RapidFire.Connection then
                    MainModule.RapidFire.Connection:Disconnect()
                    MainModule.RapidFire.Connection = nil
                end
                return 
            end
            
            pcall(function()
                -- Обработка оружия в ReplicatedStorage
                local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
                if weaponsFolder then
                    local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                    if gunsFolder then
                        for _, obj in ipairs(gunsFolder:GetDescendants()) do
                            if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                                if not MainModule.RapidFire.OriginalFireRates[obj] then
                                    MainModule.RapidFire.OriginalFireRates[obj] = obj.Value
                                end
                                obj.Value = 0
                            end
                        end
                    end
                end
                
                -- Обработка оружия в персонаже
                local character = GetCharacter()
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                                    if not MainModule.RapidFire.OriginalFireRates[obj] then
                                        MainModule.RapidFire.OriginalFireRates[obj] = obj.Value
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
        MainModule.ShowNotification("RapidFire", "Disabled", 2)
        
        if MainModule.RapidFire.Connection then
            MainModule.RapidFire.Connection:Disconnect()
            MainModule.RapidFire.Connection = nil
        end
        
        -- Восстанавливаем оригинальные значения
        pcall(function()
            for obj, originalValue in pairs(MainModule.RapidFire.OriginalFireRates) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
            MainModule.RapidFire.OriginalFireRates = {}
        end)
    end
end

function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.InfiniteAmmo.Enabled = enabled
    
    if enabled then
        MainModule.ShowNotification("InfiniteAmmo", "Enabled", 2)
        
        MainModule.InfiniteAmmo.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.InfiniteAmmo.Enabled then 
                if MainModule.InfiniteAmmo.Connection then
                    MainModule.InfiniteAmmo.Connection:Disconnect()
                    MainModule.InfiniteAmmo.Connection = nil
                end
                return 
            end
            
            task.spawn(function()
                pcall(function()
                    -- Обработка оружия в персонаже
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
                                            if not MainModule.InfiniteAmmo.OriginalAmmo[obj] then
                                                MainModule.InfiniteAmmo.OriginalAmmo[obj] = obj.Value
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
                    
                    -- Обработка оружия в рюкзаке
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
                                            if not MainModule.InfiniteAmmo.OriginalAmmo[obj] then
                                                MainModule.InfiniteAmmo.OriginalAmmo[obj] = obj.Value
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
        end)
        
    else
        MainModule.ShowNotification("InfiniteAmmo", "Disabled", 2)
        
        if MainModule.InfiniteAmmo.Connection then
            MainModule.InfiniteAmmo.Connection:Disconnect()
            MainModule.InfiniteAmmo.Connection = nil
        end
        
        -- Восстанавливаем оригинальные значения
        pcall(function()
            for obj, originalValue in pairs(MainModule.InfiniteAmmo.OriginalAmmo) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
            MainModule.InfiniteAmmo.OriginalAmmo = {}
        end)
    end
end

-- ============ ESP ============
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

MainModule.ESP = {
    Players = {},
    Objects = {},
    Connections = {},
    Folder = nil,
    MainConnection = nil,
    UpdateRate = 0.1
}

-- Новая функция для очистки ESP данных конкретного игрока
function MainModule.ClearPlayerESP(player)
    if not player then return end
    local espData = MainModule.ESP.Players[player]
    if espData then
        if espData.Highlight then
            espData.Highlight.Adornee = nil
            SafeDestroy(espData.Highlight)
        end
        if espData.Billboard then
            SafeDestroy(espData.Billboard)
        end
        if espData.CharAddedConn then
            espData.CharAddedConn:Disconnect()
            espData.CharAddedConn = nil
        end
        if espData.DiedConn then
            espData.DiedConn:Disconnect()
            espData.DiedConn = nil
        end
        MainModule.ESP.Players[player] = nil
    end
end

function MainModule.UpdatePlayerESP(player)
    if not player or player == LocalPlayer or not MainModule.Misc.ESPEnabled then return end
    
    local character = player.Character
    if not character then 
        -- Если персонажа нет, очищаем ESP для этого игрока
        MainModule.ClearPlayerESP(player)
        return 
    end
    
    local humanoid = GetHumanoid(character)
    local rootPart = GetRootPart(character)
    
    -- Проверяем, жив ли игрок
    if humanoid and rootPart and humanoid.Health > 0 then
        local localCharacter = GetCharacter()
        local localRoot = localCharacter and GetRootPart(localCharacter)
        local espData = MainModule.ESP.Players[player]
        
        -- Если ESP данных нет, создаем их
        if not espData then
            espData = {
                Player = player,
                Highlight = nil,
                Billboard = nil,
                Label = nil,
                CharAddedConn = nil,
                DiedConn = nil
            }
            MainModule.ESP.Players[player] = espData
            
            -- Подписываемся на событие смерти персонажа
            espData.DiedConn = humanoid.Died:Connect(function()
                -- При смерти очищаем ESP
                if espData.Highlight then
                    espData.Highlight.Adornee = nil
                    espData.Highlight.Enabled = false
                end
                if espData.Billboard then
                    espData.Billboard.Enabled = false
                end
            end)
        end
        
        -- Обновляем Highlight
        if not espData.Highlight then
            espData.Highlight = Instance.new("Highlight")
            espData.Highlight.Name = player.Name .. "_ESP"
            espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            espData.Highlight.Enabled = MainModule.Misc.ESPHighlight
            espData.Highlight.Parent = MainModule.ESP.Folder
        end
        
        -- Устанавливаем Adornee только если он изменился
        if espData.Highlight.Adornee ~= character then
            espData.Highlight.Adornee = character
        end
        
        -- Устанавливаем цвет в зависимости от типа игрока
        if IsHider(player) and MainModule.Misc.ESPHiders then
            espData.Highlight.FillColor = Color3.fromRGB(0, 255, 0)
            espData.Highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
            espData.Highlight.Enabled = true
        elseif IsSeeker(player) and MainModule.Misc.ESPSeekers then
            espData.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
            espData.Highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
            espData.Highlight.Enabled = true
        elseif MainModule.Misc.ESPPlayers then
            espData.Highlight.FillColor = Color3.fromRGB(0, 120, 255)
            espData.Highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
            espData.Highlight.Enabled = true
        else
            espData.Highlight.Enabled = false
        end
        
        espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
        espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
        
        -- Обновляем текст
        if MainModule.Misc.ESPNames then
            if not espData.Billboard then
                espData.Billboard = Instance.new("BillboardGui")
                espData.Billboard.Name = player.Name .. "_Text"
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
            
            -- Устанавливаем Adornee для Billboard
            if espData.Billboard.Adornee ~= rootPart then
                espData.Billboard.Adornee = rootPart
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
    else
        -- Если игрок мертв, отключаем ESP (но не удаляем данные)
        local espData = MainModule.ESP.Players[player]
        if espData then
            if espData.Highlight then
                espData.Highlight.Enabled = false
                espData.Highlight.Adornee = nil
            end
            if espData.Billboard then
                espData.Billboard.Enabled = false
                espData.Billboard.Adornee = nil
            end
        end
    end
end

function MainModule.SetupPlayerESP(player)
    if player == LocalPlayer then return end
    
    -- Очищаем старые данные, если они есть
    MainModule.ClearPlayerESP(player)
    
    -- Создаем ESP для текущего персонажа
    if player.Character then
        MainModule.UpdatePlayerESP(player)
    end
    
    -- Подписываемся на смену персонажа
    local charAddedConn = player.CharacterAdded:Connect(function(character)
        -- Ждем появления персонажа и его частей
        local maxWait = 10
        local waited = 0
        
        while waited < maxWait do
            if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                break
            end
            task.wait(0.1)
            waited = waited + 0.1
        end
        
        -- Обновляем ESP после перерождения
        MainModule.UpdatePlayerESP(player)
    end)
    
    -- Сохраняем соединение для последующей очистки
    local espData = MainModule.ESP.Players[player]
    if espData then
        espData.CharAddedConn = charAddedConn
    end
end

function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled

    if enabled then
        MainModule.ShowNotification("ESP", "ESP Enabled", 3)
    else
        MainModule.ShowNotification("ESP", "ESP Disabled", 3)
    end
    
    -- Останавливаем существующие соединения
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
    
    -- Очищаем все ESP
    MainModule.ClearESP()
    
    if enabled then
        -- Создаем папку для ESP
        MainModule.ESP.Folder = Instance.new("Folder")
        MainModule.ESP.Folder.Name = "CreonXESP"
        MainModule.ESP.Folder.Parent = game:GetService("CoreGui")
        
        -- Настраиваем ESP для всех существующих игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                MainModule.SetupPlayerESP(player)
            end
        end
        
        -- Подписываемся на добавление новых игроков
        MainModule.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            if MainModule.Misc.ESPEnabled then
                task.wait(1) -- Даем время на загрузку
                MainModule.SetupPlayerESP(player)
            end
        end)
        
        -- Подписываемся на удаление игроков
        MainModule.ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
            MainModule.ClearPlayerESP(player)
        end)
        
        -- Основной цикл обновления ESP
        MainModule.ESP.MainConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            
            for player, espData in pairs(MainModule.ESP.Players) do
                if player and player.Parent then
                    MainModule.UpdatePlayerESP(player)
                else
                    -- Если игрок вышел из игры, очищаем его ESP
                    MainModule.ClearPlayerESP(player)
                end
            end
        end)
    end
end

function MainModule.ClearESP()
    for player, _ in pairs(MainModule.ESP.Players) do
        MainModule.ClearPlayerESP(player)
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
end

-- ============ FAN FUNCTIONS ============
MainModule.FreeDash = {
    Enabled = false,
    RemoteAddedConnection = nil,
    ChildAddedHook = nil,
    RemoteEventConnection = nil,
    OriginalSprintValue = nil,
    OriginalRemote = nil,
    FakeRemote = nil,
    OriginalParent = nil,
    OriginalIndex = nil,
    OriginalNewIndex = nil,
    SecureTable = nil
}

local antiStunConnection = nil
MainModule.AutoQTE = {
    AntiStunEnabled = false
}

local bypassRagdollConnection = nil

local function DeepRemoveDashRequest()
    local Environment = (getgenv or function() return _G end)()
    local CoreServices = game:GetService("ReplicatedStorage")

    local function ProcessTargetObject()
        local RemoteContainer = CoreServices:FindFirstChild("Remotes")
        local TargetRemote = RemoteContainer and RemoteContainer:FindFirstChild("DashRequest")
        
        if TargetRemote then
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
            
            local RemoteMethods = {"FireServer", "InvokeServer", "OnClientEvent", "OnClientInvoke"}
            for _, MethodName in ipairs(RemoteMethods) do
                pcall(function()
                    local original = TargetRemote[MethodName]
                    if original then
                        MainModule.FreeDash["Original" .. MethodName] = original
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
            
            pcall(function()
                TargetRemote.Archivable = false
                MainModule.FreeDash.OriginalParent = TargetRemote.Parent
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
                            return
                        end
                        return MainModule.FreeDash.OriginalNewIndex(self, Property, Value)
                    end
                end
            end
        end
    end

    ProcessTargetObject()
    
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

local function BlockNewDashRequests()
    local CoreServices = game:GetService("ReplicatedStorage")
    local remoteFolder = CoreServices:WaitForChild("Remotes", 1)
    if remoteFolder then
        MainModule.FreeDash.ChildAddedHook = remoteFolder.ChildAdded:Connect(function(child)
            if child.Name == "DashRequest" then
                task.spawn(function()
                    task.wait(0.05)
                    pcall(function()
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

function MainModule.ToggleFreeDash(enabled)
    MainModule.FreeDash.Enabled = enabled

    if enabled then
        MainModule.ShowNotification("Free Dash", "Free Dash Enabled", 3)
    else
        MainModule.ShowNotification("Free Dash", "Free Dash Disabled", 3)
    end
    
    if enabled then
        DeepRemoveDashRequest()
        BlockNewDashRequests()

        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                MainModule.FreeDash.OriginalSprintValue = fasterSprint.Value
                fasterSprint.Value = 8
            end
        end
        
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            remote = remote:FindFirstChild("DashRequest")
            if remote then
                MainModule.FreeDash.RemoteEventConnection = remote:GetPropertyChangedSignal("Parent"):Connect(function()
                    pcall(function()
                        if remote.Parent == nil then
                            if MainModule.FreeDash.FakeRemote then
                                MainModule.FreeDash.FakeRemote.Parent = MainModule.FreeDash.OriginalParent
                            end
                        end
                    end)
                end)
            end
        end
        
    else
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
        
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                fasterSprint.Value = MainModule.FreeDash.OriginalSprintValue
            end
        end
        
        if MainModule.FreeDash.OriginalRemote and MainModule.FreeDash.OriginalParent then
            pcall(function()
                MainModule.FreeDash.OriginalRemote.Parent = MainModule.FreeDash.OriginalParent
            end)
        end
        
        if MainModule.FreeDash.FakeRemote then
            pcall(function() MainModule.FreeDash.FakeRemote:Destroy() end)
            MainModule.FreeDash.FakeRemote = nil
        end
        
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

function MainModule.ToggleAntiStunQTE(enabled)
    MainModule.AutoQTE.AntiStunEnabled = enabled

    if enabled then
        MainModule.ShowNotification("Anti-Stun QTE", "Anti-Stun QTE Enabled", 3)
    else
        MainModule.ShowNotification("Anti-Stun QTE", "Anti-Stun QTE Disabled", 3)
    end
    
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

function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled

    if enabled then
        MainModule.ShowNotification("Bypass Ragdoll", "Bypass Ragdoll Enabled", 3)
    else
        MainModule.ShowNotification("Bypass Ragdoll", "Bypass Ragdoll Disabled", 3)
    end
    
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
                
                local moveDirection = Humanoid.MoveDirection
                local isPlayerControlling = moveDirection.Magnitude > 0
                local playerVelocity = HumanoidRootPart.Velocity
                local playerSpeed = Vector3.new(playerVelocity.X, 0, playerVelocity.Z).Magnitude
                
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
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local currentVelocity = part.Velocity
                        local horizontalSpeed = Vector3.new(currentVelocity.X, 0, currentVelocity.Z).Magnitude
                        
                        local speedThreshold = isPlayerControlling and 150 or 50
                        
                        if horizontalSpeed > speedThreshold and part ~= HumanoidRootPart then
                            local newVelocity = Vector3.new(
                                currentVelocity.X * 0.8,
                                currentVelocity.Y,
                                currentVelocity.Z * 0.8
                            )
                            part.Velocity = newVelocity
                        end
                        for _, force in pairs(part:GetChildren()) do
                            if force:IsA("BodyForce") then
                                local forceMagnitude = force.Force.Magnitude
                                if forceMagnitude > 1000 then
                                    force:Destroy()
                                end
                            elseif force:IsA("BodyVelocity") then
                                if force.Velocity.Magnitude > 30 and not isPlayerControlling then
                                    force:Destroy()
                                end
                            end
                        end
                    end
                end
                local playerInputVelocity = HumanoidRootPart.Velocity
                local externalForces = {}
                for _, force in pairs(HumanoidRootPart:GetChildren()) do
                    if force:IsA("BodyForce") or force:IsA("BodyVelocity") then
                        table.insert(externalForces, force)
                    end
                end
                
                local shouldFilterVelocity = #externalForces > 0 and not isPlayerControlling
                
                if shouldFilterVelocity then
                    local filteredVelocity = Vector3.new(
                        playerInputVelocity.X,
                        HumanoidRootPart.Velocity.Y,
                        playerInputVelocity.Z
                    )
                    HumanoidRootPart.Velocity = filteredVelocity
                    for _, force in pairs(externalForces) do
                        task.spawn(function()
                            if force:IsA("BodyVelocity") then
                                for i = 1, 5 do
                                    if force and force.Parent then
                                        force.Velocity = force.Velocity * 0.5
                                        task.wait(0.02)
                                    end
                                end
                            end
                            pcall(function() force:Destroy() end)
                        end)
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
        MainModule.StopEnhancedProtection()
        MainModule.StopJointCleaning()
    end
end

function MainModule.ToggleRemoveStun(enabled)
    MainModule.Misc.RemoveStunEnabled = enabled

    if enabled then
        MainModule.ShowNotification("Remove Stun", "Remove Stun Enabled", 3)
    end
    
    if not enabled then return end
    
    local function removeStunEffects()
        local character = GetCharacter()
        if not character then return end
        
        for _, effectName in ipairs(harmfulEffectsList) do
            local effect = character:FindFirstChild(effectName)
            if effect then
                pcall(function() effect:Destroy() end)
            end
        end
        
        local humanoid = GetHumanoid(character)
        if humanoid then
            if humanoid:GetAttribute("Stunned") then
                humanoid:SetAttribute("Stunned", false)
            end
        end
    end
    
    removeStunEffects()
    
    if MainModule.Misc.RemoveStunEnabled then
        local connection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.RemoveStunEnabled then 
                connection:Disconnect()
                return 
            end
            removeStunEffects()
        end)
    end
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

-- ============ GAMEPASS FUNCTIONS ============
function MainModule.EnablePermanentGuard()
    LocalPlayer:SetAttribute("__OwnsPermGuard", true)
    MainModule.ShowNotification("GamePass", "Permanent Guard: Successfully granted", 3)
end

function MainModule.EnableGlassManufacturerVision()
    LocalPlayer:SetAttribute("__OwnsGlassManufacturerVision", true)
    MainModule.ShowNotification("GamePass", "Glass Manufacturer Vision: Successfully granted", 3)
end

function MainModule.EnableFreeVIP()
    LocalPlayer:SetAttribute("__OwnsVIPGamepass", true)
    LocalPlayer:SetAttribute("VIPChatTag", true)
    MainModule.ShowNotification("GamePass", "Free VIP: Successfully granted", 3)
end

function MainModule.EnableEmotePages()
    LocalPlayer:SetAttribute("__OwnsEmotePages", true)
    MainModule.ShowNotification("GamePass", "Emote Pages: Successfully granted", 3)
end

function MainModule.EnableCustomPlayerTag()
    LocalPlayer:SetAttribute("__OwnsCustomPlayerTag", true)
    MainModule.ShowNotification("GamePass", "Custom Player Tag: Successfully granted", 3)
end

function MainModule.EnablePrivateServerPlus()
    LocalPlayer:SetAttribute("__OwnsPSPlus", true)
    MainModule.ShowNotification("GamePass", "Private Server Plus: Successfully granted", 3)
end

function MainModule.RLGL_TP_ToStart()
    task.spawn(function()
        if not IsGameActive("RedLightGreenLight") then
            MainModule.ShowNotification("RLGL", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(-55.3, 1023.1, -545.8)) then
            MainModule.ShowNotification("RLGL", "Teleported to Start", 2)
        end
    end)
end

function MainModule.RLGL_TP_ToEnd()
    task.spawn(function()
        if not IsGameActive("RedLightGreenLight") then
            MainModule.ShowNotification("RLGL", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(-214.4, 1023.1, 146.7)) then
            MainModule.ShowNotification("RLGL", "Teleported to End", 2)
        end
    end)
end

MainModule.GodMode = {
    Enabled = false,
    Connection = nil,
    OriginalY = nil,      -- Сохраняем только высоту Y
    OriginalHealth = nil,
    CurrentX = nil,       -- Текущие координаты X и Z
    CurrentZ = nil,
    LastGameCheck = nil
}

function MainModule.ToggleGodMode(enabled)
    if MainModule.GodMode.Connection then
        MainModule.GodMode.Connection:Disconnect()
        MainModule.GodMode.Connection = nil
    end
    
    if not enabled then
        if MainModule.GodMode.OriginalY and IsGameActive("RedLightGreenLight") then
            local character = GetCharacter()
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
                if rootPart and MainModule.GodMode.CurrentX and MainModule.GodMode.CurrentZ then
                    -- Возвращаем на ту же высоту, но с текущими X и Z
                    local returnPosition = Vector3.new(
                        rootPart.Position.X,  -- Текущий X
                        MainModule.GodMode.OriginalY,  -- Оригинальная высота
                        rootPart.Position.Z   -- Текущий Z
                    )
                    
                    if SafeTeleport(returnPosition) then
                        MainModule.ShowNotification("GodMode", "Disabled", 2)
                    end
                end
            end
        end
        
        MainModule.GodMode.OriginalY = nil
        MainModule.GodMode.OriginalHealth = nil
        MainModule.GodMode.CurrentX = nil
        MainModule.GodMode.CurrentZ = nil
        MainModule.GodMode.LastGameCheck = nil
        MainModule.GodMode.Enabled = false
        
        MainModule.ShowNotification("GodMode", "Disabled", 2)
        return
    end
    
    MainModule.GodMode.Enabled = true
    
    if not IsGameActive("RedLightGreenLight") then
        MainModule.ShowNotification("GodMode", "Game Not Active", 2)
        MainModule.GodMode.Enabled = false
        return
    end
    
    local character = GetCharacter()
    if not character then
        MainModule.ShowNotification("GodMode", "Game Not Active", 2)
        MainModule.GodMode.Enabled = false
        return
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart or not humanoid then
        MainModule.ShowNotification("GodMode", "Game Not Active", 2)
        MainModule.GodMode.Enabled = false
        return
    end
    
    -- Сохраняем только высоту Y и текущие координаты
    MainModule.GodMode.OriginalY = rootPart.Position.Y
    MainModule.GodMode.CurrentX = rootPart.Position.X
    MainModule.GodMode.CurrentZ = rootPart.Position.Z
    MainModule.GodMode.OriginalHealth = humanoid.Health
    MainModule.GodMode.LastGameCheck = true
    
    -- Телепортируем на 170 блоков вверх с теми же X и Z
    local safePosition = Vector3.new(
        rootPart.Position.X,
        rootPart.Position.Y + 170,
        rootPart.Position.Z
    )
    
    if SafeTeleport(safePosition) then
        MainModule.ShowNotification("GodMode", "Enabled", 2)
    else
        MainModule.ShowNotification("GodMode", "Game Not Active", 2)
        MainModule.GodMode.Enabled = false
        MainModule.GodMode.OriginalY = nil
        MainModule.GodMode.CurrentX = nil
        MainModule.GodMode.CurrentZ = nil
        MainModule.GodMode.OriginalHealth = nil
        return
    end
    
    MainModule.GodMode.Connection = RunService.Heartbeat:Connect(function()
        if not MainModule.GodMode.Enabled then 
            if MainModule.GodMode.Connection then
                MainModule.GodMode.Connection:Disconnect()
                MainModule.GodMode.Connection = nil
            end
            return 
        end
        
        local isGameActive = IsGameActive("RedLightGreenLight")
        
        if not isGameActive then
            if MainModule.GodMode.Connection then
                MainModule.GodMode.Connection:Disconnect()
                MainModule.GodMode.Connection = nil
            end
            
            MainModule.GodMode.Enabled = false
            MainModule.GodMode.OriginalY = nil
            MainModule.GodMode.CurrentX = nil
            MainModule.GodMode.CurrentZ = nil
            MainModule.GodMode.OriginalHealth = nil
            MainModule.GodMode.LastGameCheck = nil
            
            MainModule.ShowNotification("GodMode", "Game Ended - Disabled", 2)
            return
        end
        
        local currentCharacter = GetCharacter()
        if not currentCharacter then
            return
        end
        
        local currentRootPart = currentCharacter:FindFirstChild("HumanoidRootPart") or currentCharacter.PrimaryPart
        local currentHumanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
        
        if not currentRootPart or not currentHumanoid then
            return
        end
        
        if MainModule.GodMode.OriginalHealth and currentHumanoid.Health < MainModule.GodMode.OriginalHealth then
            if SafeTeleport(Vector3.new(-903.4, 1184.9, -556)) then
                MainModule.ShowNotification("GodMode", "Safe to Player", 2)
            end
            
            if MainModule.GodMode.Connection then
                MainModule.GodMode.Connection:Disconnect()
                MainModule.GodMode.Connection = nil
            end
            
            MainModule.GodMode.Enabled = false
            MainModule.GodMode.OriginalY = nil
            MainModule.GodMode.CurrentX = nil
            MainModule.GodMode.CurrentZ = nil
            MainModule.GodMode.OriginalHealth = nil
            MainModule.GodMode.LastGameCheck = nil
            return
        end
    end)
end

MainModule.AutoSafe = {
    Enabled = false,
    Connection = nil,
    HasTeleported = false,  -- Флаг, что уже телепортировали
    LowHPChecked = false    -- Флаг, что HP было ниже порога
}

function MainModule.ToggleAutoSafe(enabled)
    if MainModule.AutoSafe.Connection then
        MainModule.AutoSafe.Connection:Disconnect()
        MainModule.AutoSafe.Connection = nil
    end
    
    MainModule.AutoSafe.Enabled = enabled
    MainModule.AutoSafe.HasTeleported = false  -- Сбрасываем флаг при включении/выключении
    MainModule.AutoSafe.LowHPChecked = false
    
    if enabled then
        MainModule.AutoSafe.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoSafe.Enabled then 
                if MainModule.AutoSafe.Connection then
                    MainModule.AutoSafe.Connection:Disconnect()
                    MainModule.AutoSafe.Connection = nil
                end
                return 
            end
            
            local noSafeGames = {
                "Mingle",
                "JumpRope", 
                "Pentathlon",
                "GlassBridge",
                "SquidGame",
                "SkySquidGame",
                "TugOfWar"
            }
            
            local isNoSafeGame = false
            for _, gameName in pairs(noSafeGames) do
                if IsGameActive(gameName) then
                    isNoSafeGame = true
                    break
                end
            end
            
            if isNoSafeGame then
                return
            end
            
            local character = GetCharacter()
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if IsGameActive("RedLightGreenLight") then
                        if humanoid.Health <= 35 then
                            -- HP ниже или равно 25 в RLGL
                            if not MainModule.AutoSafe.HasTeleported then
                                -- Еще не телепортировали - телепортируем ВВЕРХ
                                local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
                                if rootPart then
                                    -- Берем текущую позицию и добавляем 100 вверх по оси Y
                                    local currentPosition = rootPart.Position
                                    local newPosition = Vector3.new(
                                        currentPosition.X,
                                        currentPosition.Y + 100,  -- Телепорт ВВЕРХ на 100 юнитов
                                        currentPosition.Z
                                    )
                                    rootPart.CFrame = CFrame.new(newPosition)
                                    
                                    MainModule.AutoSafe.HasTeleported = true
                                    MainModule.AutoSafe.LowHPChecked = true
                                    MainModule.ShowNotification("AutoSafe", "Saved from Red Light!", 2)
                                end
                            end
                        elseif humanoid.Health > 35 and MainModule.AutoSafe.HasTeleported then
                            -- HP восстановилось выше 25 в RLGL - сбрасываем флаг
                            MainModule.AutoSafe.HasTeleported = false
                        end
                    elseif IsGameActive("HideAndSeek") or IsGameActive("LightsOut") or IsGameActive("LightOut") then
                        if humanoid.Health <= 30 then
                            -- HP ниже или равно 20 в HideAndSeek/LightsOut
                            if not MainModule.AutoSafe.HasTeleported then
                                -- Еще не телепортировали - телепортируем ВВЕРХ
                                local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
                                if rootPart then
                                    -- Берем текущую позицию и добавляем 100 вверх по оси Y
                                    local currentPosition = rootPart.Position
                                    local newPosition = Vector3.new(
                                        currentPosition.X,
                                        currentPosition.Y + 100,  -- Телепорт ВВЕРХ на 100 юнитов
                                        currentPosition.Z
                                    )
                                    rootPart.CFrame = CFrame.new(newPosition)
                                    
                                    MainModule.AutoSafe.HasTeleported = true
                                    MainModule.AutoSafe.LowHPChecked = true
                                    MainModule.ShowNotification("AutoSafe", "Auto-saved!", 2)
                                end
                            end
                        elseif humanoid.Health > 30 and MainModule.AutoSafe.HasTeleported then
                            -- HP восстановилось выше 20 - сбрасываем флаг
                            MainModule.AutoSafe.HasTeleported = false
                        end
                    else
                        if humanoid.Health <= 30 then
                            -- HP ниже или равно 20 в других играх
                            if not MainModule.AutoSafe.HasTeleported then
                                -- Еще не телепортировали - телепортируем ВВЕРХ
                                local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
                                if rootPart then
                                    -- Берем текущую позицию и добавляем 100 вверх по оси Y
                                    local currentPosition = rootPart.Position
                                    local newPosition = Vector3.new(
                                        currentPosition.X,
                                        currentPosition.Y + 100,  -- Телепорт ВВЕРХ на 100 юнитов
                                        currentPosition.Z
                                    )
                                    rootPart.CFrame = CFrame.new(newPosition)
                                    
                                    MainModule.AutoSafe.HasTeleported = true
                                    MainModule.AutoSafe.LowHPChecked = true
                                    MainModule.ShowNotification("AutoSafe", "Auto-saved!", 2)
                                end
                            end
                        elseif humanoid.Health > 30 and MainModule.AutoSafe.HasTeleported then
                            -- HP восстановилось выше 20 - сбрасываем флаг
                            MainModule.AutoSafe.HasTeleported = false
                        end
                    end
                end
            end
        end)
        MainModule.ShowNotification("AutoSafe", "AutoSafe: ON", 2)
    else
        MainModule.ShowNotification("AutoSafe", "AutoSafe: OFF", 2)
    end
end

function MainModule.Dalgona_Complete()
    task.spawn(function()
        if not IsGameActive("Dalgona") then
            MainModule.ShowNotification("Dalgona", "Game not active", 2)
            return
        end
        local DalgonaClientModule = ReplicatedStorage:FindFirstChild("Modules") and
                                    ReplicatedStorage.Modules:FindFirstChild("Games") and
                                    ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
        if not DalgonaClientModule then 
            MainModule.ShowNotification("Dalgona", "Module not found", 2)
            return 
        end
        
        pcall(function()
            for _, func in pairs(debug.getregistry()) do
                if typeof(func) == "function" and islclosure(func) then
                    local info = debug.getinfo(func)
                    if info.nups == 76 then
                        debug.setupvalue(func, 33, 9999)
                        debug.setupvalue(func, 34, 9999)
                        MainModule.ShowNotification("Dalgona", "Completed Successfully", 2)
                        return
                    end
                end
            end
            MainModule.ShowNotification("Dalgona", "Failed to complete", 2)
        end)
    end)
end

function MainModule.Dalgona_FreeLighter()
    task.spawn(function()
        if not IsGameActive("Dalgona") then
            MainModule.ShowNotification("Dalgona", "Game not active", 2)
            return
        end
        LocalPlayer:SetAttribute("HasLighter", true)
        MainModule.ShowNotification("Dalgona", "Lighter Unlocked", 2)
    end)
end

MainModule.HNS = {
    InfinityStaminaEnabled = false,
    InfinityStaminaConnection = nil
}

function MainModule.ToggleHNSInfinityStamina(enabled)
    if enabled and not IsGameActive("HideAndSeek") then
        MainModule.ShowNotification("HNS", "Game not active", 2)
        MainModule.HNS.InfinityStaminaEnabled = false
        return
    end
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    MainModule.HNS.InfinityStaminaEnabled = enabled
    
    if enabled then
        MainModule.HNS.InfinityStaminaConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.InfinityStaminaEnabled then 
                if MainModule.HNS.InfinityStaminaConnection then
                    MainModule.HNS.InfinityStaminaConnection:Disconnect()
                    MainModule.HNS.InfinityStaminaConnection = nil
                end
                return 
            end
            
            if not IsGameActive("HideAndSeek") then
                MainModule.HNS.InfinityStaminaEnabled = false
                if MainModule.HNS.InfinityStaminaConnection then
                    MainModule.HNS.InfinityStaminaConnection:Disconnect()
                    MainModule.HNS.InfinityStaminaConnection = nil
                end
                MainModule.ShowNotification("HNS", "Game ended - Infinity Stamina disabled", 2)
                return
            end
            
            local character = GetCharacter()
            if character then
                local stamina = character:FindFirstChild("StaminaVal")
                if stamina then
                    stamina.Value = 100
                end
            end
        end)
        MainModule.ShowNotification("HNS", "Infinity Stamina: ON", 2)
    else
        MainModule.ShowNotification("HNS", "Infinity Stamina: OFF", 2)
    end
end

MainModule.SpikesKillFeature = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://105341857343164",
        "rbxassetid://95623680038308",
        "rbxassetid://106191977814264",
        "rbxassetid://118039465583394"
    },
    SpikesPosition = nil,
    PlatformHeightOffset = 10,
    ReturnDelay = 0.6,
    OriginalCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    SafetyCheckConnection = nil,
    PlatformPart = nil,
    PlatformCreated = false
}

function MainModule.ToggleSpikesKill(enabled)
    if enabled and not IsGameActive("HideAndSeek") then
        MainModule.ShowNotification("Spikes Kill", "Game not active", 2)
        MainModule.SpikesKillFeature.Enabled = false
        return
    end
    
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
    
    for _, conn in ipairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKillFeature.AnimationStoppedConnections = {}
    
    if MainModule.SpikesKillFeature.PlatformPart then
        pcall(function() MainModule.SpikesKillFeature.PlatformPart:Destroy() end)
        MainModule.SpikesKillFeature.PlatformPart = nil
    end
    MainModule.SpikesKillFeature.PlatformCreated = false
    
    MainModule.SpikesKillFeature.OriginalCFrame = nil
    MainModule.SpikesKillFeature.ActiveAnimation = false
    MainModule.SpikesKillFeature.AnimationStartTime = 0
    MainModule.SpikesKillFeature.TrackedAnimations = {}
    MainModule.SpikesKillFeature.NoKnifeTimer = 0
    MainModule.SpikesKillFeature.SpikesPosition = nil
    
    if not enabled then
        MainModule.ShowNotification("Spikes Kill", "Disabled", 2)
        MainModule.SpikesKillFeature.Enabled = false
        return
    end
    
    pcall(function()
        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
        if killingParts then
            for _, spike in pairs(killingParts:GetChildren()) do
                if spike:IsA("BasePart") then
                    if not MainModule.SpikesKillFeature.SpikesPosition then
                        MainModule.SpikesKillFeature.SpikesPosition = spike.Position
                    end
                    spike:Destroy()
                end
            end
        end
    end)
    
    local function createSafetyPlatform()
        if MainModule.SpikesKillFeature.PlatformCreated then return end
        if not MainModule.SpikesKillFeature.SpikesPosition then return end
        
        pcall(function()
            local platform = Instance.new("Part")
            platform.Name = "SafetyPlatform"
            platform.Size = Vector3.new(20, 1, 20)
            platform.Position = MainModule.SpikesKillFeature.SpikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
            platform.Anchored = true
            platform.CanCollide = true
            platform.Transparency = 1
            platform.Color = Color3.fromRGB(0, 255, 0)
            
            local collision = Instance.new("BoolValue")
            collision.Name = "SafePlatform"
            collision.Value = true
            collision.Parent = platform
            
            platform.Parent = workspace
            
            MainModule.SpikesKillFeature.PlatformPart = platform
            MainModule.SpikesKillFeature.PlatformCreated = true
        end)
    end
    
    local function teleportToSafetyPlatform(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        if not MainModule.SpikesKillFeature.PlatformCreated then
            createSafetyPlatform()
        end
        
        if MainModule.SpikesKillFeature.SpikesPosition and MainModule.SpikesKillFeature.PlatformPart then
            MainModule.SpikesKillFeature.OriginalCFrame = character:GetPrimaryPartCFrame()
            
            local targetPosition = MainModule.SpikesKillFeature.PlatformPart.Position + Vector3.new(0, 3, 0)
            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        end
    end
    
    local function returnToOriginalPosition(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        if MainModule.SpikesKillFeature.OriginalCFrame then
            character:SetPrimaryPartCFrame(MainModule.SpikesKillFeature.OriginalCFrame)
            MainModule.SpikesKillFeature.OriginalCFrame = nil
        end
    end
    
    local function isKillAnimation(animationId)
        for _, id in ipairs(MainModule.SpikesKillFeature.AnimationIds) do
            if animationId == id then
                return true
            end
        end
        return false
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid")
        
        MainModule.SpikesKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.SpikesKillFeature.Enabled then return end
            
            if track.Animation and isKillAnimation(track.Animation.AnimationId) then
                MainModule.SpikesKillFeature.TrackedAnimations[track] = true
                
                if not MainModule.SpikesKillFeature.ActiveAnimation then
                    MainModule.SpikesKillFeature.ActiveAnimation = true
                    MainModule.SpikesKillFeature.AnimationStartTime = tick()
                    
                    teleportToSafetyPlatform(char)
                    
                    local stoppedConn = track.Stopped:Connect(function()
                        task.wait(MainModule.SpikesKillFeature.ReturnDelay)
                        
                        if MainModule.SpikesKillFeature.OriginalCFrame then
                            returnToOriginalPosition(char)
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
    
    MainModule.SpikesKillFeature.SafetyCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then 
            if MainModule.SpikesKillFeature.SafetyCheckConnection then
                MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
                MainModule.SpikesKillFeature.SafetyCheckConnection = nil
            end
            return 
        end
        
        if not IsGameActive("HideAndSeek") then
            MainModule.SpikesKillFeature.Enabled = false
            MainModule.ShowNotification("Spikes Kill", "Game ended - disabled", 2)
            return
        end
        
        if MainModule.SpikesKillFeature.PlatformCreated and 
           (not MainModule.SpikesKillFeature.PlatformPart or not MainModule.SpikesKillFeature.PlatformPart.Parent) then
            MainModule.SpikesKillFeature.PlatformCreated = false
            MainModule.SpikesKillFeature.PlatformPart = nil
            createSafetyPlatform()
        end
        
        if MainModule.SpikesKillFeature.ActiveAnimation and tick() - MainModule.SpikesKillFeature.AnimationStartTime >= 10 then
            local character = GetCharacter()
            if character and MainModule.SpikesKillFeature.OriginalCFrame then
                returnToOriginalPosition(character)
            end
            MainModule.SpikesKillFeature.ActiveAnimation = false
            MainModule.SpikesKillFeature.TrackedAnimations = {}
        end
    end)
    
    MainModule.SpikesKillFeature.Enabled = true
    MainModule.ShowNotification("Spikes Kill", "Enabled", 2)
    
    createSafetyPlatform()
end

MainModule.AutoGonggi = {
    Enabled = false,
    CheckInterval = 0.05,
    StoneCheckInterval = 0.5,
    LastProcessedImage = nil,
    IsProcessingQTE = false,
    ProcessingStones = false,
    QTEThread = nil,
    StoneThread = nil
}

local function getGonggiUI()
    local player = game:GetService("Players").LocalPlayer
    if not player then return nil end
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local ui = playerGui:FindFirstChild("Gonggi")
    if not ui and playerGui:FindFirstChild("OtherUIHolder") then
        ui = playerGui.OtherUIHolder:FindFirstChild("Gonggi")
    end
    
    return ui
end

local function processGonggiQTE()
    if MainModule.AutoGonggi.IsProcessingQTE then return end
    
    MainModule.AutoGonggi.IsProcessingQTE = true
    
    local ui = getGonggiUI()
    if not ui then 
        MainModule.AutoGonggi.IsProcessingQTE = false
        return 
    end
    
    local qteScreen = ui:FindFirstChild("QTEScreen")
    if not qteScreen or not qteScreen.Visible then
        MainModule.AutoGonggi.LastProcessedImage = nil
        MainModule.AutoGonggi.IsProcessingQTE = false
        return
    end
    
    local container = qteScreen:FindFirstChild("MainBar")
    container = container and container:FindFirstChild("ButtonContents")
    container = container and container:FindFirstChild("Inner")
    
    local mobileButtons = ui:FindFirstChild("MobileButtons")
    
    if not container or not mobileButtons then
        MainModule.AutoGonggi.LastProcessedImage = nil
        MainModule.AutoGonggi.IsProcessingQTE = false
        return
    end
    
    local foundActive = false
    
    for _, img in pairs(container:GetChildren()) do
        if img:IsA("ImageLabel") and img.ImageTransparency < 0.1 then
            foundActive = true
            
            if img ~= MainModule.AutoGonggi.LastProcessedImage then
                MainModule.AutoGonggi.LastProcessedImage = img
                
                local inputType = img:GetAttribute("InputType")
                if inputType then
                    local btnName = tostring(inputType)
                    local btn = mobileButtons:FindFirstChild(btnName)
                    
                    if btn then
                        if getconnections then
                            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                                conn:Fire()
                            end
                        elseif firesignal then
                            firesignal(btn.MouseButton1Click)
                        else
                            btn:Fire("MouseButton1Click")
                        end
                        
                        task.wait(0.1)
                    end
                end
            end
            break
        end
    end
    
    if not foundActive then
        MainModule.AutoGonggi.LastProcessedImage = nil
    end
    
    MainModule.AutoGonggi.IsProcessingQTE = false
end

local function processGonggiStones()
    if MainModule.AutoGonggi.ProcessingStones then return end
    MainModule.AutoGonggi.ProcessingStones = true
    
    local pentathlonMap = workspace:FindFirstChild("PentathlonMap")
    if not pentathlonMap then 
        MainModule.AutoGonggi.ProcessingStones = false
        return 
    end
    
    local stoneNames = {"Stone1", "Stone2", "Stone3", "Stone4", "Stone5", 
                       "GonggiStone1", "GonggiStone2", "GonggiStone3", "GonggiStone4", "GonggiStone5"}
    
    for _, stoneName in ipairs(stoneNames) do
        local stone = pentathlonMap:FindFirstChild(stoneName, true)
        if stone and stone:IsA("BasePart") then
            if not stone.Anchored then
                stone.Anchored = true
            end
            
            if stone.CanCollide then
                stone.CanCollide = false
            end
            
            if not stone:FindFirstChild("AutoHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "AutoHighlight"
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.OutlineColor = Color3.new(0, 0.8, 0)
                highlight.FillTransparency = 0.7
                highlight.Parent = stone
            end
        end
    end
    
    local collectionService = game:GetService("CollectionService")
    local stones = collectionService:GetTagged("GonggiStone")
    
    for _, stone in ipairs(stones) do
        if stone:IsA("BasePart") then
            if not stone.Anchored then
                stone.Anchored = true
            end
            
            if stone.CanCollide then
                stone.CanCollide = false
            end
            
            if not stone:FindFirstChild("AutoHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "AutoHighlight"
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.OutlineColor = Color3.new(0, 0.8, 0)
                highlight.FillTransparency = 0.7
                highlight.Parent = stone
            end
        end
    end
    
    MainModule.AutoGonggi.ProcessingStones = false
end

function MainModule.ToggleAutoGonggi(enabled)
    if not IsGameActive("Pentathlon") then
        MainModule.ShowNotification("AutoGonggi", "Pentathlon game not active", 2)
        if MainModule.AutoGonggi.Enabled then
            MainModule.ToggleAutoGonggi(false)
        end
        return false
    end
    
    if MainModule.AutoGonggi.Enabled == enabled then
        return MainModule.AutoGonggi.Enabled
    end
    
    if MainModule.AutoGonggi.QTEThread then
        task.cancel(MainModule.AutoGonggi.QTEThread)
        MainModule.AutoGonggi.QTEThread = nil
    end
    
    if MainModule.AutoGonggi.StoneThread then
        task.cancel(MainModule.AutoGonggi.StoneThread)
        MainModule.AutoGonggi.StoneThread = nil
    end
    
    MainModule.AutoGonggi.LastProcessedImage = nil
    MainModule.AutoGonggi.IsProcessingQTE = false
    MainModule.AutoGonggi.ProcessingStones = false
    
    MainModule.AutoGonggi.Enabled = enabled
    
    if enabled then
        MainModule.AutoGonggi.QTEThread = task.spawn(function()
            while MainModule.AutoGonggi.Enabled do
                if not IsGameActive("Pentathlon") then
                    MainModule.AutoGonggi.Enabled = false
                    if MainModule.AutoGonggi.QTEThread then
                        task.cancel(MainModule.AutoGonggi.QTEThread)
                        MainModule.AutoGonggi.QTEThread = nil
                    end
                    if MainModule.AutoGonggi.StoneThread then
                        task.cancel(MainModule.AutoGonggi.StoneThread)
                        MainModule.AutoGonggi.StoneThread = nil
                    end
                    MainModule.SnowNotification("AutoGonggi", "Pentathlon ended - AutoGonggi disabled", 2)
                    return
                end
                
                processGonggiQTE()
                task.wait(MainModule.AutoGonggi.CheckInterval)
            end
        end)
        
        MainModule.AutoGonggi.StoneThread = task.spawn(function()
            while MainModule.AutoGonggi.Enabled do
                if not IsGameActive("Pentathlon") then
                    MainModule.AutoGonggi.Enabled = false
                    return
                end
                
                processGonggiStones()
                task.wait(MainModule.AutoGonggi.StoneCheckInterval)
            end
        end)
        MainModule.SnowNotification("AutoGonggi", "AutoGonggi: ON", 2)
    else
        task.spawn(function()
            local pentathlonMap = workspace:FindFirstChild("PentathlonMap")
            if pentathlonMap then
                for _, obj in pairs(pentathlonMap:GetDescendants()) do
                    if obj:IsA("BasePart") and obj:FindFirstChild("AutoHighlight") then
                        obj.AutoHighlight:Destroy()
                    end
                end
            end
            
            local collectionService = game:GetService("CollectionService")
            local stones = collectionService:GetTagged("GonggiStone")
            for _, stone in ipairs(stones) do
                if stone:IsA("BasePart") and stone:FindFirstChild("AutoHighlight") then
                    stone.AutoHighlight:Destroy()
                end
            end
        end)
        MainModule.SnowNotification("AutoGonggi", "AutoGonggi: OFF", 2)
    end
    
    return MainModule.AutoGonggi.Enabled
end

function MainModule.ForceStopAutoGonggi()
    MainModule.ToggleAutoGonggi(false)
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
    DodgeCooldown = 0.9,
    Range = 5,
    RangeSquared = 5 * 5,
    AnimationIdsSet = {},
    
    -- УПРОЩЕННАЯ СИСТЕМА ОТСЛЕЖИВАНИЯ
    ActiveAnimations = {}, -- playerName -> {animationId = true} - активные анимации
    LastAnimationStartTime = {}, -- playerName -> lastAnimationStartTime
    
    -- Система перехвата
    CapturedCall = nil,
    LastCapturedCallTime = 0,
    OriginalFireServer = nil,
    Remote = nil,
    
    -- Для максимальной скорости
    HeartbeatConnection = nil
}

-- Заполняем сет анимаций
for _, id in ipairs(MainModule.AutoDodge.AnimationIds) do
    MainModule.AutoDodge.AnimationIdsSet[id] = true
end

-- ============ СИСТЕМА ПЕРЕХВАТА ВЫЗОВОВ ============

local function setupRemoteHook()
    local remote = nil
    local rs = game:GetService("ReplicatedStorage")
    
    -- Быстрый поиск
    local function quickFindRemote()
        if rs:FindFirstChild("Remotes") then
            local remotesFolder = rs.Remotes
            for _, child in pairs(remotesFolder:GetChildren()) do
                if child:IsA("RemoteEvent") and child.Name == "UsedTool" then
                    return child
                end
            end
        end
        
        if rs:FindFirstChild("Events") then
            local eventsFolder = rs.Events
            for _, child in pairs(eventsFolder:GetChildren()) do
                if child:IsA("RemoteEvent") and child.Name == "UsedTool" then
                    return child
                end
            end
        end
        
        return nil
    end
    
    remote = quickFindRemote()
    
    if not remote then
        return false
    end
    
    MainModule.AutoDodge.Remote = remote
    
    MainModule.AutoDodge.OriginalFireServer = hookfunction(remote.FireServer, function(self, ...)
        local args = {...}
        
        for i, arg in ipairs(args) do
            if typeof(arg) == "Instance" and arg:IsA("Tool") and arg.Name == "DODGE!" then
                MainModule.AutoDodge.CapturedCall = {
                    args = {unpack(args)},
                    timestamp = tick(),
                    tool = arg
                }
                MainModule.AutoDodge.LastCapturedCallTime = tick()
                break
            elseif typeof(arg) == "table" then
                for _, v in pairs(arg) do
                    if typeof(v) == "Instance" and v:IsA("Tool") and v.Name == "DODGE!" then
                        MainModule.AutoDodge.CapturedCall = {
                            args = {unpack(args)},
                            timestamp = tick(),
                            tool = v
                        }
                        MainModule.AutoDodge.LastCapturedCallTime = tick()
                        break
                    end
                end
            end
        end
        
        return MainModule.AutoDodge.OriginalFireServer(self, ...)
    end)
    
    return true
end

-- ============ МГНОВЕННЫЙ ДОДЖ ============

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
    
    local dodgeTool
    local character = player.Character
    if character then
        dodgeTool = character:FindFirstChild("DODGE!")
        if not dodgeTool and player.Backpack then
            dodgeTool = player.Backpack:FindFirstChild("DODGE!")
        end
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
    
    local success = pcall(function()
        autoDodge.Remote:FireServer(unpack(modifiedArgs))
    end)
    
    if not success then
        pcall(function()
            autoDodge.Remote:FireServer(dodgeTool)
        end)
        return false
    end
    
    return true
end

-- ============ БЫСТРАЯ ПРОВЕРКА ВЗГЛЯДА ============

local function isLookingAtPlayer(targetPlayer, localPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    if not localPlayer or not localPlayer.Character then return false end
    
    local targetHead = targetPlayer.Character:FindFirstChild("Head")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not (targetHead and localRoot) then return false end
    
    local directionToLocal = (localRoot.Position - targetHead.Position).Unit
    local lookVector = targetHead.CFrame.LookVector
    
    return directionToLocal:Dot(lookVector) > -0.7
end

-- ============ МГНОВЕННАЯ ОБРАБОТКА ЧЕРЕЗ HEARTBEAT ============

local function setupHeartbeatProcessing()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local function instantHeartbeatCheck()
        if not MainModule.AutoDodge.Enabled then return end
        if not LocalPlayer or not LocalPlayer.Character then return end
        
        local autoDodge = MainModule.AutoDodge
        local currentTime = tick()
        
        -- Проверяем кулдаун доджа
        if currentTime - autoDodge.LastDodgeTime < autoDodge.DodgeCooldown then
            return
        end
        
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end
        
        -- Проверяем всех игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character then continue end
            
            local character = player.Character
            local targetRoot = character:FindFirstChild("HumanoidRootPart")
            if not targetRoot then continue end
            
            -- Быстрая проверка дистанции
            local distanceSquared = (targetRoot.Position - localRoot.Position).Magnitude
            if distanceSquared > autoDodge.RangeSquared then
                -- Если вне дистанции, очищаем анимации игрока
                autoDodge.ActiveAnimations[player.Name] = nil
                continue
            end
            
            -- Проверка взгляда
            if not isLookingAtPlayer(player, LocalPlayer) then
                continue
            end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then continue end
            
            -- Проверяем ВСЕ активные треки
            local playingTracks = humanoid:GetPlayingAnimationTracks()
            
            for _, track in pairs(playingTracks) do
                if track and track.Animation and track.IsPlaying then
                    local animId = track.Animation.AnimationId
                    
                    -- Проверяем, является ли эта анимация атакой
                    if autoDodge.AnimationIdsSet[animId] then
                        
                        -- Инициализируем таблицу для игрока если нужно
                        if not autoDodge.ActiveAnimations[player.Name] then
                            autoDodge.ActiveAnimations[player.Name] = {}
                        end
                        
                        -- Ключ для отслеживания: animationId + timestamp трека
                        local animationKey = animId
                        
                        -- Если эта анимация ЕЩЁ НЕ ОБРАБОТАНА для этого игрока
                        if not autoDodge.ActiveAnimations[player.Name][animationKey] then
                            -- ОТМЕЧАЕМ АНИМАЦИЮ КАК ОБРАБОТАННУЮ
                            autoDodge.ActiveAnimations[player.Name][animationKey] = true
                            
                            -- МГНОВЕННЫЙ ДОДЖ
                            if executeDodge() then
                                -- Отслеживаем окончание трека чтобы очистить запись
                                if track.Stopped then
                                    track.Stopped:Once(function()
                                        -- При окончании трека удаляем анимацию из активных
                                        if autoDodge.ActiveAnimations[player.Name] then
                                            autoDodge.ActiveAnimations[player.Name][animationKey] = nil
                                        end
                                    end)
                                else
                                    -- Если нет события Stopped, очищаем через 2 секунды
                                    task.delay(2, function()
                                        if autoDodge.ActiveAnimations[player.Name] then
                                            autoDodge.ActiveAnimations[player.Name][animationKey] = nil
                                        end
                                    end)
                                end
                                
                                return -- Останавливаем после успешного доджа
                            else
                                -- Если додж не удался, очищаем сразу
                                autoDodge.ActiveAnimations[player.Name][animationKey] = nil
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Используем RenderStepped для максимальной скорости
    MainModule.AutoDodge.HeartbeatConnection = RunService.Heartbeat:Connect(instantHeartbeatCheck)
    table.insert(MainModule.AutoDodge.Connections, MainModule.AutoDodge.HeartbeatConnection)
end

-- ============ НАСТРОЙКА ОТСЛЕЖИВАНИЯ ИГРОКОВ ДЛЯ ОЧИСТКИ ============

local function setupPlayerCleanupTracking()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Очистка при смерти
        local function setupCharacter(character)
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Once(function()
                    MainModule.AutoDodge.ActiveAnimations[player.Name] = nil
                    MainModule.AutoDodge.LastAnimationStartTime[player.Name] = nil
                end)
            end
        end
        
        if player.Character then
            setupCharacter(player.Character)
        end
        
        local charConn = player.CharacterAdded:Connect(function(character)
            setupCharacter(character)
        end)
        
        table.insert(MainModule.AutoDodge.Connections, charConn)
    end
    
    -- Отслеживание новых игроков
    local playerAddedConn = Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer then return end
        
        local function setupCharacter(character)
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Once(function()
                    MainModule.AutoDodge.ActiveAnimations[player.Name] = nil
                    MainModule.AutoDodge.LastAnimationStartTime[player.Name] = nil
                end)
            end
        end
        
        local charConn = player.CharacterAdded:Connect(setupCharacter)
        table.insert(MainModule.AutoDodge.Connections, charConn)
    end)
    
    table.insert(MainModule.AutoDodge.Connections, playerAddedConn)
end

-- ============ УПРАВЛЕНИЕ СИСТЕМОЙ ============

function MainModule.ToggleAutoDodge(enabled)
    -- Очистка всех соединений
    if MainModule.AutoDodge.Connections then
        for _, conn in pairs(MainModule.AutoDodge.Connections) do
            if conn then
                pcall(function() conn:Disconnect() end)
            end
        end
    end
    
    -- Сброс всех данных
    MainModule.AutoDodge.Enabled = false
    MainModule.AutoDodge.Connections = {}
    MainModule.AutoDodge.ActiveAnimations = {}
    MainModule.AutoDodge.LastAnimationStartTime = {}
    MainModule.AutoDodge.LastDodgeTime = 0
    MainModule.AutoDodge.HeartbeatConnection = nil
    
    if enabled then
        MainModule.AutoDodge.Enabled = true
        
        -- Инициализация перехвата
        if not MainModule.AutoDodge.Remote then
            setupRemoteHook()
        end
        
        -- Настройка очистки данных игроков
        setupPlayerCleanupTracking()
        
        -- Запуск мгновенной обработки через Heartbeat
        setupHeartbeatProcessing()
        
        MainModule.ShowNotification("Auto Dodge", "Auto Dodge Enabled", 3)
    else
        MainModule.ShowNotification("Auto Dodge", "Auto Dodge Disabled", 3)
    end
end

-- ============ ОБРАБОТКА ВЫХОДА ИГРОКА ============

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        MainModule.ToggleAutoDodge(false)
    else
        -- Очистка данных об игроке
        MainModule.AutoDodge.ActiveAnimations[player.Name] = nil
        MainModule.AutoDodge.LastAnimationStartTime[player.Name] = nil
    end
end)

-- ============ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ============

function MainModule.ShowCapturedCall()
    return MainModule.AutoDodge.CapturedCall
end

function MainModule.ClearCapturedCall()
    MainModule.AutoDodge.CapturedCall = nil
end

function MainModule.ForceDodge()
    return executeDodge()
end

-- ============ ИНИЦИАЛИЗАЦИЯ ============

task.wait(0.4)

-- Автоматическая инициализация
local hookSuccess = setupRemoteHook()

task.spawn(function()
    if MainModule.AutoDodge.Enabled then
        MainModule.ToggleAutoDodge(true)
    end
end)

function MainModule.TeleportToHider()
    task.spawn(function()
        if not IsGameActive("HideAndSeek") then
            MainModule.ShowNotification("HNS", "Game not active", 2)
            return
        end
        local character = GetCharacter()
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            MainModule.ShowNotification("HNS", "Character not found", 2)
            return
        end
        
        local targetPlayer = nil
        local targetRoot = nil
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsHider(player) then
                local hiderChar = player.Character
                if hiderChar and hiderChar:FindFirstChild("HumanoidRootPart") then
                    targetPlayer = player
                    targetRoot = hiderChar.HumanoidRootPart
                    break
                end
            end
        end
        
        if not targetRoot then
            MainModule.ShowNotification("HNS", "No hider found", 2)
            return
        end
        
        local targetPos = targetRoot.Position
        local currentRoot = character:FindFirstChild("HumanoidRootPart")
        
        if currentRoot then
            currentRoot.CFrame = CFrame.new(targetPos.X, targetPos.Y + 3, targetPos.Z)
            MainModule.ShowNotification("HNS", "Teleported to hider", 2)
        end
    end)
end

MainModule.TugOfWar = {
    AntiMissEnabled = false,
    Connection = nil
}

function MainModule.ToggleAntiMiss(enabled)
    if enabled and not IsGameActive("TugOfWar") then
        MainModule.ShowNotification("Anti Miss", "Game not active", 2)
        MainModule.TugOfWar.AntiMissEnabled = false
        return
    end
    
    MainModule.TugOfWar.AntiMissEnabled = enabled
    
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end

    if enabled then
        MainModule.TugOfWar.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.TugOfWar.AntiMissEnabled then 
                if MainModule.TugOfWar.Connection then
                    MainModule.TugOfWar.Connection:Disconnect()
                    MainModule.TugOfWar.Connection = nil
                end
                return 
            end
            
            if not IsGameActive("TugOfWar") then
                MainModule.TugOfWar.AntiMissEnabled = false
                if MainModule.TugOfWar.Connection then
                    MainModule.TugOfWar.Connection:Disconnect()
                    MainModule.TugOfWar.Connection = nil
                end
                MainModule.ShowNotification("Anti Miss", "Game ended - disabled", 2)
                return
            end
            
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
                        
                        local buttons = progress:GetChildren()
                        for _, button in ipairs(buttons) do
                            if button:IsA("TextButton") or button:IsA("ImageButton") then
                                if button.Visible and button.Active then
                                    pcall(function()
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
        MainModule.ShowNotification("Anti Miss", "Enabled", 2)
    else
        MainModule.ShowNotification("Anti Miss", "Disabled", 2)
    end
end

MainModule.GlassBridge = {
    AntiBreakEnabled = false,
    GlassAntiBreakConnection = nil,
    SafetyPlatforms = {}
}

function MainModule.ToggleAntiBreak(enabled)
    if enabled and not IsGameActive("GlassBridge") then
        MainModule.ShowNotification("Anti Break", "Game not active", 2)
        MainModule.GlassBridge.AntiBreakEnabled = false
        return
    end
    
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    
    if MainModule.GlassBridge.GlassAntiBreakConnection then
        MainModule.GlassBridge.GlassAntiBreakConnection:Disconnect()
        MainModule.GlassBridge.GlassAntiBreakConnection = nil
    end
    
    for _, platform in pairs(MainModule.GlassBridge.SafetyPlatforms) do
        if platform then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.SafetyPlatforms = {}
    
    if enabled then
        MainModule.GlassBridge.GlassAntiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreakEnabled then 
                if MainModule.GlassBridge.GlassAntiBreakConnection then
                    MainModule.GlassBridge.GlassAntiBreakConnection:Disconnect()
                    MainModule.GlassBridge.GlassAntiBreakConnection = nil
                end
                return 
            end
            
            if not IsGameActive("GlassBridge") then
                MainModule.GlassBridge.AntiBreakEnabled = false
                if MainModule.GlassBridge.GlassAntiBreakConnection then
                    MainModule.GlassBridge.GlassAntiBreakConnection:Disconnect()
                    MainModule.GlassBridge.GlassAntiBreakConnection = nil
                end
                MainModule.ShowNotification("Anti Break", "Game ended - disabled", 2)
                return
            end
            
            local GlassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
            if not GlassHolder then return end
            
            for _, lane in pairs(GlassHolder:GetChildren()) do
                for _, glassModel in pairs(lane:GetChildren()) do
                    if glassModel:IsA("Model") and glassModel.PrimaryPart then
                        if glassModel.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                            glassModel.PrimaryPart:SetAttribute("exploitingisevil", nil)
                        end
                        
                        if not MainModule.GlassBridge.SafetyPlatforms[glassModel] then
                            local platform = Instance.new("Part")
                            platform.Name = "GlassSafetyPlatform"
                            platform.Size = Vector3.new(20, 1, 20)
                            platform.Position = glassModel.PrimaryPart.Position + Vector3.new(0, -2, 0)
                            platform.Anchored = true
                            platform.CanCollide = true
                            platform.Transparency = 1
                            platform.Color = Color3.fromRGB(255, 255, 255)
                            platform.Material = Enum.Material.Plastic
                            platform.CanQuery = false
                            platform.CastShadow = false
                            
                            platform.Parent = workspace
                            MainModule.GlassBridge.SafetyPlatforms[glassModel] = platform
                        end
                    end
                end
            end
        end)
        MainModule.ShowNotification("Anti Break", "Enabled", 2)
    else
        MainModule.ShowNotification("Anti Break", "Disabled", 2)
    end
end

MainModule.GlassESP = {
    Enabled = false,
    GlassESPConnections = {}
}

local function isRealGlass(part)
    if part:GetAttribute("GlassPart") then
        if part:GetAttribute("ActuallyKilling") ~= nil then
            return false
        end
        return true
    end
    return false
end

local function updateGlassColors()
    if not workspace:FindFirstChild("GlassBridge") then return end
    
    local GlassHolder = workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not GlassHolder then return end
    
    for _, lane in pairs(GlassHolder:GetChildren()) do
        for _, glassModel in pairs(lane:GetChildren()) do
            if glassModel:IsA("Model") then
                for _, part in pairs(glassModel:GetDescendants()) do
                    if part:IsA("BasePart") and part:GetAttribute("GlassPart") then
                        if MainModule.GlassESP.Enabled then
                            if isRealGlass(part) then
                                part.Color = Color3.fromRGB(0, 255, 0)
                            else
                                part.Color = Color3.fromRGB(255, 0, 0)
                            end
                            part.Material = Enum.Material.Neon
                            part:SetAttribute("ExploitingIsEvil", true)
                        else
                            part.Color = Color3.fromRGB(163, 162, 165)
                            part.Material = Enum.Material.Glass
                            part:SetAttribute("ExploitingIsEvil", nil)
                        end
                    end
                end
            end
        end
    end
end

local function clearGlassESP()
    if workspace:FindFirstChild("GlassBridge") then
        local GlassHolder = workspace.GlassBridge:FindFirstChild("GlassHolder")
        if GlassHolder then
            for _, lane in pairs(GlassHolder:GetChildren()) do
                for _, glassModel in pairs(lane:GetChildren()) do
                    if glassModel:IsA("Model") then
                        for _, part in pairs(glassModel:GetDescendants()) do
                            if part:IsA("BasePart") and part:GetAttribute("GlassPart") then
                                part.Color = Color3.fromRGB(163, 162, 165)
                                part.Material = Enum.Material.Glass
                                part:SetAttribute("ExploitingIsEvil", nil)
                            end
                        end
                    end
                end
            end
        end
    end
end

function MainModule.ToggleGlassESP(enabled)
    if enabled and not IsGameActive("GlassBridge") then
        MainModule.ShowNotification("Glass ESP", "Game not active", 2)
        MainModule.GlassESP.Enabled = false
        return
    end
    
    for _, conn in pairs(MainModule.GlassESP.GlassESPConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.GlassESP.GlassESPConnections = {}
    
    MainModule.GlassESP.Enabled = enabled
    
    if enabled then
        updateGlassColors()
        
        local conn1 = workspace.ChildAdded:Connect(function(child)
            if child.Name == "GlassBridge" then
                task.wait(1)
                updateGlassColors()
            end
        end)
        table.insert(MainModule.GlassESP.GlassESPConnections, conn1)
        
        local conn2 = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassESP.Enabled then 
                if conn2 then
                    conn2:Disconnect()
                end
                return 
            end
            
            if not IsGameActive("GlassBridge") then
                MainModule.GlassESP.Enabled = false
                MainModule.ShowNotification("Glass ESP", "Game ended - disabled", 2)
                clearGlassESP()
                return
            end
            
            updateGlassColors()
        end)
        table.insert(MainModule.GlassESP.GlassESPConnections, conn2)
        
        MainModule.ShowNotification("Glass ESP", "Enabled", 2)
    else
        clearGlassESP()
        MainModule.ShowNotification("Glass ESP", "Disabled", 2)
    end
end

function MainModule.GlassBridge_TP_ToEnd()
    task.spawn(function()
        if not IsGameActive("GlassBridge") then
            MainModule.ShowNotification("Glass Bridge", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(-196.372467, 522.192139, -1534.20984)) then
            MainModule.ShowNotification("Glass Bridge", "Teleported to End", 2)
        end
    end)
end

function MainModule.TeleportToJumpRopeStart()
    task.spawn(function()
        if not IsGameActive("JumpRope") then
            MainModule.ShowNotification("Jump Rope", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(615.284424, 192.274277, 920.952515)) then
            MainModule.ShowNotification("Jump Rope", "Teleported to Start", 2)
        end
    end)
end

function MainModule.TeleportToJumpRopeEnd()
    task.spawn(function()
        if not IsGameActive("JumpRope") then
            MainModule.ShowNotification("Jump Rope", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(720.896057, 198.628311, 921.170654)) then
            MainModule.ShowNotification("Jump Rope", "Teleported to End", 2)
        end
    end)
end

function MainModule.DeleteJumpRope()
    task.spawn(function()
        if not IsGameActive("JumpRope") then
            MainModule.ShowNotification("Jump Rope", "Game not active", 2)
            return
        end
        
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
        
        if ropeFound then
            MainModule.ShowNotification("Jump Rope", "Rope deleted", 2)
        else
            MainModule.ShowNotification("Jump Rope", "Rope not found", 2)
        end
    end)
end

MainModule.JumpRope = {
    AntiFallEnabled = false,
    AntiFallPlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000),  -- Увеличена высота для надежности
    PlatformPosition = nil  -- Храним изначальную позицию
}

function MainModule.CreateJumpRopeAntiFall()
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    local character = GetCharacter()
    if not character then 
        MainModule.JumpRope.AntiFallEnabled = false
        return nil 
    end
    
    local rootPart = GetRootPart(character)
    if not rootPart then 
        MainModule.JumpRope.AntiFallEnabled = false
        return nil 
    end
    
    -- Фиксируем позицию платформы на Y -5 от текущей позиции игрока
    local currentPosition = rootPart.Position
    local fixedYPosition = currentPosition.Y - 5
    
    -- Сохраняем позицию для фиксации
    MainModule.JumpRope.PlatformPosition = Vector3.new(
        currentPosition.X,
        fixedYPosition,
        currentPosition.Z
    )
    
    local platform = Instance.new("Part")
    platform.Name = "JumpRopeAntiFall"
    platform.Size = MainModule.JumpRope.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    
    -- ПОЛНОСТЬЮ НЕВИДИМАЯ
    platform.Transparency = 1
    platform.Color = Color3.fromRGB(0, 0, 0)
    platform.Material = Enum.Material.SmoothPlastic
    
    platform.CastShadow = false
    platform.CanQuery = false
    platform.CanTouch = true
    
    -- Лучшие физические свойства для поддержки
    platform.Massless = false  -- false для лучшей физики
    platform.Friction = 1
    platform.Elasticity = 0
    
    -- Фиксируем позицию платформы
    platform.Position = MainModule.JumpRope.PlatformPosition
    
    -- Настраиваем группу коллизий
    pcall(function()
        local collisionGroupName = "AntiFallJumpRope"
        if not PhysicsService:IsCollisionGroupRegistered(collisionGroupName) then
            PhysicsService:RegisterCollisionGroup(collisionGroupName)
        end
        
        PhysicsService:CollisionGroupSetCollidable(collisionGroupName, "Default", false)
        PhysicsService:CollisionGroupSetCollidable(collisionGroupName, collisionGroupName, false)
        PhysicsService:CollisionGroupSetCollidable(collisionGroupName, "Player", true)
        
        platform.CollisionGroup = collisionGroupName
    end)
    
    -- Добавляем гарантию столкновений с игроком
    local function forcePlayerCollision()
        if character and character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local hrp = character.HumanoidRootPart
                PhysicsService:SetPartCollisionGroup(hrp, "Player")
                PhysicsService:CollisionGroupSetCollidable("AntiFallJumpRope", "Player", true)
            end)
        end
    end
    
    platform.Parent = workspace
    MainModule.JumpRope.AntiFallPlatform = platform
    MainModule.JumpRope.AntiFallEnabled = true
    
    -- Применяем настройки коллизий
    spawn(forcePlayerCollision)
    
    -- Добавляем BodyVelocity для стабильности
    local velocity = Instance.new("BodyVelocity")
    velocity.Velocity = Vector3.new(0, 0, 0)
    velocity.MaxForce = Vector3.new(0, 100000, 0)  -- Только поддержка по Y
    velocity.P = 10000
    velocity.Parent = platform
    
    return platform
end

function MainModule.RemoveJumpRopeAntiFall()
    if MainModule.JumpRope.Connection then
        MainModule.JumpRope.Connection:Disconnect()
        MainModule.JumpRope.Connection = nil
    end
    
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    MainModule.JumpRope.PlatformPosition = nil
    MainModule.JumpRope.AntiFallEnabled = false
    return true
end

function MainModule.ToggleJumpRopeAntiFall(enabled)
    if enabled and not IsGameActive("JumpRope") then
        MainModule.ShowNotification("Jump Rope AntiFall", "Game not active", 2)
        MainModule.RemoveJumpRopeAntiFall()
        return
    end
    
    if enabled then
        -- Создаем фиксированную платформу один раз
        local platform = MainModule.CreateJumpRopeAntiFall()
        if not platform then
            MainModule.ShowNotification("Jump Rope AntiFall", "Failed to create platform", 2)
            return
        end
        
        MainModule.ShowNotification("Jump Rope AntiFall", "Enabled", 3)
        
        -- НЕ создаем постоянное обновление позиции - платформа фиксирована
        if MainModule.JumpRope.Connection then
            MainModule.JumpRope.Connection:Disconnect()
        end
        
        -- Только мониторинг состояния
        MainModule.JumpRope.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFallEnabled then 
                MainModule.RemoveJumpRopeAntiFall()
                return 
            end
            
            -- Проверяем активность игры
            if not IsGameActive("JumpRope") then
                MainModule.RemoveJumpRopeAntiFall()
                MainModule.ShowNotification("Jump Rope AntiFall", "Game ended - disabled", 2)
                return
            end
            
            -- Проверяем что платформа существует
            if not (MainModule.JumpRope.AntiFallPlatform and 
                   MainModule.JumpRope.AntiFallPlatform.Parent) then
                -- Если платформа пропала, пересоздаем на той же позиции
                if MainModule.JumpRope.PlatformPosition then
                    local newPlatform = Instance.new("Part")
                    newPlatform.Name = "JumpRopeAntiFall"
                    newPlatform.Size = MainModule.JumpRope.PlatformSize
                    newPlatform.Anchored = true
                    newPlatform.CanCollide = true
                    newPlatform.Transparency = 1
                    newPlatform.Position = MainModule.JumpRope.PlatformPosition
                    newPlatform.Parent = workspace
                    MainModule.JumpRope.AntiFallPlatform = newPlatform
                else
                    MainModule.CreateJumpRopeAntiFall()
                end
            end
        end)
        
    else
        MainModule.RemoveJumpRopeAntiFall()
        MainModule.ShowNotification("Jump Rope AntiFall", "Disabled", 2)
    end
end

MainModule.MingleVoidKill = {
    Enabled = false,
    AnimationId = "rbxassetid://71318091779666",
    OriginalPosition = nil,
    OriginalCFrame = nil,
    Platform = nil,
    AnimationTrack = nil,
    Connections = {},
    PlatformHeight = -30,
    PlatformTeleportYOffset = 3,
    PlatformSize = Vector3.new(100, 10, 100),
    PlatformColor = Color3.fromRGB(0, 170, 255),
    IsOnPlatform = false,
    AnimationStartTime = 0
}

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
    
    MainModule.MingleVoidKill.OriginalPosition = originalPosition
    MainModule.MingleVoidKill.OriginalCFrame = CFrame.new(originalPosition)
    
    local platform = createSafetyPlatformMingleVoidKill(originalPosition)
    
    local teleportPosition = Vector3.new(
        platform.Position.X,
        platform.Position.Y + MainModule.MingleVoidKill.PlatformTeleportYOffset,
        platform.Position.Z
    )
    
    humanoidRootPart.CFrame = CFrame.new(teleportPosition)
    MainModule.MingleVoidKill.IsOnPlatform = true
    MainModule.MingleVoidKill.AnimationStartTime = tick()
    
    return true
end

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
        local returnPosition = Vector3.new(
            MainModule.MingleVoidKill.OriginalPosition.X,
            MainModule.MingleVoidKill.OriginalPosition.Y,
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
                local currentPosition = nil
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    currentPosition = humanoidRootPart.Position
                else
                    currentPosition = character:GetPivot().Position
                end
                
                teleportToPlatformMingleVoidKill(currentPosition)
                MainModule.MingleVoidKill.AnimationTrack = track
                
                local connection
                connection = game:GetService("RunService").Heartbeat:Connect(function()
                    if not track or not track.IsPlaying then
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
    
    local heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not MainModule.MingleVoidKill.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                if animId == MainModule.MingleVoidKill.AnimationId then
                    
                    if not MainModule.MingleVoidKill.IsOnPlatform then
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
        
        if MainModule.MingleVoidKill.AnimationTrack and MainModule.MingleVoidKill.IsOnPlatform then
            local shouldReturn = false
            
            if MainModule.MingleVoidKill.AnimationTrack then
                if not MainModule.MingleVoidKill.AnimationTrack.IsPlaying then
                    shouldReturn = true
                end
            else
                if tick() - MainModule.MingleVoidKill.AnimationStartTime > 10 then
                    shouldReturn = true
                end
            end
            
            if shouldReturn then
                returnToOriginalPositionMingleVoidKill()
            end
        end
        
        if MainModule.MingleVoidKill.IsOnPlatform and tick() - MainModule.MingleVoidKill.AnimationStartTime > 15 then
            returnToOriginalPositionMingleVoidKill()
        end
    end)
    
    table.insert(MainModule.MingleVoidKill.Connections, heartbeatConnection)
end

function MainModule.ToggleMingleVoidKill(enabled)
    if enabled and not IsGameActive("Mingle") then
        MainModule.ShowNotification("Void Kill", "Game not active", 2)
        MainModule.MingleVoidKill.Enabled = false
        return
    end
    
    MainModule.MingleVoidKill.Enabled = false
    
    for _, conn in pairs(MainModule.MingleVoidKill.Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.MingleVoidKill.Connections = {}
    
    if MainModule.MingleVoidKill.Platform then
        MainModule.MingleVoidKill.Platform:Destroy()
        MainModule.MingleVoidKill.Platform = nil
    end
    
    MainModule.MingleVoidKill.OriginalPosition = nil
    MainModule.MingleVoidKill.OriginalCFrame = nil
    MainModule.MingleVoidKill.AnimationTrack = nil
    MainModule.MingleVoidKill.IsOnPlatform = false
    MainModule.MingleVoidKill.AnimationStartTime = 0
    
    if enabled then
        MainModule.MingleVoidKill.Enabled = true
        setupAnimationTrackerMingleVoidKill()
        
        local checkConnection = RunService.Heartbeat:Connect(function()
            if MainModule.MingleVoidKill.Enabled and not IsGameActive("Mingle") then
                MainModule.MingleVoidKill.Enabled = false
                MainModule.ShowNotification("Void Kill", "Game ended - disabled", 2)
                checkConnection:Disconnect()
            end
        end)
        table.insert(MainModule.MingleVoidKill.Connections, checkConnection)
        
        MainModule.ShowNotification("Void Kill", "Enabled", 2)
    else
        MainModule.ShowNotification("Void Kill", "Disabled", 2)
    end
end

MainModule.Rebel = {
    Enabled = false,
    Connection = nil,
    LastCheckTime = 0,
    LastKillTime = 0,
    CheckCooldown = 0.1,
    KillCooldown = 0.05
}

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
            
            -- Получаем список врагов
            local enemyNames = {}
            if workspace:FindFirstChild("Live") then
                for _, enemy in pairs(workspace.Live:GetChildren()) do
                    if enemy:IsA("Model") and enemy:FindFirstChild("Enemy") and not enemy:FindFirstChild("Dead") then
                        local isPlayer = false
                        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                            if player.Name == enemy.Name then
                                isPlayer = true
                                break
                            end
                        end
                        if not isPlayer then
                            table.insert(enemyNames, enemy.Name)
                        end
                    end
                end
            end
            
            if #enemyNames == 0 then return end
            
            for _, enemyName in pairs(enemyNames) do
                if currentTime - MainModule.Rebel.LastKillTime < MainModule.Rebel.KillCooldown then
                    task.wait(MainModule.Rebel.KillCooldown - (currentTime - MainModule.Rebel.LastKillTime))
                end
                
                -- Получаем текущее оружие игрока
                local character = game:GetService("Players").LocalPlayer.Character
                local backpack = game:GetService("Players").LocalPlayer.Backpack
                local gun = nil
                
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                            gun = tool
                            break
                        end
                    end
                end
                
                if not gun and backpack then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                            gun = tool
                            break
                        end
                    end
                end
                
                if gun then
                    -- Создаем данные для выстрела
                    local args = {
                        gun,
                        {
                            ClientRayNormal = Vector3.new(-1.1920928955078125e-7, 1.0000001192092896, 0),
                            FiredGun = true,
                            SecondaryHitTargets = {},
                            ClientRayInstance = workspace:WaitForChild("StairWalkWay"):WaitForChild("Part"),
                            ClientRayPosition = Vector3.new(-220.17489624023438, 183.2957763671875, 301.07257080078125),
                            bulletCF = CFrame.new(-220.5039825439453, 185.22506713867188, 302.133544921875, 0.9551116228103638, 0.2567310333251953, -0.14782091975212097, 7.450581485102248e-9, 0.4989798665046692, 0.8666135668754578, 0.2962462604045868, -0.8277127146720886, 0.4765814542770386),
                            HitTargets = {
                                [enemyName] = "Head"
                            },
                            bulletSizeC = Vector3.new(0.009999999776482582, 0.009999999776482582, 4.452499866485596),
                            NoMuzzleFX = false,
                            FirePosition = Vector3.new(-72.88850402832031, -679.4803466796875, -173.31005859375)
                        }
                    }
                    
                    -- Отправляем выстрел
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(unpack(args))
                    end)
                    
                    MainModule.Rebel.LastKillTime = tick()
                    task.wait(0.05)
                end
            end
        end)
        MainModule.ShowNotification("Rebel", "Instant Rebel Enabled", 2)
    else
        MainModule.Rebel.LastKillTime = 0
        MainModule.Rebel.LastCheckTime = 0
        MainModule.ShowNotification("Rebel", "Instant Rebel Disabled", 2)
    end
end

MainModule.ZoneKillFeature = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164",
    ZonePosition = Vector3.new(197.7, 54.6, -96.3),
    ReturnDelay = 0.6,
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
    
    for _, conn in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
    
    MainModule.ZoneKillFeature.SavedCFrame = nil
    MainModule.ZoneKillFeature.ActiveAnimation = false
    MainModule.ZoneKillFeature.AnimationStartTime = 0
    MainModule.ZoneKillFeature.TrackedAnimations = {}
    
    if not enabled then
        return
    end
    
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
                            
                            local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
                            if primaryPart then
                                MainModule.ZoneKillFeature.SavedCFrame = primaryPart.CFrame
                                character:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                            end
                            
                            local stoppedConn = track.Stopped:Connect(function()
                                task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                                
                                if MainModule.ZoneKillFeature.SavedCFrame then
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
                        
                        local primaryPart = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
                        if primaryPart then
                            MainModule.ZoneKillFeature.SavedCFrame = primaryPart.CFrame
                            char:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                        end
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                            
                            if MainModule.ZoneKillFeature.SavedCFrame then
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
    
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    MainModule.ZoneKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        setupCharacter(newChar)
    end)
    
    MainModule.ZoneKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.ZoneKillFeature.Enabled then return end
        checkAnimations()
    end)
    
    MainModule.ShowNotification("Last Dinner", "Zone Kill Enabled", 2)
end

MainModule.SkySquidGame = {
    AntiFallEnabled = false,
    AntiFallPlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000),
    PlatformPosition = nil
}

function MainModule.CreateSkySquidGameAntiFall()
    -- Удаляем старую платформу
    if MainModule.SkySquidGame.AntiFallPlatform and MainModule.SkySquidGame.AntiFallPlatform.Parent then
        MainModule.SkySquidGame.AntiFallPlatform:Destroy()
        MainModule.SkySquidGame.AntiFallPlatform = nil
    end
    
    local character = GetCharacter()
    if not character then 
        MainModule.SkySquidGame.AntiFallEnabled = false
        return nil 
    end
    
    local rootPart = GetRootPart(character)
    if not rootPart then 
        MainModule.SkySquidGame.AntiFallEnabled = false
        return nil 
    end
    
    -- Фиксируем позицию платформы на Y -5 от текущей позиции игрока
    local currentPosition = rootPart.Position
    local fixedYPosition = currentPosition.Y - 5
    
    -- Сохраняем позицию для фиксации
    MainModule.SkySquidGame.PlatformPosition = Vector3.new(
        currentPosition.X,
        fixedYPosition,
        currentPosition.Z
    )
    
    -- Создаем платформу с особыми свойствами
    local platform = Instance.new("Part")
    platform.Name = "SkySquidGameAntiFall"
    platform.Size = MainModule.SkySquidGame.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    
    -- ПОЛНОСТЬЮ НЕВИДИМАЯ
    platform.Transparency = 1
    platform.Color = Color3.fromRGB(0, 0, 0)
    platform.Material = Enum.Material.SmoothPlastic
    
    -- Ключевые настройки для предотвращения конфликтов:
    platform.CastShadow = false
    platform.CanQuery = false
    platform.CanTouch = true
    platform.CollisionGroupId = 0  -- Основная группа коллизий
    
    -- Устанавливаем особые физические свойства для надежной поддержки
    platform.Massless = false  -- Лучше false для стабильной физики
    platform.Friction = 1
    platform.Elasticity = 0
    
    -- Фиксируем позицию платформы (не двигается за игроком)
    platform.Position = MainModule.SkySquidGame.PlatformPosition
    
    -- Отключаем все возможные взаимодействия, кроме коллизий
    if platform:IsA("BasePart") then
        pcall(function()
            platform:SetNetworkOwner(nil)
        end)
    end
    
    -- Создаем специальную группу коллизий
    local collisionGroupName = "AntiFallSkySquid"
    
    pcall(function()
        -- Регистрируем группу коллизий
        if not PhysicsService:IsCollisionGroupRegistered(collisionGroupName) then
            PhysicsService:RegisterCollisionGroup(collisionGroupName)
        end
        
        -- Настраиваем коллизии: платформа сталкивается только с игроком
        PhysicsService:CollisionGroupSetCollidable(collisionGroupName, "Default", false)
        PhysicsService:CollisionGroupSetCollidable(collisionGroupName, collisionGroupName, false)
        PhysicsService:CollisionGroupSetCollidable(collisionGroupName, "Player", true)
        
        platform.CollisionGroup = collisionGroupName
    end)
    
    -- Добавляем дополнительную гарантию столкновений
    local function forcePlayerCollision()
        if character and character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local hrp = character.HumanoidRootPart
                PhysicsService:SetPartCollisionGroup(hrp, "Player")
                PhysicsService:CollisionGroupSetCollidable("AntiFallSkySquid", "Player", true)
            end)
        end
    end
    
    platform.Parent = workspace
    MainModule.SkySquidGame.AntiFallPlatform = platform
    MainModule.SkySquidGame.AntiFallEnabled = true
    
    -- Применяем настройки коллизий
    spawn(forcePlayerCollision)
    
    -- Создаем альтернативный метод поддержки через BodyVelocity если нужно
    local velocity = Instance.new("BodyVelocity")
    velocity.Velocity = Vector3.new(0, 0, 0)
    velocity.MaxForce = Vector3.new(0, 100000, 0)  -- Только по Y для поддержки
    velocity.P = 10000
    velocity.Parent = platform
    
    return platform
end

function MainModule.RemoveSkySquidGameAntiFall()
    if MainModule.SkySquidGame.Connection then
        MainModule.SkySquidGame.Connection:Disconnect()
        MainModule.SkySquidGame.Connection = nil
    end
    
    if MainModule.SkySquidGame.AntiFallPlatform and MainModule.SkySquidGame.AntiFallPlatform.Parent then
        MainModule.SkySquidGame.AntiFallPlatform:Destroy()
        MainModule.SkySquidGame.AntiFallPlatform = nil
    end
    
    MainModule.SkySquidGame.PlatformPosition = nil
    MainModule.SkySquidGame.AntiFallEnabled = false
    return true
end

function MainModule.ToggleSkySquidGameAntiFall(enabled)
    if enabled and not IsGameActive("SkySquidGame") then
        MainModule.ShowNotification("Sky Squid Game AntiFall", "Game not active", 2)
        MainModule.RemoveSkySquidGameAntiFall()
        return
    end
    
    if enabled then
        -- Создаем фиксированную платформу один раз
        local platform = MainModule.CreateSkySquidGameAntiFall()
        if not platform then
            MainModule.ShowNotification("Sky Squid Game AntiFall", "Failed to create platform", 2)
            return
        end
        
        MainModule.ShowNotification("Sky Squid Game AntiFall", "Enabled - Fixed invisible platform at Y-5", 3)
        
        -- НЕ создаем постоянное обновление позиции - платформа фиксирована
        -- Только проверяем, что игра еще активна
        if MainModule.SkySquidGame.Connection then
            MainModule.SkySquidGame.Connection:Disconnect()
        end
        
        MainModule.SkySquidGame.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquidGame.AntiFallEnabled then 
                MainModule.RemoveSkySquidGameAntiFall()
                return 
            end
            
            -- Проверяем активность игры
            if not IsGameActive("SkySquidGame") then
                MainModule.RemoveSkySquidGameAntiFall()
                MainModule.ShowNotification("Sky Squid Game AntiFall", "Game ended - disabled", 2)
                return
            end
            
            -- Платформа не двигается, просто проверяем что она существует
            if not (MainModule.SkySquidGame.AntiFallPlatform and 
                   MainModule.SkySquidGame.AntiFallPlatform.Parent) then
                -- Если платформа пропала, пересоздаем на той же позиции
                if MainModule.SkySquidGame.PlatformPosition then
                    local newPlatform = Instance.new("Part")
                    newPlatform.Name = "SkySquidGameAntiFall"
                    newPlatform.Size = MainModule.SkySquidGame.PlatformSize
                    newPlatform.Anchored = true
                    newPlatform.CanCollide = true
                    newPlatform.Transparency = 1
                    newPlatform.Position = MainModule.SkySquidGame.PlatformPosition
                    newPlatform.Parent = workspace
                    MainModule.SkySquidGame.AntiFallPlatform = newPlatform
                else
                    MainModule.CreateSkySquidGameAntiFall()
                end
            end
        end)
        
    else
        MainModule.RemoveSkySquidGameAntiFall()
        MainModule.ShowNotification("Sky Squid Game AntiFall", "Disabled", 2)
    end
end

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

for _, id in ipairs(MainModule.VoidKillFeature.AnimationIds) do
    MainModule.VoidKillFeature.AnimationIdsSet[id] = true
end

function MainModule.ToggleVoidKill(enabled)
    if enabled and not IsGameActive("SkySquidGame") then
        MainModule.ShowNotification("Void Kill", "Game not active", 2)
        MainModule.VoidKillFeature.Enabled = false
        return
    end
    
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
        MainModule.ShowNotification("Void Kill", "Disabled", 2)
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
        
        if not IsGameActive("SkySquidGame") then
            MainModule.VoidKillFeature.Enabled = false
            MainModule.ShowNotification("Void Kill", "Game ended - disabled", 2)
            return
        end
        
        checkAnimations()
    end)
    
    MainModule.ShowNotification("Void Kill", "Enabled", 2)
end

return MainModule
