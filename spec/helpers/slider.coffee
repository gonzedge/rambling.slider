beforeEach ->
  @helpers =
    create_slider: (options...) =>
      @slider_wrapper = $ '<div id="slider-wrapper" class="theme-default"></div>'
      sliderTemplate = options[0] and options[0].sliderTemplate
      @rambling_slider = $(if sliderTemplate then sliderTemplate else '<div id="#slider"><img src="image1.jpg" alt="image1" /><img src="image2.jpg" alt="image2" /><img src="image3.jpg" alt="image3" /></div>')
      @slider_wrapper.append @rambling_slider
      $('body').empty().append @slider_wrapper
      if options.length
        @rambling_slider.ramblingSlider options[0]
      else
        @rambling_slider.ramblingSlider()

    destroy_slider: =>
      @rambling_slider.data 'rambling:slider', null
      @rambling_slider.data 'rambling:vars', null
      @rambling_slider.remove()
      @slider_wrapper.remove()
      $('body').empty()
