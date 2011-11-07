String::contains = (string) ->
  return @indexOf(string) isnt -1

String::decapitalize = ->
  first = @[0..0]
  rest = @[1..]

  "#{first.toLowerCase()}#{rest}"
