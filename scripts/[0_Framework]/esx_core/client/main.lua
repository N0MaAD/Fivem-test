local isPlayerLoaded = false
local playerData = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(data)
    playerData = data
    isPlayerLoaded = true

    local spawn = data.coords
    exports.spawnmanager:spawnPlayer({
        x = spawn.x or spawn[1] or -269.4,
        y = spawn.y or spawn[2] or -955.3,
        z = spawn.z or spawn[3] or 31.2,
        heading = spawn.w or spawn[4] or 205.0,
        model = GetHashKey('mp_m_freemode_01'),
        skipFade = false,
    }, function()
        TriggerServerEvent('esx:onPlayerSpawned')
        TriggerEvent('esx:onPlayerSpawned')
    end)
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent('esx:onPlayerJoined')
    end
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(accounts)
    playerData.accounts = accounts
end)

-- Disable wanted level
if not Config.EnableWantedLevel then
    CreateThread(function()
        while true do
            Wait(0)
            ClearPlayerWantedLevel(PlayerId())
            SetMaxWantedLevel(0)
        end
    end)
end

-- Enable PvP
if Config.EnablePvP then
    CreateThread(function()
        while true do
            Wait(0)
            SetCanAttackFriendly(PlayerPedId(), true, false)
            NetworkSetFriendlyFireOption(true)
        end
    end)
end

-- Exports client
exports('GetPlayerData', function()
    return playerData
end)

exports('IsPlayerLoaded', function()
    return isPlayerLoaded
end)
