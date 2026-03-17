fx_version 'cerulean'
game 'gta5'

name 'esx_skin'
description 'Système de skin/apparence ESX basique'
version '1.0.0'
lua54 'yes'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}
