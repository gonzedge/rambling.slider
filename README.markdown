# jQuery Rambling Slider

The jQuery Rambling Slider is a CoffeeScript improved modified version of the [jQuery Nivo Slider](http://github.com/gilbitron/Nivo-Slider) by Gilbert Pellegrom, which is "The Most Awesome jQuery Image Slider".
It includes some new options and methods to give the slider the ability to adapt different image sizes, flash support and transitions extensions.

You can find more about it on [my blog](http://www.ramblinglabs.com/blog) or on [this repository's wiki](http://github.com/ramblinglabs/rambling.slider/wiki).

## How to use the jQuery Rambling Slider

The compiled JavaScript files, both for development and production, are in the `lib/` directory, named `jquery.rambling.slider.js` and `jquery.rambling.slider.min.js` respectively. Include one of them on your html and, assuming you have something like this:

``` html
<div id="slider">
  <img src="images/image1.jpg" alt="image1"/>
  <a href="#link"><img src="images/image2.jpg" alt="image2"/></a>
  <img src="images/image3.jpg" alt="image3"/>
  <img src="images/image4.jpg" alt="image4"/>
</div>
```

You can then initialize your slider with:

``` javascript
$(window).load(function(){
  $('#slider').ramblingSlider();
});
```

Note that it's set up in the `load` event from `window`, to ensure that the images are already loaded.

### Examples

There are usage examples available in the `examples/` directory.
You might want to see `default.html`, `adaptive.html` and `flash.html`.

## Issues

Please submit any issue you have or any bug that you find with the slider to [the project's issues on GitHub](http://github.com/ramblinglabs/rambling.slider/issues).

## Features

Among others, the new features added on top of the Nivo Slider include:

* `adaptImages`. __Default value:__ `false`. __Description:__ When set to `true`, uses images instead of backgrounds for the animations, and scales the images to the maximum dimension available.
* `useLargerImage`. __Default value:__ `true`. __Description:__ When set to `true`, uses the larger image dimensions as the maximum dimension available. Otherwise, it uses the slider width as the maximum available.
* `alignBottom`. __Default value:__ `false`. __Description:__ When set to `true`, aligns the bottom right corner of the scaled images with the bottom right corner of the slider. Otherwise, the images are aligned to the top left of the slider.
* Methods `stop`, `start` can be called via `$('#slider').ramblingSlider('stop')` and allow method chaining.
* Methods `option` and `effect` were added. Allow method chaining when calling the setters.
* Method `destroy` was added and allows method chaining.
* Methods `previousSlide`, `nextSlide` and `slide` were added and allow method chaining.
* Method `theme` was added and allows method chaining.
* Some new transitions: `foldLeft`, `rolloverLeft`, `rolloverRight`, `slideInRight`, `sliceUpRandom`, `sliceDownRandom`, `sliceUpDownRandom`, `foldRandom`, `sliceUpOutIn`, `sliceUpInOut`, `sliceDownOutIn`, `sliceDownInOut`, `sliceUpDownOutIn`, `sliceUpDownInOut`, `sliceFadeOutIn`, `sliceFadeInOut`, `foldOutIn`, `foldInOut`, `boxRainOutIn`, `boxRainInOut`, `boxRainGrowOutIn`, `boxRainGrowInOut`.
* Support for transitions extensibility. See [Adding and Overriding Transitions](http://github.com/ramblinglabs/rambling.slider/wiki/Adding-and-Overriding-Transitions).
* Support for flash elements.
* `fadeOut`, `slideInRight` and `slideInLeft` transitions from image to flash object.
* `slideInRight` and `slideInLeft` transitions from one flash object to another one.

## Supported jQuery versions

The jQuery Rambling Slider has been tested with the following jQuery Releases:

* 1.7.x
* 1.6.x
* 1.5.x
* 1.4.x
* 1.3.x

For more info on the jQuery versions supported go to the [Supported jQuery Versions page](http://github.com/ramblinglabs/rambling.slider/wiki/Supported-jQuery-Versions).

## CoffeeScript and Cake

If you're interested in modifying or improving this script, you'll need to resolve these dependencies first:

* NodeJS (`apt-get install nodejs`)
* Node Package Manager -- optional (`apt-get install npm`)
* CoffeeScript (`apt-get install coffeescript` or `npm install -g coffee-script`)

You can run your development build like this:

`cake build`

And your production build like this:

`cake -e 'production' build`

If you want to minify the existing js:

`cake minify`

### Unit testing

If you want to run the unit tests, you'll need to install the following node packages:

* `jasmine-node`
* `jsdom`
* `jquery`

They're easily installed with:

`npm install -g jasmine-node`
`npm install -g jsdom`
`npm install -g jquery`

To run all the tests, you can run:

`jasmine-node --coffee spec/`

Or simply:

`cake spec`

## License and copyright

Copyright (c) 2011-2012 Rambling Labs

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
