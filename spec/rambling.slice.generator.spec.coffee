describe 'Rambling Box Slicer', ->
  ramblingSliceGenerator = null
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

    ramblingSliceGenerator = new RamblingSliceGenerator slider, settings, vars

  afterEach -> global.RamblingSlicer = realRamblingSlicer

  describe 'when getting one default slice', ->
    createSlices = null

    beforeEach ->
      createSlices = RamblingSliceGenerator::createSlices
      RamblingSliceGenerator::createSlices = jasmine.createSpy()
      RamblingSliceGenerator::createSlices.andCallFake RamblingSlicer::getRamblingSlice

      result = ramblingSliceGenerator.getOneSlice()

    afterEach ->
      RamblingSliceGenerator::createSlices = createSlices

    it 'creates one slice', ->
      expect(RamblingSliceGenerator::createSlices).toHaveBeenCalledWith 1, vars.currentSlideElement
