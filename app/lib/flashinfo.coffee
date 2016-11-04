
module.exports = (dispatch, info, time=1000) ->
    dispatch -> {info, running:false}
    setTimeout ->
        dispatch -> {info:'', running: false}
    , time
