local isPhoneOpen = false
local hasPhone = true -- TODO: vérifier si le joueur a l'item 'phone' dans l'inventaire
local phoneNumber = nil

-- Récupérer le numéro du joueur au spawn
RegisterNetEvent('esx_phone:setPhoneNumber')
AddEventHandler('esx_phone:setPhoneNumber', function(number)
    phoneNumber = number
end)

AddEventHandler('esx:onPlayerSpawned', function()
    TriggerServerEvent('esx_phone:requestPhoneNumber')
end)

-- ========== OUVERTURE / FERMETURE ==========

RegisterCommand('phone', function()
    togglePhone()
end, false)

RegisterKeyMapping('phone', 'Ouvrir le téléphone', 'keyboard', 'F1')

function togglePhone()
    if not hasPhone then
        exports['esx_notify']:ShowNotification("Vous n'avez pas de téléphone.", 'error', 3000)
        return
    end

    isPhoneOpen = not isPhoneOpen

    if isPhoneOpen then
        openPhone()
    else
        closePhone()
    end
end

function openPhone()
    isPhoneOpen = true
    SetNuiFocus(true, true)

    -- Anim téléphone
    local ped = PlayerPedId()
    RequestAnimDict('cellphone@')
    while not HasAnimDictLoaded('cellphone@') do Wait(10) end
    TaskPlayAnim(ped, 'cellphone@', 'cellphone_text_read_base', 8.0, -1, -1, 50, 0, false, false, false)

    SendNUIMessage({
        action = 'openPhone',
        phoneNumber = phoneNumber or 'N/A',
    })

    -- Charger les données
    TriggerServerEvent('esx_phone:requestContacts')
    TriggerServerEvent('esx_phone:requestMessages')
    TriggerServerEvent('esx_phone:requestBank')
    TriggerServerEvent('esx_phone:requestCallHistory')
end

function closePhone()
    isPhoneOpen = false
    SetNuiFocus(false, false)

    local ped = PlayerPedId()
    StopAnimTask(ped, 'cellphone@', 'cellphone_text_read_base', 1.0)

    SendNUIMessage({ action = 'closePhone' })
end

-- ========== NUI CALLBACKS ==========

RegisterNUICallback('closePhone', function(_, cb)
    closePhone()
    cb('ok')
end)

-- Contacts
RegisterNUICallback('addContact', function(data, cb)
    TriggerServerEvent('esx_phone:addContact', data.name, data.number)
    cb('ok')
end)

RegisterNUICallback('deleteContact', function(data, cb)
    TriggerServerEvent('esx_phone:deleteContact', data.id)
    cb('ok')
end)

-- Messages
RegisterNUICallback('sendMessage', function(data, cb)
    TriggerServerEvent('esx_phone:sendMessage', data.target, data.message)
    cb('ok')
end)

RegisterNUICallback('deleteMessage', function(data, cb)
    TriggerServerEvent('esx_phone:deleteMessage', data.id)
    cb('ok')
end)

-- Appels
RegisterNUICallback('callNumber', function(data, cb)
    TriggerServerEvent('esx_phone:callPlayer', data.number)
    cb('ok')
end)

RegisterNUICallback('hangUp', function(_, cb)
    TriggerServerEvent('esx_phone:hangUp')
    cb('ok')
end)

RegisterNUICallback('answerCall', function(_, cb)
    TriggerServerEvent('esx_phone:answerCall')
    cb('ok')
end)

RegisterNUICallback('declineCall', function(_, cb)
    TriggerServerEvent('esx_phone:declineCall')
    cb('ok')
end)

-- Demander les tweets / annonces
RegisterNUICallback('requestTwitter', function(_, cb)
    TriggerServerEvent('esx_phone:requestTwitter')
    cb('ok')
end)

RegisterNUICallback('postTweet', function(data, cb)
    TriggerServerEvent('esx_phone:postTweet', data.message)
    cb('ok')
end)

-- ========== EVENTS SERVEUR -> CLIENT ==========

RegisterNetEvent('esx_phone:loadContacts')
AddEventHandler('esx_phone:loadContacts', function(contacts)
    SendNUIMessage({ action = 'loadContacts', contacts = contacts })
end)

RegisterNetEvent('esx_phone:loadMessages')
AddEventHandler('esx_phone:loadMessages', function(messages)
    SendNUIMessage({ action = 'loadMessages', messages = messages })
end)

RegisterNetEvent('esx_phone:loadBank')
AddEventHandler('esx_phone:loadBank', function(bank)
    SendNUIMessage({ action = 'loadBank', bank = bank })
end)

RegisterNetEvent('esx_phone:loadCallHistory')
AddEventHandler('esx_phone:loadCallHistory', function(calls)
    SendNUIMessage({ action = 'loadCallHistory', calls = calls })
end)

RegisterNetEvent('esx_phone:loadTwitter')
AddEventHandler('esx_phone:loadTwitter', function(tweets)
    SendNUIMessage({ action = 'loadTwitter', tweets = tweets })
end)

RegisterNetEvent('esx_phone:receiveMessage')
AddEventHandler('esx_phone:receiveMessage', function(msg)
    SendNUIMessage({ action = 'newMessage', message = msg })

    if not isPhoneOpen then
        exports['esx_notify']:ShowNotification('Nouveau message de ' .. (msg.sender or 'Inconnu'), 'info', 4000)
    end
end)

RegisterNetEvent('esx_phone:incomingCall')
AddEventHandler('esx_phone:incomingCall', function(callerNumber, callerName)
    if not isPhoneOpen then
        openPhone()
    end

    SendNUIMessage({
        action = 'incomingCall',
        callerNumber = callerNumber,
        callerName = callerName or 'Inconnu',
    })
end)

RegisterNetEvent('esx_phone:callAnswered')
AddEventHandler('esx_phone:callAnswered', function()
    SendNUIMessage({ action = 'callAnswered' })
end)

RegisterNetEvent('esx_phone:callEnded')
AddEventHandler('esx_phone:callEnded', function(reason)
    SendNUIMessage({ action = 'callEnded', reason = reason or 'Appel terminé' })
end)

RegisterNetEvent('esx_phone:contactAdded')
AddEventHandler('esx_phone:contactAdded', function()
    TriggerServerEvent('esx_phone:requestContacts')
end)

RegisterNetEvent('esx_phone:messageDeleted')
AddEventHandler('esx_phone:messageDeleted', function()
    TriggerServerEvent('esx_phone:requestMessages')
end)

-- ========== FERMETURE PAR ESC ==========

CreateThread(function()
    while true do
        Wait(0)
        if isPhoneOpen and IsControlJustPressed(0, 177) then -- ESC / Backspace
            closePhone()
        end
    end
end)
