fx_version 'cerulean'
game 'gta5'

author 'SafeGuard'
description 'Sistema de Mineiro desenvolvido por SafeGuard Team'
version '1.0.0'
site 'https://safeguardev.net/'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}