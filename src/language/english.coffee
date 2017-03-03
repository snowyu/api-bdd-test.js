Yadda     = require 'yadda'
patchLang = require './language'

module.exports = patchLang Yadda.localisation.English,
  'before': '[Bb]efore'
  'after': '[Aa]fter'
  'beforeEach': '[Bb]eforeEach'
  'afterEach': '[Aa]fterEach'
