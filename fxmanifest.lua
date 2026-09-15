fx_version 'cerulean'
game 'gta5'

name 'qbx_airdrop'
author 'Zerkke'
description 'Sistema configuravel de Airdrop com aviao, paraquedas, zonas no mapa e temporizador'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/cl_main.lua'
}

server_scripts {
    'server/sv_main.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_inventory',
    'ox_target'
}
