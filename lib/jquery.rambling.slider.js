(function() {
  /*!
   * jQuery Rambling Slider
   * http://github.com/egonzalez0787/rambling.slider
   * http://ramblinglabs.com
   *
   * Copyright 2011, Rambling Labs
   * Released under the MIT license.
   * http://www.opensource.org/licenses/mit-license.php
   *
   * November 2011
   *
   * Based on jQuery Nivo Slider by Gilbert Pellegrom
  */
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
  Array.prototype.where = function(predicate) {
    var element, newArray, _i, _len;
    newArray = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      element = this[_i];
      if (predicate(element)) {
        (function(element) {
          return newArray.push(element);
        })(element);
      }
    }
    return newArray;
  };
  Array.prototype.first = function(predicate) {
    var element, _i, _len;
    if (!predicate) {
      predicate = (function(element) {
        return true;
      });
    }
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      element = this[_i];
      if (predicate(element)) {
        return element;
      }
    }
    return null;
  };
  Array.prototype.map = function(map) {
    var element, newArray, _fn, _i, _len;
    newArray = [];
    if (!map) {
      map = (function(element) {
        return element;
      });
    }
    _fn = function(element) {
      return newArray.push(map(element));
    };
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      element = this[_i];
      _fn(element);
    }
    return newArray;
  };
  Array.prototype.random = function() {
    return this[Math.floor(Math.random() * this.length)];
  };
  Array.prototype.fromObject = function(object, valueSelector) {
    var key, self, value, _fn;
    self = this;
    if (!valueSelector) {
      valueSelector = (function(key, value) {
        return value;
      });
    }
    _fn = function(key, value) {
      return self.push(valueSelector(key, value));
    };
    for (key in object) {
      value = object[key];
      _fn(key, value);
    }
    return self;
  };
  Array.prototype.sortOutIn = function() {
    var halfLength, i, length, newArray, self, _fn;
    newArray = [];
    self = this;
    length = self.length;
    halfLength = Math.floor(length / 2);
    _fn = function(i) {
      newArray.push(self[i]);
      return newArray.push(self[length - i - 1]);
    };
    for (i = 0; 0 <= halfLength ? i < halfLength : i > halfLength; 0 <= halfLength ? i++ : i--) {
      _fn(i);
    }
    if (length % 2) {
      newArray.push(self[halfLength]);
    }
    return newArray;
  };
  (function($) {
    $.fn.reverse = [].reverse;
    $.fn.shuffle = [].shuffle;
    $.fn.sortOutIn = function() {
      var self;
      self = Array.prototype.sortOutIn.apply(this);
      return $(self);
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
  (function($) {
    var RamblingSlider, cannotChange, publicMethods;
    publicMethods = ['stop', 'start', 'option', 'effect', 'destroy', 'previousSlide', 'nextSlide', 'slide', 'theme'];
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
      var addCaption, addControlNavigation, addDirectionNavigation, addKeyboardNavigation, animateBoxes, animateBoxesIn2d, animateFullImage, animateSlices, animationTimeBuffer, children, createBoxes, createSlices, destroy, effect, extendAvailableTransitions, fadeBoxes, fadeSlices, flashTransitions, foldSlices, getAnimationsForCurrentSlideElement, getAvailableTransitions, getBox, getOneSlice, getRamblingBox, getRamblingSlice, getRandomAnimation, getSettingsArrayFor, getSlice, growBoxes, imageFlashTransitions, imageTransitions, initialize, nextSlide, option, pauseSlider, prepareAdaptiveSlider, prepareAnimationContainer, prepareSliderChildren, previousSlide, processCaption, rainBoxes, raiseAnimationFinished, ramblingRun, resetTimer, run, setAnimationFinishedActions, setCurrentSlideElement, setSliderBackground, setSliderInitialState, setUpTransitions, settings, slide, slideDownSlices, slideTo, slideUpDownSlices, slideUpSlices, slider, start, stop, theme, timer, transitionGroupSuffixes, transitionGroups, unpauseSlider, vars;
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
      stop = function() {
        vars.stopped = true;
        return slider;
      };
      start = function() {
        vars.stopped = false;
        return slider;
      };
      previousSlide = function() {
        slideTo('prev');
        return slider;
      };
      nextSlide = function() {
        slideTo('next');
        return slider;
      };
      slide = function() {
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
      destroy = function() {
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
        if (option === 'theme') {
          if (value) {
            return theme(value);
          } else {
            return theme();
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
        return slider;
      };
      theme = function() {
        var themes;
        themes = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        if (!themes.length) {
          return settings.theme;
        }
        slider.removeClass("theme-" + settings.theme);
        settings.theme = themes[0];
        return slider.addClass("theme-" + settings.theme);
      };
      initialize = function() {
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
        setAnimationFinishedActions();
        return extendAvailableTransitions();
      };
      run = function() {
        if (!settings.manualAdvance && vars.totalSlides > 1) {
          return timer = window.setInterval((function() {
            return ramblingRun(slider, children, settings, false);
          }), settings.pauseTime);
        }
      };
      setUpTransitions = function() {
        imageTransitions = $.extend({}, $.fn.ramblingSlider.defaults.imageTransitions, settings.imageTransitions);
        imageFlashTransitions = $.extend({}, $.fn.ramblingSlider.defaults.imageTransitions, settings.imageTransitions);
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
      setSliderInitialState = function() {
        effect(settings.effect);
        theme(settings.theme);
        setUpTransitions();
        slider.css({
          position: 'relative'
        });
        slider.addClass("ramblingSlider");
        vars.totalSlides = children.length;
        prepareAnimationContainer();
        if (settings.adaptImages) {
          prepareAdaptiveSlider();
        }
        return prepareSliderChildren();
      };
      prepareAnimationContainer = function() {
        var ramblingAnimationContainer;
        ramblingAnimationContainer = $('<div id="rambling-animation"></div>');
        ramblingAnimationContainer.css({
          width: slider.width(),
          height: slider.height(),
          overflow: 'hidden'
        });
        return slider.prepend(ramblingAnimationContainer);
      };
      prepareAdaptiveSlider = function() {
        return slider.addClass('adaptingSlider');
      };
      prepareSliderChildren = function() {
        var child, ramblingAnimationContainer;
        ramblingAnimationContainer = slider.find('#rambling-animation');
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
        children = ramblingAnimationContainer.children();
        children.each(function() {
          var child, childHeight, childWidth, iFrame, link;
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
          iFrame = child.find('object,embed');
          iFrame.height(slider.height());
          iFrame.width(slider.width());
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
            return slide($(this).attr('rel'));
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
            run();
          }
          setSliderBackground();
          slider.find('.rambling-slice,.rambling-box').remove();
          return settings.afterChange.call(this);
        });
      };
      extendAvailableTransitions = function() {
        if (settings.imageTransitions) {
          $.extend(imageTransitions, settings.imageTransitions);
        }
        if (settings.imageFlashTransitions) {
          $.extend(imageFlashTransitions, settings.imageFlashTransitions);
        }
        if (settings.flashTransitions) {
          return $.extend(flashTransitions, settings.flashTransitions);
        }
      };
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
        return ramblingRun(slider, children, settings, direction);
      };
      getOneSlice = function(slideElement) {
        if (slideElement == null) {
          slideElement = vars.currentSlideElement;
        }
        return createSlices(1, slideElement);
      };
      createSlices = function(slices, slideElement) {
        var i, _fn;
        if (slices == null) {
          slices = settings.slices;
        }
        if (slideElement == null) {
          slideElement = vars.currentSlideElement;
        }
        _fn = function(i) {
          var animationContainer, sliceWidth;
          sliceWidth = Math.round(slider.width() / slices);
          animationContainer = slider.find('#rambling-animation');
          return animationContainer.append(getRamblingSlice(sliceWidth, i, slices, vars, slideElement));
        };
        for (i = 0; 0 <= slices ? i < slices : i > slices; 0 <= slices ? i++ : i--) {
          _fn(i);
        }
        return slider.find('.rambling-slice');
      };
      createBoxes = function(boxCols, boxRows) {
        var boxHeight, boxWidth, rows, _fn;
        if (boxCols == null) {
          boxCols = settings.boxCols;
        }
        if (boxRows == null) {
          boxRows = settings.boxRows;
        }
        boxWidth = Math.round(slider.width() / boxCols);
        boxHeight = Math.round(slider.height() / boxRows);
        _fn = function(rows) {
          var cols, _results;
          _results = [];
          for (cols = 0; 0 <= boxCols ? cols < boxCols : cols > boxCols; 0 <= boxCols ? cols++ : cols--) {
            _results.push((function(cols) {
              var animationContainer;
              animationContainer = slider.find('#rambling-animation');
              return animationContainer.append(getRamblingBox(boxWidth, boxHeight, rows, cols, settings, vars));
            })(cols));
          }
          return _results;
        };
        for (rows = 0; 0 <= boxRows ? rows < boxRows : rows > boxRows; 0 <= boxRows ? rows++ : rows--) {
          _fn(rows);
        }
        return slider.find('.rambling-box');
      };
      getSlice = function(sliceWidth, position, total, vars, slideElement) {
        var imageSrc, sliceCss, width;
        imageSrc = slideElement.attr('src') || slideElement.find('img').attr('src');
        width = sliceWidth;
        if (position === (total - 1)) {
          width = slider.width() - (sliceWidth * position);
        }
        sliceCss = {
          left: "" + (sliceWidth * position) + "px",
          width: width,
          height: 0,
          opacity: '0',
          overflow: 'hidden'
        };
        return $('<div class="rambling-slice"></div>').css(sliceCss);
      };
      getBox = function(boxWidth, boxHeight, row, column, settings, vars) {
        var boxCss, imageSrc, width;
        imageSrc = vars.currentSlideElement.attr('src') || vars.currentSlideElement.find('img').attr('src');
        width = boxWidth;
        if (column === (settings.boxCols - 1)) {
          width = slider.width() - (boxWidth * column);
        }
        boxCss = {
          opacity: 0,
          left: "" + (boxWidth * column) + "px",
          top: "" + (boxHeight * row) + "px",
          width: width,
          height: boxHeight,
          overflow: 'hidden'
        };
        return $('<div class="rambling-box"></div>').css(boxCss);
      };
      setSliderBackground = function() {
        var alignment, slideElement;
        slideElement = slider.find('.currentSlideElement');
        if (slideElement.equals(vars.currentSlideElement)) {
          return;
        }
        slideElement.removeClass('currentSlideElement alignTop alignBottom').css({
          display: 'none',
          'z-index': '0'
        });
        vars.currentSlideElement.siblings('.slideElement').css({
          display: 'none'
        });
        slideElement = vars.currentSlideElement.addClass('currentSlideElement');
        alignment = 'alignTop';
        if (settings.alignBottom) {
          alignment = 'alignBottom';
        }
        slideElement.addClass(alignment);
        slideElement.css({
          display: 'block',
          'z-index': '0'
        });
        return slideElement.find('img').css({
          display: 'block'
        });
      };
      getRamblingSlice = function(sliceWidth, position, total, vars, slideElement) {
        var ramblingSlice, ramblingSliceImageStyle;
        ramblingSlice = getSlice(sliceWidth, position, total, vars, slideElement);
        ramblingSlice.append("<span><img src=\"" + (slideElement.attr('src') || slideElement.find('img').attr('src')) + "\" alt=\"\"/></span>");
        ramblingSliceImageStyle = {
          display: 'block',
          width: slider.width(),
          left: "-" + ((sliceWidth + (position * sliceWidth)) - sliceWidth) + "px",
          bottom: settings.alignBottom ? '0' : 'auto',
          top: settings.alignBottom ? 'auto' : '0'
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
          top: top || 'auto',
          bottom: bottom || 'auto'
        });
        ramblingBox.append("<span><img src='" + (vars.currentSlideElement.attr('src') || vars.currentSlideElement.find('img').attr('src')) + "' alt=''/></span>");
        ramblingBox.find('img').css(ramblingBoxImageStyle);
        return ramblingBox;
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
        slice = getOneSlice();
        slice.css({
          top: (settings.alignBottom ? 'auto' : '0'),
          bottom: (settings.alignBottom ? '0' : 'auto')
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
        slices = createSlices();
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
        boxes = createBoxes();
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
            top: '0px'
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
            bottom: '0px'
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
            bottom: '0px'
          } : {
            top: '0px'
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
            top: '0px',
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
      ramblingRun = function(slider, children, settings, nudge) {
        var animationHelpers;
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
        setCurrentSlideElement(children);
        if (settings.controlNav) {
          slider.find('.rambling-controlNav a').removeClass('active').filter(":eq(" + vars.currentSlide + ")").addClass('active');
        }
        processCaption(settings);
        vars.running = true;
        animationHelpers = {
          setSliderBackground: setSliderBackground,
          currentSlideElement: vars.currentSlideElement,
          previousSlideElement: vars.previousSlideElement,
          raiseAnimationFinished: raiseAnimationFinished,
          settings: $.extend({}, settings),
          createSlices: createSlices,
          createBoxes: createBoxes,
          getOneSlice: getOneSlice,
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
        return getRandomAnimation().call(animationHelpers);
      };
      settings.afterLoad.call(this);
      this.stop = stop;
      this.start = start;
      this.previousSlide = previousSlide;
      this.nextSlide = nextSlide;
      this.slide = slide;
      this.effect = effect;
      this.theme = theme;
      this.option = option;
      this.destroy = destroy;
      this.initialize = initialize;
      this.run = run;
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
          right: '0px'
        });
        this.find('img').css({
          left: "" + (-slider.width()) + "px"
        }).animate({
          left: '0px'
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
          left: "" + (-slider.width()) + "px"
        }).animate({
          left: '0px'
        }, settings.speed * 2);
        return {
          width: slider.width()
        };
      },
      slideInLeft: function(slider) {
        var finishedHandler, self;
        self = this;
        self.css({
          height: '100%',
          width: 0,
          opacity: '1',
          left: 'auto',
          right: '0px'
        });
        finishedHandler = function() {
          self.css({
            left: '0px',
            right: 'auto'
          });
          return slider.unbind('rambling:finished', finishedHandler);
        };
        slider.bind('rambling:finished', finishedHandler);
      }
    };
    flashSlideIn = function(beforeAnimation, animateStyle, afterAnimation) {
      var self;
      self = this;
      self.currentSlideElement.css(beforeAnimation);
      return window.setTimeout((function() {
        return self.currentSlideElement.animate(animateStyle, self.settings.speed * 2, self.raiseAnimationFinished);
      }), self.settings.speed * 2);
    };
    flashHorizontalSlideIn = function(initialLeft) {
      var afterAnimation, beforeAnimation;
      beforeAnimation = {
        top: (this.settings.alignBottom ? 'auto' : '0'),
        bottom: (this.settings.alignBottom ? '-7px' : 'auto'),
        left: initialLeft,
        position: 'absolute',
        display: 'block'
      };
      afterAnimation = {
        top: 'auto',
        left: 'auto',
        position: 'relative'
      };
      return flashSlideIn.apply(this([
        beforeAnimation, {
          left: '0'
        }, afterAnimation
      ]));
    };
    $.fn.ramblingSlider.defaults.imageTransitions = [];
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
        self = this;
        slice = self.getOneSlice(self.previousSlideElement);
        slice.css({
          height: '100%',
          width: slice.parents('.ramblingSlider').width(),
          position: 'absolute',
          top: 0,
          left: 0,
          opacity: '1'
        });
        self.setSliderBackground();
        return slice.animate({
          opacity: '0'
        }, self.settings.speed * 2, '', function() {
          slice.css({
            display: 'none'
          });
          return self.raiseAnimationFinished();
        });
      }
    };
    $.fn.ramblingSlider.defaults.flashTransitions = {
      slideInRight: function() {
        var slider;
        slider = this.currentSlideElement.parents('.ramblingSlider').first();
        return flashHorizontalSlideIn.apply(this, [-slider.width()]);
      },
      slideInLeft: function() {
        var slider;
        slider = this.currentSlideElement.parents('.ramblingSlider').first();
        return flashHorizontalSlideIn.apply(this([slider.width()]));
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
}).call(this);
