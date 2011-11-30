(($) ->
  slider = null
  settings = null

  animationSetUp =
    fadeIn: ->
      @css height: '100%', width: "#{slider.width()}px", position: 'absolute', top: 0, left: 0
      {opacity: '1'}
    fadeOut: ->
      @css height: '100%', width: "#{slider.width()}px", position: 'absolute', top: 0, left: 0, opacity: '1'
      {opacity: '0'}
    rolloverRight: ->
      @css height: '100%', width: '0px', opacity: '1'
      return
    rolloverLeft: ->
      @css height: '100%', width: '0px', opacity: '1', left: 'auto', right: '0px'
      @find('img').css(left: "#{-slider.width()}px").animate {left: '0px'}, settings.speed * 2
      {width: "#{slider.width()}"}
    slideInRight: ->
      @css height: '100%', width: '0px', opacity: '1'
      @find('img').css(left: "#{-slider.width()}px").animate {left: '0px'}, settings.speed * 2
      {width: "#{slider.width()}"}
    slideInLeft: ->
      self = @
      self.css height: '100%', width: '0px', opacity: '1', left: 'auto', right: '0px'
      finishedHandler = ->
        self.css left: '0px', right: 'auto'
        slider.unbind 'rambling:finished', finishedHandler
      slider.bind 'rambling:finished', finishedHandler
      return

  flashSlideIn = (beforeAnimation, animateStyle, afterAnimation) ->
    self = @
    self.currentSlideElement.css beforeAnimation
    window.setTimeout (-> self.currentSlideElement.animate animateStyle, self.settings.speed * 2, ->
        self.raiseAnimationFinished()
      ), self.settings.speed * 2

  flashHorizontalSlideIn = (initialLeft) ->
    beforeAnimation =
      top: (if settings.alignBottom then 'auto' else '0')
      bottom: (if settings.alignBottom then '-7px' else 'auto')
      left: initialLeft
      position: 'absolute'
      display: 'block'

    afterAnimation =
      top: 'auto'
      left: 'auto'
      position: 'relative'

    flashSlideIn.apply @ [beforeAnimation, {left: '0'}, afterAnimation]

  $.fn.ramblingSlider.defaults.imageTransitions =
    sliceDownRight: -> @slideDownSlices()
    sliceDownLeft: -> @slideDownSlices $.fn.reverse
    sliceDownOutIn: -> @slideDownSlices $.fn.sortOutIn
    sliceDownInOut: -> @slideDownSlices -> @sortOutIn().reverse()
    sliceDownRandom: -> @slideDownSlices $.fn.shuffle
    sliceUpRight: -> @slideUpSlices()
    sliceUpLeft: -> @slideUpSlices $.fn.reverse
    sliceUpOutIn: -> @slideUpSlices $.fn.sortOutIn
    sliceUpInOut: -> @slideUpSlices -> @sortOutIn().reverse()
    sliceUpRandom: -> @slideUpSlices $.fn.shuffle
    sliceUpDownRight: -> @slideUpDownSlices()
    sliceUpDownLeft: -> @slideUpDownSlices $.fn.reverse
    sliceUpDownOutIn: -> @slideUpDownSlices $.fn.sortOutIn
    sliceUpDownInOut: -> @slideUpDownSlices -> @sortOutIn().reverse()
    sliceUpDownRandom: -> @slideUpDownSlices $.fn.shuffle
    sliceFadeOutIn: -> @fadeSlices $.fn.sortOutIn
    sliceFadeInOut: -> @fadeSlices -> @sortOutIn().reverse()
    foldRight: -> @foldSlices()
    foldLeft: -> @foldSlices $.fn.reverse
    foldOutIn: -> @foldSlices $.fn.sortOutIn
    foldInOut: -> @foldSlices -> @sortOutIn().reverse()
    foldRandom: -> @foldSlices $.fn.shuffle
    fadeIn: ->
      slider = @currentSlideElement.parents('.ramblingSlider').first()
      settings = @settings
      @animateFullImage animationSetUp.fadeIn
    fadeOut: ->
      slider = @currentSlideElement.parents('.ramblingSlider').first()
      settings = @settings
      @animateFullImage animationSetUp.fadeIn
    slideInRight: ->
      slider = @currentSlideElement.parents('.ramblingSlider').first()
      settings = @settings
      @animateFullImage animationSetUp.slideInRight
    slideInLeft: ->
      slider = @currentSlideElement.parents('.ramblingSlider').first()
      settings = @settings
      @animateFullImage animationSetUp.slideInLeft
    rolloverRight: ->
      slider = @currentSlideElement.parents('.ramblingSlider').first()
      settings = @settings
      @animateFullImage animationSetUp.rolloverRight
    rolloverLeft: ->
      slider = @currentSlideElement.parents('.ramblingSlider').first()
      settings = @settings
      @animateFullImage animationSetUp.rolloverLeft
    boxRandom: -> @fadeBoxes $.fn.shuffle
    boxRain: -> @rainBoxes()
    boxRainReverse: -> @rainBoxes $.fn.reverse
    boxRainOutIn: -> @rainBoxes $.fn.sortOutIn
    boxRainInOut: -> @rainBoxes -> @sortOutIn().reverse()
    boxRainGrow: -> @rainBoxes undefined, true
    boxRainGrowReverse: -> @rainBoxes $.fn.reverse, true
    boxRainGrowOutIn: -> @rainBoxes $.fn.sortOutIn, true
    boxRainGrowInOut: -> @rainBoxes (-> @sortOutIn().reverse()), true

  $.fn.ramblingSlider.defaults.imageFlashTransitions =
    fadeOut: ->
      self = @
      slice = self.getOneSlice self.previousSlideElement
      animate = animationSetUp.fadeOut.apply slice

      self.setSliderBackground()
      slice.animate animate, self.settings.speed * 2, '', ->
        slice.css display: 'none'
        self.raiseAnimationFinished()

  $.fn.ramblingSlider.defaults.flashTransitions =
    slideInRight: ->
      slider = @currentSlideElement.parents('.ramblingSlider').first()
      flashHorizontalSlideIn.apply @, ["#{-slider.width()}px"]
    slideInLeft: ->
      slider = @currentSlideElement.parents('.ramblingSlider').first()
      flashHorizontalSlideIn.apply @ ["#{slider.width()}px"]

  $.extend $.fn.ramblingSlider.defaults.imageFlashTransitions, $.fn.ramblingSlider.defaults.flashTransitions

  $.fn.ramblingSlider.defaults.transitionGroups = ['sliceUp', 'sliceDown', 'sliceUpDown', 'fold', 'fade', 'rollover', 'slideIn', 'sliceFade']
  $.fn.ramblingSlider.defaults.transitionGroupSuffixes = ['Right', 'Left', 'OutIn', 'InOut', 'Random', 'In', 'Out']
)(jQuery)
