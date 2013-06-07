module.exports = (grunt) ->
  banner = '<%= grunt.file.read("assets/javascripts/comments.js").split("\\n").slice(0, 14).join("\\n") %>'
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    concat:
      sass:
        options:
          banner: banner
        src: [
          'assets/stylesheets/<%= pkg.name %>.scss'
        ]
        dest: 'assets/stylesheets/jquery.<%= pkg.name %>.scss'
      coffee:
        options:
          banner: grunt.file.read 'src/comments.coffee'
        src: [
          'src/*extensions.coffee'
          'src/jquery*.coffee'
          'src/rambling*.coffee'
        ]
        dest: 'assets/javascripts/jquery.<%= pkg.name %>.coffee'
    coffee:
      build:
        files:
          'assets/javascripts/jquery.<%= pkg.name %>.js': 'assets/javascripts/jquery.<%= pkg.name %>.coffee'
      comments:
        files:
          'assets/javascripts/comments.js': 'src/comments.coffee'
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
    shell:
      delete:
        command: 'rm assets/javascripts/comments.js'
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
  grunt.loadNpmTasks 'grunt-shell'

  grunt.registerTask 'spec', ['jasmine_node']
  grunt.registerTask 'default', [
    'concat:coffee',
    'coffee',
    'uglify',
    'concat:sass',
    'sass',
    'shell',
    'jasmine_node'
  ]
