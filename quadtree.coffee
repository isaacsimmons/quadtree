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
    @leaf = true

  find: (pos) =>
    ret = []
    if @leaf
      ret.push(@) if @intersects(pos)
    else
      ret.concat(child.find(pos)) for own child in @children
    ret

  intersects: (pos) =>
    (pos[2] >= @minX and pos[0] < @maxX) and (pos[3] >= @minY and pos[1] < @maxY)

  insert: (id, pos) =>
    if @leaf
      @items[id] = pos
      @numItems += 1
      @makeBranch() if @numItems > MAX_ITEMS and @level > 0
    else
      for own child in @children
        #TODO: by doing the x and y intersect checks here instead of recursing the children, I can save half of the comparisons
        child.insert(id, pos) if child.intersects(pos)


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
    @insert(item, pos) for own item, pos of @items
    @items = {}
    true

  print: (indent = 0) =>
    if @leaf
      console.log(SPACES[indent] + "[LEAF #{@level}]: [#{@minX} #{@maxX}), [#{@minY} #{@maxY})")
      console.log(SPACES[indent] + "  #{id} @ (#{pos[0]} #{pos[1]} #{pos[2]} #{pos[3]})") for own id, pos of @items
    else
      console.log(SPACES[indent] + "[BRANCH #{@level}]: [#{@minX} #{@maxX}), [#{@minY} #{@maxY})")
      child.print(indent + 1) for own child in @children

class QuadTree
  constructor: (@numLevels, @minX, @minY, @sizeX, @sizeY) ->
    pow = Math.pow(2, @numLevels)

    #some defaults if constructor is called with only one arg
    @minX = -pow / 2 if not @minX?
    @minY = -pow / 2 if not @minY?
    @sizeX = pow if not @sizeX?
    @sizeY = pow if not @sizeY?

    @xScale = @sizeX / pow
    @yScale = @sizeY / pow

    @positions = {}

    @root = new Node(0, 0, @numLevels)

  normalizeX: (x) =>
    #TODO: clip these to the legal range?
    Math.floor((x - @minX) / @xScale)

  normalizeY: (y) =>
    #TODO: clip these to the legal range?
    Math.floor((y - @minY) / @yScale)

  normalize: (minX, minY, maxX, maxY) =>
    [@normalizeX(minX), @normalizeY(minY), @normalizeX(maxX), @normalizeY(maxY)]

#  find: (minX, minY, maxX = minX, maxY = minY) =>

  put: (id, minX, minY, maxX = minX, maxY = minY) =>
    oldPosition = @positions[id]
    newPosition = @normalize(minX, minY, maxX, maxY)
    if oldPosition?
      console.log("removing old position")
    @positions[id] = newPosition
    @root.insert(id, newPosition)

  print: () =>
    @root.print(0)

#    Bitwise AND 	a & b 	Returns a one in each bit position for which the corresponding bits of both operands are ones.
#      Bitwise OR 	a | b 	Returns a one in each bit position for which the corresponding bits of either or both operands are ones.
#      Bitwise XOR 	a ^ b 	Returns a one in each bit position for which the corresponding bits of either but not both operands are ones.
#      Bitwise NOT 	~ a 	Inverts the bits of its operand.
#  Left shift 	a << b 	Shifts a in binary representation b (< 32) bits to the left, shifting in zeros from the right.
#  Sign-propagating right shift 	a >> b 	Shifts a in binary representation b (< 32) bits to the right, discarding bits shifted off.
#Zero-fill right shift 	a >>> b 	Shifts a in binary representation b (< 32) bits to the right, discarding bits shifted off, and shifting in zeros from the left.
