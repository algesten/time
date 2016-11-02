
module.exports = (entries, entryId) -> (state) ->
    {fn} = state
    {entries:fn.entries.edit(entries, entryId)}
