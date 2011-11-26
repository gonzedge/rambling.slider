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
  interval_spy = null
  timeout_spy = null
  fake_timer = {}

  create_slider = (options...) ->
    rambling_slider = $ '<div id="#slider"><img src="image1.jpg" alt="image1" /><img src="image2.jpg" alt="image2" /><img src="image3.jpg" alt="image3" /></div>'
    if options.length
      rambling_slider.ramblingSlider options[0]
    else
      rambling_slider.ramblingSlider()

  destroy_slider = ->
    rambling_slider.data 'rambling:slider', null
    rambling_slider.data 'rambling:vars', null
    rambling_slider.remove()

  beforeEach ->
    timeout_spy = spyOn window, 'setTimeout'
    interval_spy = spyOn window, 'setInterval'
    interval_spy.andReturn fake_timer
    spyOn window, 'clearInterval'

    result = create_slider()

  afterEach destroy_slider

  it 'should return the jQuery Array for method chaining', ->
    expect(result).toEqualJquery rambling_slider

  it 'should set the first image as the current slide element', ->
    expect(rambling_slider).toContainElementWithClass 'currentSlideElement'
    expect(rambling_slider.find '.currentSlideElement').toEqualJquery rambling_slider.find('img').first()

  it 'should add all the expected html elements', ->
    expect(rambling_slider).toContainElementWithClass 'rambling-caption'
    expect(rambling_slider).toContainElementWithClass 'rambling-directionNav'
    expect(rambling_slider).toContainElementWithClass 'rambling-controlNav'

  it 'should add the animation container element', ->
    expect(rambling_slider).toContainElementWithId 'rambling-animation'

  it 'should add the "ramblingSlider" class', ->
    expect(rambling_slider).toHaveClass 'ramblingSlider'

  it 'should add the slider data', ->
    expect(rambling_slider).toHaveData 'rambling:slider'
    expect(rambling_slider).toHaveData 'rambling:vars'

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
      effect = 'boxRain'
      other_slider = create_slider effect: effect
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

  describe 'when destroying the slider', ->
    beforeEach ->
      rambling_slider.ramblingSlider 'destroy'

    it 'should remove all the added html elements', ->
      expect(rambling_slider).not.toContainElementWithClass 'rambling-slice'
      expect(rambling_slider).not.toContainElementWithClass 'rambling-box'
      expect(rambling_slider).not.toContainElementWithClass 'rambling-caption'
      expect(rambling_slider).not.toContainElementWithClass 'rambling-directionNav'
      expect(rambling_slider).not.toContainElementWithClass 'rambling-controlNav'

    it 'should remove the animation container element', ->
      expect(rambling_slider).not.toContainElementWithId 'rambling-animation'

    it 'should remove the "ramblingSlider" class', ->
      expect(rambling_slider).not.toHaveClass 'ramblingSlider'

    it 'should remove the custom styles from the slider', ->
      expect(rambling_slider.attr 'style').toEqual ''

    it 'should clear the timer', ->
      expect(window.clearInterval).toHaveBeenCalledWith fake_timer

    it 'should remove the slider data', ->
      expect(rambling_slider).not.toHaveData 'rambling:slider'
      expect(rambling_slider).not.toHaveData 'rambling:vars'

    it 'should make the slider inner elements visible', ->
      rambling_slider.children().each ->
        expect($(@).is ':visible').toBeTruthy()

  describe 'when calling the slide changing methods', ->
    beforeEach ->
      rambling_slider.ramblingSlider 'effect', 'sliceUpDown'
      timeout_spy.andCallFake -> rambling_slider.trigger 'rambling:finished'

    describe 'when going to the previous slide', ->
      beforeEach ->
        result = rambling_slider.ramblingSlider 'previousSlide'

      it 'should return the jQuery Array for method chaining', ->
        expect(result).toEqualJquery rambling_slider

      it 'should change the current slide index', ->
        expect(rambling_slider.data('rambling:vars').currentSlide).toEqual 2

      it 'should change the current slide element to the previous one', ->
        expect(rambling_slider.find '.currentSlideElement').toEqualJquery rambling_slider.find('img[alt=image3]')

    describe 'when going to the next slide', ->
      beforeEach ->
        result = rambling_slider.ramblingSlider 'nextSlide'

      it 'should return the jQuery Array for method chaining', ->
        expect(result).toEqualJquery rambling_slider

      it 'should change the current slide index', ->
        expect(rambling_slider.data('rambling:vars').currentSlide).toEqual 1

      it 'should change the current slide element to the next one', ->
        expect(rambling_slider.find '.currentSlideElement').toEqualJquery rambling_slider.find('img[alt=image2]')

    describe 'when going to a specific slide', ->
      slide_index = null

      beforeEach ->
        slide_index = 1
        result = rambling_slider.ramblingSlider 'slide', slide_index

      it 'should return the jQuery Array for method chaining', ->
        expect(result).toEqualJquery rambling_slider

      it 'should change the current slide index', ->
        expect(rambling_slider.data('rambling:vars').currentSlide).toEqual slide_index

      it 'should change the current slide element to the next one', ->
        expect(rambling_slider.find '.currentSlideElement').toEqualJquery rambling_slider.find('img[alt=image2]')

  describe 'when getting the current slide index', ->
    beforeEach ->
      result = rambling_slider.ramblingSlider 'slide'

    it 'should return the expected index', ->
      expect(result).toEqual 0

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

      other_slider.trigger 'mouseenter', type: 'mouseenter'
      expect(other_slider.find('rambling-directionNav').is(':visible')).toBeFalsy()

  describe 'when the slider is adaptive', ->
    beforeEach ->
      create_slider adaptImages: true

    it 'should add the "adaptingSlider" class', ->
      expect(rambling_slider).toHaveClass 'adaptingSlider'

    describe 'and the slider is destroyed', ->
      beforeEach ->
        rambling_slider.ramblingSlider 'destroy'

      it 'should remove the "adaptingSlider" class', ->
        expect(rambling_slider).not.toHaveClass 'adaptingSlider'
