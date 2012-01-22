SIZE = 100
MAX_LEVEL = 6
MAX_ITEMS = 10

BOTTOM_LEFT = 0
BOTTOM_RIGHT = 1
TOP_LEFT = 2
TOP_RIGHT = 3

SPACES = ['', ' ', '  ', '   ', '    ', '     ', '      ', '       ', '        ']


class Point
  constructor: (@x, @y) ->

  print: () =>
    console.log('POINT (' + @x + ', ' + @y + ')')


class Node
  constructor: (@minX, @minY, @level) ->
    size = Math.pow(0.5, @level) * SIZE
    @midX = @minX + (size / 2)
    @midY = @minX + (size / 2)
    @maxX = @minX + size
    @maxY = @minX + size
    @children = []
    @leaf = true

  makeLeaf: () =>
    @leaf = true
    #TODO: digest existing child nodes

  makeBranch: () =>
    #cache current child items
    items = @children

    #turn node into a leaf node
    @leaf = false
    @children = []

    #create and insert new child nodes
    nextLevel = @level + 1
    @children[BOTTOM_LEFT] = new Node(@minX, @minY, nextLevel)
    @children[BOTTOM_RIGHT] = new Node(@midX, @minY, nextLevel)
    @children[TOP_LEFT] = new Node(@minX, @midY, nextLevel)
    @children[TOP_RIGHT] = new Node(@midX, @midY, nextLevel)

    #re-insert all items that were at this node
    @insert(item) for own item in items
    true

  contains: (p) =>
    @minX >= p.x > @maxX and @minY >= p.y > @maxY

  find: (p) =>
    if @leaf
      @
    else
      x = p.x >= @midX
      y = p.y >= @midY
      @children[x + 2 * y].find(p)


  insert: (p) =>
    if @leaf
      @children.push(p)
      @makeBranch() if @children.length > MAX_ITEMS and @level < MAX_LEVEL
    else
      x = p.x >= @midX
      y = p.y >= @midY
      @children[x + 2 * y].insert(p)

  print: () =>
    if @leaf
      console.log('[LEAF ' + @level + '] ')
    else
      console.log('[BRANCH ' + @level + '] ')
    console.log("x = [#{@minX} #{@maxX}) y = [#{@minY} #{@maxY})")
    item.print() for item in @children
