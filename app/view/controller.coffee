{handle} = require 'trifl'
store    = require 'store'

applayout = require './applayout'
showstate = require './showstate'
sheet     = require './sheet'
login     = require './login'

handle 'update:viewstate', ->
    applayout.top showstate

    applayout.mid switch store.viewstate.state
        when 'ready'         then sheet
        when 'require login' then login
        else null

    update()


handle 'update:entries', ->
    update()

update = ->
    showstate store.viewstate
    sheet.update()
