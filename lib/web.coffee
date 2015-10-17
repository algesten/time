{pick, split} = require 'fnuc'
session      = require 'express-session'
cookieParser = require 'cookie-parser'
bodyParser   = require 'body-parser'
express      = require 'express'
{normalize}  = require 'path'

module.exports = (port, path, cb) ->

    app    = express()
    server = require('http').Server app

    app.use cookieParser()
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
    io     = require('socket.io') server

    # hook up session reading to socket.io
    io.use (socket, next) -> sessionmw socket.request, {}, next
    io.on 'connection', (socket) ->
        rawUser = socket.request.session?.passport?.user ? {}
        user = pick rawUser, split(' ') 'id displayName name emails photos'
        socket.emit 'startup', user

    # root of static files
    root = normalize __dirname + '/../' + path

    # set up as static serving
    app.use express.static root

    # listen to port suggested by brunch
    server.listen port

    # we're done
    cb()
