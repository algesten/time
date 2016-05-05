{pipe, iif, get, converge, maybe, each, I, tap}  = require 'fnuc'
{updated, handle, navigate} = require 'trifl'
moment   = require 'moment'
doaction = require 'lib/doaction'
later    = require './lib/later'

handle.debug = (name, fn) -> handle name, (as...) ->
    console.log name, as...
    fn as...

# start socket.io
socket = io()

# server sends us signals to do stuff
each [
    'startup'
    'updated entry'
    'deleted entry'
    'updated client'
    'deleted client'
    'updated project'
    'deleted project'
    ], (n) -> socket.on n, doaction(n)

# function for emitting events
emit = socket.emit.bind(socket)

# persistence proxy to client
persist = require('lib/persist-proxy')(emit)

# singleton with latest version of each model
store = require 'store'

# tie entry decoration to current clients
decorate = (entry) ->
    projects.decorate(store.projects) clients.decorate(store.clients) entry

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

# put the given thing to the store
handle 'store entries',  store.set('entries')
handle 'store projects', store.set('projects')
handle 'store clients',  store.set('clients')

# save the current input to a new entry, and then update the store.
handle 'save input',  pipe entries.save, maybe doaction('store entries')

# start editing an existing entry
handle 'edit entry', pipe entries.edit, store.set('entries')

# deletions
deletehandler = (sing, plur, delet) ->
    handle "delete #{sing}", pipe delet, doaction("store #{plur}")
deletehandler 'entry',   'entries',  entries.delet
deletehandler 'client',  'clients',  clients.delet
deletehandler 'project', 'projects', projects.delet

log = tap console.log.bind(console)

# updates from the server
updatehandler = (sing, plur, update, erase) ->
    handle "updated #{sing}",
        converge store.get(plur), I, pipe update, store.set(plur)
    handle "deleted #{sing}",
        converge store.get(plur), I, pipe erase, store.set(plur)
updatehandler 'entry',   'entries',  entries.update,  entries.erase
updatehandler 'client',  'clients',  clients.update,  clients.erase
updatehandler 'project', 'projects', projects.update, projects.erase

# show the page given as arg
handle 'show',
    converge store.get('viewstate'), I, pipe viewstate.show, store.set('viewstate')

# navigate to the given path
handle 'navigate', (p) -> later -> navigate p

handle 'new input for clients or projects', do ->
    # test if given string is a project
    isproject = pipe require('lib/parseproject').grok, (v) -> !!v
    (both, txt) ->
        if isproject(txt)
            store.set('projects') projects.setnew both.projects, txt
            store.set('clients')  clients.edit(both.clients, '') if both.clients.input
        else
            store.set('clients')  clients.setnew both.clients, txt
            store.set('projects') projects.edit(both.projects, '') if both.projects.input

handle 'save client or project', do ->
    isproject = (model) -> !!model?.input?.projectId
    saveproject = pipe projects.save, maybe doaction('store projects')
    saveclient  = pipe clients.save,  maybe doaction('store clients')
    iif isproject, saveproject, saveclient

# start editing clients/projects
handle 'edit client',  do ->
    edit   = pipe clients.edit,  store.set('clients')
    unedit = pipe projects.edit, store.set('projects')
    (cs, id, ps) -> edit(cs, id); unedit(ps, '')
handle 'edit project', do ->
    edit   = pipe projects.edit, store.set('projects')
    unedit = pipe clients.edit,  store.set('clients')
    (ps, id, cs) -> edit(ps, id); unedit(cs, '')

module.exports = {emit, persist}
