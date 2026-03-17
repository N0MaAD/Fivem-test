RegisterNetEvent('esx_identity:showRegisterForm')
AddEventHandler('esx_identity:showRegisterForm', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openForm' })
end)

RegisterNetEvent('esx_identity:alreadyRegistered')
AddEventHandler('esx_identity:alreadyRegistered', function()
    -- Joueur déjà enregistré, rien à faire
end)

RegisterNUICallback('registerSubmit', function(data, cb)
    TriggerServerEvent('esx_identity:registerIdentity', {
        firstname   = data.firstname,
        lastname    = data.lastname,
        dateofbirth = data.dateofbirth,
        sex         = data.sex,
    })
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeForm' })
    cb('ok')
end)
