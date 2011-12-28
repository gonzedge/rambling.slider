global.window = require('jsdom').jsdom().createWindow()
global.jQuery = require 'jquery'
global.$ = global.jQuery

require './matchers/jquery.matcher'
require '../src/array_extensions'
require '../src/string_extensions'
require '../src/jquery.plugins'
require '../src/rambling.slicer'
require '../src/rambling.boxer'
require '../src/rambling.slice.generator'
require '../src/rambling.box.generator'
require '../src/rambling.slider'
require '../src/rambling.slider.transitions'

describe 'Rambling Slider', ->
  slider_wrapper = null
  rambling_slider = null
  result = null
  error = null
  interval_spy = null
  interval_callback = null
  timeout_spy = null
  fake_timer = {}

  create_slider = (options...) ->
    slider_wrapper = $ '<div id="slider-wrapper" class="theme-default"></div>'
    rambling_slider = $ '<div id="#slider"><img src="image1.jpg" alt="image1" /><img src="image2.jpg" alt="image2" /><img src="image3.jpg" alt="image3" /></div>'
    slider_wrapper.append rambling_slider
    $('body').empty().append slider_wrapper
    if options.length
      rambling_slider.ramblingSlider options[0]
    else
      rambling_slider.ramblingSlider()

  destroy_slider = ->
    rambling_slider.data 'rambling:slider', null
    rambling_slider.data 'rambling:vars', null
    rambling_slider.remove()
    slider_wrapper.remove()
    $('body').empty()

  beforeEach ->
    timeout_spy = spyOn window, 'setTimeout'
    interval_spy = spyOn window, 'setInterval'
    interval_spy.andCallFake (callback, timeout) ->
      interval_callback = callback
      fake_timer

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

  it 'should not show the direction nav', ->
    expect(rambling_slider.find('.rambling-directionNav').is(':visible')).toBeFalsy()

  it 'should add the expected amount of navigation controls', ->
    expect(rambling_slider.find('.rambling-controlNav a').length).toEqual rambling_slider.find('.slideElement').length

  it 'should not pause the slider', ->
    expect(rambling_slider.data('rambling:vars').paused).toBeFalsy()

  it 'should set the default theme', ->
    expect(slider_wrapper).toHaveClass "theme-#{$.fn.ramblingSlider.defaults.theme}"

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

  describe 'when the startSlide is not the default', ->
    slide = 1

    beforeEach ->
      create_slider startSlide: slide

    it 'should set the current slide index', ->
      expect(rambling_slider.data('rambling:vars').currentSlide).toEqual slide

    it 'should set the corresponding image as the current slide element', ->
      expect(rambling_slider.find '.currentSlideElement').toEqualJquery rambling_slider.find('img.slideElement[alt=image2]')

  describe 'when clicking any navigation control', ->
    beforeEach ->
      create_slider effect: 'sliceUpRight'
      timeout_spy.andCallFake -> rambling_slider.trigger 'rambling:finished'
      rambling_slider.find('.rambling-controlNav a').last().click()

    it 'should set the current slide index', ->
      expect(rambling_slider.data('rambling:vars').currentSlide).toEqual rambling_slider.find('.slideElement').length - 1

    it 'should set the corresponding current slide element', ->
      expect(rambling_slider.find('.currentSlideElement')).toEqualJquery rambling_slider.find('.slideElement').last()

  describe 'when hovering into the slider', ->
    beforeEach ->
      rambling_slider.trigger 'mouseenter'

    it 'should show the direction nav', ->
      expect(rambling_slider.find('.rambling-directionNav').is(':visible')).toBeTruthy()

    it 'should pause the slider', ->
      expect(rambling_slider.data('rambling:vars').paused).toBeTruthy()

    describe 'and hovering out', ->
      beforeEach ->
        rambling_slider.trigger 'mouseleave'

      it 'should hide the direction nav', ->
        expect(rambling_slider.find('.rambling-directionNav').is(':visible')).toBeFalsy()

      it 'should unpause the slider', ->
        expect(rambling_slider.data('rambling:vars').paused).toBeFalsy()

    describe 'and the pauseOnHover option is false', ->
      beforeEach ->
        rambling_slider.trigger 'mouseleave'
        create_slider pauseOnHover: false
        rambling_slider.trigger 'mouseenter'

      it 'should not pause the slider', ->
        expect(rambling_slider.data('rambling:vars').paused).toBeFalsy()

  describe 'when passing the slider callbacks', ->
    settings = null

    beforeEach ->
      settings =
        effect: 'sliceUpRight'
        beforeChange: ->
        afterChange: ->
        slideshowEnd: ->
        lastSlide: ->
        afterLoad: ->
      spyOn settings, 'beforeChange'
      spyOn settings, 'afterChange'
      spyOn settings, 'slideshowEnd'
      spyOn settings, 'lastSlide'
      spyOn settings, 'afterLoad'

      create_slider settings

    it 'should call the afterLoad immediately after creation', ->
      expect(settings.afterLoad).toHaveBeenCalled()

    describe 'and the animation is finished', ->
      beforeEach ->
        rambling_slider.trigger 'rambling:finished'

      it 'should call afterChange callback', ->
        expect(settings.afterChange).toHaveBeenCalled()

    describe 'and the first slide is run', ->
      beforeEach ->
        interval_callback()

      it 'should call the beforeChange callback', ->
        expect(settings.beforeChange).toHaveBeenCalled()

    describe 'and the last slide is run', ->
      beforeEach ->
        rambling_slider.ramblingSlider 'slide', rambling_slider.find('.slideElement').length - 1
        interval_callback()

      it 'should call the lastSlide callback', ->
        expect(settings.lastSlide).toHaveBeenCalled()

    describe 'and the slideshow is going to begin again', ->
      beforeEach ->
        rambling_slider.ramblingSlider 'slide', rambling_slider.find('.slideElement').length - 1
        interval_callback()
        interval_callback()

      it 'should call the slideshowEnd callback', ->
        expect(settings.slideshowEnd).toHaveBeenCalled()

  describe 'when trying to initialize an already initialized slider', ->
    error = null

    describe 'without any options', ->
      beforeEach ->
        try
          rambling_slider.ramblingSlider()
        catch e
          error = e

      it 'should throw an already initialized error', ->
        expect(error).toEqual 'Slider already initialized.'

    describe 'and passing some new options', ->
      beforeEach ->
        try
          rambling_slider.ramblingSlider {startSlide: 2, effect: 'sliceUp'}
        catch e
          error = e

      it 'should throw an already initialized error', ->
        expect(error).toEqual 'Slider already initialized.'


  # Methods
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
      slices = 20

      create_slider slices: slices
      expect(rambling_slider.ramblingSlider('option', 'slices')).toEqual slices

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
      rambling_slider.ramblingSlider 'effect', 'sliceUpRight'
      timeout_spy.andCallFake -> rambling_slider.trigger 'rambling:finished'

    describe 'when going to the previous slide', ->
      beforeEach ->
        result = rambling_slider.ramblingSlider 'previousSlide'

      it 'should return the jQuery Array for method chaining', ->
        expect(result).toEqualJquery rambling_slider

      it 'should change the current slide index', ->
        expect(rambling_slider.data('rambling:vars').currentSlide).toEqual 2

      it 'should change the current slide element to the previous one', ->
        expect(rambling_slider.find '.currentSlideElement').toEqualJquery rambling_slider.find('img.slideElement[alt=image3]')

    describe 'when going to the next slide', ->
      beforeEach ->
        result = rambling_slider.ramblingSlider 'nextSlide'

      it 'should return the jQuery Array for method chaining', ->
        expect(result).toEqualJquery rambling_slider

      it 'should change the current slide index', ->
        expect(rambling_slider.data('rambling:vars').currentSlide).toEqual 1

      it 'should change the current slide element to the next one', ->
        expect(rambling_slider.find '.currentSlideElement').toEqualJquery rambling_slider.find('img.slideElement[alt=image2]')

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
        expect(rambling_slider.find '.currentSlideElement').toEqualJquery rambling_slider.find('img.slideElement[alt=image2]')

  describe 'when getting the current slide index', ->
    beforeEach ->
      result = rambling_slider.ramblingSlider 'slide'

    it 'should return the expected index', ->
      expect(result).toEqual 0

  describe 'when getting the slider theme', ->
    it 'should return the default theme', ->
      expect(rambling_slider.ramblingSlider 'theme').toEqual $.fn.ramblingSlider.defaults.theme

  describe 'when setting the slider theme', ->
    theme = null

    beforeEach ->
      theme = 'another'
      create_slider theme: theme

    it 'should remove the previous theme class', ->
      expect(slider_wrapper).not.toHaveClass "theme-#{$.fn.ramblingSlider.defaults.theme}"

    it 'should add the new theme class', ->
      expect(slider_wrapper).toHaveClass "theme-#{theme}"

    it 'should return the new theme when asked', ->
      expect(rambling_slider.ramblingSlider 'theme').toEqual theme

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
