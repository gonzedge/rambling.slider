(function() {
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
  */  (function($) {
    var RamblingSlider;
    RamblingSlider = function(element, options) {
      /*
          Defaults are below
          */      var adaptImagesFunctions, clearTimer, createBoxes, createSlices, defaultFunctions, functions, i, kids, liveWith, processCaption, ramblingAnimationContainer, ramblingControl, ramblingRun, settings, shuffle, slider, timer, trace, vars, _fn, _ref;
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
            left: (sliceWidth * position) + 'px',
            width: width + 'px',
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
            left: (boxWidth * column) + 'px',
            top: (boxHeight * row) + 'px',
            width: width + 'px',
            height: boxHeight + 'px',
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
            left: '-' + ((sliceWidth + (position * sliceWidth)) - sliceWidth) + 'px',
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
          ramblingBox.append('<span><img src="' + vars.currentImage.attr('src') + '" alt=""/></span>');
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
        ramblingCaption = $('.rambling-caption', slider);
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
        slider.append('<div class="rambling-directionNav"><a class="rambling-prevNav">' + settings.prevText + '</a><a class="rambling-nextNav">' + settings.nextText + '</a></div>');
        /*
              Hide Direction nav
              */
        if (settings.directionNavHide) {
          $('.rambling-directionNav', slider).hide();
          slider.hover((function() {
            return $('.rambling-directionNav', slider).show();
          }), (function() {
            return $('.rambling-directionNav', slider).hide();
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
        $('a.rambling-prevNav', slider).live('click', function() {
          return liveWith('prev');
        });
        $('a.rambling-nextNav', slider).live('click', function() {
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
              return ramblingControl.append('<a class="rambling-control" rel="' + i + '"><img src="' + child.attr('rel') + '" alt="" /></a>');
            } else {
              return ramblingControl.append('<a class="rambling-control" rel="' + i + '"><img src="' + child.attr('src').replace(settings.controlNavThumbsSearch, settings.controlNavThumbsReplace) + '" alt="" /></a>');
            }
          } else {
            return ramblingControl.append('<a class="rambling-control" rel="' + i + '">' + (i + 1) + '</a>');
          }
        };
        for (i = 0, _ref = kids.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
          _fn(i);
        }
        /*
              Set initial active link
              */
        $(".rambling-controlNav a:eq(" + vars.currentSlide + ")", slider).addClass('active');
        $('.rambling-controlNav a', slider).live('click', function() {
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
        for (i = 0, _ref2 = settings.slices - 1; 0 <= _ref2 ? i <= _ref2 : i >= _ref2; 0 <= _ref2 ? i++ : i--) {
          _results.push((function(i) {
            var animationContainer, sliceWidth;
            sliceWidth = Math.round(slider.width() / settings.slices);
            animationContainer = slider;
            animationContainer = slider.find('#rambling-animation');
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
        for (rows = 0, _ref2 = settings.boxRows - 1; 0 <= _ref2 ? rows <= _ref2 : rows >= _ref2; 0 <= _ref2 ? rows++ : rows--) {
          _results.push((function(rows) {
            var cols, _ref3, _results2;
            _results2 = [];
            for (cols = 0, _ref3 = settings.boxCols - 1; 0 <= _ref3 ? cols <= _ref3 : cols >= _ref3; 0 <= _ref3 ? cols++ : cols--) {
              _results2.push((function(cols) {
                var animationContainer;
                animationContainer = slider;
                animationContainer = slider.find('#rambling-animation');
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
              */        var anims, box2Darr, boxes, colIndex, cols, firstSlice, rowIndex, sliceStyle, slices, timeBuff, totalBoxes, v, _ref2, _results;
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
          $('.rambling-controlNav a', slider).removeClass('active');
          $('.rambling-controlNav a:eq(' + vars.currentSlide + ')', slider).addClass('active');
        }
        /*
              Process caption
              */
        processCaption(settings);
        /*
              Remove any slices from last transition
              */
        $('.rambling-slice', slider).remove();
        /*
              Remove any boxes from last transition
              */
        $('.rambling-box', slider).remove();
        if (settings.effect === 'random') {
          anims = ['sliceDownRight', 'sliceDownLeft', 'sliceUpRight', 'sliceUpLeft', 'sliceUpDown', 'sliceUpDownLeft', 'fold', 'fade', 'boxRandom', 'boxRain', 'boxRainReverse', 'boxRainGrow', 'boxRainGrowReverse'];
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
          if (vars.randAnim) {
            vars.randAnim = 'fade';
          }
        }
        /*
              Run effects
              */
        vars.running = true;
        if (settings.effect === 'sliceDown' || settings.effect === 'sliceDownRight' || vars.randAnim === 'sliceDownRight' || settings.effect === 'sliceDownLeft' || vars.randAnim === 'sliceDownLeft') {
          createSlices(slider, settings, vars);
          timeBuff = 0;
          i = 0;
          slices = $('.rambling-slice', slider);
          if (settings.effect === 'sliceDownLeft' || vars.randAnim === 'sliceDownLeft') {
            slices = $('.rambling-slice', slider)._reverse();
          }
          return slices.each(function() {
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
          });
        } else if (settings.effect === 'sliceUp' || settings.effect === 'sliceUpRight' || vars.randAnim === 'sliceUpRight' || settings.effect === 'sliceUpLeft' || vars.randAnim === 'sliceUpLeft') {
          createSlices(slider, settings, vars);
          timeBuff = 0;
          i = 0;
          slices = $('.rambling-slice', slider);
          if (settings.effect === 'sliceUpLeft' || vars.randAnim === 'sliceUpLeft') {
            slices = $('.rambling-slice', slider)._reverse();
          }
          return slices.each(function() {
            var slice;
            slice = $(this);
            slice.css({
              'bottom': '0px'
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
          });
        } else if (settings.effect === 'sliceUpDown' || settings.effect === 'sliceUpDownRight' || vars.randAnim === 'sliceUpDown' || settings.effect === 'sliceUpDownLeft' || vars.randAnim === 'sliceUpDownLeft') {
          createSlices(slider, settings, vars);
          timeBuff = 0;
          i = 0;
          v = 0;
          slices = $('.rambling-slice', slider);
          if (settings.effect === 'sliceUpDownLeft' || vars.randAnim === 'sliceUpDownLeft') {
            slices = $('.rambling-slice', slider)._reverse();
          }
          return slices.each(function() {
            var slice;
            slice = $(this);
            if (i === 0) {
              slice.css('top', '0px');
              i++;
            } else {
              slice.css('bottom', '0px');
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
          });
        } else if (settings.effect === 'fold' || vars.randAnim === 'fold') {
          createSlices(slider, settings, vars);
          timeBuff = 0;
          i = 0;
          return $('.rambling-slice', slider).each(function() {
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
          });
        } else if (settings.effect === 'fade' || vars.randAnim === 'fade') {
          createSlices(slider, settings, vars);
          firstSlice = $('.rambling-slice:first', slider);
          sliceStyle = {
            height: '100%',
            width: slider.width() + 'px',
            position: 'absolute',
            top: 0,
            left: 0
          };
          firstSlice.css(sliceStyle);
          return firstSlice.animate({
            opacity: '1.0'
          }, settings.animSpeed * 2, '', function() {
            return slider.trigger('rambling:animFinished');
          });
        } else if (settings.effect === 'slideInRight' || vars.randAnim === 'slideInRight') {
          createSlices(slider, settings, vars);
          firstSlice = $('.rambling-slice:first', slider);
          sliceStyle = {
            height: '100%',
            width: '0px',
            opacity: '1'
          };
          firstSlice.css(sliceStyle);
          return firstSlice.animate({
            width: slider.width() + 'px'
          }, settings.animSpeed * 2, '', function() {
            return slider.trigger('rambling:animFinished');
          });
        } else if (settings.effect === 'slideInLeft' || vars.randAnim === 'slideInLeft') {
          createSlices(slider, settings, vars);
          firstSlice = $('.rambling-slice:first', slider);
          sliceStyle = {
            height: '100%',
            width: '0px',
            opacity: '1',
            left: '',
            right: '0px'
          };
          firstSlice.css(sliceStyle);
          return firstSlice.animate({
            width: slider.width() + 'px'
          }, settings.animSpeed * 2, '', function() {
            var resetStyle;
            resetStyle = {
              left: '0px',
              right: ''
            };
            firstSlice.css(resetStyle);
            return slider.trigger('rambling:animFinished');
          });
        } else if (settings.effect === 'boxRandom' || vars.randAnim === 'boxRandom') {
          createBoxes(slider, settings, vars);
          totalBoxes = settings.boxCols * settings.boxRows;
          i = 0;
          timeBuff = 0;
          boxes = shuffle($('.rambling-box', slider));
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
        } else if (settings.effect === 'boxRain' || vars.randAnim === 'boxRain' || settings.effect === 'boxRainReverse' || vars.randAnim === 'boxRainReverse' || settings.effect === 'boxRainGrow' || vars.randAnim === 'boxRainGrow' || settings.effect === 'boxRainGrowReverse' || vars.randAnim === 'boxRainGrowReverse') {
          createBoxes(slider, settings, vars);
          totalBoxes = settings.boxCols * settings.boxRows;
          i = 0;
          timeBuff = 0;
          /*
                  Split boxes into 2D array
                  */
          rowIndex = 0;
          colIndex = 0;
          box2Darr = new Array();
          box2Darr[rowIndex] = new Array();
          boxes = $('.rambling-box', slider);
          if (settings.effect === 'boxRainReverse' || vars.randAnim === 'boxRainReverse' || settings.effect === 'boxRainGrowReverse' || vars.randAnim === 'boxRainGrowReverse') {
            boxes = $('.rambling-box', slider)._reverse();
          }
          boxes.each(function() {
            box2Darr[rowIndex][colIndex] = $(this);
            colIndex++;
            if (colIndex === settings.boxCols) {
              rowIndex++;
              colIndex = 0;
              return box2Darr[rowIndex] = new Array();
            }
          });
          /*
                  Run animation
                  */
          _results = [];
          for (cols = 0, _ref2 = settings.boxCols * 2 - 1; 0 <= _ref2 ? cols <= _ref2 : cols >= _ref2; 0 <= _ref2 ? cols++ : cols--) {
            _results.push((function(cols) {
              var prevCol, rows, _fn2, _ref3;
              prevCol = cols;
              _fn2 = function(rows) {
                if (prevCol >= 0 && prevCol < settings.boxCols) {
                  (function(row, col, time, i, totalBoxes) {
                    var box, h, w;
                    box = $(box2Darr[row][col]);
                    w = box.width();
                    h = box.height();
                    if (settings.effect === 'boxRainGrow' || vars.randAnim === 'boxRainGrow' || settings.effect === 'boxRainGrowReverse' || vars.randAnim === 'boxRainGrowReverse') {
                      box.width(0).height(0);
                    }
                    if (i === totalBoxes - 1) {
                      return setTimeout((function() {
                        return box.animate({
                          opacity: '1',
                          width: w,
                          height: h
                        }, settings.animSpeed / 1.3, '', function() {
                          return slider.trigger('rambling:animFinished');
                        });
                      }), 100 + time);
                    } else {
                      return setTimeout((function() {
                        return box.animate({
                          opacity: '1',
                          width: w,
                          height: h
                        }, settings.animSpeed / 1.3);
                      }), 100 + time);
                    }
                  })(rows, prevCol, timeBuff, i, totalBoxes);
                  i++;
                }
                return prevCol--;
              };
              for (rows = 0, _ref3 = settings.boxRows - 1; 0 <= _ref3 ? rows <= _ref3 : rows >= _ref3; 0 <= _ref3 ? rows++ : rows--) {
                _fn2(rows);
              }
              return timeBuff += 100;
            })(cols));
          }
          return _results;
        }
      };
      /*
          Shuffle an array
          */
      shuffle = function(arr) {
        var i, _fn2, _ref2;
        _fn2 = function(i) {
          var j, x;
          j = parseInt(Math.random() * i);
          x = arr[--i];
          arr[i] = arr[j];
          return arr[j] = j;
        };
        for (i = _ref2 = arr.length; _ref2 <= 1 ? i <= 1 : i >= 1; _ref2 <= 1 ? i++ : i--) {
          _fn2(i);
        }
        return arr;
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
    $.fn.ramblingSlider = function(options) {
      return this.each(function(key, value) {
        var element, ramblingslider;
        element = $(this);
        /*
              Return early if this element already has a plugin instance
              */
        if (element.data('ramblingslider')) {
          return element.data('ramblingslider');
        }
        /*
              Pass options to plugin constructor
              */
        ramblingslider = new RamblingSlider(this, options);
        /*
              Store plugin object in this element's data
              */
        return element.data('ramblingslider', ramblingslider);
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
    return $.fn._reverse = [].reverse;
  })(jQuery);
}).call(this);
