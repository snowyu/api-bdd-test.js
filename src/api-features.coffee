inherits  = require 'inherits-ex'
Api       = require 'loopback-supertest/lib/abstract-api'
Features  = require './features'

module.exports = class ApiFeatures

  inherits ApiFeatures, Features

  constructor: (aOptions = {})->
    return new ApiFeatures(aOptions) unless this instanceof ApiFeatures
    @server   = aOptions.server
    @root     = aOptions.root || aOptions.app
    @resource = aOptions.res || aOptions.resource
    super

  beforeFeature: (feature, context)->
    context.resource = feature.annotations.res || feature.annotations.resource || @resource
    context.root = feature.annotations.root || feature.annotations.app || @root
    context.server = feature.annotations.server || @server
    context.api = Api context.server, context.root#, context.resource
    return
  loadDefaultLib: (aFeature, aLibrary, aDictionary, aLangName)->
    super
  loadDefaultDict: (aFeature, aLibrary, aDictionary, aLangName)->
    super
