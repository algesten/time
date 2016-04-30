passport = require 'passport'
log      = require 'bog'

profile =
    id: '110994664963851875523'
    displayName: 'Martin Algesten',
    name: { familyName: 'Algesten', givenName: 'Martin' },
    emails: [ { value: 'martin@algesten.se', type: 'account' } ]

module.exports = (app) ->

    passport.serializeUser (user, done) ->
      done(null, user);

    passport.deserializeUser (obj, done) ->
      done(null, obj);

    app.use passport.initialize()
    app.use passport.session()

    dologin = (redirect) -> (req, res) ->
        req.login profile, (err) ->
            if err
                log.warn 'login failed', err
                res.status(400).send 'LOGIN FAILED'
            else
                if redirect
                    res.redirect(redirect)
                else
                    res.status(200).send 'OK'

    # phone app verify a JWT token to authenticate session
    app.post '/auth/token', dologin()

    # client entry point for starting auth
    app.get '/auth/google', dologin('/')
