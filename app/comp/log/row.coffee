
{div, span} = require('react-elem').DOM

module.exports = ({title, projectTitle, projectId, time, date, key}) ->
    div key:key, class:'entryrow', ->
        div ->
            if date
                span class:'date', date
            span class:'title', title
        div projectTitle
        div projectId
        div time
