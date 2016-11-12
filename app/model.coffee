module.exports =
    user: {}        # received on startup
    fn: {}          # operation functions from lib/entries, lib/projects. init on startup
    info: ''        # user information messages
    running: false  # whether info has a spinning icon
    view: 'log'     # view to view 'login', 'log', 'report', 'register'
    views: [
        {id:'log',      icon:'clock',       href:'/',         sort:1}
        {id:'report',   icon:'paper-plane', href:'/report',   sort:2}
        {id:'register', icon:'vcard',       href:'/register', sort:3}
    ]
    entries:  {}      # input and entry list. see lib/entries
    clients:  {}      # client list. see lib/clients
    projects: {}      # project list. see lib/projects
    report:   {}      # the latest report. see lib/reports