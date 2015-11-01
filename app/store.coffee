{updated} = require 'trifl'

# actual store
_store = {}

# sets a value in the store
set = (k) -> (v) -> store[k] = v; v
get = (k) -> -> store[k]

# exposed store
module.exports = store = {set, get}

define = (prop) -> Object.defineProperty store, prop,
    enumerable: true
    get: -> _store[prop]
    set: (v) -> _store[prop] = v; updated(prop); v

'user viewstate entries clients reports'.split(' ').forEach define
