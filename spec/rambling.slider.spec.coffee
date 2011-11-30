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
  interval_callback = null
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
    expect(rambling_slider).toHaveClass "theme-#{$.fn.ramblingSlider.defaults.theme}"

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
      create_slider effect: 'sliceUpDown'
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
        effect: 'sliceUpDown'
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

  describe 'when extending the available transitions', ->
    options = null
    helper = null

    beforeEach ->
      options =
        effect: 'newTransition'
        afterChange: ->
        imageTransitions:
          newTransition: ->
            helper = @
            called = true
      spyOn(options.imageTransitions, 'newTransition').andCallThrough()
      spyOn($.fn, 'trigger').andCallThrough()
      spyOn(options, 'afterChange')
      create_slider options
      interval_callback()

    it 'should be able to execute the new transition', ->
      expect(options.imageTransitions.newTransition).toHaveBeenCalled()

    it 'should return a helper with all the expected functions', ->
      expect(helper.createSlices).not.toBeNull()
      expect(helper.createBoxes).not.toBeNull()
      expect(helper.getOneSlice).not.toBeNull()
      expect(helper.animateFullImage).not.toBeNull()
      expect(helper.animateSlices).not.toBeNull()
      expect(helper.animateBoxes).not.toBeNull()
      expect(helper.slideUpSlices).not.toBeNull()
      expect(helper.slideDownSlices).not.toBeNull()
      expect(helper.slideUpDownSlices).not.toBeNull()
      expect(helper.foldSlices).not.toBeNull()
      expect(helper.fadeSlices).not.toBeNull()
      expect(helper.rainBoxes).not.toBeNull()

    describe 'and calling the create slices helper function', ->
      describe 'with no arguments', ->
        beforeEach ->
          result = helper.createSlices()

        it 'should create the expected number of slices', ->
          expect(result.length).toEqual $.fn.ramblingSlider.defaults.slices

        it 'should append all the slices to the animation container', ->
          expect(rambling_slider.find('#rambling-animation .rambling-slice')).toEqualJquery result

        it 'should set the expected slice images', ->
          result.find('img').each (index, element) ->
            expect($(element).attr 'src').toEqual rambling_slider.find('img.currentSlideElement').next().attr('src')

      describe 'with specific number of slices', ->
        slices = null

        beforeEach ->
          slices = 10
          result = helper.createSlices slices

        it 'should create the expected number of slices', ->
          expect(result.length).toEqual slices

      describe 'with specific slide element', ->
        slide_element = null

        beforeEach ->
          slide_element = rambling_slider.find '.slideElement:last'
          result = helper.createSlices $.fn.ramblingSlider.defaults.slices, slide_element

        it 'should set the expected slice images', ->
          result.find('img').each (index, element) ->
            expect($(element).attr 'src').toEqual slide_element.attr('src')

    describe 'and calling the create boxes helper function', ->
      describe 'with no arguments', ->
        beforeEach ->
          result = helper.createBoxes()

        it 'should create the expected number of boxes', ->
          expect(result.length).toEqual $.fn.ramblingSlider.defaults.boxRows * $.fn.ramblingSlider.defaults.boxCols

        it 'should append all the boxes to the animation container', ->
          expect(rambling_slider.find('#rambling-animation .rambling-box')).toEqualJquery result

        it 'should set the expected box images', ->
          result.find('img').each (index, element) ->
            expect($(element).attr 'src').toEqual rambling_slider.find('img.currentSlideElement').next().attr('src')

      describe 'with specific rows and columns', ->
        rows = null
        columns = null

        beforeEach ->
          rows = 2
          columns = 2
          result = helper.createBoxes rows, columns

        it 'should create the expected number of boxes', ->
          expect(result.length).toEqual rows * columns

    describe 'and calling the get one slice helper function', ->
      describe 'with no arguments', ->
        beforeEach ->
          result = helper.getOneSlice()

        it 'should only return one slice', ->
          expect(result.length).toEqual 1

        it 'should append the slice to the animation container', ->
          expect(rambling_slider.find('#rambling-animation .rambling-slice')).toEqualJquery result

        it 'should set the expected slice image', ->
          expect(result.find('img').attr 'src').toEqual rambling_slider.find('img.currentSlideElement').next().attr('src')

      describe 'for a specific element', ->
        slide_element = null

        beforeEach ->
          slide_element = rambling_slider.find '.slideElement:last'
          result = helper.getOneSlice slide_element

        it 'should set the expected slice image', ->
          expect(result.find('img').attr 'src').toEqual slide_element.attr('src')

    describe 'and calling the animate full image helper function', ->
      beforeEach ->
        spyOn($.fn, 'css').andCallThrough()
        spyOn($.fn, 'animate').andCallFake (options, speed, easing, callback) -> callback() if callback

      describe 'as is', ->
        beforeEach ->
          result = helper.animateFullImage ->

        it 'should call the after change callback', ->
          expect(options.afterChange).toHaveBeenCalled()

        it 'should raise the rambling:finished event', ->
          expect($.fn.trigger).toHaveBeenCalledWith 'rambling:finished'

      describe 'and it is aligned to the top', ->
        beforeEach ->
          rambling_slider.ramblingSlider 'option', 'alignBottom', false
          result = helper.animateFullImage ->

        it 'should set the top to 0 and the bottom to auto', ->
          expect($.fn.css).toHaveBeenCalledWith top: '0', bottom: 'auto'

      describe 'and it is aligned to the bottom', ->
        beforeEach ->
          rambling_slider.ramblingSlider 'option', 'alignBottom', true
          result = helper.animateFullImage ->

        it 'should set the top to auto and the bottom to 0', ->
          expect($.fn.css).toHaveBeenCalledWith top: 'auto', bottom: '0'

      describe 'and nothing is returned by the animation set up callback', ->
        beforeEach ->
          result = helper.animateFullImage ->

        it 'should animate the slice width to the width of the slider', ->
          expect($.fn.animate).toHaveBeenCalledWith {width: "#{rambling_slider.width()}px"}, $.fn.ramblingSlider.defaults.speed * 2, '', jasmine.any(Function)

      describe 'and something is returned by the animation set up callback', ->
        animate = null

        beforeEach ->
          animate = height: '500px'
          result = helper.animateFullImage -> animate

        it 'should animate the slice width to the width of the slider', ->
          expect($.fn.animate).toHaveBeenCalledWith animate, $.fn.ramblingSlider.defaults.speed * 2, '', jasmine.any(Function)

    describe 'and calling the animate slices helper function', ->
      beforeEach ->
        spyOn($.fn, 'animate').andCallFake (options, speed, easing, callback) -> callback() if callback
        timeout_spy.andCallFake (callback, timeout) -> callback()

      describe 'and a sort callback is given', ->
        sort_callback = null

        beforeEach ->
          sort_callback = jasmine.createSpy()
          sort_callback.andCallFake -> @
          result = helper.animateSlices (->), sort_callback

        it 'should call the sort callback', ->
          expect(sort_callback).toHaveBeenCalled()

      describe 'and an animate set up callback is given', ->
        animation_callback = null

        beforeEach ->
          animation_callback = jasmine.createSpy()

        describe 'which returns nothing', ->
          finished_callback = null

          beforeEach ->
            animation_callback.andReturn null
            result = helper.animateSlices animation_callback

          it 'should call the jQuery animate method with an empty object', ->
            expect($.fn.animate).toHaveBeenCalledWith {}, $.fn.ramblingSlider.defaults.speed, '', null

          it 'should trigger the rambling:finished event for the last slice', ->
            expect($.fn.animate).toHaveBeenCalledWith {}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)
            expect($.fn.trigger).toHaveBeenCalledWith 'rambling:finished'

          it 'should call the jQuery animate method to be called for each slice', ->
            expect($.fn.animate.callCount).toEqual $.fn.ramblingSlider.defaults.slices

        describe 'which returns an object', ->
          animate = null

          beforeEach ->
            animate = width: 5000
            animation_callback.andReturn animate
            result = helper.animateSlices animation_callback

          it 'should call the jQuery animate method with the returned object', ->
            expect($.fn.animate).toHaveBeenCalledWith animate, $.fn.ramblingSlider.defaults.speed, '', null

    describe 'and calling the animate boxes helper function', ->
      describe 'and a sort callback is given', ->
        sort_callback = null

        beforeEach ->
          sort_callback = jasmine.createSpy()
          result = helper.animateBoxes (->), sort_callback

        it 'should call the sort callback', ->
          expect(sort_callback).toHaveBeenCalled()

      describe 'and an animation callback is given', ->
        animation_callback = null
        finished_callback = null

        beforeEach ->
          animation_callback = jasmine.createSpy()
          animation_callback.andCallFake (callback) -> finished_callback = callback
          result = helper.animateBoxes animation_callback

        it 'should call the animation callback', ->
          expect(animation_callback).toHaveBeenCalledWith jasmine.any(Function)

        it 'should raise the rambling:finished event with the finished callback', ->
          finished_callback()
          expect($.fn.trigger).toHaveBeenCalledWith 'rambling:finished'

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
      expect(rambling_slider).not.toHaveClass "theme-#{$.fn.ramblingSlider.defaults.theme}"

    it 'should add the new theme class', ->
      expect(rambling_slider).toHaveClass "theme-#{theme}"

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
