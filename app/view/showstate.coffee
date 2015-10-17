{view} = require 'trifl'
{div}  = require('trifl').tagg

module.exports = view (appstate) -> div -> appstate.state
