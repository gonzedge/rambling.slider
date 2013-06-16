describe 'jQuery Plugins', ->
  beforeEach ->
    @htmlBox = $ '<div></div>'
    @htmlBox.append '<ul><li></li><li></li><li></li><li></li></ul>'

  describe '$.fn.reverse', ->
    beforeEach ->
      @originalArray = @htmlBox.find 'li'
      @reversedArray = @htmlBox.find('li').reverse()

    it 'returns the elements in reverse order', ->
      for i in [0...@reversedArray.length]
        expect(@reversedArray[i]).toEqual @originalArray[@reversedArray.length - 1 - i]

  describe '$.fn.shuffle', ->
    beforeEach ->
      @originalArray = @htmlBox.find 'li'
      @firstCopy = @originalArray.slice()
      @secondCopy = @originalArray.shuffle()

    it 'returns the same array with shifted the positions', ->
      expect(@secondCopy).toEqual @originalArray

    it 'does not let the original array untouched', ->
      expect(@firstCopy).not.toEqual @originalArray

  describe '$.fn.as2dArray', ->
    it 'returns an array with the expected dimensions', ->
      listItems = @htmlBox.find 'li'
      array = listItems.as2dArray 2

      for i in [0...2]
        for j in [0...2]
          expect(array[i][j].get(0)).toEqual listItems.get(i * 2 + j)

  describe '$.fn.containsFlash', ->
    describe 'when there is an object element', ->
      beforeEach ->
        @htmlBox.append '<object></object>'

      it 'returns true', ->
        expect(@htmlBox.containsFlash()).toBeTruthy()

    describe 'when there is an embed element', ->
      beforeEach ->
        @htmlBox.append '<embed></embed>'

      it 'returns true', ->
        expect(@htmlBox.containsFlash()).toBeTruthy()

    describe 'when there is no flash', ->
      it 'returns false', ->
        expect(@htmlBox.containsFlash()).toBeFalsy()

  describe '$.fn.sortOutIn', ->
    beforeEach ->
      @array = @htmlBox.find 'li'
      @sortedArray = @array.sortOutIn()

    it 'returns an array with the same length', ->
      expect(@sortedArray.length).toEqual @array.length

    it 'returns the elements in the expected order', ->
      for i in [0...(Math.floor(@array.length / 2))]
        expect(@sortedArray[2 * i]).toEqual @array[i]
        expect(@sortedArray[2 * i + 1]).toEqual @array[@array.length - i - 1]

      expect(@sortedArray[@sortedArray.length - 1]).toEqual @array[Math.floor(@array.length / 2)]

  describe '$.fn.sortInOut', ->
    beforeEach ->
      @array = @htmlBox.find 'li'
      @sortedArray = @array.sortInOut()

    it 'returns an array with the same length', ->
      expect(@sortedArray.length).toEqual @array.length

    it 'returns the elements in the expected order', ->
      for i in [0...(Math.floor(@array.length / 2))]
        expect(@sortedArray[@sortedArray.length - 2 * i - 1]).toEqual @array[i]
        expect(@sortedArray[@sortedArray.length - 2 * i - 2]).toEqual @array[@array.length - i - 1]

      expect(@sortedArray[0]).toEqual @array[Math.floor(@array.length / 2)]

  describe '$.fn.equals', ->
    beforeEach ->
      @array = @htmlBox.find 'li'

    it 'returns true when the arrays are equal', ->
      expect(@array.equals(@htmlBox.find 'li')).toBeTruthy()

    it 'returns false when the arrays are different', ->
      expect(@array.equals(@htmlBox.find 'ul')).toBeFalsy()
      expect(@array.equals(@htmlBox.find 'body')).toBeFalsy()
      expect(@array.equals(@htmlBox.find('li').first())).toBeFalsy()
