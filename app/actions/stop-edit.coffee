
module.exports = (entries) -> (state, dispatch) ->
    {fn} = state
    {entries:fn.entries.unedit(entries)}
