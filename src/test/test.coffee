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

queryPoints = (t1, t2, test) ->
  for i in [0...100]
    px = Math.random() * (MAX_SIZE - QUERY_SIZE)
    py = Math.random() * (MAX_SIZE - QUERY_SIZE)
    q = [px, py, px + QUERY_SIZE, py + QUERY_SIZE]
    test.deepEqual(t1.find(q[0], q[1], q[2], q[3]), t2.find(q[0], q[1], q[2], q[3]), 'Wrong results returned from search')

exports.testSearch = (test) ->
  s = new Scenario(MAX_SIZE)
  qt = new QuadTree([0, 0, MAX_SIZE, MAX_SIZE], 6)
  ft = new FlatTree()

  s.initCoords()

  for i in [0...500]
    s.driftCoords()
    s.storeCoords(qt)
    s.storeCoords(ft)
    validate(test, qt)


#  s.storeCoords(qt)
#  s.storeCoords(ft)

  queryPoints(qt, ft, test)
  test.done()

