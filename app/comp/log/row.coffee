{I} = require 'fnuc'
{div, span, input} = require('react-elem').DOM
newInput = require '../../actions/new-input'
later = require '../../lib/later'

module.exports = (params) ->
    {title, projectTitle, projectId, time, date,
     key, onClick, orig, beginEdit, dispatch} = params
    console.log beginEdit
    div key:key, class:"entryrow #{clz}", ->
        div key:"#{key}-1st", ->
            if isedit
                input key:"#{key}-1st-input", defaultValue:orig, onKeyDown: (ev) ->
                    el = ev.target
                    # later, so we get the key just typed in el.value
                    later -> dispatch newInput(entries, el.value)
            else
                span class:'date', date if date
                span class:'title', title
        div projectTitle
        div projectId
        div time
    , onClick: onClick ? I
