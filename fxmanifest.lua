fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'RDE | Peds | Advanced Ped Management System'
author 'RDE SerpentsByte'
version '1.0.2'
description 'Advanced Ped Management System'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql'
}