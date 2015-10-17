{handle} = require 'trifl'
store    = require 'store'

applayout = require './applayout'
showstate  = require './showstate'

handle 'update:viewstate', ->
    applayout.top showstate
    showstate store.viewstate
