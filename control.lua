local handler = require('event_handler')
_C = require ('tools.common')
config = require ('tools.config')

handler.add_lib(require('tools.paths'))
handler.add_lib(require('tools.waves'))
handler.add_lib(require('tools.origins'))
handler.add_lib(require('tools.pollution_tracker'))

-- handler.add_lib(require('tools.styles.gui_cheatsheet'))
handler.add_lib(require('tools.origin_controls_gui'))