MAX_ITEMS = 10

BOTTOM_LEFT = 0
BOTTOM_RIGHT = 1
TOP_LEFT = 2
TOP_RIGHT = 3

SPACES = ['', ' ', '  ', '   ', '    ', '     ', '      ', '       ', '        ']

class Node
  constructor: (@minX, @minY, @level, @parent = null) ->
    #TODO: do I care about the parent pointer?
    size = Math.pow(2, level)
    @midX = @minX + size / 2
    @midY = @minY + size / 2
    @maxX = @minX + size
    @maxY = @minY + size

    @children = []
    @items = {}
    @numItems = 0
    @numBigItems = 0
    @leaf = true

  find: (pos) =>
    ret = []
    if @leaf
      ret.push(@) if @intersects(pos)
    else
      ret.concat(child.find(pos)) for own child in @children
    ret

  intersects: (pos) =>
    pos[2] >= @minX and pos[0] < @maxX and pos[3] >= @minY and pos[1] < @maxY

  covers: (pos) =>
    pos[0] < @midX and pos[1] < @minY and pos[2] >= @midX and pos[3] >= @midY

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
    @children[BOTTOM_LEFT] = new Node(@minX, @minY, nextLevel, @)
    @children[BOTTOM_RIGHT] = new Node(@midX, @minY, nextLevel, @)
    @children[TOP_LEFT] = new Node(@minX, @midY, nextLevel, @)
    @children[TOP_RIGHT] = new Node(@midX, @midY, nextLevel, @)

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

    @positions = {}

    @root = new Node(0, 0, @numLevels)

  normalizeX: (x) =>
    Math.floor((x - @minX) / @xScale)

  normalizeY: (y) =>
    Math.floor((y - @minY) / @yScale)

  normalize: (minX, minY, maxX, maxY) =>
    [@normalizeX(minX), @normalizeY(minY), @normalizeX(maxX), @normalizeY(maxY)]

  put: (id, minX, minY, maxX = minX, maxY = minY) =>
    if minX < @minX or minY < @minY or maxX >= (@minX + @sizeX) or maxY >= (@minY + @sizeY)
      throw "coordinate out of bounds for quadtree"
    oldPosition = @positions[id]
    newPosition = @normalize(minX, minY, maxX, maxY)
    if oldPosition?
      console.log("removing old position")
    @positions[id] = newPosition
    @root.insert(id, newPosition)

  remove: (id) =>
    pos = @positions[id]
    throw "Item not present in quadtree" if not pos?
    @root.remove(pos)