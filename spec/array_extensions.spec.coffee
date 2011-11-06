require '../src/array_extensions'

describe 'Array Extensions', ->
  describe 'when shuffling an array', ->
    original_array = null
    first_copy = null
    second_copy = null

    beforeEach ->
      original_array = [1..100]
      first_copy = original_array
      second_copy = original_array.shuffle()

    it 'should return a copy with shifted the positions', ->
      expect(second_copy).not.toEqual original_array

    it 'should let the original array untouched', ->
      expect(first_copy).toEqual original_array
