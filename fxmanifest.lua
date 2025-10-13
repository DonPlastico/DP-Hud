fx_version 'cerulean'
game 'gta5'

author 'DP-Scripts'
version '1.0.0'

clr_disable_task_scheduler 'yes'

client_scripts {
	'Golden.Minimap.net.dll',
	'modules/cl.lua',
}


files {
	'*.dll',
	'stream/*.gfx'
}

ui_page 'nui/index.html'

files {
    'nui/*.*',
    'nui/**/*.*', 
	'*.dll',
    'stream/*.gfx'
}

data_file "SCALEFORM_DLC_FILE" "stream/*.gfx"
