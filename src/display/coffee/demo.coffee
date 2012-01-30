
qt = new QuadTree(8)
canvas = document.getElementById('test')
r = new Renderer(canvas, qt, 2)

r.clear()
r.drawbox([5,5,10,10])