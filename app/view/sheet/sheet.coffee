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
    {entries, projects} = store
    if entries
        controls.update entries
        entrylist entries, projects
