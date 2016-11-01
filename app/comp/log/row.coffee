
{tr, td, span} = require('react-elem').DOM

module.exports = (as...) -> tr class:'entryrow', ->
    if as.length == 4
        [title, projectTitle, projectId, time] = as
        date = ''
    else
        [date, title, projectTitle, projectId, time] = as
    td ->
        if date
            span class:'date', date
        span class:'title', title
    td projectTitle
    td projectId
    td time
