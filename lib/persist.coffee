
# persistence to database

module.export =

    # :: (date, date) -> model (anemic)
    # {userId, entries}
    load:     (start, stop) ->

    # :: entry -> entry
    save:     (entry) ->

    # :: (date, date) -> [client]
    clients:  (start, stop) ->

    # :: (date, date) -> [project]
    projects: (start, stop) ->

    # :: (project) -> (project)
    saveproject: (project) ->
