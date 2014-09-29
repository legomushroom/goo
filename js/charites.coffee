require './polyfills'
h      = require './helpers'
TWEEN  = require './vendor/tween'

class Circle
  constructor:(@o={})-> @vars(); @draw()

  vars:->
    @ctx = @o.ctx
    if !@ctx then console.error('nay! I need a conext'); return

    @radius = @o.radius or 50
    @x      = @o.x or 0
    @y      = @o.y or 0
    @fill   = @o.fill

  draw:->
    @ctx.beginPath()
    @ctx.arc(@x, @y, @radius, 0, 2*Math.PI, false)
    @ctx.fillStyle = @fill or '#222'
    @ctx.fill()
    # @ctx.stroke()

  set:(key, val)->
    if key isnt null and typeof key is 'object'
      for propName, propValue of key
        @[propName] = propValue
    if typeof key is 'string' then @[key] = val

    @draw()


class Goo
  constructor:(@o={})-> @vars(); @createCircles(); @run()

  vars:->
    @canvas = document.querySelector '#js-canvas'
    @ctx    = @canvas.getContext('2d')
    @width  = parseInt(@canvas.getAttribute('width'), 10)
    @height = parseInt(@canvas.getAttribute('height'), 10)
    @isDebug = true

  createCircles:->
    @circle1 = new Circle
      ctx: @ctx
      x: 200
      y: 200
      radius: 100
      # fill: '#DD2476'
      fill: '#222'
    @circle2 = new Circle
      ctx: @ctx
      x: 400
      y: 200
      radius: 100
      fill: '#222'
      # fill: '#12FFF7'
  
  gooCircles:(circle1, circle2)->
    if circle1.radius >= circle2.radius
      bigCircle = circle1
      smallCircle = circle2
    else
      bigCircle = circle2
      smallCircle = circle1

    if circle1.x >= circle2.x
      rightCircle = circle1
      leftCircle  = circle2
    else
      leftCircle  = circle1
      rightCircle = circle2

    leftCircleRight = leftCircle.x + leftCircle.radius
    rightCircleLeft = rightCircle.x - rightCircle.radius
    dx = Math.abs (leftCircleRight-rightCircleLeft)/2
    @ctx.beginPath()

    if leftCircleRight < rightCircleLeft then x = leftCircleRight + dx
    else x = leftCircleRight - dx
    centerLine =
      start: x: x, y: bigCircle.y - bigCircle.radius
      end:   x: x, y: bigCircle.y + bigCircle.radius

    curvePoints1 = @circleMath
      centerLine: centerLine
      circle:     circle2
      dir:        if circle2 isnt leftCircle then 'left'

    curvePoints2 = @circleMath
      centerLine: centerLine
      circle:     circle1
      dir:        if circle1 isnt leftCircle then 'left'

    curvePoints3 = @circleMath
      centerLine: centerLine
      circle:     circle2
      side:       'bottom'
      dir:        if circle2 isnt leftCircle then 'left'

    curvePoints4 = @circleMath
      centerLine: centerLine
      circle:     circle1
      side:       'bottom'
      dir:        if circle1 isnt leftCircle then 'left'

    @ctx.beginPath()
    @ctx.moveTo(curvePoints1.circlePoint.x,curvePoints1.circlePoint.y)
    x1 = curvePoints1.handlePoint.x
    y1 = curvePoints1.handlePoint.y
    x2 = curvePoints2.handlePoint.x
    y2 = curvePoints2.handlePoint.y
    x3 = curvePoints2.circlePoint.x
    y3 = curvePoints2.circlePoint.y
    @ctx.bezierCurveTo(x1,y1,x2,y2,x3,y3)

    @ctx.lineTo(curvePoints4.circlePoint.x,curvePoints4.circlePoint.y)
    x1 = curvePoints4.handlePoint.x
    y1 = curvePoints4.handlePoint.y
    x2 = curvePoints3.handlePoint.x
    y2 = curvePoints3.handlePoint.y
    x3 = curvePoints3.circlePoint.x
    y3 = curvePoints3.circlePoint.y
    @ctx.bezierCurveTo(x1,y1,x2,y2,x3,y3)


    @ctx.closePath()
    x1 = curvePoints1.circlePoint.x
    x2 = curvePoints4.circlePoint.x
    # grd = @ctx.createLinearGradient(x2,0,x1,0)
    # grd.addColorStop(0,'#DD2476')
    # grd.addColorStop(1,'#12FFF7')
    # @ctx.fillStyle = grd
    @ctx.fillStyle = if @isDebug then "rgba(34, 34, 34, 0.5)" else '#222'
    @ctx.fill()

  circleMath:(o)->
    @ctx.beginPath()
    deg = Math.PI/180

    if o.dir is 'left'
      dx = Math.abs o.circle.x - o.centerLine.start.x
    else
      dx = Math.abs o.circle.x - o.centerLine.start.x

    angleSize1 = (90+(dx/4))*deg; angleSize12 = angleSize1 + (1*deg)
    angleSize2 = (90-(dx/4))*deg; angleSize22 = angleSize2 + (1*deg)

    if o.side isnt 'bottom'
      if o.dir is 'left' then angle = -angleSize1; angle2 = -angleSize12
      else angle = -angleSize2; angle2 = -angleSize22
    else
      if o.dir is 'left' then angle = angleSize1; angle2 = angleSize12
      else angle = angleSize2; angle2 = angleSize22

    point1X = o.circle.x + (Math.cos(angle)*o.circle.radius)
    point1Y = o.circle.y + (Math.sin(angle)*o.circle.radius)
    point1X2 = o.circle.x + (Math.cos(angle2)*o.circle.radius)
    point1Y2 = o.circle.y + (Math.sin(angle2)*o.circle.radius)

    vector1 = point1Y - point1Y2
    vector2 = point1X - point1X2

    if o.side isnt 'bottom'
      dirAngle = if o.dir is 'left' then 180*deg else 0
    else
      dirAngle = if o.dir is 'left' then 180*deg else 0

    vectorAngle = Math.atan(vector1/vector2) + dirAngle

    radius = 2000 # !hardcode!

    pX = point1X + (Math.cos(vectorAngle)*radius)
    pY = point1Y + (Math.sin(vectorAngle)*radius)

    line1 =
      start: x: pX,      y: pY
      end:   x: point1X, y: point1Y

    intPoint = @intersection line1, o.centerLine

    # visualize
    if @isDebug
      @ctx.arc(point1X, point1Y, radius, 0, 2*Math.PI, false)

      @ctx.moveTo pX, pY
      @ctx.lineTo point1X, point1Y
      @ctx.stroke()

      @ctx.beginPath()
      @ctx.arc(intPoint.x, intPoint.y, 2, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'cyan'
      @ctx.fill()

      @ctx.beginPath()

      @ctx.arc(point1X, point1Y, 2, 0, 2*Math.PI, false)
      @ctx.arc(point1X2, point1Y2, 2, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'deeppink'
      @ctx.fill()
      
      @ctx.beginPath()
      @ctx.moveTo o.centerLine.start.x, o.centerLine.start.y
      @ctx.lineTo o.centerLine.end.x, o.centerLine.end.y
      @ctx.strokeStyle = '#ccc'
      @ctx.stroke()

    {
      handlePoint: x: intPoint.x, y: intPoint.y
      circlePoint: x: point1X, y: point1Y
    }

  intersection:(line1, line2)->
    result = {}
    dm1 = (line2.end.y - line2.start.y) * (line1.end.x - line1.start.x)
    dm2 = (line2.end.x - line2.start.x) * (line1.end.y - line1.start.y)
    denominator = dm1 - dm2
    return result if denominator is 0
    a = line1.start.y - line2.start.y
    b = line1.start.x - line2.start.x
    num1 = ((line2.end.x - line2.start.x)*a) - ((line2.end.y - line2.start.y)*b)
    num2 = ((line1.end.x - line1.start.x)*a) - ((line1.end.y - line1.start.y)*b)
    a = num1 / denominator
    b = num2 / denominator
    # if we cast these lines infinitely in both directions, they intersect here:
    result.x = line1.start.x + (a * (line1.end.x - line1.start.x))
    result.y = line1.start.y + (a * (line1.end.y - line1.start.y))
    # if line1 is a segment and line2 is infinite, they intersect if:
    result.onLine1 = true  if a > 0 and a < 1
    
    # if line2 is a segment and line1 is infinite, they intersect if:
    result.onLine2 = true  if b > 0 and b < 1
    
    result

  run:->
    it = @
    start  = 650
    offset = 500
    tween = new TWEEN.Tween({p:0}).to({p:1}, 50000)
      .onUpdate ->
        it.ctx.clear()
        it.circle2.draw()
        it.circle1.set
          x: start - @p*offset, y: it.circle1.y
        it.gooCircles it.circle1, it.circle2
      # .easing TWEEN.Easing.Elastic.Out
      .yoyo(true)
      .repeat(999)
      .start()
    h.startAnimationLoop()

new Goo

