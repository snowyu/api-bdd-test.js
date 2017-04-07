cs          = require 'coffeescript'
vm          = require? 'vm'

createContext = vm.Script.createContext ? vm.createContext

module.exports = (value)->
  sandbox = createContext(testScope.context)
  sandbox.require = require
  sandbox.console = console
  cs.eval value, {sandbox}
