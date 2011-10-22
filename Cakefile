{exec} = require 'child_process'

String::as_console_message = ->
  "--> #{this}"

log = (string) ->
  console.log string.as_console_message()

error_handler = (err, stdout, stderr) ->
  throw err if err

option '-e', '--environment [ENVIRONMENT_NAME]', 'set the environment for `build`'
task 'build', 'Build the jquery.rambling.slider files', (options) ->
  options.environment or= 'development'

  log 'Building scripts from src/ to lib/'
  exec 'coffee -o lib/ -c src/', (err, stdout, stderr) ->
    log 'Done'
    error_handler(err, stdout, stderr)
    if options.environment is 'production'
      log 'Detected production build'
      invoke 'minify'



task 'minify', 'Minify the generate jquery.rambling.slider files', ->
  log 'Minifying the generated js files'
  exec 'java -jar "/media/d/tools/yuicompressor/yuicompressor-2.4.6.jar" lib/jquery.rambling.slider.js -o lib/jquery.rambling.slider.min.js',
    (err, stdout, stderr) ->
      error_handler(err, stdout, stderr)
      log 'Done'
