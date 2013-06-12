describe 'Array Extensions', ->
  array = null

  beforeEach ->
    array = [1...10]

  describe 'when shuffling an array', ->
    first_copy = null
    second_copy = null

    beforeEach ->
      first_copy = array.slice()
      second_copy = array.shuffle()

    it 'returns the same array with shifted the positions', ->
      expect(second_copy).toEqual array

    it 'does not let the original array untouched', ->
      expect(first_copy).not.toEqual array

  describe 'when verifying if an array contains an element', ->
    it 'returns true for a contained element', ->
      expect(array.contains(1)).toBeTruthy()

    it 'returns false for a non contained element', ->
      expect(array.contains(array.length + 1)).toBeFalsy()

  describe 'when getting the values that match a predicate', ->
    new_array = null

    beforeEach ->
      new_array = array.where (number) -> number > 2

    it 'contains the matching elements', ->
      for number in [3..5] then do (number) ->
        expect(new_array).toContain number

    it 'does not contain the non matching elements', ->
      for number in [1..2] then do (number) ->
        expect(new_array).not.toContain number

  describe 'when getting the first value of an array', ->
    predicate = null

    beforeEach ->
      predicate = (number) -> number > array[1]

    it 'returns the first element', ->
      expect(array.first()).toEqual array[0]

    describe 'and passing a predicate', ->
      it 'returns the first matching element', ->
        expect(array.first predicate).toEqual array[2]

      describe 'but the array is empty', ->
        expect([].first predicate).toBeUndefined()

    describe 'and the array is empty', ->
      it 'returns undefined', ->
        expect([].first()).toBeUndefined()

  describe 'when mapping the array to another value', ->
    it 'maps the values correctly', ->
      new_array = array.map (number) -> number * number
      for number in array then do (number) ->
        expect(new_array).toContain number * number

    describe 'and no map function is passed', ->
      it 'leaves the elements as they are', ->
        expect(array.map()).toEqual array

  describe 'when adding values from an object', ->
    object = null

    beforeEach ->
      object =
        one: 'one'
        two: ->
        three: {}

    describe 'and the value selector is not specified', ->
      beforeEach ->
        array = [].fromObject object

      it 'contains all property values', ->
        for key, value of object then do (key, value) ->
          expect(array).toContain value

    describe 'and the value selector is specified', ->
      value_selector = (key, value) -> key

      beforeEach ->
        array = [].fromObject object, value_selector

      it 'contains the expected values', ->
        for key, value of object then do (key, value) ->
          expect(array).toContain value_selector(key, value)

  describe 'when getting a random value from the array', ->
    it 'returns a contained element', ->
      expect(array).toContain array.random()

    describe 'and the array is empty', ->
      it 'returns null', ->
        expect([].random()).toBeUndefined()

  describe 'when sorting an array from outer to inner elements', ->
    new_array = null

    beforeEach ->
      new_array = array.sortOutIn()

    it 'returns an array with the same length', ->
      expect(new_array.length).toEqual array.length

    it 'returns the elements in the expected order', ->
      for i in [0...(Math.floor(array.length / 2))] then do (i) ->
        expect(new_array[2 * i]).toEqual array[i]
        expect(new_array[2 * i + 1]).toEqual array[array.length - i - 1]

      expect(new_array[new_array.length - 1]).toEqual array[Math.floor(array.length / 2)]
