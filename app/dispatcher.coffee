{pipe, iif, get}  = require 'fnuc'
{updated, handle} = require 'trifl'
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

# viewstate transition
trans = (state) -> -> store.set('viewstate') viewstate.transition store.viewstate, state

# when page has just loaded
handle 'init', ->

    # initial viewstate set in store
    store.set('viewstate') viewstate.init()

# loads one month of data
loadMonth = ->

    # default time period to load into UI
    start = moment().subtract(1, 'month').toDate()
    stop  = moment().toDate()

    # load the start model
    model.load(start, stop).then doaction('loaded')


# when server tells us to start
handle 'startup', pipe store.set('user'),
    iif get('id'), pipe(trans('loading'), loadMonth), trans('require login')

# when we loaded new model data
handle 'loaded', pipe store.set('model'), trans('ready')

handle 'newentry', (model, text) ->
    console.log model, text
