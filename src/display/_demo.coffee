TREE_PROPS =
  MAX_SIZE: 100
  MAX_ITEMS: 7
  MAX_LEVELS: 6

FRAMERATE = 20

qt = new QuadTree([0, 0, TREE_PROPS.MAX_SIZE, TREE_PROPS.MAX_SIZE], TREE_PROPS.MAX_LEVELS, TREE_PROPS.MAX_ITEMS)

canvas = document.getElementById('test')
r = if canvas? then new Renderer(canvas, qt) else null
scenario = new Scenario(TREE_PROPS.MAX_SIZE)
scenario.sizes['cluster'] = 20

tick = () ->
  scenario.driftCoords()
  scenario.storeCoords(qt)
  r.draw() if r?

tickId = null

pause = () ->
  if tickId?
    clearInterval(tickId)
    tickId = null
  else
    tickId = setInterval(tick, 1000/FRAMERATE)

print = () ->
  out = document.getElementById('output')
  out.innerHTML = "TREE:<br/>"
  (out.innerHTML += line + "<br/>") for line in printTree(qt)

document.getElementById('pause').onclick = pause
document.getElementById('print').onclick = print

scenario.initCoords()
scenario.storeCoords(qt)
r.draw() if r?
