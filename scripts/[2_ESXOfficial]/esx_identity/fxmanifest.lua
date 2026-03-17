fx_version 'cerulean'
game 'gta5'

name 'esx_identity'
description 'Système d\'identité ESX'
version '1.0.0'
lua54 'yes'

ui_page 'html/ui.html'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

files {
    'html/ui.html',
    'html/css/app.css',
    'html/js/app.js',
}
