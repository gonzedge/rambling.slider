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
        dest: 'assets/javascripts/jquery.<%= pkg.name %>.coffee'
    coffee:
      build:
        files:
          'assets/javascripts/jquery.<%= pkg.name %>.js': 'assets/javascripts/jquery.<%= pkg.name %>.coffee'
    jasmine_node:
      extensions: 'coffee'
    sass:
      dev:
        files:
          'assets/stylesheets/jquery.<%= pkg.name %>.css': 'assets/stylesheets/jquery.<%= pkg.name %>.scss'
          'assets/stylesheets/style.css': 'assets/stylesheets/style.scss'
      dist:
        options:
          style: 'compressed'
        files:
          'assets/stylesheets/jquery.<%= pkg.name %>.min.css': 'assets/stylesheets/jquery.<%= pkg.name %>.scss'
          'assets/stylesheets/style.min.css': 'assets/stylesheets/style.scss'
    uglify:
      dist:
        files:
          'assets/javascripts/jquery.<%= pkg.name %>.min.js': ['assets/javascripts/jquery.<%= pkg.name %>.js']
      options:
        banner: banner
    watch:
      spec:
        files: ['src/**/*.coffee', 'spec/**/*.coffee']
        tasks: ['spec']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-jasmine-node'

  grunt.registerTask 'spec', ['jasmine_node']
  grunt.registerTask 'default', ['concat', 'coffee', 'uglify', 'sass']
