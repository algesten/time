{pick, each, keys, pfail, pipe, apply} = require 'fnuc'

# the original persistence definition
shim = require '../app/lib/persist'

# persistence per user
persistfor = require('./persist')

# sanity check
each keys(shim), (name) ->
    throw new Error("Missing persist function: #{name}") unless persistfor(null)[name]

userOf    = (socket) -> socket.request.session?.passport?.user ? {}
userProps = pick 'id displayName name emails photos'.split(' ')

ok   = (cb) -> (v) -> cb null, v
fail = (cb) -> (e) -> cb e

module.exports = (socket) ->

    # this is a read only user object from auth
    user =  userProps userOf socket

    # emit the user to the client
    socket.emit 'startup', user

    # we don't wire up the persistence unless there is a logged in
    # user.
    if user.id

        # user wrapped persistence
        persist = persistfor user

        # provide user to every persistence method
        each keys(shim), (name) -> socket.on name, (as, cb) ->
            fn = pipe persist[name], ok(cb), pfail(fail cb)
            fn as...
