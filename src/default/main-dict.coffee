Yadda       = require 'yadda'
cson        = require 'cson'

converters  = Yadda.converters


# str_convert = (delimiter, value, next)->
#   value = value.replace /\\(.)/g, '$1'
#   next null, value

str_convert = (value, next)->
  value = value.slice 1, value.length-1
  next null, value

obj_convert = (value, next)->
  try
    value = cson.parseCSONString value
    next null, value
  catch err
    next err


module.exports = (aDictionary)->
  aDictionary
  .define 'string', /(".+"|'.+'|“.+”|‘.+’)/ , str_convert
  # .define 'string', /(['"])([^\1\\]*(?:\\.[^\1\\]*)*)\1/, str_convert
  .define 'identifier', /([\w\x7f-\ufaff]+)/
  .define 'object', /([^\u0000]*)/, obj_convert
  .define 'list', /([^\u0000]*)/, converters.list
  .define 'table', /([^\u0000]*)/, converters.table
  .define 'integer', /(\d+)/, converters.integer
  .define 'int', /(\d+)/, converters.integer
  .define 'float', /([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)/, converters.float
  .define 'date', /(\d{4}-\d{1,2}-\d{1,2}(?:T\d{2}:\d{2}:\d{2}Z)?)/, converters.date
