{pipe, iif, get, converge, maybe, each, I, tap}  = require 'fnuc'
{updated, handle, navigate} = require 'trifl'
moment   = require 'moment'
doaction = require 'lib/doaction'
later    = require './lib/later'

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
clients   = require('lib/clients')  persist
projects  = require('lib/projects') persist
entries   = require('lib/entries')  persist, decorate
reports   = require('lib/reports')  persist
viewstate = require('lib/viewstate')

# viewstate transition
trans = (state) -> -> store.set('viewstate') viewstate.transition store.viewstate, state

# do load month and then dispatch action
loadstuff = do ->
    loadentries  = pipe entries.month, doaction('loaded entries')
    loadclients  = pipe clients.init,  doaction('loaded clients')
    loadprojects = pipe projects.init, doaction('loaded projects')
    pipe trans('loading'), converge loadentries, loadclients, loadprojects, doaction('loaded')

# when page has just loaded
handle 'init', ->
    # initial viewstate set in store
    store.set('viewstate') viewstate.init()

# initialize report lazily
handle 'reports init', pipe reports.init, doaction('reports set')
handle 'reports refresh', pipe store.get('reports'), reports.refresh, doaction('reports set')
handle 'reports set', store.set('reports')

# when server tells us to start
handle 'startup', pipe store.set('user'),
    iif get('id'), loadstuff, trans('require login')

# when we loaded new entries/client/project data
handle 'loaded entries',  store.set('entries')
handle 'loaded clients',  store.set('clients')
handle 'loaded projects', store.set('projects')
handle 'loaded', pipe store.get('viewstate'), get('showing'), trans, (fn) -> fn()

# parse new input and update the store
handle 'new input', pipe entries.setnew, store.set('entries')

# put the given entries to the store
handle 'store entries', store.set('entries')

# save the current input to a new entry, and then update the store.
handle 'save input',  pipe entries.save, maybe doaction('store entries')

# start editing an existing entry
handle 'edit entry', pipe entries.edit, store.set('entries')

# delete existing entry
handle 'delete entry', pipe entries.delet, doaction('store entries')

log = tap console.log.bind(console)

# updates from the server
handle 'updated entry',
    converge store.get('entries'), I, pipe entries.update, store.set('entries')
# delete from server
handle 'deleted entry',
    converge store.get('entries'), I, pipe entries.erase, store.set('entries')

# show the page given as arg
handle 'show',
    converge store.get('viewstate'), I, pipe viewstate.show, store.set('viewstate')

# navigate to the given path
handle 'navigate', (p) -> later -> navigate p

module.exports = {emit, persist}
