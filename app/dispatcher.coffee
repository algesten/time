{updated, handle} = require 'trifl'
{pipe}  = require 'fnuc'
moment            = require 'moment'
doaction          = require 'lib/doaction'

# start socket.io
socket = io()

# server sends us the signal to do stuff
socket.on 'startup', doaction('startup')

# function for emitting events
emit = socket.emit.bind(socket)

# persistence proxy to client
persist = require('lib/persist-proxy')(emit)

# the model handling functions
model     = require('lib/model') persist, updated
viewstate = require('lib/viewstate') updated

# singleton with latest version of each model
store = require 'store'

# when page has just loaded
handle 'init', ->

    # initial viewstate set in store
    store.set('viewstate') viewstate.init()

# when server tells us to start
handle 'startup', pipe store.set('user'), (user) ->

    state = if user then 'entry' else 'need_login'
    store.set('viewstate') viewstate.transition store.viewstate, state

    # default time period to load into UI
    start = moment().subtract(1, 'month').toDate()
    stop  = moment().toDate()

    # load the start model
    model.load(start, stop).then doaction('loaded')

# when we loaded new model data
handle 'loaded', store.set('model')
