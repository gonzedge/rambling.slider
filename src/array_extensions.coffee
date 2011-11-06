Array::shuffle = ->
  new_array = []
  for i in [@length..1]
    new_array[i] = @[i]
    j = parseInt(Math.random() * i)
    x = @[--i]
    new_array[i] = @[j]
    new_array[j] = x
  new_array
