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
        permonth:
            date_histogram:
                field:'date'
                interval:'month'
            aggs:
                seconds:sum:field:'time'
                projects:
                    terms:field:'projectId'
                    aggs:seconds:sum:field:'time'
                perclient:
                    terms:field:'clientId'
                    aggs:seconds:sum:field:'time'
                perweek:
                    date_histogram:
                        field:'date'
                        interval:'week'
                    aggs:
                        seconds:sum:field:'time'
                        projects:
                            terms:field:'projectId'
                            aggs:seconds:sum:field:'time'

    rearrange = pipe get('aggregations'), (aggs) ->
        permonth:aggs.permonth.buckets.map (m) ->
            date:m.key
            seconds:m.seconds.value
            projects:m.projects.buckets.map (p) ->
                projectId:p.key
                seconds:p.seconds.value
            perclient:m.perclient.buckets.map (c) ->
                clientId:c.key
                seconds:c.seconds.value
            perweek:m.perweek.buckets.map (w) ->
                date:w.key
                seconds:w.seconds.value
                projects:w.projects.buckets.map (p) ->
                    projectId:p.key
                    seconds:p.seconds.value

    pipe limit, mixin(size:0), mixin(aggs), run, rearrange
