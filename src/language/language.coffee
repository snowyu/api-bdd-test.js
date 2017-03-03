extend = require 'util-ex/lib/_extend'

module.exports = (aLanguage, aVocabulary)->
  oldLocalise = aLanguage.localise
  newLocalise = (keyword)->
    result = @vocabulary[keyword]
    result = @_localise_ keyword unless result
    result
  aLanguage.vocabulary = extend {}, aLanguage.vocabulary, aVocabulary
  if oldLocalise isnt newLocalise
    aLanguage.localise = newLocalise
    aLanguage._localise_ = oldLocalise
  aLanguage

