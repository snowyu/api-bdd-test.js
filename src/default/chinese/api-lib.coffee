isObject      = require 'util-ex/lib/is/type/object'
isString      = require 'util-ex/lib/is/type/string'
path          = require 'path.js/lib/posix'
cson          = require '../../cson-string'
toQuery       = require '../../to-query'

module.exports = (aDictionary)->
  # `this` is the library.
  #console.log
  # 新建资源:ResName
  # a:1,b:2
  resNameRegEx    = '[:：]?[(（‘\'“" ]$identifier(?:[)），,.。’”"\' ]|$)'
  resResultRegEx  = '[的其]?(?:内容|结果)[为是]?[:：]?$object'
  res4DataRegEx   = resNameRegEx + '[,，.。]?\\s*'+ resResultRegEx

  this.define new RegExp('列[出举]资源\\s*'+resNameRegEx), (resource)->
    testScope = this.ctx
    resource ?= this.resource
    this.api.get resource
    .then (res)=>
      testScope.result = res
      return
    .catch (err)=>
      testScope.result = err
      return err

  this.define new RegExp('[搜查][索询找]资源\\s*'+resNameRegEx+'[,，.。]?\\s*按?(?:指定|如下)?(?:条件|设置)[:：]?$object'), (resource, filter)->
    testScope = this.ctx
    resource ?= this.resource
    result = this.api.get resource
    result = result.query toQuery filter if filter
    result.then (res)=>
      testScope.result = res
      return
    .catch (err)=>
      testScope.result = err
      return err

  this.define new RegExp('[新创]建资源\\s*'+res4DataRegEx), (resource, data)->
    testScope = this.ctx
    resource ?= this.resource
    this.api.post resource, data:data
    .then (res)=>
      testScope.result = res
    .catch (err)=>
      testScope.result = err
      return err

  this.define new RegExp('[新创]建资源\\s*'+resNameRegEx+'成功[,，.。]?\\s*'+ resResultRegEx), (resource, data)->
    testScope = this.ctx
    resource ?= this.resource
    this.api.post resource, data:data
    .then (res)=>
      testScope.result = res
      return if res.status is 200 or res.status is 201
      console.log res
      expect(res.status).to.be.equal 200
    .catch (err)=>
      testScope.result = err
      console.log err
      expect(err).to.be.null
      return err

  this.define new RegExp('[编修][辑改](?:id|ID|编号)[为是:：]?$string的?资源\\s*'+res4DataRegEx), (id, resource, data)->
    testScope = this.ctx
    resource ?= this.resource
    id = path.join(resource, encodeURIComponent id) if resource
    this.api.put id, data:data
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

  this.define /上次[的]?(?:状态[码]?|status)[为是][：:]?\s*$identifier/, (data)->
    testScope = this.ctx
    data = '200' if data is 'ok'
    console.log(testScope.result) if testScope.result.status+'' isnt data
    expect(testScope.result.status+'').to.be.equal data
    return

  # this.define /上次[的]?(?:状态[码]?|status)匹配[：:]?$object/, (data)->
  #   testScope = this.ctx
  #   result = matchPattern testScope.result.status, data
  #   if result
  #     console.log(testScope.result)
  #     throw result
  #   return

  # this.define /上次[的]?(?:结果|body)匹配[：:]?$match/, (pattern)->
  #   testScope = this.ctx
  #   result = matchPattern testScope.result.body, pattern
  #   if result
  #     console.log(testScope.result)
  #     console.log pattern, testScope.result.body
  #     throw new Error result
  #   return

  this.define /上次[的]?(?:结果|body)([为是]|包[括含]?)[：:]?\s*$object/, (isInclude, data)->
    testScope = this.ctx
    if isInclude[0] is '包'
      expect(testScope.result.body).to.be.containSubset data
    else
      expect(testScope.result.body).to.be.deep.equal data

  # 希望获得id为"id"的资源:bottle，其结果（包含）为
  this.define new RegExp('[获取拿得][取得到](?:id|ID|编号)[为是:：]?$string的?资源\\s*'+resNameRegEx + '[,，.。]?\\s*[的其]?(?:内容|结果)(包[含括]|[为是等]同?于?)[:：]?$object'), (id, resource, aInclude, data)->
    resource ?= this.resource
    id = path.join(resource, encodeURIComponent id) if resource
    aInclude = aInclude[0] is '包'
    this.api.get id
    .then (res)=>
      if aInclude
        expect(res.body).to.be.containSubset data
      else
        expect(res.body).to.be.deep.equal data
      return
    # .catch (err)=>
    #   console.log 'err',err
    #   expect(err).to.be.include data
    #   return err

  # 获得id为"id",过滤条件为"xxx"的资源:bottle
  this.define new RegExp('[获取拿得][取得到](?:id|ID|编号)[为是:：]?$string[,，]?\\s*过?滤?条件[为是:：]?$string的?资源\\s*'+resNameRegEx), (id, filter, resource)->
    testScope = this.ctx
    resource ?= this.resource
    # return
    filter = JSON.stringify cson filter if isString(filter) and filter.length
    id = path.join(resource, encodeURIComponent id) if resource
    result = this.api.get id
    result.query filter: filter if filter
    result
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

  # 记住`result.body[0].id`到"myvar"
  this.define /(?:记[住下忆]?|保[存留])$string到[:：]?$string/, (aKey, aToVar)->
    this.ctx[aToVar] = aKey
    return


  # 记住结果的"body.id"到"myvar"
  this.define /(?:记[住下忆]?|保[存留])结果的$string(?:属性)?到[:：]?$string/, (aKey, aToVar)->
    vResult = this.ctx.result
    if isString(aKey) and aKey.length and vResult?
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
  this.define /(?:记[住下忆]?|保[存留])的\s*$string\s*(不)?((?:大于|小于)等于|至[少多]|等于|是|包[含括](?:key)?|[><!]=|[<=>])\s*(.+)$/, (aKey, aNot, aOp, aValue)->
    aValue = cson aValue
    myExpect = expect(aKey).to.be
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
          myExpect.containSubset aValue
    return

  this.define /(?:记[住下忆]?|保[存留])的\s*$string\s*(不)?((?:大于|小于)等于|至[少多]|等于|是|包[含括](?:key)?|[><!]=|[<=>])[:：]$object/, (aKey, aNot, aOp, aValue)->
    myExpect = expect(aKey).to.be
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
          myExpect.containSubset aValue
    return

  this.define /(不?存在)(?:记[住下忆]?|保[存留]的)?\s*$string$/, (aExists, aKey)->
    if aExists[0] isnt '不'
      expect(this.ctx[aKey]).to.be.exist
    else
      expect(this.ctx[aKey]).not.to.be.exist
