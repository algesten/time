{action} = require 'trifl'

# init dispatcher/controller
{emit, persist} = require 'dispatcher'

# tell dispatcher to init the stores
action 'init'

require 'view/controller'
require './router'

store = require 'store'

# expose for easy debugging
window.emit    = emit
window.store   = store
window.persist = persist

# tie applayout to DOM
document.querySelector('#applayout').appendChild require('view/applayout').el
