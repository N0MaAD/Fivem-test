local ESXObj = nil
local activeCalls = {} -- activeCalls[src] = targetSrc

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        ESXObj = exports['esx_core']:getSharedObject()
    end
end)

-- ========== UTILITAIRES ==========

local function getIdentifier(src)
    for _, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(v, 'license:') then return v end
    end
    return nil
end

local function getPhoneNumber(identifier, cb)
    MySQL.Async.fetchAll('SELECT phone_number FROM phone_users WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
    }, function(result)
        if result[1] then
            cb(result[1].phone_number)
        else
            -- Générer un numéro
            local number = '06' .. math.random(10000000, 99999999)
            MySQL.Async.execute('INSERT INTO phone_users (identifier, phone_number) VALUES (@identifier, @number)', {
                ['@identifier'] = identifier,
                ['@number'] = number,
            })
            cb(number)
        end
    end)
end

local function getSourceByPhoneNumber(number, cb)
    MySQL.Async.fetchAll('SELECT identifier FROM phone_users WHERE phone_number = @number', {
        ['@number'] = number,
    }, function(result)
        if not result[1] then cb(nil) return end

        local targetIdentifier = result[1].identifier
        if not ESXObj then ESXObj = exports['esx_core']:getSharedObject() end

        for src, player in pairs(ESXObj.GetPlayers()) do
            if player.identifier == targetIdentifier then
                cb(src)
                return
            end
        end
        cb(nil)
    end)
end

-- ========== NUMÉRO DE TÉLÉPHONE ==========

RegisterNetEvent('esx_phone:requestPhoneNumber')
AddEventHandler('esx_phone:requestPhoneNumber', function()
    local src = source
    local identifier = getIdentifier(src)
    if not identifier then return end

    getPhoneNumber(identifier, function(number)
        TriggerClientEvent('esx_phone:setPhoneNumber', src, number)
    end)
end)

-- ========== CONTACTS ==========

RegisterNetEvent('esx_phone:requestContacts')
AddEventHandler('esx_phone:requestContacts', function()
    local src = source
    local identifier = getIdentifier(src)
    if not identifier then return end

    MySQL.Async.fetchAll('SELECT * FROM phone_contacts WHERE identifier = @identifier ORDER BY name ASC', {
        ['@identifier'] = identifier,
    }, function(result)
        TriggerClientEvent('esx_phone:loadContacts', src, result or {})
    end)
end)

RegisterNetEvent('esx_phone:addContact')
AddEventHandler('esx_phone:addContact', function(name, number)
    local src = source
    local identifier = getIdentifier(src)
    if not identifier or not name or not number then return end

    if #name > 50 or #number > 20 then return end

    MySQL.Async.execute('INSERT INTO phone_contacts (identifier, name, number) VALUES (@identifier, @name, @number)', {
        ['@identifier'] = identifier,
        ['@name'] = name,
        ['@number'] = number,
    })
    TriggerClientEvent('esx_phone:contactAdded', src)
end)

RegisterNetEvent('esx_phone:deleteContact')
AddEventHandler('esx_phone:deleteContact', function(id)
    local src = source
    local identifier = getIdentifier(src)
    if not identifier or not id then return end

    MySQL.Async.execute('DELETE FROM phone_contacts WHERE id = @id AND identifier = @identifier', {
        ['@id'] = id,
        ['@identifier'] = identifier,
    })
    TriggerClientEvent('esx_phone:contactAdded', src)
end)

-- ========== MESSAGES ==========

RegisterNetEvent('esx_phone:requestMessages')
AddEventHandler('esx_phone:requestMessages', function()
    local src = source
    local identifier = getIdentifier(src)
    if not identifier then return end

    getPhoneNumber(identifier, function(myNumber)
        MySQL.Async.fetchAll(
            'SELECT * FROM phone_messages WHERE sender = @number OR receiver = @number ORDER BY created_at DESC LIMIT 50',
            { ['@number'] = myNumber },
            function(result)
                TriggerClientEvent('esx_phone:loadMessages', src, result or {})
            end
        )
    end)
end)

RegisterNetEvent('esx_phone:sendMessage')
AddEventHandler('esx_phone:sendMessage', function(targetNumber, message)
    local src = source
    local identifier = getIdentifier(src)
    if not identifier or not targetNumber or not message then return end

    if #message > 500 then message = string.sub(message, 1, 500) end

    getPhoneNumber(identifier, function(myNumber)
        MySQL.Async.execute(
            'INSERT INTO phone_messages (sender, receiver, message) VALUES (@sender, @receiver, @message)',
            {
                ['@sender'] = myNumber,
                ['@receiver'] = targetNumber,
                ['@message'] = message,
            }
        )

        -- Notifier le destinataire s'il est en ligne
        getSourceByPhoneNumber(targetNumber, function(targetSrc)
            if targetSrc then
                TriggerClientEvent('esx_phone:receiveMessage', targetSrc, {
                    sender = myNumber,
                    message = message,
                })
            end
        end)

        -- Rafraîchir les messages de l'envoyeur
        TriggerClientEvent('esx_phone:messageDeleted', src)
    end)
end)

RegisterNetEvent('esx_phone:deleteMessage')
AddEventHandler('esx_phone:deleteMessage', function(id)
    local src = source
    local identifier = getIdentifier(src)
    if not identifier or not id then return end

    local myNumber = nil
    getPhoneNumber(identifier, function(number)
        myNumber = number
    end)

    Wait(100)

    if myNumber then
        MySQL.Async.execute('DELETE FROM phone_messages WHERE id = @id AND (sender = @number OR receiver = @number)', {
            ['@id'] = id,
            ['@number'] = myNumber,
        })
        TriggerClientEvent('esx_phone:messageDeleted', src)
    end
end)

-- ========== BANQUE ==========

RegisterNetEvent('esx_phone:requestBank')
AddEventHandler('esx_phone:requestBank', function()
    local src = source
    if not ESXObj then ESXObj = exports['esx_core']:getSharedObject() end

    local player = ESXObj.GetPlayerFromId(src)
    if player then
        TriggerClientEvent('esx_phone:loadBank', src, {
            money = player.accounts.money or 0,
            bank = player.accounts.bank or 0,
            black_money = player.accounts.black_money or 0,
        })
    end
end)

-- ========== APPELS ==========

RegisterNetEvent('esx_phone:callPlayer')
AddEventHandler('esx_phone:callPlayer', function(targetNumber)
    local src = source
    local identifier = getIdentifier(src)
    if not identifier or not targetNumber then return end

    if activeCalls[src] then
        TriggerClientEvent('esx_phone:callEnded', src, 'Vous êtes déjà en appel.')
        return
    end

    getPhoneNumber(identifier, function(myNumber)
        getSourceByPhoneNumber(targetNumber, function(targetSrc)
            if not targetSrc then
                TriggerClientEvent('esx_phone:callEnded', src, 'Numéro hors ligne.')

                MySQL.Async.execute(
                    'INSERT INTO phone_calls (caller, receiver, status) VALUES (@caller, @receiver, @status)',
                    { ['@caller'] = myNumber, ['@receiver'] = targetNumber, ['@status'] = 'missed' }
                )
                return
            end

            if activeCalls[targetSrc] then
                TriggerClientEvent('esx_phone:callEnded', src, 'Ligne occupée.')
                return
            end

            -- Marquer l'appel comme actif
            activeCalls[src] = targetSrc
            activeCalls[targetSrc] = src

            -- Chercher le nom du contact
            local callerName = GetPlayerName(src) or 'Inconnu'

            TriggerClientEvent('esx_phone:incomingCall', targetSrc, myNumber, callerName)

            -- Timeout 30s si pas de réponse
            SetTimeout(30000, function()
                if activeCalls[src] == targetSrc and activeCalls[targetSrc] == src then
                    -- Vérifier si l'appel est toujours en attente (pas encore answered)
                    activeCalls[src] = nil
                    activeCalls[targetSrc] = nil
                    TriggerClientEvent('esx_phone:callEnded', src, 'Pas de réponse.')
                    TriggerClientEvent('esx_phone:callEnded', targetSrc, 'Appel manqué.')

                    MySQL.Async.execute(
                        'INSERT INTO phone_calls (caller, receiver, status) VALUES (@caller, @receiver, @status)',
                        { ['@caller'] = myNumber, ['@receiver'] = targetNumber, ['@status'] = 'missed' }
                    )
                end
            end)
        end)
    end)
end)

RegisterNetEvent('esx_phone:answerCall')
AddEventHandler('esx_phone:answerCall', function()
    local src = source
    local callerSrc = activeCalls[src]

    if not callerSrc then return end

    TriggerClientEvent('esx_phone:callAnswered', src)
    TriggerClientEvent('esx_phone:callAnswered', callerSrc)

    -- Log l'appel
    local callerIdentifier = getIdentifier(callerSrc)
    local receiverIdentifier = getIdentifier(src)

    if callerIdentifier and receiverIdentifier then
        getPhoneNumber(callerIdentifier, function(callerNumber)
            getPhoneNumber(receiverIdentifier, function(receiverNumber)
                MySQL.Async.execute(
                    'INSERT INTO phone_calls (caller, receiver, status) VALUES (@caller, @receiver, @status)',
                    { ['@caller'] = callerNumber, ['@receiver'] = receiverNumber, ['@status'] = 'answered' }
                )
            end)
        end)
    end
end)

RegisterNetEvent('esx_phone:hangUp')
AddEventHandler('esx_phone:hangUp', function()
    local src = source
    local otherSrc = activeCalls[src]

    activeCalls[src] = nil
    if otherSrc then
        activeCalls[otherSrc] = nil
        TriggerClientEvent('esx_phone:callEnded', otherSrc, 'Appel terminé.')
    end
    TriggerClientEvent('esx_phone:callEnded', src, 'Appel terminé.')
end)

RegisterNetEvent('esx_phone:declineCall')
AddEventHandler('esx_phone:declineCall', function()
    local src = source
    local callerSrc = activeCalls[src]

    activeCalls[src] = nil
    if callerSrc then
        activeCalls[callerSrc] = nil
        TriggerClientEvent('esx_phone:callEnded', callerSrc, 'Appel refusé.')
    end
    TriggerClientEvent('esx_phone:callEnded', src, 'Appel refusé.')
end)

-- ========== HISTORIQUE APPELS ==========

RegisterNetEvent('esx_phone:requestCallHistory')
AddEventHandler('esx_phone:requestCallHistory', function()
    local src = source
    local identifier = getIdentifier(src)
    if not identifier then return end

    getPhoneNumber(identifier, function(myNumber)
        MySQL.Async.fetchAll(
            'SELECT * FROM phone_calls WHERE caller = @number OR receiver = @number ORDER BY created_at DESC LIMIT 30',
            { ['@number'] = myNumber },
            function(result)
                TriggerClientEvent('esx_phone:loadCallHistory', src, result or {})
            end
        )
    end)
end)

-- ========== TWITTER / ANNONCES ==========

RegisterNetEvent('esx_phone:requestTwitter')
AddEventHandler('esx_phone:requestTwitter', function()
    local src = source
    MySQL.Async.fetchAll('SELECT * FROM phone_twitter ORDER BY created_at DESC LIMIT 50', {}, function(result)
        TriggerClientEvent('esx_phone:loadTwitter', src, result or {})
    end)
end)

RegisterNetEvent('esx_phone:postTweet')
AddEventHandler('esx_phone:postTweet', function(message)
    local src = source
    if not message or #message == 0 then return end
    if #message > 280 then message = string.sub(message, 1, 280) end

    local playerName = GetPlayerName(src) or 'Anonyme'

    MySQL.Async.execute(
        'INSERT INTO phone_twitter (author, message) VALUES (@author, @message)',
        { ['@author'] = playerName, ['@message'] = message }
    )

    -- Broadcast à tous les joueurs qui ont le phone ouvert
    TriggerClientEvent('esx_phone:loadTwitter', -1, nil)

    -- Rafraîchir pour tous
    if ESXObj then
        for playerSrc, _ in pairs(ESXObj.GetPlayers()) do
            TriggerEvent('esx_phone:requestTwitter')
        end
    end
end)

-- ========== NETTOYAGE DÉCONNEXION ==========

AddEventHandler('playerDropped', function()
    local src = source
    local otherSrc = activeCalls[src]

    if otherSrc then
        activeCalls[otherSrc] = nil
        TriggerClientEvent('esx_phone:callEnded', otherSrc, 'Correspondant déconnecté.')
    end
    activeCalls[src] = nil
end)
