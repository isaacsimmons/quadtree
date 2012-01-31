MAX_ITEMS = 10

intersects = (p1, p2) ->
  #TODO: double check edge conditions -- make sure I don't have p1 and p2 reversed
  p2[2] >= p1[0] and p2[0] < p1[2] and p2[3] >= p1[1] and p2[1] < p1[3]

#TODO: better name
intersects2 = (p1, p2) ->
  p2[2] >= p1[0] and p2[0] <= p1[2] and p2[3] >= p1[1] and p2[1] <= p1[3]


class Node
  constructor: (@minX, @minY, @level, @parent = null) ->
    #TODO: do I care about the parent pointer?
    size = Math.pow(2, level)
    @midX = @minX + size / 2
    @midY = @minY + size / 2
    @maxX = @minX + size
    @maxY = @minY + size
    @pos = [@minX, @minY, @maxX, @maxY]

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
    intersects(pos, @pos)

  covers: (pos) =>
    pos[0] < @midX and pos[1] < @midY and pos[2] >= @midX and pos[3] >= @midY

  insert: (id, pos) =>
    if @covers(pos)
      @bigItems[id] = pos
      @numBigItems += 1
    else if @leaf
      @items[id] = pos
      @numItems += 1
      @makeBranch() if @numItems > MAX_ITEMS and @level > 0
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
    nextLevel = @level - 1
    @children = []
    @children[0] = new Node(@minX, @minY, nextLevel, @)
    @children[1] = new Node(@midX, @minY, nextLevel, @)
    @children[2] = new Node(@minX, @midY, nextLevel, @)
    @children[3] = new Node(@midX, @midY, nextLevel, @)

    #re-insert all items that were at this node
    temp = @items
    @items = {}
    @insert(item, pos) for own item, pos of temp
    true

class QuadTree
  constructor: (@numLevels, @minX, @minY, @sizeX, @sizeY) ->
    pow = Math.pow(2, @numLevels)

    #some defaults if constructor is called with only one arg
    @minX = 0 if not @minX?
    @minY = 0 if not @minY?
    @sizeX = pow if not @sizeX?
    @sizeY = pow if not @sizeY?

    @xScale = @sizeX / pow
    @yScale = @sizeY / pow

    @positions = {} #TODO: nodes need to keep normalized positions. Not sure quadtree does as well
    @rawPositions = {}

    @root = new Node(0, 0, @numLevels)

  normalize: (pos) =>
    [ Math.floor((pos[0] - @minX) / @xScale),
      Math.floor((pos[1] - @minY) / @yScale),
      Math.floor((pos[2] - @minX) / @xScale),
      Math.floor((pos[3] - @minY) / @yScale)
    ]

  put: (id, minX, minY, maxX = minX, maxY = minY) =>
    if minX < @minX or minY < @minY or maxX >= (@minX + @sizeX) or maxY >= (@minY + @sizeY)
      throw "coordinate out of bounds for quadtree"
    newPosition = [minX, minY, maxX, maxY]
    norm = @normalize(newPosition)
    @rawPositions[id] = newPosition
    oldPosition = @positions[id]
    if oldPosition?
      if norm is oldPosition
        console.log('new position is same as old')
        return
      console.log("removing old position")
      #TODO: could be much more efficient than remove + reinsert
      @root.remove(id, oldPosition)
    @positions[id] = norm
    @root.insert(id, norm)

  find: (minX, minY, maxX = minX, maxY = minY) =>
    pos = [minX, minY, maxX, maxY]
    norm = @normalize(pos)
    filter = []
    @root.find(norm, filter)
    ret = []
    console.log("Got #{filter.length} candidate matches")
    for own id in filter
      ret.push(id) if intersects2(@rawPositions[id], pos)
    console.log("#{ret.length} matched")
    ret

  remove: (id) =>
    pos = @positions[id]
    delete @positions[id]
    delete @rawPositions[id]
    throw "Item not present in quadtree" if not pos?
    @root.remove(pos)
