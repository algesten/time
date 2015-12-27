session      = require 'express-session'
bodyParser   = require 'body-parser'
express      = require 'express'
{normalize}  = require 'path'

module.exports = (port, path, cb) ->

    app    = express()
    server = require('http').Server app

    app.use bodyParser.text()
    SESSION_OPTS =
        secret: process.env.COOKIE_SECRET
        resave: false
        saveUninitialized:false
    sessionmw = session SESSION_OPTS # the middleware function
    app.use sessionmw

    # hook up auth
    require('./auth') app

    # start socket.io
    io = require('socket.io') server

    # hook up session reading to socket.io
    io.use (socket, next) -> sessionmw socket.request, {}, next
    io.on 'connection', require('./connect')

    # set up pushstate serving
    pushstate = require('./pushstate') [path]
    app.all '/*', pushstate

    # listen to port suggested by brunch
    server.listen port

    # we're done
    cb()
