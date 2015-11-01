{mixin, pipe, get} = require 'fnuc'

{client, index} = require './elasticclient'

run = (body) -> client.search {index, 'entry', body}

module.exports = (user) ->

    limit = (from, to) ->
        query:filtered:
            query:match_all:{}
            filter:bool:must:[
                {term:userId:user.id}
                {range:date:{gte:from,lt:to}}
            ]

    aggs = aggs:
        projects:
            terms:field:'projectId'
            aggs:
                seconds:sum:field:'time'
                perweek:
                    date_histogram:
                        field:'date'
                        interval:'week'
                    aggs:
                        seconds:sum:field:'time'

    rearrange = pipe get('aggregations'), (aggs) ->
        projects:aggs.projects.buckets.map (p) ->
            projectId:p.key
            seconds:p.seconds.value
            perweek:p.perweek.buckets.map (w) ->
                date:w.key_as_string
                seconds:w.seconds.value

    pipe limit, mixin(size:0), mixin(aggs), run, rearrange
