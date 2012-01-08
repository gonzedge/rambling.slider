fs = require 'fs'
{exec} = require 'child_process'
require './string_extensions'
require '../src/string_extensions'
require '../src/array_extensions'

class BuildUtils
  slider_file: 'jquery.rambling.slider.coffee'

  log: (string) ->
    console.log string.as_console_message()

  log_raw: (string) ->
    console.log string

  error_handler: (err, stdout, stderr) ->
    console.log stdout if stdout
    console.log stderr if stderr
    throw err if err

  process: (content, callback) ->
    fs.writeFile "lib/#{@slider_file}", content.join("\n\n"), 'utf8', (err) =>
      @error_handler err
      @log "Building `src/#{@slider_file}`"
      exec "coffee -c lib/#{@slider_file}", (err, stdout, stderr) =>
        @error_handler err, stdout, stderr
        @log "Done. Output in `lib/#{@slider_file.replace(/coffee/, 'js')}`"
        callback()

  compile: (callback) ->
    @combine_source_files (content) =>
      @process content, callback

  file_sorter: (first, second) ->
    return -1 if first is 'comments.coffee'
    return 1 if second is 'comments.coffee'
    return -1 if first < second
    return 1 if first > second
    0

  combine_source_files: (callback) ->
    fs.readdir './src', (err, files) =>
      @error_handler err
      content = []
      contentAdded = 0

      files = files.where (file) -> file.endsWith('.coffee') and not file.startsWith('.')
      files = files.sort @file_sorter

      @log "Combining following files into `src/#{@slider_file}`:\n  #{files.join('\n  ')}"
      for file, index in files then do (file, index) =>
        fs.readFile "./src/#{file}", 'utf8', (err, fileContent) =>
          @error_handler err
          content[index] = fileContent
          contentAdded++

          callback(content) if contentAdded is files.length

global.BuildUtils = BuildUtils
