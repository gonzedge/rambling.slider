beforeEach ->
  matchers =
    toEqualJquery: (jQueryArray) ->
      result = true
      @actual.each (index, element) ->
        result = result and @ is jQueryArray.get(index)

      result

  @addMatchers matchers
