describe 'Rambling Slider transitions', ->
  result = null

  beforeEach ->
    result = @helpers.createSlider()

  afterEach ->
    @helpers.destroySlider()

  describe 'when extending the available transitions', ->
    options = null
    helper = null

    beforeEach ->
      options =
        effect: 'newTransition'
        afterChange: jasmine.createSpy()
        imageTransitions:
          newTransition: jasmine.createSpy()

      spyOn($.fn, 'trigger').andCallThrough()
      spyOn($.fn, 'css').andCallThrough()

      options.imageTransitions.newTransition.andCallFake -> helper = @

      @helpers.createSlider options
      jasmine.Clock.tick 6000

    it 'is able to execute the new transition', ->
      expect(options.imageTransitions.newTransition).toHaveBeenCalled()

    it 'returns a helper with all the expected functions', ->
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

        it 'creates the expected number of slices', ->
          expect(result.length).toEqual $.fn.ramblingSlider.defaults.slices

        it 'appends all the slices to the animation container', ->
          expect(@ramblingSlider.find('#rambling-animation .rambling-slice')).toEqualJquery result

        it 'sets the expected slice images', ->
          result.find('img').each (index, element) =>
            expect($(element).attr 'src').toEqual @ramblingSlider.find('img.currentSlideElement').next().attr('src')

      describe 'with specific number of slices', ->
        slices = null

        beforeEach ->
          slices = 10
          result = helper.createSlices slices

        it 'creates the expected number of slices', ->
          expect(result.length).toEqual slices

      describe 'with specific slide element', ->
        slideElement = null

        beforeEach ->
          slideElement = @ramblingSlider.find '.slideElement:last'
          result = helper.createSlices $.fn.ramblingSlider.defaults.slices, slideElement

        it 'sets the expected slice images', ->
          result.find('img').each (index, element) ->
            expect($(element).attr 'src').toEqual slideElement.attr('src')

    describe 'and calling the create boxes helper function', ->
      describe 'with no arguments', ->
        beforeEach ->
          result = helper.createBoxes()

        it 'creates the expected number of boxes', ->
          expect(result.length).toEqual $.fn.ramblingSlider.defaults.boxRows * $.fn.ramblingSlider.defaults.boxCols

        it 'appends all the boxes to the animation container', ->
          expect(@ramblingSlider.find('#rambling-animation .rambling-box')).toEqualJquery result

        it 'sets the expected box images', ->
          result.find('img').each (index, element) =>
            expect($(element).attr 'src').toEqual @ramblingSlider.find('img.currentSlideElement').next().attr('src')

      describe 'with specific rows and columns', ->
        rows = null
        columns = null

        beforeEach ->
          rows = 2
          columns = 2
          result = helper.createBoxes rows, columns

        it 'creates the expected number of boxes', ->
          expect(result.length).toEqual rows * columns

    describe 'and calling the get one slice helper function', ->
      describe 'with no arguments', ->
        beforeEach ->
          result = helper.getOneSlice()

        it 'returns only one slice', ->
          expect(result.length).toEqual 1

        it 'appends the slice to the animation container', ->
          expect(@ramblingSlider.find('#rambling-animation .rambling-slice')).toEqualJquery result

        it 'sets the expected slice image', ->
          expect(result.find('img').attr 'src').toEqual @ramblingSlider.find('img.currentSlideElement').next().attr('src')

      describe 'for a specific element', ->
        slideElement = null

        beforeEach ->
          slideElement = @ramblingSlider.find '.slideElement:last'
          result = helper.getOneSlice slideElement

        it 'sets the expected slice image', ->
          expect(result.find('img').attr 'src').toEqual slideElement.attr('src')

    describe 'and calling the animate full image helper function', ->
      beforeEach ->

      describe 'as is', ->
        beforeEach ->
          result = helper.animateFullImage ->

        it 'calls the after change callback', ->
          expect(options.afterChange).toHaveBeenCalled()

        it 'raises the rambling:finished event', ->
          expect($.fn.trigger).toHaveBeenCalledWith 'rambling:finished'

      describe 'and it is aligned to the top', ->
        beforeEach ->
          @ramblingSlider.ramblingSlider 'option', 'alignBottom', false
          result = helper.animateFullImage ->

        it 'sets the top to 0 and the bottom to auto', ->
          expect($.fn.css).toHaveBeenCalledWith top: 0, bottom: 'auto'

      describe 'and it is aligned to the bottom', ->
        beforeEach ->
          @ramblingSlider.ramblingSlider 'option', 'alignBottom', true
          result = helper.animateFullImage ->

        it 'sets the top to auto and the bottom to 0', ->
          expect($.fn.css).toHaveBeenCalledWith top: 'auto', bottom: 0

      describe 'and nothing is returned by the animation set up callback', ->
        beforeEach ->
          result = helper.animateFullImage ->

        it 'animates the slice width to the width of the slider', ->
          expect($.fn.animate).toHaveBeenCalledWith {width: @ramblingSlider.width()}, $.fn.ramblingSlider.defaults.speed * 2, '', jasmine.any(Function)

      describe 'and something is returned by the animation set up callback', ->
        animate = null

        beforeEach ->
          animate = height: 500
          result = helper.animateFullImage -> animate

        it 'animates the slice width to the width of the slider', ->
          expect($.fn.animate).toHaveBeenCalledWith animate, $.fn.ramblingSlider.defaults.speed * 2, '', jasmine.any(Function)

    describe 'and calling the animate slices helper function', ->
      beforeEach ->
        jasmine.Clock.tick 5000

      describe 'and a sort callback is given', ->
        sortCallback = null

        beforeEach ->
          sortCallback = jasmine.createSpy()
          sortCallback.andCallFake -> @
          result = helper.animateSlices (->), sortCallback

        it 'calls the sort callback', ->
          expect(sortCallback).toHaveBeenCalled()

      describe 'and an animate set up callback is given', ->
        beforeEach ->
          $.fn.animate.reset()

        describe 'which returns nothing', ->
          beforeEach ->
            result = helper.animateSlices (-> null)
            jasmine.Clock.tick 1000

          it 'calls the jQuery animate method with an empty object', ->
            expect($.fn.animate).toHaveBeenCalledWith {}, $.fn.ramblingSlider.defaults.speed, '', undefined

          it 'triggers the rambling:finished event for the last slice', ->
            expect($.fn.animate).toHaveBeenCalledWith {}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)
            expect($.fn.trigger).toHaveBeenCalledWith 'rambling:finished'

          it 'calls the jQuery animate method to be called for each slice', ->
            expect($.fn.animate.callCount).toEqual $.fn.ramblingSlider.defaults.slices

        describe 'which returns an object', ->
          beforeEach ->
            result = helper.animateSlices (-> width: 5000)
            jasmine.Clock.tick 1000

          it 'calls the jQuery animate method with the returned object', ->
            expect($.fn.animate).toHaveBeenCalledWith {width: 5000}, $.fn.ramblingSlider.defaults.speed, '', undefined

    describe 'and calling the animate boxes helper function', ->
      describe 'and a sort callback is given', ->
        sortCallback = null

        beforeEach ->
          sortCallback = jasmine.createSpy()
          result = helper.animateBoxes (->), sortCallback

        it 'calls the sort callback', ->
          expect(sortCallback).toHaveBeenCalled()

      describe 'and an animation callback is given', ->
        animationCallback = null
        finishedCallback = null

        beforeEach ->
          animationCallback = jasmine.createSpy()
          animationCallback.andCallFake (callback) -> finishedCallback = callback
          result = helper.animateBoxes animationCallback

        it 'calls the animation callback', ->
          expect(animationCallback).toHaveBeenCalledWith jasmine.any(Function)

        it 'raises the rambling:finished event with the finished callback', ->
          finishedCallback()
          expect($.fn.trigger).toHaveBeenCalledWith 'rambling:finished'

    describe 'and calling the animate boxes in 2d helper function', ->
      beforeEach ->
        spyOn($.fn, 'as2dArray').andCallFake -> @

      describe 'and an animation set up callback is given', ->
        setUpCallback = null
        setUpOptions = null

        beforeEach ->
          setUpOptions = {opacity: 5000}
          setUpCallback = jasmine.createSpy()
          setUpCallback.andReturn setUpOptions

          result = helper.animateBoxesIn2d setUpCallback
          jasmine.Clock.tick 5000

        it 'executes the set up callback the expected amount of times', ->
          expect(setUpCallback.callCount).toEqual $.fn.ramblingSlider.defaults.boxRows * $.fn.ramblingSlider.defaults.boxCols

        it 'does not pass a finished callback to the jQuery animate for the first boxes', ->
          expect($.fn.animate).toHaveBeenCalledWith setUpOptions, $.fn.ramblingSlider.defaults.speed / 1.3, '', undefined

        it 'passs a finished callback to the jQuery animate for the last box', ->
          expect($.fn.animate).toHaveBeenCalledWith setUpOptions, $.fn.ramblingSlider.defaults.speed / 1.3, '', jasmine.any(Function)

      describe 'and a sort callback is given', ->
        customSortCallback = null

        beforeEach ->
          customSortCallback = jasmine.createSpy()
          customSortCallback.andCallFake -> @
          result = helper.animateBoxesIn2d (->), customSortCallback

        it 'calls the sort callback', ->
          expect(customSortCallback).toHaveBeenCalled()

        it 'divides the boxes into a bidimensional array', ->
          expect($.fn.as2dArray).toHaveBeenCalled()

      describe 'and no sort callback is given', ->
        beforeEach ->
          result = helper.animateBoxesIn2d (->)

        it 'divides the boxes into a bidimensional array', ->
          expect($.fn.as2dArray).toHaveBeenCalled()

    describe 'and calling the slide down slices helper function', ->
      sortCallback = null

      beforeEach ->
        sortCallback = jasmine.createSpy()
        sortCallback.andCallFake -> @

        result = helper.slideDownSlices sortCallback

      it 'aligns the slices to the top', ->
        jasmine.Clock.tick 5000
        expect($.fn.css).toHaveBeenCalledWith top: 0

      it 'sorts the slices', ->
        expect(sortCallback).toHaveBeenCalled()

      it 'sets the height to the slider height and the opacity to 1', ->
        jasmine.Clock.tick 5000
        expect($.fn.animate).toHaveBeenCalledWith {height: @ramblingSlider.height(), opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

    describe 'and calling the slide up slices helper function', ->
      sortCallback = null

      beforeEach ->
        sortCallback = jasmine.createSpy()
        sortCallback.andCallFake -> @

        result = helper.slideUpSlices sortCallback

      it 'aligns the slices to the bottom', ->
        jasmine.Clock.tick 5000
        expect($.fn.css).toHaveBeenCalledWith bottom: 0

      it 'sorts the slices', ->
        expect(sortCallback).toHaveBeenCalled()

      it 'sets the height to the slider height and the opacity to 1', ->
        jasmine.Clock.tick 5000
        expect($.fn.animate).toHaveBeenCalledWith {height: @ramblingSlider.height(), opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

    describe 'and calling the slide up down slices helper function', ->
      sortCallback = null

      beforeEach ->
        sortCallback = jasmine.createSpy()
        sortCallback.andCallFake -> @

        result = helper.slideUpDownSlices sortCallback

      it 'sorts the slices', ->
        expect(sortCallback).toHaveBeenCalled()

      it 'sets the height to the slider height and the opacity to 1', ->
        jasmine.Clock.tick 5000
        expect($.fn.animate).toHaveBeenCalledWith {height: @ramblingSlider.height(), opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

    describe 'and calling the slide fold slices helper function', ->
      sortCallback = null

      beforeEach ->
        sortCallback = jasmine.createSpy()
        sortCallback.andCallFake -> @

        result = helper.foldSlices sortCallback

      it 'sorts the slices', ->
        expect(sortCallback).toHaveBeenCalled()

      it 'aligns the slices to the bottom', ->
        jasmine.Clock.tick 5000
        expect($.fn.css).toHaveBeenCalledWith top: 0, height: '100%', width: 0

      it 'sets the height to the slider width and the opacity to 1', ->
        jasmine.Clock.tick 5000
        expect($.fn.animate).toHaveBeenCalledWith {width: @ramblingSlider.width(), opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

    describe 'and calling the slide fade slices helper function', ->
      sortCallback = null

      beforeEach ->
        sortCallback = jasmine.createSpy()
        sortCallback.andCallFake -> @

        result = helper.fadeSlices sortCallback

      it 'sorts the slices', ->
        expect(sortCallback).toHaveBeenCalled()

      it 'aligns the slices to the bottom', ->
        jasmine.Clock.tick 5000
        expect($.fn.css).toHaveBeenCalledWith height: @ramblingSlider.height()

      it 'sets the opacity to 1', ->
        jasmine.Clock.tick 5000
        expect($.fn.animate).toHaveBeenCalledWith {opacity: '1'}, $.fn.ramblingSlider.defaults.speed, '', jasmine.any(Function)

  describe 'when running the transitions', ->
    animationHelpers = null
    sortCallback = null
    animationSetUpCallback = null
    imageTransitions = null
    allAroundTransitions = [
      { name: 'sliceDown', shortName: 'down', helper: 'slideDownSlices', helperName: 'slide down' }
      { name: 'sliceUp', shortName: 'up', helper: 'slideUpSlices', helperName: 'slide up' }
      { name: 'sliceUpDown', shortName: 'up down', helper: 'slideUpDownSlices', helperName: 'slide up down' }
      { name: 'sliceFade', shortName: 'fade', helper: 'fadeSlices', helperName: 'fading' }
      { name: 'fold', shortName: 'fold', helper: 'foldSlices', helperName: 'folding' }
    ]
    boxTransitions = [
      { name: 'boxRain', shortName: 'rain', helper: 'rainBoxes' }
      { name: 'boxGrow', shortName: 'grow', helper: 'growBoxes' }
    ]

    beforeEach ->
      sortCallbackSetter = (callback) -> sortCallback = callback

      sortedHelpers = (element.helper for element in allAroundTransitions)

      animationHelpers = jasmine.createSpyObj 'animation', [
        'animateFullImage'
        'fadeBoxes'
        'rainBoxes'
        'growBoxes'
        sortedHelpers...
      ]

      spyOn($.fn, 'css').andCallFake -> @

      animationHelpers.animateFullImage.andCallFake (callback) -> animationSetUpCallback = callback
      animationHelpers[helper].andCallFake sortCallbackSetter for helper in sortedHelpers

      imageTransitions = $.fn.ramblingSlider.defaults.imageTransitions

    $.each allAroundTransitions, (index, element) ->
      describe "and executing a #{element.helperName} of slices", ->
        describe 'from left to right', ->
          beforeEach ->
            imageTransitions["#{element.name}Right"].apply animationHelpers

          it "calls the #{element.helperName} slices helper", ->
            expect(animationHelpers[element.helper]).toHaveBeenCalled()

        describe 'from right to left', ->
          beforeEach ->
            imageTransitions["#{element.name}Left"].apply animationHelpers

          it "calls the #{element.helperName} slices helper with the reverse callback", ->
            expect(animationHelpers[element.helper]).toHaveBeenCalledWith $.fn.reverse

        describe 'from outer to inner', ->
          beforeEach ->
            imageTransitions["#{element.name}OutIn"].apply animationHelpers

          it "calls the #{element.helperName} slices helper with the sort out in callback", ->
            expect(animationHelpers[element.helper]).toHaveBeenCalledWith $.fn.sortOutIn

        describe 'from inner to outer', ->
          beforeEach ->
            imageTransitions["#{element.name}InOut"].apply animationHelpers

          it "calls the #{element.helperName} slices helper", ->
            expect(animationHelpers[element.helper]).toHaveBeenCalledWith $.fn.sortInOut

        describe 'randomly', ->
          beforeEach ->
            imageTransitions["#{element.name}Random"].apply animationHelpers

          it "calls the #{element.helperName} slices helper with the shuffle callback", ->
            expect(animationHelpers[element.helper]).toHaveBeenCalledWith $.fn.shuffle

    describe 'and executing a full image fade in', ->
      beforeEach ->
        imageTransitions.fadeIn.apply animationHelpers
        result = animationSetUpCallback.apply $('<div></div>'), [@ramblingSlider]

      it 'calls the animate full image helper', ->
        expect(animationHelpers.animateFullImage).toHaveBeenCalled()

      it 'sets the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: @ramblingSlider.width(), position: 'absolute', top: 0, left: 0

      it 'returns the expected animation', ->
        expect(result).toEqual { opacity: '1' }

    describe 'and executing a full image fade out', ->
      beforeEach ->
        imageTransitions.fadeOut.apply animationHelpers
        result = animationSetUpCallback.apply $('<div></div>'), [@ramblingSlider]

      it 'calls the animate full image helper', ->
        expect(animationHelpers.animateFullImage).toHaveBeenCalled()

      it 'sets the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: @ramblingSlider.width(), position: 'absolute', top: 0, left: 0

      it 'returns the expected animation', ->
        expect(result).toEqual { opacity: '1' }

    describe 'and executing a full image rollover right', ->
      beforeEach ->
        imageTransitions.rolloverRight.apply animationHelpers
        result = animationSetUpCallback.apply $('<div></div>'), [@ramblingSlider]

      it 'calls the animate full image helper', ->
        expect(animationHelpers.animateFullImage).toHaveBeenCalled()

      it 'sets the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: 0, opacity: '1'

      it 'returns the expected animation', ->
        expect(result).toBeUndefined()

    describe 'and executing a full image rollover left', ->
      settings = null

      beforeEach ->
        settings =
          speed: 500

        imageTransitions.rolloverLeft.apply animationHelpers
        result = animationSetUpCallback.apply $('<div><img src="" alt="" /></div>'), [@ramblingSlider, settings]

      it 'calls the animate full image helper', ->
        expect(animationHelpers.animateFullImage).toHaveBeenCalled()

      it 'sets the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: 0, opacity: '1', left: 'auto', right: 0

      it 'sets the style to the image', ->
        expect($.fn.css).toHaveBeenCalledWith left: -@ramblingSlider.width()

      it 'animates the image', ->
        expect($.fn.animate).toHaveBeenCalledWith {left: 0}, settings.speed * 2

      it 'returns the expected animation', ->
        expect(result).toEqual {width: @ramblingSlider.width()}

    describe 'and executing a full image slide in right', ->
      settings = null

      beforeEach ->
        settings =
          speed: 500

        imageTransitions.slideInRight.apply animationHelpers
        result = animationSetUpCallback.apply $('<div><img src="" alt="" /></div>'), [@ramblingSlider, settings]

      it 'calls the animate full image helper', ->
        expect(animationHelpers.animateFullImage).toHaveBeenCalled()

      it 'sets the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: 0, opacity: '1'

      it 'sets the style to the image', ->
        expect($.fn.css).toHaveBeenCalledWith left: -@ramblingSlider.width()

      it 'animates the image', ->
        expect($.fn.animate).toHaveBeenCalledWith {left: 0}, settings.speed * 2

      it 'returns the expected animation', ->
        expect(result).toEqual {width: @ramblingSlider.width()}

    describe 'and executing a full image slide in left', ->
      finishedCallback = null

      beforeEach ->
        spyOn($.fn, 'bind').andCallFake (event, callback) -> finishedCallback = callback
        spyOn $.fn, 'unbind'

        imageTransitions.slideInLeft.apply animationHelpers
        result = animationSetUpCallback.apply $('<div></div>'), [@ramblingSlider]

      it 'calls the animate full image helper', ->
        expect(animationHelpers.animateFullImage).toHaveBeenCalled()

      it 'sets the style to the slice', ->
        expect($.fn.css).toHaveBeenCalledWith height: '100%', width: 0, opacity: '1', left: 'auto', right: 0

      it 'binds to the rambling:finished event', ->
        expect($.fn.bind).toHaveBeenCalledWith 'rambling:finished', jasmine.any(Function)

      describe 'and executing the finished callback', ->
        beforeEach ->
          finishedCallback()

        it 'sets the finished style to the slice', ->
          expect($.fn.css).toHaveBeenCalledWith left: 0, right: 'auto'

        it 'unbinds from the rambling:finished event', ->
          expect($.fn.unbind).toHaveBeenCalledWith 'rambling:finished', finishedCallback

    $.each boxTransitions, (index, element) ->
      describe "and executing a box #{element.shortName}", ->
        beforeEach ->
          imageTransitions["#{element.name}Forward"].apply animationHelpers

        it "#{element.shortName}s the boxes with default order", ->
          expect(animationHelpers[element.helper]).toHaveBeenCalledWith

      describe "and executing a reversed box #{element.shortName}", ->
        beforeEach ->
          imageTransitions["#{element.name}Reverse"].apply animationHelpers

        it "#{element.shortName}s the boxes with reversed order", ->
          expect(animationHelpers[element.helper]).toHaveBeenCalledWith $.fn.reverse

      describe "and executing a outer to inner box #{element.shortName}", ->
        beforeEach ->
          imageTransitions["#{element.name}OutIn"].apply animationHelpers

        it "#{element.shortName}s the boxes from outer to inner", ->
          expect(animationHelpers[element.helper]).toHaveBeenCalledWith $.fn.sortOutIn

      describe "and executing a inner to outer box #{element.shortName}", ->
        beforeEach ->
          imageTransitions["#{element.name}InOut"].apply animationHelpers

        it "#{element.shortName}s the boxes from inner to outer", ->
          expect(animationHelpers[element.helper]).toHaveBeenCalledWith $.fn.sortInOut

      describe "and executing a random box #{element.shortName}", ->
        beforeEach ->
          imageTransitions["#{element.name}Random"].apply animationHelpers

        it "#{element.shortName}s the boxes randomly", ->
          expect(animationHelpers[element.helper]).toHaveBeenCalledWith $.fn.shuffle
