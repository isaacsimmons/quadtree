qt = new QuadTree(6)

#console.log(root.find(4, 5))

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
#root.insert(new Point(2, 3))
#root.insert(new Point(2, 3))
#root.insert(new Point(2, 3))
#root.insert(new Point(2, 3))
#root.insert(new Point(2, 3))
#root.insert(new Point(2, 3))
#root.insert(new Point(2, 3))
#root.insert(new Point(2, 3))
#root.insert(new Point(2, 4))
#root.insert(new Point(2, 30))
#
printTree(qt)

console.log(JSON.stringify(qt.find(7,5)))
#
#console.log(toKey(10, 5))
#console.log(toKey(90, 5))
#console.log(toKey(45, 36))

#
#console.log(JSON.stringify(qt.normalize(20, 30)))