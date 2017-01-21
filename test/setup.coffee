app = require('./app')

before (done)->
  app.start('localhost', 3000, done)

after (done)->
  app.stop(done)
