path        = require 'path'
appRoot     = require 'app-root-path'
loadConfig  = require './load-config'
# Features    = require './features'
Features    = require './api-features'

Features loadConfig.loadSync path.resolve appRoot.path, '.api-bdd-test'
.run()
