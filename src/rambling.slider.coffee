(($) ->

  publicMethods = ['stop', 'start', 'option', 'effect', 'destroy', 'previousSlide', 'nextSlide', 'slide', 'theme']

  $.fn.ramblingSlider = (options, others...) ->
    methodExists = options in publicMethods
    optionsIsString = typeof(options) is 'string'
    ramblingSlider = @data 'rambling:slider'
    isCallingGetter = (options, others) -> not others.length or (options is 'option' and others.length is 1 and typeof(others[0]) is 'string')

    return if ramblingSlider
      if methodExists
        value = ramblingSlider[options](others...)
        if isCallingGetter options, others
          value
        else
          @
      else
        if optionsIsString
          $.error "Method '#{options}' not found."
        else
          $.error "Slider already initialized."
    else
      $.error "Tried to call method '#{options}' on element without slider." if methodExists or optionsIsString

    @each (key, value) ->
      element = $ @
      return if element.data 'rambling:slider'

      ramblingSlider = new RamblingSlider @, options
      element.data 'rambling:slider', ramblingSlider

      ramblingSlider.initialize()
      ramblingSlider.run()

  $.fn.ramblingSlider.defaults =
    slices: 15
    boxCols: 8
    boxRows: 4
    speed: 500
    pauseTime: 4500
    manualAdvance: false
    captionOpacity: 0.8
    theme: 'default'
    alignBottom: false
    effect: 'random'
    startSlide: 0
    directionNav: true
    directionNavHide: true
    controlNav: true
    controlNavThumbs: false
    controlNavThumbsFromRel: false
    controlNavThumbsSearch: '.jpg'
    controlNavThumbsReplace: '_thumb.jpg'
    adaptImages: false
    useLargerImage: true
    keyboardNav: true
    pauseOnHover: true
    prevText: 'Prev'
    nextText: 'Next'
    imageTransitions: null
    flashTransitions: null
    imageFlashTransitions: null
    transitionGroups: []
    transitionGroupSuffixes: []
    beforeChange: ->
    afterChange: ->
    slideshowEnd: ->
    lastSlide: ->
    afterLoad: ->

  cannotChange = [
   'startSlide',
   'directionNav',
   'directionNavHide',
   'controlNav',
   'controlNavThumbs',
   'controlNavThumbsFromRel',
   'controlNavThumbsSearch',
   'controlNavThumbsReplace',
   'adaptImages',
   'useLargerImage',
   'keyboardNav',
   'pauseOnHover',
   'prevText',
   'nextText',
   'imageTransitions',
   'flashTransitions',
   'imageFlashTransitions',
   'transitionGroups',
   'transitionGroupSuffixes',
   'afterLoad'
  ]

  RamblingSlider = (element, options) ->
    slider = $ element
    children = slider.children ':not(#rambling-animation)'
    settings = $.extend {}, $.fn.ramblingSlider.defaults, options
    timer = 0
    animationTimeBuffer = 0
    imageTransitions = null
    imageFlashTransitions = null
    flashTransitions = null
    transitionGroups = []
    transitionGroupSuffixes = []
    vars =
      currentSlide: 0
      currentSlideElement: ''
      previousSlideElement: ''
      totalSlides: 0
      running: false
      paused: false
      stopped: false

    slider.data 'rambling:vars', vars

    ramblingSliceGenerator = new RamblingSliceGenerator slider, settings, vars
    ramblingBoxGenerator = new RamblingBoxGenerator slider, settings, vars

    @stop = ->
      vars.stopped = true
      slider

    @start = ->
      vars.stopped = false
      slider

    @previousSlide = ->
      slideTo 'prev'
      slider

    @nextSlide = ->
      slideTo 'next'
      slider

    @slide = (slideNumbers...) ->
      return vars.currentSlide unless slideNumbers.length

      slideNumber = slideNumbers[0] % vars.totalSlides

      unless vars.running or vars.totalSlides is 1
        vars.currentSlide = slideNumber - 1
        ramblingRun slider, children, settings, 'control'

      slider

    @destroy = ->
      slider.find('#rambling-animation,.rambling-slice,.rambling-box,.rambling-caption,.rambling-directionNav,.rambling-controlNav').remove()
      slider.removeClass 'ramblingSlider adaptingSlider'
      slider.removeAttr 'style'
      slider.data 'rambling:vars', null
      slider.data 'rambling:slider', null
      slider.unbind 'rambling:finished'
      slider.unbind 'hover'
      resetTimer()
      slider.children().show().children().show()
      slider

    @option = (options...) =>
      return settings unless options.length

      [option, value] = options
      optionIsObject =  typeof(option) is 'object'

      return @effect.apply(@, [value] if value) if option is 'effect'
      return @theme.apply(@, [value] if value) if option is 'theme'

      return if optionIsObject
        $.extend settings, option
      else
        if value?
          if option in cannotChange
            return $.error "Slider already running. Option '#{option}' cannot be changed."

          settings[option] = value
        else
          settings[option]

    @effect = (effects...) ->
      return settings.effect unless effects.length

      settings.effect = effects[0]
      slider

    @theme = (themes...) ->
      return settings.theme unless themes.length

      oldTheme = settings.theme
      [settings.theme] = themes

      classes = ["theme-#{oldTheme}", "theme-#{$.fn.ramblingSlider.defaults.theme}"]
      slider.parents(classes.map((c) -> ".#{c}").join ',').removeClass(classes.join ' ').addClass("theme-#{settings.theme}")
      slider

    @initialize = ->
      setSliderInitialState()

      vars.currentSlide = settings.startSlide = settings.startSlide % vars.totalSlides
      setCurrentSlideElement children
      setSliderBackground()

      addCaption()
      addDirectionNavigation()
      addControlNavigation(children)
      addKeyboardNavigation()
      slider.hover(pauseSlider, unpauseSlider) if settings.pauseOnHover
      setAnimationFinishedActions()

    @run = ->
      if not settings.manualAdvance and vars.totalSlides > 1
        timer = window.setInterval (-> ramblingRun slider, children, settings, false), settings.pauseTime

    setUpTransitions = ->
      imageTransitions = $.extend {}, $.fn.ramblingSlider.defaults.imageTransitions, settings.imageTransitions
      imageFlashTransitions = $.extend {}, $.fn.ramblingSlider.defaults.imageFlashTransitions, settings.imageFlashTransitions
      flashTransitions = $.extend {}, $.fn.ramblingSlider.defaults.flashTransitions, settings.flashTransitions

      transitionGroups = getSettingsArrayFor 'transitionGroups'
      transitionGroupSuffixes = getSettingsArrayFor 'transitionGroupSuffixes'

    getSettingsArrayFor = (key) ->
      array = []
      $.each $.fn.ramblingSlider.defaults[key], (index, element) -> array.push element
      $.each settings[key], (index, element) -> array.push element
      array

    setSliderInitialState = =>
      @effect settings.effect
      @theme settings.theme
      setUpTransitions()

      slider.css position: 'relative'
      slider.addClass 'ramblingSlider'

      vars.totalSlides = children.length

      prepareSliderChildren()
      prepareAnimationContainer()
      prepareAdaptiveSlider() if settings.adaptImages

    prepareAnimationContainer = ->
      ramblingAnimationContainer = $('<div id="rambling-animation"></div>').css(width: slider.width(), height: slider.height(), overflow: 'hidden')
      slider.prepend ramblingAnimationContainer
      children.each ->
        child = $(@)
        child.css display: 'none'
        clone = child.clone().addClass 'slideElement'
        if clone.containsFlash()
          clone.find('object').prepend('<param name="wmode" value="opaque" />') unless clone.find('param[name=wmode]').length
          clone.find('embed').attr wmode: 'opaque'
        ramblingAnimationContainer.append clone
      children = ramblingAnimationContainer.children()

    prepareAdaptiveSlider = -> slider.addClass 'adaptingSlider'

    prepareSliderChildren = ->
      children.each ->
        child = $ @
        link = null
        if child.is('a') and not child.containsFlash()
          link = child.addClass 'rambling-imageLink'
          child = child.find 'img:first'

        childWidth = child.width() or child.attr('width')
        childHeight = child.height() or child.attr('height')

        slider.width(childWidth) if childWidth > slider.width() and settings.useLargerImage
        slider.height(childHeight) if childHeight > slider.height() and (settings.useLargerImage or not settings.adaptImages)

        object = child.find 'object,embed'
        object.height slider.height()
        object.width slider.width()

        link.css(display: 'none') if link
        child.css display: 'none'

      child = setCurrentSlideElement children
      child.css(display: 'block') if child.is 'a'

    addCaption = ->
      slider.append $('<div class="rambling-caption"><p></p></div>').css(display:'none', opacity: settings.captionOpacity)
      processCaption settings

    addDirectionNavigation = ->
      if settings.directionNav and vars.totalSlides > 1
        directionNav = $ "<div class='rambling-directionNav'><a class='rambling-prevNav'>#{settings.prevText}</a><a class='rambling-nextNav'>#{settings.nextText}</a></div>"
        slider.append directionNav

        if settings.directionNavHide
          directionNav.hide()
          slider.hover (-> directionNav.show()), (-> directionNav.hide())

        slider.find('a.rambling-prevNav').live 'click', -> slideTo 'prev'
        slider.find('a.rambling-nextNav').live 'click', -> slideTo 'next'

    addControlNavigation = =>
      self = @
      if settings.controlNav
        ramblingControl = $ '<div class="rambling-controlNav"></div>'
        slider.append ramblingControl
        for i in [0...children.length] then do (i) ->
          if settings.controlNavThumbs
            child = children.eq i
            child = child.find('img:first') unless child.is 'img'
            if settings.controlNavThumbsFromRel
              ramblingControl.append "<a class='rambling-control' rel='#{i}'><img src='#{child.attr('rel')}' alt='' /></a>"
            else
              ramblingControl.append "<a class='rambling-control' rel='#{i}'><img src='#{child.attr('src').replace(settings.controlNavThumbsSearch, settings.controlNavThumbsReplace)}' alt='' /></a>"

          else ramblingControl.append "<a class='rambling-control' rel='#{i}'>#{i + 1}'</a>"

        controlNavAnchors = slider.find '.rambling-controlNav a'
        controlNavAnchors.filter(":eq(#{vars.currentSlide})").addClass 'active'

        controlNavAnchors.live 'click', ->
          return false if vars.running
          return false if $(@).hasClass 'active'
          resetTimer()
          setSliderBackground()
          self.slide $(@).attr('rel')

    addKeyboardNavigation = ->
      if settings.keyboardNav
        $(window).keypress (event) ->
          slideTo('prev') if event.keyCode is 37
          slideTo('next') if event.keyCode is 39

    setAnimationFinishedActions = =>
      self = @
      slider.bind 'rambling:finished', ->
        vars.running = false

        child = $ children.get(vars.currentSlide)
        child.siblings().css display: 'none'
        child.css(display: 'block') if child.is 'a'

        self.run() if timer is '' and not vars.paused

        setSliderBackground()
        slider.find('.rambling-slice,.rambling-box').remove()

        settings.afterChange.call @

    processCaption = (settings) ->
      ramblingCaption = slider.find '.rambling-caption'
      title = vars.currentSlideElement.attr 'title'
      if title
        title = $(title).html() if title.startsWith '#'

        if ramblingCaption.css('display') is 'block'
          ramblingCaption.find('p').fadeOut settings.speed, ->
            p = $ @
            p.html title
            p.fadeIn settings.speed
        else ramblingCaption.find('p').html title

        ramblingCaption.fadeIn settings.speed
      else ramblingCaption.fadeOut settings.speed

    setCurrentSlideElement = (children) ->
      child = $ children.get(vars.currentSlide)
      vars.previousSlideElement = vars.currentSlideElement
      vars.currentSlideElement = child
      vars.currentSlideElement = child.find('img:first') if child.is('a') and not child.containsFlash()
      child

    resetTimer = ->
      window.clearInterval timer
      timer = ''

    pauseSlider = ->
      vars.paused = true
      resetTimer()

    unpauseSlider = =>
      vars.paused = false
      @run() if timer is ''

    slideTo = (direction) ->
      return false if vars.running or vars.totalSlides is 1
      resetTimer()
      vars.currentSlide -= 2 if direction is 'prev'
      ramblingRun slider, children, settings, direction

    setSliderBackground = ->
      slideElement = slider.find '.currentSlideElement'

      return if slideElement.equals vars.currentSlideElement

      slideElement.removeClass('currentSlideElement alignTop alignBottom').css display: 'none', 'z-index': 0

      slideElement = vars.currentSlideElement
      slideElement.siblings('.slideElement').css display: 'none'
      slideElement.addClass('currentSlideElement').addClass if settings.alignBottom then 'alignBottom' else 'alignTop'
      slideElement.css display: 'block', 'z-index': 0
      slideElement.find('img').css display: 'block'

    getAvailableTransitions = ->
      effects = settings.effect.split ','
      $.each transitionGroups, (index, group) ->
        if effects.contains group
          parameters = [effects.indexOf(group), 1]
          $.each transitionGroupSuffixes, (index, suffix) -> parameters.push "#{group}#{suffix}"
          effects.splice.apply effects, parameters

      effects

    getAnimationsForCurrentSlideElement = ->
      transitions = []
      sourceTransitions = []
      if vars.currentSlideElement.containsFlash()
        if vars.previousSlideElement.containsFlash()
          sourceTransitions = flashTransitions
          defaultTransition = flashTransitions.slideInRight
        else
          sourceTransitions = imageFlashTransitions
          defaultTransition = imageFlashTransitions.fadeOut
      else
        sourceTransitions = imageTransitions
        defaultTransition = imageTransitions.fadeIn

      availableTransitions = getAvailableTransitions()
      transitions = [].fromObject sourceTransitions, (key, value) -> key
      transitions = (transitions.where (animationName) -> availableTransitions.contains animationName) unless settings.effect is 'random'
      transitions = transitions.map (animationName) -> sourceTransitions[animationName]
      transitions.default = defaultTransition

      transitions

    getRandomAnimation = ->
      transitions = getAnimationsForCurrentSlideElement()
      transitions.random() or transitions.default

    raiseAnimationFinished = -> slider.trigger 'rambling:finished'

    animateFullImage = (animationSetUp) ->
      slice = ramblingSliceGenerator.getOneSlice()
      slice.css top: (if settings.alignBottom then 'auto' else 0), bottom: (if settings.alignBottom then 0 else 'auto')
      slice.animate (animationSetUp.apply(slice, [slider, $.extend({}, settings)]) or width: slider.width()), settings.speed * 2, '', ->
        settings.afterChange.apply(slice) if settings.afterChange
        raiseAnimationFinished()

    animateSlices = (animationSetUp, sortCallback) ->
      slices = ramblingSliceGenerator.createSlices()
      animationTimeBuffer = 0
      slices = sortCallback.apply(slices) if sortCallback
      slices.each (index, element) ->
        slice = $ element
        finishedCallback = raiseAnimationFinished if index is settings.slices - 1

        window.setTimeout (-> slice.animate animationSetUp.apply(slice, [index, element]) or {}, settings.speed, '', finishedCallback), 100 + animationTimeBuffer
        animationTimeBuffer += 50

    animateBoxes = (animationCallback, sortCallback) ->
      boxes = ramblingBoxGenerator.createBoxes()
      animationTimeBuffer = 0
      boxes = sortCallback.apply(boxes) if sortCallback
      animationCallback.apply boxes, [raiseAnimationFinished]

    animateBoxesIn2d = (animationSetUp, sortCallback) ->
      animateBoxes (finishedCallback) ->
          boxes = @
          totalBoxes = settings.boxCols * settings.boxRows
          index = 0
          for column in [0...(settings.boxCols * 2)] then do (column) ->
            for row in [0...settings.boxRows] then do (row) ->
              if column >= 0 and column < settings.boxCols
                box = $ boxes[row][column]
                finished = finishedCallback if index is totalBoxes - 1

                window.setTimeout (-> box.animate animationSetUp.apply(box), settings.speed / 1.3, '', finished), 100 + animationTimeBuffer

                index++
                animationTimeBuffer += 20

              column--
        , ->
          boxes = @
          boxes = sortCallback.call(@) if sortCallback
          boxes.as2dArray settings.boxCols

    slideDownSlices = (sortCallback) ->
      animateSlices ((index, element) ->
          @css top: 0
          { height: slider.height(), opacity:'1' }
        ), sortCallback

    slideUpSlices = (sortCallback) ->
      animateSlices ((index, element) ->
          @css bottom: 0
          { height: slider.height(), opacity:'1' }
        ), sortCallback

    slideUpDownSlices = (sortCallback) ->
      animateSlices ((index, element) ->
          @css (if index % 2 then bottom: 0 else top: 0)
          { height: slider.height(), opacity: '1' }
        ), sortCallback

    foldSlices = (sortCallback) ->
      animateSlices ((index, element) ->
          slice = $ element
          animateStyle =
            width: slice.width()
            opacity: '1'

          slice.css top: 0, height: '100%', width: 0
          animateStyle
        ), sortCallback

    fadeSlices = (sortCallback) ->
      animateSlices ((index, element) ->
          @css height: slider.height()
          { opacity:'1' }
        ), sortCallback

    fadeBoxes = (sortCallback) ->
      animateBoxes (finishedCallback) ->
          totalBoxes = @length
          animationTimeBuffer = 0
          @each (index) ->
            box = $ @
            finished = finishedCallback if index is totalBoxes - 1

            window.setTimeout (-> box.animate { opacity:'1' }, settings.speed, '', finished), 100 + animationTimeBuffer
            animationTimeBuffer += 20
        , sortCallback

    rainBoxes = (sortCallback) -> animateBoxesIn2d (-> { opacity: '1' }), sortCallback

    growBoxes = (sortCallback) ->
      animateBoxesIn2d (->
          width = @width()
          height = @height()
          @css width: 0, height: 0
          { opacity: '1', width: width, height: height }
        ), sortCallback

    getAnimationHelpers = ->
      animationHelpers =
        setSliderBackground: setSliderBackground
        currentSlideElement: vars.currentSlideElement
        previousSlideElement: vars.previousSlideElement
        raiseAnimationFinished: raiseAnimationFinished
        settings: $.extend {}, settings
        createSlices: (slices, element) -> ramblingSliceGenerator.createSlices slices, element
        createBoxes: (rows, columns) -> ramblingBoxGenerator.createBoxes rows, columns
        getOneSlice: (element) -> ramblingSliceGenerator.getOneSlice element
        animateFullImage: animateFullImage
        animateSlices: animateSlices
        animateBoxes: animateBoxes
        animateBoxesIn2d: animateBoxesIn2d
        slideUpSlices: slideUpSlices
        slideDownSlices: slideDownSlices
        slideUpDownSlices: slideUpDownSlices
        foldSlices: foldSlices
        fadeSlices: fadeSlices
        fadeBoxes: fadeBoxes
        rainBoxes: rainBoxes
        growBoxes: growBoxes

    ramblingRun = (slider, children, settings, nudge) ->
      settings.lastSlide.call(@) if vars.currentSlide is vars.totalSlides - 1

      return false if vars.stopped and not nudge

      settings.beforeChange.call @

      vars.currentSlide = (vars.currentSlide + 1) % vars.totalSlides
      settings.slideshowEnd.call(@) if vars.currentSlide is 0

      vars.currentSlide = (vars.totalSlides + vars.currentSlide) if vars.currentSlide < 0
      setCurrentSlideElement children

      slider.find('.rambling-controlNav a').removeClass('active').filter(":eq(#{vars.currentSlide})").addClass('active') if settings.controlNav
      processCaption settings
      vars.running = true

      getRandomAnimation().call getAnimationHelpers()

    settings.afterLoad.call @
    @
)(jQuery)
