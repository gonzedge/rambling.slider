describe 'Array Extensions', ->
  beforeEach ->
    @array = [1...10]

  describe '#shuffle', ->
    beforeEach ->
      @firstCopy = @array.slice()
      @secondCopy = @array.shuffle()

    it 'returns the same array with shifted the positions', ->
      expect(@secondCopy).toEqual @array

    it 'does not let the original array untouched', ->
      expect(@firstCopy).not.toEqual @array

  describe '#where', ->
    beforeEach ->
      @newArray = @array.where (number) -> number > 2

    it 'contains the matching elements', ->
      for number in [3..5]
        expect(@newArray).toContain number

    it 'does not contain the non matching elements', ->
      for number in [1..2]
        expect(@newArray).not.toContain number

  describe '#first', ->
    it 'returns the first element', ->
      expect(@array.first()).toEqual @array[0]

    describe 'and passing a predicate', ->
      beforeEach ->
        @predicate = (number) -> number > 2

      it 'returns the first matching element', ->
        expect(@array.first @predicate).toEqual 3

      describe 'but the array is empty', ->
        expect([].first @predicate).toBeUndefined()

    describe 'and the array is empty', ->
      it 'returns undefined', ->
        expect([].first()).toBeUndefined()

  describe '#map', ->
    it 'maps the values correctly', ->
      @newArray = @array.map (number) -> number * number
      for number in @array
        expect(@newArray).toContain number * number

    describe 'and no map function is passed', ->
      it 'leaves the elements as they are', ->
        expect(@array.map()).toEqual @array

  describe '#fromObject', ->
    beforeEach ->
      @object =
        one: 'one'
        two: ->
        three: {}

    describe 'and the value selector is not specified', ->
      beforeEach ->
        @array = [].fromObject @object

      it 'contains all property values', ->
        for key, value of @object
          expect(@array).toContain value

    describe 'and the value selector is specified', ->
      valueSelector = (key, value) -> key

      beforeEach ->
        @array = [].fromObject @object, valueSelector

      it 'contains the expected values', ->
        for key, value of @object
          expect(@array).toContain valueSelector(key, value)

  describe '#random', ->
    it 'returns a contained element', ->
      expect(@array).toContain @array.random()

    describe 'and the array is empty', ->
      it 'returns null', ->
        expect([].random()).toBeUndefined()

  describe '#sortOutIn', ->
    beforeEach ->
      @newArray = @array.sortOutIn()

    it 'returns an array with the same length', ->
      expect(@newArray.length).toEqual @array.length

    it 'returns the elements in the expected order', ->
      for i in [0...(Math.floor(@array.length / 2))]
        expect(@newArray[2 * i]).toEqual @array[i]
        expect(@newArray[2 * i + 1]).toEqual @array[@array.length - i - 1]

      expect(@newArray[@newArray.length - 1]).toEqual @array[Math.floor(@array.length / 2)]
