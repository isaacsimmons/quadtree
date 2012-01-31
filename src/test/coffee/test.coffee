
populate = (tree) ->
  tree.put('alfa', 6, 4)
  tree.put('bravo', 6, 4)
  tree.put('charlie', 6, 4)
  tree.put('delta', 6, 4)
  tree.put('echo', 6, 4, 7, 5)
  tree.put('foxtrot', 6, 4, 7, 5)
  tree.put('golf', 6, 4)
  tree.put('hotel', 2, 4)
  tree.put('india', 6, 4)
  tree.put('juliet', 6, 4)
  tree.put('kilo', 6, 4)
  tree.put('lima', 6, 4)

exports.testSearch = (test) ->
  qt = new QuadTree(6)
  ft = new FlatTree()

  populate(qt)
  populate(ft)

  test.ok(qt.find(6, 4).length == ft.find(6,4).length)

  test.done()

