###!
 * jQuery Rambling Slider
 * http://github.com/ramblinglabs/rambling.slider
 * http://ramblinglabs.com
 *
 * Copyright 2011-2012, Rambling Labs
 * Released under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 *
 * February 2012
 *
 * Based on jQuery Nivo Slider by Gilbert Pellegrom
###



Array::shuffle = ->
  for i in [@length..1]
    j = parseInt Math.random() * i
    [@[i], @[j]] = [@[j], @[--i]]

  @

Array::contains = (value) ->
  value in @

Array::where = (predicate) ->
  element for element in @ when predicate(element)

Array::first = (predicate) ->
  predicate = ((element) -> true) unless predicate
  (element for element in @ when predicate(element))[0]

Array::map = (map) ->
  map = ((element) -> element) unless map
  map(element) for element in @

Array::random = ->
  @[Math.floor Math.random() * @length]

Array::fromObject = (object, valueSelector) ->
  valueSelector = ((key, value) -> value) unless valueSelector

  for key, value of object then do (key, value) =>
    @push valueSelector(key, value)

  @

Array::sortOutIn = ->
  newArray = []

  length = @length
  halfLength = Math.floor(length / 2)
  for i in [0...halfLength] then do (i) =>
    newArray.push @[i]
    newArray.push @[length - i - 1]

  newArray.push(@[halfLength]) if length % 2

  newArray


(($) ->
  $.fn.reverse = [].reverse
  $.fn.shuffle = [].shuffle
  $.fn.sortOutIn = -> $ Array.prototype.sortOutIn.apply(@)
  $.fn.sortInOut = -> @sortOutIn().reverse()

  $.fn.as2dArray = (totalColumns) ->
    rowIndex = 0
    colIndex = 0
    array_2d = $ ''
    array_2d[rowIndex] = $ ''

    @each ->
      array_2d[rowIndex][colIndex] = $ @
      colIndex++
      if colIndex is totalColumns
        rowIndex++
        colIndex = 0
        array_2d[rowIndex] = $ ''

    array_2d

  $.fn.containsFlash = ->
    @find('object,embed').length

  $.fn.equals = (other) ->
    result = true
    result = @length is other.length
    @each (index, element) ->
      result = result and element is other.get(index)

    result
)(jQuery)


class RamblingBoxGenerator
  constructor: (@slider, @settings, @vars) ->
    @boxer = new RamblingBoxer @slider

  createBoxes: (boxCols = @settings.boxCols, boxRows = @settings.boxRows) ->
    boxWidth = Math.round(@slider.width() / boxCols)
    boxHeight = Math.round(@slider.height() / boxRows)
    animationContainer = @slider.find '#rambling-animation'

    for row in [0...boxRows] then do (row) =>
      for column in [0...boxCols] then do (column) =>
        animationContainer.append @boxer.getRamblingBox(boxWidth, boxHeight, row, column, @settings, @vars)

    @slider.find '.rambling-box'

root = global ? window
root.RamblingBoxGenerator = RamblingBoxGenerator


class RamblingBoxer
  constructor: (@slider) ->

  getBox: (boxWidth, boxHeight, row, column, settings) ->
    boxCss =
      opacity: 0
      left: boxWidth * column
      top: boxHeight * row
      width: if column is (settings.boxCols - 1) then (@slider.width() - (boxWidth * column)) else boxWidth
      height: boxHeight
      overflow: 'hidden'

    $('<div class="rambling-box"></div>').css boxCss

  getRamblingBox: (boxWidth, boxHeight, row, column, settings, vars) ->
    ramblingBox = @getBox boxWidth, boxHeight, row, column, settings

    bottom = if settings.alignBottom then boxHeight * (settings.boxRows - (row + 1)) else 'auto'
    top = if settings.alignBottom then 'auto' else row * boxHeight

    ramblingBoxImageStyle =
      display: 'block'
      width: @slider.width()
      left: -(column * boxWidth)
      top: if settings.alignBottom then 'auto' else -top
      bottom: if settings.alignBottom then -bottom else 'auto'

    ramblingBox.css top: top, bottom: bottom
    ramblingBox.append("<span><img src='#{vars.currentSlideElement.attr('src') or vars.currentSlideElement.find('img').attr('src')}' alt=''/></span>")
    ramblingBox.find('img').css ramblingBoxImageStyle
    ramblingBox

root = global ? window
root.RamblingBoxer = RamblingBoxer


class RamblingSliceGenerator
  constructor: (@slider, @settings, @vars) ->
    @slicer = new RamblingSlicer @slider

  getOneSlice: (slideElement = @vars.currentSlideElement) ->
    @createSlices 1, slideElement

  createSlices: (slices = @settings.slices, slideElement = @vars.currentSlideElement) ->
    sliceWidth = Math.round(@slider.width() / slices)
    animationContainer = @slider.find '#rambling-animation'

    for i in [0...slices] then do (i) =>
      animationContainer.append @slicer.getRamblingSlice(sliceWidth, i, slices, slideElement, @settings)

    @slider.find '.rambling-slice'

root = global ? window
root.RamblingSliceGenerator = RamblingSliceGenerator


class RamblingSlicer
  constructor: (@slider) ->

  getSlice: (sliceWidth, position, total) ->
    sliceCss =
      left: sliceWidth * position
      width: if position is (total - 1) then @slider.width() - (sliceWidth * position) else sliceWidth
      height: 0
      opacity: 0
      overflow: 'hidden'

    $('<div class="rambling-slice"></div>').css sliceCss

  getRamblingSlice: (sliceWidth, position, total, slideElement, settings) ->
    ramblingSlice = @getSlice sliceWidth, position, total
    ramblingSlice.append "<span><img src=\"#{slideElement.attr('src') or slideElement.find('img').attr('src')}\" alt=\"\"/></span>"

    ramblingSliceImageStyle =
      display: 'block'
      width: @slider.width()
      left: - position * sliceWidth
      bottom: if settings.alignBottom then 0 else 'auto'
      top: if settings.alignBottom then 'auto' else 0

    ramblingSlice.find('img').css ramblingSliceImageStyle
    ramblingSlice

root = global ? window
root.RamblingSlicer = RamblingSlicer


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


(($) ->
  allAroundTransitions = [
    { name: 'sliceUp', helper: 'slideUpSlices' },
    { name: 'sliceDown', helper: 'slideDownSlices' },
    { name: 'sliceUpDown', helper: 'slideUpDownSlices' },
    { name: 'sliceFade', helper: 'fadeSlices' },
    { name: 'fold', helper: 'foldSlices' },
  ]

  allAroundTransitions.suffixes = [
    { name: 'Right', sorter: undefined },
    { name: 'Left', sorter: $.fn.reverse },
    { name: 'OutIn', sorter: $.fn.sortOutIn },
    { name: 'InOut', sorter: $.fn.sortInOut },
    { name: 'Random', sorter: $.fn.shuffle },
  ]

  boxTransitions = [
    { name: 'boxRain', helper: 'rainBoxes' },
    { name: 'boxGrow', helper: 'growBoxes' },
  ]

  boxTransitions.suffixes = [
    { name: 'Forward', sorter: undefined },
    { name: 'Reverse', sorter: $.fn.reverse },
    { name: 'OutIn', sorter: $.fn.sortOutIn },
    { name: 'InOut', sorter: $.fn.sortInOut },
    { name: 'Random', sorter: $.fn.shuffle },
  ]

  transitions = [allAroundTransitions, boxTransitions]

  animationFullImageOptions =
    fadeIn: (slider) ->
      @css height: '100%', width: slider.width(), position: 'absolute', top: 0, left: 0
      {opacity: '1'}
    fadeOut: (slider) ->
      @css height: '100%', width: slider.width(), position: 'absolute', top: 0, left: 0
      {opacity: '1'}
    rolloverRight: ->
      @css height: '100%', width: 0, opacity: '1'
      return
    rolloverLeft: (slider, settings) ->
      @css height: '100%', width: 0, opacity: '1', left: 'auto', right: 0
      @find('img').css(left: -slider.width()).animate {left: 0}, settings.speed * 2
      {width: slider.width()}
    slideInRight: (slider, settings) ->
      @css height: '100%', width: 0, opacity: '1'
      @find('img').css(left: -slider.width()).animate {left: 0}, settings.speed * 2
      {width: slider.width()}
    slideInLeft: (slider) ->
      @css height: '100%', width: 0, opacity: '1', left: 'auto', right: 0
      finishedHandler = =>
        @css left: 0, right: 'auto'
        slider.unbind 'rambling:finished', finishedHandler
      slider.bind 'rambling:finished', finishedHandler
      return

  flashSlideIn = (beforeAnimation, animateStyle, afterAnimation) ->
    @currentSlideElement.css beforeAnimation
    window.setTimeout (=> @currentSlideElement.animate animateStyle, @settings.speed * 2, @raiseAnimationFinished), @settings.speed * 2

  flashHorizontalSlideIn = (initialLeft) ->
    beforeAnimation =
      top: (if @settings.alignBottom then 'auto' else 0)
      bottom: (if @settings.alignBottom then 0 else 'auto')
      left: initialLeft
      position: 'absolute'
      display: 'block'

    afterAnimation =
      top: 'auto'
      left: 'auto'
      position: 'relative'

    flashSlideIn.apply @, [beforeAnimation, {left: 0}, afterAnimation]

  $.fn.ramblingSlider.defaults.imageTransitions = {}
  $.each transitions, (index, group) ->
    $.each group, (index, transition) ->
      $.each group.suffixes, (index, suffix) ->
        $.fn.ramblingSlider.defaults.imageTransitions["#{transition.name}#{suffix.name}"] = -> @[transition.helper] suffix.sorter

  for name, value of animationFullImageOptions then do (name, value) ->
    $.fn.ramblingSlider.defaults.imageTransitions[name] = -> @animateFullImage value

  $.fn.ramblingSlider.defaults.imageFlashTransitions =
    fadeOut: ->
      slice = @getOneSlice @previousSlideElement
      slice.css height: '100%', width: slice.parents('.ramblingSlider').width(), position: 'absolute', top: 0, left: 0, opacity: '1'

      @setSliderBackground()
      self = @
      slice.animate {opacity: '0'}, @settings.speed * 2, '', ->
        slice.css display: 'none'
        self.raiseAnimationFinished()

  $.fn.ramblingSlider.defaults.flashTransitions =
    slideInRight: -> flashHorizontalSlideIn.apply @, [-@currentSlideElement.parents('.ramblingSlider').width()]
    slideInLeft: -> flashHorizontalSlideIn.apply @, [@currentSlideElement.parents('.ramblingSlider').width()]

  $.extend $.fn.ramblingSlider.defaults.imageFlashTransitions, $.fn.ramblingSlider.defaults.flashTransitions

  $.fn.ramblingSlider.defaults.transitionGroups = ['fade', 'rollover', 'slideIn']
  $.each transitions, (index, group) ->
    $.each group, (index, element) ->
      $.fn.ramblingSlider.defaults.transitionGroups.push element.name

  $.fn.ramblingSlider.defaults.transitionGroupSuffixes = ['Right', 'Left', 'OutIn', 'InOut', 'Random', 'Forward', 'Reverse', 'In', 'Out']
)(jQuery)


String::contains = (string) ->
  @indexOf(string) isnt -1

String::decapitalize = ->
  first = @[0..0]
  rest = @[1..]

  "#{first.toLowerCase()}#{rest}"

String::startsWith = (string) ->
  @substring(0, string.length) is string

String::endsWith = (string) ->
  @substring(@length - string.length, @length) is string
