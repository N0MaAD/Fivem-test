local isFishing = false
local isInSpot = false
local isAtSeller = false
local currentSpotIndex = nil
local playerData = { xp = 0, level = 1 }
local fishInventory = {}
local spawnedPeds = {}

-- ========== INIT ==========

AddEventHandler('esx:onPlayerSpawned', function()
    TriggerServerEvent('esx_fishing:requestData')
    setupBlips()
    setupSellPeds()
end)

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() == res then
        TriggerServerEvent('esx_fishing:requestData')
        setupBlips()
        setupSellPeds()
    end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        for _, ped in ipairs(spawnedPeds) do
            if DoesEntityExist(ped) then DeleteEntity(ped) end
        end
    end
end)

-- ========== BLIPS ==========

function setupBlips()
    if Config.ShowBlips then
        for _, spot in ipairs(Config.FishingSpots) do
            local blip = AddBlipForCoord(spot.coords.x, spot.coords.y, spot.coords.z)
            SetBlipSprite(blip, Config.BlipSprite)
            SetBlipColour(blip, Config.BlipColor)
            SetBlipScale(blip, Config.BlipScale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.BlipName)
            EndTextCommandSetBlipName(blip)
        end

        for _, seller in ipairs(Config.SellLocations) do
            local blip = AddBlipForCoord(seller.coords.x, seller.coords.y, seller.coords.z)
            SetBlipSprite(blip, Config.SellBlipSprite)
            SetBlipColour(blip, Config.SellBlipColor)
            SetBlipScale(blip, Config.SellBlipScale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.SellBlipName)
            EndTextCommandSetBlipName(blip)
        end
    end
end

-- ========== PNJ VENDEUR ==========

function setupSellPeds()
    for _, seller in ipairs(Config.SellLocations) do
        local model = GetHashKey(seller.ped)
        RequestModel(model)

        local timeout = 0
        while not HasModelLoaded(model) and timeout < 50 do
            Wait(100)
            timeout = timeout + 1
        end

        if HasModelLoaded(model) then
            local ped = CreatePed(4, model, seller.coords.x, seller.coords.y, seller.coords.z - 1.0, seller.heading, false, true)
            SetEntityAsMissionEntity(ped, true, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
            table.insert(spawnedPeds, ped)
        end
    end
end

-- ========== EVENTS SERVEUR ==========

RegisterNetEvent('esx_fishing:loadData')
AddEventHandler('esx_fishing:loadData', function(data)
    playerData = data
end)

RegisterNetEvent('esx_fishing:loadInventory')
AddEventHandler('esx_fishing:loadInventory', function(inv)
    fishInventory = inv or {}
end)

RegisterNetEvent('esx_fishing:xpGained')
AddEventHandler('esx_fishing:xpGained', function(xpGained, totalXp, level)
    playerData.xp = totalXp
    playerData.level = level
    exports['esx_notify']:ShowNotification(Config.Lang.xp_gained:format(xpGained), 'info', 3000)
end)

RegisterNetEvent('esx_fishing:levelUp')
AddEventHandler('esx_fishing:levelUp', function(level)
    playerData.level = level
    exports['esx_notify']:ShowNotification(Config.Lang.level_up:format(level), 'success', 5000)
end)

RegisterNetEvent('esx_fishing:rodCheck')
AddEventHandler('esx_fishing:rodCheck', function(hasRod)
    if hasRod then
        startFishing()
    else
        exports['esx_notify']:ShowNotification(Config.Lang.no_rod, 'error', 3000)
    end
end)

RegisterNetEvent('esx_fishing:sellResult')
AddEventHandler('esx_fishing:sellResult', function(success, amount, fishLabel, fishCount)
    if success then
        if fishLabel then
            exports['esx_notify']:ShowNotification(Config.Lang.sold_fish:format(fishCount, fishLabel, amount), 'success', 4000)
        else
            exports['esx_notify']:ShowNotification(Config.Lang.sold_all:format(amount), 'success', 4000)
        end
        fishInventory = {}
        TriggerServerEvent('esx_fishing:requestData')
    else
        exports['esx_notify']:ShowNotification(Config.Lang.no_fish, 'error', 3000)
    end
end)

-- ========== BOUCLE PRINCIPALE ==========

CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        isInSpot = false
        currentSpotIndex = nil
        isAtSeller = false

        -- Check spots de pêche
        for i, spot in ipairs(Config.FishingSpots) do
            local dist = #(playerCoords - spot.coords)
            if dist < spot.radius then
                isInSpot = true
                currentSpotIndex = i
                sleep = 0

                if not isFishing then
                    drawHelpText(Config.Lang.press_to_fish)

                    if IsControlJustPressed(0, Config.Key) then
                        TriggerServerEvent('esx_fishing:checkRod')
                    end
                end
                break
            end
        end

        -- Check vendeurs
        if not isInSpot then
            for _, seller in ipairs(Config.SellLocations) do
                local dist = #(playerCoords - seller.coords)
                if dist < 3.0 then
                    isAtSeller = true
                    sleep = 0

                    drawHelpText(Config.Lang.press_to_sell)

                    if IsControlJustPressed(0, Config.Key) then
                        openSellMenu()
                    end
                    break
                end
            end
        end

        Wait(sleep)
    end
end)

-- ========== PÊCHE ==========

function startFishing()
    if isFishing then return end
    isFishing = true

    local ped = PlayerPedId()

    -- Animation de lancer
    RequestAnimDict('amb@world_human_stand_fishing@idle_a')
    while not HasAnimDictLoaded('amb@world_human_stand_fishing@idle_a') do Wait(10) end
    TaskPlayAnim(ped, 'amb@world_human_stand_fishing@idle_a', 'idle_a', 8.0, -8.0, -1, 1, 0.0, false, false, false)

    exports['esx_notify']:ShowNotification(Config.Lang.fishing_start, 'info', 3000)

    -- Attente aléatoire
    local waitTime = math.random(Config.FishingTime.min, Config.FishingTime.max)
    Wait(waitTime)

    if not isFishing then return end

    -- 15% de chance de rien attraper
    if math.random(1, 100) <= 15 then
        exports['esx_notify']:ShowNotification(Config.Lang.fishing_nothing, 'warning', 3000)
        stopFishing()
        return
    end

    exports['esx_notify']:ShowNotification(Config.Lang.fishing_bite, 'warning', 2000)

    -- Lancer le minijeu NUI
    SendNUIMessage({
        action   = 'startMinigame',
        duration = Config.MinigameDuration,
        zoneSize = Config.MinigameZoneSize + getLevelBonus(),
    })
    SetNuiFocus(true, false)
end

function stopFishing()
    isFishing = false
    local ped = PlayerPedId()
    ClearPedTasks(ped)
end

function getLevelBonus()
    if not Config.EnableLevels then return 0 end
    for i = #Config.Levels, 1, -1 do
        if playerData.level >= Config.Levels[i].level then
            return Config.Levels[i].bonusChance
        end
    end
    return 0
end

-- ========== SÉLECTION DU POISSON ==========

function getRandomFish()
    local totalChance = 0
    for _, fish in ipairs(Config.Fish) do
        totalChance = totalChance + fish.chance
    end

    local roll = math.random(1, totalChance)
    local current = 0

    for _, fish in ipairs(Config.Fish) do
        current = current + fish.chance
        if roll <= current then
            return fish
        end
    end

    return Config.Fish[1]
end

-- ========== NUI CALLBACKS ==========

RegisterNUICallback('minigameResult', function(data, cb)
    SetNuiFocus(false, false)

    if data.success then
        local fish = getRandomFish()
        exports['esx_notify']:ShowNotification(Config.Lang.fishing_success:format(fish.label), 'success', 4000)
        TriggerServerEvent('esx_fishing:catchFish', fish.name)

        fishInventory[fish.name] = (fishInventory[fish.name] or 0) + 1
    else
        exports['esx_notify']:ShowNotification(Config.Lang.fishing_fail, 'error', 3000)
    end

    stopFishing()
    cb('ok')
end)

RegisterNUICallback('closeSellMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sellFish', function(data, cb)
    TriggerServerEvent('esx_fishing:sellFish', data.fishName)
    cb('ok')
end)

RegisterNUICallback('sellAll', function(_, cb)
    TriggerServerEvent('esx_fishing:sellAll')
    SetNuiFocus(false, false)
    cb('ok')
end)

-- ========== MENU VENTE ==========

function openSellMenu()
    -- Construire la liste des poissons avec prix
    local sellList = {}
    for _, fish in ipairs(Config.Fish) do
        local amount = fishInventory[fish.name] or 0
        if amount > 0 then
            table.insert(sellList, {
                name   = fish.name,
                label  = fish.label,
                amount = amount,
                price  = fish.price,
                total  = fish.price * amount,
            })
        end
    end

    SendNUIMessage({
        action   = 'openSellMenu',
        fish     = sellList,
        level    = playerData.level,
        xp       = playerData.xp,
    })
    SetNuiFocus(true, true)
end

-- ========== UTILS ==========

function drawHelpText(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end
