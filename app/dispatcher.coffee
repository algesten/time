{pipe, iif, get, converge, maybe, each, I}  = require 'fnuc'
{updated, handle} = require 'trifl'
moment            = require 'moment'
doaction          = require 'lib/doaction'

# start socket.io
socket = io()

# server sends us signals to do stuff
each ['startup', 'updated entry', 'deleted entry'], (n) -> socket.on n, doaction(n)

# function for emitting events
emit = socket.emit.bind(socket)

# persistence proxy to client
persist = require('lib/persist-proxy')(emit)

# singleton with latest version of each model
store = require 'store'

# tie entry decoration to current clients
decorate = (entry) -> clients.decorate store.clients, entry

# the model handling functions
clients   = require('lib/clients') persist
entries   = require('lib/entries') persist, decorate
viewstate = require('lib/viewstate')

# viewstate transition
trans = (state) -> -> store.set('viewstate') viewstate.transition store.viewstate, state

# do load month and then dispatch action
loadstuff = do ->
    loadentries = pipe entries.month, doaction('loaded entries')
    loadclients = pipe clients.init,  doaction('loaded clients')
    pipe trans('loading'), converge loadentries, loadclients, doaction('loaded')

# when page has just loaded
handle 'init', ->
    # initial viewstate set in store
    store.set('viewstate') viewstate.init()

# when server tells us to start
handle 'startup', pipe store.set('user'),
    iif get('id'), loadstuff, trans('require login')

# when we loaded new entries/client data
handle 'loaded entries', store.set('entries')
handle 'loaded clients', store.set('clients')
handle 'loaded', trans('ready')

# parse new input and update the store
handle 'new input', pipe entries.setnew, store.set('entries')

# put the given entries to the store
handle 'store entries', store.set('entries')

# save the current input to a new entry, and then update the store.
handle 'save input',  pipe entries.save, maybe doaction('store entries')

# updates from the server
handle 'updated entry',
    converge store.get('entries'), I, pipe entries.update, store.set('entries')

# start editing an existing entry
handle 'edit entry', pipe entries.edit, store.set('entries')

# delete existing entry
handle 'delete entry', pipe entries.delet, doaction('store entries')

# delete from server
handle 'deleted entry',
    converge store.get('entries'), I, pipe entries.erase, store.set('entries')
