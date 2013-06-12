describe 'Rambling Box Generator', ->
  ramblingBoxGenerator = null
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

    ramblingBoxGenerator = new RamblingBoxGenerator slider, settings, vars

  afterEach -> global.RamblingBoxer = realRamblingBoxer

  describe 'when creating the default amount of boxes', ->
    beforeEach ->
      result = ramblingBoxGenerator.createBoxes()

    it 'returns the expected amount of boxes', ->
      expect(result.length).toEqual settings.boxCols * settings.boxRows

    it 'calls the rambling boxer with the correct parameters', ->
      boxWidth = slider.width() / settings.boxRows
      boxHeight = slider.height() / settings.boxCols

      for row in [0...settings.boxRows]
        for column in [0...settings.boxCols]
          expect(RamblingBoxer::getRamblingBox).toHaveBeenCalledWith boxWidth, boxHeight, row, column, settings, vars

    it 'calls the rambling boxer the expected amount of times', ->
      expect(RamblingBoxer::getRamblingBox.callCount).toEqual settings.boxCols * settings.boxRows

  describe 'when creating a custom amount of boxes', ->
    boxRows = null
    boxCols = null

    beforeEach ->
      boxRows = 3
      boxCols = 6

      result = ramblingBoxGenerator.createBoxes boxCols, boxRows

    it 'returns the expected amount of boxes', ->
      expect(result.length).toEqual boxRows * boxCols

    it 'calls the rambling boxer with the correct parameters', ->
      boxWidth = Math.round slider.width() / boxRows
      boxHeight = Math.round slider.height() / boxCols

      for row in [0...boxRows]
        for column in [0...boxCols]
          expect(RamblingBoxer::getRamblingBox).toHaveBeenCalledWith boxHeight, boxWidth, row, column, settings, vars

    it 'calls the rambling boxer the expected amount of times', ->
      expect(RamblingBoxer::getRamblingBox.callCount).toEqual boxRows * boxCols

