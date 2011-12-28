class RamblingSliceGenerator
  constructor: (@slider, @settings, @vars) ->
    @slicer = new RamblingSlicer @slider

  getOneSlice: (slideElement = @vars.currentSlideElement) ->
    @createSlices 1, slideElement

  createSlices: (slices = @settings.slices, slideElement = @vars.currentSlideElement) ->
    sliceWidth = Math.round(@slider.width() / slices)
    animationContainer = @slider.find '#rambling-animation'

    for i in [0...slices] then do (i) =>
      animationContainer.append @slicer.getRamblingSlice(sliceWidth, i, slices, slideElement, @settings)

    @slider.find '.rambling-slice'

root = global ? window
root.RamblingSliceGenerator = RamblingSliceGenerator
