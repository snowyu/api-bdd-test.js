isObject  = require 'util-ex/lib/is/type/object'
isArray   = require 'util-ex/lib/is/type/array'
path      = require 'path'

module.exports = (aDictionary)->
  # `this` is the library.

  this.define new RegExp('(GET|HEAD|DEL(?:ETE)?|POST|PATCH|PUT)\\s+$string[:]?\\n$object'), (method, resource, data={})->
    testScope = this.ctx
    resource ?= this.resource
    method = method.toLowerCase()
    request = this.api.request method, resource
    data.head = data.heads || data.head
    data.accept = data.accepts || data.accept
    data.query = data.queries || data.query
    data.field = data.fields || data.field
    data.attach = data.attachs || data.attachments || data.attachment || data.attach
    request = request.send data.data if data.data
    # accepting the canonicalized MIME type name complete with type/subtype, or simply the extension name such as "xml", "json", "png", etc
    # defaults to json
    request = request.set data.head if data.head
    request = request.type data.type if data.type
    request = request.accept data.accept if data.accept
    request = request.query data.query if data.query
    request = request.field data.field if data.field
    if isArray data.attach
      for attach in data.attach
        if isArray(attach) and attach.length >= 2
          attach[1] = path.resolve this.dir, attach[1]
          request = request.attach.apply request, attach
    request
    .then (res)=>
      testScope.result = res
    .catch (err)=>
      testScope.result = err
      return err

  this.define new RegExp('(?:last|prev(?:ious)?)\\s+results?\\s+(?:should\\s+)?(be|is|are|includes?)\\s*[:]?\\s*\\n$object'), (isInclude, data={})->
    testScope = this.ctx
    isInclude = isInclude[2] is 'n'
    if isInclude
      expect(testScope.result.body).to.be.include data
    else
      expect(testScope.result.body).to.be.deep.equal data

  this.define /(?:last|prev(?:ious)?)\s+status\s*(?:code)?\s*(?:should\s+)?((?:be|is)(?:n't|\s+not)?)\s*[:]?\s*$integer/, (isNot, status)->
    testScope = this.ctx
    isNot = isNot.length > 2
    if isNot
      expect(testScope.result.status).to.be.not.equal status
    else
      expect(testScope.result.status).to.be.equal status
    return
