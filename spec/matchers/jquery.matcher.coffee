require '../../src/jquery.plugins'

formatJqueryElement = (jQueryArray) ->
  return 'undefined' unless jQueryArray.length

  element = jQueryArray.get 0
  formatElement element

formatElement = (element) ->
  tag_name = element.tagName.toLowerCase()
  id = element.id
  classes = element.className
  format = "<#{tag_name}"
  for attribute in element.attributes then do (attribute) ->
    format = "#{format} #{attribute.name}='#{attribute.value}'"
  format = "#{format}>#{element.innerHTML}</#{tag_name}>"

beforeEach ->
  matchers =
    toEqualJquery: (jQueryArray) ->
      @message = ->
        "Expected #{formatJqueryElement(@actual)} to equal #{formatJqueryElement(jQueryArray)}"

      @actual.equals jQueryArray

    toContainElementWithClass: (class_name) ->
      @message = ->
        "Expected #{formatJqueryElement(@actual)} to include an element with class '#{class_name}'"

      @actual.find(".#{class_name}").length

    toContainElementWithId: (id) ->
      @message = ->
        "Expected #{formatJqueryElement(@actual)} to include an element with id '#{id}'"

      @actual.find("##{id}").length

    toHaveClass: (class_name) ->
      @message = ->
        "Expected #{formatJqueryElement(@actual)} to have class '#{class_name}'"

      @actual.hasClass class_name

    toHaveAttribute: (attribute) ->
      @actual.filter("[#{attribute}]").length

    toHaveData: (data_name) ->
      @actual.data data_name

  @addMatchers matchers
