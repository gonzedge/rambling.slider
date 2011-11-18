String::contains = (string) ->
  @match "#{string}"

String::decapitalize = ->
  first = @[0..0]
  rest = @[1..]

  "#{first.toLowerCase()}#{rest}"

String::startsWith = (string) ->
  @match "^#{string}"
