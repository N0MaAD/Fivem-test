-- Fonctions serveur utilitaires ESX

function ESX.GetIdentifier(src)
    for _, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(v, 'license:') then
            return v
        end
    end
    return nil
end

function ESX.SavePlayer(src)
    local ESXObj = exports['esx_core']:getSharedObject()
    local player = ESXObj.GetPlayerFromId(src)
    if player then
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        MySQL.Async.execute('UPDATE users SET accounts = @accounts, position = @position WHERE identifier = @identifier', {
            ['@accounts'] = json.encode(player.accounts),
            ['@position'] = json.encode({ x = coords.x, y = coords.y, z = coords.z }),
            ['@identifier'] = player.identifier,
        })
    end
end

function ESX.SavePlayers()
    local ESXObj = exports['esx_core']:getSharedObject()
    for src, _ in pairs(ESXObj.GetPlayers()) do
        ESX.SavePlayer(src)
    end
    print('[^2ESX^7] Tous les joueurs sauvegardés.')
end

-- Sauvegarde automatique toutes les 5 minutes
CreateThread(function()
    while true do
        Wait(300000)
        ESX.SavePlayers()
    end
end)
