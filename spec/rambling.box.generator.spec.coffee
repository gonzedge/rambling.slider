global.window = require('jsdom').jsdom().createWindow()
global.jQuery = require 'jquery'
global.$ = global.jQuery

require '../src/rambling.box.generator'

describe 'Rambling Box Generator', ->
  rambling_box_generator = null
  slider = null
  settings = null
  vars = null
  result = null
  RamblingBoxer = ->
  realRamblingBoxer = null

  beforeEach ->
    slider = $ '<div id="slider"><div id="rambling-animation"></div></div>'
    slider.css width: 200, height: 200
    settings = boxCols: 2, boxRows: 2
    vars = {}

    realRamblingBoxer = global.RamblingBoxer
    global.RamblingBoxer = RamblingBoxer
    RamblingBoxer::getRamblingBox = jasmine.createSpy()
    RamblingBoxer::getRamblingBox.andCallFake ->  $ '<div class="rambling-box"></div>'

    rambling_box_generator = new RamblingBoxGenerator slider, settings, vars

  afterEach -> global.RamblingBoxer = realRamblingBoxer

  describe 'when creating the default amount of boxes', ->
    beforeEach ->
      result = rambling_box_generator.createBoxes()

    it 'should return the expected amount of boxes', ->
      expect(result.length).toEqual settings.boxCols * settings.boxRows

    it 'should call the rambling boxer with the correct parameters', ->
      box_width = slider.width() / settings.boxRows
      box_height = slider.height() / settings.boxCols

      for row in [0...settings.boxRows]
        for column in [0...settings.boxCols]
          expect(RamblingBoxer::getRamblingBox).toHaveBeenCalledWith box_width, box_height, row, column, settings, vars

    it 'should call the rambling boxer the expected amount of times', ->
      expect(RamblingBoxer::getRamblingBox.callCount).toEqual settings.boxCols * settings.boxRows

  describe 'when creating a custom amount of boxes', ->
    box_rows = null
    box_cols = null

    beforeEach ->
      box_rows = 3
      box_cols = 6

      result = rambling_box_generator.createBoxes box_cols, box_rows

    it 'should return the expected amount of boxes', ->
      expect(result.length).toEqual box_rows * box_cols

    it 'should call the rambling boxer with the correct parameters', ->
      box_width = Math.round slider.width() / box_rows
      box_height = Math.round slider.height() / box_cols

      for row in [0...box_rows]
        for column in [0...box_cols]
          expect(RamblingBoxer::getRamblingBox).toHaveBeenCalledWith box_height, box_width, row, column, settings, vars

    it 'should call the rambling boxer the expected amount of times', ->
      expect(RamblingBoxer::getRamblingBox.callCount).toEqual box_rows * box_cols

