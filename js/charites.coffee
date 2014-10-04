require './polyfills'
h      = require './helpers'
TWEEN  = require './vendor/tween'


# TODO:
#   change circle sizes on connection
#   GC fix
#   make it work on diff y


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
    @circle2 = new Circle
      ctx: @ctx
      x: 600
      y: 400
      radius: 100
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
    

    # FIND MIDDLE Line
    #   find middle point
    middlePoint =
      x: (point1.x + point2.x)/2
      y: (point1.y + point2.y)/2
    
    #   find middle circle radius
    dx = Math.abs point1.x - point2.x
    dy = Math.abs point1.y - point2.y
    radius = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2))/2
    

    # find middle line
    middleLinePoint1 =
      x: middlePoint.x + Math.cos(angle+(90*@deg))*radius
      y: middlePoint.y + Math.sin(angle+(90*@deg))*radius
    middleLinePoint2 =
      x: middlePoint.x + Math.cos(angle+(-90*@deg))*radius
      y: middlePoint.y + Math.sin(angle+(-90*@deg))*radius

    
    dX = circle1.x - circle2.x
    dY = circle1.y - circle2.y

    len = Math.sqrt Math.pow(dX, 2) + Math.pow(dY, 2)
    reactDistance = ((circle1.radius + circle2.radius)/2)

    distance = (1 - reactDistance/len)
    isRadiusIntX = point1.x - point2.x < 0
    isCirclesIntX = circle1.x - circle2.x < 0
    isRadiusIntY = point1.y - point2.y < 0
    isCirclesIntY = circle1.y - circle2.y < 0
    # console.log isRadiusInt ^ isCirclesInt
    isIntersectX = isRadiusIntX ^ isCirclesIntX
    isIntersectY = isRadiusIntY ^ isCirclesIntY
    isIntersect = isIntersectX or isIntersectY

    if @isDebug and !isIntersect
      @ctx.beginPath()
      @ctx.arc(point1.x, point1.y, 2, 0, 2*Math.PI, false)
      @ctx.arc(point2.x, point2.y, 2, 0, 2*Math.PI, false)
      @ctx.fillStyle = 'deeppink'
      @ctx.fill()

    if isIntersect
      intPoints = @circlesIntersecton circle2, circle1
      middleLinePoint1 = x: intPoints[0], y: intPoints[2]
      middleLinePoint2 = x: intPoints[1], y: intPoints[3]

      # y = middleLinePoint1.y - circle2.y
      # x = circle2.x - middleLinePoint1.x
      # angle = Math.atan2 y, x

      # y = middleLinePoint2.y - circle2.y
      # x = circle2.x - middleLinePoint2.x
      # angle2 = Math.atan2 y, x
      # # console.log (angle*180)/Math.PI

      # if @isDebug
      #   @ctx.beginPath()
      #   x = circle2.x + Math.cos(angle-(25*@deg)-(180*@deg))*circle2.radius
      #   y = circle2.y + Math.sin(angle-(25*@deg)-(180*@deg))*circle2.radius
      #   x2 = circle2.x + Math.cos(angle2+(25*@deg)-(180*@deg))*circle2.radius
      #   y2 = circle2.y + Math.sin(angle2+(25*@deg)-(180*@deg))*circle2.radius
      #   @ctx.arc(x, y, 2, 0, 2*Math.PI, false)
      #   @ctx.arc(x2, y2, 2, 0, 2*Math.PI, false)
      #   @ctx.fillStyle = 'yellow'
      #   @ctx.fill()

      middlePoint =
        x: (middleLinePoint1.x + middleLinePoint2.x)/2
        y: (middleLinePoint1.y + middleLinePoint2.y)/2

      if @isDebug
        @ctx.beginPath()
        @ctx.arc(middleLinePoint1.x, middleLinePoint1.y, 2, 0, 2*Math.PI, false)
        @ctx.arc(middleLinePoint2.x, middleLinePoint2.y, 2, 0, 2*Math.PI, false)
        @ctx.fillStyle = 'deeppink'
        @ctx.fill()
    else
      if @isDebug
        @ctx.beginPath()
        @ctx.arc(middleLinePoint1.x, middleLinePoint1.y, 2, 0, 2*Math.PI, false)
        @ctx.arc(middleLinePoint2.x, middleLinePoint2.y, 2, 0, 2*Math.PI, false)
        @ctx.fillStyle = 'orange'
        @ctx.fill()

      if @isDebug
        @ctx.beginPath()
        @ctx.arc(middlePoint.x, middlePoint.y, radius, 0, 2*Math.PI, false)
        @ctx.strokeStyle = 'cyan'
        @ctx.lineWidth = .25
        @ctx.stroke()

      if @isDebug
        @ctx.beginPath()
        @ctx.arc(middlePoint.x, middlePoint.y, 2, 0, 2*Math.PI, false)
        @ctx.fillStyle = 'cyan'
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

    # console.log distance
    # distance = Math.max distance, 0

    if @isDebug and !isIntersect
      @ctx.beginPath()
      @ctx.arc(middlePoint.x, middlePoint.y, reactDistance, 0, 2*Math.PI, false)
      @ctx.strokeStyle = 'yellow'
      @ctx.stroke()

    curvePoints1 = @circleMath
      middleLine: middleLine
      circle:     circle1
      angle:      angle
      distance:   distance
      isIntersect: isIntersect

    curvePoints2 = @circleMath
      middleLine: middleLine
      circle:     circle1
      angle:      angle
      side:       'top'
      distance:   distance
      isIntersect: isIntersect

    curvePoints3 = @circleMath
      middleLine: middleLine
      circle:     circle2
      angle:      angle
      distance:   distance
      isIntersect: isIntersect
      isRight: true

    curvePoints4 = @circleMath
      middleLine: middleLine
      circle:     circle2
      angle:      angle
      side:       'top'
      distance:   distance
      isIntersect: isIntersect
      isRight: true
    
    if reactDistance < radius then return


    # if !isIntersect
    #   @ctx.beginPath()
    #   @ctx.moveTo(curvePoints1.circlePoint.x,curvePoints1.circlePoint.y)
    #   x1 = curvePoints1.handlePoint.x
    #   y1 = curvePoints1.handlePoint.y
    #   x2 = curvePoints4.handlePoint.x
    #   y2 = curvePoints4.handlePoint.y
    #   x3 = curvePoints4.circlePoint.x
    #   y3 = curvePoints4.circlePoint.y
    #   @ctx.bezierCurveTo(x1,y1,x2,y2,x3,y3)

    #   @ctx.lineTo(curvePoints3.circlePoint.x,curvePoints3.circlePoint.y)
    #   x1 = curvePoints3.handlePoint.x
    #   y1 = curvePoints3.handlePoint.y
    #   x2 = curvePoints2.handlePoint.x
    #   y2 = curvePoints2.handlePoint.y
    #   x3 = curvePoints2.circlePoint.x
    #   y3 = curvePoints2.circlePoint.y
    #   @ctx.bezierCurveTo(x1,y1,x2,y2,x3,y3)
    #   @ctx.closePath()

    #   @ctx.fillStyle = if @isDebug then "rgba(255, 255, 255, 0.5)" else '#999'
    #   @ctx.fill()
    if isIntersect
      @ctx.beginPath()
      @ctx.moveTo(curvePoints1.circlePoint.x,curvePoints1.circlePoint.y)
      x1 = curvePoints1.handlePoint.x
      y1 = curvePoints1.handlePoint.y
      x2 = curvePoints3.handlePoint.x
      y2 = curvePoints3.handlePoint.y
      x3 = curvePoints3.circlePoint.x
      y3 = curvePoints3.circlePoint.y
      @ctx.bezierCurveTo(x1,y1,x2,y2,x3,y3)

      @ctx.lineTo(curvePoints4.circlePoint.x,curvePoints4.circlePoint.y)
      x1 = curvePoints4.handlePoint.x
      y1 = curvePoints4.handlePoint.y
      x2 = curvePoints2.handlePoint.x
      y2 = curvePoints2.handlePoint.y
      x3 = curvePoints2.circlePoint.x
      y3 = curvePoints2.circlePoint.y
      @ctx.bezierCurveTo(x1,y1,x2,y2,x3,y3)
      @ctx.closePath()

      @ctx.fillStyle = if @isDebug then "rgba(255, 255, 255, 0.5)" else '#999'
      @ctx.fill()


  circleMath:(o)->
    circle = o.circle; angle  = o.angle; middleLine = o.middleLine
    side = o.side; dist = o.distance; isSmall = o.isSmall
    isInt = o.isIntersect; isRight = o.isRight

    if !isInt
      dx = circle.x - middleLine.center.x
      point1Angle = if dx > 0 then angle else angle+(180*@deg)
      offset = 0
      handlesAngle = if dist > 0 then 45*dist else 0

      absOffsetAngle = (90+(offset)+(handlesAngle))*@deg
      offsetAngle = if side is 'top' then absOffsetAngle else -absOffsetAngle

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
        @ctx.arc(circle.x, circle.y, 2, 0, 2*Math.PI, false)
        @ctx.fillStyle = 'cyan'
        @ctx.fill()

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

      return {
        handlePoint: x: intPoint.x, y: intPoint.y
        circlePoint: x: point1.x, y: point1.y
      }
    else
      angle = 15*@deg
      if side is 'top'
        point = middleLine.start
        angleOffset = angle
      else
        point = middleLine.end
        angleOffset = -angle

      if isRight then angleOffset = -angleOffset

      y = point.y - circle.y
      x = circle.x - point.x
      angle = Math.atan2 y, x

      point1Angle = angle+angleOffset-(180*@deg)
      point1 =
        x: circle.x + Math.cos(point1Angle)*circle.radius
        y: circle.y + Math.sin(point1Angle)*circle.radius

      point11 =
        x: circle.x + Math.cos(1.01*point1Angle)*circle.radius
        y: circle.y + Math.sin(1.01*point1Angle)*circle.radius

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
        @ctx.arc(circle.x, circle.y, 2, 0, 2*Math.PI, false)
        @ctx.fillStyle = 'cyan'
        @ctx.fill()

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

      return {
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

  circlesIntersecton: (circle1, circle2) ->
    x0 = circle1.x; y0 = circle1.y; r0 = circle1.radius
    x1 = circle2.x; y1 = circle2.y; r1 = circle2.radius
    # dx and dy are the vertical and horizontal distances between
    #   * the circle centers.

    dx = x1 - x0
    dy = y1 - y0
    
    # Determine the straight-line distance between the centers.
    d = Math.sqrt((dy * dy) + (dx * dx))
    
    # Check for solvability.
    
    # no solution. circles do not intersect.
    return false  if d > (r0 + r1)
    
    # no solution. one circle is contained in the other
    return false  if d < Math.abs(r0 - r1)
    
    # 'point 2' is the point where the line through the circle
    #   * intersection points crosses the line between the circle
    #   * centers.
    
    # Determine the distance from point 0 to point 2.
    a = ((r0 * r0) - (r1 * r1) + (d * d)) / (2.0 * d)
    
    # Determine the coordinates of point 2.
    x2 = x0 + (dx * a / d)
    y2 = y0 + (dy * a / d)
    
    # Determine the distance from point 2 to either of the
    #   * intersection points.
    h = Math.sqrt((r0 * r0) - (a * a))
    
    # Now determine the offsets of the intersection points from
    #   * point 2.

    rx = -dy * (h / d)
    ry = dx * (h / d)
    
    # Determine the absolute intersection points.
    xi = x2 + rx
    xi_prime = x2 - rx
    yi = y2 + ry
    yi_prime = y2 - ry
    [
      xi
      xi_prime
      yi
      yi_prime
    ]

  run:->
    it = @
    start  = 400
    offset = 400
    angle = 5*360
    radius = 365
    radiusOffset = 349
    # radiusOffset = 0

    tween = new TWEEN.Tween({p:0}).to({p:1}, 50000)
      .onUpdate ->
        it.ctx.clear()
        it.circle2.draw()
        # it.circle1.draw()
        # x = 600 + Math.cos(angle*it.deg*@p)*(radius-(radiusOffset*@p))
        # y = 400 + Math.sin(angle*it.deg*@p)*(radius-(radiusOffset*@p))
        it.circle1.set
          x: start+(offset*@p), y: it.circle1.y

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

