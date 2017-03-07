cs          = require 'coffee-script'
vm          = require? 'vm'

createContext = vm.Script.createContext ? vm.createContext

module.exports = (value)->
  sandbox = createContext(testScope.context)
  sandbox.require = require
  cs.eval value, {sandbox}