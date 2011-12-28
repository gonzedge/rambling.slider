class RamblingSlicer
  constructor: (@slider) ->

  getSlice: (sliceWidth, position, total) ->
    sliceCss =
      left: sliceWidth * position
      width: if position is (total - 1) then @slider.width() - (sliceWidth * position) else sliceWidth
      height: 0
      opacity: 0
      overflow: 'hidden'

    $('<div class="rambling-slice"></div>').css sliceCss

  getRamblingSlice: (sliceWidth, position, total, slideElement, settings) ->
    ramblingSlice = @getSlice sliceWidth, position, total
    ramblingSlice.append "<span><img src=\"#{slideElement.attr('src') or slideElement.find('img').attr('src')}\" alt=\"\"/></span>"

    ramblingSliceImageStyle =
      display: 'block'
      width: @slider.width()
      left: - position * sliceWidth
      bottom: if settings.alignBottom then 0 else 'auto'
      top: if settings.alignBottom then 'auto' else 0

    ramblingSlice.find('img').css ramblingSliceImageStyle
    ramblingSlice

root = global ? window
root.RamblingSlicer = RamblingSlicer
