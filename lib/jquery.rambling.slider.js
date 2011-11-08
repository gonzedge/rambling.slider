(function() {
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
    var RamblingSlider, methods;
    methods = ['stop', 'start'];
    $.fn.ramblingSlider = function(options) {
      return this.each(function(key, value) {
        var element, ramblingSlider;
        element = $(this);
        if ((ramblingSlider = element.data('rambling:slider'))) {
          if (methods.contains(options)) {
            ramblingSlider[options]();
          }
          return ramblingSlider;
        }
        return element.data('rambling:slider', new RamblingSlider(this, options));
      });
    };
    /*
      Default settings
      */
    $.fn.ramblingSlider.defaults = {
      effect: 'random',
      slices: 15,
      boxCols: 8,
      boxRows: 4,
      animSpeed: 500,
      pauseTime: 3000,
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
      alignBottom: false,
      keyboardNav: true,
      pauseOnHover: true,
      manualAdvance: false,
      captionOpacity: 0.8,
      prevText: 'Prev',
      nextText: 'Next',
      beforeChange: function() {},
      afterChange: function() {},
      slideshowEnd: function() {},
      lastSlide: function() {},
      afterLoad: function() {}
    };
    return RamblingSlider = function(element, options) {
      var addCaption, addControlNavigation, addDirectionNavigation, addKeyboardNavigation, anims, createBoxes, createSlices, getBox, getRamblingBox, getRamblingSlice, getRandomAnimation, getSlice, initialize, kids, pauseSlider, prepareAdaptiveSlider, prepareSliderChildren, processCaption, ramblingRun, resetTimer, run, setAnimationFinishedActions, setCurrentSlideImage, setSliderBackground, setSliderInitialState, settings, slideTo, slider, timer, unpauseSlider, vars;
      slider = $(element);
      settings = $.extend({}, $.fn.ramblingSlider.defaults, options);
      timer = 0;
      vars = {
        currentSlide: 0,
        currentImage: '',
        totalSlides: 0,
        randAnim: '',
        running: false,
        paused: false,
        stop: false
      };
      anims = ['sliceDownRight', 'sliceDownLeft', 'sliceUpRight', 'sliceUpLeft', 'sliceUpDown', 'sliceUpDownLeft', 'fold', 'foldLeft', 'fade', 'slideInRight', 'slideInLeft', 'boxRandom', 'boxRain', 'boxRainReverse', 'boxRainGrow', 'boxRainGrowReverse'];
      if (settings.effect.contains(',')) {
        anims = settings.effect.split(',');
      }
      this.stop = function() {
        if (!vars.stop) {
          return vars.stop = true;
        }
      };
      this.start = function() {
        if (vars.stop) {
          return vars.stop = false;
        }
      };
      initialize = function() {
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
          return timer = setInterval((function() {
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
        if (settings.directionNav) {
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
        return anims[Math.floor(Math.random() * (anims.length + 1))] || 'fade';
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
            ramblingCaption.find('p').fadeOut(settings.animSpeed, function() {
              $(this).html(title);
              return $(this).fadeIn(settings.animSpeed);
            });
          } else {
            ramblingCaption.find('p').html(title);
          }
          return ramblingCaption.fadeIn(settings.animSpeed);
        } else {
          return ramblingCaption.fadeOut(settings.animSpeed);
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
        if (vars.running) {
          return false;
        }
        resetTimer();
        if (direction === 'prev') {
          vars.currentSlide -= 2;
        }
        return ramblingRun(slider, kids, settings, direction);
      };
      createSlices = function(slider, settings, vars) {
        var i, _ref, _results;
        _results = [];
        for (i = 0, _ref = settings.slices; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
          _results.push((function(i) {
            var animationContainer, sliceWidth;
            sliceWidth = Math.round(slider.width() / settings.slices);
            animationContainer = slider;
            if (settings.adaptImages) {
              animationContainer = slider.find('#rambling-animation');
            }
            return animationContainer.append(getRamblingSlice(sliceWidth, i, settings.slices, vars));
          })(i));
        }
        return _results;
      };
      createBoxes = function(slider, settings, vars) {
        var boxHeight, boxWidth, rows, _ref, _results;
        boxWidth = Math.round(slider.width() / settings.boxCols);
        boxHeight = Math.round(slider.height() / settings.boxRows);
        _results = [];
        for (rows = 0, _ref = settings.boxRows; 0 <= _ref ? rows < _ref : rows > _ref; 0 <= _ref ? rows++ : rows--) {
          _results.push((function(rows) {
            var cols, _ref2, _results2;
            _results2 = [];
            for (cols = 0, _ref2 = settings.boxCols; 0 <= _ref2 ? cols < _ref2 : cols > _ref2; 0 <= _ref2 ? cols++ : cols--) {
              _results2.push((function(cols) {
                var animationContainer;
                animationContainer = slider;
                if (settings.adaptImages) {
                  animationContainer = slider.find('#rambling-animation');
                }
                return animationContainer.append(getRamblingBox(boxWidth, boxHeight, rows, cols, settings, vars));
              })(cols));
            }
            return _results2;
          })(rows));
        }
        return _results;
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
      kids = slider.children(':not(#rambling-animation)');
      initialize();
      run();
      ramblingRun = function(slider, kids, settings, nudge) {
        var animate, animation, animation_callbacks, animation_options, boxes, callbacks, controlNavAnchors, current_animation, current_effect, current_effect_options, firstSlice, i, slices, timeBuff, totalBoxes, v;
        if (vars && vars.currentSlide === vars.totalSlides - 1) {
          settings.lastSlide.call(this);
        }
        if ((!vars || vars.stop) && !nudge) {
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
        /*
              Set active links
              */
        if (settings.controlNav) {
          controlNavAnchors = slider.find('.rambling-controlNav a');
          controlNavAnchors.removeClass('active');
          controlNavAnchors.filter(":eq(" + vars.currentSlide + ")").addClass('active');
        }
        /*
              Process caption
              */
        processCaption(settings);
        /*
              Remove any slices and boxes from last transition
              */
        slider.find('.rambling-slice,.rambling-box').remove();
        /*
              Run random effect from specified or default set (eg: effect:'fold,fade')
              */
        if (settings.effect === 'random' || settings.effect.contains(',')) {
          vars.randAnim = getRandomAnimation();
        }
        /*
              Run effects
              */
        vars.running = true;
        current_effect = vars.randAnim || settings.effect;
        if (current_effect.contains('slice') || current_effect.contains('fold')) {
          createSlices(slider, settings, vars);
          timeBuff = 0;
          i = 0;
          v = 0;
          slices = slider.find('.rambling-slice');
          if (current_effect.contains('Left')) {
            slices = slices.reverse();
          }
          animation = current_effect.replace(/Right/, '').replace(/Left/, '');
          animation_callbacks = {
            sliceDown: function() {
              var slice;
              slice = $(this);
              slice.css({
                top: '0px'
              });
              if (i === settings.slices - 1) {
                setTimeout(function() {
                  return slice.animate({
                    height: '100%',
                    opacity: '1.0'
                  }, settings.animSpeed, '', function() {
                    return slider.trigger('rambling:finished');
                  });
                }, 100 + timeBuff);
              } else {
                setTimeout((function() {
                  return slice.animate({
                    height: '100%',
                    opacity: '1.0'
                  }, settings.animSpeed);
                }), 100 + timeBuff);
              }
              timeBuff += 50;
              return i++;
            },
            sliceUp: function() {
              var slice;
              slice = $(this);
              slice.css({
                bottom: '0px'
              });
              if (i === settings.slices - 1) {
                setTimeout((function() {
                  return slice.animate({
                    height: '100%',
                    opacity: '1.0'
                  }, settings.animSpeed, '', function() {
                    return slider.trigger('rambling:finished');
                  });
                }), 100 + timeBuff);
              } else {
                setTimeout((function() {
                  return slice.animate({
                    height: '100%',
                    opacity: '1.0'
                  }, settings.animSpeed);
                }), 100 + timeBuff);
              }
              timeBuff += 50;
              return i++;
            },
            sliceUpDown: function() {
              var slice;
              slice = $(this);
              if (i === 0) {
                slice.css({
                  top: '0px'
                });
                i++;
              } else {
                slice.css({
                  bottom: '0px'
                });
                i = 0;
              }
              if (v === settings.slices - 1) {
                setTimeout((function() {
                  return slice.animate({
                    height: '100%',
                    opacity: '1.0'
                  }, settings.animSpeed, '', function() {
                    return slider.trigger('rambling:finished');
                  });
                }), 100 + timeBuff);
              } else {
                setTimeout((function() {
                  return slice.animate({
                    height: '100%',
                    opacity: '1.0'
                  }, settings.animSpeed);
                }), 100 + timeBuff);
              }
              timeBuff += 50;
              return v++;
            },
            fold: function() {
              var origWidth, slice;
              slice = $(this);
              origWidth = slice.width();
              slice.css({
                top: '0px',
                height: '100%',
                width: '0px'
              });
              if (i === settings.slices - 1) {
                setTimeout((function() {
                  return slice.animate({
                    width: origWidth,
                    opacity: '1.0'
                  }, settings.animSpeed, '', function() {
                    return slider.trigger('rambling:finished');
                  });
                }), 100 + timeBuff);
              } else {
                setTimeout((function() {
                  return slice.animate({
                    width: origWidth,
                    opacity: '1.0'
                  }, settings.animSpeed);
                }), 100 + timeBuff);
              }
              timeBuff += 50;
              return i++;
            }
          };
          return slices.each(animation_callbacks[animation]);
        } else if (current_effect === 'fade' || current_effect === 'slideInRight' || current_effect === 'slideInLeft') {
          createSlices(slider, settings, vars);
          animation_options = {
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
              callback: function(slice) {
                var resetStyle;
                resetStyle = {
                  left: '0px',
                  right: ''
                };
                return slice.css(resetStyle);
              }
            }
          };
          current_effect_options = animation_options[current_effect];
          animate = current_effect_options.animate || {
            width: "" + (slider.width()) + "px"
          };
          firstSlice = slider.find('.rambling-slice:first');
          firstSlice.css(animation_options[current_effect].style);
          return firstSlice.animate(animate, settings.animSpeed * 2, '', function() {
            if (current_effect_options.callback) {
              current_effect_options.callback(firstSlice);
            }
            return slider.trigger('rambling:finished');
          });
        } else if (current_effect.contains('box')) {
          createBoxes(slider, settings, vars);
          totalBoxes = settings.boxCols * settings.boxRows;
          i = 0;
          timeBuff = 0;
          boxes = slider.find('.rambling-box');
          if (current_effect.contains('Reverse')) {
            boxes = boxes.reverse();
          }
          animation_callbacks = {
            random: {
              beforeAnimation: function() {
                return boxes = boxes.shuffle();
              },
              animate: function(boxes) {
                return boxes.each(function() {
                  var box;
                  box = $(this);
                  if (i === totalBoxes - 1) {
                    setTimeout((function() {
                      return box.animate({
                        opacity: '1'
                      }, settings.animSpeed, '', function() {
                        return slider.trigger('rambling:finished');
                      });
                    }), 100 + timeBuff);
                  } else {
                    setTimeout((function() {
                      return box.animate({
                        opacity: '1'
                      }, settings.animSpeed);
                    }), 100 + timeBuff);
                  }
                  timeBuff += 20;
                  return i++;
                });
              }
            },
            rain: {
              beforeAnimation: function() {
                return boxes = boxes.as2dArray(settings.boxCols);
              },
              animate: function(boxes) {
                var cols, _ref, _results;
                _results = [];
                for (cols = 0, _ref = settings.boxCols * 2; 0 <= _ref ? cols < _ref : cols > _ref; 0 <= _ref ? cols++ : cols--) {
                  _results.push((function(cols) {
                    var prevCol, rows, _fn, _ref2;
                    prevCol = cols;
                    _fn = function(rows) {
                      var box, col, h, row, time, w;
                      if (prevCol >= 0 && prevCol < settings.boxCols) {
                        row = rows;
                        col = prevCol;
                        time = timeBuff;
                        box = $(boxes[row][col]);
                        w = box.width();
                        h = box.height();
                        if (current_effect.contains('Grow')) {
                          box.css({
                            width: 0,
                            height: 0
                          });
                        }
                        if (i === totalBoxes - 1) {
                          setTimeout((function() {
                            return box.animate({
                              opacity: '1',
                              width: w,
                              height: h
                            }, settings.animSpeed / 1.3, '', function() {
                              return slider.trigger('rambling:finished');
                            });
                          }), 100 + time);
                        } else {
                          setTimeout((function() {
                            return box.animate({
                              opacity: '1',
                              width: w,
                              height: h
                            }, settings.animSpeed / 1.3);
                          }), 100 + time);
                        }
                        i++;
                      }
                      return prevCol--;
                    };
                    for (rows = 0, _ref2 = settings.boxRows; 0 <= _ref2 ? rows < _ref2 : rows > _ref2; 0 <= _ref2 ? rows++ : rows--) {
                      _fn(rows);
                    }
                    return timeBuff += 100;
                  })(cols));
                }
                return _results;
              }
            }
          };
          current_animation = current_effect.replace(/box/, '').replace(/Grow/, '').replace(/Reverse/, '').decapitalize();
          callbacks = animation_callbacks[current_animation];
          callbacks.beforeAnimation();
          return callbacks.animate(boxes);
        }
      };
      settings.afterLoad.call(this);
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
