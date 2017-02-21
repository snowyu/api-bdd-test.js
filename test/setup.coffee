app = require('./app')
yaml = require('js-yaml')
fs   = require('fs')
path = require('path')

cfg = yaml.safeLoad(fs.readFileSync(path.join(__dirname, '/../.api-bdd-test.yml'), 'utf8'))

before (done)->
  port = cfg.server.split(':')[2] or 3001
  app.start('localhost', port, done)

after (done)->
  app.stop(done)
