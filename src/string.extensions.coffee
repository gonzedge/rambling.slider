String::decapitalize = ->
  first = @[0]
  rest = @[1..]

  "#{first.toLowerCase()}#{rest}"

String::startsWith = (string) ->
  @[0...string.length] is string

String::endsWith = (string) ->
  @[(@length - string.length)...@length] is string
