global.window = require('jsdom').jsdom().createWindow()
global.jQuery = require 'jquery'
global.$ = global.jQuery

require '../src/rambling.slice.generator'

describe 'Rambling Box Slicer', ->
  rambling_slice_generator = null
  slider = null
  settings = null
  vars = null
  result = null
  RamblingSlicer = ->
  realRamblingSlicer = null

  beforeEach ->
    slider = $ '<div id="slider"><div id="rambling-animation"></div></div>'
    slider.css width: 200, height: 200
    settings = boxCols: 2, boxRows: 2
    vars =
      currentSlideElement: $ '<img src="" alt="" />'

    realRamblingSlicer = global.RamblingSlicer
    global.RamblingSlicer = RamblingSlicer
    RamblingSlicer::getRamblingSlice = jasmine.createSpy()
    RamblingSlicer::getRamblingSlice.andCallFake -> $ '<div class="rambling-slice"></div>'

    rambling_slice_generator = new RamblingSliceGenerator slider, settings, vars

  afterEach -> global.RamblingSlicer = realRamblingSlicer

  describe 'when getting one default slice', ->
    create_slices = null

    beforeEach ->
      create_slices = RamblingSliceGenerator::createSlices
      RamblingSliceGenerator::createSlices = jasmine.createSpy()
      RamblingSliceGenerator::createSlices.andCallFake RamblingSlicer::getRamblingSlice

      result = rambling_slice_generator.getOneSlice()

    afterEach ->
      RamblingSliceGenerator::createSlices = create_slices

    it 'should create one slice', ->
      expect(RamblingSliceGenerator::createSlices).toHaveBeenCalledWith 1, vars.currentSlideElement
