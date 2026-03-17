local ESXObj = nil

AddEventHandler('esx:playerLoaded', function(src, playerData)
    if not ESXObj then
        ESXObj = exports['esx_core']:getSharedObject()
    end

    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
        ['@identifier'] = playerData.identifier
    }, function(result)
        if result[1] and result[1].firstname then
            TriggerClientEvent('esx_identity:alreadyRegistered', src)
        else
            TriggerClientEvent('esx_identity:showRegisterForm', src)
        end
    end)
end)

RegisterNetEvent('esx_identity:registerIdentity')
AddEventHandler('esx_identity:registerIdentity', function(data)
    local src = source
    local identifier = nil

    for _, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(v, 'license:') then
            identifier = v
            break
        end
    end

    if not identifier then return end

    MySQL.Async.execute('UPDATE users SET firstname = @firstname, lastname = @lastname, dateofbirth = @dob, sex = @sex WHERE identifier = @identifier', {
        ['@firstname']  = data.firstname,
        ['@lastname']   = data.lastname,
        ['@dob']        = data.dateofbirth,
        ['@sex']        = data.sex,
        ['@identifier'] = identifier,
    })

    print(('[^2ESX Identity^7] %s %s enregistré (ID: %s)'):format(data.firstname, data.lastname, src))
end)
