MAX_ITEMS = 10

intersects = (p1, p2) ->
  #TODO: double check edge conditions -- make sure I don't have p1 and p2 reversed
  p2[2] >= p1[0] and p2[0] < p1[2] and p2[3] >= p1[1] and p2[1] < p1[3]

class Node
  constructor: (@bounds, @depth, @quadtree, @parent) ->
    #TODO: do I care about the parent pointer? (certainly not until I start deleting nodes)
    @midX = (@bounds[0] + @bounds[2]) / 2
    @midY = (@bounds[1] + @bounds[3]) / 2

    @children = []

    @items = {}
    @numItems = 0

    @bigItems = {}
    @numBigItems = 0

    @leaf = true

  find: (pos, res) =>
    for own id of @bigItems
      res.push(id) if (intersects(@quadtree.positions[id], pos))
    if @leaf
      for own id of @items
        res.push(id) if (intersects(@quadtree.positions[id], pos))
    else
      for own child in @children
        child.find(pos, res) if child.intersects(pos)
    res

  intersects: (pos) =>
    intersects(pos, @bounds)

  covers: (pos) =>
    #TODO: this needs to be something based on the relative size, not whether or not it covers (maybe in addition to a covers-type-metric?)
    pos[0] < @midX and pos[1] < @midY and pos[2] >= @midX and pos[3] >= @midY

  insert: (id, pos) =>
    if @covers(pos)
      @bigItems[id] = pos
      @numBigItems += 1
    else if @leaf
      @items[id] = pos #TODO: I don't really need to store these here with the pointer back to the tree
      @numItems += 1
      @makeBranch() if @numItems > @quadtree.maxItems and @depth < @quadtree.maxDepth
    else
      for own child in @children
        #TODO: by doing the x and y checks here instead of child.intersects, I can save half of the comparisons
        child.insert(id, pos) if child.intersects(pos)

    remove: (id, pos) =>
      if id in @bigItems
        #If the item is stored in our bigItems map, just remove it and we are done
        delete @bigItems[id]
        @numBigItems -= 1
      else if @leaf
        #If we are a leaf, it should be stored here
        throw "Item not found" if not id in @items
        delete @items[id]
        @numItems -= 1
        #TODO: check if this needs to be rolled back up into its parent
      else
        #recurse to children
        for own child in @children
          child.remove(id, pos) if child.intersects(pos)

    #TODO: update (is that a node or a quadtree method?)

  makeBranch: () =>
    #turn node into a branch node
    @leaf = false

    #create and insert new child nodes
    @children = [
      new Node([@bounds[0], @bounds[1], @midX, @midY], @depth + 1, @quadtree, @),
      new Node([@bounds[0], @midY, @midX, @bounds[3]], @depth + 1, @quadtree, @),
      new Node([@midX, @bounds[1], @bounds[2], @midY], @depth + 1, @quadtree, @),
      new Node([@midX, @midY, @bounds[2], @bounds[3]], @depth + 1, @quadtree, @)
    ]

    #re-insert all items that were at this node
    temp = @items
    #TODO: might not need to move this map to temp
    @items = {}
    @insert(item, pos) for own item, pos of temp
    true

class QuadTree
  constructor: (@bounds, @maxDepth, @maxItems = 10) ->
    if @bounds[0] >= @bounds[2] or @bounds[1] >= @bounds[3]
      throw "Illegal bounding box for quadtree"
    @positions = {}
    @root = new Node(@bounds, 0, @, null)

  put: (id, minX, minY, maxX = minX, maxY = minY) =>
    #Repair ordering if passed in incorrectly
    [minX, maxX] = [maxX, minX] if minX > maxX
    [minY, maxY] = [maxY, minY] if minY > maxY

    if minX < @bounds[0] or minY < @bounds[1] or maxX >= @bounds[2] or maxY >= @bounds[3]
      throw "coordinate out of bounds for quadtree"

    newPosition = [minX, minY, maxX, maxY]
    oldPosition = @positions[id]
    if oldPosition?
      console.log("removing old position")
      #TODO: could be much more efficient than remove + reinsert
      @root.remove(id, oldPosition)
    @positions[id] = newPosition
    @root.insert(id, newPosition)

  find: (minX, minY, maxX = minX, maxY = minY) =>
    #Repair ordering if passed in incorrectly
    [minX, maxX] = [maxX, minX] if minX > maxX
    [minY, maxY] = [maxY, minY] if minY > maxY

    #TODO: should be safe to search outside of the tree area -- make sure that is true

    ret = []
    @root.find([minX, minY, maxX, maxY], ret)
    console.log("#{ret.length} matches")
    ret

  remove: (id) =>
    throw "Item not present in quadtree" if not id in positions
    pos = @positions[id]
    delete @positions[id]
    @root.remove(pos)
    true
