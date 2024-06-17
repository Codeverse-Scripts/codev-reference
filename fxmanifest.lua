fx_version 'cerulean'
game 'gta5'
author 'atiysu'
lua54 'yes'

shared_script 'config.lua'
client_script 'client/client.lua'
server_scripts {
    'server/server.lua',
    'server/prizes.lua',
}

ui_page 'ui/index.html'

files {
    'database.json',
    'ui/**/*.*',
    'ui/*.*',
}

escrow_ignore {
    'client/client.lua',
    'config.lua',
    'server/*.lua',
}