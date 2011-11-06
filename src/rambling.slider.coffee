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

        if not currentImage.length
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
      child = $ this
      link = ''
      if not child.is('img')
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
      ramblingCaption = $ '.rambling-caption', slider
      title = vars.currentImage.attr('title')
      if title? and title isnt ''
        title = $(title).html() if title.substr(0, 1) is '#'

        if ramblingCaption.css('display') is 'block'
          ramblingCaption.find('p').fadeOut(settings.animSpeed, ->
            $(this).html title
            $(this).fadeIn settings.animSpeed
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
        $('.rambling-directionNav', slider).hide()
        slider.hover (-> $('.rambling-directionNav', slider).show()), (-> $('.rambling-directionNav', slider).hide())

      liveWith = (slider, kids, settings, direction) ->
        return false if vars.running
        clearTimer()
        vars.currentSlide -= 2
        ramblingRun(slider, kids, settings, direction)

      $('a.rambling-prevNav', slider).live 'click', -> liveWith('prev')
      $('a.rambling-nextNav', slider).live 'click', -> liveWith('next')

    ###
    Add Control nav
    ###
    if settings.controlNav
      ramblingControl = $('<div class="rambling-controlNav"></div>')
      slider.append ramblingControl
      for i in [0..(kids.length - 1)] then do (i) ->
        if settings.controlNavThumbs
          child = kids.eq i
          child = child.find('img:first') if not child.is('img')
          if settings.controlNavThumbsFromRel
            ramblingControl.append('<a class="rambling-control" rel="' + i + '"><img src="' + child.attr('rel') + '" alt="" /></a>')
          else
            ramblingControl.append('<a class="rambling-control" rel="' + i + '"><img src="' + child.attr('src').replace(settings.controlNavThumbsSearch, settings.controlNavThumbsReplace) + '" alt="" /></a>')

        else ramblingControl.append('<a class="rambling-control" rel="' + i + '">' + (i + 1) + '</a>')

      ###
      Set initial active link
      ###
      $(".rambling-controlNav a:eq(#{vars.currentSlide})", slider).addClass('active')

      $('.rambling-controlNav a', slider).live 'click', ->
        return false if vars.running
        return false if $(this).hasClass('active')
        clearTimer()
        functions.setSliderBackground(slider, vars)
        vars.currentSlide = $(this).attr('rel') - 1
        ramblingRun(slider, kids, settings, 'control')

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
        if $(this).is('a')
          $(this).css(display: 'none')
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
      settings.afterChange.call(this)

    ###
    Add slices for slice animations
    ###
    createSlices = (slider, settings, vars) ->
      for i in [0..(settings.slices - 1)] then do (i) ->
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

      for rows in [0..(settings.boxRows - 1)] then do (rows) ->
        for cols in [0..(settings.boxCols - 1)] then do (cols) ->
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
      vars = slider.data('rambling:vars')

      ###
      Trigger the lastSlide callback
      ###
      settings.lastSlide.call(this) if vars and vars.currentSlide is vars.totalSlides - 1

      ###
      Stop
      ###
      return false if (not vars or vars.stop) and not nudge

      ###
      Trigger the beforeChange callback
      ###
      settings.beforeChange.call(this)

      vars.currentSlide++
      ###
      Trigger the slideshowEnd callback
      ###
      if vars.currentSlide is vars.totalSlides
        vars.currentSlide = 0
        settings.slideshowEnd.call(this)

      vars.currentSlide = (vars.totalSlides - 1) if vars.currentSlide < 0
      ###
      Set vars.currentImage
      ###
      if $(kids[vars.currentSlide]).is('img')
        vars.currentImage = $(kids[vars.currentSlide])
      else
        vars.currentImage = $(kids[vars.currentSlide]).find('img:first')

      ###
      Set active links
      ###
      if settings.controlNav
        $('.rambling-controlNav a', slider).removeClass('active')
        $('.rambling-controlNav a:eq(' + vars.currentSlide + ')', slider).addClass('active')

      ###
      Process caption
      ###
      processCaption(settings)

      ###
      Remove any slices from last transition
      ###
      $('.rambling-slice', slider).remove()

      ###
      Remove any boxes from last transition
      ###
      $('.rambling-box', slider).remove()

      if settings.effect is 'random'
        anims = ['sliceDownRight', 'sliceDownLeft', 'sliceUpRight', 'sliceUpLeft', 'sliceUpDown', 'sliceUpDownLeft', 'fold', 'fade',
            'boxRandom', 'boxRain', 'boxRainReverse', 'boxRainGrow', 'boxRainGrowReverse']
        vars.randAnim = anims[Math.floor(Math.random() * (anims.length + 1))]
        vars.randAnim = 'fade' if not vars.randAnim

      ###
      Run random effect from specified set (eg: effect:'fold,fade')
      ###
      if settings.effect.indexOf(',') isnt -1
        anims = settings.effect.split(',')
        vars.randAnim = anims[Math.floor(Math.random() * (anims.length))]
        vars.randAnim = 'fade' if vars.randAnim

      ###
      Run effects
      ###
      vars.running = true
      if settings.effect is 'sliceDown' or settings.effect is 'sliceDownRight' or vars.randAnim is 'sliceDownRight' or settings.effect is 'sliceDownLeft' or vars.randAnim is 'sliceDownLeft'
        createSlices(slider, settings, vars)
        timeBuff = 0
        i = 0
        slices = $('.rambling-slice', slider)
        slices = $('.rambling-slice', slider).reverse() if settings.effect is 'sliceDownLeft' or vars.randAnim is 'sliceDownLeft'

        slices.each ->
          slice = $ this
          slice.css top: '0px'
          if i is settings.slices - 1
            setTimeout ->
              slice.animate({ height:'100%', opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger('rambling:animFinished'))
            , 100 + timeBuff
          else
            setTimeout (-> slice.animate({ height:'100%', opacity:'1.0' }, settings.animSpeed)), 100 + timeBuff

          timeBuff += 50
          i++

      else if settings.effect is 'sliceUp' or settings.effect is 'sliceUpRight' or vars.randAnim is 'sliceUpRight' or settings.effect is 'sliceUpLeft' or vars.randAnim is 'sliceUpLeft'
        createSlices(slider, settings, vars)
        timeBuff = 0
        i = 0
        slices = $('.rambling-slice', slider)
        slices = $('.rambling-slice', slider).reverse() if settings.effect is 'sliceUpLeft' or vars.randAnim is 'sliceUpLeft'

        slices.each ->
          slice = $(this)
          slice.css({ 'bottom': '0px' })
          if i is settings.slices - 1
            setTimeout (-> slice.animate({ height:'100%', opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger('rambling:animFinished'))), 100 + timeBuff
          else
            setTimeout (-> slice.animate({ height:'100%', opacity:'1.0' }, settings.animSpeed)), 100 + timeBuff

          timeBuff += 50
          i++

      else if settings.effect is 'sliceUpDown' or settings.effect is 'sliceUpDownRight' or vars.randAnim is 'sliceUpDown' or settings.effect is 'sliceUpDownLeft' or vars.randAnim is 'sliceUpDownLeft'
        createSlices(slider, settings, vars)
        timeBuff = 0
        i = 0
        v = 0
        slices = $('.rambling-slice', slider)
        slices = $('.rambling-slice', slider).reverse() if settings.effect is 'sliceUpDownLeft' or vars.randAnim is 'sliceUpDownLeft'

        slices.each ->
          slice = $ this
          if i is 0
            slice.css('top', '0px')
            i++
          else
            slice.css('bottom', '0px')
            i = 0

          if v is settings.slices - 1
            setTimeout (-> slice.animate({ height:'100%', opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger('rambling:animFinished'))),
              100 + timeBuff
          else
            setTimeout (-> slice.animate({ height:'100%', opacity:'1.0' }, settings.animSpeed)), 100 + timeBuff

          timeBuff += 50
          v++

      else if settings.effect is 'fold' or vars.randAnim is 'fold'
        createSlices(slider, settings, vars)
        timeBuff = 0
        i = 0

        $('.rambling-slice', slider).each ->
          slice = $ this
          origWidth = slice.width()
          slice.css({ top:'0px', height:'100%', width:'0px' })
          if i is settings.slices - 1
            setTimeout (-> slice.animate({ width:origWidth, opacity:'1.0' }, settings.animSpeed, '', -> slider.trigger('rambling:animFinished'))),
              100 + timeBuff
          else
            setTimeout (-> slice.animate({ width:origWidth, opacity:'1.0' }, settings.animSpeed)), 100 + timeBuff

          timeBuff += 50
          i++

      else if settings.effect is 'fade' or vars.randAnim is 'fade'
        createSlices(slider, settings, vars)

        firstSlice = $('.rambling-slice:first', slider)
        sliceStyle =
          height: '100%'
          width: slider.width() + 'px'
          position: 'absolute'
          top: 0
          left: 0

        firstSlice.css sliceStyle
        firstSlice.animate({ opacity:'1.0' }, (settings.animSpeed * 2), '', -> slider.trigger('rambling:animFinished'))

      else if settings.effect is 'slideInRight' or vars.randAnim is 'slideInRight'
        createSlices(slider, settings, vars)

        firstSlice = $('.rambling-slice:first', slider)
        sliceStyle =
          height: '100%'
          width: '0px'
          opacity: '1'

        firstSlice.css(sliceStyle)
        firstSlice.animate({ width: slider.width() + 'px' }, (settings.animSpeed * 2), '', -> slider.trigger('rambling:animFinished'))

      else if settings.effect is 'slideInLeft' or vars.randAnim is 'slideInLeft'
        createSlices(slider, settings, vars)

        firstSlice = $('.rambling-slice:first', slider)
        sliceStyle =
          height: '100%'
          width: '0px'
          opacity: '1'
          left: ''
          right: '0px'

        firstSlice.css(sliceStyle)
        firstSlice.animate({ width: slider.width() + 'px' }, (settings.animSpeed * 2), '', ->
            #Reset positioning
            resetStyle =
              left: '0px'
              right: ''
            firstSlice.css(resetStyle)
            slider.trigger('rambling:animFinished')
        )

      else if settings.effect is 'boxRandom' or vars.randAnim is 'boxRandom'
        createBoxes(slider, settings, vars)

        totalBoxes = settings.boxCols * settings.boxRows
        i = 0
        timeBuff = 0

        boxes = $('.rambling-box', slider).shuffle()
        boxes.each ->
          box = $(this)
          if i is totalBoxes - 1
            setTimeout (-> box.animate({ opacity:'1' }, settings.animSpeed, '', -> slider.trigger('rambling:animFinished'))),
             100 + timeBuff
          else
            setTimeout (-> box.animate({ opacity:'1' }, settings.animSpeed)), 100 + timeBuff

          timeBuff += 20
          i++

      else if settings.effect is 'boxRain' or vars.randAnim is 'boxRain' or settings.effect is 'boxRainReverse' or vars.randAnim is 'boxRainReverse' or settings.effect is 'boxRainGrow' or vars.randAnim is 'boxRainGrow' or settings.effect is 'boxRainGrowReverse' or vars.randAnim is 'boxRainGrowReverse'
        createBoxes(slider, settings, vars)

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
        boxes = $('.rambling-box', slider)
        if settings.effect is 'boxRainReverse' or vars.randAnim is 'boxRainReverse' or settings.effect is 'boxRainGrowReverse' or vars.randAnim is 'boxRainGrowReverse'
          boxes = $('.rambling-box', slider).reverse()

        boxes.each ->
          box2Darr[rowIndex][colIndex] = $(this)
          colIndex++
          if colIndex is settings.boxCols
            rowIndex++
            colIndex = 0
            box2Darr[rowIndex] = new Array()

        ###
        Run animation
        ###
        for cols in [0..(settings.boxCols * 2 - 1)] then do (cols) ->
          prevCol = cols
          for rows in [0..(settings.boxRows - 1)] then do (rows) ->
            if prevCol >= 0 and prevCol < settings.boxCols
              ((row, col, time, i, totalBoxes) ->
                box = $(box2Darr[row][col])
                w = box.width()
                h = box.height()
                if settings.effect is 'boxRainGrow' or vars.randAnim is 'boxRainGrow' or settings.effect is 'boxRainGrowReverse' or vars.randAnim is 'boxRainGrowReverse'
                  box.width(0).height(0)
                if i is totalBoxes - 1
                  setTimeout (-> box.animate({ opacity:'1', width:w, height:h }, settings.animSpeed / 1.3, '', -> slider.trigger('rambling:animFinished'))),
                    100 + time
                else
                  setTimeout (-> box.animate({ opacity:'1', width:w, height:h }, settings.animSpeed / 1.3)), 100 + time
              )(rows, prevCol, timeBuff, i, totalBoxes)
              i++

            prevCol--

          timeBuff += 100

    ###
    For debugging
    ###
    trace = (msg) ->
      console.log(msg) if this.console and console and console.log

    ###
    Start / Stop
    ###
    this.stop = ->
      $element = $ element
      if not $element.data('rambling:vars').stop
        $element.data('rambling:vars').stop = true
        trace 'Stop Slider'

    this.start = ->
      $element = $ element
      if $element.data('rambling:vars').stop
        $element.data('rambling:vars').stop = false
        trace 'Start Slider'

    ###
    Trigger the afterLoad callback
    ###
    settings.afterLoad.call(this)

    this

  $.fn.ramblingSlider = (options) ->
    this.each (key, value) ->
      element = $(this)
      ###
      Return early if this element already has a plugin instance
      ###
      return element.data('ramblingslider') if element.data('ramblingslider')
      ###
      Pass options to plugin constructor
      ###
      ramblingslider = new RamblingSlider(this, options)
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
