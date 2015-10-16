passport = require 'passport'
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy

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

    # client entry point for starting auth
    app.get '/auth/google',
        passport.authenticate 'google', {scope: 'profile email'}

    # google callback on successful/not successful auth
    app.get '/auth/google/callback',
        passport.authenticate('google', {failureRedirect:'/login'})
    , (req, res) ->
        # successful authentication, redirect home.
        res.redirect '/'
