session      = require 'express-session'
bodyParser   = require 'body-parser'
express      = require 'express'
{normalize}  = require 'path'

# running in dev mode?
isdev = !!process.env.DEV

getsessionmw = ->
    SESSION_OPTS =
        secret: if isdev then 'slybastard' else process.env.COOKIE_SECRET
        resave: false
        saveUninitialized:false
    session SESSION_OPTS # the middleware function

module.exports = (port, path, cb) ->

    app    = express()
    server = require('http').Server app

    app.use bodyParser.text()

    sessionmw = getsessionmw()
    app.use sessionmw

    # hook up auth
    require(if isdev then './fakeauth' else './auth') app

    # start socket.io
    io = require('socket.io') server

    # hook up session reading to socket.io
    io.use (socket, next) -> sessionmw socket.request, socket.request.res, next
    io.on 'connection', require('./connect')

    # set up pushstate serving
    pushstate = require('./pushstate') [path]
    app.all '/*', pushstate

    # listen to port suggested by brunch
    server.listen port, cb

    server
