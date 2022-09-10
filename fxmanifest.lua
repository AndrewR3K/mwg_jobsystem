fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'SavSin'
description 'Job system with Levels'

client_scripts {
    'client/*.lua',
}

shared_script {
    'config.lua',
    'locale.lua',
    'languages/*.lua',
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/*.lua',
}

files {
    'ui/*',
    'ui/vendor/*',
    'ui/assets/*',
    'ui/assets/fonts/*'
}

ui_page 'ui/index.html'

dependencies {
    'vorp_core',
    'oxmysql'
}
