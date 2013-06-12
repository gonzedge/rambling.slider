describe 'Rambling Slider', ->
  result = null
  intervalSpy = null
  intervalCallback = null
  timeoutSpy = null
  fakeTimer = {}

  beforeEach ->
    timeoutSpy = spyOn window, 'setTimeout'
    intervalSpy = spyOn window, 'setInterval'
    intervalSpy.andCallFake (callback, timeout) ->
      intervalCallback = callback
      fakeTimer

    spyOn window, 'clearInterval'

    result = @helpers.createSlider()

  afterEach ->
    @helpers.destroySlider()

  it 'returns the jQuery Array for method chaining', ->
    expect(result).toEqualJquery @ramblingSlider

  it 'sets the first image as the current slide element', ->
    expect(@ramblingSlider).toContainElementWithClass 'currentSlideElement'
    expect(@ramblingSlider.find '.currentSlideElement').toEqualJquery @ramblingSlider.find('img').first()

  it 'adds all the expected html elements', ->
    expect(@ramblingSlider).toContainElementWithClass 'rambling-caption'
    expect(@ramblingSlider).toContainElementWithClass 'rambling-directionNav'
    expect(@ramblingSlider).toContainElementWithClass 'rambling-controlNav'

  it 'adds the animation container element', ->
    expect(@ramblingSlider).toContainElementWithId 'rambling-animation'

  it 'adds the "ramblingSlider" class', ->
    expect(@ramblingSlider).toHaveClass 'ramblingSlider'

  it 'adds the slider data', ->
    expect(@ramblingSlider).toHaveData 'rambling:slider'
    expect(@ramblingSlider).toHaveData 'rambling:vars'

  it 'does not show the direction nav', ->
    expect(@ramblingSlider.find('.rambling-directionNav').is(':visible')).toBeFalsy()

  it 'adds the expected amount of navigation controls', ->
    expect(@ramblingSlider.find('.rambling-controlNav a').length).toEqual @ramblingSlider.find('.slideElement').length

  it 'does not pause the slider', ->
    expect(@ramblingSlider.data('rambling:vars').paused).toBeFalsy()

  it 'sets the default theme', ->
    expect(@sliderWrapper).toHaveClass "theme-#{$.fn.ramblingSlider.defaults.theme}"

  describe 'when the slider has only one slide', ->
    beforeEach ->
      @helpers.createSlider sliderTemplate: '<div><img src="image1.jpg" alt="image1"/></div>'

    it 'never shows the direction nav', ->
      expect(@ramblingSlider.find('rambling-directionNav').is(':visible')).toBeFalsy()

      @ramblingSlider.trigger 'mouseenter', type: 'mouseenter'
      expect(@ramblingSlider.find('rambling-directionNav').is(':visible')).toBeFalsy()

  describe 'when the slider is adaptive', ->
    beforeEach ->
      @helpers.createSlider adaptImages: true

    it 'adds the "adaptingSlider" class', ->
      expect(@ramblingSlider).toHaveClass 'adaptingSlider'

    describe 'and the slider is destroyed', ->
      beforeEach ->
        @ramblingSlider.ramblingSlider 'destroy'

      it 'removes the "adaptingSlider" class', ->
        expect(@ramblingSlider).not.toHaveClass 'adaptingSlider'

  describe 'when the startSlide is not the default', ->
    slide = 1

    beforeEach ->
      @helpers.createSlider startSlide: slide

    it 'sets the current slide index', ->
      expect(@ramblingSlider.data('rambling:vars').currentSlide).toEqual slide

    it 'sets the corresponding image as the current slide element', ->
      expect(@ramblingSlider.find '.currentSlideElement').toEqualJquery @ramblingSlider.find('img.slideElement[alt=image2]')

  describe 'when the slider has links', ->
    beforeEach ->
      @helpers.createSlider sliderTemplate: '<div id="#slider"><a href="a"><img src="image1.jpg" alt="image1" /></a><a href="b"><img src="image2.jpg" alt="image2" /></a><a href="c"><img src="image3.jpg" alt="image3" /></a></div>'

    it 'displays the first link as a block', ->
      expect(@ramblingSlider.find('#rambling-animation .rambling-imageLink:first').css('display')).toBe 'block'

  describe 'when clicking any navigation control', ->
    beforeEach ->
      @helpers.createSlider effect: 'sliceUpRight'
      timeoutSpy.andCallFake => @ramblingSlider.trigger 'rambling:finished'
      @ramblingSlider.find('.rambling-controlNav a').last().click()

    it 'sets the current slide index', ->
      expect(@ramblingSlider.data('rambling:vars').currentSlide).toEqual @ramblingSlider.find('.slideElement').length - 1

    it 'sets the corresponding current slide element', ->
      expect(@ramblingSlider.find('.currentSlideElement')).toEqualJquery @ramblingSlider.find('.slideElement').last()

  describe 'when hovering into the slider', ->
    beforeEach ->
      @ramblingSlider.trigger 'mouseenter'

    it 'shows the direction nav', ->
      expect(@ramblingSlider.find('.rambling-directionNav').is(':visible')).toBeTruthy()

    it 'pauses the slider', ->
      expect(@ramblingSlider.data('rambling:vars').paused).toBeTruthy()

    describe 'and hovering out', ->
      beforeEach ->
        @ramblingSlider.trigger 'mouseleave'

      it 'hides the direction nav', ->
        expect(@ramblingSlider.find('.rambling-directionNav').is(':visible')).toBeFalsy()

      it 'unpauses the slider', ->
        expect(@ramblingSlider.data('rambling:vars').paused).toBeFalsy()

    describe 'and the pauseOnHover option is false', ->
      beforeEach ->
        @ramblingSlider.trigger 'mouseleave'
        @helpers.createSlider pauseOnHover: false
        @ramblingSlider.trigger 'mouseenter'

      it 'does not pause the slider', ->
        expect(@ramblingSlider.data('rambling:vars').paused).toBeFalsy()

  describe 'when passing the slider callbacks', ->
    settings = null

    beforeEach ->
      settings = jasmine.createSpyObj 'settings', [
        'beforeChange'
        'afterChange'
        'slideshowEnd'
        'lastSlide'
        'afterLoad'
      ]
      settings.effect = 'sliceUpRight'

      @helpers.createSlider settings

    it 'calls the afterLoad immediately after creation', ->
      expect(settings.afterLoad).toHaveBeenCalled()

    describe 'and the animation is finished', ->
      beforeEach ->
        @ramblingSlider.trigger 'rambling:finished'

      it 'calls afterChange callback', ->
        expect(settings.afterChange).toHaveBeenCalled()

    describe 'and the first slide is run', ->
      beforeEach ->
        intervalCallback()

      it 'calls the beforeChange callback', ->
        expect(settings.beforeChange).toHaveBeenCalled()

    describe 'and the last slide is run', ->
      beforeEach ->
        @ramblingSlider.ramblingSlider 'slide', @ramblingSlider.find('.slideElement').length - 1
        intervalCallback()

      it 'calls the lastSlide callback', ->
        expect(settings.lastSlide).toHaveBeenCalled()

    describe 'and the slideshow is going to begin again', ->
      beforeEach ->
        @ramblingSlider.ramblingSlider 'slide', @ramblingSlider.find('.slideElement').length - 1
        intervalCallback()
        intervalCallback()

      it 'calls the slideshowEnd callback', ->
        expect(settings.slideshowEnd).toHaveBeenCalled()

  describe 'when trying to initialize an already initialized slider', ->
    describe 'without any options', ->
      it 'throws an already initialized error', ->
        expect(=> @ramblingSlider.ramblingSlider()).toThrow 'Slider already initialized.'

    describe 'and passing some new options', ->
      it 'throws an already initialized error', ->
        expect(=> @ramblingSlider.ramblingSlider {startSlide: 2, effect: 'sliceUp'}).toThrow 'Slider already initialized.'

  # Methods
  describe 'when getting the effect', ->
    it 'returns the default one', ->
      expect(@ramblingSlider.ramblingSlider 'effect').toEqual $.fn.ramblingSlider.defaults.effect

    describe 'when set on initialization', ->
      effect = 'boxRain'

      beforeEach ->
        @helpers.createSlider effect: effect

      it 'returns the one previously set', ->
        expect(@ramblingSlider.ramblingSlider 'effect').toEqual effect

  describe 'when setting the effect', ->
    effect = null

    beforeEach ->
      effect = 'fade'
      result = @ramblingSlider.ramblingSlider 'effect', effect

    it 'returns the jQuery Array for method chaining', ->
      expect(result).toEqualJquery @ramblingSlider

    it 'sets the effect', ->
      expect(@ramblingSlider.ramblingSlider 'effect').toEqual effect

  describe 'when stopping the slider', ->
    beforeEach ->
      result = @ramblingSlider.ramblingSlider 'stop'

    it 'returns the jQuery Array for method chaining', ->
      expect(result).toEqualJquery @ramblingSlider

    it 'stops the slider', ->
      expect(@ramblingSlider.data('rambling:vars').stopped).toBeTruthy()

    describe 'when starting the slider after stopped', ->
      beforeEach ->
        @ramblingSlider.ramblingSlider 'start'

      it 'starts the slider', ->
        expect(@ramblingSlider.data('rambling:vars').stopped).toBeFalsy()

  describe 'when starting the slider', ->
    beforeEach ->
      result = @ramblingSlider.ramblingSlider 'start'

    it 'returns the jQuery Array for method chaining', ->
      expect(result).toEqualJquery @ramblingSlider

    it 'stops the slider', ->
      expect(@ramblingSlider.data('rambling:vars').stopped).toBeFalsy()

    describe 'when stopping the slider after started', ->
      beforeEach ->
        @ramblingSlider.ramblingSlider 'stop'

      it 'starts the slider', ->
        expect(@ramblingSlider.data('rambling:vars').stopped).toBeTruthy()

  describe 'when getting any option', ->
    it 'gets the default value', ->
      expect(@ramblingSlider.ramblingSlider('option', 'slices')).toEqual $.fn.ramblingSlider.defaults.slices

    it 'returns the one set at initialization', ->
      slices = 20

      @helpers.createSlider slices: slices
      expect(@ramblingSlider.ramblingSlider('option', 'slices')).toEqual slices

  describe 'when setting a writable option', ->
    slices = null

    beforeEach ->
      slices = 20
      result = @ramblingSlider.ramblingSlider 'option', 'slices', slices

    it 'returns the jQuery Array for method chaining', ->
      expect(result).toEqualJquery @ramblingSlider

    it 'sets the option value', ->
      expect(@ramblingSlider.ramblingSlider('option', 'slices')).toEqual slices

  describe 'when setting a readonly option', ->
    startSlide = 2

    it 'throws an already running error', ->
      expect(=> @ramblingSlider.ramblingSlider 'option', 'startSlide', startSlide).toThrow "Slider already running. Option 'startSlide' cannot be changed."

    it 'does not change the value', ->
      expect(@ramblingSlider.ramblingSlider('option', 'startSlide')).toEqual $.fn.ramblingSlider.defaults.startSlide

  describe 'when destroying the slider', ->
    beforeEach ->
      @ramblingSlider.ramblingSlider 'destroy'

    it 'removes all the added html elements', ->
      expect(@ramblingSlider).not.toContainElementWithClass 'rambling-slice'
      expect(@ramblingSlider).not.toContainElementWithClass 'rambling-box'
      expect(@ramblingSlider).not.toContainElementWithClass 'rambling-caption'
      expect(@ramblingSlider).not.toContainElementWithClass 'rambling-directionNav'
      expect(@ramblingSlider).not.toContainElementWithClass 'rambling-controlNav'

    it 'removes the animation container element', ->
      expect(@ramblingSlider).not.toContainElementWithId 'rambling-animation'

    it 'removes the "ramblingSlider" class', ->
      expect(@ramblingSlider).not.toHaveClass 'ramblingSlider'

    it 'removes the custom styles from the slider', ->
      expect(@ramblingSlider.attr 'style').toBeUndefined()

    it 'clears the timer', ->
      expect(window.clearInterval).toHaveBeenCalledWith fakeTimer

    it 'removes the slider data', ->
      expect(@ramblingSlider).not.toHaveData 'rambling:slider'
      expect(@ramblingSlider).not.toHaveData 'rambling:vars'

    it 'makes the slider inner elements visible', ->
      @ramblingSlider.children().each ->
        expect($(@).is ':visible').toBeTruthy()

  describe 'when calling the slide changing methods', ->
    beforeEach ->
      @ramblingSlider.ramblingSlider 'effect', 'sliceUpRight'
      timeoutSpy.andCallFake => @ramblingSlider.trigger 'rambling:finished'

    describe 'when going to the previous slide', ->
      beforeEach ->
        result = @ramblingSlider.ramblingSlider 'previousSlide'

      it 'returns the jQuery Array for method chaining', ->
        expect(result).toEqualJquery @ramblingSlider

      it 'changes the current slide index', ->
        expect(@ramblingSlider.data('rambling:vars').currentSlide).toEqual 2

      it 'changes the current slide element to the previous one', ->
        expect(@ramblingSlider.find '.currentSlideElement').toEqualJquery @ramblingSlider.find('img.slideElement[alt=image3]')

    describe 'when going to the next slide', ->
      beforeEach ->
        result = @ramblingSlider.ramblingSlider 'nextSlide'

      it 'returns the jQuery Array for method chaining', ->
        expect(result).toEqualJquery @ramblingSlider

      it 'changes the current slide index', ->
        expect(@ramblingSlider.data('rambling:vars').currentSlide).toEqual 1

      it 'changes the current slide element to the next one', ->
        expect(@ramblingSlider.find '.currentSlideElement').toEqualJquery @ramblingSlider.find('img.slideElement[alt=image2]')

    describe 'when going to a specific slide', ->
      slideIndex = null

      beforeEach ->
        slideIndex = 1
        result = @ramblingSlider.ramblingSlider 'slide', slideIndex

      it 'returns the jQuery Array for method chaining', ->
        expect(result).toEqualJquery @ramblingSlider

      it 'changes the current slide index', ->
        expect(@ramblingSlider.data('rambling:vars').currentSlide).toEqual slideIndex

      it 'changes the current slide element to the next one', ->
        expect(@ramblingSlider.find '.currentSlideElement').toEqualJquery @ramblingSlider.find('img.slideElement[alt=image2]')

  describe 'when getting the current slide index', ->
    beforeEach ->
      result = @ramblingSlider.ramblingSlider 'slide'

    it 'returns the expected index', ->
      expect(result).toEqual 0

  describe 'when getting the slider theme', ->
    it 'returns the default theme', ->
      expect(@ramblingSlider.ramblingSlider 'theme').toEqual $.fn.ramblingSlider.defaults.theme

  describe 'when setting the slider theme', ->
    theme = null

    beforeEach ->
      theme = 'another'
      @helpers.createSlider theme: theme

    it 'removes the previous theme class', ->
      expect(@sliderWrapper).not.toHaveClass "theme-#{$.fn.ramblingSlider.defaults.theme}"

    it 'adds the new theme class', ->
      expect(@sliderWrapper).toHaveClass "theme-#{theme}"

    it 'returns the new theme when asked', ->
      expect(@ramblingSlider.ramblingSlider 'theme').toEqual theme

  describe 'when trying to call a non existent method', ->
    it 'throws a method not present error', ->
      expect(=> @ramblingSlider.ramblingSlider 'methodNotPresent').toThrow "Method 'methodNotPresent' not found."

  describe 'when trying to call a method over an uninitialized slider', ->
    it 'throws an invalid arguments error', ->
      expect(-> $('<div></div>').ramblingSlider 'start').toThrow "Tried to call method 'start' on element without slider."
