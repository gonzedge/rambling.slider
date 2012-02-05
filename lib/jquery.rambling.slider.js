(function() {
  /*!
   * jQuery Rambling Slider
   * http://github.com/ramblinglabs/rambling.slider
   * http://ramblinglabs.com
   *
   * Copyright 2011-2012, Rambling Labs
   * Released under the MIT license.
   * http://www.opensource.org/licenses/mit-license.php
   *
   * February 2012
   *
   * Based on jQuery Nivo Slider by Gilbert Pellegrom
  */
  var RamblingBoxGenerator, RamblingBoxer, RamblingSliceGenerator, RamblingSlicer, root;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  Array.prototype.shuffle = function() {
    var i, j, _ref, _ref2;
    for (i = _ref = this.length; _ref <= 1 ? i <= 1 : i >= 1; _ref <= 1 ? i++ : i--) {
      j = parseInt(Math.random() * i);
      _ref2 = [this[j], this[--i]], this[i] = _ref2[0], this[j] = _ref2[1];
    }
    return this;
  };
  Array.prototype.contains = function(value) {
    return __indexOf.call(this, value) >= 0;
  };
  Array.prototype.where = function(predicate) {
    var element, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      element = this[_i];
      if (predicate(element)) {
        _results.push(element);
      }
    }
    return _results;
  };
  Array.prototype.first = function(predicate) {
    var element;
    if (!predicate) {
      predicate = (function(element) {
        return true;
      });
    }
    return ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        element = this[_i];
        if (predicate(element)) {
          _results.push(element);
        }
      }
      return _results;
    }).call(this))[0];
  };
  Array.prototype.map = function(map) {
    var element, _i, _len, _results;
    if (!map) {
      map = (function(element) {
        return element;
      });
    }
    _results = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      element = this[_i];
      _results.push(map(element));
    }
    return _results;
  };
  Array.prototype.random = function() {
    return this[Math.floor(Math.random() * this.length)];
  };
  Array.prototype.fromObject = function(object, valueSelector) {
    var key, value, _fn;
    if (!valueSelector) {
      valueSelector = (function(key, value) {
        return value;
      });
    }
    _fn = __bind(function(key, value) {
      return this.push(valueSelector(key, value));
    }, this);
    for (key in object) {
      value = object[key];
      _fn(key, value);
    }
    return this;
  };
  Array.prototype.sortOutIn = function() {
    var halfLength, i, length, newArray, _fn;
    newArray = [];
    length = this.length;
    halfLength = Math.floor(length / 2);
    _fn = __bind(function(i) {
      newArray.push(this[i]);
      return newArray.push(this[length - i - 1]);
    }, this);
    for (i = 0; 0 <= halfLength ? i < halfLength : i > halfLength; 0 <= halfLength ? i++ : i--) {
      _fn(i);
    }
    if (length % 2) {
      newArray.push(this[halfLength]);
    }
    return newArray;
  };
  (function($) {
    $.fn.reverse = [].reverse;
    $.fn.shuffle = [].shuffle;
    $.fn.sortOutIn = function() {
      return $(Array.prototype.sortOutIn.apply(this));
    };
    $.fn.sortInOut = function() {
      return this.sortOutIn().reverse();
    };
    $.fn.as2dArray = function(totalColumns) {
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
    $.fn.containsFlash = function() {
      return this.find('object,embed').length;
    };
    return $.fn.equals = function(other) {
      var result;
      result = true;
      result = this.length === other.length;
      this.each(function(index, element) {
        return result = result && element === other.get(index);
      });
      return result;
    };
  })(jQuery);
  RamblingBoxGenerator = (function() {
    function RamblingBoxGenerator(slider, settings, vars) {
      this.slider = slider;
      this.settings = settings;
      this.vars = vars;
      this.boxer = new RamblingBoxer(this.slider);
    }
    RamblingBoxGenerator.prototype.createBoxes = function(boxCols, boxRows) {
      var animationContainer, boxHeight, boxWidth, row, _fn;
      if (boxCols == null) {
        boxCols = this.settings.boxCols;
      }
      if (boxRows == null) {
        boxRows = this.settings.boxRows;
      }
      boxWidth = Math.round(this.slider.width() / boxCols);
      boxHeight = Math.round(this.slider.height() / boxRows);
      animationContainer = this.slider.find('#rambling-animation');
      _fn = __bind(function(row) {
        var column, _results;
        _results = [];
        for (column = 0; 0 <= boxCols ? column < boxCols : column > boxCols; 0 <= boxCols ? column++ : column--) {
          _results.push(__bind(function(column) {
            return animationContainer.append(this.boxer.getRamblingBox(boxWidth, boxHeight, row, column, this.settings, this.vars));
          }, this)(column));
        }
        return _results;
      }, this);
      for (row = 0; 0 <= boxRows ? row < boxRows : row > boxRows; 0 <= boxRows ? row++ : row--) {
        _fn(row);
      }
      return this.slider.find('.rambling-box');
    };
    return RamblingBoxGenerator;
  })();
  root = typeof global !== "undefined" && global !== null ? global : window;
  root.RamblingBoxGenerator = RamblingBoxGenerator;
  RamblingBoxer = (function() {
    function RamblingBoxer(slider) {
      this.slider = slider;
    }
    RamblingBoxer.prototype.getBox = function(boxWidth, boxHeight, row, column, settings) {
      var boxCss;
      boxCss = {
        opacity: 0,
        left: boxWidth * column,
        top: boxHeight * row,
        width: column === (settings.boxCols - 1) ? this.slider.width() - (boxWidth * column) : boxWidth,
        height: boxHeight,
        overflow: 'hidden'
      };
      return $('<div class="rambling-box"></div>').css(boxCss);
    };
    RamblingBoxer.prototype.getRamblingBox = function(boxWidth, boxHeight, row, column, settings, vars) {
      var bottom, ramblingBox, ramblingBoxImageStyle, top;
      ramblingBox = this.getBox(boxWidth, boxHeight, row, column, settings);
      bottom = settings.alignBottom ? boxHeight * (settings.boxRows - (row + 1)) : 'auto';
      top = settings.alignBottom ? 'auto' : row * boxHeight;
      ramblingBoxImageStyle = {
        display: 'block',
        width: this.slider.width(),
        left: -(column * boxWidth),
        top: settings.alignBottom ? 'auto' : -top,
        bottom: settings.alignBottom ? -bottom : 'auto'
      };
      ramblingBox.css({
        top: top,
        bottom: bottom
      });
      ramblingBox.append("<span><img src='" + (vars.currentSlideElement.attr('src') || vars.currentSlideElement.find('img').attr('src')) + "' alt=''/></span>");
      ramblingBox.find('img').css(ramblingBoxImageStyle);
      return ramblingBox;
    };
    return RamblingBoxer;
  })();
  root = typeof global !== "undefined" && global !== null ? global : window;
  root.RamblingBoxer = RamblingBoxer;
  RamblingSliceGenerator = (function() {
    function RamblingSliceGenerator(slider, settings, vars) {
      this.slider = slider;
      this.settings = settings;
      this.vars = vars;
      this.slicer = new RamblingSlicer(this.slider);
    }
    RamblingSliceGenerator.prototype.getOneSlice = function(slideElement) {
      if (slideElement == null) {
        slideElement = this.vars.currentSlideElement;
      }
      return this.createSlices(1, slideElement);
    };
    RamblingSliceGenerator.prototype.createSlices = function(slices, slideElement) {
      var animationContainer, i, sliceWidth, _fn;
      if (slices == null) {
        slices = this.settings.slices;
      }
      if (slideElement == null) {
        slideElement = this.vars.currentSlideElement;
      }
      sliceWidth = Math.round(this.slider.width() / slices);
      animationContainer = this.slider.find('#rambling-animation');
      _fn = __bind(function(i) {
        return animationContainer.append(this.slicer.getRamblingSlice(sliceWidth, i, slices, slideElement, this.settings));
      }, this);
      for (i = 0; 0 <= slices ? i < slices : i > slices; 0 <= slices ? i++ : i--) {
        _fn(i);
      }
      return this.slider.find('.rambling-slice');
    };
    return RamblingSliceGenerator;
  })();
  root = typeof global !== "undefined" && global !== null ? global : window;
  root.RamblingSliceGenerator = RamblingSliceGenerator;
  RamblingSlicer = (function() {
    function RamblingSlicer(slider) {
      this.slider = slider;
    }
    RamblingSlicer.prototype.getSlice = function(sliceWidth, position, total) {
      var sliceCss;
      sliceCss = {
        left: sliceWidth * position,
        width: position === (total - 1) ? this.slider.width() - (sliceWidth * position) : sliceWidth,
        height: 0,
        opacity: 0,
        overflow: 'hidden'
      };
      return $('<div class="rambling-slice"></div>').css(sliceCss);
    };
    RamblingSlicer.prototype.getRamblingSlice = function(sliceWidth, position, total, slideElement, settings) {
      var ramblingSlice, ramblingSliceImageStyle;
      ramblingSlice = this.getSlice(sliceWidth, position, total);
      ramblingSlice.append("<span><img src=\"" + (slideElement.attr('src') || slideElement.find('img').attr('src')) + "\" alt=\"\"/></span>");
      ramblingSliceImageStyle = {
        display: 'block',
        width: this.slider.width(),
        left: -position * sliceWidth,
        bottom: settings.alignBottom ? 0 : 'auto',
        top: settings.alignBottom ? 'auto' : 0
      };
      ramblingSlice.find('img').css(ramblingSliceImageStyle);
      return ramblingSlice;
    };
    return RamblingSlicer;
  })();
  root = typeof global !== "undefined" && global !== null ? global : window;
  root.RamblingSlicer = RamblingSlicer;
  (function($) {
    var RamblingSlider, cannotChange, publicMethods;
    publicMethods = ['stop', 'start', 'option', 'effect', 'destroy', 'previousSlide', 'nextSlide', 'slide', 'theme'];
    $.fn.ramblingSlider = function() {
      var isCallingGetter, methodExists, options, optionsIsString, others, ramblingSlider, value;
      options = arguments[0], others = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      methodExists = __indexOf.call(publicMethods, options) >= 0;
      optionsIsString = typeof options === 'string';
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
            return $.error("Slider already initialized.");
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
      pauseTime: 4500,
      manualAdvance: false,
      captionOpacity: 0.8,
      theme: 'default',
      alignBottom: false,
      effect: 'random',
      startSlide: 0,
      directionNav: true,
      directionNavHide: true,
      controlNav: true,
      controlNavThumbs: false,
      controlNavThumbsFromRel: false,
      controlNavThumbsSearch: '.jpg',
      controlNavThumbsReplace: '_thumb.jpg',
      adaptImages: false,
      useLargerImage: true,
      keyboardNav: true,
      pauseOnHover: true,
      prevText: 'Prev',
      nextText: 'Next',
      imageTransitions: null,
      flashTransitions: null,
      imageFlashTransitions: null,
      transitionGroups: [],
      transitionGroupSuffixes: [],
      beforeChange: function() {},
      afterChange: function() {},
      slideshowEnd: function() {},
      lastSlide: function() {},
      afterLoad: function() {}
    };
    cannotChange = ['startSlide', 'directionNav', 'directionNavHide', 'controlNav', 'controlNavThumbs', 'controlNavThumbsFromRel', 'controlNavThumbsSearch', 'controlNavThumbsReplace', 'adaptImages', 'useLargerImage', 'keyboardNav', 'pauseOnHover', 'prevText', 'nextText', 'imageTransitions', 'flashTransitions', 'imageFlashTransitions', 'transitionGroups', 'transitionGroupSuffixes', 'afterLoad'];
    return RamblingSlider = function(element, options) {
      var addCaption, addControlNavigation, addDirectionNavigation, addKeyboardNavigation, animateBoxes, animateBoxesIn2d, animateFullImage, animateSlices, animationTimeBuffer, children, fadeBoxes, fadeSlices, flashTransitions, foldSlices, getAnimationHelpers, getAnimationsForCurrentSlideElement, getAvailableTransitions, getRandomAnimation, getSettingsArrayFor, growBoxes, imageFlashTransitions, imageTransitions, pauseSlider, prepareAdaptiveSlider, prepareAnimationContainer, prepareSliderChildren, processCaption, rainBoxes, raiseAnimationFinished, ramblingBoxGenerator, ramblingRun, ramblingSliceGenerator, resetTimer, setAnimationFinishedActions, setCurrentSlideElement, setSliderBackground, setSliderInitialState, setUpTransitions, settings, slideDownSlices, slideTo, slideUpDownSlices, slideUpSlices, slider, timer, transitionGroupSuffixes, transitionGroups, unpauseSlider, vars;
      slider = $(element);
      children = slider.children(':not(#rambling-animation)');
      settings = $.extend({}, $.fn.ramblingSlider.defaults, options);
      timer = 0;
      animationTimeBuffer = 0;
      imageTransitions = null;
      imageFlashTransitions = null;
      flashTransitions = null;
      transitionGroups = [];
      transitionGroupSuffixes = [];
      vars = {
        currentSlide: 0,
        currentSlideElement: '',
        previousSlideElement: '',
        totalSlides: 0,
        running: false,
        paused: false,
        stopped: false
      };
      slider.data('rambling:vars', vars);
      ramblingSliceGenerator = new RamblingSliceGenerator(slider, settings, vars);
      ramblingBoxGenerator = new RamblingBoxGenerator(slider, settings, vars);
      this.stop = function() {
        vars.stopped = true;
        return slider;
      };
      this.start = function() {
        vars.stopped = false;
        return slider;
      };
      this.previousSlide = function() {
        slideTo('prev');
        return slider;
      };
      this.nextSlide = function() {
        slideTo('next');
        return slider;
      };
      this.slide = function() {
        var slideNumber, slideNumbers;
        slideNumbers = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        if (!slideNumbers.length) {
          return vars.currentSlide;
        }
        slideNumber = slideNumbers[0] % vars.totalSlides;
        if (!(vars.running || vars.totalSlides === 1)) {
          vars.currentSlide = slideNumber - 1;
          ramblingRun(slider, children, settings, 'control');
        }
        return slider;
      };
      this.destroy = function() {
        slider.find('#rambling-animation,.rambling-slice,.rambling-box,.rambling-caption,.rambling-directionNav,.rambling-controlNav').remove();
        slider.removeClass('ramblingSlider adaptingSlider');
        slider.removeAttr('style');
        slider.data('rambling:vars', null);
        slider.data('rambling:slider', null);
        slider.unbind('rambling:finished');
        slider.unbind('hover');
        resetTimer();
        slider.children().show().children().show();
        return slider;
      };
      this.option = __bind(function() {
        var option, optionIsObject, options, value;
        options = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        if (!options.length) {
          return settings;
        }
        option = options[0], value = options[1];
        optionIsObject = typeof option === 'object';
        if (option === 'effect') {
          return this.effect.apply(this, value ? [value] : void 0);
        }
        if (option === 'theme') {
          return this.theme.apply(this, value ? [value] : void 0);
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
      }, this);
      this.effect = function() {
        var effects;
        effects = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        if (!effects.length) {
          return settings.effect;
        }
        settings.effect = effects[0];
        return slider;
      };
      this.theme = function() {
        var classes, oldTheme, themes;
        themes = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        if (!themes.length) {
          return settings.theme;
        }
        oldTheme = settings.theme;
        settings.theme = themes[0];
        classes = ["theme-" + oldTheme, "theme-" + $.fn.ramblingSlider.defaults.theme];
        slider.parents(classes.map(function(c) {
          return "." + c;
        }).join(',')).removeClass(classes.join(' ')).addClass("theme-" + settings.theme);
        return slider;
      };
      this.initialize = function() {
        setSliderInitialState();
        vars.currentSlide = settings.startSlide = settings.startSlide % vars.totalSlides;
        setCurrentSlideElement(children);
        setSliderBackground();
        addCaption();
        addDirectionNavigation();
        addControlNavigation(children);
        addKeyboardNavigation();
        if (settings.pauseOnHover) {
          slider.hover(pauseSlider, unpauseSlider);
        }
        return setAnimationFinishedActions();
      };
      this.run = function() {
        if (!settings.manualAdvance && vars.totalSlides > 1) {
          return timer = window.setInterval((function() {
            return ramblingRun(slider, children, settings, false);
          }), settings.pauseTime);
        }
      };
      setUpTransitions = function() {
        imageTransitions = $.extend({}, $.fn.ramblingSlider.defaults.imageTransitions, settings.imageTransitions);
        imageFlashTransitions = $.extend({}, $.fn.ramblingSlider.defaults.imageFlashTransitions, settings.imageFlashTransitions);
        flashTransitions = $.extend({}, $.fn.ramblingSlider.defaults.flashTransitions, settings.flashTransitions);
        transitionGroups = getSettingsArrayFor('transitionGroups');
        return transitionGroupSuffixes = getSettingsArrayFor('transitionGroupSuffixes');
      };
      getSettingsArrayFor = function(key) {
        var array;
        array = [];
        $.each($.fn.ramblingSlider.defaults[key], function(index, element) {
          return array.push(element);
        });
        $.each(settings[key], function(index, element) {
          return array.push(element);
        });
        return array;
      };
      setSliderInitialState = __bind(function() {
        this.effect(settings.effect);
        this.theme(settings.theme);
        setUpTransitions();
        slider.css({
          position: 'relative'
        });
        slider.addClass('ramblingSlider');
        vars.totalSlides = children.length;
        prepareSliderChildren();
        prepareAnimationContainer();
        if (settings.adaptImages) {
          return prepareAdaptiveSlider();
        }
      }, this);
      prepareAnimationContainer = function() {
        var ramblingAnimationContainer;
        ramblingAnimationContainer = $('<div id="rambling-animation"></div>').css({
          width: slider.width(),
          height: slider.height(),
          overflow: 'hidden'
        });
        slider.prepend(ramblingAnimationContainer);
        children.each(function() {
          var child, clone;
          child = $(this);
          child.css({
            display: 'none'
          });
          clone = child.clone().addClass('slideElement');
          if (clone.containsFlash()) {
            if (!clone.find('param[name=wmode]').length) {
              clone.find('object').prepend('<param name="wmode" value="opaque" />');
            }
            clone.find('embed').attr({
              wmode: 'opaque'
            });
          }
          return ramblingAnimationContainer.append(clone);
        });
        return children = ramblingAnimationContainer.children();
      };
      prepareAdaptiveSlider = function() {
        return slider.addClass('adaptingSlider');
      };
      prepareSliderChildren = function() {
        var child;
        children.each(function() {
          var child, childHeight, childWidth, link, object;
          child = $(this);
          link = null;
          if (child.is('a') && !child.containsFlash()) {
            link = child.addClass('rambling-imageLink');
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
          object = child.find('object,embed');
          object.height(slider.height());
          object.width(slider.width());
          if (link) {
            link.css({
              display: 'none'
            });
          }
          return child.css({
            display: 'none'
          });
        });
        child = setCurrentSlideElement(children);
        if (child.is('a')) {
          return child.css({
            display: 'block'
          });
        }
      };
      addCaption = function() {
        slider.append($('<div class="rambling-caption"><p></p></div>').css({
          display: 'none',
          opacity: settings.captionOpacity
        }));
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
      addControlNavigation = __bind(function() {
        var controlNavAnchors, i, ramblingControl, self, _fn, _ref;
        self = this;
        if (settings.controlNav) {
          ramblingControl = $('<div class="rambling-controlNav"></div>');
          slider.append(ramblingControl);
          _fn = function(i) {
            var child;
            if (settings.controlNavThumbs) {
              child = children.eq(i);
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
          for (i = 0, _ref = children.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
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
            setSliderBackground();
            return self.slide($(this).attr('rel'));
          });
        }
      }, this);
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
      setAnimationFinishedActions = __bind(function() {
        var self;
        self = this;
        return slider.bind('rambling:finished', function() {
          var child;
          vars.running = false;
          child = $(children.get(vars.currentSlide));
          child.siblings().css({
            display: 'none'
          });
          if (child.is('a')) {
            child.css({
              display: 'block'
            });
          }
          if (timer === '' && !vars.paused) {
            self.run();
          }
          setSliderBackground();
          slider.find('.rambling-slice,.rambling-box').remove();
          return settings.afterChange.call(this);
        });
      }, this);
      processCaption = function(settings) {
        var ramblingCaption, title;
        ramblingCaption = slider.find('.rambling-caption');
        title = vars.currentSlideElement.attr('title');
        if (title) {
          if (title.startsWith('#')) {
            title = $(title).html();
          }
          if (ramblingCaption.css('display') === 'block') {
            ramblingCaption.find('p').fadeOut(settings.speed, function() {
              var p;
              p = $(this);
              p.html(title);
              return p.fadeIn(settings.speed);
            });
          } else {
            ramblingCaption.find('p').html(title);
          }
          return ramblingCaption.fadeIn(settings.speed);
        } else {
          return ramblingCaption.fadeOut(settings.speed);
        }
      };
      setCurrentSlideElement = function(children) {
        var child;
        child = $(children.get(vars.currentSlide));
        vars.previousSlideElement = vars.currentSlideElement;
        vars.currentSlideElement = child;
        if (child.is('a') && !child.containsFlash()) {
          vars.currentSlideElement = child.find('img:first');
        }
        return child;
      };
      resetTimer = function() {
        window.clearInterval(timer);
        return timer = '';
      };
      pauseSlider = function() {
        vars.paused = true;
        return resetTimer();
      };
      unpauseSlider = __bind(function() {
        vars.paused = false;
        if (timer === '') {
          return this.run();
        }
      }, this);
      slideTo = function(direction) {
        if (vars.running || vars.totalSlides === 1) {
          return false;
        }
        resetTimer();
        if (direction === 'prev') {
          vars.currentSlide -= 2;
        }
        return ramblingRun(slider, children, settings, direction);
      };
      setSliderBackground = function() {
        var slideElement;
        slideElement = slider.find('.currentSlideElement');
        if (slideElement.equals(vars.currentSlideElement)) {
          return;
        }
        slideElement.removeClass('currentSlideElement alignTop alignBottom').css({
          display: 'none',
          'z-index': 0
        });
        slideElement = vars.currentSlideElement;
        slideElement.siblings('.slideElement').css({
          display: 'none'
        });
        slideElement.addClass('currentSlideElement').addClass(settings.alignBottom ? 'alignBottom' : 'alignTop');
        slideElement.css({
          display: 'block',
          'z-index': 0
        });
        return slideElement.find('img').css({
          display: 'block'
        });
      };
      getAvailableTransitions = function() {
        var effects;
        effects = settings.effect.split(',');
        $.each(transitionGroups, function(index, group) {
          var parameters;
          if (effects.contains(group)) {
            parameters = [effects.indexOf(group), 1];
            $.each(transitionGroupSuffixes, function(index, suffix) {
              return parameters.push("" + group + suffix);
            });
            return effects.splice.apply(effects, parameters);
          }
        });
        return effects;
      };
      getAnimationsForCurrentSlideElement = function() {
        var availableTransitions, defaultTransition, sourceTransitions, transitions;
        transitions = [];
        sourceTransitions = [];
        if (vars.currentSlideElement.containsFlash()) {
          if (vars.previousSlideElement.containsFlash()) {
            sourceTransitions = flashTransitions;
            defaultTransition = flashTransitions.slideInRight;
          } else {
            sourceTransitions = imageFlashTransitions;
            defaultTransition = imageFlashTransitions.fadeOut;
          }
        } else {
          sourceTransitions = imageTransitions;
          defaultTransition = imageTransitions.fadeIn;
        }
        availableTransitions = getAvailableTransitions();
        transitions = [].fromObject(sourceTransitions, function(key, value) {
          return key;
        });
        if (settings.effect !== 'random') {
          transitions = transitions.where(function(animationName) {
            return availableTransitions.contains(animationName);
          });
        }
        transitions = transitions.map(function(animationName) {
          return sourceTransitions[animationName];
        });
        transitions["default"] = defaultTransition;
        return transitions;
      };
      getRandomAnimation = function() {
        var transitions;
        transitions = getAnimationsForCurrentSlideElement();
        return transitions.random() || transitions["default"];
      };
      raiseAnimationFinished = function() {
        return slider.trigger('rambling:finished');
      };
      animateFullImage = function(animationSetUp) {
        var slice;
        slice = ramblingSliceGenerator.getOneSlice();
        slice.css({
          top: (settings.alignBottom ? 'auto' : 0),
          bottom: (settings.alignBottom ? 0 : 'auto')
        });
        return slice.animate(animationSetUp.apply(slice, [slider, $.extend({}, settings)]) || {
          width: slider.width()
        }, settings.speed * 2, '', function() {
          if (settings.afterChange) {
            settings.afterChange.apply(slice);
          }
          return raiseAnimationFinished();
        });
      };
      animateSlices = function(animationSetUp, sortCallback) {
        var slices;
        slices = ramblingSliceGenerator.createSlices();
        animationTimeBuffer = 0;
        if (sortCallback) {
          slices = sortCallback.apply(slices);
        }
        return slices.each(function(index, element) {
          var finishedCallback, slice;
          slice = $(element);
          if (index === settings.slices - 1) {
            finishedCallback = raiseAnimationFinished;
          }
          window.setTimeout((function() {
            return slice.animate(animationSetUp.apply(slice, [index, element]) || {}, settings.speed, '', finishedCallback);
          }), 100 + animationTimeBuffer);
          return animationTimeBuffer += 50;
        });
      };
      animateBoxes = function(animationCallback, sortCallback) {
        var boxes;
        boxes = ramblingBoxGenerator.createBoxes();
        animationTimeBuffer = 0;
        if (sortCallback) {
          boxes = sortCallback.apply(boxes);
        }
        return animationCallback.apply(boxes, [raiseAnimationFinished]);
      };
      animateBoxesIn2d = function(animationSetUp, sortCallback) {
        return animateBoxes(function(finishedCallback) {
          var boxes, column, index, totalBoxes, _ref, _results;
          boxes = this;
          totalBoxes = settings.boxCols * settings.boxRows;
          index = 0;
          _results = [];
          for (column = 0, _ref = settings.boxCols * 2; 0 <= _ref ? column < _ref : column > _ref; 0 <= _ref ? column++ : column--) {
            _results.push((function(column) {
              var row, _ref2, _results2;
              _results2 = [];
              for (row = 0, _ref2 = settings.boxRows; 0 <= _ref2 ? row < _ref2 : row > _ref2; 0 <= _ref2 ? row++ : row--) {
                _results2.push((function(row) {
                  var box, finished;
                  if (column >= 0 && column < settings.boxCols) {
                    box = $(boxes[row][column]);
                    if (index === totalBoxes - 1) {
                      finished = finishedCallback;
                    }
                    window.setTimeout((function() {
                      return box.animate(animationSetUp.apply(box), settings.speed / 1.3, '', finished);
                    }), 100 + animationTimeBuffer);
                    index++;
                    animationTimeBuffer += 20;
                  }
                  return column--;
                })(row));
              }
              return _results2;
            })(column));
          }
          return _results;
        }, function() {
          var boxes;
          boxes = this;
          if (sortCallback) {
            boxes = sortCallback.call(this);
          }
          return boxes.as2dArray(settings.boxCols);
        });
      };
      slideDownSlices = function(sortCallback) {
        return animateSlices((function(index, element) {
          this.css({
            top: 0
          });
          return {
            height: slider.height(),
            opacity: '1'
          };
        }), sortCallback);
      };
      slideUpSlices = function(sortCallback) {
        return animateSlices((function(index, element) {
          this.css({
            bottom: 0
          });
          return {
            height: slider.height(),
            opacity: '1'
          };
        }), sortCallback);
      };
      slideUpDownSlices = function(sortCallback) {
        return animateSlices((function(index, element) {
          this.css((index % 2 ? {
            bottom: 0
          } : {
            top: 0
          }));
          return {
            height: slider.height(),
            opacity: '1'
          };
        }), sortCallback);
      };
      foldSlices = function(sortCallback) {
        return animateSlices((function(index, element) {
          var animateStyle, slice;
          slice = $(element);
          animateStyle = {
            width: slice.width(),
            opacity: '1'
          };
          slice.css({
            top: 0,
            height: '100%',
            width: 0
          });
          return animateStyle;
        }), sortCallback);
      };
      fadeSlices = function(sortCallback) {
        return animateSlices((function(index, element) {
          this.css({
            height: slider.height()
          });
          return {
            opacity: '1'
          };
        }), sortCallback);
      };
      fadeBoxes = function(sortCallback) {
        return animateBoxes(function(finishedCallback) {
          var totalBoxes;
          totalBoxes = this.length;
          animationTimeBuffer = 0;
          return this.each(function(index) {
            var box, finished;
            box = $(this);
            if (index === totalBoxes - 1) {
              finished = finishedCallback;
            }
            window.setTimeout((function() {
              return box.animate({
                opacity: '1'
              }, settings.speed, '', finished);
            }), 100 + animationTimeBuffer);
            return animationTimeBuffer += 20;
          });
        }, sortCallback);
      };
      rainBoxes = function(sortCallback) {
        return animateBoxesIn2d((function() {
          return {
            opacity: '1'
          };
        }), sortCallback);
      };
      growBoxes = function(sortCallback) {
        return animateBoxesIn2d((function() {
          var height, width;
          width = this.width();
          height = this.height();
          this.css({
            width: 0,
            height: 0
          });
          return {
            opacity: '1',
            width: width,
            height: height
          };
        }), sortCallback);
      };
      getAnimationHelpers = function() {
        var animationHelpers;
        return animationHelpers = {
          setSliderBackground: setSliderBackground,
          currentSlideElement: vars.currentSlideElement,
          previousSlideElement: vars.previousSlideElement,
          raiseAnimationFinished: raiseAnimationFinished,
          settings: $.extend({}, settings),
          createSlices: function(slices, element) {
            return ramblingSliceGenerator.createSlices(slices, element);
          },
          createBoxes: function(rows, columns) {
            return ramblingBoxGenerator.createBoxes(rows, columns);
          },
          getOneSlice: function(element) {
            return ramblingSliceGenerator.getOneSlice(element);
          },
          animateFullImage: animateFullImage,
          animateSlices: animateSlices,
          animateBoxes: animateBoxes,
          animateBoxesIn2d: animateBoxesIn2d,
          slideUpSlices: slideUpSlices,
          slideDownSlices: slideDownSlices,
          slideUpDownSlices: slideUpDownSlices,
          foldSlices: foldSlices,
          fadeSlices: fadeSlices,
          fadeBoxes: fadeBoxes,
          rainBoxes: rainBoxes,
          growBoxes: growBoxes
        };
      };
      ramblingRun = function(slider, children, settings, nudge) {
        if (vars.currentSlide === vars.totalSlides - 1) {
          settings.lastSlide.call(this);
        }
        if (vars.stopped && !nudge) {
          return false;
        }
        settings.beforeChange.call(this);
        vars.currentSlide = (vars.currentSlide + 1) % vars.totalSlides;
        if (vars.currentSlide === 0) {
          settings.slideshowEnd.call(this);
        }
        if (vars.currentSlide < 0) {
          vars.currentSlide = vars.totalSlides + vars.currentSlide;
        }
        setCurrentSlideElement(children);
        if (settings.controlNav) {
          slider.find('.rambling-controlNav a').removeClass('active').filter(":eq(" + vars.currentSlide + ")").addClass('active');
        }
        processCaption(settings);
        vars.running = true;
        return getRandomAnimation().call(getAnimationHelpers());
      };
      settings.afterLoad.call(this);
      return this;
    };
  })(jQuery);
  (function($) {
    var allAroundTransitions, animationFullImageOptions, boxTransitions, flashHorizontalSlideIn, flashSlideIn, name, transitions, value, _fn;
    allAroundTransitions = [
      {
        name: 'sliceUp',
        helper: 'slideUpSlices'
      }, {
        name: 'sliceDown',
        helper: 'slideDownSlices'
      }, {
        name: 'sliceUpDown',
        helper: 'slideUpDownSlices'
      }, {
        name: 'sliceFade',
        helper: 'fadeSlices'
      }, {
        name: 'fold',
        helper: 'foldSlices'
      }
    ];
    allAroundTransitions.suffixes = [
      {
        name: 'Right',
        sorter: void 0
      }, {
        name: 'Left',
        sorter: $.fn.reverse
      }, {
        name: 'OutIn',
        sorter: $.fn.sortOutIn
      }, {
        name: 'InOut',
        sorter: $.fn.sortInOut
      }, {
        name: 'Random',
        sorter: $.fn.shuffle
      }
    ];
    boxTransitions = [
      {
        name: 'boxRain',
        helper: 'rainBoxes'
      }, {
        name: 'boxGrow',
        helper: 'growBoxes'
      }
    ];
    boxTransitions.suffixes = [
      {
        name: 'Forward',
        sorter: void 0
      }, {
        name: 'Reverse',
        sorter: $.fn.reverse
      }, {
        name: 'OutIn',
        sorter: $.fn.sortOutIn
      }, {
        name: 'InOut',
        sorter: $.fn.sortInOut
      }, {
        name: 'Random',
        sorter: $.fn.shuffle
      }
    ];
    transitions = [allAroundTransitions, boxTransitions];
    animationFullImageOptions = {
      fadeIn: function(slider) {
        this.css({
          height: '100%',
          width: slider.width(),
          position: 'absolute',
          top: 0,
          left: 0
        });
        return {
          opacity: '1'
        };
      },
      fadeOut: function(slider) {
        this.css({
          height: '100%',
          width: slider.width(),
          position: 'absolute',
          top: 0,
          left: 0
        });
        return {
          opacity: '1'
        };
      },
      rolloverRight: function() {
        this.css({
          height: '100%',
          width: 0,
          opacity: '1'
        });
      },
      rolloverLeft: function(slider, settings) {
        this.css({
          height: '100%',
          width: 0,
          opacity: '1',
          left: 'auto',
          right: 0
        });
        this.find('img').css({
          left: -slider.width()
        }).animate({
          left: 0
        }, settings.speed * 2);
        return {
          width: slider.width()
        };
      },
      slideInRight: function(slider, settings) {
        this.css({
          height: '100%',
          width: 0,
          opacity: '1'
        });
        this.find('img').css({
          left: -slider.width()
        }).animate({
          left: 0
        }, settings.speed * 2);
        return {
          width: slider.width()
        };
      },
      slideInLeft: function(slider) {
        var finishedHandler;
        this.css({
          height: '100%',
          width: 0,
          opacity: '1',
          left: 'auto',
          right: 0
        });
        finishedHandler = __bind(function() {
          this.css({
            left: 0,
            right: 'auto'
          });
          return slider.unbind('rambling:finished', finishedHandler);
        }, this);
        slider.bind('rambling:finished', finishedHandler);
      }
    };
    flashSlideIn = function(beforeAnimation, animateStyle, afterAnimation) {
      this.currentSlideElement.css(beforeAnimation);
      return window.setTimeout((__bind(function() {
        return this.currentSlideElement.animate(animateStyle, this.settings.speed * 2, this.raiseAnimationFinished);
      }, this)), this.settings.speed * 2);
    };
    flashHorizontalSlideIn = function(initialLeft) {
      var afterAnimation, beforeAnimation;
      beforeAnimation = {
        top: (this.settings.alignBottom ? 'auto' : 0),
        bottom: (this.settings.alignBottom ? 0 : 'auto'),
        left: initialLeft,
        position: 'absolute',
        display: 'block'
      };
      afterAnimation = {
        top: 'auto',
        left: 'auto',
        position: 'relative'
      };
      return flashSlideIn.apply(this, [
        beforeAnimation, {
          left: 0
        }, afterAnimation
      ]);
    };
    $.fn.ramblingSlider.defaults.imageTransitions = {};
    $.each(transitions, function(index, group) {
      return $.each(group, function(index, transition) {
        return $.each(group.suffixes, function(index, suffix) {
          return $.fn.ramblingSlider.defaults.imageTransitions["" + transition.name + suffix.name] = function() {
            return this[transition.helper](suffix.sorter);
          };
        });
      });
    });
    _fn = function(name, value) {
      return $.fn.ramblingSlider.defaults.imageTransitions[name] = function() {
        return this.animateFullImage(value);
      };
    };
    for (name in animationFullImageOptions) {
      value = animationFullImageOptions[name];
      _fn(name, value);
    }
    $.fn.ramblingSlider.defaults.imageFlashTransitions = {
      fadeOut: function() {
        var self, slice;
        slice = this.getOneSlice(this.previousSlideElement);
        slice.css({
          height: '100%',
          width: slice.parents('.ramblingSlider').width(),
          position: 'absolute',
          top: 0,
          left: 0,
          opacity: '1'
        });
        this.setSliderBackground();
        self = this;
        return slice.animate({
          opacity: '0'
        }, this.settings.speed * 2, '', function() {
          slice.css({
            display: 'none'
          });
          return self.raiseAnimationFinished();
        });
      }
    };
    $.fn.ramblingSlider.defaults.flashTransitions = {
      slideInRight: function() {
        return flashHorizontalSlideIn.apply(this, [-this.currentSlideElement.parents('.ramblingSlider').width()]);
      },
      slideInLeft: function() {
        return flashHorizontalSlideIn.apply(this, [this.currentSlideElement.parents('.ramblingSlider').width()]);
      }
    };
    $.extend($.fn.ramblingSlider.defaults.imageFlashTransitions, $.fn.ramblingSlider.defaults.flashTransitions);
    $.fn.ramblingSlider.defaults.transitionGroups = ['fade', 'rollover', 'slideIn'];
    $.each(transitions, function(index, group) {
      return $.each(group, function(index, element) {
        return $.fn.ramblingSlider.defaults.transitionGroups.push(element.name);
      });
    });
    return $.fn.ramblingSlider.defaults.transitionGroupSuffixes = ['Right', 'Left', 'OutIn', 'InOut', 'Random', 'Forward', 'Reverse', 'In', 'Out'];
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
  String.prototype.startsWith = function(string) {
    return this.substring(0, string.length) === string;
  };
  String.prototype.endsWith = function(string) {
    return this.substring(this.length - string.length, this.length) === string;
  };
}).call(this);
