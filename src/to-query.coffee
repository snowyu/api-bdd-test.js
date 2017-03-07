module.exports = (aQuery)->
  for k,v of aQuery
    aQuery[k] = JSON.stringify v
  aQuery
