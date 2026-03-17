local Players = {}

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    deferrals.update(('Bienvenue %s, chargement en cours...'):format(name))
    Wait(500)
    deferrals.done()
end)

RegisterNetEvent('esx:onPlayerJoined')
AddEventHandler('esx:onPlayerJoined', function()
    local src = source
    if Players[src] then return end

    local identifier = nil
    for _, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(v, 'license:') then
            identifier = v
            break
        end
    end

    if not identifier then
        DropPlayer(src, 'Identifiant introuvable.')
        return
    end

    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if #result == 0 then
            MySQL.Async.execute('INSERT INTO users (identifier, accounts, group_name) VALUES (@identifier, @accounts, @group)', {
                ['@identifier'] = identifier,
                ['@accounts'] = json.encode(Config.StartingAccountMoney),
                ['@group'] = 'user',
            })
            loadPlayer(src, identifier, nil)
        else
            loadPlayer(src, identifier, result[1])
        end
    end)
end)

function loadPlayer(src, identifier, data)
    local playerData = {
        source     = src,
        identifier = identifier,
        group      = data and data.group_name or 'user',
        accounts   = data and json.decode(data.accounts) or Config.StartingAccountMoney,
        coords     = data and data.position and json.decode(data.position) or Config.DefaultSpawnCoords,
        name       = GetPlayerName(src),
    }

    Players[src] = playerData

    TriggerClientEvent('esx:playerLoaded', src, playerData)
    TriggerEvent('esx:playerLoaded', src, playerData)

    print(('[^2ESX^7] %s (ID: %s) connecté.'):format(playerData.name, src))
end

AddEventHandler('playerDropped', function(reason)
    local src = source
    local player = Players[src]

    if player then
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        MySQL.Async.execute('UPDATE users SET accounts = @accounts, position = @position WHERE identifier = @identifier', {
            ['@accounts'] = json.encode(player.accounts),
            ['@position'] = json.encode({ x = coords.x, y = coords.y, z = coords.z }),
            ['@identifier'] = player.identifier,
        })
        print(('[^2ESX^7] %s (ID: %s) déconnecté. (%s)'):format(player.name, src, reason))
        Players[src] = nil
    end
end)

-- Exports
local obj = {}

function obj.GetPlayerFromId(src)
    return Players[src]
end

function obj.GetPlayers()
    return Players
end

function obj.GetConfig()
    return Config
end

function obj.AddMoney(src, amount)
    if Players[src] then
        Players[src].accounts.money = (Players[src].accounts.money or 0) + amount
        TriggerClientEvent('esx:setAccountMoney', src, Players[src].accounts)
    end
end

function obj.RemoveMoney(src, amount)
    if Players[src] then
        Players[src].accounts.money = math.max(0, (Players[src].accounts.money or 0) - amount)
        TriggerClientEvent('esx:setAccountMoney', src, Players[src].accounts)
    end
end

exports('getSharedObject', function()
    return obj
end)
