Yadda     = require 'yadda'
patchLang = require './language'

module.exports = patchLang Yadda.localisation.Chinese,
  'before': '[Bb]efore|功能前提'
  'after': '[Aa]fter|功能收[尾工关]'
  'beforeEach': '[Bb]eforeEach|(?:场景|大纲|剧本)前提'
  'afterEach': '[Aa]fterEach|(?:场景|大纲|剧本)收[尾工关]'
  'beforeStep': '[Bb]eforeStep|步骤前提'
  'afterStep': '[Aa]fterStep|步骤收[尾工关]'
