Array::shuffle = ->
  for i in [@length..1]
    j = parseInt(Math.random() * i)
    x = @[--i]
    @[i] = @[j]
    @[j] = x
  @
