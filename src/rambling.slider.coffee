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
  RamblingSlider = (element, options) ->
    ###
    Defaults are below
    ###
    settings = $.extend {}, $.fn.ramblingSlider.defaults, options

    ###
    Useful variables. Play carefully.
    ###
    vars =
      currentSlide: 0
      currentImage: ''
      totalSlides: 0
      randAnim: ''
      running: false
      paused: false
      stop: false

    ###
    Additional stuff for adapt images
    ###
    functions = {}
    defaultFunctions =
      setSliderBackground: (slider, vars) ->
        slider.css background: "url(#{vars.currentImage.attr('src')}) no-repeat"

      getRamblingSlice: (sliceWidth, position, total, vars) ->
        background = "url(#{vars.currentImage.attr('src')}) no-repeat -#{((sliceWidth + (position * sliceWidth)) - sliceWidth)}px 0%"
        width = sliceWidth
        if position is (total - 1)
            background = "url(#{vars.currentImage.attr('src')}) no-repeat -#{((sliceWidth + (position * sliceWidth)) - sliceWidth)}px 0%"
            width = slider.width() - (sliceWidth * position)

        sliceCss =
          left: (sliceWidth * position) + 'px'
          width: width + 'px'
          height: '0px'
          opacity: '0'
          background: background
          overflow: 'hidden'

        $('<div class="rambling-slice"></div>').css sliceCss

      getRamblingBox: (boxWidth, boxHeight, row, column, settings, vars) ->
        background = "url(#{vars.currentImage.attr('src')}) no-repeat -#{((boxWidth + (column * boxWidth)) - boxWidth)}px -#{((boxHeight + (row * boxHeight)) - boxHeight)}px"
        width = boxWidth
        if column is (settings.boxCols - 1)
            background = "url(#{vars.currentImage.attr('src')}) no-repeat -#{((boxWidth + (column * boxWidth)) - boxWidth)}px -#{((boxHeight + (row * boxHeight)) - boxHeight)}px"
            width = (slider.width() - (boxWidth * column))

        boxCss =
          opacity: 0
          left:(boxWidth * column) + 'px'
          top:(boxHeight * row) + 'px'
          width:width + 'px'
          height:boxHeight + 'px'
          background: background
          overflow: 'hidden'

        $('<div class="rambling-box"></div>').css boxCss

    adaptImagesFunctions =
      setSliderBackground: ->
        image = vars.currentImage
        currentImage = slider.find('.currentImage')

        unless currentImage.length
          alignment = 'alignTop'
          alignment = 'alignBottom'if settings.alignBottom
          currentImage = $ '<img src="" alt="currentImage" class="currentImage"/>'
          currentImage.addClass alignment
          currentImage.css display: 'block'
          slider.find('#rambling-animation').prepend currentImage

        currentImage.attr src: image.attr('src'), alt: image.attr('alt')

      getRamblingSlice: (sliceWidth, position, total, vars) ->
        ramblingSlice = defaultFunctions.getRamblingSlice sliceWidth, position, total, vars
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
          left: '-' + ((sliceWidth + (position * sliceWidth)) - sliceWidth) + 'px'
          bottom: bottom
          top: top

        ramblingSlice.find('img').css ramblingSliceImageStyle

        ramblingSlice

      getRamblingBox: (boxWidth, boxHeight, row, column, settings, vars) ->
        ramblingBox = defaultFunctions.getRamblingBox boxWidth, boxHeight, row, column, settings, vars

        bottom = false
        top = "#{((boxHeight + (row * boxHeight)) - boxHeight)}px"
        if settings.alignBottom
          bottom = "#{(boxHeight * (settings.boxRows - (row + 1)))}px"
          top = false

        ramblingBoxImageStyle =
          display: 'block'
          width: slider.width()
          left: "-#{((boxWidth + (column * boxWidth)) - boxWidth)}px"
          top: 'auto'
          bottom: 'auto'

        ramblingBoxImageStyle.top = "-#{top}" if top
        ramblingBoxImageStyle.bottom = "-#{bottom}" if bottom

        ramblingBox.css background: 'none', top: top or 'auto', bottom: bottom or 'auto'
        ramblingBox.append('<span><img src="' + vars.currentImage.attr('src') + '" alt=""/></span>')
        ramblingBox.find('img').css ramblingBoxImageStyle

        ramblingBox

    $.extend functions, defaultFunctions
    $.extend functions, adaptImagesFunctions  if settings.adaptImages
    ###
    End adapt images
    ###

    ###
    Get this slider
    ###
    slider = $ element
    slider.data 'rambling:vars', vars
    slider.css position: 'relative'
    slider.addClass 'ramblingSlider'
    if settings.adaptImages
      ramblingAnimationContainer = $ '<div id="rambling-animation"></div>'
      ramblingAnimationContainer.css width: slider.width(), height: slider.height(), overflow: 'hidden'
      slider.prepend ramblingAnimationContainer
      slider.addClass 'adaptingSlider'

    ###
    Find our slider children
    ###
    kids = slider.children ':not(#rambling-animation)'
    kids.each ->
      child = $ @
      link = ''
      unless child.is('img')
        if child.is('a')
          child.addClass 'rambling-imageLink'
          link = child
        child = child.find 'img:first'

      ###
      Get img width & height
      ###
      childWidth = child.width()
      childWidth = child.attr('width') if childWidth is 0
      childHeight = child.height()
      childHeight = child.attr('height') if childHeight is 0

      ###
      Resize the slider
      ###
      slider.width childWidth if childWidth > slider.width() and settings.useLargerImage
      slider.height(childHeight) if childHeight > slider.height() and (settings.useLargerImage or not settings.adaptImages)
      link.css(display: 'none') if link isnt ''

      child.css display: 'none'
      vars.totalSlides++

    ###
    Set startSlide
    ###
    if settings.startSlide > 0
      settings.startSlide = (vars.totalSlides - 1) if settings.startSlide >= vars.totalSlides
      vars.currentSlide = settings.startSlide

    ###
    Get initial image
    ###
    if $(kids[vars.currentSlide]).is('img')
      vars.currentImage = $ kids[vars.currentSlide]
    else
      vars.currentImage = $(kids[vars.currentSlide]).find 'img:first'

    ###
    Show initial link
    ###
    $(kids[vars.currentSlide]).css('display', 'block') if $(kids[vars.currentSlide]).is('a')

    ###
    Set first background
    ###
    functions.setSliderBackground slider, vars

    ###
    Create caption
    ###
    slider.append $('<div class="rambling-caption"><p></p></div>').css(display:'none', opacity: settings.captionOpacity)

    ###
    Process caption function
    ###
    processCaption = (settings) ->
      ramblingCaption = slider.find '.rambling-caption'
      title = vars.currentImage.attr('title')
      if title? and title isnt ''
        title = $(title).html() if title.substr(0, 1) is '#'

        if ramblingCaption.css('display') is 'block'
          ramblingCaption.find('p').fadeOut(settings.animSpeed, ->
            $(@).html title
            $(@).fadeIn settings.animSpeed
          )
        else ramblingCaption.find('p').html title

        ramblingCaption.fadeIn settings.animSpeed
      else ramblingCaption.fadeOut settings.animSpeed

    ###
    Process initial  caption
    ###
    processCaption settings

    ###
    In the words of Super Mario "let's a go!"
    ###
    timer = 0
    if not settings.manualAdvance and kids.length > 1
      timer = setInterval (-> ramblingRun(slider, kids, settings, false)), settings.pauseTime

    clearTimer = ->
      clearInterval timer
      timer = ''

    ###
    Add Direction nav
    ###
    if settings.directionNav
      slider.append('<div class="rambling-directionNav"><a class="rambling-prevNav">' + settings.prevText + '</a><a class="rambling-nextNav">' + settings.nextText + '</a></div>')

      ###
      Hide Direction nav
      ###
      if settings.directionNavHide
        directionNav = slider.find '.rambling-directionNav'
        directionNav.hide()
        slider.hover (-> directionNav.show()), (-> directionNav.hide())

      liveWith = (slider, kids, settings, direction) ->
        return false if vars.running
        clearTimer()
        vars.currentSlide -= 2
        ramblingRun(slider, kids, settings, direction)

      slider.find('a.rambling-prevNav').live 'click', -> liveWith('prev')
      slider.find('a.rambling-nextNav').live 'click', -> liveWith('next')

    ###
    Add Control nav
    ###
    if settings.controlNav
      ramblingControl = $('<div class="rambling-controlNav"></div>')
      slider.append ramblingControl
      for i in [0...kids.length] then do (i) ->
        if settings.controlNavThumbs
          child = kids.eq i
          child = child.find('img:first') unless child.is('img')
          if settings.controlNavThumbsFromRel
            ramblingControl.append('<a class="rambling-control" rel="' + i + '"><img src="' + child.attr('rel') + '" alt="" /></a>')
          else
            ramblingControl.append('<a class="rambling-control" rel="' + i + '"><img src="' + child.attr('src').replace(settings.controlNavThumbsSearch, settings.controlNavThumbsReplace) + '" alt="" /></a>')

        else ramblingControl.append('<a class="rambling-control" rel="' + i + '">' + (i + 1) + '</a>')

      ###
      Set initial active link
      ###
      controlNavAnchors = slider.find '.rambling-controlNav a'
      controlNavAnchors.filter(":eq(#{vars.currentSlide})").addClass 'active'

      controlNavAnchors.live 'click', ->
        return false if vars.running
        return false if $(@).hasClass 'active'
        clearTimer()
        functions.setSliderBackground slider, vars
        vars.currentSlide = $(@).attr('rel') - 1
        ramblingRun slider, kids, settings, 'control'

    ###
    Keyboard Navigation
    ###
    if settings.keyboardNav
      $(window).keypress (event) ->
        ###
        Left
        ###
        if event.keyCode is '37'
          return false if vars.running
          clearTimer()
          vars.currentSlide -= 2
          ramblingRun(slider, kids, settings, 'prev')
        ###
        Right
        ###
        if event.keyCode == '39'
          return false if vars.running
          clearTimer()
          ramblingRun(slider, kids, settings, 'next')

    ###
    For pauseOnHover setting
    ###
    if settings.pauseOnHover
      slider.hover ->
        vars.paused = true
        clearTimer()
      , ->
        vars.paused = false
        #Restart the timer
        if timer is '' and not settings.manualAdvance
          timer = setInterval (-> ramblingRun(slider, kids, settings, false)), settings.pauseTime

    ###
    Event when Animation finishes
    ###
    slider.bind 'rambling:animFinished', ->
      vars.running = false
      ###
      Hide child links
      ###
      $(kids).each ->
        if $(@).is('a')
          $(@).css(display: 'none')
      ###
      Show current link
      ###
      if $(kids[vars.currentSlide]).is('a')
          $(kids[vars.currentSlide]).css(display: 'block')
      ###
      Restart the timer
      ###
      if timer is '' and not vars.paused and not settings.manualAdvance
        timer = setInterval (-> ramblingRun(slider, kids, settings, false)), settings.pauseTime

      functions.setSliderBackground(slider, vars)
      ###
      Trigger the afterChange callback
      ###
      settings.afterChange.call @

    ###
    Add slices for slice animations
    ###
    createSlices = (slider, settings, vars) ->
      for i in [0...settings.slices] then do (i) ->
        sliceWidth = Math.round(slider.width() / settings.slices)
        animationContainer = slider
        animationContainer = slider.find('#rambling-animation') if settings.adaptImages
        animationContainer.append(functions.getRamblingSlice(sliceWidth, i, settings.slices, vars))

    ###
    Add boxes for box animations
    ###
    createBoxes = (slider, settings, vars) ->
      boxWidth = Math.round(slider.width() / settings.boxCols)
      boxHeight = Math.round(slider.height() / settings.boxRows)

      for rows in [0...settings.boxRows] then do (rows) ->
        for cols in [0...settings.boxCols] then do (cols) ->
          animationContainer = slider
          animationContainer = slider.find('#rambling-animation') if settings.adaptImages
          animationContainer.append(functions.getRamblingBox(boxWidth, boxHeight, rows, cols, settings, vars))

    ###
    Private run method
    ###
    ramblingRun = (slider, kids, settings, nudge) ->
      ###
      Get our vars
      ###
      vars = slider.data 'rambling:vars'

      ###
      Trigger the lastSlide callback
      ###
      settings.lastSlide.call(@) if vars and vars.currentSlide is vars.totalSlides - 1

      ###
      Stop
      ###
      return false if (not vars or vars.stop) and not nudge

      ###
      Trigger the beforeChange callback
      ###
      settings.beforeChange.call @

      vars.currentSlide++
      ###
      Trigger the slideshowEnd callback
      ###
      if vars.currentSlide is vars.totalSlides
        vars.currentSlide = 0
        settings.slideshowEnd.call @

      vars.currentSlide = (vars.totalSlides - 1) if vars.currentSlide < 0
      ###
      Set vars.currentImage
      ###
      if $(kids[vars.currentSlide]).is 'img'
        vars.currentImage = $ kids[vars.currentSlide]
      else
        vars.currentImage = $(kids[vars.currentSlide]).find 'img:first'

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
      Remove any slices from last transition
      ###
      slider.find('.rambling-slice').remove()

      ###
      Remove any boxes from last transition
      ###
      slider.find('.rambling-box').remove()

      if settings.effect is 'random'
        anims = [
          'sliceDownRight',
          'sliceDownLeft',
          'sliceUpRight',
          'sliceUpLeft',
          'sliceUpDown',
          'sliceUpDownLeft',
          'fold',
          'fade',
          'boxRandom',
          'boxRain',
          'boxRainReverse',
          'boxRainGrow',
          'boxRainGrowReverse'
        ]

        vars.randAnim = anims[Math.floor(Math.random() * (anims.length + 1))]
        vars.randAnim = 'fade' unless vars.randAnim

      ###
      Run random effect from specified set (eg: effect:'fold,fade')
      ###
      if settings.effect.indexOf(',') isnt -1
        anims = settings.effect.split ','
        vars.randAnim = anims[Math.floor(Math.random() * (anims.length))]
        vars.randAnim = 'fade' unless vars.randAnim

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
                slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger 'rambling:animFinished'
              , 100 + timeBuff
            else
              setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed), 100 + timeBuff

            timeBuff += 50
            i++
          sliceUp: ->
            slice = $ @
            slice.css bottom: '0px'
            if i is settings.slices - 1
              setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger 'rambling:animFinished'), 100 + timeBuff
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
              setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger 'rambling:animFinished'),
                100 + timeBuff
            else
              setTimeout (-> slice.animate { height:'100%', opacity:'1.0' }, settings.animSpeed), 100 + timeBuff

            timeBuff += 50
            v++
          fold: ->
            slice = $ @
            origWidth = slice.width()
            slice.css { top:'0px', height:'100%', width:'0px' }
            if i is settings.slices - 1
              setTimeout (-> slice.animate { width: origWidth, opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger 'rambling:animFinished'),
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
          slider.trigger 'rambling:animFinished'

      else if current_effect is 'boxRandom'
        createBoxes slider, settings, vars

        totalBoxes = settings.boxCols * settings.boxRows
        i = 0
        timeBuff = 0

        boxes = slider.find('.rambling-box').shuffle()
        boxes.each ->
          box = $ @
          if i is totalBoxes - 1
            setTimeout (-> box.animate({ opacity:'1' }, settings.animSpeed, '', -> slider.trigger('rambling:animFinished'))),
             100 + timeBuff
          else
            setTimeout (-> box.animate({ opacity:'1' }, settings.animSpeed)), 100 + timeBuff

          timeBuff += 20
          i++

      else if ['boxRain', 'boxRainReverse', 'boxRainGrow', 'boxRainGrowReverse'].contains current_effect
        createBoxes slider, settings, vars

        totalBoxes = settings.boxCols * settings.boxRows
        i = 0
        timeBuff = 0

        ###
        Split boxes into 2D array
        ###
        rowIndex = 0
        colIndex = 0
        box2Darr = new Array()
        box2Darr[rowIndex] = new Array()
        boxes = slider.find '.rambling-box'
        if current_effect is 'boxRainReverse' or current_effect is 'boxRainGrowReverse'
          boxes = boxes.reverse()

        boxes.each ->
          box2Darr[rowIndex][colIndex] = $ @
          colIndex++
          if colIndex is settings.boxCols
            rowIndex++
            colIndex = 0
            box2Darr[rowIndex] = new Array()

        ###
        Run animation
        ###
        for cols in [0...(settings.boxCols * 2)] then do (cols) ->
          prevCol = cols
          for rows in [0...settings.boxRows] then do (rows) ->
            if prevCol >= 0 and prevCol < settings.boxCols
              ((row, col, time, i, totalBoxes) ->
                box = $(box2Darr[row][col])
                w = box.width()
                h = box.height()
                if current_effect is 'boxRainGrow' or current_effect is 'boxRainGrowReverse'
                  box.width(0).height(0)
                if i is totalBoxes - 1
                  setTimeout (-> box.animate { opacity:'1', width:w, height:h }, settings.animSpeed / 1.3, '', -> slider.trigger 'rambling:animFinished'),
                    100 + time
                else
                  setTimeout (-> box.animate { opacity:'1', width:w, height:h }, settings.animSpeed / 1.3), 100 + time
              )(rows, prevCol, timeBuff, i, totalBoxes)
              i++

            prevCol--

          timeBuff += 100

    ###
    For debugging
    ###
    trace = (msg) ->
      console.log(msg) if @console and console and console.log

    ###
    Start / Stop
    ###
    @stop = ->
      $element = $ element
      unless $element.data('rambling:vars').stop
        $element.data('rambling:vars').stop = true
        trace 'Stop Slider'

    @start = ->
      $element = $ element
      if $element.data('rambling:vars').stop
        $element.data('rambling:vars').stop = false
        trace 'Start Slider'

    ###
    Trigger the afterLoad callback
    ###
    settings.afterLoad.call @

    @

  $.fn.ramblingSlider = (options) ->
    @each (key, value) ->
      element = $ @
      ###
      Return early if this element already has a plugin instance
      ###
      return element.data('ramblingslider') if element.data('ramblingslider')
      ###
      Pass options to plugin constructor
      ###
      ramblingslider = new RamblingSlider(@, options)
      ###
      Store plugin object in this element's data
      ###
      element.data('ramblingslider', ramblingslider)

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

  $.fn.reverse = [].reverse
  $.fn.shuffle = [].shuffle
)(jQuery)
