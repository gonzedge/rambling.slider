{exec} = require 'child_process'
require './build/build_utils'

utils = new BuildUtils
compile = null
minify = null

option '-e', '--environment [ENVIRONMENT_NAME]', 'set the environment for `build`'
option '-v', '--verbose', 'give more information about the tests is being run'
option '-t', '--teamcity', 'format the tests output for teamcity'

task 'build', 'Run the complete build', (options) ->
  compile = -> invoke 'compile'
  invoke 'spec'

task 'compile', 'Compile the jquery.rambling.slider files', (options) ->
  options.environment or= 'development'
  utils.compile ->
    if options.environment is 'production'
      utils.log 'Detected production build'
      invoke 'minify'

task 'minify', 'Minify the generate jquery.rambling.slider files', ->
  utils.log 'Minifying files in `lib/`'
  exec 'java -jar "build/yuicompressor/yuicompressor-2.4.6.jar" lib/jquery.rambling.slider.js -o lib/jquery.rambling.slider.min.js',
    (err, stdout, stderr) ->
      utils.error_handler err, stdout, stderr
      utils.log 'Done'

task 'spec', 'Run all specs', (options) ->
  utils.log 'Running specs...'
  exec "jasmine-node --coffee #{'--verbose ' if options.verbose}#{'--teamcity ' if options.teamcity} spec/", (err, stdout, stderr) ->
    utils.log_raw stdout
    utils.log "Error: #{stderr}" if stderr
    unless err
      utils.log 'Done'
      compile() if compile
