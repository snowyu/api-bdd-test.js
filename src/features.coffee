Promise   = require 'bluebird'
Yadda     = require 'yadda'
chai      = require 'chai'
path      = require 'path'
firstline = require './first-line'
appRoot   = require 'app-root-path'
requireAll= require 'require-all'
isArray   = require 'util-ex/lib/is/type/array'
isString  = require 'util-ex/lib/is/type/string'
isFunction= require 'util-ex/lib/is/type/function'
Platform  = require 'yadda/lib/Platform'

platform  = Platform()
container = platform.get_container()
# expose assertion library
container.expect = chai.expect
container.assert = chai.assert
container.should = chai.should()
container.testScope = {}

#cleanArray.call array
cleanArray = ->
  i = 0
  while i < @length
    unless @[i]?
      @splice i, 1
    else
      i++
  return this
# cleanArray = (aDeletedValue)->
#   i = 0
#   while i < @length
#     if @[i] is aDeletedValue
#       @splice i, 1
#     else
#       i++
#   return this

resolveDirFromRoot = (aDir, aRootDir)->
  if isArray aDir
    aDir = for v in aDir
      path.resolve aRootDir, v
  else if isString aDir
    aDir = [path.resolve aRootDir, aDir]
  aDir

module.exports = class Features

  constructor: (aOptions = {})->
    return new Features(aOptions) unless this instanceof Features
    @context = aOptions.context
    # @before = aOptions.before
    # @beforeFeature = aOptions.beforeFeature
    # gAfter = aOptions.after
    # gAfterFeature = aOptions.afterFeature
    @lang   = aOptions.lang || aOptions.language
    @useDefaultDict = aOptions.defaultDict
    @useDefaultDict?= true
    @useDefaultLib = aOptions.defaultLib
    @useDefaultLib?= true
    if s=@lang
      @lang = Yadda.localisation[s]
      console.error 'no such default language:', s unless @lang
    @lang   = Yadda.localisation.default unless @lang

    @rootDir     = aOptions.cwd || './test'
    @featuresDir = aOptions.features || path.join @rootDir, 'features'
    @stepsDir    = aOptions.steps || path.join @rootDir, 'steps'
    @libsDir     = aOptions.libs || path.join @rootDir, 'libs'

    @rootDir     = path.resolve appRoot.path, @rootDir

    # featuresDir = resolveDirFromRoot featuresDir, appRoot.path
    # stepsDir    = resolveDirFromRoot stepsDir, appRoot.path
    @libsDir     = resolveDirFromRoot @libsDir, appRoot.path
    @featuresDir = path.resolve appRoot.path, @featuresDir
    @stepsDir    = path.resolve appRoot.path, @stepsDir
    # libsDir     = path.resolve appRoot.path, libsDir

  setLang: (aLangName)->
    if aLangName
      lang = Yadda.localisation[aLangName]
      console.error 'no such language:', aLangName unless lang
    unless lang
      lang = @lang
      aLangName = indexOfObject Yadda.localisation, lang
    Yadda.plugins.mocha.StepLevelPlugin.init(language:lang)
    aLangName

  requireLibs: (aLibsDir, aLibrary, aDictionary, aLanguage, aFilter = /^([^.-].*)[.-](lib[s]?|dict[s]?)\.(js|coffee)$/)->
    aLibsDir = [aLibsDir] if isString aLibsDir
    if isArray aLibsDir
      for dir in aLibsDir
        try requireAll
          dirname: dir
          filter: aFilter
          recursive: false
          resolve: (lib)-> lib.call(aLibrary, aDictionary)
        try requireAll
          dirname: path.join dir, aLanguage.toLowerCase()
          filter: aFilter
          recursive: false
          resolve: (lib)-> lib.call(aLibrary, aDictionary)

  loadDefaultDict: (aFeature, aLibrary, aDictionary, aLangName)->
    # defineDefaultDict(aDictionary, aLangName) if useDefaultDict
    @requireLibs path.join(__dirname, 'default')
      , aLibrary
      , aDictionary
      , aLangName
      , /^([^\.\-].*)[\-\.]dict[s]?\.(js|coffee)$/
  loadDefaultLib: (aFeature, aLibrary, aDictionary, aLangName)->
    # defineDefaultLib.call(aLibrary, aDictionary, aLangName) if useDefaultLib
    @requireLibs path.join(__dirname, 'default')
      , aLibrary
      , aDictionary
      , aLangName
      , /^([^\.\-].*)[\-\.]lib[s]?\.(js|coffee)$/

  # before/after, beforeEach/afterEach
  processHook: (aFeature, yadda, context)->
    yaddaRun = Promise.promisify(yadda.run)
    vHooks =
      before: []
      after: []
      beforeEach: []
      afterEach: []
    scenarios = aFeature.scenarios
    for scenario, i in scenarios
      for k, v of vHooks
        if scenario.annotations[k]
          v.push scenario
          scenarios[i] = undefined
          break
    for k,v of vHooks
      if v.length
        for scenario in v
          container[k] scenario.title, ->
            Promise.mapSeries scenario.steps, (step)->
              testScope.context = context.ctx
              yaddaRun.call yadda, step
    cleanArray.call scenarios



  # run a feature file.
  runFile: (aFile, aLangName)->
    aLang = Yadda.localisation[aLangName]

    featureFile aFile, (feature)=>
      context = dir: path.dirname(aFile), file: aFile, language: aLangName, ctx:{}
      @beforeFeature(feature, context) if isFunction @beforeFeature
      useDefaultDict = feature.annotations.defaultDict
      useDefaultDict?= @useDefaultDict
      useDefaultLib  = feature.annotations.defaultLib
      useDefaultLib ?= @useDefaultLib

      libraries = []
      dictionary = new Yadda.Dictionary()
      library = aLang.library(dictionary)
      @loadDefaultDict(feature, library, dictionary, aLangName) if useDefaultDict
      @loadDefaultLib(feature, library, dictionary, aLangName) if useDefaultLib
      libraries.push library
      @requireLibs @libsDir, library, dictionary, aLangName
      try
        vBaseName = path.basename(aFile).split('.')[0]
        @requireLibs @stepsDir, library, dictionary, aLangName, new RegExp "^(#{vBaseName})(?:\\.#{aLangName})?[.-]step[s]?\\.(?:js|coffee)$", 'i'

      context = Object.assign {}, @context, context

      # the context could be used in the .give etc function: `this.language`
      # yadda = Yadda.createInstance libraries.concat(steps), context
      yadda = Yadda.createInstance libraries, context

      @processHook feature, yadda, context
      # add the describe to each scenario
      scenarios feature.scenarios, (scenario)->
        # add the it to each step
        steps scenario.steps, (step, done)->
          testScope.context = context.ctx
          yadda.run(step, done)

  run: ->
    @before() if isFunction @before
    new Yadda.FeatureFileSearch(@featuresDir).each (file)=>
      # supports: 'xxx.chinese.feature'
      lang = getLanguageFromFileName file
      if !lang
        lang = /^\s*#\s*language:\s*(\S+)/.exec firstline file
        lang = upperCaseFirstLetter lang[1] if lang
      # if !lang ## DO NOT support async for define descriptiono!!!
      #   # supports: the first line of the file is "# language: Chinese"
      #   firstline(file).then (aLine)=>
      #     console.log 'firstline', aLine
      #     lang = /^\s*#\s*language:\s*(\S+)/.exec aLine
      #     if lang
      #       lang = upperCaseFirstLetter lang[1]
      #     @runFile file, @setLang(lang)
      # else
      @runFile file, @setLang(lang)


upperCaseFirstLetter = (word)->word.charAt(0).toUpperCase() + word.slice(1)
getLanguageFromFileName = (aFileName)->
  aFileName = path.basename aFileName
  result = path.extname aFileName.substring 0, aFileName.length - '.feature'.length
  result = upperCaseFirstLetter result.slice(1) if result
  result

indexOfObject = (aObj, aValue)->
  for k,v of aObj
    return k if v is aValue
  return

