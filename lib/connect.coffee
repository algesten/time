{pick, each, keys, pfail, pipe, apply} = require 'fnuc'

shim    = require '../app/lib/persist'
persist = require './persist'

# sanity check
each keys(shim), (name) ->
    throw new Error("Missing persist function: #{name}") unless persist[name]

userOf    = (socket) -> socket.request.session?.passport?.user ? {}
userProps = pick 'id displayName name emails photos'.split(' ')

ok   = (cb) -> (v) -> cb null, v
fail = (cb) -> (e) -> cb e

module.exports = (socket) ->

    # this is a read only user object from auth
    user =  userProps userOf socket

    # emit the user to the client
    socket.emit 'startup', user

    # create args array with prepended contextual user
    args = (as) -> [user, as...]

    # provide user to every persistence method
    each keys(shim), (name) -> socket.on name, (as, cb) ->
        fn = pipe apply(persist[name]), ok(cb), pfail(fail cb)
        fn args(as)
