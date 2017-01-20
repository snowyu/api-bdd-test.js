loadConfig = require 'load-config-file'
yaml  = require 'js-yaml'
cson  = require 'cson'

# first search.
loadConfig.register(['.yaml', '.yml'], yaml.safeLoad)
# second search
loadConfig.register('.cson', cson.parseCSONString.bind(cson))
# third search.
loadConfig.register('.json', JSON.parse)

module.exports = loadConfig
