MAX_ITEMS = 10

intersects = (p1, p2) ->
  #TODO: double check edge conditions -- make sure I don't have p1 and p2 reversed
  p2[2] >= p1[0] and p2[0] < p1[2] and p2[3] >= p1[1] and p2[1] < p1[3]

#TODO: better name
intersects2 = (p1, p2) ->
  p2[2] >= p1[0] and p2[0] <= p1[2] and p2[3] >= p1[1] and p2[1] <= p1[3]

class Node
  constructor: (minX, minY, maxX, maxY, @depth, @parent = null) ->
    #TODO: do I care about the parent pointer? (certainly not until I start deleting nodes)
    @midX = (minX + maxX) / 2
    @midY = (minY + maxY) / 2
    @bounds = [minX, minY, maxX, maxY]

    @children = []

    @items = {}
    @numItems = 0

    @bigItems = {}
    @numBigItems = 0

    @leaf = true

  find: (pos, res) =>
    res.push(id) for own id of @bigItems
    if @leaf
      res.push(id) for own id of @items
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
      @items[id] = pos
      @numItems += 1
      @makeBranch() if @numItems > MAX_ITEMS and @depth > 0
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
    #TODO: do I need to store the un-normalized bounding box?

  makeBranch: () =>
    #turn node into a leaf node
    @leaf = false

    #create and insert new child nodes
    nextdepth = @depth - 1
    @children = []
    @children[0] = new Node(@bounds[0], @bounds[1], @midX, @midY, nextdepth, @)
    @children[1] = new Node(@bounds[0], @midY, @midX, @bounds[3], nextdepth, @)
    @children[2] = new Node(@midX, @bounds[1], @bounds[2], @midY, nextdepth, @)
    @children[3] = new Node(@midX, @midY, @bounds[2], @bounds[3], nextdepth, @)

    #re-insert all items that were at this node
    temp = @items
    #TODO: might not need to move this map to temp
    @items = {}
    @insert(item, pos) for own item, pos of temp
    true

class QuadTree
  constructor: (@numLevels, minX, minY, maxX, maxY) ->
    @bounds = [minX, minY, maxX, maxY]
    @positions = {}
    @root = new Node(minX, minY, maxX, maxY, @numLevels)

  put: (id, minX, minY, maxX = minX, maxY = minY) =>
    if minX < @minX or minY < @minY or maxX >= (@minX + @sizeX) or maxY >= (@minY + @sizeY)
      throw "coordinate out of bounds for quadtree"
    newPosition = [minX, minY, maxX, maxY]
    oldPosition = @positions[id]
    if oldPosition?
      if newPosition is oldPosition
        console.log('new position is same as old')
        #TODO: really, I want to check if it is still contained within the same boxes, not if it is identical
        return
      console.log("removing old position")
      #TODO: could be much more efficient than remove + reinsert
      @root.remove(id, oldPosition)
    @positions[id] = newPosition
    @root.insert(id, newPosition)

  find: (minX, minY, maxX = minX, maxY = minY) =>
    pos = [minX, minY, maxX, maxY]
    filter = []
    @root.find(pos, filter)
    ret = []
    console.log("Got #{filter.length} candidate matches")
    for own id in filter
      ret.push(id) if intersects2(@positions[id], pos)
    console.log("#{ret.length} matched")
    ret

  remove: (id) =>
    throw "Item not present in quadtree" if not id in positions
    pos = @positions[id]
    delete @positions[id]
    @root.remove(pos)
