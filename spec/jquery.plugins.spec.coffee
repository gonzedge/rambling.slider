describe 'jQuery Plugins', ->
  htmlBox = null

  beforeEach ->
    htmlBox = $ '<div></div>'
    htmlBox.append '<ul><li></li><li></li><li></li><li></li></ul>'

  describe 'when reversing a jQuery array', ->
    originalArray = null
    array = null

    beforeEach ->
      array = htmlBox.find 'li'
      originalArray = htmlBox.find 'li'
      array = array.reverse()

    it 'returns the elements in reverse order', ->
      for i in [0...array.length]
        expect(array[i]).toEqual originalArray[array.length - 1 - i]

  describe 'when shuffling a jQuery array', ->
    originalArray = null
    firstCopy = null
    secondCopy = null

    beforeEach ->
      originalArray = htmlBox.find 'li'
      firstCopy = originalArray.slice()
      secondCopy = originalArray.shuffle()

    it 'returns the same array with shifted the positions', ->
      expect(secondCopy).toEqual originalArray

    it 'does not let the original array untouched', ->
      expect(firstCopy).not.toEqual originalArray

  describe 'when converting an array to bidimensional', ->
    it 'returns an array with the expected dimensions', ->
      listItems = htmlBox.find 'li'
      array = listItems.as2dArray 2

      for i in [0...2]
        for j in [0...2]
          expect(array[i][j].get(0)).toEqual listItems.get(i * 2 + j)

  describe 'when finding out if an element contains a flash element', ->
    describe 'and there is an object element', ->
      beforeEach ->
        htmlBox.append '<object></object>'

      it 'returns true', ->
        expect(htmlBox.containsFlash()).toBeTruthy()

    describe 'and there is an embed element', ->
      beforeEach ->
        htmlBox.append '<embed></embed>'

      it 'returns true', ->
        expect(htmlBox.containsFlash()).toBeTruthy()

    describe 'and there is no flash', ->
      it 'returns false', ->
        expect(htmlBox.containsFlash()).toBeFalsy()

  describe 'when sorting a jQuery array from outer to inner elements', ->
    array = null
    newArray = null

    beforeEach ->
      array = htmlBox.find 'li'
      newArray = array.sortOutIn()

    it 'returns an array with the same length', ->
      expect(newArray.length).toEqual array.length

    it 'returns the elements in the expected order', ->
      for i in [0...(Math.floor(array.length / 2))] then do (i) ->
        expect(newArray[2 * i]).toEqual array[i]
        expect(newArray[2 * i + 1]).toEqual array[array.length - i - 1]

      expect(newArray[newArray.length - 1]).toEqual array[Math.floor(array.length / 2)]

  describe 'when sorting a jQuery array from inner to outer elements', ->
    array = null
    newArray = null

    beforeEach ->
      array = htmlBox.find 'li'
      newArray = array.sortInOut()

    it 'returns an array with the same length', ->
      expect(newArray.length).toEqual array.length

    it 'returns the elements in the expected order', ->
      for i in [0...(Math.floor(array.length / 2))] then do (i) ->
        expect(newArray[newArray.length - 2 * i - 1]).toEqual array[i]
        expect(newArray[newArray.length - 2 * i - 2]).toEqual array[array.length - i - 1]

      expect(newArray[0]).toEqual array[Math.floor(array.length / 2)]

  describe 'when comparing to jquery arrays', ->
    array = null

    beforeEach ->
      array = htmlBox.find 'li'

    describe 'and they are equal', ->
      it 'returns true', ->
        expect(array.equals(htmlBox.find 'li')).toBeTruthy()

    describe 'and they are different', ->
      it 'returns false', ->
        expect(array.equals(htmlBox.find 'ul')).toBeFalsy()

    describe 'and one of them is empty', ->
      it 'returns false', ->
        expect(array.equals(htmlBox.find 'body')).toBeFalsy()

    describe 'and one of them is smaller', ->
      it 'returns false', ->
        expect(array.equals(htmlBox.find('li').first())).toBeFalsy()
