{pick, each, keys, pfail, pipe, apply, maybe, tap, I} = require 'fnuc'
log = require 'bog'

# the original persistence definition
shim  = require '../app/lib/persist'
delay = require './delay'

# persistence per user
persistfor = require './persist'

# sanity check
each keys(shim), (name) ->
    throw new Error("Missing persist function: #{name}") unless persistfor(null)[name]

userOf    = (socket) -> socket.request.session?.passport?.user ? {}
userProps = pick 'id displayName name emails photos'.split(' ')

ok   = (cb) -> tap (v) -> cb(null, v)
fail = (cb) -> (e) ->
    log.warn e.stack
    cb e.message

# map of events that are mapped to user room broadcast
BROADCASTED =
    save:   'updated entry'
    delete: 'deleted entry'

module.exports = (socket) ->

    # this is a read only user object from auth
    user =  userProps userOf socket

    # emit the user to the client
    socket.emit 'startup', user

    # we don't wire up the persistence unless there is a logged in
    # user.
    if user.id

        # join a channel for userid where we broadcast all
        # changes to that user. for multiple browser windows.
        socket.join String user.id

        # user wrapped persistence
        persist = persistfor user

        # broadcast certain events
        broadcast = (name) ->
            event = BROADCASTED[name]
            # delay emit by a second to allow elastic to flush
            emit = tap maybe (value) -> delay(1000) ->
                socket.server.to(String user.id).emit event, value
            if event then emit else I

        # provide user to every persistence method
        each keys(shim), (name) ->
            bcast = broadcast(name)
            socket.on name, (as, cb) ->
                fn = pipe persist[name], ok(cb), bcast, pfail(fail cb)
                fn as...
