{layout, region} = require 'trifl'
{div}  = require('trifl').tagg

store     = require 'store'

input     = require './input'
interpret = require './interpret'
entrylist = require './entrylist'

module.exports = sheet = layout -> div ->
    div class:'controls', ->
        div region('input')
        div region('interpret')
    div region('entrylist')

sheet.input input
sheet.interpret interpret
sheet.entrylist entrylist

sheet.update = ->
    {entries} = store
    if entries
        input     entries
        interpret entries
        entrylist entries
