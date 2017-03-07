Yadda       = require 'yadda'
cson        = require '../cson-string'

converters  = Yadda.converters
# createContext = vm.Script.createContext ? vm.createContext

# str_convert = (delimiter, value, next)->
#   value = value.replace /\\(.)/g, '$1'
#   next null, value

str_convert = (value, next)->
  delimiter = value[0]
  value = value.slice 1, value.length-1
  console
  if delimiter is '`'
    cstype_convert value, next
  else
    next null, value

cstype_convert = (value, next)->
  try
    value = cson value
    next null, value
  catch err
    next err


module.exports = (aDictionary)->
  aDictionary
  .define 'string', /(".+"|'.+'|“.+”|‘.+’|`.+`)/ , str_convert
  # .define 'string', /(['"])([^\1\\]*(?:\\.[^\1\\]*)*)\1/, str_convert
  .define 'identifier', /([\w\x7f-\ufaff]+)/
  .define 'object', /([^\u0000]*)/, cstype_convert
  # .define 'cstype', /`(.+)`/, cstype_convert
  .define 'list', /([^\u0000]*)/, converters.list
  .define 'table', /([^\u0000]*)/, converters.table
  .define 'integer', /(\d+)/, converters.integer
  .define 'int', /(\d+)/, converters.integer
  .define 'float', /([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)/, converters.float
  .define 'date', /(\d{4}-\d{1,2}-\d{1,2}(?:T\d{2}:\d{2}:\d{2}Z)?)/, converters.date
