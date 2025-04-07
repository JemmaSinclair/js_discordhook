fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

author 'JemmaSinclair'
description 'discord logging for Trail Roleplay'
version '0.0.1'

client_scripts {
    'client.lua'
}

server_scripts { 
    'server.lua'
}

shared_script 'config.lua'

server_export 'sendToDiscordEmbed'

exports {
    'sendToDiscordEmbed'
}