(($) ->
  publicMethods = [
    'stop'
    'start'
    'option'
    'effect'
    'destroy'
    'previousSlide'
    'nextSlide'
    'slide'
    'theme'
  ]

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
          throw "Method '#{options}' not found."
        else
          throw "Slider already initialized."
    else
      throw "Tried to call method '#{options}' on element without slider." if methodExists or optionsIsString

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
)(jQuery)
