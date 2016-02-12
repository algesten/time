{converge, indexfn, eq, get, nth, pipe, evolve, firstfn, mixin} = require 'fnuc'
{append, adjust} = require './immut'

module.exports = (persist) ->

    # :: * -> projects
    init = do ->
        doinit = (projects) -> {projects}
        fn = pipe persist.projects, doinit
        -> fn() # no arguments

    # :: string -> projects -> boolean
    _eq = (prop) -> (id) -> pipe(get(prop), eq(id))
    eqproject = _eq 'projectId'

    # :: (projects, project) -> projects
    addproject = converge nth(0), pipe(nth(1), persist.saveproject), (model, project) ->
        idx = indexfn model.projects, eqproject(project.projectId)
        evolve model,
            projects: (if idx < 0 then append else adjust(idx)) project

    # :: (projects, entry) -> entry
    decorate = (model, entry) ->
        project = firstfn model.projects, eqproject(entry.projectId)
        mixin entry, {_project:project}

    {init, addproject, decorate}
