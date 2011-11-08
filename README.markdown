# jQuery Rambling Slider

The jQuery Rambling Slider is a CoffeeScript improved modified version of the [jQuery Nivo Slider](http://github.com/gilbitron/Nivo-Slider) by Gilbert Pellegrom, which is "The Most Awesome jQuery Image Slider".
It includes some new options to give the slider the ability to adapt different image sizes.

You can find more about it on [my blog](http://ramblinglabs.com).

## How to use the jQuery Rambling Slider

The compiled JavaScript files, both for development and production, are in the lib/ directory, named "jquery.rambling.slider.js" and "jquery.rambling.slider.min.js" respectively.

### Examples

There are usage examples available in the examples/ directory.
You might want to see both "examples/default.html" and "examples/adaptive.html".

## Features

Among others, the new features added on top of the Nivo Slider include:

* <code>adaptImages</code>. __Default value:__ <code>false</code>. __Description:__ When set to <code>true</code>, uses images instead of backgrounds for the animations, and scales the images to the maximum dimension available.
* <code>useLargerImage</code>. __Default value:__ <code>true</code>. __Description:__ When set to <code>true</code>, uses the larger image dimensions as the maximum dimension available. Otherwise, it uses the slider width as the maximum available.
* <code>alignBottom</code>. __Default value:__ <code>false</code>. __Description:__ When set to <code>true</code>, aligns the bottom right corner of the scaled images with the bottom right corner of the slider. Otherwise, the images are aligned to the top left of the slider.

## CoffeeScript and Cake

If you're interested in modifying or improving this script, you'll need to resolve these dependencies first:

* NodeJS (<code>apt-get install nodejs</code>)
* Node Package Manager -- optional (<code>apt-get install npm</code>)
* CoffeeScript (<code>apt-get install coffeescript</code> or <code>npm install -g coffee-script</code>)

You can run your development build like this:

<code>cake build</code>

And your production build like this:

<code>cake -e 'production' build</code>

If you want to minify the existing js:

<code>cake minify</code>

### Unit testing

If you want to run the unit tests, you'll need to install the following node packages:
* <code>jasmine-node</code>
* <code>jsdom</code>
* <code>jquery</code>

They're easily installed with:

<code>npm install -g jasmine-node</code>
<code>npm install -g jsdom</code>
<code>npm install -g jquery</code>

To run all the tests, you can run:

<code>jasmine-node --coffee spec/</code>

Or simply:

<code>cake spec</code>

## License and copyright

Copyright (c) 2011 Edgar Gonzalez

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
