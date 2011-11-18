require '../src/array_extensions'

describe 'Array Extensions', ->
  describe 'when shuffling an array', ->
    original_array = null
    first_copy = null
    second_copy = null

    beforeEach ->
      original_array = [1..100]
      first_copy = original_array.slice()
      second_copy = original_array.shuffle()

    it 'should return the same array with shifted the positions', ->
      expect(second_copy).toEqual original_array

    it 'should not let the original array untouched', ->
      expect(first_copy).not.toEqual original_array

  describe 'when verifying if an array contains an element', ->
    array = null

    beforeEach ->
      array = [1...5]

    it 'should return true for a contained element', ->
      expect(array.contains(1)).toBeTruthy()

    it 'should return false for a non contained element', ->
      expect(array.contains(5)).toBeFalsy()

  describe 'when getting the values that match a predicate', ->
    array = null
    new_array = null

    beforeEach ->
      array = [1..5]
      new_array = array.where (number) -> number > 2

    it 'should contain the matching elements', ->
      for number in [3..5] then do (number) ->
        expect(new_array).toContain number

    it 'should not contain the non matching elements', ->
      for number in [1..2] then do (number) ->
        expect(new_array).not.toContain number

  describe 'when getting the first value of an array', ->
    array = null
    predicate = null

    beforeEach ->
      array = [1..5]
      predicate = (number) -> number > array[1]

    it 'should return the first element', ->
      expect(array.first()).toEqual array[0]

    describe 'and passing a predicate', ->
      it 'should return the first matching element', ->
        expect(array.first predicate).toEqual array[2]

      describe 'but the array is empty', ->
        expect([].first predicate).toBeNull()

    describe 'and the array is empty', ->
      it 'should return null', ->
        expect([].first()).toBeNull()

  describe 'when mapping the array to another value', ->
    array = null

    beforeEach ->
      array = [1..5]

    it 'should map the values correctly', ->
      new_array = array.map (number) -> number * number
      for number in array then do (number) ->
        expect(new_array).toContain number * number

    describe 'and no map function is passed', ->
      it 'should leave the elements as they are', ->
        expect(array.map()).toEqual array

  describe 'when adding values from an object', ->
    array = null
    object = null

    beforeEach ->
      object =
        one: 'one'
        two: ->
        three: {}

    describe 'and the value selector is not specified', ->
      beforeEach ->
        array = [].fromObject object

      it 'should contain all property values', ->
        for key, value of object then do (key, value) ->
          expect(array).toContain value

    describe 'and the value selector is specified', ->
      value_selector = (key, value) -> key

      beforeEach ->
        array = [].fromObject object, value_selector

      it 'should contain the expected values', ->
        for key, value of object then do (key, value) ->
          expect(array).toContain value_selector(key, value)
