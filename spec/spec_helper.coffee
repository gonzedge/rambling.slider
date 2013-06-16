global.window = require('jsdom').jsdom().createWindow()
global.jQuery = require 'jquery'
global.$ = global.jQuery

require './matchers/jquery.matcher'
require './helpers/slider'
require '../src/array.extensions'
require '../src/string.extensions'
require '../src/rambling.slicer'
require '../src/rambling.boxer'
require '../src/rambling.slice.generator'
require '../src/rambling.box.generator'
require '../src/rambling.slider'
require '../src/jquery.plugins'
require '../src/jquery.plugins.rambling.slider'
require '../src/rambling.slider.transitions'
