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

Array::where = (predicate) ->
  newArray = []

  for element in @ when predicate(element) then do (element) ->
    newArray.push element

  newArray

Array::first = (predicate) ->
  predicate = ((element) -> true) unless predicate
  for element in @ when predicate(element)
    return element

  null

Array::map = (map) ->
  newArray = []

  map = ((element) -> element) unless map
  for element in @ then do (element) ->
    newArray.push map(element)

  newArray

Array::random = ->
  @[Math.floor Math.random() * @length]

Array::fromObject = (object, valueSelector) ->
  self = @
  valueSelector = ((key, value) -> value) unless valueSelector

  for key, value of object then do (key, value) ->
    self.push valueSelector(key, value)

  self

Array::sortOutIn = ->
  newArray = []
  self = @

  length = self.length
  halfLength = Math.floor(length / 2)
  for i in [0...halfLength] then do (i) ->
    newArray.push self[i]
    newArray.push self[length - i - 1]

  newArray.push(self[halfLength]) if length % 2

  newArray
