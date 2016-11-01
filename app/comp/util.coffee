
stopped = (fn) -> (ev) ->
    ev.stopPropagation()
    ev.preventDefault()
    fn(ev)


module.exports = {stopped}
