global.window = require('jsdom').jsdom().createWindow()
global.jQuery = require 'jquery'

require '../src/array_extensions'
require '../src/jquery.plugins'

$ = jQuery

describe 'jQuery Plugins', ->
  describe 'when converting an array to bidimensional', ->
    html_box = null

    beforeEach ->
      html_box = $ '<div></div>'
      html_box.append($('<ul></ul>').append($('<li></li>')).append($('<li></li>')).append($('<li></li>')).append($('<li></li>')))

    it 'should return an array with the expected dimensions', ->
      list_items = html_box.find 'ul li'
      array = list_items.as2dArray 2
      expect(array[0][0].get(0)).toEqual(list_items.get(0))
      expect(array[0][1].get(0)).toEqual(list_items.get(1))
      expect(array[1][0].get(0)).toEqual(list_items.get(2))
      expect(array[1][1].get(0)).toEqual(list_items.get(3))
