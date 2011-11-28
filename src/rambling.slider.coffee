#
# jQuery Rambling Slider
# http://github.com/egonzalez0787/rambling.slider
#
# Copyright 2011, Rambling Labs
# Released under the MIT license.
# http://www.opensource.org/licenses/mit-license.php
#
# October 2011
#
# Based on jQuery Nivo Slider by Gilbert Pellegrom
#

(($) ->

  publicMethods = ['stop', 'start', 'option', 'effect', 'destroy', 'previousSlide', 'nextSlide', 'slide', 'theme']

  $.fn.ramblingSlider = (options, others...) ->
    methodExists = options in publicMethods
    optionsIsString = (typeof options) is 'string'
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
          $.error "Slider already initialized." if options
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
    startSlide: 0
    effect: 'random'
    directionNav: true
    directionNavHide: true
    controlNav: true
    controlNavThumbs: false
    controlNavThumbsFromRel: false
    controlNavThumbsSearch: '.jpg'
    controlNavThumbsReplace: '_thumb.jpg'
    adaptImages: false
    useLargerImage: true
    alignBottom: false
    keyboardNav: true
    pauseOnHover: true
    prevText: 'Prev'
    nextText: 'Next'
    imageTransitions: null
    flashTransitions: null
    imageFlashTransitions: null
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
   'alignBottom',
   'keyboardNav',
   'pauseOnHover',
   'prevText',
   'nextText',
   'imageTransitions',
   'flashTransitions',
   'imageFlashTransitions',
   'afterLoad'
  ]

  RamblingSlider = (element, options) ->
    slider = $ element
    children = slider.children ':not(#rambling-animation)'
    settings = $.extend {}, $.fn.ramblingSlider.defaults, options
    timer = 0
    animationTimeBuffer = 0
    vars =
      currentSlide: 0
      currentSlideElement: ''
      previousSlideElement: ''
      totalSlides: 0
      running: false
      paused: false
      stopped: false

    slider.data 'rambling:vars', vars

    stop = ->
      vars.stopped = true
      slider

    start = ->
      vars.stopped = false
      slider

    previousSlide = ->
      slideTo 'prev'
      slider

    nextSlide = ->
      slideTo 'next'
      slider

    slide = (slideNumbers...) ->
      return vars.currentSlide unless slideNumbers.length

      slideNumber = slideNumbers[0] % vars.totalSlides

      unless vars.running or vars.totalSlides is 1
        vars.currentSlide = slideNumber - 1
        ramblingRun slider, children, settings, 'control'

      slider

    destroy = ->
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

    option = (options...) ->
      return settings unless options.length

      option = options[0]
      value = options[1]
      optionIsObject =  typeof(option) is 'object'

      if option is 'effect'
        return if value then effect(value) else effect()

      if option is 'theme'
        return if value then theme(value) else theme()

      return if optionIsObject
        $.extend settings, option
      else
        if value?
          if option in cannotChange
            return $.error "Slider already running. Option '#{option}' cannot be changed."

          settings[option] = value
        else
          settings[option]

    effect = (effects...) ->
      return settings.effect unless effects.length

      settings.effect = effects[0]
      slider

    theme = (themes...) ->
      return settings.theme unless themes.length

      slider.removeClass "theme-#{settings.theme}"
      settings.theme = themes[0]
      slider.addClass "theme-#{settings.theme}"

    initialize = ->
      effect settings.effect
      theme settings.theme
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
      extendAvailableTransitions()

    run = ->
      if not settings.manualAdvance and vars.totalSlides > 1
        timer = window.setInterval (-> ramblingRun slider, children, settings, false), settings.pauseTime

    setSliderInitialState = ->
      slider.css position: 'relative'
      slider.addClass "ramblingSlider"

      vars.totalSlides = children.length

      prepareAnimationContainer()
      prepareAdaptiveSlider() if settings.adaptImages
      prepareSliderChildren()

    prepareAnimationContainer = ->
      ramblingAnimationContainer = $ '<div id="rambling-animation"></div>'
      ramblingAnimationContainer.css width: slider.width(), height: slider.height(), overflow: 'hidden'
      slider.prepend ramblingAnimationContainer

    prepareAdaptiveSlider = -> slider.addClass 'adaptingSlider'

    prepareSliderChildren = ->
      ramblingAnimationContainer = slider.find '#rambling-animation'
      children.each ->
        child = $(@)
        child.css display: 'none'
        clone = child.clone().addClass 'slideElement'
        if clone.containsFlash()
          clone.find('object').prepend('<param name="wmode" value="opaque" />') unless clone.find('param[name=wmode]').length
          clone.find('embed').attr wmode: 'opaque'
        ramblingAnimationContainer.append clone
      children = ramblingAnimationContainer.children()

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

        iFrame = child.find 'object,embed'
        iFrame.height slider.height()
        iFrame.width slider.width()

        link.css(display: 'none') if link
        child.css display: 'none'

      child = setCurrentSlideElement children
      child.css(display: 'block') if child.is 'a'

    addCaption = ->
      caption = $('<div class="rambling-caption"><p></p></div>').css display:'none', opacity: settings.captionOpacity
      slider.append caption

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

    addControlNavigation = ->
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
          slide $(@).attr('rel')

    addKeyboardNavigation = ->
      if settings.keyboardNav
        $(window).keypress (event) ->
          slideTo('prev') if event.keyCode is 37
          slideTo('next') if event.keyCode is 39

    setAnimationFinishedActions = ->
      slider.bind 'rambling:finished', ->
        vars.running = false


        child = $ children.get(vars.currentSlide)
        child.siblings().css display: 'none'
        child.css(display: 'block') if child.is 'a'

        run() if timer is '' and not vars.paused

        setSliderBackground()
        slider.find('.rambling-slice,.rambling-box').remove()

        settings.afterChange.call @

    extendAvailableTransitions = ->
      $.extend imageTransitions, settings.imageTransitions if settings.imageTransitions
      $.extend imageFlashTransitions, settings.imageFlashTransitions if settings.imageFlashTransitions
      $.extend flashTransitions, settings.flashTransitions if settings.flashTransitions

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

    unpauseSlider = ->
      vars.paused = false
      run() if timer is ''

    slideTo = (direction) ->
      return false if vars.running or vars.totalSlides is 1
      resetTimer()
      vars.currentSlide -= 2 if direction is 'prev'
      ramblingRun slider, children, settings, direction

    getOneSlice = (slideElement = vars.currentSlideElement) ->
      createSlices 1, slideElement

    createSlices = (slices = settings.slices, slideElement = vars.currentSlideElement) ->
      for i in [0...slices] then do (i) ->
        sliceWidth = Math.round(slider.width() / slices)
        animationContainer = slider.find '#rambling-animation'
        animationContainer.append getRamblingSlice(sliceWidth, i, slices, vars, slideElement)

      slider.find '.rambling-slice'

    createBoxes = (boxCols = settings.boxCols, boxRows = settings.boxRows) ->
      boxWidth = Math.round(slider.width() / boxCols)
      boxHeight = Math.round(slider.height() / boxRows)

      for rows in [0...boxRows] then do (rows) ->
        for cols in [0...boxCols] then do (cols) ->
          animationContainer = slider.find '#rambling-animation'
          animationContainer.append getRamblingBox(boxWidth, boxHeight, rows, cols, settings, vars)

      slider.find '.rambling-box'

    getSlice = (sliceWidth, position, total, vars, slideElement) ->
      imageSrc = slideElement.attr('src') or slideElement.find('img').attr('src')
      width = sliceWidth
      width = slider.width() - (sliceWidth * position) if position is (total - 1)

      sliceCss =
        left: "#{sliceWidth * position}px"
        width: "#{width}px"
        height: '0px'
        opacity: '0'
        overflow: 'hidden'

      $('<div class="rambling-slice"></div>').css sliceCss

    getBox = (boxWidth, boxHeight, row, column, settings, vars) ->
      imageSrc = vars.currentSlideElement.attr('src') or vars.currentSlideElement.find('img').attr('src')
      width = boxWidth
      width = (slider.width() - (boxWidth * column)) if column is (settings.boxCols - 1)

      boxCss =
        opacity: 0
        left: "#{boxWidth * column}px"
        top: "#{boxHeight * row}px"
        width: "#{width}px"
        height: "#{boxHeight}px"
        overflow: 'hidden'

      $('<div class="rambling-box"></div>').css boxCss

    setSliderBackground = ->
      slideElement = slider.find '.currentSlideElement'

      return if slideElement.equals vars.currentSlideElement

      slideElement.removeClass('currentSlideElement alignTop alignBottom').css display: 'none', 'z-index': '0'
      vars.currentSlideElement.siblings('.slideElement').css display: 'none'
      slideElement = vars.currentSlideElement.addClass 'currentSlideElement'

      alignment = 'alignTop'
      alignment = 'alignBottom' if settings.alignBottom

      slideElement.addClass alignment
      slideElement.css display: 'block', 'z-index': '0'
      slideElement.find('img').css display: 'block'

    getRamblingSlice = (sliceWidth, position, total, vars, slideElement) ->
      ramblingSlice = getSlice sliceWidth, position, total, vars, slideElement
      ramblingSlice.append "<span><img src=\"#{slideElement.attr('src') or slideElement.find('img').attr('src')}\" alt=\"\"/></span>"

      ramblingSliceImageStyle =
        display: 'block'
        width: slider.width()
        left: "-#{(sliceWidth + (position * sliceWidth)) - sliceWidth}px"
        bottom: if settings.alignBottom then '0' else 'auto'
        top: if settings.alignBottom then 'auto' else '0'

      ramblingSlice.find('img').css ramblingSliceImageStyle

      ramblingSlice

    getRamblingBox = (boxWidth, boxHeight, row, column, settings, vars) ->
      ramblingBox = getBox boxWidth, boxHeight, row, column, settings, vars

      bottom = false
      top = "#{((boxHeight + (row * boxHeight)) - boxHeight)}px"
      if settings.alignBottom
        bottom = "#{(boxHeight * (settings.boxRows - (row + 1)))}px"
        top = false

      ramblingBoxImageStyle =
        display: 'block'
        width: slider.width()
        left: "-#{(boxWidth + (column * boxWidth)) - boxWidth}px"
        top: 'auto'
        bottom: 'auto'

      ramblingBoxImageStyle.top = "-#{top}" if top
      ramblingBoxImageStyle.bottom = "-#{bottom}" if bottom

      ramblingBox.css top: top or 'auto', bottom: bottom or 'auto'
      ramblingBox.append("<span><img src='#{vars.currentSlideElement.attr('src') or vars.currentSlideElement.find('img').attr('src')}' alt=''/></span>")
      ramblingBox.find('img').css ramblingBoxImageStyle

      ramblingBox

    transitionGroups = ['sliceUp', 'sliceDown', 'sliceUpDown', 'fold', 'fade', 'rollover', 'slideIn']
    getAvailableTransitions = ->
      effects = settings.effect.split ','
      $.each transitionGroups, (index, element) ->
        if effects.contains element

          effects.splice effects.indexOf(element), 1, "#{element}Right", "#{element}Left", "#{element}OutIn", "#{element}InOut", "#{element}Random", "#{element}In", "#{element}Out"

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

    animateFullImage = (options) ->
      slice = getOneSlice()

      if settings.alignBottom
        options.style.bottom = '0'
        options.style.top = 'auto'
      else
        options.style.top = '0'
        options.style.bottom = 'auto'

      slice.css options.style
      image = slice.find 'img'
      image.css options.imageStyle if options.imageStyle
      image.animate(options.imageAnimate, settings.speed * 2) if options.imageAnimate
      slice.animate (options.animate or width: "#{slider.width()}px"), settings.speed * 2, '', ->
        settings.afterChange.apply(slice) if settings.afterChange
        raiseAnimationFinished()

    animateSlices = (reorderCallback, animationSetUp) ->
      slices = createSlices()
      animationTimeBuffer = 0
      slices = reorderCallback.apply(slices) if reorderCallback
      slices.each (index, element) ->
        slice = $ element
        finishedCallback = null
        finishedCallback = raiseAnimationFinished if index is settings.slices - 1

        window.setTimeout (-> slice.animate animationSetUp.apply(slice, [index, element]), settings.speed, '', finishedCallback), 100 + animationTimeBuffer
        animationTimeBuffer += 50

    animateBoxes = (animationCallback, reorderCallback) ->
      boxes = createBoxes()
      animationTimeBuffer = 0
      boxes = reorderCallback.apply(boxes) if reorderCallback
      animationCallback.apply boxes, [raiseAnimationFinished]

    slideDownSlices = (reorderCallback) ->
      animateSlices reorderCallback, (index, element) ->
        @css top: '0px'
        { height: "#{slider.height()}px", opacity:'1.0' }

    slideUpSlices = (reorderCallback) ->
      animateSlices reorderCallback, (index, element) ->
        @css bottom: '0px'
        { height: "#{slider.height()}px", opacity:'1.0' }

    slideUpDownSlices = (reorderCallback) ->
      animateSlices reorderCallback, (index, element) ->
        @css (if index % 2 then bottom: '0px' else top: '0px')
        { height: "#{slider.height()}px", opacity:'1.0' }

    foldSlices = (reorderCallback) ->
      animateSlices reorderCallback, (index, element) ->
        slice = $ element
        animateStyle =
          width: "#{slice.width()}px"
          opacity: '1.0'

        slice.css top: '0px', height: '100%', width: '0px'
        animateStyle

    fadeSlices = (reorderCallback) ->
      animateSlices reorderCallback, (index, element) ->
        @css height: "#{slider.height()}px"
        { opacity:'1.0' }

    randomBoxes = ->
      animateBoxes (finishedCallback) ->
          totalBoxes = @length
          @each (index) ->
            box = $ @
            if index is totalBoxes - 1
              window.setTimeout (-> box.animate { opacity:'1' }, settings.speed, '', finishedCallback),
               100 + animationTimeBuffer
            else
              window.setTimeout (-> box.animate { opacity:'1' }, settings.speed), 100 + animationTimeBuffer

            animationTimeBuffer += 20
        , $.fn.shuffle

    rainBoxes = (reorderCallback, grow) ->
      animateBoxes (finishedCallback) ->
          boxes = @
          totalBoxes = settings.boxCols * settings.boxRows
          index = 0
          for cols in [0...(settings.boxCols * 2)] then do (cols) ->
            prevCol = cols
            for rows in [0...settings.boxRows] then do (rows) ->
              if prevCol >= 0 and prevCol < settings.boxCols
                row = rows
                col = prevCol
                time = animationTimeBuffer
                box = $ boxes[row][col]
                w = box.width()
                h = box.height()

                box.css(width: 0, height: 0) if grow

                if index is totalBoxes - 1
                  window.setTimeout (-> box.animate { opacity:'1', width: w, height: h }, settings.speed / 1.3, '', finishedCallback),
                    100 + animationTimeBuffer
                else
                  window.setTimeout (-> box.animate { opacity:'1', width: w, height: h }, settings.speed / 1.3), 100 + animationTimeBuffer

                index++
                animationTimeBuffer += 20

              prevCol--
        , ->
          boxes = @
          boxes = reorderCallback.call(@) if reorderCallback
          boxes.as2dArray settings.boxCols

    transitionOptions =
      fadeIn:
        style:
          height: '100%'
          width: "#{slider.width()}px"
          position: 'absolute'
          top: 0
          left: 0
        animate:
          opacity: '1'
      fadeOut:
        style:
          height: '100%'
          width: "#{slider.width()}px"
          position: 'absolute'
          top: 0
          left: 0
          opacity: '1'
        animate:
          opacity: '0'
      rolloverRight:
        style:
          height: '100%'
          width: '0px'
          opacity: '1'
      rolloverLeft:
        imageAnimate:
          left: '0px'
        animate:
          width: "#{slider.width()}"
        style:
          height: '100%'
          width: '0px'
          opacity: '1'
          left: ''
          right: '0px'
        imageStyle:
          left: "#{-slider.width()}px"
      slideInRight:
        imageAnimate:
          left: '0px'
        animate:
          width: "#{slider.width()}"
        style:
          height: '100%'
          width: '0px'
          opacity: '1'
        imageStyle:
          left: "#{-slider.width()}px"
      slideInLeft:
        style:
          height: '100%'
          width: '0px'
          opacity: '1'
          left: ''
          right: '0px'
        afterChange: -> @css left: '0px', right: ''

    imageTransitions =
      sliceDownRight: slideDownSlices
      sliceDownLeft: -> slideDownSlices $.fn.reverse
      sliceDownOutIn: -> slideDownSlices $.fn.sortOutIn
      sliceDownInOut: -> slideDownSlices -> @sortOutIn().reverse()
      sliceDownRandom: -> slideDownSlices $.fn.shuffle
      sliceUpRight: slideUpSlices
      sliceUpLeft: -> slideUpSlices $.fn.reverse
      sliceUpOutIn: -> slideUpSlices $.fn.sortOutIn
      sliceUpInOut: -> slideUpSlices -> @sortOutIn().reverse()
      sliceUpRandom: -> slideUpSlices $.fn.shuffle
      sliceUpDownRight: slideUpDownSlices
      sliceUpDownLeft: -> slideUpDownSlices $.fn.reverse
      sliceUpDownOutIn: -> slideUpDownSlices $.fn.sortOutIn
      sliceUpDownInOut: -> slideUpDownSlices -> @sortOutIn().reverse()
      sliceUpDownRandom: -> slideUpDownSlices $.fn.shuffle
      sliceFadeOutIn: -> fadeSlices $.fn.sortOutIn
      sliceFadeInOut: -> fadeSlices -> @sortOutIn().reverse()
      foldRight: foldSlices
      foldLeft: -> foldSlices $.fn.reverse
      foldOutIn: -> foldSlices $.fn.sortOutIn
      foldInOut: -> foldSlices -> @sortOutIn().reverse()
      foldRandom: -> foldSlices $.fn.shuffle
      fadeIn: -> animateFullImage transitionOptions.fadeIn
      fadeOut: -> animateFullImage transitionOptions.fadeIn
      slideInRight: -> animateFullImage transitionOptions.slideInRight
      slideInLeft: -> animateFullImage transitionOptions.slideInLeft
      rolloverRight: -> animateFullImage transitionOptions.rolloverRight
      rolloverLeft: -> animateFullImage transitionOptions.rolloverLeft
      boxRandom: randomBoxes
      boxRain: rainBoxes
      boxRainReverse: -> rainBoxes $.fn.reverse
      boxRainOutIn: -> rainBoxes $.fn.sortOutIn
      boxRainInOut: -> rainBoxes -> @sortOutIn().reverse()
      boxRainGrow: -> rainBoxes undefined, true
      boxRainGrowReverse: -> rainBoxes $.fn.reverse, true
      boxRainGrowOutIn: -> rainBoxes $.fn.sortOutIn, true
      boxRainGrowInOut: -> rainBoxes (-> @sortOutIn().reverse()), true

    imageFlashTransitions =
      fadeOut: ->
        slice = getOneSlice vars.previousSlideElement
        slice.css transitionOptions.fadeOut.style

        setSliderBackground()
        slice.animate transitionOptions.fadeOut.animate, settings.speed * 2, '', ->
          settings.afterChange.apply(slice) if settings.afterChange
          slice.css display: 'none'
          raiseAnimationFinished()

    flashSlideIn = (beforeAnimation, animateStyle, afterAnimation) ->
      vars.currentSlideElement.css beforeAnimation
      window.setTimeout (-> vars.currentSlideElement.animate animateStyle, settings.speed * 2, ->
          raiseAnimationFinished()
        ), settings.speed * 2

    flashHorizontalSlideIn = (initialLeft) ->
      flashSlideIn {top: (if settings.alignBottom then 'auto' else '0'), bottom: (if settings.alignBottom then '-7px' else 'auto'), left: initialLeft, position: 'absolute', display: 'block'}, {left: '0'}, {top: 'auto', left: 'auto', position: 'relative'}

    flashTransitions =
      slideInRight: -> flashHorizontalSlideIn "#{-slider.width()}px"
      slideInLeft: -> flashHorizontalSlideIn "#{slider.width()}px"

    $.extend imageFlashTransitions, flashTransitions

    ramblingRun = (slider, children, settings, nudge) ->
      settings.lastSlide.call(@) if vars.currentSlide is vars.totalSlides - 1

      return false if vars.stopped and not nudge

      settings.beforeChange.call @

      vars.currentSlide++

      if vars.currentSlide is vars.totalSlides
        vars.currentSlide = 0
        settings.slideshowEnd.call @

      vars.currentSlide = (vars.totalSlides - 1) if vars.currentSlide < 0
      setCurrentSlideElement children

      slider.find('.rambling-controlNav a').removeClass('active').filter(":eq(#{vars.currentSlide})").addClass('active') if settings.controlNav

      processCaption settings

      vars.running = true

      animationHelpers =
        createSlices: createSlices
        createBoxes: createBoxes
        getOneSlice: getOneSlice
        animateFullImage: animateFullImage
        animateSlices: animateSlices
        animateBoxes: animateBoxes
        slideUpSlices: slideUpSlices
        slideDownSlices: slideDownSlices
        slideUpDownSlices: slideUpDownSlices
        foldSlices: foldSlices
        rainBoxes: rainBoxes

      getRandomAnimation().apply animationHelpers

    settings.afterLoad.call @

    @stop = stop
    @start = start
    @previousSlide = previousSlide
    @nextSlide = nextSlide
    @slide = slide
    @effect = effect
    @theme = theme
    @option = option
    @destroy = destroy
    @initialize = initialize
    @run = run

    @
)(jQuery)
