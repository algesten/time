{view} = require 'trifl'
{div, a} = require('trifl').tagg

module.exports = login = view ->
    div class:'login', a href:"auth/google", "Login with google"

login()
