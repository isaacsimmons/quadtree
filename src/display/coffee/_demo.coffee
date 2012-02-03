MAX_SIZE = 40
BUFFER = 5
MAX_ITEMS = 10
MAX_LEVELS = 6

NUM_CLUSTERS = 5
SMALL_PER_CLUSTER = 10
MEDIUM_PER_CLUSTER = 2
POINTS_PER_CLUSTER = 20

NUM_LARGE = 15

SMALL_RADIUS = 1
MEDIUM_RADIUS = 2
LARGE_RADIUS = 4
CLUSTER_RADIUS = 10

CLUSTER_CENTERS = []
CLUSTER_SPEEDS = []

POINTS = []
SMALL_BOXES = []
MEDIUM_BOXES = []
LARGE_BOXES = []

CLUSTER_SPEED = 1
SMALL_SPEED = 2
POINT_SPEED = 3

randomCoord = (buffer = 0) ->
  [Math.random() * (MAX_SIZE - buffer), Math.random() * (MAX_SIZE - buffer)]

randomDelta = (size) ->
  [Math.random() * 2 * size - size, Math.random() * 2 * size - size]

randomPosDelta = (size) ->
  [Math.random() * size, Math.random() * size]

sum = (v1, v2) ->
  [v1[0] + v2[0], v1[1], v2[1]]

add = (v1, v2) ->
  v1[0] += v2[0]
  v1[1] += v2[1]

initCoords = () ->
  for large in [0...NUM_LARGE]
    LARGE_BOXES[large] = randomCoord(LARGE_RADIUS)
  for cluster in [0...NUM_CLUSTERS]
    CLUSTER_CENTERS[cluster] = randomCoord(CLUSTER_RADIUS + MEDIUM_RADIUS)
    for point in [0...POINTS_PER_CLUSTER]
      POINTS[cluster * POINTS_PER_CLUSTER + point] = sum(CLUSTER_CENTERS[cluster], randomPosDelta(CLUSTER_RADIUS))
    for smallitem in [0...SMALL_PER_CLUSTER]
      SMALL_BOXES[cluster * SMALL_PER_CLUSTER + smallitem] = sum(CLUSTER_CENTERS[cluster], randomPosDelta(CLUSTER_RADIUS))
    for mediumitem in [0...MEDIUM_PER_CLUSTER]
      MEDIUM_BOXES[cluster * MEDIUM_PER_CLUSTER + mediumitem] = sum(CLUSTER_CENTERS[cluster], randomPosDelta(CLUSTER_RADIUS))
    heading = Math.random() * Math.PI * 2
    CLUSTER_SPEEDS[cluster] = [Math.sin(heading) * CLUSTER_SPEED, Math.cos(heading) * CLUSTER_SPEED]
  true

outOfRange = (p1, box, boxsize) ->
  p1[0] > box[0] + boxsize or p1[0] < box[0] or p1[1] > box[1] + boxsize or p1[1] < box[1]

driftCoords = () ->
  for cluster in [0...NUM_CLUSTERS]
    clusterDelta = CLUSTER_SPEEDS[cluster]
    add(CLUSTER_CENTERS[cluster], clusterDelta)
    if MEDIUM_RADIUS > CLUSTER_CENTERS[cluster][0] or CLUSTER_CENTERS[cluster][0] > MAX_SIZE - CLUSTER_RADIUS - MEDIUM_RADIUS or MEDIUM_RADIUS > CLUSTER_CENTERS[cluster][1] or CLUSTER_CENTERS[cluster][1] > MAX_SIZE - CLUSTER_RADIUS - MEDIUM_RADIUS
      CLUSTER_CENTERS[cluster] = randomCoord(CLUSTER_RADIUS + MEDIUM_RADIUS)
    for point in [0...POINTS_PER_CLUSTER]
      i = cluster * POINTS_PER_CLUSTER + point
      add(POINTS[i], randomDelta(POINT_SPEED))
      POINTS[i] = sum(CLUSTER_CENTERS[cluster], randomPosDelta(CLUSTER_RADIUS)) if outOfRange(POINTS[i], CLUSTER_CENTERS[cluster], CLUSTER_RADIUS)
    for smallitem in [0...SMALL_PER_CLUSTER]
      i = cluster * SMALL_PER_CLUSTER + smallitem
      add(SMALL_BOXES[i], randomDelta(SMALL_SPEED))
      SMALL_BOXES[i] = sum(CLUSTER_CENTERS[cluster], randomPosDelta(CLUSTER_RADIUS)) if outOfRange(SMALL_BOXES[i], CLUSTER_CENTERS[cluster], CLUSTER_RADIUS)
    for mediumitem in [0...MEDIUM_PER_CLUSTER]
      i = cluster * MEDIUM_PER_CLUSTER + mediumitem
      add(MEDIUM_BOXES[i], clusterDelta)
      MEDIUM_BOXES[i] = sum(CLUSTER_CENTERS[cluster], randomPosDelta(CLUSTER_RADIUS)) if outOfRange(MEDIUM_BOXES[i], CLUSTER_CENTERS[cluster], CLUSTER_RADIUS)
  true

storeCoords = () ->
  console.log('Storing Points...')
#  console.log(JSON.stringify(POINTS))
  for point, i in POINTS
    qt.put("point#{i}", point[0], point[1])
  console.log('Storing Small Boxes...')
  for sbox, si in SMALL_BOXES
    qt.put("small#{si}", sbox[0], sbox[1], sbox[0] + SMALL_RADIUS, sbox[1] + SMALL_RADIUS)
  console.log('Storing Medium Boxes...')
  for mbox, mi in MEDIUM_BOXES
    qt.put("medium#{mi}", mbox[0], mbox[1], mbox[0] + MEDIUM_RADIUS, mbox[1] + MEDIUM_RADIUS)
  console.log('Storing Large Boxes...')
  for lbox, li in LARGE_BOXES
    qt.put("large#{li}", lbox[0], lbox[1], lbox[0] + LARGE_RADIUS, lbox[1] + LARGE_RADIUS)

tick = () ->
  console.log('tick')
  driftCoords()
  storeCoords()
  if r?
    r.draw()
#    r.drawBox([cluster[0], cluster[1], cluster[0] + CLUSTER_RADIUS, cluster[1] + CLUSTER_RADIUS], 'green') for cluster in CLUSTER_CENTERS


qt = new QuadTree([0, 0, MAX_SIZE, MAX_SIZE], MAX_LEVELS, MAX_ITEMS)
canvas = document.getElementById('test')
r = if canvas? then new Renderer(canvas, qt) else null

initCoords()
tick()

setInterval(tick, 300)




