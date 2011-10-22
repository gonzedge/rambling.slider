(function() {
  (function($) {
    var NivoSlider;
    NivoSlider = function(element, options) {
      var adaptImagesFunctions, clearTimer, createBoxes, createSlices, defaultFunctions, functions, i, kids, liveWith, nivoControl, nivoRun, processCaption, settings, shuffle, slider, timer, trace, vars, _fn, _ref;
      settings = $.extend({}, $.fn.nivoSlider.defaults, options);
      vars = {
        currentSlide: 0,
        currentImage: '',
        totalSlides: 0,
        randAnim: '',
        running: false,
        paused: false,
        stop: false
      };
      functions = {};
      defaultFunctions = {
        setSliderBackground: function(slider, vars) {
          return slider.css({
            background: "url(" + (vars.currentImage.attr('src')) + ") no-repeat"
          });
        },
        getNivoSlice: function(sliceWidth, position, total, vars) {
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
          return $('<div class="nivo-slice"></div>').css(sliceCss);
        },
        getNivoBox: function(boxWidth, boxHeight, row, column, settings, vars) {
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
          return $('<div class="nivo-box"></div>').css(boxCss);
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
            slider.prepend(currentImage);
          }
          return currentImage.attr({
            src: image.attr('src'),
            alt: image.attr('alt')
          });
        },
        getNivoSlice: function(sliceWidth, position, total, vars) {
          var bottom, nivoSlice, nivoSliceImageStyle, top;
          nivoSlice = defaultFunctions.getNivoSlice(sliceWidth, position, total, vars);
          nivoSlice.css({
            background: 'none'
          });
          nivoSlice.append("<span><img src=\"" + (vars.currentImage.attr('src')) + "\" alt=\"\"/></span>");
          bottom = 0;
          top = 'auto';
          if (settings.alignBottom) {
            bottom = 'auto';
            top = 0;
          }
          nivoSliceImageStyle = {
            display: 'block',
            width: slider.width(),
            left: '-' + ((sliceWidth + (position * sliceWidth)) - sliceWidth) + 'px',
            bottom: bottom,
            top: top
          };
          nivoSlice.find('img').css(nivoSliceImageStyle);
          return nivoSlice;
        },
        getNivoBox: function(boxWidth, boxHeight, row, column, settings, vars) {
          var bottom, nivoBox, nivoBoxImageStyle, top;
          nivoBox = defaultFunctions.getNivoBox(boxWidth, boxHeight, row, column, settings, vars);
          bottom = false;
          top = "" + ((boxHeight + (row * boxHeight)) - boxHeight) + "px";
          if (settings.alignBottom) {
            bottom = "" + (boxHeight * (settings.boxRows - (row + 1))) + "px";
            top = false;
          }
          nivoBoxImageStyle = {
            display: 'block',
            width: slider.width(),
            left: "-" + ((boxWidth + (column * boxWidth)) - boxWidth) + "px",
            top: 'auto',
            bottom: 'auto'
          };
          if (top) {
            nivoBoxImageStyle.top = "-" + top;
          }
          if (bottom) {
            nivoBoxImageStyle.bottom = "-" + bottom;
          }
          nivoBox.css({
            background: 'none',
            top: top || 'auto',
            bottom: bottom || 'auto'
          });
          nivoBox.append('<span><img src="' + vars.currentImage.attr('src') + '" alt=""/></span>');
          nivoBox.find('img').css(nivoBoxImageStyle);
          return nivoBox;
        }
      };
      $.extend(functions, defaultFunctions);
      if (settings.adaptImages) {
        $.extend(functions, adaptImagesFunctions);
      }
      slider = $(element);
      slider.data('nivo:vars', vars);
      slider.css({
        position: 'relative'
      });
      slider.addClass('nivoSlider');
      kids = slider.children();
      kids.each(function() {
        var child, childHeight, childWidth, link;
        child = $(this);
        link = '';
        if (!child.is('img')) {
          if (child.is('a')) {
            child.addClass('nivo-imageLink');
            link = child;
          }
          child = child.find('img:first');
        }
        childWidth = child.width();
        if (childWidth === 0) {
          childWidth = child.attr('width');
        }
        childHeight = child.height();
        if (childHeight === 0) {
          childHeight = child.attr('height');
        }
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
      if (settings.startSlide > 0) {
        if (settings.startSlide >= vars.totalSlides) {
          settings.startSlide = vars.totalSlides - 1;
        }
        vars.currentSlide = settings.startSlide;
      }
      if ($(kids[vars.currentSlide]).is('img')) {
        vars.currentImage = $(kids[vars.currentSlide]);
      } else {
        vars.currentImage = $(kids[vars.currentSlide]).find('img:first');
      }
      if ($(kids[vars.currentSlide]).is('a')) {
        $(kids[vars.currentSlide]).css('display', 'block');
      }
      functions.setSliderBackground(slider, vars);
      slider.append($('<div class="nivo-caption"><p></p></div>').css({
        display: 'none',
        opacity: settings.captionOpacity
      }));
      processCaption = function(settings) {
        var nivoCaption, title;
        nivoCaption = $('.nivo-caption', slider);
        title = vars.currentImage.attr('title');
        if ((title != null) && title !== '') {
          if (title.substr(0, 1) === '#') {
            title = $(title).html();
          }
          if (nivoCaption.css('display') === 'block') {
            nivoCaption.find('p').fadeOut(settings.animSpeed, function() {
              $(this).html(title);
              return $(this).fadeIn(settings.animSpeed);
            });
          } else {
            nivoCaption.find('p').html(title);
          }
          return nivoCaption.fadeIn(settings.animSpeed);
        } else {
          return nivoCaption.fadeOut(settings.animSpeed);
        }
      };
      processCaption(settings);
      timer = 0;
      if (!settings.manualAdvance && kids.length > 1) {
        timer = setInterval((function() {
          return nivoRun(slider, kids, settings, false);
        }), settings.pauseTime);
      }
      clearTimer = function() {
        clearInterval(timer);
        return timer = '';
      };
      if (settings.directionNav) {
        slider.append('<div class="nivo-directionNav"><a class="nivo-prevNav">' + settings.prevText + '</a><a class="nivo-nextNav">' + settings.nextText + '</a></div>');
        if (settings.directionNavHide) {
          $('.nivo-directionNav', slider).hide();
          slider.hover((function() {
            return $('.nivo-directionNav', slider).show();
          }), (function() {
            return $('.nivo-directionNav', slider).hide();
          }));
        }
        liveWith = function(slider, kids, settings, direction) {
          if (vars.running) {
            return false;
          }
          clearTimer();
          vars.currentSlide -= 2;
          return nivoRun(slider, kids, settings, direction);
        };
        $('a.nivo-prevNav', slider).live('click', function() {
          return liveWith('prev');
        });
        $('a.nivo-nextNav', slider).live('click', function() {
          return liveWith('next');
        });
      }
      if (settings.controlNav) {
        nivoControl = $('<div class="nivo-controlNav"></div>');
        slider.append(nivoControl);
        _fn = function(i) {
          var child;
          if (settings.controlNavThumbs) {
            child = kids.eq(i);
            if (!child.is('img')) {
              child = child.find('img:first');
            }
            if (settings.controlNavThumbsFromRel) {
              return nivoControl.append('<a class="nivo-control" rel="' + i + '"><img src="' + child.attr('rel') + '" alt="" /></a>');
            } else {
              return nivoControl.append('<a class="nivo-control" rel="' + i + '"><img src="' + child.attr('src').replace(settings.controlNavThumbsSearch, settings.controlNavThumbsReplace) + '" alt="" /></a>');
            }
          } else {
            return nivoControl.append('<a class="nivo-control" rel="' + i + '">' + (i + 1) + '</a>');
          }
        };
        for (i = 0, _ref = kids.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
          _fn(i);
        }
        $('.nivo-controlNav a:eq(' + vars.currentSlide + ')', slider).addClass('active');
        $('.nivo-controlNav a', slider).live('click', function() {
          if (vars.running) {
            return false;
          }
          if ($(this).hasClass('active')) {
            return false;
          }
          clearTimer();
          functions.setSliderBackground(slider, vars);
          vars.currentSlide = $(this).attr('rel') - 1;
          return nivoRun(slider, kids, settings, 'control');
        });
      }
      if (settings.keyboardNav) {
        $(window).keypress(function(event) {
          if (event.keyCode === '37') {
            if (vars.running) {
              return false;
            }
            clearTimer();
            vars.currentSlide -= 2;
            nivoRun(slider, kids, settings, 'prev');
          }
          if (event.keyCode === '39') {
            if (vars.running) {
              return false;
            }
            clearTimer();
            return nivoRun(slider, kids, settings, 'next');
          }
        });
      }
      if (settings.pauseOnHover) {
        slider.hover(function() {
          vars.paused = true;
          return clearTimer();
        }, function() {
          vars.paused = false;
          if (timer === '' && !settings.manualAdvance) {
            return timer = setInterval((function() {
              return nivoRun(slider, kids, settings, false);
            }), settings.pauseTime);
          }
        });
      }
      slider.bind('nivo:animFinished', function() {
        vars.running = false;
        $(kids).each(function() {
          if ($(this).is('a')) {
            return $(this).css({
              display: 'none'
            });
          }
        });
        if ($(kids[vars.currentSlide]).is('a')) {
          $(kids[vars.currentSlide]).css({
            display: 'block'
          });
        }
        if (timer === '' && !vars.paused && !settings.manualAdvance) {
          timer = setInterval((function() {
            return nivoRun(slider, kids, settings, false);
          }), settings.pauseTime);
        }
        functions.setSliderBackground(slider, vars);
        return settings.afterChange.call(this);
      });
      createSlices = function(slider, settings, vars) {
        var i, _ref2, _results;
        _results = [];
        for (i = 0, _ref2 = settings.slices - 1; 0 <= _ref2 ? i <= _ref2 : i >= _ref2; 0 <= _ref2 ? i++ : i--) {
          _results.push((function(i) {
            var sliceWidth;
            sliceWidth = Math.round(slider.width() / settings.slices);
            return slider.append(functions.getNivoSlice(sliceWidth, i, settings.slices, vars));
          })(i));
        }
        return _results;
      };
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
                return slider.append(functions.getNivoBox(boxWidth, boxHeight, rows, cols, settings, vars));
              })(cols));
            }
            return _results2;
          })(rows));
        }
        return _results;
      };
      nivoRun = function(slider, kids, settings, nudge) {
        var anims, box2Darr, boxes, colIndex, cols, firstSlice, rowIndex, sliceStyle, slices, timeBuff, totalBoxes, v, _ref2, _results;
        vars = slider.data('nivo:vars');
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
        if ($(kids[vars.currentSlide]).is('img')) {
          vars.currentImage = $(kids[vars.currentSlide]);
        } else {
          vars.currentImage = $(kids[vars.currentSlide]).find('img:first');
        }
        if (settings.controlNav) {
          $('.nivo-controlNav a', slider).removeClass('active');
          $('.nivo-controlNav a:eq(' + vars.currentSlide + ')', slider).addClass('active');
        }
        processCaption(settings);
        $('.nivo-slice', slider).remove();
        $('.nivo-box', slider).remove();
        if (settings.effect === 'random') {
          anims = ['sliceDownRight', 'sliceDownLeft', 'sliceUpRight', 'sliceUpLeft', 'sliceUpDown', 'sliceUpDownLeft', 'fold', 'fade', 'boxRandom', 'boxRain', 'boxRainReverse', 'boxRainGrow', 'boxRainGrowReverse'];
          vars.randAnim = anims[Math.floor(Math.random() * (anims.length + 1))];
          if (!vars.randAnim) {
            vars.randAnim = 'fade';
          }
        }
        if (settings.effect.indexOf(',') !== -1) {
          anims = settings.effect.split(',');
          vars.randAnim = anims[Math.floor(Math.random() * anims.length)];
          if (vars.randAnim) {
            vars.randAnim = 'fade';
          }
        }
        vars.running = true;
        if (settings.effect === 'sliceDown' || settings.effect === 'sliceDownRight' || vars.randAnim === 'sliceDownRight' || settings.effect === 'sliceDownLeft' || vars.randAnim === 'sliceDownLeft') {
          createSlices(slider, settings, vars);
          timeBuff = 0;
          i = 0;
          slices = $('.nivo-slice', slider);
          if (settings.effect === 'sliceDownLeft' || vars.randAnim === 'sliceDownLeft') {
            slices = $('.nivo-slice', slider)._reverse();
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
                  return slider.trigger('nivo:animFinished');
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
          slices = $('.nivo-slice', slider);
          if (settings.effect === 'sliceUpLeft' || vars.randAnim === 'sliceUpLeft') {
            slices = $('.nivo-slice', slider)._reverse();
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
                  return slider.trigger('nivo:animFinished');
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
          slices = $('.nivo-slice', slider);
          if (settings.effect === 'sliceUpDownLeft' || vars.randAnim === 'sliceUpDownLeft') {
            slices = $('.nivo-slice', slider)._reverse();
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
                  return slider.trigger('nivo:animFinished');
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
          return $('.nivo-slice', slider).each(function() {
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
                  return slider.trigger('nivo:animFinished');
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
          firstSlice = $('.nivo-slice:first', slider);
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
            return slider.trigger('nivo:animFinished');
          });
        } else if (settings.effect === 'slideInRight' || vars.randAnim === 'slideInRight') {
          createSlices(slider, settings, vars);
          firstSlice = $('.nivo-slice:first', slider);
          sliceStyle = {
            height: '100%',
            width: '0px',
            opacity: '1'
          };
          firstSlice.css(sliceStyle);
          return firstSlice.animate({
            width: slider.width() + 'px'
          }, settings.animSpeed * 2, '', function() {
            return slider.trigger('nivo:animFinished');
          });
        } else if (settings.effect === 'slideInLeft' || vars.randAnim === 'slideInLeft') {
          createSlices(slider, settings, vars);
          firstSlice = $('.nivo-slice:first', slider);
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
            return slider.trigger('nivo:animFinished');
          });
        } else if (settings.effect === 'boxRandom' || vars.randAnim === 'boxRandom') {
          createBoxes(slider, settings, vars);
          totalBoxes = settings.boxCols * settings.boxRows;
          i = 0;
          timeBuff = 0;
          boxes = shuffle($('.nivo-box', slider));
          return boxes.each(function() {
            var box;
            box = $(this);
            if (i === totalBoxes - 1) {
              setTimeout((function() {
                return box.animate({
                  opacity: '1'
                }, settings.animSpeed, '', function() {
                  return slider.trigger('nivo:animFinished');
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
          rowIndex = 0;
          colIndex = 0;
          box2Darr = new Array();
          box2Darr[rowIndex] = new Array();
          boxes = $('.nivo-box', slider);
          if (settings.effect === 'boxRainReverse' || vars.randAnim === 'boxRainReverse' || settings.effect === 'boxRainGrowReverse' || vars.randAnim === 'boxRainGrowReverse') {
            boxes = $('.nivo-box', slider)._reverse();
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
                          return slider.trigger('nivo:animFinished');
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
      trace = function(msg) {
        if (this.console && console && console.log) {
          return console.log(msg);
        }
      };
      this.stop = function() {
        var $element;
        $element = $(element);
        if (!$element.data('nivo:vars').stop) {
          $element.data('nivo:vars').stop = true;
          return trace('Stop Slider');
        }
      };
      this.start = function() {
        var $element;
        $element = $(element);
        if ($element.data('nivo:vars').stop) {
          $element.data('nivo:vars').stop = false;
          return trace('Start Slider');
        }
      };
      settings.afterLoad.call(this);
      return this;
    };
    $.fn.nivoSlider = function(options) {
      return this.each(function(key, value) {
        var element, nivoslider;
        element = $(this);
        if (element.data('nivoslider')) {
          return element.data('nivoslider');
        }
        nivoslider = new NivoSlider(this, options);
        return element.data('nivoslider', nivoslider);
      });
    };
    $.fn.nivoSlider.defaults = {
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
