loadConfig = require 'load-config-file'
yaml  = require 'js-yaml'
cs    = require 'coffeescript'

# first search.
loadConfig.register(['.yaml', '.yml'], yaml.safeLoad)
# second search
loadConfig.register(['.cson', 'coffee'], cs.eval.bind(cs))
# third search.
loadConfig.register('.json', JSON.parse)

module.exports = loadConfig
