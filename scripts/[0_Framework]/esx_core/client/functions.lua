-- Fonctions client utilitaires

function ESX.ShowNotification(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentSubstringPlayerName(msg)
    DrawNotification(false, true)
end

function ESX.ShowHelpNotification(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function ESX.GetClosestPlayer(coords)
    local closestPlayer = -1
    local closestDistance = -1
    coords = coords or GetEntityCoords(PlayerPedId())

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

function ESX.GetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then return end

    local props = {
        model       = GetEntityModel(vehicle),
        plate       = GetVehicleNumberPlateText(vehicle),
        color1      = {GetVehicleColours(vehicle)},
        color2      = {select(2, GetVehicleColours(vehicle))},
        pearlescentColor = {GetVehicleExtraColours(vehicle)},
        wheelColor  = {select(2, GetVehicleExtraColours(vehicle))},
    }

    return props
end
