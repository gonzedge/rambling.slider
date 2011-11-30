global.window = require('jsdom').jsdom().createWindow()
global.jQuery = require 'jquery'

require './matchers/jquery.matcher'
require '../src/array_extensions'
require '../src/string_extensions'
require '../src/jquery.plugins'
require '../src/rambling.slider'
require '../src/rambling.slider.transitions'

$ = jQuery

describe 'Rambling Slider transitions', ->
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
      spyOn($.fn, 'css').andCallThrough()
      spyOn($.fn, 'animate').andCallFake (options, speed, easing, callback) -> callback() if callback
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
            $.fn.animate.reset()
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

    describe 'and calling the slide down slices helper function', ->
      sort_callback = null
      timeout_callback = null

      beforeEach ->
        timeout_spy.andCallFake (callback) -> timeout_callback = callback
        sort_callback = jasmine.createSpy()
        sort_callback.andCallFake -> @

        result = helper.slideDownSlices sort_callback

      it 'should align the slices to the top', ->
        timeout_callback()
        expect($.fn.css).toHaveBeenCalledWith top: '0px'

      it 'should sort the slices', ->
        expect(sort_callback).toHaveBeenCalled()

      it 'should set the height to the slider height and the opacity to 1', ->
        timeout_callback()
        expect($.fn.animate).toHaveBeenCalledWith {height: "#{rambling_slider.height()}px", opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

    describe 'and calling the slide up slices helper function', ->
      sort_callback = null
      timeout_callback = null

      beforeEach ->
        timeout_spy.andCallFake (callback) -> timeout_callback = callback
        sort_callback = jasmine.createSpy()
        sort_callback.andCallFake -> @

        result = helper.slideUpSlices sort_callback

      it 'should align the slices to the bottom', ->
        timeout_callback()
        expect($.fn.css).toHaveBeenCalledWith bottom: '0px'

      it 'should sort the slices', ->
        expect(sort_callback).toHaveBeenCalled()

      it 'should set the height to the slider height and the opacity to 1', ->
        timeout_callback()
        expect($.fn.animate).toHaveBeenCalledWith {height: "#{rambling_slider.height()}px", opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

    describe 'and calling the slide up down slices helper function', ->
      sort_callback = null
      timeout_callback = null

      beforeEach ->
        timeout_spy.andCallFake (callback) -> timeout_callback = callback
        sort_callback = jasmine.createSpy()
        sort_callback.andCallFake -> @

        result = helper.slideUpDownSlices sort_callback

      it 'should sort the slices', ->
        expect(sort_callback).toHaveBeenCalled()

      it 'should set the height to the slider height and the opacity to 1', ->
        timeout_callback()
        expect($.fn.animate).toHaveBeenCalledWith {height: "#{rambling_slider.height()}px", opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

    describe 'and calling the slide fold slices helper function', ->
      sort_callback = null
      timeout_callback = null

      beforeEach ->
        timeout_spy.andCallFake (callback) -> timeout_callback = callback
        sort_callback = jasmine.createSpy()
        sort_callback.andCallFake -> @

        result = helper.foldSlices sort_callback

      it 'should sort the slices', ->
        expect(sort_callback).toHaveBeenCalled()

      it 'should align the slices to the bottom', ->
        timeout_callback()
        expect($.fn.css).toHaveBeenCalledWith top: '0px', height: '100%', width: '0px'

      it 'should set the height to the slider width and the opacity to 1', ->
        timeout_callback()
        expect($.fn.animate).toHaveBeenCalledWith {width: "#{rambling_slider.width()}px", opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

    describe 'and calling the slide fade slices helper function', ->
      sort_callback = null
      timeout_callback = null

      beforeEach ->
        timeout_spy.andCallFake (callback) -> timeout_callback = callback
        sort_callback = jasmine.createSpy()
        sort_callback.andCallFake -> @

        result = helper.fadeSlices sort_callback

      it 'should sort the slices', ->
        expect(sort_callback).toHaveBeenCalled()

      it 'should align the slices to the bottom', ->
        timeout_callback()
        expect($.fn.css).toHaveBeenCalledWith height: "#{rambling_slider.height()}px"

      it 'should set the opacity to 1', ->
        timeout_callback()
        expect($.fn.animate).toHaveBeenCalledWith {opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)
