RegisterNetEvent('esx:showNotification')
AddEventHandler('esx:showNotification', function(msg, notifyType, duration)
    SendNUIMessage({
        action   = 'notify',
        message  = msg,
        type     = notifyType or 'info',
        duration = duration or 5000,
    })
end)

exports('ShowNotification', function(msg, notifyType, duration)
    SendNUIMessage({
        action   = 'notify',
        message  = msg,
        type     = notifyType or 'info',
        duration = duration or 5000,
    })
end)

RegisterNetEvent('esx_notify:send')
AddEventHandler('esx_notify:send', function(msg, notifyType, duration)
    SendNUIMessage({
        action   = 'notify',
        message  = msg,
        type     = notifyType or 'info',
        duration = duration or 5000,
    })
end)
