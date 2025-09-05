fx_version "cerulean"
game "gta5"
lua54 "yes"

author 'DP-Scripts'

shared_scripts {"@ox_lib/init.lua", "config.lua", "main.lua"}

client_script "client/*.lua"

server_scripts {"@oxmysql/lib/MySQL.lua", "server/*.lua"}

ui_page "web/index.html"

files {"web/*", "web/font/bankgothic.ttf"}

escrow_ignore {"config.lua", "main.lua", "install/*"}
