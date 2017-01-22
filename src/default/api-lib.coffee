isObject  = require 'util-ex/lib/is/type/object'
isArray   = require 'util-ex/lib/is/type/array'
path      = require 'path'
cson      = require 'cson'

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

  # Yadda can not support ignore case: /xxx/i
  this.define /login\s+user:\s*$string\s*,\s*passw(?:or)?d:\s*$string/, (username, password)->
    testScope = this.ctx
    this.api.login
      username: username
      password: password
    .then (res)=>
      testScope.result = res
      return
    .catch (err)=>
      testScope.result = err
      return err

  this.define /logout\s+user|(?:exit|quit)\s+system/, ->
    testScope = this.ctx
    this.api.logout()
    .then (res)=>
      testScope.result = res
      return
    .catch (err)=>
      testScope.result = err
      return err

  # keep the result of 'body.id' to 'myvar'
  this.define /(?:keep|store|save)\s+(?:the\s+)?result\s+of\s+$string\s+(?:in)?to\s+$string/, (aKey, aToVar)->
    vResult = this.ctx.result
    if aKey? and aKey.length and vResult?
      aKey = aKey.split '.'
      for k in aKey
        vResult = vResult[k] if vResult?
    this.ctx[aToVar] = vResult
    return

  # keep the result to 'myvar'
  this.define /(?:keep|store|save)\s+(?:the\s+)?result\s+(?:in)?to\s+$string/, (aToVar)->
    this.ctx[aToVar] = this.ctx.result
    return


  # expect the stored "mvar" equal xxx
  this.define /expect\s+(?:the\s+)(?:stored|kept|saved)\s+$string(?:\s+is|be|are|to)?\s+(not\s+)?(above|below|most|least|equa?l?|(?:include|contain)(?:\s+key)?|[><!]=|[<=>])\s*(.+)$/, (aKey, aNot, aOp, aValue)->
    aValue = cson.parseCSONString aValue
    myExpect = expect(this.ctx[aKey]).to.be
    myExpect = myExpect.not if aNot?
    switch aOp
      when 'least', '>='
        myExpect.least aValue
      when 'most', '<='
        myExpect.most aValue
      when 'above', '>'
        myExpect.above aValue
      when 'below', '<'
        myExpect.below aValue
      when 'equal', 'equ', '='
        myExpect.equal aValue
      when  '!='
        myExpect.not.equal aValue
      else
        if aOp.slice(aOp.length-3) is 'key'
          myExpect.include.keys aValue
        else
          myExpect.include aValue
    return

  this.define /expect\s+(?:the\s+)(?:stored|kept|saved)\s+$string(?:\s+is|be|are|to)?\s+(not\s+)?(above|below|most|least|equa?l?|(?:include|contain)(?:\s+key)?|[><!]=|[<=>])[:]\n$object/, (aKey, aNot, aOp, aValue)->
    myExpect = expect(this.ctx[aKey]).to.be
    myExpect = myExpect.not if aNot?
    switch aOp
      when 'least', '>='
        myExpect.least aValue
      when 'most', '<='
        myExpect.most aValue
      when 'above', '>'
        myExpect.above aValue
      when 'below', '<'
        myExpect.below aValue
      when 'equal', 'equ', '='
        myExpect.equal aValue
      when '!='
        myExpect.not.equal aValue
      else
        myExpect = myExpect.not if aOp[0] is 'n'
        if aOp.slice(aOp.length-3) is 'key'
          myExpect.include.keys aValue
        else
          myExpect.include aValue
    return

  this.define /expect\s+((?:not\s+)?exist)(?:the\s+)?(?:stored|kept|saved)\s+$string/, (aExists, aKey)->
    if aExists[0] isnt 'n'
      expect(this.ctx[aKey]).to.be.exist
    else
      expect(this.ctx[aKey]).not.to.be.exist
