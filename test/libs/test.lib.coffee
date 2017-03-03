module.exports = (aDictionary)->

  this.given 'this is a general lib', ->

  this.define /increment\s+$identifier/, (aKey)->
    testScope = this.ctx
    if testScope[aKey] then testScope[aKey]++ else testScope[aKey] = 1
    console.log 'incr', aKey, testScope[aKey]
    return
