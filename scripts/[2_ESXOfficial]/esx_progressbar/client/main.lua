local isActive = false

function ESX.ShowProgressBar(duration, label, cb)
    if isActive then return end
    isActive = true

    SendNUIMessage({
        action   = 'start',
        duration = duration,
        label    = label or '',
    })

    SetTimeout(duration, function()
        isActive = false
        SendNUIMessage({ action = 'stop' })
        if cb then cb() end
    end)
end

exports('ShowProgressBar', ESX.ShowProgressBar)

RegisterNetEvent('esx_progressbar:start')
AddEventHandler('esx_progressbar:start', function(duration, label, cb)
    ESX.ShowProgressBar(duration, label, cb)
end)
