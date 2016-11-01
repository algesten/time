{render}        = require 'react-dom'
{createFactory} = require 'react'
{createStore, Provider} = require 'refnux'
app             = require 'comp/app'
wrap            = require 'react-elem'

# the store with state
store = window.store = createStore require('model')

# kick it off by initializing the routing
require('./route') store.dispatch, store.state.views

# start socket io
require('./io') store.dispatch

socket.on 'startup', ->
    #store.dispatch -> {username, userId, pinfo:info}

provider = wrap createFactory Provider

# and bind state to app
render provider({store, app}), document.querySelector('#app')
