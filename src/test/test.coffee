#More on nodeunit at https://github.com/caolan/nodeunit#readme

MAX_SIZE = 50
QUERY_SIZE = 10

validate = (test, qt) ->
  validateNode(test, qt, qt.root)

validateNode = (test, qt, node) ->
  test.ok(node.children.length is (if node.leaf then 0 else 4))

  test.ok(node.covers(qt.positions[item])) for own item of node.bigItems
  test.ok(intersects(qt.positions[item], node.bounds)) for own item of node.items

  validateNode(test, qt, child) for child in node.children

queryPointsTest = (t1, t2, test) ->
  for i in [0...100]
    px = Math.random() * (MAX_SIZE - QUERY_SIZE)
    py = Math.random() * (MAX_SIZE - QUERY_SIZE)
    q = [px, py, px + QUERY_SIZE, py + QUERY_SIZE]
    test.deepEqual(t1.find(q[0], q[1], q[2], q[3]), t2.find(q[0], q[1], q[2], q[3]), 'Wrong results returned from search')

queryPoints = (qt) ->
  for i in [0...100]
    px = Math.random() * (MAX_SIZE - QUERY_SIZE)
    py = Math.random() * (MAX_SIZE - QUERY_SIZE)
    qt.find(px, py, px + QUERY_SIZE, py + QUERY_SIZE)

exports.testSimulation = (test) ->
  s = new Scenario(MAX_SIZE)
  qt = new QuadTree([0, 0, MAX_SIZE, MAX_SIZE], 6)
  ft = new FlatTree()

  s.initCoords()

  for i in [0...100]
    s.driftCoords()
    s.storeCoords(qt)
    s.storeCoords(ft)
    validate(test, qt)

  queryPointsTest(qt, ft, test)
  test.done()


exports.testSpeed = (test) ->
  s = new Scenario(MAX_SIZE)
  qt = new QuadTree([0, 0, MAX_SIZE, MAX_SIZE], 6)

  s.initCoords()

  for i in [0...250]
    s.driftCoords()
    s.storeCoords(qt)
    queryPoints(qt)

  test.done()


exports.testEdgeCases = (test) ->
  qt = new QuadTree([-2, -2, 2, 2], 1, 1)
  qt.put('a', -1, -1, 0, 0)
  qt.put('b', 0, 0, 1, 1)
  qt.put('c', 0, 0)

  test.ok('a' of qt.find(-1, -1))
  test.ok('b' not of qt.find(-1, -1))
  test.ok('c' not of qt.find(-1, -1))
  test.ok('a' of qt.find(0, 0))
  test.ok('b' of qt.find(0, 0))
  test.ok('c' of qt.find(0, 0))
  test.ok('a' of qt.find(0, 0, 1, 1))
  test.ok('b' of qt.find(0, 0, 1, 1))
  test.ok('c' of qt.find(0, 0, 1, 1))
  test.ok('a' not of qt.find(1, 1))
  test.ok('b' of qt.find(1, 1))
  test.ok('c' not of qt.find(1, 1))
  test.done()
