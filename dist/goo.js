(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Circle, Goo, TWEEN, h;

require('./polyfills');

h = require('./helpers');

TWEEN = require('./vendor/tween');

Circle = (function() {
  function Circle(o) {
    this.o = o != null ? o : {};
    this.vars();
    this.draw();
  }

  Circle.prototype.vars = function() {
    this.ctx = this.o.ctx;
    if (!this.ctx) {
      console.error('nay! I need a conext');
      return;
    }
    this.radius = this.o.radius || 50;
    this.x = this.o.x || 0;
    this.y = this.o.y || 0;
    return this.fill = this.o.fill;
  };

  Circle.prototype.draw = function() {
    this.ctx.beginPath();
    this.ctx.arc(this.x, this.y, this.radius, 0, 2 * Math.PI, false);
    this.ctx.fillStyle = this.fill || '#999';
    return this.ctx.fill();
  };

  Circle.prototype.set = function(key, val) {
    var propName, propValue;
    if (key !== null && typeof key === 'object') {
      for (propName in key) {
        propValue = key[propName];
        this[propName] = propValue;
      }
    }
    if (typeof key === 'string') {
      this[key] = val;
    }
    return this.draw();
  };

  return Circle;

})();

Goo = (function() {
  function Goo(o) {
    this.o = o != null ? o : {};
    this.vars();
    this.createCircles();
    this.run();
  }

  Goo.prototype.vars = function() {
    this.canvas = document.querySelector('#js-canvas');
    this.ctx = this.canvas.getContext('2d');
    this.width = parseInt(this.canvas.getAttribute('width'), 10);
    this.height = parseInt(this.canvas.getAttribute('height'), 10);
    this.deg = Math.PI / 180;
    return this.isDebug = true;
  };

  Goo.prototype.createCircles = function() {
    this.circle1 = new Circle({
      ctx: this.ctx,
      x: 400,
      y: 400,
      radius: 75
    });
    return this.circle2 = new Circle({
      ctx: this.ctx,
      x: 600,
      y: 400,
      radius: 100
    });
  };

  Goo.prototype.gooCircles = function(circle1, circle2) {
    var angle, angleShift1, angleShift2, bigCircle, bottomCircle, curvePoints1, curvePoints2, curvePoints3, curvePoints4, dX, dY, distance, dx, dy, intPoints, isCirclesIntX, isCirclesIntY, isIntersect, isIntersectX, isIntersectY, isRadiusIntX, isRadiusIntY, leftCircle, len, middleLine, middleLinePoint1, middleLinePoint2, middlePoint, point1, point2, radius, reactDistance, rightCircle, smallCircle, topCircle, x, x1, x2, x3, y, y1, y2, y3;
    if (circle1.radius >= circle2.radius) {
      bigCircle = circle1;
      smallCircle = circle2;
    } else {
      bigCircle = circle2;
      smallCircle = circle1;
    }
    if (circle1.x >= circle2.x) {
      rightCircle = circle1;
      leftCircle = circle2;
    } else {
      leftCircle = circle1;
      rightCircle = circle2;
    }
    if (circle1.y >= circle2.y) {
      topCircle = circle1;
      bottomCircle = circle2;
    } else {
      bottomCircle = circle1;
      topCircle = circle2;
    }
    x = circle1.x - circle2.x;
    y = circle1.y - circle2.y;
    angle = Math.atan(y / x);
    angleShift1 = x > 0 ? 180 * this.deg : 0;
    angleShift2 = x > 0 ? 0 : 180 * this.deg;
    point1 = {
      x: circle1.x + Math.cos(angle + angleShift1) * circle1.radius,
      y: circle1.y + Math.sin(angle + angleShift1) * circle1.radius
    };
    point2 = {
      x: circle2.x + Math.cos(angle + angleShift2) * circle2.radius,
      y: circle2.y + Math.sin(angle + angleShift2) * circle2.radius
    };
    middlePoint = {
      x: (point1.x + point2.x) / 2,
      y: (point1.y + point2.y) / 2
    };
    dx = Math.abs(point1.x - point2.x);
    dy = Math.abs(point1.y - point2.y);
    radius = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2)) / 2;
    middleLinePoint1 = {
      x: middlePoint.x + Math.cos(angle + (90 * this.deg)) * radius,
      y: middlePoint.y + Math.sin(angle + (90 * this.deg)) * radius
    };
    middleLinePoint2 = {
      x: middlePoint.x + Math.cos(angle + (-90 * this.deg)) * radius,
      y: middlePoint.y + Math.sin(angle + (-90 * this.deg)) * radius
    };
    dX = circle1.x - circle2.x;
    dY = circle1.y - circle2.y;
    len = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2));
    reactDistance = (circle1.radius + circle2.radius) / 2;
    distance = 1 - reactDistance / len;
    isRadiusIntX = point1.x - point2.x < 0;
    isCirclesIntX = circle1.x - circle2.x < 0;
    isRadiusIntY = point1.y - point2.y < 0;
    isCirclesIntY = circle1.y - circle2.y < 0;
    isIntersectX = isRadiusIntX ^ isCirclesIntX;
    isIntersectY = isRadiusIntY ^ isCirclesIntY;
    isIntersect = isIntersectX || isIntersectY;
    if (this.isDebug && !isIntersect) {
      this.ctx.beginPath();
      this.ctx.arc(point1.x, point1.y, 2, 0, 2 * Math.PI, false);
      this.ctx.arc(point2.x, point2.y, 2, 0, 2 * Math.PI, false);
      this.ctx.fillStyle = 'deeppink';
      this.ctx.fill();
    }
    if (isIntersect) {
      intPoints = this.circlesIntersecton(circle2, circle1);
      middleLinePoint1 = {
        x: intPoints[0],
        y: intPoints[2]
      };
      middleLinePoint2 = {
        x: intPoints[1],
        y: intPoints[3]
      };
      middlePoint = {
        x: (middleLinePoint1.x + middleLinePoint2.x) / 2,
        y: (middleLinePoint1.y + middleLinePoint2.y) / 2
      };
      if (this.isDebug) {
        this.ctx.beginPath();
        this.ctx.arc(middleLinePoint1.x, middleLinePoint1.y, 2, 0, 2 * Math.PI, false);
        this.ctx.arc(middleLinePoint2.x, middleLinePoint2.y, 2, 0, 2 * Math.PI, false);
        this.ctx.fillStyle = 'deeppink';
        this.ctx.fill();
      }
    } else {
      if (this.isDebug) {
        this.ctx.beginPath();
        this.ctx.arc(middleLinePoint1.x, middleLinePoint1.y, 2, 0, 2 * Math.PI, false);
        this.ctx.arc(middleLinePoint2.x, middleLinePoint2.y, 2, 0, 2 * Math.PI, false);
        this.ctx.fillStyle = 'orange';
        this.ctx.fill();
      }
      if (this.isDebug) {
        this.ctx.beginPath();
        this.ctx.arc(middlePoint.x, middlePoint.y, radius, 0, 2 * Math.PI, false);
        this.ctx.strokeStyle = 'cyan';
        this.ctx.lineWidth = .25;
        this.ctx.stroke();
      }
      if (this.isDebug) {
        this.ctx.beginPath();
        this.ctx.arc(middlePoint.x, middlePoint.y, 2, 0, 2 * Math.PI, false);
        this.ctx.fillStyle = 'cyan';
        this.ctx.fill();
      }
    }
    middleLine = {
      start: middleLinePoint1,
      end: middleLinePoint2,
      center: middlePoint
    };
    if (this.isDebug) {
      this.ctx.beginPath();
      this.ctx.moveTo(middleLine.start.x, middleLine.start.y);
      this.ctx.lineTo(middleLine.end.x, middleLine.end.y);
      this.ctx.strokeStyle = 'orange';
      this.ctx.stroke();
    }
    if (this.isDebug && !isIntersect) {
      this.ctx.beginPath();
      this.ctx.arc(middlePoint.x, middlePoint.y, reactDistance, 0, 2 * Math.PI, false);
      this.ctx.strokeStyle = 'yellow';
      this.ctx.stroke();
    }
    curvePoints1 = this.circleMath({
      middleLine: middleLine,
      circle: circle1,
      angle: angle,
      distance: distance,
      isIntersect: isIntersect
    });
    curvePoints2 = this.circleMath({
      middleLine: middleLine,
      circle: circle1,
      angle: angle,
      side: 'top',
      distance: distance,
      isIntersect: isIntersect
    });
    curvePoints3 = this.circleMath({
      middleLine: middleLine,
      circle: circle2,
      angle: angle,
      distance: distance,
      isIntersect: isIntersect,
      isRight: true
    });
    curvePoints4 = this.circleMath({
      middleLine: middleLine,
      circle: circle2,
      angle: angle,
      side: 'top',
      distance: distance,
      isIntersect: isIntersect,
      isRight: true
    });
    if (reactDistance < radius) {
      return;
    }
    if (!isIntersect) {
      this.ctx.beginPath();
      this.ctx.moveTo(curvePoints1.circlePoint.x, curvePoints1.circlePoint.y);
      x1 = curvePoints1.handlePoint.x;
      y1 = curvePoints1.handlePoint.y;
      x2 = curvePoints4.handlePoint.x;
      y2 = curvePoints4.handlePoint.y;
      x3 = curvePoints4.circlePoint.x;
      y3 = curvePoints4.circlePoint.y;
      this.ctx.bezierCurveTo(x1, y1, x2, y2, x3, y3);
      this.ctx.lineTo(curvePoints3.circlePoint.x, curvePoints3.circlePoint.y);
      x1 = curvePoints3.handlePoint.x;
      y1 = curvePoints3.handlePoint.y;
      x2 = curvePoints2.handlePoint.x;
      y2 = curvePoints2.handlePoint.y;
      x3 = curvePoints2.circlePoint.x;
      y3 = curvePoints2.circlePoint.y;
      this.ctx.bezierCurveTo(x1, y1, x2, y2, x3, y3);
      this.ctx.closePath();
      this.ctx.fillStyle = this.isDebug ? "rgba(255, 255, 255, 0.5)" : '#999';
      this.ctx.fill();
    }
    if (isIntersect) {
      this.ctx.beginPath();
      this.ctx.moveTo(curvePoints1.circlePoint.x, curvePoints1.circlePoint.y);
      x1 = curvePoints1.handlePoint.x;
      y1 = curvePoints1.handlePoint.y;
      x2 = curvePoints3.handlePoint.x;
      y2 = curvePoints3.handlePoint.y;
      x3 = curvePoints3.circlePoint.x;
      y3 = curvePoints3.circlePoint.y;
      this.ctx.bezierCurveTo(x1, y1, x2, y2, x3, y3);
      this.ctx.lineTo(curvePoints4.circlePoint.x, curvePoints4.circlePoint.y);
      x1 = curvePoints4.handlePoint.x;
      y1 = curvePoints4.handlePoint.y;
      x2 = curvePoints2.handlePoint.x;
      y2 = curvePoints2.handlePoint.y;
      x3 = curvePoints2.circlePoint.x;
      y3 = curvePoints2.circlePoint.y;
      this.ctx.bezierCurveTo(x1, y1, x2, y2, x3, y3);
      this.ctx.closePath();
      this.ctx.fillStyle = this.isDebug ? "rgba(255, 255, 255, 0.5)" : '#999';
      return this.ctx.fill();
    }
  };

  Goo.prototype.circleMath = function(o) {
    var absOffsetAngle, angle, angleOffset, circle, dist, dx, dy, gulp, handlesAngle, intPoint, intersectAngle, isInt, isRight, isSmall, line1, middleLine, normAngle, offset, offsetAngle, point, point1, point11, point1Angle, side, x, y;
    circle = o.circle;
    angle = o.angle;
    middleLine = o.middleLine;
    side = o.side;
    dist = o.distance;
    isSmall = o.isSmall;
    isInt = o.isIntersect;
    isRight = o.isRight;
    if (!isInt) {
      dx = circle.x - middleLine.center.x;
      point1Angle = dx > 0 ? angle : angle + (180 * this.deg);
      offset = 0;
      handlesAngle = dist > 0 ? 45 * dist : 0;
      absOffsetAngle = (90 + offset + handlesAngle) * this.deg;
      offsetAngle = side === 'top' ? absOffsetAngle : -absOffsetAngle;
      point1 = {
        x: circle.x + Math.cos(point1Angle + offsetAngle) * circle.radius,
        y: circle.y + Math.sin(point1Angle + offsetAngle) * circle.radius
      };
      point11 = {
        x: circle.x + Math.cos(point1Angle + (1.01 * offsetAngle)) * circle.radius,
        y: circle.y + Math.sin(point1Angle + (1.01 * offsetAngle)) * circle.radius
      };
      dx = point1.x - point11.x;
      dy = point1.y - point11.y;
      intersectAngle = middleLine.center.x - point1.x > 0 ? Math.atan(dy / dx) : Math.atan(dy / dx) + 180 * this.deg;
    } else {
      gulp = (middleLine.center.x - circle.x) * (circle.radius / 100) / 56.225;
      gulp = 1 - Math.abs(gulp);
      console.log(gulp);
      angle = 15 * gulp * this.deg;
      if (isRight) {
        angle = -angle;
      }
      if (side === 'top') {
        point = middleLine.start;
        angleOffset = angle;
      } else {
        point = middleLine.end;
        angleOffset = -angle;
      }
      if (isRight) {
        angleOffset = -angleOffset;
      }
      y = point.y - circle.y;
      x = circle.x - point.x;
      angle = Math.atan2(y, x);
      if (!isRight) {
        normAngle = angle * 180 / Math.PI;
        if (normAngle < 0) {
          if (normAngle > -40) {
            angle = -40 * this.deg;
          }
        } else {
          if (normAngle < 40) {
            angle = 40 * this.deg;
          }
        }
      }
      point1Angle = angle + angleOffset - (180 * this.deg);
      point1 = {
        x: circle.x + Math.cos(point1Angle) * circle.radius,
        y: circle.y + Math.sin(point1Angle) * circle.radius
      };
      point11 = {
        x: circle.x + Math.cos(1.01 * point1Angle) * circle.radius,
        y: circle.y + Math.sin(1.01 * point1Angle) * circle.radius
      };
      dx = point1.x - point11.x;
      dy = point1.y - point11.y;
      intersectAngle = middleLine.center.x - point1.x > 0 ? Math.atan(dy / dx) : Math.atan(dy / dx) + 180 * this.deg;
    }
    line1 = {
      start: point1,
      end: point11
    };
    intPoint = this.intersection(line1, middleLine);
    if (this.isDebug) {
      this.ctx.beginPath();
      this.ctx.arc(circle.x, circle.y, 2, 0, 2 * Math.PI, false);
      this.ctx.fillStyle = 'cyan';
      this.ctx.fill();
      this.ctx.beginPath();
      this.ctx.arc(intPoint.x, intPoint.y, 2, 0, 2 * Math.PI, false);
      this.ctx.fillStyle = 'yellow';
      this.ctx.fill();
      this.ctx.beginPath();
      this.ctx.arc(point1.x, point1.y, 2, 0, 2 * Math.PI, false);
      this.ctx.fillStyle = 'cyan';
      this.ctx.fill();
      this.ctx.beginPath();
      this.ctx.arc(point11.x, point11.y, 1, 0, 2 * Math.PI, false);
      this.ctx.fillStyle = 'cyan';
      this.ctx.fill();
      this.ctx.beginPath();
      this.ctx.moveTo(point1.x, point1.y);
      this.ctx.lineTo(intPoint.x, intPoint.y);
      this.ctx.strokeStyle = 'yellow';
      this.ctx.stroke();
    }
    return {
      handlePoint: {
        x: intPoint.x,
        y: intPoint.y
      },
      circlePoint: {
        x: point1.x,
        y: point1.y
      }
    };
  };

  Goo.prototype.intersection = function(line1, line2) {
    var a, b, denominator, dm1, dm2, num1, num2, result;
    result = {};
    dm1 = (line2.end.y - line2.start.y) * (line1.end.x - line1.start.x);
    dm2 = (line2.end.x - line2.start.x) * (line1.end.y - line1.start.y);
    denominator = dm1 - dm2;
    if (denominator === 0) {
      return result;
    }
    a = line1.start.y - line2.start.y;
    b = line1.start.x - line2.start.x;
    num1 = ((line2.end.x - line2.start.x) * a) - ((line2.end.y - line2.start.y) * b);
    num2 = ((line1.end.x - line1.start.x) * a) - ((line1.end.y - line1.start.y) * b);
    a = num1 / denominator;
    b = num2 / denominator;
    result.x = line1.start.x + (a * (line1.end.x - line1.start.x));
    result.y = line1.start.y + (a * (line1.end.y - line1.start.y));
    if (a > 0 && a < 1) {
      result.onLine1 = true;
    }
    if (b > 0 && b < 1) {
      result.onLine2 = true;
    }
    return result;
  };

  Goo.prototype.circlesIntersecton = function(circle1, circle2) {
    var a, d, dx, dy, r0, r1, rx, ry, x0, x1, x2, xi, xi_prime, y0, y1, y2, yi, yi_prime;
    x0 = circle1.x;
    y0 = circle1.y;
    r0 = circle1.radius;
    x1 = circle2.x;
    y1 = circle2.y;
    r1 = circle2.radius;
    dx = x1 - x0;
    dy = y1 - y0;
    d = Math.sqrt((dy * dy) + (dx * dx));
    if (d > (r0 + r1)) {
      return false;
    }
    if (d < Math.abs(r0 - r1)) {
      return false;
    }
    a = ((r0 * r0) - (r1 * r1) + (d * d)) / (2.0 * d);
    x2 = x0 + (dx * a / d);
    y2 = y0 + (dy * a / d);
    h = Math.sqrt((r0 * r0) - (a * a));
    rx = -dy * (h / d);
    ry = dx * (h / d);
    xi = x2 + rx;
    xi_prime = x2 - rx;
    yi = y2 + ry;
    yi_prime = y2 - ry;
    return [xi, xi_prime, yi, yi_prime];
  };

  Goo.prototype.run = function() {
    var angle, it, offset, radius, radiusOffset, start, tween;
    it = this;
    start = 400;
    offset = 400;
    angle = 5 * 360;
    radius = 365;
    radiusOffset = 349;
    tween = new TWEEN.Tween({
      p: 0
    }).to({
      p: 1
    }, 50000).onUpdate(function() {
      it.ctx.clear();
      it.circle2.draw();
      it.circle1.set({
        x: start + (offset * this.p),
        y: it.circle1.y
      });
      return it.gooCircles(it.circle1, it.circle2);
    }).yoyo(true).repeat(999).start();
    return h.startAnimationLoop();
  };

  return Goo;

})();

new Goo;



},{"./helpers":2,"./polyfills":3,"./vendor/tween":4}],2:[function(require,module,exports){
var Helpers, TWEEN;

TWEEN = require('./vendor/tween');

Helpers = (function() {
  Helpers.prototype.pixel = 2;

  Helpers.prototype.doc = document;

  Helpers.prototype.body = document.body;

  Helpers.prototype.deg = Math.PI / 180;

  Helpers.prototype.DEG = Math.PI / 180;

  Helpers.prototype.s = 1;

  Helpers.prototype.time = function(time) {
    return time * this.s;
  };

  Helpers.prototype.isFF = function() {
    return navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
  };

  Helpers.prototype.isIE = function() {
    return this.isIE9l() || this.isIE10g();
  };

  Helpers.prototype.isIE9l = function() {
    return navigator.userAgent.toLowerCase().indexOf('msie') > -1;
  };

  Helpers.prototype.isIE10g = function() {
    return navigator.userAgent.toLowerCase().indexOf('rv') > -1;
  };

  function Helpers(o) {
    this.o = o != null ? o : {};
    this.animationLoop = this.animationLoop.bind(this);
    this.div = document.createElement('div');
    this.computedStyle = function(elem) {
      if (window.getComputedStyle) {
        return getComputedStyle(elem, '');
      } else {
        return elem.currentStyle;
      }
    };
    this.shortColors = {
      aqua: 'rgb(0,255,255)',
      black: 'rgb(0,0,0)',
      blue: 'rgb(0,0,255)',
      fuchsia: 'rgb(255,0,255)',
      gray: 'rgb(128,128,128)',
      green: 'rgb(0,128,0)',
      lime: 'rgb(0,255,0)',
      maroon: 'rgb(128,0,0)',
      navy: 'rgb(0,0,128)',
      olive: 'rgb(128,128,0)',
      purple: 'rgb(128,0,128)',
      red: 'rgb(255,0,0)',
      silver: 'rgb(192,192,192)',
      teal: 'rgb(0,128,128)',
      white: 'rgb(255,255,255)',
      yellow: 'rgb(255,255,0)',
      orange: 'rgb(255,128,0)'
    };
  }

  Helpers.prototype.slice = function(value, max) {
    if (value > max) {
      return max;
    } else {
      return value;
    }
  };

  Helpers.prototype.sliceMod = function(value, max) {
    if (value > 0) {
      if (value > max) {
        return max;
      } else {
        return value;
      }
    } else if (value < -max) {
      return -max;
    } else {
      return value;
    }
  };

  Helpers.prototype.clone = function(obj) {
    var key, target, value;
    target = {};
    for (key in obj) {
      value = obj[key];
      target[key] = value;
    }
    return target;
  };

  Helpers.prototype.getStyle = function(el) {
    var computedStyle;
    if (window.getComputedStyle) {
      return computedStyle = getComputedStyle(el, null);
    } else {
      return computedStyle = el.currentStyle;
    }
  };

  Helpers.prototype.rand = function(min, max) {
    return Math.floor((Math.random() * ((max + 1) - min)) + min);
  };

  Helpers.prototype.bind = function(func, context) {
    var bindArgs, wrapper;
    wrapper = function() {
      var args, unshiftArgs;
      args = Array.prototype.slice.call(arguments);
      unshiftArgs = bindArgs.concat(args);
      return func.apply(context, unshiftArgs);
    };
    bindArgs = Array.prototype.slice.call(arguments, 2);
    return wrapper;
  };

  Helpers.prototype.isObj = function(obj) {
    return !!obj && (obj.constructor === Object);
  };

  Helpers.prototype.makeColorObj = function(color) {
    var alpha, b, colorObj, g, isRgb, r, regexString1, regexString2, result, rgbColor;
    if (color[0] === '#') {
      result = /^#?([a-f\d]{1,2})([a-f\d]{1,2})([a-f\d]{1,2})$/i.exec(color);
      colorObj = {};
      if (result) {
        r = result[1].length === 2 ? result[1] : result[1] + result[1];
        g = result[2].length === 2 ? result[2] : result[2] + result[2];
        b = result[3].length === 2 ? result[3] : result[3] + result[3];
        colorObj = {
          r: parseInt(r, 16),
          g: parseInt(g, 16),
          b: parseInt(b, 16),
          a: 1
        };
      }
    }
    if (color[0] !== '#') {
      isRgb = color[0] === 'r' && color[1] === 'g' && color[2] === 'b';
      if (isRgb) {
        rgbColor = color;
      }
      if (!isRgb) {
        rgbColor = !this.shortColors[color] ? (this.div.style.color = color, this.isFF() || this.isIE() ? this.computedStyle(this.div).color : this.div.style.color) : this.shortColors[color];
      }
      regexString1 = '^rgba?\\((\\d{1,3}),\\s?(\\d{1,3}),';
      regexString2 = '\\s?(\\d{1,3}),?\\s?(\\d{1}|0?\\.\\d{1,})?\\)$';
      result = new RegExp(regexString1 + regexString2, 'gi').exec(rgbColor);
      colorObj = {};
      alpha = parseFloat(result[4] || 1);
      if (result) {
        colorObj = {
          r: parseInt(result[1], 10),
          g: parseInt(result[2], 10),
          b: parseInt(result[3], 10),
          a: (alpha != null) && !isNaN(alpha) ? alpha : 1
        };
      }
    }
    return colorObj;
  };

  Helpers.prototype.size = function(obj) {
    var i, key, value;
    i = 0;
    for (key in obj) {
      value = obj[key];
      i++;
    }
    return i;
  };

  Helpers.prototype.isSizeChange = function(o) {
    var isLineWidth, isRadius, isRadiusAxes1, isRadiusAxes2;
    isRadius = o.radiusStart || o.radiusEnd;
    isRadiusAxes1 = o.radiusStartX || o.radiusStartY;
    isRadiusAxes2 = o.radiusEndX || o.radiusEndX;
    isLineWidth = o.lineWidth || o.lineWidthMiddle || o.lineWidthEnd;
    return isRadius || isRadiusAxes1 || isRadiusAxes2 || isLineWidth;
  };

  Helpers.prototype.lock = function(o) {
    !this[o.lock] && o.fun();
    return this[o.lock] = true;
  };

  Helpers.prototype.unlock = function(o) {
    return this[o.lock] = false;
  };

  Helpers.prototype.animationLoop = function() {
    if (!TWEEN.getAll().length) {
      this.isAnimateLoop = false;
    }
    if (!this.isAnimateLoop) {
      return;
    }
    TWEEN.update();
    return requestAnimationFrame(this.animationLoop);
  };

  Helpers.prototype.startAnimationLoop = function() {
    if (this.isAnimateLoop) {
      return;
    }
    this.isAnimateLoop = true;
    return requestAnimationFrame(this.animationLoop);
  };

  Helpers.prototype.stopAnimationLoop = function() {
    return this.isAnimateLoop = false;
  };

  return Helpers;

})();

module.exports = (function() {
  return new Helpers;
})();



},{"./vendor/tween":4}],3:[function(require,module,exports){
module.exports = (function() {
  if (!CanvasRenderingContext2D.prototype.clear) {
    return CanvasRenderingContext2D.prototype.clear = function(preserveTransform) {
      if (preserveTransform) {
        this.save();
        this.setTransform(1, 0, 0, 1, 0, 0);
      }
      this.clearRect(0, 0, this.canvas.width, this.canvas.height);
      if (preserveTransform) {
        this.restore();
      }
    };
  }
})();



},{}],4:[function(require,module,exports){
;(function(undefined){


	
(function() {
    var lastTime = 0;
    var vendors = ['ms', 'moz', 'webkit', 'o'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame'] 
                                   || window[vendors[x]+'CancelRequestAnimationFrame'];
    }
 
    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); }, 
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };
 
    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}());
	

	/**
	 * Tween.js - Licensed under the MIT license
	 * https://github.com/sole/tween.js
	 * ----------------------------------------------
	 *
	 * See https://github.com/sole/tween.js/graphs/contributors for the full list of contributors.
	 * Thank you all, you're awesome!
	 */

	// Date.now shim for (ahem) Internet Explo(d|r)er
	if ( Date.now === undefined ) {

		Date.now = function () {

			return new Date().valueOf();

		};

	}

	var TWEEN = TWEEN || ( function () {

		var _tweens = [];

		return {

			REVISION: '14',

			getAll: function () {

				return _tweens;

			},

			removeAll: function () {

				_tweens = [];

			},

			add: function ( tween ) {

				_tweens.push( tween );

			},

			remove: function ( tween ) {

				var i = _tweens.indexOf( tween );

				if ( i !== -1 ) {

					_tweens.splice( i, 1 );

				}

			},

			update: function ( time ) {

				if ( _tweens.length === 0 ) return false;

				var i = 0;

				time = time !== undefined ? time : ( typeof window !== 'undefined' && window.performance !== undefined && window.performance.now !== undefined ? window.performance.now() : Date.now() );

				while ( i < _tweens.length ) {

					if ( _tweens[ i ].update( time ) ) {

						i++;

					} else {

						_tweens.splice( i, 1 );

					}

				}

				return true;

			}
		};

	} )();

	TWEEN.Tween = function ( object ) {

		var _object = object;
		var _valuesStart = {};
		var _valuesEnd = {};
		var _valuesStartRepeat = {};
		var _duration = 1000;
		var _repeat = 0;
		var _yoyo = false;
		var _isPlaying = false;
		var _reversed = false;
		var _delayTime = 0;
		var _startTime = null;
		var _easingFunction = TWEEN.Easing.Linear.None;
		var _interpolationFunction = TWEEN.Interpolation.Linear;
		var _chainedTweens = [];
		var _onStartCallback = null;
		var _onStartCallbackFired = false;
		var _onUpdateCallback = null;
		var _onCompleteCallback = null;
		var _onStopCallback = null;

		// Set all starting values present on the target object
		for ( var field in object ) {

			_valuesStart[ field ] = parseFloat(object[field], 10);

		}

		this.to = function ( properties, duration ) {

			if ( duration !== undefined ) {

				_duration = duration;

			}

			_valuesEnd = properties;

			return this;

		};

		this.start = function ( time ) {

			TWEEN.add( this );

			_isPlaying = true;

			_onStartCallbackFired = false;

			_startTime = time !== undefined ? time : ( typeof window !== 'undefined' && window.performance !== undefined && window.performance.now !== undefined ? window.performance.now() : Date.now() );
			_startTime += _delayTime;

			for ( var property in _valuesEnd ) {

				// check if an Array was provided as property value
				if ( _valuesEnd[ property ] instanceof Array ) {

					if ( _valuesEnd[ property ].length === 0 ) {

						continue;

					}

					// create a local copy of the Array with the start value at the front
					_valuesEnd[ property ] = [ _object[ property ] ].concat( _valuesEnd[ property ] );

				}

				_valuesStart[ property ] = _object[ property ];

				if( ( _valuesStart[ property ] instanceof Array ) === false ) {
					_valuesStart[ property ] *= 1.0; // Ensures we're using numbers, not strings
				}

				_valuesStartRepeat[ property ] = _valuesStart[ property ] || 0;

			}

			return this;

		};

		this.stop = function () {

			if ( !_isPlaying ) {
				return this;
			}

			TWEEN.remove( this );
			_isPlaying = false;

			if ( _onStopCallback !== null ) {

				_onStopCallback.call( _object );

			}

			this.stopChainedTweens();
			return this;

		};

		this.stopChainedTweens = function () {

			for ( var i = 0, numChainedTweens = _chainedTweens.length; i < numChainedTweens; i++ ) {

				_chainedTweens[ i ].stop();

			}

		};

		this.delay = function ( amount ) {

			_delayTime = amount;
			return this;

		};

		this.repeat = function ( times ) {
			_repeat = times;
			return this;

		};

		this.yoyo = function( yoyo ) {

			_yoyo = yoyo;
			return this;

		};


		this.easing = function ( easing ) {

			_easingFunction = easing;
			return this;

		};

		this.interpolation = function ( interpolation ) {

			_interpolationFunction = interpolation;
			return this;

		};

		this.chain = function () {

			_chainedTweens = arguments;
			return this;

		};

		this.onStart = function ( callback ) {

			_onStartCallback = callback;
			return this;

		};

		this.onUpdate = function ( callback ) {

			_onUpdateCallback = callback;
			return this;

		};

		this.onComplete = function ( callback ) {

			_onCompleteCallback = callback;
			return this;

		};

		this.onStop = function ( callback ) {

			_onStopCallback = callback;
			return this;

		};

		this.update = function ( time ) {

			var property;

			if ( time < _startTime ) {

				return true;

			}

			if ( _onStartCallbackFired === false ) {

				if ( _onStartCallback !== null ) {

					_onStartCallback.call( _object );

				}

				_onStartCallbackFired = true;

			}

			var elapsed = ( time - _startTime ) / _duration;
			elapsed = elapsed > 1 ? 1 : elapsed;

			var value = _easingFunction( elapsed );

			for ( property in _valuesEnd ) {

				var start = _valuesStart[ property ] || 0;
				var end = _valuesEnd[ property ];

				if ( end instanceof Array ) {

					_object[ property ] = _interpolationFunction( end, value );

				} else {

					// Parses relative end values with start as base (e.g.: +10, -3)
					if ( typeof(end) === "string" ) {
						end = start + parseFloat(end, 10);
					}

					// protect against non numeric properties.
					if ( typeof(end) === "number" ) {
						_object[ property ] = start + ( end - start ) * value;
					}

				}

			}

			if ( _onUpdateCallback !== null ) {

				_onUpdateCallback.call( _object, value );

			}

			if ( elapsed == 1 ) {

				if ( _repeat > 0 ) {

					if( isFinite( _repeat ) ) {
						_repeat--;
					}

					// reassign starting values, restart by making startTime = now
					for( property in _valuesStartRepeat ) {

						if ( typeof( _valuesEnd[ property ] ) === "string" ) {
							_valuesStartRepeat[ property ] = _valuesStartRepeat[ property ] + parseFloat(_valuesEnd[ property ], 10);
						}

						if (_yoyo) {
							var tmp = _valuesStartRepeat[ property ];
							_valuesStartRepeat[ property ] = _valuesEnd[ property ];
							_valuesEnd[ property ] = tmp;
						}

						_valuesStart[ property ] = _valuesStartRepeat[ property ];

					}

					if (_yoyo) {
						_reversed = !_reversed;
					}

					_startTime = time + _delayTime;

					return true;

				} else {

					if ( _onCompleteCallback !== null ) {

						_onCompleteCallback.call( _object );

					}

					for ( var i = 0, numChainedTweens = _chainedTweens.length; i < numChainedTweens; i++ ) {

						_chainedTweens[ i ].start( time );

					}

					return false;

				}

			}

			return true;

		};

	};


	TWEEN.Easing = {

		Linear: {

			None: function ( k ) {

				return k;

			}

		},

		Quadratic: {

			In: function ( k ) {

				return k * k;

			},

			Out: function ( k ) {

				return k * ( 2 - k );

			},

			InOut: function ( k ) {

				if ( ( k *= 2 ) < 1 ) return 0.5 * k * k;
				return - 0.5 * ( --k * ( k - 2 ) - 1 );

			}

		},

		Cubic: {

			In: function ( k ) {

				return k * k * k;

			},

			Out: function ( k ) {

				return --k * k * k + 1;

			},

			InOut: function ( k ) {

				if ( ( k *= 2 ) < 1 ) return 0.5 * k * k * k;
				return 0.5 * ( ( k -= 2 ) * k * k + 2 );

			}

		},

		Quartic: {

			In: function ( k ) {

				return k * k * k * k;

			},

			Out: function ( k ) {

				return 1 - ( --k * k * k * k );

			},

			InOut: function ( k ) {

				if ( ( k *= 2 ) < 1) return 0.5 * k * k * k * k;
				return - 0.5 * ( ( k -= 2 ) * k * k * k - 2 );

			}

		},

		Quintic: {

			In: function ( k ) {

				return k * k * k * k * k;

			},

			Out: function ( k ) {

				return --k * k * k * k * k + 1;

			},

			InOut: function ( k ) {

				if ( ( k *= 2 ) < 1 ) return 0.5 * k * k * k * k * k;
				return 0.5 * ( ( k -= 2 ) * k * k * k * k + 2 );

			}

		},

		Sinusoidal: {

			In: function ( k ) {

				return 1 - Math.cos( k * Math.PI / 2 );

			},

			Out: function ( k ) {

				return Math.sin( k * Math.PI / 2 );

			},

			InOut: function ( k ) {

				return 0.5 * ( 1 - Math.cos( Math.PI * k ) );

			}

		},

		Exponential: {

			In: function ( k ) {

				return k === 0 ? 0 : Math.pow( 1024, k - 1 );

			},

			Out: function ( k ) {

				return k === 1 ? 1 : 1 - Math.pow( 2, - 10 * k );

			},

			InOut: function ( k ) {

				if ( k === 0 ) return 0;
				if ( k === 1 ) return 1;
				if ( ( k *= 2 ) < 1 ) return 0.5 * Math.pow( 1024, k - 1 );
				return 0.5 * ( - Math.pow( 2, - 10 * ( k - 1 ) ) + 2 );

			}

		},

		Circular: {

			In: function ( k ) {

				return 1 - Math.sqrt( 1 - k * k );

			},

			Out: function ( k ) {

				return Math.sqrt( 1 - ( --k * k ) );

			},

			InOut: function ( k ) {

				if ( ( k *= 2 ) < 1) return - 0.5 * ( Math.sqrt( 1 - k * k) - 1);
				return 0.5 * ( Math.sqrt( 1 - ( k -= 2) * k) + 1);

			}

		},

		Elastic: {

			In: function ( k ) {

				var s, a = 0.1, p = 0.4;
				if ( k === 0 ) return 0;
				if ( k === 1 ) return 1;
				if ( !a || a < 1 ) { a = 1; s = p / 4; }
				else s = p * Math.asin( 1 / a ) / ( 2 * Math.PI );
				return - ( a * Math.pow( 2, 10 * ( k -= 1 ) ) * Math.sin( ( k - s ) * ( 2 * Math.PI ) / p ) );

			},

			Out: function ( k ) {

				var s, a = 0.1, p = 0.4;
				if ( k === 0 ) return 0;
				if ( k === 1 ) return 1;
				if ( !a || a < 1 ) { a = 1; s = p / 4; }
				else s = p * Math.asin( 1 / a ) / ( 2 * Math.PI );
				return ( a * Math.pow( 2, - 10 * k) * Math.sin( ( k - s ) * ( 2 * Math.PI ) / p ) + 1 );

			},

			InOut: function ( k ) {

				var s, a = 0.1, p = 0.4;
				if ( k === 0 ) return 0;
				if ( k === 1 ) return 1;
				if ( !a || a < 1 ) { a = 1; s = p / 4; }
				else s = p * Math.asin( 1 / a ) / ( 2 * Math.PI );
				if ( ( k *= 2 ) < 1 ) return - 0.5 * ( a * Math.pow( 2, 10 * ( k -= 1 ) ) * Math.sin( ( k - s ) * ( 2 * Math.PI ) / p ) );
				return a * Math.pow( 2, -10 * ( k -= 1 ) ) * Math.sin( ( k - s ) * ( 2 * Math.PI ) / p ) * 0.5 + 1;

			}

		},

		Back: {

			In: function ( k ) {

				var s = 1.70158;
				return k * k * ( ( s + 1 ) * k - s );

			},

			Out: function ( k ) {

				var s = 1.70158;
				return --k * k * ( ( s + 1 ) * k + s ) + 1;

			},

			InOut: function ( k ) {

				var s = 1.70158 * 1.525;
				if ( ( k *= 2 ) < 1 ) return 0.5 * ( k * k * ( ( s + 1 ) * k - s ) );
				return 0.5 * ( ( k -= 2 ) * k * ( ( s + 1 ) * k + s ) + 2 );

			}

		},

		Bounce: {

			In: function ( k ) {

				return 1 - TWEEN.Easing.Bounce.Out( 1 - k );

			},

			Out: function ( k ) {

				if ( k < ( 1 / 2.75 ) ) {

					return 7.5625 * k * k;

				} else if ( k < ( 2 / 2.75 ) ) {

					return 7.5625 * ( k -= ( 1.5 / 2.75 ) ) * k + 0.75;

				} else if ( k < ( 2.5 / 2.75 ) ) {

					return 7.5625 * ( k -= ( 2.25 / 2.75 ) ) * k + 0.9375;

				} else {

					return 7.5625 * ( k -= ( 2.625 / 2.75 ) ) * k + 0.984375;

				}

			},

			InOut: function ( k ) {

				if ( k < 0.5 ) return TWEEN.Easing.Bounce.In( k * 2 ) * 0.5;
				return TWEEN.Easing.Bounce.Out( k * 2 - 1 ) * 0.5 + 0.5;

			}

		}

	};

	TWEEN.Interpolation = {

		Linear: function ( v, k ) {

			var m = v.length - 1, f = m * k, i = Math.floor( f ), fn = TWEEN.Interpolation.Utils.Linear;

			if ( k < 0 ) return fn( v[ 0 ], v[ 1 ], f );
			if ( k > 1 ) return fn( v[ m ], v[ m - 1 ], m - f );

			return fn( v[ i ], v[ i + 1 > m ? m : i + 1 ], f - i );

		},

		Bezier: function ( v, k ) {

			var b = 0, n = v.length - 1, pw = Math.pow, bn = TWEEN.Interpolation.Utils.Bernstein, i;

			for ( i = 0; i <= n; i++ ) {
				b += pw( 1 - k, n - i ) * pw( k, i ) * v[ i ] * bn( n, i );
			}

			return b;

		},

		CatmullRom: function ( v, k ) {

			var m = v.length - 1, f = m * k, i = Math.floor( f ), fn = TWEEN.Interpolation.Utils.CatmullRom;

			if ( v[ 0 ] === v[ m ] ) {

				if ( k < 0 ) i = Math.floor( f = m * ( 1 + k ) );

				return fn( v[ ( i - 1 + m ) % m ], v[ i ], v[ ( i + 1 ) % m ], v[ ( i + 2 ) % m ], f - i );

			} else {

				if ( k < 0 ) return v[ 0 ] - ( fn( v[ 0 ], v[ 0 ], v[ 1 ], v[ 1 ], -f ) - v[ 0 ] );
				if ( k > 1 ) return v[ m ] - ( fn( v[ m ], v[ m ], v[ m - 1 ], v[ m - 1 ], f - m ) - v[ m ] );

				return fn( v[ i ? i - 1 : 0 ], v[ i ], v[ m < i + 1 ? m : i + 1 ], v[ m < i + 2 ? m : i + 2 ], f - i );

			}

		},

		Utils: {

			Linear: function ( p0, p1, t ) {

				return ( p1 - p0 ) * t + p0;

			},

			Bernstein: function ( n , i ) {

				var fc = TWEEN.Interpolation.Utils.Factorial;
				return fc( n ) / fc( i ) / fc( n - i );

			},

			Factorial: ( function () {

				var a = [ 1 ];

				return function ( n ) {

					var s = 1, i;
					if ( a[ n ] ) return a[ n ];
					for ( i = n; i > 1; i-- ) s *= i;
					return a[ n ] = s;

				};

			} )(),

			CatmullRom: function ( p0, p1, p2, p3, t ) {

				var v0 = ( p2 - p0 ) * 0.5, v1 = ( p3 - p1 ) * 0.5, t2 = t * t, t3 = t * t2;
				return ( 2 * p1 - 2 * p2 + v0 + v1 ) * t3 + ( - 3 * p1 + 3 * p2 - 2 * v0 - v1 ) * t2 + v0 * t + p1;

			}

		}

	};

	module.exports = TWEEN;


})()


},{}]},{},[1])