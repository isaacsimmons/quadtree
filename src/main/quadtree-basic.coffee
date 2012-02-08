intersects = (p1, p2) ->
  #TODO: double check edge conditions -- make sure I don't have p1 and p2 reversed
  #TODO: maybe I should just use >= on both ends of the bounding box
  #TODO: move this into Node?
  p2[2] >= p1[0] and p2[0] < p1[2] and p2[3] >= p1[1] and p2[1] < p1[3]

#TODO: don't store positions in @items/@bigItems maps, just reference the pointers back in the quadtree
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
    for own id, pos of @bigItems
      res[id] = true
    for own id, pos of @items
      res[id] = true if intersects(pos, q)
    vals = @intersectTest(q)
    for own child, i in @children
      child.find(q, res) if vals[i]
    res

  insert: (id, pos) =>
    if @covers(pos)
      @bigItems[id] = pos
      return

    @numItems += 1

    if @leaf
      @items[id] = pos #TODO: I don't really need to store these here with the pointer back to the tree
      @makeBranch() if @numItems > @quadtree.maxItems and @depth < @quadtree.maxDepth
    else
      vals = @intersectTest(pos)
      for own child, i in @children
        child.insert(id, pos) if vals[i]
    true

  remove: (id, pos) =>
    if id of @bigItems
      #If the item is stored in our bigItems map, just remove it and we are done
      delete @bigItems[id]
      return

    @numItems -= 1

    if @leaf #If we are a leaf, it should be stored here
      delete @items[id]
    else #recurse to children
      vals = @intersectTest(pos)
      for own child, i in @children
        child.remove(id, pos) if vals[i]
      @makeLeaf() if @numItems <= (@quadtree.maxItems / 2)

  makeLeaf: () =>
    @leaf = true
    for own child in @children
      for own id, pos of child.bigItems
        @items[id] = pos #if not id in @items  #Not sure if I should bother with this if -- probably no slower to just overwrite
      for own id, pos of child.items
        @items[id] = pos
    @children = []

  update: (id, oldpos, newpos) =>
    #TODO: these if/else branching trees can be cleaned up some once I know they work
    if id of @bigItems #shortcut for @covers(oldpos)
      if @covers(newpos)
        #used to cover node, still does -- nothing to do
        @bigItems[id] = newpos
      else
        #used to cover, doesn't anymore
        delete @bigItems[id]
        @insert(id, newpos)
    else #not @covers(oldpos)
      if @covers(newpos)

        #didnt used to cover, does now
        @remove(id, oldpos)
        @bigItems[id] = newpos
      else
        #didnt cover before, doesn't now
        if @leaf
          @items[id] = newpos
        else
          oldVals = @intersectTest(oldpos)
          newVals = @intersectTest(newpos)

          for own child, i in @children
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
    #TODO: consider other options for this
    q[0] <= @bounds[0] and q[1] <= @bounds[1] and q[2] >= @bounds[2] and q[3] >= @bounds[3]

  intersectTest: (q) =>
    #TODO: write this, use in find/insert/update to reduce number of checks run
    #TODO: can I simplify somewhat if I know that intersects_self is true?
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

  createChildren: () =>
    [ new Node([@bounds[0], @bounds[1], @midPoint[0], @midPoint[1]], @depth + 1, @quadtree),
      new Node([@bounds[0], @midPoint[1], @midPoint[0], @bounds[3]], @depth + 1, @quadtree),
      new Node([@midPoint[0], @bounds[1], @bounds[2], @midPoint[1]], @depth + 1, @quadtree),
      new Node([@midPoint[0], @midPoint[1], @bounds[2], @bounds[3]], @depth + 1, @quadtree)
    ]

  makeBranch: () =>
    @leaf = false

    #create and insert new child nodes
    @children = @createChildren()

    #re-insert all items that were at this node
    @numItems = 0
    @insert(item, pos) for own item, pos of @items
    @items = {}

class QuadTree
  constructor: (@bounds, @maxDepth, @maxItems = 10) ->
    @positions = {}
    @root = new Node(@bounds, 0, @)

  put: (id, minX, minY, maxX = minX, maxY = minY) =>
    newPosition = [minX, minY, maxX, maxY]

    oldPosition = @positions[id]
    @positions[id] = newPosition

    if oldPosition?
      @root.update(id, oldPosition, newPosition)
    else
      @root.insert(id, newPosition)

  find: (minX, minY, maxX = minX, maxY = minY) =>
    @root.find([minX, minY, maxX, maxY], {})

  remove: (id) =>
    @root.remove(id, @positions[id])
    delete @positions[id]
