flashinfo = require './lib/flashinfo'

module.exports = (dispatch) ->

    dispatch (state) -> {info:"Connecting…", running:true}

    socket = window.socket = io()

    socket.on 'connect', ->
        flashinfo dispatch, 'Connected'
    socket.on 'disconnect', ->
        dispatch (state) -> {info:"Not connected"}

    # expose globally
    window.emit = socket.emit.bind(socket)
