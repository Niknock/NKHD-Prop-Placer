fx_version 'cerulean'
game 'gta5'

author 'Niknock HD'
description 'NKHD Prop Placer'
version '1.1.0'

server_scripts {
    '@es_extended/locale.lua',
    'server.lua',
    'config.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'client.lua',
    'config.lua'
}

shared_scripts {
    'config.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}

dependencies {
    'es_extended',
    'ox_target'
}
