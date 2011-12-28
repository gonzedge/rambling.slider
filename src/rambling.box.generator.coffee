class RamblingBoxGenerator
  constructor: (@slider, @settings, @vars) ->
    @boxer = new RamblingBoxer @slider

  createBoxes: (boxCols = @settings.boxCols, boxRows = @settings.boxRows) ->
    boxWidth = Math.round(@slider.width() / boxCols)
    boxHeight = Math.round(@slider.height() / boxRows)
    animationContainer = @slider.find '#rambling-animation'

    for rows in [0...boxRows] then do (rows) =>
      for cols in [0...boxCols] then do (cols) =>
        animationContainer.append @boxer.getRamblingBox(boxWidth, boxHeight, rows, cols, @settings, @vars)

    @slider.find '.rambling-box'

root = global ? window
root.RamblingBoxGenerator = RamblingBoxGenerator
