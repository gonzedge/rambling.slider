class RamblingBoxer
  constructor: (@slider) ->

  getBox: (boxWidth, boxHeight, row, column, settings) ->
    boxCss =
      opacity: 0
      left: boxWidth * column
      top: boxHeight * row
      width: if column is (settings.boxCols - 1) then (@slider.width() - (boxWidth * column)) else boxWidth
      height: boxHeight
      overflow: 'hidden'

    $('<div class="rambling-box"></div>').css boxCss

  getRamblingBox: (boxWidth, boxHeight, row, column, settings, vars) ->
    ramblingBox = @getBox boxWidth, boxHeight, row, column, settings

    bottom = if settings.alignBottom then boxHeight * (settings.boxRows - (row + 1)) else 'auto'
    top = if settings.alignBottom then 'auto' else row * boxHeight

    ramblingBoxImageStyle =
      display: 'block'
      width: @slider.width()
      left: -(column * boxWidth)
      top: if settings.alignBottom then 'auto' else -top
      bottom: if settings.alignBottom then -bottom else 'auto'

    ramblingBox.css top: top, bottom: bottom
    ramblingBox.append("<span><img src='#{vars.currentSlideElement.attr('src') or vars.currentSlideElement.find('img').attr('src')}' alt=''/></span>")
    ramblingBox.find('img').css ramblingBoxImageStyle
    ramblingBox

root = global ? window
root.RamblingBoxer = RamblingBoxer
