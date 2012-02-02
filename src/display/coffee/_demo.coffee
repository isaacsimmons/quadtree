
qt = new QuadTree([0, 0, 40, 40], 6, 1)
canvas = document.getElementById('test')
r = new Renderer(canvas, qt)

offset = 0

moveBoxes = () ->
  offset += 2
  console.log("Moving boxes (offset: #{offset})")
  qt.put('alfa', 6, 4 + offset, 21, 21 + offset)
#  qt.put('bravo', 6, 4 + offset, 21, 21 + offset)
#  qt.put('charlie', 6, 4 + offset, 21, 21 + offset)
#  qt.put('delta', 6, 4 + offset, 21, 21 + offset)
#  qt.put('echo', 6, 4 + offset, 7, 5 + offset)
#  qt.put('foxtrot', 6, 4 + offset, 7, 5 + offset)
#  qt.put('golf', 6, 4 + offset, 21, 21 + offset)
#  qt.put('hotel', 2, 4 + offset, 21, 21 + offset)
#  qt.put('india', 6, 4 + offset, 21, 21 + offset)
#  qt.put('juliet', 6, 4 + offset, 21, 21 + offset)
#  qt.put('kilo', 6, 4 + offset, 21, 21 + offset)
#  qt.put('juliet1', 16 + offset, 8, 31, 25 + offset)
#  qt.put('kilo1', 16, 8 + offset, 31, 25 + offset)
#  qt.put('juliet2', 16, 8 + offset, 31, 25 + offset)
#  qt.put('kilo2', 16, 8 + offset, 31, 25 + offset)
#  qt.put('juliet3', 16, 8 + offset, 31, 25 + offset)
#  qt.put('kilo3', 16, 8 + offset, 31, 25 + offset)
#  qt.put('juliet4', 16, 8 + offset, 31, 25 + offset)
#  qt.put('kilo4', 16, 8 + offset, 31, 25 + offset)
  qt.put('lima', 6, 4 + offset, 21, 21 + offset)
  r.draw()
#  printTree(qt)

removeBoxes = () ->
  console.log("Removing boxes")
  qt.remove('alfa')
#  qt.remove('bravo')
#  qt.remove('charlie')
#  qt.remove('delta')
#  qt.remove('echo')
#  qt.remove('foxtrot')
#  qt.remove('golf')
#  qt.remove('hotel')
#  qt.remove('india')
#  qt.remove('juliet')
#  qt.remove('kilo')
#  qt.remove('juliet1')
#  qt.remove('kilo1')
#  qt.remove('juliet2')
#  qt.remove('kilo2')
#  qt.remove('juliet3')
#  qt.remove('kilo3')
#  qt.remove('juliet4')
#  qt.remove('kilo4')
  qt.remove('lima')
  r.draw()
#  printTree(qt)

DEFAULT_POINT = [1.4, 2.3]

movePoints = () ->
  offset += 2
  console.log("Moving points (offset: #{offset})")
  for num in [0...1]
    qt.put("point#{num}", DEFAULT_POINT[0], DEFAULT_POINT[1] + offset)
  r.draw()
#  printTree(qt)


moveBoxes()

setTimeout(moveBoxes, 1000)
setTimeout(moveBoxes, 2000)
setTimeout(moveBoxes, 3000)
setTimeout(moveBoxes, 4000)
setTimeout(moveBoxes, 5000)
setTimeout(moveBoxes, 6000)

#setTimeout(removeBoxes, 7000)


#setTimeout(movePoints, 1000)
#setTimeout(movePoints, 2000)
#setTimeout(movePoints, 3000)
#setTimeout(movePoints, 4000)
#setTimeout(movePoints, 5000)
#setTimeout(movePoints, 6000)

