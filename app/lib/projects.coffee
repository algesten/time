{converge, indexfn, eq, get, nth, pipe, evolve, firstfn, mixin, split,
iif, pick, always, I} = require 'fnuc'
{append, adjust, remove}     = require './immut'
{tostate, stateis, validate} = require './state'
parseclient  = require './parseclient'
parseproject = require './parseproject'
hasnullvalue = require './hasnullvalues'

spc = split ' '

module.exports = (persist) ->

    # :: * -> model
    init = do ->
        doinit = (projects) -> {projects}
        fn = pipe persist.projects, doinit
        -> fn() # no arguments

    # :: model -> boolean
    isvalid = do ->
        props = spc 'clientId projectId title'
        check = iif pipe(pick(props), hasnullvalue), always(false), always(true)
        pipe get('input'), check

    # :: (model, string, string) -> model
    setnew = do ->
        doset = (model, clientId, projectId, title) ->
            mixin model, {input:{clientId, projectId, title}}
        fn = pipe doset, validate(isvalid)
        (model, projectId, title) ->
            fn model, parseclient(projectId), parseproject(projectId), title

    # :: string -> model -> boolean
    _eq = (prop) -> (id) -> pipe(get(prop), eq(id))
    eqproject = _eq 'projectId'

    # :: (model, project) -> model
    addproject = converge nth(0), pipe(nth(1), persist.saveproject), (model, project) ->
        idx = indexfn model.projects, eqproject(project.projectId)
        evolve model,
            projects: (if idx < 0 then append else adjust(idx)) project

    # :: model, project -> model
    update = (model, project) ->
        idx = indexfn model.projects, eqproject(project.projectId)
        evolve model,
            projects: (if idx < 0 then append else adjust(idx))(project)

    # entries -> entries
    unedit = evolve {editId:always(null), input:always(null)}

    # :: model -> model
    save = do ->
        saveinput = pipe get('input'), persist.saveproject
        dosave = converge I, saveinput, pipe update, unedit
        stateis('valid') pipe tostate('saving'), dosave, tostate('saved')

    # :: (model, entry) -> entry
    decorate = (model, entry) ->
        project = firstfn model.projects, eqproject(entry.projectId)
        mixin entry, {_project:project}

    {init, setnew, addproject, update, save, decorate}
