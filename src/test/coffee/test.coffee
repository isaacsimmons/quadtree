#More on nodeunit at https://github.com/caolan/nodeunit#readme

populate = (tree) ->
  tree.put('alfa', 6, 4, 7, 5)
  tree.put('bravo', 6, 4, 7, 5)
  tree.put('charlie', 6, 4, 7, 5)
  tree.put('delta', 6, 4, 7, 5)
  tree.put('echo', 6, 4, 7, 5)
  tree.put('foxtrot', 6, 4, 7, 5)
  tree.put('golf', 6, 4, 7, 5)
  tree.put('hotel', 2, 4, 3, 5)
  tree.put('india', 6, 4, 7, 5)
  tree.put('juliet', 6, 4, 7, 5)
  tree.put('kilo', 6, 4, 7, 5)
  tree.put('lima', 6, 4, 7, 5)

exports.testSearch = (test) ->
  qt = new QuadTreeDebug([0, 0, 30, 30], 6)
  ft = new FlatTree()

  populate(qt)
  populate(ft)

  test.equal(qt.find(6.5, 4.5).length, ft.find(6.5, 4.5).length, 'Wrong number of results returned from search')

  test.done()

