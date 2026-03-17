RegisterCommand('setgroup', function(source, args)
    if source == 0 or IsPlayerAdmin(source) then
        local target = tonumber(args[1])
        local group = args[2]
        if not target or not group then
            print('[ESX] Usage: /setgroup [id] [group]')
            return
        end
        local identifier = GetPlayerIdentifier(target, 'license')
        if identifier then
            MySQL.Async.execute('UPDATE users SET group_name = @group WHERE identifier = @identifier', {
                ['@group'] = group,
                ['@identifier'] = identifier,
            })
            print(('[^2ESX^7] Groupe de ID %s => %s'):format(target, group))
        end
    end
end, false)

RegisterCommand('givemoney', function(source, args)
    if source == 0 or IsPlayerAdmin(source) then
        local target = tonumber(args[1])
        local amount = tonumber(args[2])
        if not target or not amount then
            print('[ESX] Usage: /givemoney [id] [montant]')
            return
        end
        local ESXObj = exports['esx_core']:getSharedObject()
        ESXObj.AddMoney(target, amount)
        print(('[^2ESX^7] $%s donné à ID %s'):format(amount, target))
    end
end, false)

function IsPlayerAdmin(src)
    local identifier = GetPlayerIdentifier(src, 'license')
    if not identifier then return false end
    local result = MySQL.Sync.fetchAll('SELECT group_name FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
    })
    if result and result[1] then
        return Config.AdminGroups[result[1].group_name] or false
    end
    return false
end
