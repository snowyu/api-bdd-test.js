fs = require 'fs'

module.exports = (aFileName, encoding)->
  bufsize = 1024
  buffer = new Buffer(bufsize)
  bufread = 0
  fd = fs.openSync(aFileName,'r')
  position = 0
  eof = false
  data = ''
  encoding = encoding || 'utf8'

  readbuf = ->
    bufread = fs.readSync(fd,buffer,0,bufsize,position)
    position += bufread
    eof = if bufread then false else true
    data += buffer.toString(encoding,0,bufread)

  while not eof
    readbuf()
    i = data.indexOf('\n')
    if (i isnt -1) or eof
      fs.closeSync(fd)
      data = data.slice(0,i) if i >= 0
      break
  return data

