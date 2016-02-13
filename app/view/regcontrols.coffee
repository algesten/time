{view, action} = require 'trifl'
{div, button}  = require('trifl').tagg

stop = (ev) ->
    ev.stopPropagation()
    ev.preventDefault()

module.exports = regcontrols = view -> div class:'regcontrols', ->
    button 'Add Client', onclick: (ev) ->
        stop ev
    button 'Add Project', onclick: (ev) ->
        stop ev

regcontrols()
