require './polyfills'
h      = require './helpers'
TWEEN  = require './vendor/tween'


# TODO:
#   change circle sizes on connection
#   GC fix
#   make it work on diff y
#     find a curve

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
    @ctx.fillStyle = @fill or '#999'
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
    @deg = Math.PI/180
    @isDebug = true

  createCircles:->
    @circle1 = new Circle
      ctx: @ctx
      x: 400
      y: 400
      radius: 75
      # fill: '#DD2476'
    @circle2 = new Circle
      ctx: @ctx
      x: 600
      y: 400
      radius: 100
      # fill: '#12FFF7'

    # @circle3 = new Circle
    #   ctx: @ctx
    #   x: 400
    #   y: 200
    #   radius: 75
    #   fill: '#222'
    #   # fill: '#12FFF7'
  
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

    if circle1.y >= circle2.y
      topCircle = circle1
      bottomCircle  = circle2
    else
      bottomCircle  = circle1
      topCircle = circle2

    # FIND FACE POINTS
    #   find the angle between two circles
    x = circle1.x - circle2.x
    y = circle1.y - circle2.y
    angle = Math.atan y/x
    #   find a angle shift for circle1 and circle2
    angleShift1 = if x > 0 then 180*@deg else 0
    angleShift2 = if x > 0 then 0 else 180*@deg
    point1 =
      x: circle1.x + Math.cos(angle+angleShift1)*circle1.radius
      y: circle1.y + Math.sin(angle+angleShift1)*circle1.radius
    point2 =
      x: circle2.x + Math.cos(angle+angleShift2)*circle2.radius
      y: circle2.y + Math.sin(angle+angleShift2)*circle2.radius
    if @isDebug
      @ctx.beginPath()
      @ctx.arc(point1.x, point1.y, 2, 0, 2*Math.PI, false)
      @ctx.arc(point2.x, point2.y, 2, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'deeppink'
      @ctx.fill()

    # FIND MIDDLE Line
    #   find middle point
    middlePoint =
      x: (point1.x + point2.x)/2
      y: (point1.y + point2.y)/2
    if @isDebug
      @ctx.beginPath()
      @ctx.arc(middlePoint.x, middlePoint.y, 2, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'cyan'
      @ctx.fill()
    #   find middle circle radius
    #   not necessary but nice
    dx = Math.abs point1.x - point2.x
    dy = Math.abs point1.y - point2.y
    radius = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2))/2
    radius = 2000
    if @isDebug
      @ctx.beginPath()
      @ctx.arc(middlePoint.x, middlePoint.y, radius, 0, 2*Math.PI, false)
      @ctx.strokeStyle = 'cyan'
      @ctx.lineWidth = .25
      @ctx.stroke()
    # find middle line
    middleLinePoint1 =
      x: middlePoint.x + Math.cos(angle+(90*@deg))*radius
      y: middlePoint.y + Math.sin(angle+(90*@deg))*radius
    middleLinePoint2 =
      x: middlePoint.x + Math.cos(angle+(-90*@deg))*radius
      y: middlePoint.y + Math.sin(angle+(-90*@deg))*radius
    if @isDebug
      @ctx.beginPath()
      @ctx.arc(middleLinePoint1.x, middleLinePoint1.y, 2, 0, 2*Math.PI, false)
      @ctx.arc(middleLinePoint2.x, middleLinePoint2.y, 2, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'orange'
      @ctx.fill()
    middleLine =
      start: middleLinePoint1
      end:   middleLinePoint2
      center: middlePoint
    if @isDebug
      @ctx.beginPath()
      @ctx.moveTo(middleLine.start.x, middleLine.start.y)
      @ctx.lineTo(middleLine.end.x, middleLine.end.y)
      @ctx.strokeStyle = 'orange'
      @ctx.stroke()

    curvePoints1 = @circleMath
      middleLine: middleLine
      circle:     circle1
      angle:      angle

    curvePoints2 = @circleMath
      middleLine: middleLine
      circle:     circle1
      angle:      angle
      side:       'top'

    curvePoints3 = @circleMath
      middleLine: middleLine
      circle:     circle2
      angle:      angle

    curvePoints4 = @circleMath
      middleLine: middleLine
      circle:     circle2
      angle:      angle
      side:       'top'

    # return if curvePoints3.handlePoint.y < curvePoints1.handlePoint.y
      
    @ctx.beginPath()
    @ctx.moveTo(curvePoints1.circlePoint.x,curvePoints1.circlePoint.y)
    x1 = curvePoints1.handlePoint.x
    y1 = curvePoints1.handlePoint.y
    x2 = curvePoints4.handlePoint.x
    y2 = curvePoints4.handlePoint.y
    x3 = curvePoints4.circlePoint.x
    y3 = curvePoints4.circlePoint.y
    @ctx.bezierCurveTo(x1,y1,x2,y2,x3,y3)

    @ctx.lineTo(curvePoints3.circlePoint.x,curvePoints3.circlePoint.y)
    x1 = curvePoints3.handlePoint.x
    y1 = curvePoints3.handlePoint.y
    x2 = curvePoints2.handlePoint.x
    y2 = curvePoints2.handlePoint.y
    x3 = curvePoints2.circlePoint.x
    y3 = curvePoints2.circlePoint.y
    @ctx.bezierCurveTo(x1,y1,x2,y2,x3,y3)
    @ctx.closePath()

    @ctx.fillStyle = if @isDebug then "rgba(255, 255, 255, 0.5)" else '#222'
    @ctx.fill()


  circleMath:(o)->
    circle = o.circle; angle  = o.angle; middleLine = o.middleLine
    side = o.side

    if @isDebug
      @ctx.beginPath()
      @ctx.arc(circle.x, circle.y, 2, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'cyan'
      @ctx.fill()

    dx = circle.x - middleLine.center.x

    point1Angle = if dx > 0 then angle else angle+(180*@deg)

    offsetAngle = if side is 'top' then (100*@deg) else -(100*@deg)

    point1 =
      x: circle.x + Math.cos(point1Angle+offsetAngle)*circle.radius
      y: circle.y + Math.sin(point1Angle+offsetAngle)*circle.radius

    point11 =
      x: circle.x + Math.cos(point1Angle+(1.01*offsetAngle))*circle.radius
      y: circle.y + Math.sin(point1Angle+(1.01*offsetAngle))*circle.radius

    dx = point1.x - point11.x
    dy = point1.y - point11.y
    intersectAngle = if middleLine.center.x - point1.x > 0
      Math.atan dy/dx
    else Math.atan(dy/dx) + 180*@deg

    line1 =
      start: point1
      end:   point11
    intPoint = @intersection line1, middleLine

    if @isDebug
      @ctx.beginPath()
      @ctx.arc(intPoint.x, intPoint.y, 2, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'yellow'
      @ctx.fill()

      @ctx.beginPath()
      @ctx.arc(point1.x, point1.y, 2, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'cyan'
      @ctx.fill()

      @ctx.beginPath()
      @ctx.arc(point11.x, point11.y, 1, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'cyan'
      @ctx.fill()

      @ctx.beginPath()
      @ctx.moveTo(point1.x, point1.y)
      @ctx.lineTo(intPoint.x, intPoint.y)
      @ctx.strokeStyle = 'yellow'
      @ctx.stroke()

    {
      handlePoint: x: intPoint.x, y: intPoint.y
      circlePoint: x: point1.x, y: point1.y
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
    # start  = 850
    # offset = 600
    angle = 5*360
    radius = 300
    # radiusOffset = 150
    radiusOffset = 0

    tween = new TWEEN.Tween({p:0}).to({p:1}, 200000)
      .onUpdate ->
        it.ctx.clear()
        it.circle2.draw()
        x = 600 + Math.cos(angle*it.deg*@p)*(radius-(radiusOffset*@p))
        y = 400 + Math.sin(angle*it.deg*@p)*(radius-(radiusOffset*@p))
        it.circle1.set
          x: x, y: y

        # it.circle3.set
        #   x: start - 200 - @p*offset, y: it.circle1.y

        it.gooCircles it.circle1, it.circle2
        # it.gooCircles it.circle2, it.circle3
      # .easing TWEEN.Easing.Elastic.Out
      .yoyo(true)
      .repeat(999)
      .start()
    h.startAnimationLoop()

new Goo

