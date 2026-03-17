local ESXObj = nil

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() == res then
        ESXObj = exports['esx_core']:getSharedObject()
    end
end)

local function getIdentifier(src)
    for _, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(v, 'license:') then return v end
    end
    return nil
end

-- ========== DONNÉES JOUEUR ==========

RegisterNetEvent('esx_fishing:requestData')
AddEventHandler('esx_fishing:requestData', function()
    local src = source
    local identifier = getIdentifier(src)
    if not identifier then return end

    -- Charger ou créer le profil de pêche
    MySQL.Async.fetchAll('SELECT * FROM fishing_data WHERE identifier = @id', {
        ['@id'] = identifier,
    }, function(result)
        if #result == 0 then
            MySQL.Async.execute('INSERT INTO fishing_data (identifier, xp, level) VALUES (@id, 0, 1)', {
                ['@id'] = identifier,
            })
            TriggerClientEvent('esx_fishing:loadData', src, { xp = 0, level = 1 })
        else
            TriggerClientEvent('esx_fishing:loadData', src, {
                xp    = result[1].xp,
                level = result[1].level,
            })
        end
    end)

    -- Charger l'inventaire de poissons
    MySQL.Async.fetchAll('SELECT * FROM fishing_inventory WHERE identifier = @id', {
        ['@id'] = identifier,
    }, function(result)
        local inventory = {}
        for _, row in ipairs(result) do
            inventory[row.fish_name] = row.amount
        end
        TriggerClientEvent('esx_fishing:loadInventory', src, inventory)
    end)
end)

-- ========== PRISE DE POISSON ==========

RegisterNetEvent('esx_fishing:catchFish')
AddEventHandler('esx_fishing:catchFish', function(fishName)
    local src = source
    local identifier = getIdentifier(src)
    if not identifier or not fishName then return end

    -- Vérifier que le poisson existe dans la config
    local fishData = nil
    for _, f in ipairs(Config.Fish) do
        if f.name == fishName then
            fishData = f
            break
        end
    end
    if not fishData then return end

    -- Ajouter au fishing_inventory
    MySQL.Async.fetchAll('SELECT * FROM fishing_inventory WHERE identifier = @id AND fish_name = @fish', {
        ['@id'] = identifier,
        ['@fish'] = fishName,
    }, function(result)
        if #result == 0 then
            MySQL.Async.execute('INSERT INTO fishing_inventory (identifier, fish_name, amount) VALUES (@id, @fish, 1)', {
                ['@id'] = identifier,
                ['@fish'] = fishName,
            })
        else
            MySQL.Async.execute('UPDATE fishing_inventory SET amount = amount + 1 WHERE identifier = @id AND fish_name = @fish', {
                ['@id'] = identifier,
                ['@fish'] = fishName,
            })
        end
    end)

    -- XP
    if Config.EnableLevels then
        MySQL.Async.fetchAll('SELECT xp, level FROM fishing_data WHERE identifier = @id', {
            ['@id'] = identifier,
        }, function(result)
            if not result[1] then return end

            local currentXp = result[1].xp + fishData.xp
            local currentLevel = result[1].level

            -- Vérifier level up
            local newLevel = currentLevel
            for _, lvl in ipairs(Config.Levels) do
                if currentXp >= lvl.xpRequired and lvl.level > newLevel then
                    newLevel = lvl.level
                end
            end

            MySQL.Async.execute('UPDATE fishing_data SET xp = @xp, level = @level WHERE identifier = @id', {
                ['@xp'] = currentXp,
                ['@level'] = newLevel,
                ['@id'] = identifier,
            })

            TriggerClientEvent('esx_fishing:xpGained', src, fishData.xp, currentXp, newLevel)

            if newLevel > currentLevel then
                TriggerClientEvent('esx_fishing:levelUp', src, newLevel)
            end
        end)
    end
end)

-- ========== VENTE ==========

RegisterNetEvent('esx_fishing:sellAll')
AddEventHandler('esx_fishing:sellAll', function()
    local src = source
    local identifier = getIdentifier(src)
    if not identifier then return end
    if not ESXObj then ESXObj = exports['esx_core']:getSharedObject() end

    MySQL.Async.fetchAll('SELECT * FROM fishing_inventory WHERE identifier = @id AND amount > 0', {
        ['@id'] = identifier,
    }, function(result)
        if #result == 0 then
            TriggerClientEvent('esx_fishing:sellResult', src, false, 0)
            return
        end

        local totalMoney = 0

        for _, row in ipairs(result) do
            local fishData = nil
            for _, f in ipairs(Config.Fish) do
                if f.name == row.fish_name then
                    fishData = f
                    break
                end
            end

            if fishData then
                totalMoney = totalMoney + (fishData.price * row.amount)
            end
        end

        -- Vider l'inventaire
        MySQL.Async.execute('DELETE FROM fishing_inventory WHERE identifier = @id', {
            ['@id'] = identifier,
        })

        -- Donner l'argent
        ESXObj.AddMoney(src, totalMoney)

        TriggerClientEvent('esx_fishing:sellResult', src, true, totalMoney)
    end)
end)

RegisterNetEvent('esx_fishing:sellFish')
AddEventHandler('esx_fishing:sellFish', function(fishName)
    local src = source
    local identifier = getIdentifier(src)
    if not identifier or not fishName then return end
    if not ESXObj then ESXObj = exports['esx_core']:getSharedObject() end

    local fishData = nil
    for _, f in ipairs(Config.Fish) do
        if f.name == fishName then
            fishData = f
            break
        end
    end
    if not fishData then return end

    MySQL.Async.fetchAll('SELECT amount FROM fishing_inventory WHERE identifier = @id AND fish_name = @fish', {
        ['@id'] = identifier,
        ['@fish'] = fishName,
    }, function(result)
        if #result == 0 or result[1].amount <= 0 then
            TriggerClientEvent('esx_fishing:sellResult', src, false, 0)
            return
        end

        local amount = result[1].amount
        local money = fishData.price * amount

        MySQL.Async.execute('DELETE FROM fishing_inventory WHERE identifier = @id AND fish_name = @fish', {
            ['@id'] = identifier,
            ['@fish'] = fishName,
        })

        ESXObj.AddMoney(src, money)
        TriggerClientEvent('esx_fishing:sellResult', src, true, money, fishData.label, amount)
    end)
end)

-- ========== CHECK ROD ==========

RegisterNetEvent('esx_fishing:checkRod')
AddEventHandler('esx_fishing:checkRod', function()
    local src = source

    if not Config.RequireRod then
        TriggerClientEvent('esx_fishing:rodCheck', src, true)
        return
    end

    -- Vérifier item fishing_rod via items table
    local identifier = getIdentifier(src)
    if not identifier then
        TriggerClientEvent('esx_fishing:rodCheck', src, false)
        return
    end

    -- Simple check: on considère que le joueur a la canne (à brancher sur un vrai inventaire)
    TriggerClientEvent('esx_fishing:rodCheck', src, true)
end)
