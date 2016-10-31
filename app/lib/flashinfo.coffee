
module.exports = (dispatch, info, time=3000) ->
    dispatch -> {info, running:false}
    setTimeout ->
        dispatch -> {info:'', running: false}
    , time
