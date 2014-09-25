require './polyfills'
h      = require './helpers'
TWEEN  = require './vendor/tween'

class Circle
  constructor:(@o={})->
    @vars()
    @draw()
  vars:->
    @ctx = @o.ctx
    if !@ctx then console.error('nay! I need a conext'); return

    @radius = @o.radius or 50
    @x = @o.x or 0
    @y = @o.y or 0

  draw:->
    @ctx.beginPath()
    @ctx.arc(@x, @y, @radius, 0, 2*Math.PI, false)

    @ctx.fillStyle = @fill or '#222'
    @ctx.fill()

  set:(key, val)->
    if key isnt null and typeof key is 'object'
      for propName, propValue of key
        @[propName] = propValue
    if typeof key is 'string' then @[key] = val

    @draw()


class Goo
  constructor:(@o={})->
    @vars()
    @createCircles()
    @run()

  vars:->
    @canvas = document.querySelector '#js-canvas'
    @ctx    = @canvas.getContext('2d')
    @width  = parseInt(@canvas.getAttribute('width'), 10)
    @height = parseInt(@canvas.getAttribute('height'), 10)

  createCircles:->
    @circle1 = new Circle
      ctx: @ctx
      x: 200
      y: 200
      radius: 50
    @circle2 = new Circle
      ctx: @ctx
      x: 400
      y: 200
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

    leftCircleRight = leftCircle.x + leftCircle.radius
    rightCircleLeft = rightCircle.x - rightCircle.radius
    x = Math.abs (leftCircleRight-rightCircleLeft)/2
    @ctx.beginPath()
    @ctx.moveTo leftCircleRight + x, bigCircle.y - bigCircle.radius
    @ctx.lineTo leftCircleRight + x, bigCircle.y + bigCircle.radius
    @ctx.strokeStyle = '#ccc'
    @ctx.stroke()

    @ctx.beginPath()
    # x = centerX + cos(angle)*radius
    # y = centerY + sin(angle)*radius
    deg = Math.PI/180
    angle = -120*deg; angle2 = -125*deg
    point1X = circle2.x + (Math.cos(angle)*circle2.radius)
    point1Y = circle2.y + (Math.sin(angle)*circle2.radius)
    point1X2 = circle2.x + (Math.cos(angle2)*circle2.radius)
    point1Y2 = circle2.y + (Math.sin(angle2)*circle2.radius)

    vector1 = point1Y - point1Y2
    vector2 = point1X - point1X2
    vectorAngle = Math.atan(vector1/vector2) - 180*deg

    radius = 200 # !hardcode!
    @ctx.arc(point1X, point1Y, radius, 0, 2*Math.PI, false)

    pX = point1X + (Math.cos(vectorAngle)*radius)
    pY = point1Y + (Math.sin(vectorAngle)*radius)

    @ctx.moveTo pX, pY
    @ctx.lineTo point1X, point1Y

    @ctx.stroke()

    line1 =
      start: x: pX,      y: pY
      end:   x: point1X, y: point1Y
    line2 =
      start: x: leftCircleRight+x, y: bigCircle.y - bigCircle.radius
      end:   x: leftCircleRight+x, y: bigCircle.y + bigCircle.radius

    intPoint = @intersection line1, line2
    console.log intPoint

    @ctx.beginPath()
    @ctx.arc(intPoint.x, intPoint.y, 2, 0, 2*Math.PI, false)
    @ctx.fillStyle = 'cyan'
    @ctx.fill()

    @ctx.beginPath()

    @ctx.arc(point1X, point1Y, 4, 0, 2*Math.PI, false)
    @ctx.arc(point1X2, point1Y2, 2, 0, 2*Math.PI, false)

    @ctx.fillStyle = 'deeppink'
    @ctx.fill()

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
    tween = new TWEEN.Tween({p:0}).to({p:1}, 105000)
      .onUpdate ->
        it.ctx.clear()
        it.circle1.set
          x: 200 + @p*200, y: it.circle1.y
        it.circle2.draw()
        it.gooCircles it.circle1, it.circle2
      .yoyo(true)
      .repeat(999)
      .start()
    h.startAnimationLoop()

new Goo

