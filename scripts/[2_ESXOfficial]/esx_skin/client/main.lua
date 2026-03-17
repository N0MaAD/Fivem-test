local defaultSkin = {
    sex = 0,
    face = 0,
    skin = 0,
    hair_1 = 0,
    hair_2 = 0,
    hair_color_1 = 0,
    hair_color_2 = 0,
}

RegisterNetEvent('esx_skin:loadSkin')
AddEventHandler('esx_skin:loadSkin', function(skin)
    applySkin(skin)
end)

RegisterNetEvent('esx_skin:loadDefaultSkin')
AddEventHandler('esx_skin:loadDefaultSkin', function()
    applySkin(defaultSkin)
    TriggerServerEvent('esx_skin:save', defaultSkin)
end)

AddEventHandler('esx:onPlayerSpawned', function()
    TriggerServerEvent('esx_skin:requestSkin')
end)

function applySkin(skin)
    local ped = PlayerPedId()

    if skin.sex == 0 then
        SetPlayerModel(PlayerId(), GetHashKey('mp_m_freemode_01'))
    else
        SetPlayerModel(PlayerId(), GetHashKey('mp_f_freemode_01'))
    end

    ped = PlayerPedId()

    SetPedDefaultComponentVariation(ped)

    if skin.face then
        SetPedHeadBlendData(ped, skin.face, skin.face, 0, skin.skin or 0, skin.skin or 0, 0, 0.0, 0.0, 0.0, false)
    end

    if skin.hair_1 then
        SetPedComponentVariation(ped, 2, skin.hair_1, skin.hair_2 or 0, 2)
        SetPedHairColor(ped, skin.hair_color_1 or 0, skin.hair_color_2 or 0)
    end
end
