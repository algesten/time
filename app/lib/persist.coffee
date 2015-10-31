
module.exports =

    # :: (date, date) -> entries (anemic)
    # {userId, entries}
    load: (start, stop) ->

    # :: entry -> entry
    save: (entry) ->

    # :: entry -> bool
    delete: (entry) ->

    # :: (date, date) -> [client]
    clients: ->

    # :: client -> client
    saveclient:  (client) ->

    # :: client -> bool
    deleteclient: (client) ->

    # :: (date, date) -> [project]
    projects: ->

    # :: project -> project
    saveproject: (project) ->

    # :: project -> bool
    deleteproject: (project) ->