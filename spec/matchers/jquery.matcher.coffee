formatJqueryElement = (jQueryArray) ->
  return 'undefined' unless jQueryArray.length

  element = jQueryArray.get 0
  formatElement element

formatElement = (element) ->
  tagName = element.tagName.toLowerCase()
  id = element.id
  classes = element.className
  format = "<#{tagName}"
  for attribute in element.attributes then do (attribute) ->
    format = "#{format} #{attribute.name}='#{attribute.value}'"
  format = "#{format}>#{element.innerHTML}</#{tagName}>"

beforeEach ->
  @addMatchers
    toEqualJquery: (jQueryArray) ->
      @message = ->
        "Expected #{formatJqueryElement(@actual)} to equal #{formatJqueryElement(jQueryArray)}"

      @actual.equals jQueryArray

    toContainElementWithClass: (className) ->
      @message = ->
        "Expected #{formatJqueryElement(@actual)} to include an element with class '#{className}'"

      @actual.find(".#{className}").length

    toContainElementWithId: (id) ->
      @message = ->
        "Expected #{formatJqueryElement(@actual)} to include an element with id '#{id}'"

      @actual.find("##{id}").length

    toHaveClass: (className) ->
      @message = ->
        "Expected #{formatJqueryElement(@actual)} to have class '#{className}'"

      @actual.hasClass className

    toHaveAttribute: (attribute) ->
      @actual.filter("[#{attribute}]").length

    toHaveData: (dataName) ->
      @actual.data dataName
