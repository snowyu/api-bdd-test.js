isObject  = require 'util-ex/lib/is/type/object'
path      = require 'path'
cson      = require 'cson'

module.exports = (aDictionary)->
  # `this` is the library.
  #console.log
  # 新建资源:ResName
  # a:1,b:2
  resNameRegEx    = '[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?'
  resResultRegEx  = '[的其]?(?:内容|结果)[为是]?\\n$object'
  res4DataRegEx   = resNameRegEx + '\\s*'+ resResultRegEx

  this.define new RegExp('[新创]建资源\\s*'+res4DataRegEx), (resource, data)->
    testScope = this.ctx
    resource ?= this.resource
    this.api.post resource, data:data
    .then (res)=>
      testScope.result = res
    .catch (err)=>
      testScope.result = err
      return err

  this.define new RegExp('[编修][辑改]资源\\s*'+res4DataRegEx), (resource, data)->
    testScope = this.ctx
    resource ?= this.resource
    this.api.put resource, data:data
    .then (res)=>
      testScope.result = res
    .catch (err)=>
      testScope.result = err
      return err

  this.define new RegExp('删[除掉](?:id|ID|编号)[为是:：]?$string的?资源\\s*'+ resNameRegEx), (id, resource)->
    testScope = this.ctx
    resource ?= this.resource
    id = path.join(resource, encodeURIComponent id) if resource
    this.api.delete id
    .then (res)=>
      testScope.result = res
    .catch (err)=>
      testScope.result = err
      return err

  this.define new RegExp('检[查测]是否存在资源\\s*'+resNameRegEx + '\\s*[:：]?$string'), (resource, id)->
    testScope = this.ctx
    resource ?= this.resource
    id = path.join(resource, encodeURIComponent id) if resource
    this.api.head id
    .then (res)=>
      testScope.result = res
      return
    .catch (err)=>
      testScope.result = err
      return err

  this.define /上次[的]?(?:状态[码]?|status)[为是：:]\s*$identifier/, (data)->
    testScope = this.ctx
    data = '200' if data is 'ok'
    expect(testScope.result.status+'').to.be.equal data
    return


  this.define /上次[的]?(?:结果|body)([为是：:]|包[括含][：:]?)\s*\n$object/, (isInclude, data)->
    testScope = this.ctx
    if isInclude[0] is '包'
      expect(testScope.result.body).to.be.include data
    else
      expect(testScope.result.body).to.be.deep.equal data

  # 希望获得id为"id"的资源:bottle，其结果为
  this.define new RegExp('[希期]望(?:获[取得]|取[得]?)(?:id|ID|编号)[为是:：]?$string的?资源\\s*'+res4DataRegEx), (id, resource, data)->
    resource ?= this.resource
    id = path.join(resource, encodeURIComponent id) if resource
    this.api.get id
    .then (res)=>
      expect(res.body).to.be.include data
      return
    # .catch (err)=>
    #   console.log 'err',err
    #   expect(err).to.be.include data
    #   return err

  this.define new RegExp('(?:获[取得]|取得?)资源\\s*'+resNameRegEx + '\\s*[:：]?$string'), (resource, id)->
    testScope = this.ctx
    resource ?= this.resource
    id = path.join(resource, encodeURIComponent id) if resource
    this.api.get id
    .then (res)=>
      testScope.result = res
      return
    .catch (err)=>
      testScope.result = err
      return err

  this.define new RegExp('([不]?会?存在|没有?|有)(?:id|ID|编号)[为是:：]?$string的?资源\\s*'+resNameRegEx), (isExists, id, resource)->
    isExists = isExists[0] isnt '不' and isExists[0] isnt '没'
    resource ?= this.resource
    id = path.join(resource, encodeURIComponent id) if resource
    this.api.head id
    .then (res)=>
      if res.status is 204 or res.status is 200
        expect(isExists).to.be.true
      else if res.status is 404
        expect(isExists).to.be.false
      else
        throw new Error 'Call isExists API Error:' + status
      return

  this.define /登[录陆]\s*用户[:：]\s*$string\s*[,，]\s*密码[:：]\s*$string/, (username, password)->
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

  this.define /注销用户|退出系统/, ->
    testScope = this.ctx
    this.api.logout()
    .then (res)=>
      testScope.result = res
      return
    .catch (err)=>
      testScope.result = err
      return err

  # 记住结果的"body.id"到"myvar"
  this.define /(?:记[住下忆]?|保[存留])结果的$string(?:属性)?到[:：]?$string/, (aKey, aToVar)->
    vResult = this.ctx.result
    if aKey? and aKey.length and vResult?
      aKey = aKey.split '.'
      for k in aKey
        vResult = vResult[k] if vResult?
    this.ctx[aToVar] = vResult
    return

  # 记住结果到"myvar"
  this.define /(?:记[住下忆]?|保[存留])结果到[:：]?$string/, (aToVar)->
    this.ctx[aToVar] = this.ctx.result
    return

  # 期望保留的"mvar"等于xxx
  this.define /[期希]望(?:记[住下忆]?|保[存留])的\s*$string\s*(不)?((?:大于|小于)等于|至[少多]|等于|是|包[含括](?:key)?|[><!]=|[<=>])\s*(.+)$/, (aKey, aNot, aOp, aValue)->
    aValue = cson.parseCSONString aValue
    myExpect = expect(this.ctx[aKey]).to.be
    myExpect = myExpect.not if aNot?
    switch aOp
      when '大于等于', '>=', '至少'
        myExpect.least aValue
      when '小于等于', '<=', '至多'
        myExpect.most aValue
      when '大于', '>'
        myExpect.above aValue
      when '小于', '<'
        myExpect.below aValue
      when '等于', '=', '是'
        myExpect.equal aValue
      else
        if aOp.slice(aOp.length-3) is 'key'
          myExpect.include.keys aValue
        else
          myExpect.include aValue
    return

  this.define /[期希]望(?:记[住下忆]?|保[存留])的\s*$string\s*(不)?((?:大于|小于)等于|至[少多]|等于|是|包[含括](?:key)?|[><!]=|[<=>])[:：]\n$object/, (aKey, aNot, aOp, aValue)->
    myExpect = expect(this.ctx[aKey]).to.be
    myExpect = myExpect.not if aNot?
    switch aOp
      when '大于等于', '>=', '至少'
        myExpect.least aValue
      when '小于等于', '<=', '至多'
        myExpect.great aValue
      when '大于', '>'
        myExpect.above aValue
      when '小于', '<'
        myExpect.below aValue
      when '等于', '=', '是'
        myExpect.equal aValue
      else
        if aOp.slice(aOp.length-3) is 'key'
          myExpect.include.keys aValue
        else
          myExpect.include aValue
    return

  this.define /[期希]望(不?存在)(?:记[住下忆]?|保[存留]的)?\s*$string$/, (aExists, aKey)->
    if aExists[0] isnt '不'
      expect(this.ctx[aKey]).to.be.exist
    else
      expect(this.ctx[aKey]).not.to.be.exist
