fx_version 'cerulean'
game 'gta5'

name 'esx_core'
description 'ESX Core Framework - Base du serveur'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'shared/config.lua',
    'shared/functions.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/commands.lua',
    'server/functions.lua',
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
}

provides 'es_extended'
