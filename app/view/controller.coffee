{handle} = require 'trifl'
store    = require 'store'

applayout = require './applayout'
showstate = require './showstate'
input     = require './input'
sheet     = require './sheet'
login     = require './login'

handle 'update:viewstate', ->
    applayout.top showstate

    applayout.mid switch store.viewstate.state
        when 'entry'      then sheet
        when 'need_login' then login
        else null

    update()

update = ->
    showstate store.viewstate
    if store.model
        input store.model
