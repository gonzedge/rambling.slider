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
    RamblingSlider = function(element, options) {
      /*
          Defaults are below
          */      var adaptImagesFunctions, clearTimer, controlNavAnchors, createBoxes, createSlices, defaultFunctions, directionNav, functions, i, kids, liveWith, processCaption, ramblingAnimationContainer, ramblingControl, ramblingRun, settings, slider, timer, trace, vars, _fn, _ref;
      settings = $.extend({}, $.fn.ramblingSlider.defaults, options);
      /*
          Useful variables. Play carefully.
          */
      vars = {
        currentSlide: 0,
        currentImage: '',
        totalSlides: 0,
        randAnim: '',
        running: false,
        paused: false,
        stop: false
      };
      /*
          Additional stuff for adapt images
          */
      functions = {};
      defaultFunctions = {
        setSliderBackground: function(slider, vars) {
          return slider.css({
            background: "url(" + (vars.currentImage.attr('src')) + ") no-repeat"
          });
        },
        getRamblingSlice: function(sliceWidth, position, total, vars) {
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
        },
        getRamblingBox: function(boxWidth, boxHeight, row, column, settings, vars) {
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
        }
      };
      adaptImagesFunctions = {
        setSliderBackground: function() {
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
        },
        getRamblingSlice: function(sliceWidth, position, total, vars) {
          var bottom, ramblingSlice, ramblingSliceImageStyle, top;
          ramblingSlice = defaultFunctions.getRamblingSlice(sliceWidth, position, total, vars);
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
        },
        getRamblingBox: function(boxWidth, boxHeight, row, column, settings, vars) {
          var bottom, ramblingBox, ramblingBoxImageStyle, top;
          ramblingBox = defaultFunctions.getRamblingBox(boxWidth, boxHeight, row, column, settings, vars);
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
        }
      };
      $.extend(functions, defaultFunctions);
      if (settings.adaptImages) {
        $.extend(functions, adaptImagesFunctions);
      }
      /*
          End adapt images
          */
      /*
          Get this slider
          */
      slider = $(element);
      slider.data('rambling:vars', vars);
      slider.css({
        position: 'relative'
      });
      slider.addClass('ramblingSlider');
      if (settings.adaptImages) {
        ramblingAnimationContainer = $('<div id="rambling-animation"></div>');
        ramblingAnimationContainer.css({
          width: slider.width(),
          height: slider.height(),
          overflow: 'hidden'
        });
        slider.prepend(ramblingAnimationContainer);
        slider.addClass('adaptingSlider');
      }
      /*
          Find our slider children
          */
      kids = slider.children(':not(#rambling-animation)');
      kids.each(function() {
        var child, childHeight, childWidth, link;
        child = $(this);
        link = '';
        if (!child.is('img')) {
          if (child.is('a')) {
            child.addClass('rambling-imageLink');
            link = child;
          }
          child = child.find('img:first');
        }
        /*
              Get img width & height
              */
        childWidth = child.width();
        if (childWidth === 0) {
          childWidth = child.attr('width');
        }
        childHeight = child.height();
        if (childHeight === 0) {
          childHeight = child.attr('height');
        }
        /*
              Resize the slider
              */
        if (childWidth > slider.width() && settings.useLargerImage) {
          slider.width(childWidth);
        }
        if (childHeight > slider.height() && (settings.useLargerImage || !settings.adaptImages)) {
          slider.height(childHeight);
        }
        if (link !== '') {
          link.css({
            display: 'none'
          });
        }
        child.css({
          display: 'none'
        });
        return vars.totalSlides++;
      });
      /*
          Set startSlide
          */
      if (settings.startSlide > 0) {
        if (settings.startSlide >= vars.totalSlides) {
          settings.startSlide = vars.totalSlides - 1;
        }
        vars.currentSlide = settings.startSlide;
      }
      /*
          Get initial image
          */
      if ($(kids[vars.currentSlide]).is('img')) {
        vars.currentImage = $(kids[vars.currentSlide]);
      } else {
        vars.currentImage = $(kids[vars.currentSlide]).find('img:first');
      }
      /*
          Show initial link
          */
      if ($(kids[vars.currentSlide]).is('a')) {
        $(kids[vars.currentSlide]).css('display', 'block');
      }
      /*
          Set first background
          */
      functions.setSliderBackground(slider, vars);
      /*
          Create caption
          */
      slider.append($('<div class="rambling-caption"><p></p></div>').css({
        display: 'none',
        opacity: settings.captionOpacity
      }));
      /*
          Process caption function
          */
      processCaption = function(settings) {
        var ramblingCaption, title;
        ramblingCaption = slider.find('.rambling-caption');
        title = vars.currentImage.attr('title');
        if ((title != null) && title !== '') {
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
      /*
          Process initial  caption
          */
      processCaption(settings);
      /*
          In the words of Super Mario "let's a go!"
          */
      timer = 0;
      if (!settings.manualAdvance && kids.length > 1) {
        timer = setInterval((function() {
          return ramblingRun(slider, kids, settings, false);
        }), settings.pauseTime);
      }
      clearTimer = function() {
        clearInterval(timer);
        return timer = '';
      };
      /*
          Add Direction nav
          */
      if (settings.directionNav) {
        slider.append("<div class='rambling-directionNav'><a class='rambling-prevNav'>" + settings.prevText + "</a><a class='rambling-nextNav'>" + settings.nextText + "</a></div>");
        /*
              Hide Direction nav
              */
        if (settings.directionNavHide) {
          directionNav = slider.find('.rambling-directionNav');
          directionNav.hide();
          slider.hover((function() {
            return directionNav.show();
          }), (function() {
            return directionNav.hide();
          }));
        }
        liveWith = function(slider, kids, settings, direction) {
          if (vars.running) {
            return false;
          }
          clearTimer();
          vars.currentSlide -= 2;
          return ramblingRun(slider, kids, settings, direction);
        };
        slider.find('a.rambling-prevNav').live('click', function() {
          return liveWith('prev');
        });
        slider.find('a.rambling-nextNav').live('click', function() {
          return liveWith('next');
        });
      }
      /*
          Add Control nav
          */
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
        /*
              Set initial active link
              */
        controlNavAnchors = slider.find('.rambling-controlNav a');
        controlNavAnchors.filter(":eq(" + vars.currentSlide + ")").addClass('active');
        controlNavAnchors.live('click', function() {
          if (vars.running) {
            return false;
          }
          if ($(this).hasClass('active')) {
            return false;
          }
          clearTimer();
          functions.setSliderBackground(slider, vars);
          vars.currentSlide = $(this).attr('rel') - 1;
          return ramblingRun(slider, kids, settings, 'control');
        });
      }
      /*
          Keyboard Navigation
          */
      if (settings.keyboardNav) {
        $(window).keypress(function(event) {
          /*
                  Left
                  */          if (event.keyCode === '37') {
            if (vars.running) {
              return false;
            }
            clearTimer();
            vars.currentSlide -= 2;
            ramblingRun(slider, kids, settings, 'prev');
          }
          /*
                  Right
                  */
          if (event.keyCode === '39') {
            if (vars.running) {
              return false;
            }
            clearTimer();
            return ramblingRun(slider, kids, settings, 'next');
          }
        });
      }
      /*
          For pauseOnHover setting
          */
      if (settings.pauseOnHover) {
        slider.hover(function() {
          vars.paused = true;
          return clearTimer();
        }, function() {
          vars.paused = false;
          if (timer === '' && !settings.manualAdvance) {
            return timer = setInterval((function() {
              return ramblingRun(slider, kids, settings, false);
            }), settings.pauseTime);
          }
        });
      }
      /*
          Event when Animation finishes
          */
      slider.bind('rambling:animFinished', function() {
        vars.running = false;
        /*
              Hide child links
              */
        $(kids).each(function() {
          if ($(this).is('a')) {
            return $(this).css({
              display: 'none'
            });
          }
        });
        /*
              Show current link
              */
        if ($(kids[vars.currentSlide]).is('a')) {
          $(kids[vars.currentSlide]).css({
            display: 'block'
          });
        }
        /*
              Restart the timer
              */
        if (timer === '' && !vars.paused && !settings.manualAdvance) {
          timer = setInterval((function() {
            return ramblingRun(slider, kids, settings, false);
          }), settings.pauseTime);
        }
        functions.setSliderBackground(slider, vars);
        /*
              Trigger the afterChange callback
              */
        return settings.afterChange.call(this);
      });
      /*
          Add slices for slice animations
          */
      createSlices = function(slider, settings, vars) {
        var i, _ref2, _results;
        _results = [];
        for (i = 0, _ref2 = settings.slices; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
          _results.push((function(i) {
            var animationContainer, sliceWidth;
            sliceWidth = Math.round(slider.width() / settings.slices);
            animationContainer = slider;
            if (settings.adaptImages) {
              animationContainer = slider.find('#rambling-animation');
            }
            return animationContainer.append(functions.getRamblingSlice(sliceWidth, i, settings.slices, vars));
          })(i));
        }
        return _results;
      };
      /*
          Add boxes for box animations
          */
      createBoxes = function(slider, settings, vars) {
        var boxHeight, boxWidth, rows, _ref2, _results;
        boxWidth = Math.round(slider.width() / settings.boxCols);
        boxHeight = Math.round(slider.height() / settings.boxRows);
        _results = [];
        for (rows = 0, _ref2 = settings.boxRows; 0 <= _ref2 ? rows < _ref2 : rows > _ref2; 0 <= _ref2 ? rows++ : rows--) {
          _results.push((function(rows) {
            var cols, _ref3, _results2;
            _results2 = [];
            for (cols = 0, _ref3 = settings.boxCols; 0 <= _ref3 ? cols < _ref3 : cols > _ref3; 0 <= _ref3 ? cols++ : cols--) {
              _results2.push((function(cols) {
                var animationContainer;
                animationContainer = slider;
                if (settings.adaptImages) {
                  animationContainer = slider.find('#rambling-animation');
                }
                return animationContainer.append(functions.getRamblingBox(boxWidth, boxHeight, rows, cols, settings, vars));
              })(cols));
            }
            return _results2;
          })(rows));
        }
        return _results;
      };
      /*
          Private run method
          */
      ramblingRun = function(slider, kids, settings, nudge) {
        /*
              Get our vars
              */        var animate, animation, animation_callbacks, animation_options, anims, boxes, callbacks, current_animation, current_effect, current_effect_options, firstSlice, slices, timeBuff, totalBoxes, v;
        vars = slider.data('rambling:vars');
        /*
              Trigger the lastSlide callback
              */
        if (vars && vars.currentSlide === vars.totalSlides - 1) {
          settings.lastSlide.call(this);
        }
        /*
              Stop
              */
        if ((!vars || vars.stop) && !nudge) {
          return false;
        }
        /*
              Trigger the beforeChange callback
              */
        settings.beforeChange.call(this);
        vars.currentSlide++;
        /*
              Trigger the slideshowEnd callback
              */
        if (vars.currentSlide === vars.totalSlides) {
          vars.currentSlide = 0;
          settings.slideshowEnd.call(this);
        }
        if (vars.currentSlide < 0) {
          vars.currentSlide = vars.totalSlides - 1;
        }
        /*
              Set vars.currentImage
              */
        if ($(kids[vars.currentSlide]).is('img')) {
          vars.currentImage = $(kids[vars.currentSlide]);
        } else {
          vars.currentImage = $(kids[vars.currentSlide]).find('img:first');
        }
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
              Remove any slices from last transition
              */
        slider.find('.rambling-slice').remove();
        /*
              Remove any boxes from last transition
              */
        slider.find('.rambling-box').remove();
        if (settings.effect === 'random') {
          anims = ['sliceDownRight', 'sliceDownLeft', 'sliceUpRight', 'sliceUpLeft', 'sliceUpDown', 'sliceUpDownLeft', 'fold', 'fade', 'slideInRight', 'slideInLeft', 'boxRandom', 'boxRain', 'boxRainReverse', 'boxRainGrow', 'boxRainGrowReverse'];
          vars.randAnim = anims[Math.floor(Math.random() * (anims.length + 1))];
          if (!vars.randAnim) {
            vars.randAnim = 'fade';
          }
        }
        /*
              Run random effect from specified set (eg: effect:'fold,fade')
              */
        if (settings.effect.indexOf(',') !== -1) {
          anims = settings.effect.split(',');
          vars.randAnim = anims[Math.floor(Math.random() * anims.length)];
          if (!vars.randAnim) {
            vars.randAnim = 'fade';
          }
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
                    return slider.trigger('rambling:animFinished');
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
                    return slider.trigger('rambling:animFinished');
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
                    return slider.trigger('rambling:animFinished');
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
                    return slider.trigger('rambling:animFinished');
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
            return slider.trigger('rambling:animFinished');
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
                        return slider.trigger('rambling:animFinished');
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
                var cols, _ref2, _results;
                _results = [];
                for (cols = 0, _ref2 = settings.boxCols * 2; 0 <= _ref2 ? cols < _ref2 : cols > _ref2; 0 <= _ref2 ? cols++ : cols--) {
                  _results.push((function(cols) {
                    var prevCol, rows, _fn2, _ref3;
                    prevCol = cols;
                    _fn2 = function(rows) {
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
                              return slider.trigger('rambling:animFinished');
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
                    for (rows = 0, _ref3 = settings.boxRows; 0 <= _ref3 ? rows < _ref3 : rows > _ref3; 0 <= _ref3 ? rows++ : rows--) {
                      _fn2(rows);
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
      /*
          For debugging
          */
      trace = function(msg) {
        if (this.console && console && console.log) {
          return console.log(msg);
        }
      };
      /*
          Start / Stop
          */
      this.stop = function() {
        var $element;
        $element = $(element);
        if (!$element.data('rambling:vars').stop) {
          $element.data('rambling:vars').stop = true;
          return trace('Stop Slider');
        }
      };
      this.start = function() {
        var $element;
        $element = $(element);
        if ($element.data('rambling:vars').stop) {
          $element.data('rambling:vars').stop = false;
          return trace('Start Slider');
        }
      };
      /*
          Trigger the afterLoad callback
          */
      settings.afterLoad.call(this);
      return this;
    };
    methods = ['stop', 'start'];
    $.fn.ramblingSlider = function(options) {
      return this.each(function(key, value) {
        var element, ramblingSlider;
        element = $(this);
        ramblingSlider = element.data('ramblingSlider');
        if (methods.contains(options) && ramblingSlider) {
          ramblingSlider[options]();
        }
        /*
              Return early if this element already has a plugin instance
              */
        if (ramblingSlider) {
          return ramblingSlider;
        }
        /*
              Pass options to plugin constructor
              */
        ramblingSlider = new RamblingSlider(this, options);
        /*
              Store plugin object in this element's data
              */
        return element.data('ramblingSlider', ramblingSlider);
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
