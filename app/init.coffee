{render}        = require 'react-dom'
{createFactory} = require 'react'
{createStore, Provider} = require 'refnux'
app             = require 'comp/app'
wrap            = require 'react-elem'

# the store with state
store = window.store = createStore require('model')

init = ->
    # kick it off by initializing the routing
    require('./route') store.dispatch

# start socket io
require('./io') store.dispatch

socket.on 'user', ({username, userId, info}) ->
    #store.dispatch -> {username, userId, pinfo:info}
    init()

provider = wrap createFactory Provider

# and bind state to app
render provider({store, app}), document.querySelector('#app')
