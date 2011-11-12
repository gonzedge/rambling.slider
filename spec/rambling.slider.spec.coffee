global.window = require('jsdom').jsdom().createWindow()
global.jQuery = require 'jquery'

require './matchers/jquery.matcher'
require '../src/array_extensions'
require '../src/string_extensions'
require '../src/jquery.plugins'
require '../src/rambling.slider'

$ = jQuery

describe 'Rambling Slider', ->
  rambling_slider = null
  result = null
  error = null

  beforeEach ->
    rambling_slider = $ '<div id="#slider"><img src="image1.jpg" alt="image1" /><img src="image2.jpg" alt="image2" /></div>'
    result = rambling_slider.ramblingSlider()

  it 'should return the jQuery Array for method chaining', ->
    expect(result).toEqualJquery rambling_slider

  it 'should set the first image as the current image', ->
    expect(rambling_slider.css 'background').toContain(rambling_slider.find('img').attr 'src')

  #describe 'when the startSlide is not the default', ->
  #  other_slider = null
  #  slide = 1

  #  beforeEach ->
  #    other_slider = $ '<div id="#slider2"><img src="image1.jpg" alt="image1" /><img src="image2.jpg" alt="image2" /></div>'
  #    other_slider.ramblingSlider startSlide: slide

  #  it 'should set the corresponding image as the current image', ->
  #    expect(other_slider.css 'background').toContain($(other_slider.find('img').get slide).attr 'src')

  #it 'should show the direction nav on hover', ->
  #  expect(rambling_slider.find('rambling-directionNav').is(':visible')).toBeFalsy()

  #  rambling_slider.trigger 'mouseenter', {type: 'mouseenter'}
  #  expect(rambling_slider.find('rambling-directionNav').is(':visible')).toBeTruthy()

  describe 'when getting the effect', ->
    it 'should return the default one', ->
      expect(rambling_slider.ramblingSlider 'effect').toEqual $.fn.ramblingSlider.defaults.effect

    it 'should return the one set at initialization', ->
      other_slider = $ '<div id="#slider2"><img src="image1.jpg" alt="image1" /><img src="image2.jpg" alt="image2" /></div>'
      effect = 'boxRain'

      other_slider.ramblingSlider effect: effect
      expect(other_slider.ramblingSlider 'effect').toEqual effect

  describe 'when setting the effect', ->
    effect = null

    beforeEach ->
      effect = 'fade'
      result = rambling_slider.ramblingSlider 'effect', effect

    it 'should return the jQuery Array for method chaining', ->
      expect(result).toEqualJquery rambling_slider

    it 'should have set the effect', ->
      expect(rambling_slider.ramblingSlider 'effect').toEqual effect

  describe 'when stopping the slider', ->
    beforeEach ->
      result = rambling_slider.ramblingSlider 'stop'

    it 'should return the jQuery Array for method chaining', ->
      expect(result).toEqualJquery rambling_slider

    it 'should stop the slider', ->
      expect(rambling_slider.data('rambling:vars').stopped).toBeTruthy()

    describe 'when starting the slider after stopped', ->
      beforeEach ->
        rambling_slider.ramblingSlider 'start'

      it 'should start the slider', ->
        expect(rambling_slider.data('rambling:vars').stopped).toBeFalsy()

  describe 'when starting the slider', ->
    beforeEach ->
      result = rambling_slider.ramblingSlider 'start'

    it 'should return the jQuery Array for method chaining', ->
      expect(result).toEqualJquery rambling_slider

    it 'should stop the slider', ->
      expect(rambling_slider.data('rambling:vars').stopped).toBeFalsy()

    describe 'when stopping the slider after started', ->
      beforeEach ->
        rambling_slider.ramblingSlider 'stop'

      it 'should start the slider', ->
        expect(rambling_slider.data('rambling:vars').stopped).toBeTruthy()

  describe 'when getting any option', ->
    it 'should get the default value', ->
      expect(rambling_slider.ramblingSlider('option', 'slices')).toEqual $.fn.ramblingSlider.defaults.slices

    it 'should return the one set at initialization', ->
      other_slider = $ '<div id="#slider2"><img src="image1.jpg" alt="image1" /><img src="image2.jpg" alt="image2" /></div>'
      slices = 20

      other_slider.ramblingSlider slices: slices
      expect(other_slider.ramblingSlider('option', 'slices')).toEqual slices

  describe 'when setting a writable option', ->
    slices = null

    beforeEach ->
      slices = 20
      result = rambling_slider.ramblingSlider 'option', 'slices', slices

    it 'should return the jQuery Array for method chaining', ->
      expect(result).toEqualJquery rambling_slider

    it 'should set the option value', ->
      expect(rambling_slider.ramblingSlider('option', 'slices')).toEqual slices

  describe 'when setting a readonly option', ->
    startSlide = 2

    beforeEach ->
      try
        rambling_slider.ramblingSlider 'option', 'startSlide', startSlide
      catch e
        error = e

    it 'should throw an error', ->
      expect(error).not.toBeNull()
      expect(error).toEqual "Slider already running. Option 'startSlide' cannot be changed."

    it 'should not change the value', ->
      expect(rambling_slider.ramblingSlider('option', 'startSlide')).toEqual $.fn.ramblingSlider.defaults.startSlide

  describe 'when trying to call a non existent method', ->

    beforeEach ->
      try
        rambling_slider.ramblingSlider 'methodNotPresent'
      catch e
        error = e

    it 'should throw and error', ->
      expect(error).not.toBeNull()
      expect(error).toEqual "Method 'methodNotPresent' not found."

  describe 'when trying to call a method over an uninitialized slider', ->
    beforeEach ->
      try
        $('<div></div>').ramblingSlider 'start'
      catch e
        error = e

    it 'should throw an error', ->
      expect(error).not.toBeNull()
      expect(error).toEqual "Tried to call method 'start' on element without slider."

  describe 'when the slider has only one slide', ->
    other_slider = null

    beforeEach ->
      other_slider = $ '<div><img src="image1.jpg" alt="image1"/></div>'
      other_slider.ramblingSlider()

    it 'should never show the direction nav', ->
      expect(other_slider.find('rambling-directionNav').is(':visible')).toBeFalsy()

      other_slider.trigger 'mouseenter', {type: 'mouseenter'}
      expect(other_slider.find('rambling-directionNav').is(':visible')).toBeFalsy()
