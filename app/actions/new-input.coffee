
module.exports = (entries, input) -> (state, dispatch) ->
    {fn} = state
    {entries:fn.entries.setnew(entries, input)}
