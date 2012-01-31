
qt = new QuadTree(6)
canvas = document.getElementById('test')
r = new Renderer(canvas, qt)

r.draw()

qt.put('alfa', 6, 4)
qt.put('bravo', 6, 4)
qt.put('charlie', 6, 4)
qt.put('delta', 6, 4)
qt.put('echo', 6, 4, 7, 5)
qt.put('foxtrot', 6, 4, 7, 5)
qt.put('golf', 6, 4)
qt.put('hotel', 2, 4)
qt.put('india', 6, 4)
qt.put('juliet', 6, 4)
qt.put('kilo', 6, 4)
qt.put('lima', 6, 4)
qt.put('m', 34, 2)
qt.put('n', 36, 4)
qt.put('oscar', 36, 4)
qt.put('p', 36, 4)
qt.put('q', 36, 4)
qt.put('romeo', 36, 4)
qt.put('sierra', 36, 4)
qt.put('tango', 36, 8)
qt.put('u', 36, 8)
qt.put('victor', 36, 8)
qt.put('whiskey', 36, 4)
qt.put('xray', 36, 4)
qt.put('yankee', 36, 4)
qt.put('zulu', 36, 4)

r.draw()