module.exports = (grunt) ->
  banner = "
/*\n
 * jQuery Rambling Slider\n
 * http://github.com/gonzedge/rambling.slider\n
 * http://ramblinglabs.com\n
 *\n
 * Copyright 2011-2013, Edgar Gonzalez\n
 * Released under the MIT license.\n
 * http://www.opensource.org/licenses/mit-license.php\n
 *\n
 * May 2013\n
 *\n
 * Based on jQuery Nivo Slider by Gilbert Pellegrom\n
*/\n"
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    concat:
      dist:
        src: [
          'src/comments.coffee',
          'src/*extensions.coffee'
          'src/jquery*.coffee'
          'src/rambling*.coffee'
        ]
        dest: 'lib/<%= pkg.name %>.coffee'
    coffee:
      build:
        files:
          'lib/<%= pkg.name %>.js': 'lib/<%= pkg.name %>.coffee'
    jasmine_node:
      extensions: 'coffee'
    uglify:
      dist:
        files:
          'lib/<%= pkg.name %>.min.js': ['lib/<%= pkg.name %>.js']
      options:
        banner: banner
    watch:
      spec:
        files: ['src/**/*.coffee', 'spec/**/*.coffee']
        tasks: ['spec']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-jasmine-node'

  grunt.registerTask 'spec', ['jasmine_node']
  grunt.registerTask 'default', ['concat', 'coffee', 'uglify']
