(function() {
  var __slice = Array.prototype.slice, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  Array.prototype.shuffle = function() {
    var i, j, length, x;
    length = this.length;
    for (i = length; length <= 1 ? i <= 1 : i >= 1; length <= 1 ? i++ : i--) {
      this[i] = this[i];
      j = parseInt(Math.random() * i);
      x = this[--i];
      this[i] = this[j];
      this[j] = x;
    }
    return this;
  };
  Array.prototype.contains = function(value) {
    var i, length;
    length = this.length;
    for (i = 0; 0 <= length ? i < length : i > length; 0 <= length ? i++ : i--) {
      if (value === this[i]) {
        return true;
      }
    }
    return false;
  };
  (function($) {
    $.fn.reverse = [].reverse;
    $.fn.shuffle = [].shuffle;
    return $.fn.as2dArray = function(totalColumns) {
      var array_2d, colIndex, rowIndex;
      rowIndex = 0;
      colIndex = 0;
      array_2d = $('');
      array_2d[rowIndex] = $('');
      this.each(function() {
        array_2d[rowIndex][colIndex] = $(this);
        colIndex++;
        if (colIndex === totalColumns) {
          rowIndex++;
          colIndex = 0;
          return array_2d[rowIndex] = $('');
        }
      });
      return array_2d;
    };
  })(jQuery);
  /*
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
  */
  (function($) {
    var RamblingSlider, cannotChange, publicMethods;
    publicMethods = ['stop', 'start', 'option', 'effect'];
    $.fn.ramblingSlider = function() {
      var isCallingGetter, methodExists, options, optionsIsString, others, ramblingSlider, value;
      options = arguments[0], others = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      methodExists = __indexOf.call(publicMethods, options) >= 0;
      optionsIsString = (typeof options) === 'string';
      ramblingSlider = this.data('rambling:slider');
      isCallingGetter = function(options, others) {
        return !others.length || (options === 'option' && others.length === 1 && typeof others[0] === 'string');
      };
      if (ramblingSlider) {
        if (methodExists) {
          value = ramblingSlider[options].apply(ramblingSlider, others);
          if (isCallingGetter(options, others)) {
            return value;
          } else {
            return this;
          }
        } else {
          if (optionsIsString) {
            return $.error("Method '" + options + "' not found.");
          } else {
            if (options) {
              return $.error("Slider already initialized.");
            }
          }
        }
      } else {
        if (methodExists || optionsIsString) {
          return $.error("Tried to call method '" + options + "' on element without slider.");
        }
      }
      return this.each(function(key, value) {
        var element;
        element = $(this);
        if (element.data('rambling:slider')) {
          return;
        }
        ramblingSlider = new RamblingSlider(this, options);
        element.data('rambling:slider', ramblingSlider);
        ramblingSlider.initialize();
        return ramblingSlider.run();
      });
    };
    $.fn.ramblingSlider.defaults = {
      slices: 15,
      boxCols: 8,
      boxRows: 4,
      speed: 500,
      pauseTime: 3000,
      manualAdvance: false,
      captionOpacity: 0.8,
      startSlide: 0,
      effect: 'random',
      directionNav: true,
      directionNavHide: true,
      controlNav: true,
      controlNavThumbs: false,
      controlNavThumbsFromRel: false,
      controlNavThumbsSearch: '.jpg',
      controlNavThumbsReplace: '_thumb.jpg',
      adaptImages: false,
      useLargerImage: true,
      alignBottom: false,
      keyboardNav: true,
      pauseOnHover: true,
      prevText: 'Prev',
      nextText: 'Next',
      beforeChange: function() {},
      afterChange: function() {},
      slideshowEnd: function() {},
      lastSlide: function() {},
      afterLoad: function() {}
    };
    cannotChange = ['startSlide', 'directionNav', 'directionNavHide', 'controlNav', 'controlNavThumbs', 'controlNavThumbsFromRel', 'controlNavThumbsSearch', 'controlNavThumbsReplace', 'adaptImages', 'useLargerImage', 'alignBottom', 'keyboardNav', 'pauseOnHover', 'prevText', 'nextText'];
    return RamblingSlider = function(element, options) {
      var addCaption, addControlNavigation, addDirectionNavigation, addKeyboardNavigation, animateBoxes, animateFullImage, animateSlices, animationOptions, animationTimeBuffer, animations, animationsToRun, createBoxes, createSlices, effect, foldSlices, getBox, getRamblingBox, getRamblingSlice, getRandomAnimation, getSlice, initialize, kids, option, pauseSlider, prepareAdaptiveSlider, prepareSliderChildren, processCaption, rainBoxes, ramblingRun, randomBoxes, resetTimer, run, setAnimationFinishedActions, setCurrentSlideImage, setSliderBackground, setSliderInitialState, settings, slideDownSlices, slideTo, slideUpDownSlices, slideUpSlices, slider, start, stop, timer, unpauseSlider, vars;
      slider = $(element);
      kids = slider.children(':not(#rambling-animation)');
      settings = $.extend({}, $.fn.ramblingSlider.defaults, options);
      animationsToRun = [];
      timer = 0;
      animationTimeBuffer = 0;
      vars = {
        currentSlide: 0,
        currentImage: '',
        totalSlides: 0,
        randomAnimation: '',
        running: false,
        paused: false,
        stopped: false
      };
      slider.data('rambling:vars', vars);
      stop = function() {
        vars.stopped = true;
        return slider;
      };
      start = function() {
        vars.stopped = false;
        return slider;
      };
      option = function() {
        var optionIsObject, options, value;
        options = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        if (!options.length) {
          return settings;
        }
        option = options[0];
        value = options[1];
        optionIsObject = typeof option === 'object';
        if (option === 'effect') {
          if (value) {
            return effect(value);
          } else {
            return effect();
          }
        }
        if (optionIsObject) {
          return $.extend(settings, option);
        } else {
          if (value != null) {
            if (__indexOf.call(cannotChange, option) >= 0) {
              return $.error("Slider already running. Option '" + option + "' cannot be changed.");
            }
            return settings[option] = value;
          } else {
            return settings[option];
          }
        }
      };
      effect = function() {
        var effects;
        effects = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        if (!effects.length) {
          return settings.effect;
        }
        settings.effect = effects[0];
        animationsToRun = ['sliceDownRight', 'sliceDownLeft', 'sliceUpRight', 'sliceUpLeft', 'sliceUpDown', 'sliceUpDownLeft', 'fold', 'foldLeft', 'fade', 'slideInRight', 'slideInLeft', 'boxRandom', 'boxRain', 'boxRainReverse', 'boxRainGrow', 'boxRainGrowReverse'];
        if (settings.effect.contains(',')) {
          animationsToRun = settings.effect.split(',');
        }
        return settings.effect;
      };
      initialize = function() {
        effect(settings.effect);
        setSliderInitialState();
        vars.currentSlide = settings.startSlide = settings.startSlide % vars.totalSlides;
        setSliderBackground(slider, vars);
        addCaption();
        addDirectionNavigation();
        addControlNavigation(kids);
        addKeyboardNavigation();
        if (settings.pauseOnHover) {
          slider.hover(pauseSlider, unpauseSlider);
        }
        return setAnimationFinishedActions();
      };
      run = function() {
        if (!settings.manualAdvance && kids.length > 1) {
          return timer = window.setInterval((function() {
            return ramblingRun(slider, kids, settings, false);
          }), settings.pauseTime);
        }
      };
      setSliderInitialState = function() {
        slider.css({
          position: 'relative'
        });
        slider.addClass('ramblingSlider');
        vars.totalSlides = kids.length;
        if (settings.adaptImages) {
          prepareAdaptiveSlider();
        }
        return prepareSliderChildren();
      };
      prepareAdaptiveSlider = function() {
        var ramblingAnimationContainer;
        ramblingAnimationContainer = $('<div id="rambling-animation"></div>');
        ramblingAnimationContainer.css({
          width: slider.width(),
          height: slider.height(),
          overflow: 'hidden'
        });
        slider.prepend(ramblingAnimationContainer);
        return slider.addClass('adaptingSlider');
      };
      prepareSliderChildren = function() {
        var kid;
        kids.each(function() {
          var child, childHeight, childWidth, link;
          child = $(this);
          link = null;
          if (!child.is('img')) {
            if (child.is('a')) {
              link = child.addClass('rambling-imageLink');
            }
            child = child.find('img:first');
          }
          childWidth = child.width() || child.attr('width');
          childHeight = child.height() || child.attr('height');
          if (childWidth > slider.width() && settings.useLargerImage) {
            slider.width(childWidth);
          }
          if (childHeight > slider.height() && (settings.useLargerImage || !settings.adaptImages)) {
            slider.height(childHeight);
          }
          if (link) {
            link.css({
              display: 'none'
            });
          }
          return child.css({
            display: 'none'
          });
        });
        kid = setCurrentSlideImage(kids);
        if (kid.is('a')) {
          return kid.css({
            display: 'block'
          });
        }
      };
      addCaption = function() {
        var caption;
        caption = $('<div class="rambling-caption"><p></p></div>').css({
          display: 'none',
          opacity: settings.captionOpacity
        });
        slider.append(caption);
        return processCaption(settings);
      };
      addDirectionNavigation = function() {
        var directionNav;
        if (settings.directionNav && vars.totalSlides > 1) {
          directionNav = $("<div class='rambling-directionNav'><a class='rambling-prevNav'>" + settings.prevText + "</a><a class='rambling-nextNav'>" + settings.nextText + "</a></div>");
          slider.append(directionNav);
          if (settings.directionNavHide) {
            directionNav.hide();
            slider.hover((function() {
              return directionNav.show();
            }), (function() {
              return directionNav.hide();
            }));
          }
          slider.find('a.rambling-prevNav').live('click', function() {
            return slideTo('prev');
          });
          return slider.find('a.rambling-nextNav').live('click', function() {
            return slideTo('next');
          });
        }
      };
      addControlNavigation = function() {
        var controlNavAnchors, i, ramblingControl, _fn, _ref;
        if (settings.controlNav) {
          ramblingControl = $('<div class="rambling-controlNav"></div>');
          slider.append(ramblingControl);
          _fn = function(i) {
            var child;
            if (settings.controlNavThumbs) {
              child = kids.eq(i);
              if (!child.is('img')) {
                child = child.find('img:first');
              }
              if (settings.controlNavThumbsFromRel) {
                return ramblingControl.append("<a class='rambling-control' rel='" + i + "'><img src='" + (child.attr('rel')) + "' alt='' /></a>");
              } else {
                return ramblingControl.append("<a class='rambling-control' rel='" + i + "'><img src='" + (child.attr('src').replace(settings.controlNavThumbsSearch, settings.controlNavThumbsReplace)) + "' alt='' /></a>");
              }
            } else {
              return ramblingControl.append("<a class='rambling-control' rel='" + i + "'>" + (i + 1) + "'</a>");
            }
          };
          for (i = 0, _ref = kids.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
            _fn(i);
          }
          controlNavAnchors = slider.find('.rambling-controlNav a');
          controlNavAnchors.filter(":eq(" + vars.currentSlide + ")").addClass('active');
          return controlNavAnchors.live('click', function() {
            if (vars.running) {
              return false;
            }
            if ($(this).hasClass('active')) {
              return false;
            }
            resetTimer();
            setSliderBackground(slider, vars);
            vars.currentSlide = $(this).attr('rel') - 1;
            return ramblingRun(slider, kids, settings, 'control');
          });
        }
      };
      addKeyboardNavigation = function() {
        if (settings.keyboardNav) {
          return $(window).keypress(function(event) {
            if (event.keyCode === 37) {
              slideTo('prev');
            }
            if (event.keyCode === 39) {
              return slideTo('next');
            }
          });
        }
      };
      setAnimationFinishedActions = function() {
        return slider.bind('rambling:finished', function() {
          var kid;
          vars.running = false;
          kids.filter('a').css({
            display: 'none'
          });
          kid = $(kids[vars.currentSlide]);
          if (kid.is('a')) {
            kid.css({
              display: 'block'
            });
          }
          if (timer === '' && !vars.paused) {
            run();
          }
          setSliderBackground(slider, vars);
          return settings.afterChange.call(this);
        });
      };
      getRandomAnimation = function() {
        return animationsToRun[Math.floor(Math.random() * animationsToRun.length)] || 'fade';
      };
      processCaption = function(settings) {
        var ramblingCaption, title;
        ramblingCaption = slider.find('.rambling-caption');
        title = vars.currentImage.attr('title');
        if (title) {
          if (title.substr(0, 1) === '#') {
            title = $(title).html();
          }
          if (ramblingCaption.css('display') === 'block') {
            ramblingCaption.find('p').fadeOut(settings.speed, function() {
              $(this).html(title);
              return $(this).fadeIn(settings.speed);
            });
          } else {
            ramblingCaption.find('p').html(title);
          }
          return ramblingCaption.fadeIn(settings.speed);
        } else {
          return ramblingCaption.fadeOut(settings.speed);
        }
      };
      setCurrentSlideImage = function(kids) {
        var kid;
        kid = $(kids[vars.currentSlide]);
        vars.currentImage = kid;
        if (!kid.is('img')) {
          vars.currentImage = kid.find('img:first');
        }
        return kid;
      };
      resetTimer = function() {
        clearInterval(timer);
        return timer = '';
      };
      pauseSlider = function() {
        vars.paused = true;
        return resetTimer();
      };
      unpauseSlider = function() {
        vars.paused = false;
        if (timer === '') {
          return run();
        }
      };
      slideTo = function(direction) {
        if (vars.running || vars.totalSlides === 1) {
          return false;
        }
        resetTimer();
        if (direction === 'prev') {
          vars.currentSlide -= 2;
        }
        return ramblingRun(slider, kids, settings, direction);
      };
      createSlices = function(slider, settings, vars) {
        var i, _fn, _ref;
        _fn = function(i) {
          var animationContainer, sliceWidth;
          sliceWidth = Math.round(slider.width() / settings.slices);
          animationContainer = slider;
          if (settings.adaptImages) {
            animationContainer = slider.find('#rambling-animation');
          }
          return animationContainer.append(getRamblingSlice(sliceWidth, i, settings.slices, vars));
        };
        for (i = 0, _ref = settings.slices; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
          _fn(i);
        }
        return slider.find('.rambling-slice');
      };
      createBoxes = function(slider, settings, vars) {
        var boxHeight, boxWidth, rows, _fn, _ref;
        boxWidth = Math.round(slider.width() / settings.boxCols);
        boxHeight = Math.round(slider.height() / settings.boxRows);
        _fn = function(rows) {
          var cols, _ref2, _results;
          _results = [];
          for (cols = 0, _ref2 = settings.boxCols; 0 <= _ref2 ? cols < _ref2 : cols > _ref2; 0 <= _ref2 ? cols++ : cols--) {
            _results.push((function(cols) {
              var animationContainer;
              animationContainer = slider;
              if (settings.adaptImages) {
                animationContainer = slider.find('#rambling-animation');
              }
              return animationContainer.append(getRamblingBox(boxWidth, boxHeight, rows, cols, settings, vars));
            })(cols));
          }
          return _results;
        };
        for (rows = 0, _ref = settings.boxRows; 0 <= _ref ? rows < _ref : rows > _ref; 0 <= _ref ? rows++ : rows--) {
          _fn(rows);
        }
        return slider.find('.rambling-box');
      };
      setSliderBackground = function(slider, vars) {
        return slider.css({
          background: "url(" + (vars.currentImage.attr('src')) + ") no-repeat"
        });
      };
      getRamblingSlice = function(sliceWidth, position, total, vars) {
        var background, sliceCss, width;
        background = "url(" + (vars.currentImage.attr('src')) + ") no-repeat -" + ((sliceWidth + (position * sliceWidth)) - sliceWidth) + "px 0%";
        width = sliceWidth;
        if (position === (total - 1)) {
          background = "url(" + (vars.currentImage.attr('src')) + ") no-repeat -" + ((sliceWidth + (position * sliceWidth)) - sliceWidth) + "px 0%";
          width = slider.width() - (sliceWidth * position);
        }
        sliceCss = {
          left: "" + (sliceWidth * position) + "px",
          width: "" + width + "px",
          height: '0px',
          opacity: '0',
          background: background,
          overflow: 'hidden'
        };
        return $('<div class="rambling-slice"></div>').css(sliceCss);
      };
      getRamblingBox = function(boxWidth, boxHeight, row, column, settings, vars) {
        var background, boxCss, width;
        background = "url(" + (vars.currentImage.attr('src')) + ") no-repeat -" + ((boxWidth + (column * boxWidth)) - boxWidth) + "px -" + ((boxHeight + (row * boxHeight)) - boxHeight) + "px";
        width = boxWidth;
        if (column === (settings.boxCols - 1)) {
          background = "url(" + (vars.currentImage.attr('src')) + ") no-repeat -" + ((boxWidth + (column * boxWidth)) - boxWidth) + "px -" + ((boxHeight + (row * boxHeight)) - boxHeight) + "px";
          width = slider.width() - (boxWidth * column);
        }
        boxCss = {
          opacity: 0,
          left: "" + (boxWidth * column) + "px",
          top: "" + (boxHeight * row) + "px",
          width: "" + width + "px",
          height: "" + boxHeight + "px",
          background: background,
          overflow: 'hidden'
        };
        return $('<div class="rambling-box"></div>').css(boxCss);
      };
      if (settings.adaptImages) {
        getSlice = getRamblingSlice;
        getBox = getRamblingBox;
        setSliderBackground = function() {
          var alignment, currentImage, image;
          image = vars.currentImage;
          currentImage = slider.find('.currentImage');
          if (!currentImage.length) {
            alignment = 'alignTop';
            if (settings.alignBottom) {
              alignment = 'alignBottom';
            }
            currentImage = $('<img src="" alt="currentImage" class="currentImage"/>');
            currentImage.addClass(alignment);
            currentImage.css({
              display: 'block'
            });
            slider.find('#rambling-animation').prepend(currentImage);
          }
          return currentImage.attr({
            src: image.attr('src'),
            alt: image.attr('alt')
          });
        };
        getRamblingSlice = function(sliceWidth, position, total, vars) {
          var bottom, ramblingSlice, ramblingSliceImageStyle, top;
          ramblingSlice = getSlice(sliceWidth, position, total, vars);
          ramblingSlice.css({
            background: 'none'
          });
          ramblingSlice.append("<span><img src=\"" + (vars.currentImage.attr('src')) + "\" alt=\"\"/></span>");
          bottom = 0;
          top = 'auto';
          if (settings.alignBottom) {
            bottom = 'auto';
            top = 0;
          }
          ramblingSliceImageStyle = {
            display: 'block',
            width: slider.width(),
            left: "-" + ((sliceWidth + (position * sliceWidth)) - sliceWidth) + "px",
            bottom: bottom,
            top: top
          };
          ramblingSlice.find('img').css(ramblingSliceImageStyle);
          return ramblingSlice;
        };
        getRamblingBox = function(boxWidth, boxHeight, row, column, settings, vars) {
          var bottom, ramblingBox, ramblingBoxImageStyle, top;
          ramblingBox = getBox(boxWidth, boxHeight, row, column, settings, vars);
          bottom = false;
          top = "" + ((boxHeight + (row * boxHeight)) - boxHeight) + "px";
          if (settings.alignBottom) {
            bottom = "" + (boxHeight * (settings.boxRows - (row + 1))) + "px";
            top = false;
          }
          ramblingBoxImageStyle = {
            display: 'block',
            width: slider.width(),
            left: "-" + ((boxWidth + (column * boxWidth)) - boxWidth) + "px",
            top: 'auto',
            bottom: 'auto'
          };
          if (top) {
            ramblingBoxImageStyle.top = "-" + top;
          }
          if (bottom) {
            ramblingBoxImageStyle.bottom = "-" + bottom;
          }
          ramblingBox.css({
            background: 'none',
            top: top || 'auto',
            bottom: bottom || 'auto'
          });
          ramblingBox.append("<span><img src='" + (vars.currentImage.attr('src')) + "' alt=''/></span>");
          ramblingBox.find('img').css(ramblingBoxImageStyle);
          return ramblingBox;
        };
      }
      animateFullImage = function(options) {
        var slice, slices;
        slices = createSlices(slider, settings, vars);
        slice = slices.filter(':first');
        slice.css(options.style);
        return slice.animate(options.animate || {
          width: "" + (slider.width()) + "px"
        }, settings.speed * 2, '', function() {
          if (options.afterChange) {
            options.afterChange.apply(slice);
          }
          return slider.trigger('rambling:finished');
        });
      };
      animateSlices = function(animationCallback, reorderCallback) {
        var slices;
        slices = createSlices(slider, settings, vars);
        animationTimeBuffer = 0;
        if (reorderCallback) {
          slices = reorderCallback.apply(slices);
        }
        return slices.each(animationCallback);
      };
      animateBoxes = function(animationCallback, reorderCallback) {
        var boxes;
        boxes = createBoxes(slider, settings, vars);
        animationTimeBuffer = 0;
        if (reorderCallback) {
          boxes = reorderCallback.apply(boxes);
        }
        return animationCallback.apply(boxes);
      };
      slideDownSlices = function(reorderCallback) {
        return animateSlices(function(index) {
          var slice;
          slice = $(this);
          slice.css({
            top: '0px'
          });
          if (index === settings.slices - 1) {
            window.setTimeout(function() {
              return slice.animate({
                height: "" + (slider.height()) + "px",
                opacity: '1.0'
              }, settings.speed, '', function() {
                return slider.trigger('rambling:finished');
              });
            }, 100 + animationTimeBuffer);
          } else {
            window.setTimeout((function() {
              return slice.animate({
                height: "" + (slider.height()) + "px",
                opacity: '1.0'
              }, settings.speed);
            }), 100 + animationTimeBuffer);
          }
          return animationTimeBuffer += 50;
        }, reorderCallback);
      };
      slideUpSlices = function(reorderCallback) {
        return animateSlices(function(index) {
          var slice;
          slice = $(this);
          slice.css({
            bottom: '0px'
          });
          if (index === settings.slices - 1) {
            window.setTimeout((function() {
              return slice.animate({
                height: "" + (slider.height()) + "px",
                opacity: '1.0'
              }, settings.speed, '', function() {
                return slider.trigger('rambling:finished');
              });
            }), 100 + animationTimeBuffer);
          } else {
            window.setTimeout((function() {
              return slice.animate({
                height: "" + (slider.height()) + "px",
                opacity: '1.0'
              }, settings.speed);
            }), 100 + animationTimeBuffer);
          }
          return animationTimeBuffer += 50;
        }, reorderCallback);
      };
      slideUpDownSlices = function(reorderCallback) {
        return animateSlices(function(index) {
          var slice;
          slice = $(this);
          slice.css((index % 2 ? {
            bottom: '0px'
          } : {
            top: '0px'
          }));
          if (index === settings.slices - 1) {
            window.setTimeout((function() {
              return slice.animate({
                height: "" + (slider.height()) + "px",
                opacity: '1.0'
              }, settings.speed, '', function() {
                return slider.trigger('rambling:finished');
              });
            }), 100 + animationTimeBuffer);
          } else {
            window.setTimeout((function() {
              return slice.animate({
                height: "" + (slider.height()) + "px",
                opacity: '1.0'
              }, settings.speed);
            }), 100 + animationTimeBuffer);
          }
          return animationTimeBuffer += 50;
        }, reorderCallback);
      };
      foldSlices = function(reorderCallback) {
        return animateSlices(function(index) {
          var origWidth, slice;
          slice = $(this);
          origWidth = slice.width();
          slice.css({
            top: '0px',
            height: '100%',
            width: '0px'
          });
          if (index === settings.slices - 1) {
            window.setTimeout((function() {
              return slice.animate({
                width: origWidth,
                opacity: '1.0'
              }, settings.speed, '', function() {
                return slider.trigger('rambling:finished');
              });
            }), 100 + animationTimeBuffer);
          } else {
            window.setTimeout((function() {
              return slice.animate({
                width: origWidth,
                opacity: '1.0'
              }, settings.speed);
            }), 100 + animationTimeBuffer);
          }
          return animationTimeBuffer += 50;
        }, reorderCallback);
      };
      randomBoxes = function() {
        return animateBoxes(function() {
          var totalBoxes;
          totalBoxes = this.length;
          return this.each(function(index) {
            var box;
            box = $(this);
            if (index === totalBoxes - 1) {
              window.setTimeout((function() {
                return box.animate({
                  opacity: '1'
                }, settings.speed, '', function() {
                  return slider.trigger('rambling:finished');
                });
              }), 100 + animationTimeBuffer);
            } else {
              window.setTimeout((function() {
                return box.animate({
                  opacity: '1'
                }, settings.speed);
              }), 100 + animationTimeBuffer);
            }
            return animationTimeBuffer += 20;
          });
        }, $.fn.shuffle);
      };
      rainBoxes = function(reorderCallback, grow) {
        return animateBoxes(function() {
          var boxes, cols, index, totalBoxes, _ref, _results;
          boxes = this;
          totalBoxes = settings.boxCols * settings.boxRows;
          index = 0;
          _results = [];
          for (cols = 0, _ref = settings.boxCols * 2; 0 <= _ref ? cols < _ref : cols > _ref; 0 <= _ref ? cols++ : cols--) {
            _results.push((function(cols) {
              var prevCol, rows, _ref2, _results2;
              prevCol = cols;
              _results2 = [];
              for (rows = 0, _ref2 = settings.boxRows; 0 <= _ref2 ? rows < _ref2 : rows > _ref2; 0 <= _ref2 ? rows++ : rows--) {
                _results2.push((function(rows) {
                  var box, col, h, row, time, w;
                  if (prevCol >= 0 && prevCol < settings.boxCols) {
                    row = rows;
                    col = prevCol;
                    time = animationTimeBuffer;
                    box = $(boxes[row][col]);
                    w = box.width();
                    h = box.height();
                    if (grow) {
                      box.css({
                        width: 0,
                        height: 0
                      });
                    }
                    if (index === totalBoxes - 1) {
                      window.setTimeout((function() {
                        return box.animate({
                          opacity: '1',
                          width: w,
                          height: h
                        }, settings.speed / 1.3, '', function() {
                          return slider.trigger('rambling:finished');
                        });
                      }), 100 + animationTimeBuffer);
                    } else {
                      window.setTimeout((function() {
                        return box.animate({
                          opacity: '1',
                          width: w,
                          height: h
                        }, settings.speed / 1.3);
                      }), 100 + animationTimeBuffer);
                    }
                    index++;
                    animationTimeBuffer += 20;
                  }
                  return prevCol--;
                })(rows));
              }
              return _results2;
            })(cols));
          }
          return _results;
        }, reorderCallback);
      };
      animationOptions = {
        fade: {
          style: {
            height: '100%',
            width: "" + (slider.width()) + "px",
            position: 'absolute',
            top: 0,
            left: 0
          },
          animate: {
            opacity: '1'
          }
        },
        slideInRight: {
          style: {
            height: '100%',
            width: '0px',
            opacity: '1'
          }
        },
        slideInLeft: {
          style: {
            height: '100%',
            width: '0px',
            opacity: '1',
            left: '',
            right: '0px'
          },
          afterChange: function() {
            return this.css({
              left: '0px',
              right: ''
            });
          }
        }
      };
      animations = {
        sliceDown: slideDownSlices,
        sliceDownRight: slideDownSlices,
        sliceDownLeft: function() {
          return slideDownSlices($.fn.reverse);
        },
        sliceUp: slideUpSlices,
        sliceUpRight: slideUpSlices,
        sliceUpLeft: function() {
          return slideUpSlices($.fn.reverse);
        },
        sliceUpDown: slideUpDownSlices,
        sliceUpDownRight: slideUpDownSlices,
        sliceUpDownLeft: function() {
          return slideUpDownSlices($.fn.reverse);
        },
        fold: foldSlices,
        foldLeft: function() {
          return foldSlices($.fn.reverse);
        },
        fade: function() {
          return animateFullImage(animationOptions.fade);
        },
        slideIn: function() {
          return animateFullImage(animationOptions.slideInRight);
        },
        slideInRight: function() {
          return animateFullImage(animationOptions.slideInRight);
        },
        slideInLeft: function() {
          return animateFullImage(animationOptions.slideInLeft);
        },
        boxRandom: randomBoxes,
        boxRain: function() {
          return rainBoxes(function() {
            return $(this).as2dArray(settings.boxCols);
          });
        },
        boxRainReverse: function() {
          return rainBoxes(function() {
            return $(this).reverse().as2dArray(settings.boxCols);
          });
        },
        boxRainGrow: function() {
          return rainBoxes((function() {
            return $(this).as2dArray(settings.boxCols);
          }), true);
        },
        boxRainGrowReverse: function() {
          return rainBoxes((function() {
            return $(this).reverse().as2dArray(settings.boxCols);
          }), true);
        }
      };
      ramblingRun = function(slider, kids, settings, nudge) {
        var currentEffect;
        if (vars.currentSlide === vars.totalSlides - 1) {
          settings.lastSlide.call(this);
        }
        if (vars.stopped && !nudge) {
          return false;
        }
        settings.beforeChange.call(this);
        vars.currentSlide++;
        if (vars.currentSlide === vars.totalSlides) {
          vars.currentSlide = 0;
          settings.slideshowEnd.call(this);
        }
        if (vars.currentSlide < 0) {
          vars.currentSlide = vars.totalSlides - 1;
        }
        setCurrentSlideImage(kids);
        if (settings.controlNav) {
          slider.find('.rambling-controlNav a').removeClass('active').filter(":eq(" + vars.currentSlide + ")").addClass('active');
        }
        processCaption(settings);
        slider.find('.rambling-slice,.rambling-box').remove();
        if (settings.effect === 'random' || settings.effect.contains(',')) {
          vars.randomAnimation = getRandomAnimation();
        } else {
          vars.randomAnimation = null;
        }
        vars.running = true;
        currentEffect = vars.randomAnimation || settings.effect;
        return animations[currentEffect].apply(this);
      };
      settings.afterLoad.call(this);
      this.stop = stop;
      this.start = start;
      this.effect = effect;
      this.option = option;
      this.initialize = initialize;
      this.run = run;
      return this;
    };
  })(jQuery);
  String.prototype.contains = function(string) {
    return this.indexOf(string) !== -1;
  };
  String.prototype.decapitalize = function() {
    var first, rest;
    first = this.slice(0, 1);
    rest = this.slice(1);
    return "" + (first.toLowerCase()) + rest;
  };
}).call(this);
