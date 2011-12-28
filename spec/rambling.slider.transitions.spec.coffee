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
      spyOn options, 'afterChange'
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
      expect(helper.animateBoxesIn2d).not.toBeNull()
      expect(helper.slideUpSlices).not.toBeNull()
      expect(helper.slideDownSlices).not.toBeNull()
      expect(helper.slideUpDownSlices).not.toBeNull()
      expect(helper.foldSlices).not.toBeNull()
      expect(helper.fadeSlices).not.toBeNull()
      expect(helper.fadeBoxes).not.toBeNull()
      expect(helper.rainBoxes).not.toBeNull()
      expect(helper.growBoxes).not.toBeNull()

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
          expect($.fn.css).toHaveBeenCalledWith top: 0, bottom: 'auto'

      describe 'and it is aligned to the bottom', ->
        beforeEach ->
          rambling_slider.ramblingSlider 'option', 'alignBottom', true
          result = helper.animateFullImage ->

        it 'should set the top to auto and the bottom to 0', ->
          expect($.fn.css).toHaveBeenCalledWith top: 'auto', bottom: 0

      describe 'and nothing is returned by the animation set up callback', ->
        beforeEach ->
          result = helper.animateFullImage ->

        it 'should animate the slice width to the width of the slider', ->
          expect($.fn.animate).toHaveBeenCalledWith {width: rambling_slider.width()}, $.fn.ramblingSlider.defaults.speed * 2, '', jasmine.any(Function)

      describe 'and something is returned by the animation set up callback', ->
        animate = null

        beforeEach ->
          animate = height: 500
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
            expect($.fn.animate).toHaveBeenCalledWith {}, $.fn.ramblingSlider.defaults.speed, '', undefined

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
            expect($.fn.animate).toHaveBeenCalledWith animate, $.fn.ramblingSlider.defaults.speed, '', undefined

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

    describe 'and calling the animate boxes in 2d helper function', ->
      beforeEach ->
        spyOn($.fn, 'as2dArray').andCallFake -> @

      describe 'and an animation set up callback is given', ->
        set_up_callback = null
        set_up_options = null

        beforeEach ->
          set_up_options = {opacity: 5000}
          set_up_callback = jasmine.createSpy()
          set_up_callback.andReturn set_up_options
          timeout_spy.andCallFake (callback) -> callback()

          result = helper.animateBoxesIn2d set_up_callback

        it 'should execute the set up callback the expected amount of times', ->
          expect(set_up_callback.callCount).toEqual $.fn.ramblingSlider.defaults.boxRows * $.fn.ramblingSlider.defaults.boxCols

        it 'should not pass a finished callback to the jQuery animate for the first boxes', ->
          expect($.fn.animate).toHaveBeenCalledWith set_up_options, $.fn.ramblingSlider.defaults.speed / 1.3, '', undefined

        it 'should pass a finished callback to the jQuery animate for the last box', ->
          expect($.fn.animate).toHaveBeenCalledWith set_up_options, $.fn.ramblingSlider.defaults.speed / 1.3, '', jasmine.any(Function)

      describe 'and a sort callback is given', ->
        custom_sort_callback = null

        beforeEach ->
          custom_sort_callback = jasmine.createSpy()
          custom_sort_callback.andCallFake -> @
          result = helper.animateBoxesIn2d (->), custom_sort_callback

        it 'should call the sort callback', ->
          expect(custom_sort_callback).toHaveBeenCalled()

        it 'should divide the boxes into a bidimensional array', ->
          expect($.fn.as2dArray).toHaveBeenCalled()

      describe 'and no sort callback is given', ->
        beforeEach ->
          result = helper.animateBoxesIn2d (->)

        it 'should divide the boxes into a bidimensional array', ->
          expect($.fn.as2dArray).toHaveBeenCalled()

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
        expect($.fn.css).toHaveBeenCalledWith top: 0

      it 'should sort the slices', ->
        expect(sort_callback).toHaveBeenCalled()

      it 'should set the height to the slider height and the opacity to 1', ->
        timeout_callback()
        expect($.fn.animate).toHaveBeenCalledWith {height: rambling_slider.height(), opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

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
        expect($.fn.css).toHaveBeenCalledWith bottom: 0

      it 'should sort the slices', ->
        expect(sort_callback).toHaveBeenCalled()

      it 'should set the height to the slider height and the opacity to 1', ->
        timeout_callback()
        expect($.fn.animate).toHaveBeenCalledWith {height: rambling_slider.height(), opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

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
        expect($.fn.animate).toHaveBeenCalledWith {height: rambling_slider.height(), opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

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
        expect($.fn.css).toHaveBeenCalledWith top: 0, height: '100%', width: 0

      it 'should set the height to the slider width and the opacity to 1', ->
        timeout_callback()
        expect($.fn.animate).toHaveBeenCalledWith {width: rambling_slider.width(), opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

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
        expect($.fn.css).toHaveBeenCalledWith height: rambling_slider.height()

      it 'should set the opacity to 1', ->
        timeout_callback()
        expect($.fn.animate).toHaveBeenCalledWith {opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

  describe 'when running the transitions', ->
    animation_helpers = null
    sort_callback = null
    animation_set_up_callback = null
    image_transitions = null
    all_around_transitions = [
      { name: 'sliceDown', short_name: 'down', helper: 'slideDownSlices', helper_name: 'slide down' },
      { name: 'sliceUp', short_name: 'up', helper: 'slideUpSlices', helper_name: 'slide up' },
      { name: 'sliceUpDown', short_name: 'up down', helper: 'slideUpDownSlices', helper_name: 'slide up down' },
      { name: 'sliceFade', short_name: 'fade', helper: 'fadeSlices', helper_name: 'fading' },
      { name: 'fold', short_name: 'fold', helper: 'foldSlices', helper_name: 'folding' },
    ]
    box_transitions = [
      { name: 'boxRain', short_name: 'rain', helper: 'rainBoxes' },
      { name: 'boxGrow', short_name: 'grow', helper: 'growBoxes' },
    ]

    beforeEach ->
      sort_callback_setter = (callback) -> sort_callback = callback
      animation_helpers =
        animateFullImage: ->
        fadeBoxes: ->
        rainBoxes: ->
        growBoxes: ->

      spyOn($.fn, 'css').andCallFake -> @
      spyOn($.fn, 'animate').andCallFake -> @
      spyOn(animation_helpers, 'animateFullImage').andCallFake (callback) -> animation_set_up_callback = callback
      spyOn animation_helpers, 'fadeBoxes'
      spyOn animation_helpers, 'rainBoxes'
      spyOn animation_helpers, 'growBoxes'

      $.each all_around_transitions, (index, element) ->
        animation_helpers[element.helper] = ->
        spyOn(animation_helpers, element.helper).andCallFake sort_callback_setter

      image_transitions = $.fn.ramblingSlider.defaults.imageTransitions

    $.each all_around_transitions, (index, element) ->
      describe "and executing a #{element.helper_name} of slices", ->
        describe 'from left to right', ->
          beforeEach ->
            image_transitions["#{element.name}Right"].apply animation_helpers

          it "should call the #{element.helper_name} slices helper", ->
            expect(animation_helpers[element.helper]).toHaveBeenCalled()

        describe 'from right to left', ->
          beforeEach ->
            image_transitions["#{element.name}Left"].apply animation_helpers

          it "should call the #{element.helper_name} slices helper with the reverse callback", ->
            expect(animation_helpers[element.helper]).toHaveBeenCalledWith $.fn.reverse

        describe 'from outer to inner', ->
          beforeEach ->
            image_transitions["#{element.name}OutIn"].apply animation_helpers

          it "should call the #{element.helper_name} slices helper with the sort out in callback", ->
            expect(animation_helpers[element.helper]).toHaveBeenCalledWith $.fn.sortOutIn

        describe 'from inner to outer', ->
          beforeEach ->
            image_transitions["#{element.name}InOut"].apply animation_helpers

          it "should call the #{element.helper_name} slices helper", ->
            expect(animation_helpers[element.helper]).toHaveBeenCalledWith $.fn.sortInOut

        describe 'randomly', ->
          beforeEach ->
            image_transitions["#{element.name}Random"].apply animation_helpers

          it "should call the #{element.helper_name} slices helper with the shuffle callback", ->
            expect(animation_helpers[element.helper]).toHaveBeenCalledWith $.fn.shuffle

    describe 'and executing a full image fade in', ->
      beforeEach ->
        image_transitions.fadeIn.apply animation_helpers
        result = animation_set_up_callback.apply $('<div></div>'), [rambling_slider]

      it 'should call the animate full image helper', ->
        expect(animation_helpers.animateFullImage).toHaveBeenCalled()

      it 'should set the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: rambling_slider.width(), position: 'absolute', top: 0, left: 0

      it 'should return the expected animation', ->
        expect(result).toEqual { opacity: '1' }

    describe 'and executing a full image fade out', ->
      beforeEach ->
        image_transitions.fadeOut.apply animation_helpers
        result = animation_set_up_callback.apply $('<div></div>'), [rambling_slider]

      it 'should call the animate full image helper', ->
        expect(animation_helpers.animateFullImage).toHaveBeenCalled()

      it 'should set the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: rambling_slider.width(), position: 'absolute', top: 0, left: 0

      it 'should return the expected animation', ->
        expect(result).toEqual { opacity: '1' }

    describe 'and executing a full image rollover right', ->
      beforeEach ->
        image_transitions.rolloverRight.apply animation_helpers
        result = animation_set_up_callback.apply $('<div></div>'), [rambling_slider]

      it 'should call the animate full image helper', ->
        expect(animation_helpers.animateFullImage).toHaveBeenCalled()

      it 'should set the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: 0, opacity: '1'

      it 'should return the expected animation', ->
        expect(result).toBeUndefined()

    describe 'and executing a full image rollover left', ->
      settings = null

      beforeEach ->
        settings =
          speed: 500

        image_transitions.rolloverLeft.apply animation_helpers
        result = animation_set_up_callback.apply $('<div><img src="" alt="" /></div>'), [rambling_slider, settings]

      it 'should call the animate full image helper', ->
        expect(animation_helpers.animateFullImage).toHaveBeenCalled()

      it 'should set the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: 0, opacity: '1', left: 'auto', right: 0

      it 'should set the style to the image', ->
        expect($.fn.css).toHaveBeenCalledWith left: -rambling_slider.width()

      it 'should animate the image', ->
        expect($.fn.animate).toHaveBeenCalledWith {left: 0}, settings.speed * 2

      it 'should return the expected animation', ->
        expect(result).toEqual {width: rambling_slider.width()}

    describe 'and executing a full image slide in right', ->
      settings = null

      beforeEach ->
        settings =
          speed: 500

        image_transitions.slideInRight.apply animation_helpers
        result = animation_set_up_callback.apply $('<div><img src="" alt="" /></div>'), [rambling_slider, settings]

      it 'should call the animate full image helper', ->
        expect(animation_helpers.animateFullImage).toHaveBeenCalled()

      it 'should set the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: 0, opacity: '1'

      it 'should set the style to the image', ->
        expect($.fn.css).toHaveBeenCalledWith left: -rambling_slider.width()

      it 'should animate the image', ->
        expect($.fn.animate).toHaveBeenCalledWith {left: 0}, settings.speed * 2

      it 'should return the expected animation', ->
        expect(result).toEqual {width: rambling_slider.width()}

    describe 'and executing a full image slide in left', ->
      finished_callback = null

      beforeEach ->
        spyOn($.fn, 'bind').andCallFake (event, callback) -> finished_callback = callback
        spyOn $.fn, 'unbind'

        image_transitions.slideInLeft.apply animation_helpers
        result = animation_set_up_callback.apply $('<div></div>'), [rambling_slider]

      it 'should call the animate full image helper', ->
        expect(animation_helpers.animateFullImage).toHaveBeenCalled()

      it 'should set the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: 0, opacity: '1', left: 'auto', right: 0

      it 'should bind to the rambling:finished event', ->
        expect($.fn.bind).toHaveBeenCalledWith 'rambling:finished', jasmine.any(Function)

      describe 'and executing the finished callback', ->
        beforeEach ->
          finished_callback()

        it 'should set the finished style to the slice', ->
          expect($.fn.css).toHaveBeenCalledWith left: 0, right: 'auto'

        it 'should unbind from the rambling:finished event', ->
          expect($.fn.unbind).toHaveBeenCalledWith 'rambling:finished', finished_callback

    $.each box_transitions, (index, element) ->
      describe "and executing a box #{element.short_name}", ->
        beforeEach ->
          image_transitions["#{element.name}Forward"].apply animation_helpers

        it "should #{element.short_name} the boxes with default order", ->
          expect(animation_helpers[element.helper]).toHaveBeenCalledWith

      describe "and executing a reversed box #{element.short_name}", ->
        beforeEach ->
          image_transitions["#{element.name}Reverse"].apply animation_helpers

        it "should #{element.short_name} the boxes with reversed order", ->
          expect(animation_helpers[element.helper]).toHaveBeenCalledWith $.fn.reverse

      describe "and executing a outer to inner box #{element.short_name}", ->
        beforeEach ->
          image_transitions["#{element.name}OutIn"].apply animation_helpers

        it "should #{element.short_name} the boxes from outer to inner", ->
          expect(animation_helpers[element.helper]).toHaveBeenCalledWith $.fn.sortOutIn

      describe "and executing a inner to outer box #{element.short_name}", ->
        beforeEach ->
          image_transitions["#{element.name}InOut"].apply animation_helpers

        it "should #{element.short_name} the boxes from inner to outer", ->
          expect(animation_helpers[element.helper]).toHaveBeenCalledWith $.fn.sortInOut

      describe "and executing a random box #{element.short_name}", ->
        beforeEach ->
          image_transitions["#{element.name}Random"].apply animation_helpers

        it "should #{element.short_name} the boxes randomly", ->
          expect(animation_helpers[element.helper]).toHaveBeenCalledWith $.fn.shuffle
