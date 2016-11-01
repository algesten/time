flashinfo = require './lib/flashinfo'

module.exports = (dispatch) ->

    dispatch (state) -> {info:"Connecting…", running:true}

    socket = window.socket = io()

    socket.on 'connect', ->
        flashinfo dispatch, 'Connected'
    socket.on 'disconnect', ->
        dispatch (state) -> {info:"Reconnecting…", running:true}

    # expose globally and return
    return window.emit = socket.emit.bind(socket)
