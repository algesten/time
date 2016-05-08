GoogleStrategy = require('passport-google-oauth20').Strategy
passport   = require 'passport'
token      = require './token'
log        = require 'bog'

module.exports = (app) ->

    passport.serializeUser (user, done) ->
      done(null, user);

    passport.deserializeUser (obj, done) ->
      done(null, obj);

    passport.use new GoogleStrategy
        clientID:     process.env.AUTH_GOOGLE_CLIENT_ID
        clientSecret: process.env.AUTH_GOOGLE_CLIENT_SECRET
        callbackURL:  process.env.AUTH_HOST + "/auth/google/callback"
    , (accessToken, refreshToken, profile, done) ->
        done null, profile

    app.use passport.initialize()
    app.use passport.session()

    # phone app verify a JWT token to authenticate session
    app.post '/auth/token', (req, res) ->
        body = req.body if typeof req.body == 'string'
        token(body).then (profile) ->
            req.login profile, (err) ->
                if err
                    log.warn 'login failed', err
                    res.status(500).send 'LOGIN FAILED'
                else
                    res.status(200).send 'OK'
        .catch (err) ->
            if typeof err == 'number'
                res.status(err).send 'NOT OK'
            else
                log.warn 'Token failed', err
                res.status(500).send 'FAILED'

    # client entry point for starting auth
    app.get '/auth/google', passport.authenticate 'google',
        scope:          'profile email'
        accessType:     'online'
        approvalPrompt: 'auto'

    # google callback on successful/not successful auth
    app.get '/auth/google/callback',
        passport.authenticate('google', {failureRedirect:'/login'})
    , (req, res) ->
        # successful authentication, redirect home.
        res.redirect '/'
