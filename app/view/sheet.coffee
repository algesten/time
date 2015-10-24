{layout, region} = require 'trifl'
{div}  = require('trifl').tagg

store     = require 'store'

controls  = require './controls'
entrylist = require './entrylist'

module.exports = sheet = layout -> div ->
    div region('controls')
    div region('entrylist')

sheet.controls controls
sheet.entrylist entrylist

sheet.update = ->
    {entries} = store
    if entries
        unless entries.editId
            controls.update entries
        entrylist entries
