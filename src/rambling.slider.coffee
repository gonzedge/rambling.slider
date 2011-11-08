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

  methods = ['stop', 'start']

  $.fn.ramblingSlider = (options) ->
    @each (key, value) ->
      element = $ @

      if (ramblingSlider = element.data 'rambling:slider')
        ramblingSlider[options]() if methods.contains(options)
        return ramblingSlider

      element.data 'rambling:slider', new RamblingSlider(@, options)

  ###
  Default settings
  ###
  $.fn.ramblingSlider.defaults =
    effect: 'random'
    slices: 15
    boxCols: 8
    boxRows: 4
    animSpeed: 500
    pauseTime: 3000
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
    alignBottom: false
    keyboardNav: true
    pauseOnHover: true
    manualAdvance: false
    captionOpacity: 0.8
    prevText: 'Prev'
    nextText: 'Next'
    beforeChange: ->
    afterChange: ->
    slideshowEnd: ->
    lastSlide: ->
    afterLoad: ->

  RamblingSlider = (element, options) ->
    slider = $ element
    settings = $.extend {}, $.fn.ramblingSlider.defaults, options
    timer = 0
    vars =
      currentSlide: 0
      currentImage: ''
      totalSlides: 0
      randAnim: ''
      running: false
      paused: false
      stop: false
    anims = [
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
    anims = settings.effect.split(',') if settings.effect.contains(',')

    @stop = -> vars.stop = true unless vars.stop

    @start = -> vars.stop = false if vars.stop

    initialize = ->
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

    getRandomAnimation = -> anims[Math.floor(Math.random() * (anims.length + 1))] or 'fade'

    processCaption = (settings) ->
      ramblingCaption = slider.find '.rambling-caption'
      title = vars.currentImage.attr 'title'
      if title
        title = $(title).html() if title.substr(0, 1) is '#'

        if ramblingCaption.css('display') is 'block'
          ramblingCaption.find('p').fadeOut settings.animSpeed, ->
            $(@).html title
            $(@).fadeIn settings.animSpeed
        else ramblingCaption.find('p').html title

        ramblingCaption.fadeIn settings.animSpeed
      else ramblingCaption.fadeOut settings.animSpeed

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

    createBoxes = (slider, settings, vars) ->
      boxWidth = Math.round(slider.width() / settings.boxCols)
      boxHeight = Math.round(slider.height() / settings.boxRows)

      for rows in [0...settings.boxRows] then do (rows) ->
        for cols in [0...settings.boxCols] then do (cols) ->
          animationContainer = slider
          animationContainer = slider.find('#rambling-animation') if settings.adaptImages
          animationContainer.append getRamblingBox(boxWidth, boxHeight, rows, cols, settings, vars)

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

    kids = slider.children ':not(#rambling-animation)'
    initialize()
    run()

    ramblingRun = (slider, kids, settings, nudge) ->
      settings.lastSlide.call(@) if vars and vars.currentSlide is vars.totalSlides - 1

      return false if (not vars or vars.stop) and not nudge

      settings.beforeChange.call @

      vars.currentSlide++

      if vars.currentSlide is vars.totalSlides
        vars.currentSlide = 0
        settings.slideshowEnd.call @

      vars.currentSlide = (vars.totalSlides - 1) if vars.currentSlide < 0
      setCurrentSlideImage kids

      ###
      Set active links
      ###
      if settings.controlNav
        controlNavAnchors = slider.find '.rambling-controlNav a'
        controlNavAnchors.removeClass 'active'
        controlNavAnchors.filter(":eq(#{vars.currentSlide})").addClass 'active'

      ###
      Process caption
      ###
      processCaption settings

      ###
      Remove any slices and boxes from last transition
      ###
      slider.find('.rambling-slice,.rambling-box').remove()

      ###
      Run random effect from specified or default set (eg: effect:'fold,fade')
      ###
      vars.randAnim = getRandomAnimation() if settings.effect is 'random' or settings.effect.contains(',')

      ###
      Run effects
      ###
      vars.running = true
      current_effect = vars.randAnim or settings.effect

      if current_effect.contains('slice') or current_effect.contains('fold')
        createSlices slider, settings, vars
        timeBuff = 0
        i = 0
        v = 0
        slices = slider.find '.rambling-slice'
        slices = slices.reverse() if current_effect.contains 'Left'
        animation = current_effect.replace(/Right/, '').replace(/Left/, '')

        animation_callbacks =
          sliceDown: ->
            slice = $ @
            slice.css top: '0px'
            if i is settings.slices - 1
              setTimeout ->
                slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger 'rambling:finished'
              , 100 + timeBuff
            else
              setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed), 100 + timeBuff

            timeBuff += 50
            i++
          sliceUp: ->
            slice = $ @
            slice.css bottom: '0px'
            if i is settings.slices - 1
              setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger 'rambling:finished'), 100 + timeBuff
            else
              setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed), 100 + timeBuff

            timeBuff += 50
            i++
          sliceUpDown: ->
            slice = $ @
            if i is 0
              slice.css top: '0px'
              i++
            else
              slice.css bottom: '0px'
              i = 0

            if v is settings.slices - 1
              setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger 'rambling:finished'),
                100 + timeBuff
            else
              setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed), 100 + timeBuff

            timeBuff += 50
            v++
          fold: ->
            slice = $ @
            origWidth = slice.width()
            slice.css top: '0px', height: '100%', width: '0px'
            if i is settings.slices - 1
              setTimeout (-> slice.animate { width: origWidth, opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger 'rambling:finished'),
                100 + timeBuff
            else
              setTimeout (-> slice.animate { width: origWidth, opacity:'1.0' }, settings.animSpeed), 100 + timeBuff

            timeBuff += 50
            i++

        slices.each animation_callbacks[animation]

      else if current_effect is 'fade' or current_effect is 'slideInRight' or current_effect is 'slideInLeft'
        createSlices slider, settings, vars

        animation_options =
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
            callback: (slice) ->
              #Reset positioning
              resetStyle =
                left: '0px'
                right: ''
              slice.css resetStyle

        current_effect_options = animation_options[current_effect]
        animate = current_effect_options.animate or {width: "#{slider.width()}px"}

        firstSlice = slider.find '.rambling-slice:first'
        firstSlice.css animation_options[current_effect].style
        firstSlice.animate animate, (settings.animSpeed * 2),'', ->
          current_effect_options.callback(firstSlice) if current_effect_options.callback
          slider.trigger 'rambling:finished'

      else if current_effect.contains('box')
        createBoxes slider, settings, vars

        totalBoxes = settings.boxCols * settings.boxRows
        i = 0
        timeBuff = 0

        boxes = slider.find '.rambling-box'
        boxes = boxes.reverse() if current_effect.contains('Reverse')

        animation_callbacks =
          random:
            beforeAnimation: ->
              boxes = boxes.shuffle()
            animate: (boxes) ->
              boxes.each ->
                box = $ @
                if i is totalBoxes - 1
                  setTimeout (-> box.animate { opacity:'1' }, settings.animSpeed, '', -> slider.trigger 'rambling:finished'),
                   100 + timeBuff
                else
                  setTimeout (-> box.animate { opacity:'1' }, settings.animSpeed), 100 + timeBuff

                timeBuff += 20
                i++
          rain:
            beforeAnimation: ->
              boxes = boxes.as2dArray settings.boxCols
            animate: (boxes) ->
              for cols in [0...(settings.boxCols * 2)] then do (cols) ->
                prevCol = cols
                for rows in [0...settings.boxRows] then do (rows) ->
                  if prevCol >= 0 and prevCol < settings.boxCols
                    row = rows
                    col = prevCol
                    time = timeBuff
                    box = $ boxes[row][col]
                    w = box.width()
                    h = box.height()

                    box.css(width: 0, height: 0) if current_effect.contains('Grow')

                    if i is totalBoxes - 1
                      setTimeout (-> box.animate { opacity:'1', width: w, height: h }, settings.animSpeed / 1.3, '', -> slider.trigger 'rambling:finished'),
                        100 + time
                    else
                      setTimeout (-> box.animate { opacity:'1', width: w, height: h }, settings.animSpeed / 1.3), 100 + time
                    i++

                  prevCol--

                timeBuff += 100

        current_animation = current_effect.replace(/box/, '').replace(/Grow/, '').replace(/Reverse/, '').decapitalize()
        callbacks = animation_callbacks[current_animation]

        callbacks.beforeAnimation()
        callbacks.animate boxes

    settings.afterLoad.call @

    @
)(jQuery)
