{converge, indexfn, eq, get, nth, pipe, evolve, firstfn, mixin, split,
iif, pick, always, I, match, aand, call, keyval, sort} = require 'fnuc'
{append, adjust, remove}     = require './immut'
{tostate, stateis, validate} = require './state'
parseclient  = require './parseclient'
parseproject = require './parseproject'
hasnullvalue = require './hasnullvalues'

spc = split ' '

module.exports = (persist) ->

    # :: * -> model
    init = do ->
        doinit = (projects) -> {projects, state:null, input:null, editId:null}
        fn = pipe persist.projects, doinit
        -> fn() # no arguments

    # :: string -> model -> boolean
    _eq = (prop) -> (id) -> pipe(get(prop), eq(id))
    eqproject = _eq 'projectId'

    # :: (model) -> boolean
    isedit = (model) -> !!model?.editId

    # :: model -> string|null
    isnotvalid = do ->
        props = spc 'clientId projectId title'
        notnull = pipe get('input'), pick(props), iif hasnullvalue, always('nullval'), always(null)
        doexists = (model) -> indexfn(model.projects, eqproject(model.input.projectId)) >= 0
        notexists = (model) -> 'exists' if !isedit(model) and doexists(model)
        converge notexists, notnull, (a, b) -> a ? b

    mkeyval = (k, v) -> if v then keyval(k,v) else null

    # :: (model, string, string) -> model
    setnew = do ->
        doset = (model, clientId, projectId, title) ->
            mixin model, input:mixin({clientId, projectId, title}, mkeyval('_id', model?.input?._id))
        splitter = pipe match(/^\s*(\w{3}\d{1,4})\s*(.*?)\s*$/), iif I, I, always([])
        fn = pipe doset, validate(isnotvalid)
        (model, txt) ->
            [_, idpart, title] = splitter txt
            fn model, parseclient(idpart), parseproject(idpart), title

    # :: (model, project) -> model
    addproject = converge nth(0), pipe(nth(1), persist.saveproject), (model, project) ->
        idx = indexfn model.projects, eqproject(project.projectId)
        evolve model,
            projects: (if idx < 0 then append else adjust(idx)) project

    # :: model, project -> model
    update = (model, project) ->
        idx = indexfn model.projects, eqproject(project.projectId)
        sorted = sort (c1, c2) -> c1.projectId.localeCompare c2.projectId
        evolve model,
            projects: pipe (if idx < 0 then append else adjust(idx))(project), sorted

    # :: (model, string) -> model
    edit = do ->
        finder = pipe nth(1), eqproject, firstfn
        projectsof = pipe nth(0), get('projects')
        toinput  = (project) -> {editId:project?.projectId, input:project}
        getinput = converge finder, projectsof, pipe call, toinput
        converge I, getinput, pipe mixin, iif get('input'), tostate('valid'), tostate('')

    # model -> model
    unedit = evolve {input:always(null), state:always(null), editId:always(null)}

    # :: model -> model
    save = do ->
        saveinput = pipe get('input'), persist.saveproject
        dosave = converge I, saveinput, pipe update, unedit
        stateis('valid') pipe tostate('saving'), dosave, tostate('saved')

    # :: (model) -> (entry) -> entry
    decorate = (model) -> (entry) ->
        project = firstfn (model?.projects ? []), eqproject(entry.projectId)
        mixin entry, {_project:project}

    # :: model, project -> model
    erase = (model, project) ->
        idx = indexfn model.projects, eqproject(project.projectId)
        evolve model, {projects:remove(idx)}

    # :: (model, project) -> model
    delet = do ->
        eraseif = iif nth(2), erase, nth(0)
        converge nth(0), nth(1), pipe(nth(1), persist.deleteproject), pipe eraseif, unedit

    {init, setnew, addproject, update, save, edit, decorate, erase, delet}
