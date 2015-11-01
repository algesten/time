moment = require 'moment'

{today} = require './datefun'

module.exports = (d) ->
    switch moment(d).diff moment(today()), 'days'
        when 1 then 'Tomorrow'
        when 0 then 'Today'
        when -1 then 'Yesterday'
        when -2 then 'Two days ago'
        when -3 then 'Three days ago'
        else moment(d).format('ll')
