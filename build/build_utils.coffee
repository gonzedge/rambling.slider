fs = require 'fs'
{exec} = require 'child_process'

class BuildUtils
  log: (string) ->
    console.log string.as_console_message()

  error_handler: (err, stdout, stderr) ->
    console.log stdout if stdout
    console.log stderr if stderr
    throw err if err

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

  compile: (callback) ->
    self = @
    @combine_source_files (content) ->
      self.process content, callback

  combine_source_files: (callback) ->
    self = @
    fs.readdir './src', (err, files) ->
      self.error_handler err
      content = new Array()

      for file, index in files then do (file, index) ->
        unless file.indexOf('.') is 0
          fs.readFile "./src/#{file}", 'utf8', (err, fileContent) ->
            self.error_handler err
            content[content.length] = fileContent

            if index is files.length - 1
              callback content

global.BuildUtils = BuildUtils
