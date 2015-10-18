{action} = require 'trifl'

# init dispatcher/controller
require 'dispatcher'
require 'view/controller'

# expose store, for easy debugging
window.store = require 'store'

# tie applayout to DOM
document.querySelector('#applayout').appendChild require('view/applayout').el

# tell dispatcher to init the stores
action 'init'
