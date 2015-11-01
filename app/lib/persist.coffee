
module.exports =

    # :: (date, date) -> entries (anemic)
    # {userId, entries}
    load: (start, stop) ->

    # :: entry -> entry
    save: (entry) ->

    # :: entry -> entry
    delete: (entry) ->

    # :: (date, date) -> [client]
    clients: ->

    # :: client -> client
    saveclient:  (client) ->

    # :: client -> entry
    deleteclient: (client) ->

    # :: (date, date) -> [project]
    projects: ->

    # :: project -> project
    saveproject: (project) ->

    # :: project -> entry
    deleteproject: (project) ->