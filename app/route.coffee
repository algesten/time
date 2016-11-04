{route, path, navigate} = require 'broute'

loadReports = require './actions/load-reports'

module.exports = (dispatch, views) ->

    # reverse sort to get href '/' last
    sorted = views.slice(0).sort (v1, v2) -> v2.href.localeCompare v1

    path ->
        did = false
        sorted.forEach (v) ->
            return if did
            path v.href, -> did = true; dispatch -> {view:v.id}

        path '/report', ->
            dispatch loadReports

    navigate()
