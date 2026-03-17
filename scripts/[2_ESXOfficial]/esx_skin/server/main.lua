RegisterNetEvent('esx_skin:save')
AddEventHandler('esx_skin:save', function(skin)
    local src = source
    local identifier = nil

    for _, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(v, 'license:') then
            identifier = v
            break
        end
    end

    if not identifier then return end

    MySQL.Async.fetchAll('SELECT * FROM skin WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if #result == 0 then
            MySQL.Async.execute('INSERT INTO skin (identifier, skin) VALUES (@identifier, @skin)', {
                ['@identifier'] = identifier,
                ['@skin'] = json.encode(skin),
            })
        else
            MySQL.Async.execute('UPDATE skin SET skin = @skin WHERE identifier = @identifier', {
                ['@skin'] = json.encode(skin),
                ['@identifier'] = identifier,
            })
        end
    end)
end)

RegisterNetEvent('esx_skin:requestSkin')
AddEventHandler('esx_skin:requestSkin', function()
    local src = source
    local identifier = nil

    for _, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(v, 'license:') then
            identifier = v
            break
        end
    end

    if not identifier then return end

    MySQL.Async.fetchAll('SELECT skin FROM skin WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] then
            TriggerClientEvent('esx_skin:loadSkin', src, json.decode(result[1].skin))
        else
            TriggerClientEvent('esx_skin:loadDefaultSkin', src)
        end
    end)
end)
