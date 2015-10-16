exports.config =

    paths:
        watched: ['app']

    files:
        javascripts:
            joinTo: 'app.js'
        stylesheets:
            joinTo: 'app.css'
        templates:
            joinTo: 'app.js'

    server:
        path: 'lib/brunch-wrapper'
