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
