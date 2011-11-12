###
 * jQuery Rambling Slider
 * http://github.com/egonzalez0787/rambling.slider
 *
 * Copyright 2011, Rambling Labs
 * Released under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 *
 * October 2011
 *
 * Based on jQuery Nivo Slider by Gilbert Pellegrom
###

(($) ->

  publicMethods = ['stop', 'start', 'option', 'effect']

  $.fn.ramblingSlider = (options, others...) ->
    methodExists = options in publicMethods
    optionsIsString = (typeof options) is 'string'
    ramblingSlider = @data 'rambling:slider'
    isCallingGetter = (others) -> not others.length or (others.length is 1 and typeof(others[0]) is 'string')

    if ramblingSlider
      return if methodExists
        value = ramblingSlider[options](others...)
        if isCallingGetter others
          value
        else
          @
      else
        if optionsIsString
          $.error "Method '#{options}' not found."
        else
          $.error "Slider already initialized." if options
    else
      return $.error "Tried to call method '#{options}' on element without slider." if methodExists or optionsIsString

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
    pauseTime: 3000
    manualAdvance: false
    captionOpacity: 0.8
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
   'nextText'
  ]

  RamblingSlider = (element, options) ->
    slider = $ element
    kids = slider.children ':not(#rambling-animation)'
    settings = $.extend {}, $.fn.ramblingSlider.defaults, options
    animationsToRun = []
    timer = 0
    animationTimeBuffer = 0
    vars =
      currentSlide: 0
      currentImage: ''
      totalSlides: 0
      randomAnimation: ''
      running: false
      paused: false
      stopped: false

    stop = ->
      vars.stopped = true
      slider

    start = ->
      vars.stopped = false
      slider

    option = (options...) ->
      return settings unless options.length

      option = options[0]
      value = options[1]
      optionIsObject =  typeof(option) is 'object'

      if option is 'effect'
        return if value then effect(value) else effect()

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
      animationsToRun = [
        'sliceDownRight',
        'sliceDownLeft',
        'sliceUpRight',
        'sliceUpLeft',
        'sliceUpDown',
        'sliceUpDownLeft',
        'fold',
        'foldLeft',
        'fade',
        'slideInRight',
        'slideInLeft',
        'boxRandom',
        'boxRain',
        'boxRainReverse',
        'boxRainGrow',
        'boxRainGrowReverse'
      ]
      animationsToRun = settings.effect.split(',') if settings.effect.contains(',')
      settings.effect

    initialize = ->
      effect settings.effect
      setSliderInitialState()

      vars.currentSlide = settings.startSlide = settings.startSlide % vars.totalSlides

      setSliderBackground slider, vars

      addCaption()
      addDirectionNavigation()
      addControlNavigation(kids)
      addKeyboardNavigation()
      slider.hover(pauseSlider, unpauseSlider) if settings.pauseOnHover
      setAnimationFinishedActions()

    run = ->
      if not settings.manualAdvance and kids.length > 1
        timer = setInterval (-> ramblingRun slider, kids, settings, false), settings.pauseTime

    setSliderInitialState = ->
      slider.css position: 'relative'
      slider.addClass 'ramblingSlider'

      vars.totalSlides = kids.length

      prepareAdaptiveSlider() if settings.adaptImages
      prepareSliderChildren()

    prepareAdaptiveSlider = ->
      ramblingAnimationContainer = $ '<div id="rambling-animation"></div>'
      ramblingAnimationContainer.css width: slider.width(), height: slider.height(), overflow: 'hidden'
      slider.prepend ramblingAnimationContainer
      slider.addClass 'adaptingSlider'

    prepareSliderChildren = ->
      kids.each ->
        child = $ @
        link = null
        unless child.is 'img'
          link = child.addClass('rambling-imageLink') if child.is 'a'
          child = child.find 'img:first'

        childWidth = child.width() or child.attr('width')
        childHeight = child.height() or child.attr('height')

        slider.width(childWidth) if childWidth > slider.width() and settings.useLargerImage
        slider.height(childHeight) if childHeight > slider.height() and (settings.useLargerImage or not settings.adaptImages)

        link.css(display: 'none') if link
        child.css display: 'none'

      kid = setCurrentSlideImage kids
      kid.css(display: 'block') if kid.is 'a'

    addCaption = ->
      caption = $('<div class="rambling-caption"><p></p></div>').css display:'none', opacity: settings.captionOpacity
      slider.append caption

      processCaption settings

    addDirectionNavigation = ->
      if settings.directionNav
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
        for i in [0...kids.length] then do (i) ->
          if settings.controlNavThumbs
            child = kids.eq i
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
          setSliderBackground slider, vars
          vars.currentSlide = $(@).attr('rel') - 1
          ramblingRun slider, kids, settings, 'control'

    addKeyboardNavigation = ->
      if settings.keyboardNav
        $(window).keypress (event) ->
          slideTo('prev') if event.keyCode is 37
          slideTo('next') if event.keyCode is 39

    setAnimationFinishedActions = ->
      slider.bind 'rambling:finished', ->
        vars.running = false

        kids.filter('a').css display: 'none'

        kid = $(kids[vars.currentSlide])
        kid.css(display: 'block') if kid.is 'a'

        run() if timer is '' and not vars.paused

        setSliderBackground slider, vars

        settings.afterChange.call @

    getRandomAnimation = -> animationsToRun[Math.floor(Math.random() * (animationsToRun.length + 1))] or 'fade'

    processCaption = (settings) ->
      ramblingCaption = slider.find '.rambling-caption'
      title = vars.currentImage.attr 'title'
      if title
        title = $(title).html() if title.substr(0, 1) is '#'

        if ramblingCaption.css('display') is 'block'
          ramblingCaption.find('p').fadeOut settings.speed, ->
            $(@).html title
            $(@).fadeIn settings.speed
        else ramblingCaption.find('p').html title

        ramblingCaption.fadeIn settings.speed
      else ramblingCaption.fadeOut settings.speed

    setCurrentSlideImage = (kids) ->
      kid = $ kids[vars.currentSlide]
      vars.currentImage = kid
      vars.currentImage = kid.find('img:first') unless kid.is 'img'
      kid

    resetTimer = ->
      clearInterval timer
      timer = ''

    pauseSlider = ->
      vars.paused = true
      resetTimer()

    unpauseSlider = ->
      vars.paused = false
      run() if timer is ''

    slideTo = (direction) ->
      return false if vars.running
      resetTimer()
      vars.currentSlide -= 2 if direction is 'prev'
      ramblingRun slider, kids, settings, direction

    createSlices = (slider, settings, vars) ->
      for i in [0...settings.slices] then do (i) ->
        sliceWidth = Math.round(slider.width() / settings.slices)
        animationContainer = slider
        animationContainer = slider.find('#rambling-animation') if settings.adaptImages
        animationContainer.append getRamblingSlice(sliceWidth, i, settings.slices, vars)

      slider.find '.rambling-slice'

    createBoxes = (slider, settings, vars) ->
      boxWidth = Math.round(slider.width() / settings.boxCols)
      boxHeight = Math.round(slider.height() / settings.boxRows)

      for rows in [0...settings.boxRows] then do (rows) ->
        for cols in [0...settings.boxCols] then do (cols) ->
          animationContainer = slider
          animationContainer = slider.find('#rambling-animation') if settings.adaptImages
          animationContainer.append getRamblingBox(boxWidth, boxHeight, rows, cols, settings, vars)

      slider.find '.rambling-box'

    setSliderBackground = (slider, vars) -> slider.css background: "url(#{vars.currentImage.attr('src')}) no-repeat"

    getRamblingSlice = (sliceWidth, position, total, vars) ->
      background = "url(#{vars.currentImage.attr('src')}) no-repeat -#{((sliceWidth + (position * sliceWidth)) - sliceWidth)}px 0%"
      width = sliceWidth
      if position is (total - 1)
          background = "url(#{vars.currentImage.attr('src')}) no-repeat -#{((sliceWidth + (position * sliceWidth)) - sliceWidth)}px 0%"
          width = slider.width() - (sliceWidth * position)

      sliceCss =
        left: "#{sliceWidth * position}px"
        width: "#{width}px"
        height: '0px'
        opacity: '0'
        background: background
        overflow: 'hidden'

      $('<div class="rambling-slice"></div>').css sliceCss

    getRamblingBox = (boxWidth, boxHeight, row, column, settings, vars) ->
      background = "url(#{vars.currentImage.attr('src')}) no-repeat -#{((boxWidth + (column * boxWidth)) - boxWidth)}px -#{((boxHeight + (row * boxHeight)) - boxHeight)}px"
      width = boxWidth
      if column is (settings.boxCols - 1)
          background = "url(#{vars.currentImage.attr('src')}) no-repeat -#{((boxWidth + (column * boxWidth)) - boxWidth)}px -#{((boxHeight + (row * boxHeight)) - boxHeight)}px"
          width = (slider.width() - (boxWidth * column))

      boxCss =
        opacity: 0
        left: "#{boxWidth * column}px"
        top: "#{boxHeight * row}px"
        width: "#{width}px"
        height: "#{boxHeight}px"
        background: background
        overflow: 'hidden'

      $('<div class="rambling-box"></div>').css boxCss
    if settings.adaptImages
      getSlice = getRamblingSlice
      getBox = getRamblingBox

      setSliderBackground = ->
        image = vars.currentImage
        currentImage = slider.find('.currentImage')

        unless currentImage.length
          alignment = 'alignTop'
          alignment = 'alignBottom' if settings.alignBottom
          currentImage = $ '<img src="" alt="currentImage" class="currentImage"/>'
          currentImage.addClass alignment
          currentImage.css display: 'block'
          slider.find('#rambling-animation').prepend currentImage

        currentImage.attr src: image.attr('src'), alt: image.attr('alt')

      getRamblingSlice = (sliceWidth, position, total, vars) ->
        ramblingSlice = getSlice sliceWidth, position, total, vars
        ramblingSlice.css background: 'none'
        ramblingSlice.append "<span><img src=\"#{vars.currentImage.attr('src')}\" alt=\"\"/></span>"

        bottom = 0
        top = 'auto'
        if settings.alignBottom
          bottom = 'auto'
          top = 0

        ramblingSliceImageStyle =
          display: 'block'
          width: slider.width()
          left: "-#{(sliceWidth + (position * sliceWidth)) - sliceWidth}px"
          bottom: bottom
          top: top

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

        ramblingBox.css background: 'none', top: top or 'auto', bottom: bottom or 'auto'
        ramblingBox.append("<span><img src='#{vars.currentImage.attr('src')}' alt=''/></span>")
        ramblingBox.find('img').css ramblingBoxImageStyle

        ramblingBox

    animateFullImage = (options) ->
      slices = createSlices slider, settings, vars
      slice = slices.filter ':first'
      slice.css options.style
      slice.animate (options.animate or width: "#{slider.width()}px"), (settings.speed * 2), '', ->
        options.afterChange.apply(slice) if options.afterChange
        slider.trigger 'rambling:finished'

    animateSlices = (animationCallback, reorderCallback) ->
      slices = createSlices slider, settings, vars
      animationTimeBuffer = 0
      slices = reorderCallback.apply(slices) if reorderCallback
      slices.each animationCallback

    animateBoxes = (animationCallback, reorderCallback) ->
      boxes = createBoxes slider, settings, vars
      animationTimeBuffer = 0
      boxes = reorderCallback.apply(boxes) if reorderCallback
      animationCallback.apply boxes

    slideDownSlices = (reorderCallback) ->
      animateSlices (index) ->
          slice = $ @
          slice.css top: '0px'
          if index is settings.slices - 1
            setTimeout ->
              slice.animate { height:'100%', opacity:'1.0' }, settings.speed, '', -> slider.trigger 'rambling:finished'
            , 100 + animationTimeBuffer
          else
            setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.speed), 100 + animationTimeBuffer

          animationTimeBuffer += 50
        , reorderCallback

    slideUpSlices = (reorderCallback) ->
      animateSlices (index) ->
          slice = $ @
          slice.css bottom: '0px'
          if index is settings.slices - 1
            setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.speed, '', -> slider.trigger 'rambling:finished'), 100 + animationTimeBuffer
          else
            setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.speed), 100 + animationTimeBuffer

          animationTimeBuffer += 50
        , reorderCallback

    slideUpDownSlices = (reorderCallback) ->
      animateSlices (index) ->
          slice = $ @
          slice.css (if index % 2 then bottom: '0px' else top: '0px')

          if index is settings.slices - 1
            setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.speed, '', -> slider.trigger 'rambling:finished'),
              100 + animationTimeBuffer
          else
            setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.speed), 100 + animationTimeBuffer

          animationTimeBuffer += 50
        , reorderCallback

    foldSlices = (reorderCallback) ->
      animateSlices (index) ->
          slice = $ @
          origWidth = slice.width()
          slice.css top: '0px', height: '100%', width: '0px'
          if index is settings.slices - 1
            setTimeout (-> slice.animate { width: origWidth, opacity:'1.0' }, settings.speed, '', -> slider.trigger 'rambling:finished'),
              100 + animationTimeBuffer
          else
            setTimeout (-> slice.animate { width: origWidth, opacity:'1.0' }, settings.speed), 100 + animationTimeBuffer

          animationTimeBuffer += 50
        , reorderCallback

    randomBoxes = ->
      animateBoxes ->
          totalBoxes = @length
          @each (index) ->
            box = $ @
            if index is totalBoxes - 1
              setTimeout (-> box.animate { opacity:'1' }, settings.speed, '', -> slider.trigger 'rambling:finished'),
               100 + animationTimeBuffer
            else
              setTimeout (-> box.animate { opacity:'1' }, settings.speed), 100 + animationTimeBuffer

            animationTimeBuffer += 20
        , $.fn.shuffle

    rainBoxes = (reorderCallback, grow) ->
      animateBoxes ->
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
                  setTimeout (-> box.animate { opacity:'1', width: w, height: h }, settings.speed / 1.3, '', -> slider.trigger 'rambling:finished'),
                    100 + animationTimeBuffer
                else
                  setTimeout (-> box.animate { opacity:'1', width: w, height: h }, settings.speed / 1.3), 100 + animationTimeBuffer

                index++
                animationTimeBuffer += 20

              prevCol--
        , reorderCallback

    animationOptions =
      fade:
        style:
          height: '100%'
          width: "#{slider.width()}px"
          position: 'absolute'
          top: 0
          left: 0
        animate:
          opacity: '1'
      slideInRight:
        style:
          height: '100%'
          width: '0px'
          opacity: '1'
      slideInLeft:
        style:
          height: '100%'
          width: '0px'
          opacity: '1'
          left: ''
          right: '0px'
        afterChange: -> @.css left: '0px', right: ''

    animations =
      sliceDown: slideDownSlices
      sliceDownRight: slideDownSlices
      sliceDownLeft: -> slideDownSlices $.fn.reverse
      sliceUp: slideUpSlices
      sliceUpRight: slideUpSlices
      sliceUpLeft: -> slideUpSlices $.fn.reverse
      sliceUpDown: slideUpDownSlices
      sliceUpDownRight: slideUpDownSlices
      sliceUpDownLeft: -> slideUpDownSlices $.fn.reverse
      fold: foldSlices
      foldLeft: -> foldSlices $.fn.reverse
      fade: -> animateFullImage animationOptions.fade
      slideIn: -> animateFullImage animationOptions.slideInRight
      slideInRight: -> animateFullImage animationOptions.slideInRight
      slideInLeft: -> animateFullImage animationOptions.slideInLeft
      boxRandom: randomBoxes
      boxRain: -> rainBoxes -> $(@).as2dArray settings.boxCols
      boxRainReverse: -> rainBoxes -> $(@).reverse().as2dArray settings.boxCols
      boxRainGrow: -> rainBoxes (-> $(@).as2dArray settings.boxCols), true
      boxRainGrowReverse: -> rainBoxes (-> $(@).reverse().as2dArray settings.boxCols), true

    ramblingRun = (slider, kids, settings, nudge) ->
      settings.lastSlide.call(@) if vars.currentSlide is vars.totalSlides - 1

      return false if vars.stopped and not nudge

      settings.beforeChange.call @

      vars.currentSlide++

      if vars.currentSlide is vars.totalSlides
        vars.currentSlide = 0
        settings.slideshowEnd.call @

      vars.currentSlide = (vars.totalSlides - 1) if vars.currentSlide < 0
      setCurrentSlideImage kids

      slider.find('.rambling-controlNav a').removeClass('active').filter(":eq(#{vars.currentSlide})").addClass('active') if settings.controlNav

      processCaption settings
      slider.find('.rambling-slice,.rambling-box').remove()

      if settings.effect is 'random' or settings.effect.contains(',')
        vars.randomAnimation = getRandomAnimation()
      else
        vars.randomAnimation = null

      vars.running = true
      currentEffect = vars.randomAnimation or settings.effect
      animations[currentEffect].apply @

    settings.afterLoad.call @

    @stop = stop
    @start = start
    @effect = effect
    @option = option
    @initialize = initialize
    @run = run

    @
)(jQuery)
