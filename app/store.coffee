{updated} = require 'trifl'

# actual store
_store = {}

# sets a value in the store
set = (k) -> (v) -> store[k] = v; v

# exposed store
module.exports = store = {set}

define = (prop) -> Object.defineProperty store, prop,
    enumerable: true
    get: -> _store[prop]
    set: (v) -> _store[prop] = v; updated prop

'user viewstate model clients'.split(' ').forEach define
