{pipe, iif, I, map, split, pick, mixin, converge, get, nth, always} = require 'fnuc'
elasticsearch = require 'elasticsearch'
shortid       = require 'shortid'

# make a new id
mkid = -> shortid.generate()

# client to es
client = new elasticsearch.Client
    host: 'localhost:9200'
    log: 'trace'
    apiVersion: '1.7'

index = 'totlio'

exists = -> client.indices.exists {index}
create = -> client.indices.create {index, type:'entry'}
putmap = (type) -> ->
    client.indices.putMapping {index, type:type, body:require "./mapping-#{type}"}

# ensure index exists and has the mapping
do pipe (iif exists, I, create), putmap('entry'), putmap('client'), putmap('project')

# turn a es hit into an entry/client/project
toentry   = (hit) -> mixin hit._source, {entryId: hit._id}
toclient  = (hit) -> mixin hit._source, {_id: hit._id}
toproject = (hit) -> mixin hit._source, {_id: hit._id}

spc = split ' '

# the props we use from the client
entryprops   = pick spc 'date modified title time clientId projectId orig'
clientprops  = pick spc 'clientId title'
projectprops = pick spc 'projectId clientId title'

# persistence to database
module.exports = (user) ->

    # all searches are similar with a user filter
    search = (type, sort) -> (query) -> client.search {index, type, body:
        query:filtered:
            filter:term:userId:user.id
            query:query
        size: 10000
        sort:sort}

    doindex  = (type) -> (id, body) -> client.index {index, type, id, body}
    dodelete = (type) -> (id) -> client.delete {index, type, id}

    load: do ->
        mkquery = (start, stop) -> {range:date:{gte:start,lt:stop}}
        toresp  = (res) -> {userId:user.id, entries:map(toentry) res.hits.hits}
        pipe mkquery, search('entry', [date:'desc', projectId:'asc', title:'asc']), toresp

    save: do ->
        bodyof = (entry) -> mixin entryprops(entry), userId:user.id
        toresp = (entry, res) -> mixin entry, {entryId:res._id}
        converge I, converge(get('entryId'), bodyof, doindex('entry')), toresp

    delete: do ->
        toresp = get('found')
        pipe get('entryId'), dodelete('entry'), toresp

    clients: do ->
        mkquery = -> match_all:{}
        toresp  = (res) -> map(toclient) res.hits.hits
        pipe mkquery, search('client', [clientId:'asc']), toresp

    saveclient: do ->
        bodyof = (client) -> mixin clientprops(client), userId:user.id
        toresp = (client, res) -> mixin client, {_id:res._id}
        converge I, converge(get('_id'), bodyof, doindex('client')), toresp

    deleteclient: do ->
        toresp = get('found')
        pipe get('_id'), dodelete('client'), toresp

    projects: do ->
        mkquery = -> match_all:{}
        toresp  = (res) -> map(toproject) res.hits.hits
        pipe mkquery, search('project', [projectId:'asc']), toresp

    saveproject: do ->
        bodyof = (project) -> mixin projectprops(project), userId:user.id
        toresp = (project, res) -> mixin project, {_id:res._id}
        converge I, converge(get('_id'), bodyof, doindex('project')), toresp

    deleteproject: do ->
        toresp = get('found')
        pipe get('_id'), dodelete('project'), toresp
