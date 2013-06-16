(($) ->
  $.fn.reverse = Array::reverse
  $.fn.shuffle = Array::shuffle
  $.fn.sortOutIn = -> $ Array::sortOutIn.apply(@)
  $.fn.sortInOut = -> @sortOutIn().reverse()

  $.fn.as2dArray = (totalColumns) ->
    rowIndex = 0
    colIndex = 0
    array2d = $ ''
    array2d[rowIndex] = $ ''

    @each ->
      array2d[rowIndex][colIndex] = $ @
      colIndex++
      if colIndex is totalColumns
        rowIndex++
        colIndex = 0
        array2d[rowIndex] = $ ''

    array2d

  $.fn.containsFlash = -> @find('object,embed').length

  $.fn.equals = (other) ->
    result = @length is other.length
    @each (index, element) ->
      result = result and element is other.get(index)

    result
)(jQuery)
