{render}        = require 'react-dom'
{createFactory} = require 'react'
{createStore, Provider} = require 'refnux'
app             = require 'comp/app'
wrap            = require 'react-elem'

# the store with state
store = window.store = createStore require('model')

# kick it off by initializing the routing
require('./route') store.dispatch, store.state.views

# start socket io.
emit = require('./io') store.dispatch

do ->
    # persistence layer
    persist = require('./lib/persist-proxy')(emit)

    # tie entry decoration to projects/clients
    decorate = (entry) ->
        projects.decorate(store.projects) clients.decorate(store.clients) entry

    # the model handling functions
    clients   = require('lib/clients')  persist
    projects  = require('lib/projects') persist
    entries   = require('lib/entries')  persist, decorate
    reports   = require('lib/reports')  persist

    # put in model for use in actions
    store.dispatch -> fn:{clients, projects, entries, reports}


socket.on 'startup', (user) ->
    unless user?.id?
        store.dispatch -> view:'login'
    else
        store.dispatch -> {user}
        store.dispatch require './actions/load' # load data for user

provider = wrap createFactory Provider

# and bind state to app
render provider({store, app}), document.querySelector('#app')
