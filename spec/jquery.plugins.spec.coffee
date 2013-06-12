describe 'jQuery Plugins', ->
  html_box = null

  beforeEach ->
    html_box = $ '<div></div>'
    html_box.append '<ul><li></li><li></li><li></li><li></li></ul>'

  describe 'when reversing a jQuery array', ->
    original_array = null
    array = null

    beforeEach ->
      array = html_box.find 'li'
      original_array = html_box.find 'li'
      array = array.reverse()

    it 'returns the elements in reverse order', ->
      for i in [0...array.length]
        expect(array[i]).toEqual original_array[array.length - 1 - i]

  describe 'when shuffling a jQuery array', ->
    original_array = null
    first_copy = null
    second_copy = null

    beforeEach ->
      original_array = html_box.find 'li'
      first_copy = original_array.slice()
      second_copy = original_array.shuffle()

    it 'returns the same array with shifted the positions', ->
      expect(second_copy).toEqual original_array

    it 'does not let the original array untouched', ->
      expect(first_copy).not.toEqual original_array

  describe 'when converting an array to bidimensional', ->
    it 'returns an array with the expected dimensions', ->
      list_items = html_box.find 'li'
      array = list_items.as2dArray 2

      for i in [0...2]
        for j in [0...2]
          expect(array[i][j].get(0)).toEqual list_items.get(i * 2 + j)

  describe 'when finding out if an element contains a flash element', ->
    describe 'and there is an object element', ->
      beforeEach ->
        html_box.append '<object></object>'

      it 'returns true', ->
        expect(html_box.containsFlash()).toBeTruthy()

    describe 'and there is an embed element', ->
      beforeEach ->
        html_box.append '<embed></embed>'

      it 'returns true', ->
        expect(html_box.containsFlash()).toBeTruthy()

    describe 'and there is no flash', ->
      it 'returns false', ->
        expect(html_box.containsFlash()).toBeFalsy()

  describe 'when sorting a jQuery array from outer to inner elements', ->
    array = null
    new_array = null

    beforeEach ->
      array = html_box.find 'li'
      new_array = array.sortOutIn()

    it 'returns an array with the same length', ->
      expect(new_array.length).toEqual array.length

    it 'returns the elements in the expected order', ->
      for i in [0...(Math.floor(array.length / 2))] then do (i) ->
        expect(new_array[2 * i]).toEqual array[i]
        expect(new_array[2 * i + 1]).toEqual array[array.length - i - 1]

      expect(new_array[new_array.length - 1]).toEqual array[Math.floor(array.length / 2)]

  describe 'when sorting a jQuery array from inner to outer elements', ->
    array = null
    new_array = null

    beforeEach ->
      array = html_box.find 'li'
      new_array = array.sortInOut()

    it 'returns an array with the same length', ->
      expect(new_array.length).toEqual array.length

    it 'returns the elements in the expected order', ->
      for i in [0...(Math.floor(array.length / 2))] then do (i) ->
        expect(new_array[new_array.length - 2 * i - 1]).toEqual array[i]
        expect(new_array[new_array.length - 2 * i - 2]).toEqual array[array.length - i - 1]

      expect(new_array[0]).toEqual array[Math.floor(array.length / 2)]

  describe 'when comparing to jquery arrays', ->
    array = null

    beforeEach ->
      array = html_box.find 'li'

    describe 'and they are equal', ->
      it 'returns true', ->
        expect(array.equals(html_box.find 'li')).toBeTruthy()

    describe 'and they are different', ->
      it 'returns false', ->
        expect(array.equals(html_box.find 'ul')).toBeFalsy()

    describe 'and one of them is empty', ->
      it 'returns false', ->
        expect(array.equals(html_box.find 'body')).toBeFalsy()

    describe 'and one of them is smaller', ->
      it 'returns false', ->
        expect(array.equals(html_box.find('li').first())).toBeFalsy()
