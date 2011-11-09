{exec} = require 'child_process'
require './build/build_utils'

utils = new BuildUtils

option '-e', '--environment [ENVIRONMENT_NAME]', 'set the environment for `build`'
task 'build', 'Build the jquery.rambling.slider files', (options) ->
  options.environment or= 'development'
  utils.compile ->
    if options.environment is 'production'
      utils.log 'Detected production build'
      invoke 'minify'

task 'minify', 'Minify the generate jquery.rambling.slider files', ->
  utils.log 'Minifying the generated js files'
  exec 'java -jar "build/yuicompressor/yuicompressor-2.4.6.jar" lib/jquery.rambling.slider.js -o lib/jquery.rambling.slider.min.js',
    (err, stdout, stderr) ->
      utils.error_handler err, stdout, stderr
      utils.log 'Done'

task 'spec', 'Run all specs', ->
  utils.log 'Running specs...'
  exec 'jasmine-node --coffee spec/', (err, stdout, stderr) ->
    utils.error_handler err, stdout, stderr
    utils.log 'Done' unless err
