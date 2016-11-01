module.exports =
    user: {}        # received on startup
    fn: {}          # operation functions from lib/entries, lib/projects. init on startup
    info: ''        # user information messages
    running: false  # whether info has a spinning icon
    view: 'log'     # view to view 'log', 'report', 'register'
    views: [
        {id:'log',      icon:'clock',       href:'/'}
        {id:'report',   icon:'paper-plane', href:'/report'}
        {id:'register', icon:'vcard',       href:'/register'}
    ]
    entries:{}      # structure with input and entry list. see lib/entries
