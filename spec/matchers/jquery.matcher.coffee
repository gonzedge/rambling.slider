beforeEach ->
  matchers =
    toEqualJquery: (jQueryArray) ->
      result = true
      @actual.each (index, element) ->
        result = result and @ is jQueryArray.get(index)

      result

    toContainElementWithClass: (class_name) ->
      @actual.find(".#{class_name}").length

    toContainElementWithId: (id) ->
      @actual.find("##{id}").length

    toHaveClass: (class_name) ->
      @actual.hasClass class_name

    toHaveAttribute: (attribute) ->
      @actual.filter("[#{attribute}]").length

    toHaveData: (data_name) ->
      @actual.data data_name

  @addMatchers matchers
