{each, filter} = require 'fnuc'
{view, action} = require 'trifl'
{ol, li, div, pass} = require('trifl').tagg

module.exports = view (clients, projects) -> div class:'reglist', ->
