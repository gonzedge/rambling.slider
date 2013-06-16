Array::shuffle = ->
  for i in [@length..1]
    j = parseInt Math.random() * i
    [@[i], @[j]] = [@[j], @[--i]]

  @

Array::where = (predicate) ->
  element for element in @ when predicate(element)

Array::first = (predicate) ->
  predicate = ((element) -> true) unless predicate
  for element in @
    return element if predicate(element)

Array::map = (map) ->
  map = ((element) -> element) unless map
  map(element) for element in @

Array::random = -> @[Math.floor Math.random() * @length]

Array::fromObject = (object, valueSelector) ->
  valueSelector = ((key, value) -> value) unless valueSelector

  for key, value of object then do (key, value) =>
    @push valueSelector(key, value)

  @

Array::sortOutIn = ->
  newArray = []

  length = @length
  halfLength = Math.floor(length / 2)
  for i in [0...halfLength] then do (i) =>
    newArray.push @[i]
    newArray.push @[length - i - 1]

  newArray.push(@[halfLength]) if length % 2

  newArray
