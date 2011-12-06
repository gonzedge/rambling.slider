String::contains = (string) ->
  @indexOf(string) isnt -1

String::decapitalize = ->
  first = @[0..0]
  rest = @[1..]

  "#{first.toLowerCase()}#{rest}"

String::startsWith = (string) ->
  @substring(0, string.length) is string

String::endsWith = (string) ->
  @substring(@length - string.length, @length) is string
