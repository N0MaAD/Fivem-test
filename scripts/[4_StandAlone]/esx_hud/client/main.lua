CreateThread(function()
    while true do
        Wait(500)

        local ped = PlayerPedId()
        local health = GetEntityHealth(ped) - 100
        local armour = GetPedArmour(ped)

        local money = 0
        local bank = 0

        local playerData = exports['esx_core']:GetPlayerData()
        if playerData and playerData.accounts then
            money = playerData.accounts.money or 0
            bank = playerData.accounts.bank or 0
        end

        SendNUIMessage({
            action = 'updateHud',
            health = math.max(0, health),
            armour = armour,
            money  = money,
            bank   = bank,
        })
    end
end)

-- Masquer le HUD natif de GTA
CreateThread(function()
    while true do
        Wait(0)
        HideHudComponentThisFrame(1)  -- Wanted Stars
        HideHudComponentThisFrame(2)  -- Weapon Icon
        HideHudComponentThisFrame(3)  -- Cash
        HideHudComponentThisFrame(4)  -- MP Cash
        HideHudComponentThisFrame(13) -- Cash Change
    end
end)
