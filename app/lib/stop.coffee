
module.exports = (fn) -> (ev) ->
    ev.stopPropagation()
    ev.preventDefault()
    fn ev
