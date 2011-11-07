Array::shuffle = ->
  length = @length

  for i in [length..1]
    @[i] = @[i]
    j = parseInt(Math.random() * i)
    x = @[--i]
    @[i] = @[j]
    @[j] = x

  @

Array::contains = (value) ->
  length = @length

  for i in [0...length]
    return true if value is @[i]

  false
