intersects = (p1, p2) ->
  #TODO: double check edge conditions -- make sure I don't have p1 and p2 reversed
  #TODO: maybe I should just use >= on both ends of the bounding box
  #TODO: move this into Node?
  p2[2] >= p1[0] and p2[0] <= p1[2] and p2[3] >= p1[1] and p2[1] <= p1[3]

#TODO: normalize box to bottom level cells and don't bother recursing the tree on update if unchanged

class Node
  constructor: (@bounds, @depth, @quadtree) ->
    @midPoint = [(@bounds[0] + @bounds[2]) / 2, (@bounds[1] + @bounds[3]) / 2]

    @leaf = true
    @children = []

    @numItems = 0
    @items = {}
    @bigItems = {}


  find: (q, res) =>
    if DEBUG
      throw "Search doesn't intersect node" if not intersects(q, @bounds)
    for own id of @bigItems
      res[id] = true
    for own id of @items
      #TODO: if the query overlaps an item in multiple cells, I will waste time calling intersects repeatedly
      res[id] = true if intersects(@quadtree.positions[id], q)
    vals = @intersectTest(q)
    for child, i in @children
      child.find(q, res) if vals[i]
    res

  insert: (id, pos) =>
    if DEBUG
      throw "Position doesn't intersect node for insert" if not intersects(pos, @bounds)
    if @covers(pos)
      @bigItems[id] = true
      return

    @numItems += 1

    if @leaf
      @items[id] = true
      @makeBranch() if @numItems > @quadtree.maxItems and @depth < @quadtree.maxDepth
    else
      vals = @intersectTest(pos)
      for child, i in @children
        child.insert(id, pos) if vals[i]
    true

  remove: (id, pos) =>
    if DEBUG
      throw "Position doesn't intersect node for remove" if not intersects(pos, @bounds)
      throw "Item not found" if @leaf and not id in @items
    if id of @bigItems
      #If the item is stored in our bigItems map, just remove it and we are done
      delete @bigItems[id]
      return

    @numItems -= 1

    if @leaf #If we are a leaf, it should be stored here
      delete @items[id]
    else #recurse to children
      vals = @intersectTest(pos)
      for child, i in @children
        child.remove(id, pos) if vals[i]
      @makeLeaf() if @numItems <= (@quadtree.maxItems / 2)

  makeLeaf: () =>
    if DEBUG
      throw "Calling makeLeaf on a leaf node" if @leaf
      throw "Calling makeLeaf on a node with too many items under it" if @numItems > (@quadtree.maxItems / 2)
      throw "Calling makeLeaf on a node without children" if @children.length != 4
      for child in @children
        throw "Children of makeLeaf call should be leaves" if not child.leaf
    @leaf = true
    for child in @children
      for own id, pos of child.bigItems
        @items[id] = true
      for own id, pos of child.items
        @items[id] = true
    @children = []

  update: (id, oldpos, newpos) =>
    if DEBUG
      throw "oldpos doesn't intersect node for update" if not intersects(oldpos, @bounds)
      throw "newpos doesn't intersect node for update" if not intersects(newpos, @bounds)
      throw "Illegal state for old position" if @covers(oldpos) ^ id of @bigItems
    #TODO: these if/else branching trees can be cleaned up some once I know they work
    if id of @bigItems #shortcut for @covers(oldpos)
      if not @covers(newpos)
        #used to cover, doesn't anymore
        delete @bigItems[id]
        @insert(id, newpos)
    else #not @covers(oldpos)
      if @covers(newpos)

        #didnt used to cover, does now
        @remove(id, oldpos)
        @bigItems[id] = true
      else
        #didnt cover before, doesn't now
        if not @leaf
          oldVals = @intersectTest(oldpos)
          newVals = @intersectTest(newpos)

          for child, i in @children
            if oldVals[i]
              if newVals[i]
                #intersected before, still does
                child.update(id, oldpos, newpos)
              else
                #intersected before, doesn't anymore
                child.remove(id, oldpos)
            else if newVals[i]
              #didn't used to intersect, does now -- insert
              child.insert(id, newpos)

  covers: (q) =>
    q[0] <= @bounds[0] and q[1] <= @bounds[1] and q[2] >= @bounds[2] and q[3] >= @bounds[3]

  intersectTest: (q) =>
    #Assumes that intersects self is true
    lowX = q[0] < @midPoint[0]
    highX = q[2] >= @midPoint[0]
    lowY = q[1] < @midPoint[1]
    highY = q[3] >= @midPoint[1]
    [ lowX and lowY,
      lowX and highY,
      highX and lowY,
      highX and highY
    ]

  makeBranch: () =>
    if DEBUG
      throw "Calling make branch on a branch node" if not @leaf
      throw "Calling make branch on a node with too few items" if @numItems <= @quadtree.maxItems
      throw "Calling makeBranch on a node that already has children" if @children.length > 0

    @leaf = false

    #create and insert new child nodes
    @children = [
      new Node([@bounds[0], @bounds[1], @midPoint[0], @midPoint[1]], @depth + 1, @quadtree),
      new Node([@bounds[0], @midPoint[1], @midPoint[0], @bounds[3]], @depth + 1, @quadtree),
      new Node([@midPoint[0], @bounds[1], @bounds[2], @midPoint[1]], @depth + 1, @quadtree),
      new Node([@midPoint[0], @midPoint[1], @bounds[2], @bounds[3]], @depth + 1, @quadtree)
    ]

    #re-insert all items that were at this node
    @numItems = 0
    @insert(item, @quadtree.positions[item]) for own item of @items
    @items = {}

class QuadTree
  constructor: (@bounds, @maxDepth, @maxItems = 10) ->
    throw "Illegal bounding box for quadtree" if @bounds[0] >= @bounds[2] or @bounds[1] >= @bounds[3]
    @positions = {}
    @root = new Node(@bounds, 0, @)

  put: (id, minX, minY, maxX = minX, maxY = minY) =>
    throw "Illegal bounding box for put" if minX > maxX or minY > maxY
    throw "Coordinate out of bounds for put" if minX < @bounds[0] or minY < @bounds[1] or maxX > @bounds[2] or maxY > @bounds[3]

    newPosition = [minX, minY, maxX, maxY]

    oldPosition = @positions[id]
    @positions[id] = newPosition

    if oldPosition?
      @root.update(id, oldPosition, newPosition)
    else
      @root.insert(id, newPosition)

  find: (minX, minY, maxX = minX, maxY = minY) =>
    throw "Illegal bounding box for search" if minX > maxX or minY > maxY
    #TODO: should be safe to search outside of the tree area -- make sure that is true
    @root.find([minX, minY, maxX, maxY], {})

  remove: (id) =>
    throw "Item not present in quadtree" if not id in @positions
    @root.remove(id, @positions[id])
    delete @positions[id]
