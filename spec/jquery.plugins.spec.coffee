global.window = require('jsdom').jsdom().createWindow()
global.jQuery = require 'jquery'

require '../src/array_extensions'
require '../src/jquery.plugins'

$ = jQuery

describe 'jQuery Plugins', ->
  html_box = null

  beforeEach ->
    html_box = $ '<div></div>'
    html_box.append($('<ul></ul>').append($('<li></li>')).append($('<li></li>')).append($('<li></li>')).append($('<li></li>')))

  describe 'when reversing a jQuery array', ->
    original_array = null
    array = null

    beforeEach ->
      array = html_box.find 'li'
      original_array = html_box.find 'li'
      array = array.reverse()

    it 'should return the elements in reverse order', ->
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

    it 'should return the same array with shifted the positions', ->
      expect(second_copy).toEqual original_array

    it 'should not let the original array untouched', ->
      expect(first_copy).not.toEqual original_array

  describe 'when converting an array to bidimensional', ->
    it 'should return an array with the expected dimensions', ->
      list_items = html_box.find 'li'
      array = list_items.as2dArray 2

      for i in [0...2]
        for j in [0...2]
          expect(array[i][j].get(0)).toEqual list_items.get(i * 2 + j)
