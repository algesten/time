
module.exports = groupby = (fn) -> (as) ->
    res = []; gr = null; cur = null
    for a in as
        if (c = fn a) != cur
            res.push(gr = []); cur = c;
        gr.push a
    res
