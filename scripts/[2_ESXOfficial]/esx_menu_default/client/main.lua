local menus = {}
local currentMenu = nil

function ESX.UI.Menu.Open(menuType, namespace, name, data, submit, cancel, change, close)
    local menu = {
        type      = menuType,
        namespace = namespace,
        name      = name,
        data      = data,
        submit    = submit,
        cancel    = cancel,
        change    = change,
        close     = close,
    }

    local menuId = ('%s_%s'):format(namespace, name)
    menus[menuId] = menu
    currentMenu = menuId

    SendNUIMessage({
        action   = 'openMenu',
        menuId   = menuId,
        title    = data.title or 'Menu',
        elements = data.elements or {},
    })
    SetNuiFocus(true, true)

    return menu
end

function ESX.UI.Menu.Close(namespace, name)
    local menuId = ('%s_%s'):format(namespace, name)

    if menus[menuId] then
        if menus[menuId].close then
            menus[menuId].close()
        end
        menus[menuId] = nil
    end

    if currentMenu == menuId then
        currentMenu = nil
        SendNUIMessage({ action = 'closeMenu' })
        SetNuiFocus(false, false)
    end
end

RegisterNUICallback('menuSubmit', function(data, cb)
    if currentMenu and menus[currentMenu] and menus[currentMenu].submit then
        menus[currentMenu].submit(data)
    end
    cb('ok')
end)

RegisterNUICallback('menuCancel', function(data, cb)
    if currentMenu and menus[currentMenu] and menus[currentMenu].cancel then
        menus[currentMenu].cancel()
    end
    cb('ok')
end)

ESX = ESX or {}
ESX.UI = ESX.UI or {}
ESX.UI.Menu = ESX.UI.Menu or {}
