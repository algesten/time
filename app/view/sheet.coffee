{layout, region} = require 'trifl'
{div}  = require('trifl').tagg

store     = require 'store'

input     = require './input'
interpret = require './interpret'

module.exports = sheet = layout ->
    div class:'controls', ->
        div region('input')
        div region('interpret')
    div class:'entries', region('entries')

sheet.input input
sheet.interpret interpret

sheet.update = ->
    if store.entries
        input store.entries
        interpret store.entries
