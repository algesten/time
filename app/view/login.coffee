{view} = require 'trifl'
{div, a, pass, i} = require('trifl').tagg

module.exports = login = view ->
    div class:'login', -> a href:"auth/google", ->
        i class:'icon-googlex', "Log in with Google"

login()
