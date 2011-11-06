fs = require 'fs'
{exec} = require 'child_process'
require './build/string_extensions'

class BuildUtils
  log: (string) ->
    console.log string.as_console_message()

  error_handler: (err, stdout, stderr) ->
    throw err if err
    console.log stdout if stdout
    console.log stderr if stderr

  process: (content, callback) ->
    self = @
    sliderFile = 'jquery.rambling.slider.coffee'
    fs.writeFile "lib/#{sliderFile}", content.join("\n\n"), 'utf8', (err) ->
      self.error_handler err
      self.log 'Building scripts from src/ to lib/'
      exec "coffee -c lib/#{sliderFile}", (err, stdout, stderr) ->
        self.error_handler err, stdout, stderr
        fs.unlink "lib/#{sliderFile}", (err) ->
          self.error_handler err
          self.log 'Done'
          callback()

utils = new BuildUtils

option '-e', '--environment [ENVIRONMENT_NAME]', 'set the environment for `build`'
task 'build', 'Build the jquery.rambling.slider files', (options) ->
  options.environment or= 'development'

  fs.readdir './src', (err, files) ->
    utils.error_handler err
    content = new Array()

    for file, index in files then do (file, index) ->
      if file.indexOf('.') isnt 0
        fs.readFile "./src/#{file}", 'utf8', (err, fileContent) ->
          utils.error_handler err
          content[content.length] = fileContent

          if index is files.length - 1
            utils.process content, ->
              if options.environment is 'production'
                utils.log 'Detected production build'
                invoke 'minify'

task 'minify', 'Minify the generate jquery.rambling.slider files', ->
  utils.log 'Minifying the generated js files'
  exec 'java -jar "/media/d/tools/yuicompressor/yuicompressor-2.4.6.jar" lib/jquery.rambling.slider.js -o lib/jquery.rambling.slider.min.js',
    (err, stdout, stderr) ->
      utils.error_handler err, stdout, stderr
      utils.log 'Done'
