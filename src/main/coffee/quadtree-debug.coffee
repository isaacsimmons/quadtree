class NodeDebug extends Node
  constructor: (bounds, depth, quadtree) ->
    super(bounds, depth, quadtree)

  find: (q, res) =>
    throw "Search doesn't intersect node" if not @intersects(q)
    super(q, res)

  insert: (id, pos) =>
    throw "Position doesn't intersect node for insert" if not @intersects(pos)
    super(id, pos)

  remove: (id, pos) =>
    throw "Position doesn't intersect node for remove" if not @intersects(pos)
    throw "Item not found" if @leaf and not id in @items
    super(id, pos)

  makeLeaf: () =>
    throw "Calling makeLeaf on a leaf node" if @leaf
    throw "Calling makeLeaf on a node with too many items under it" if @numItems > (@quadtree.maxItems / 2)
    throw "Calling makeLeaf on a node without children" if @children.length != 4
    for own child in @children
      throw "Children of makeLeaf call should be leaves" if not child.leaf
    super()

  update: (id, oldpos, newpos) =>
    throw "oldpos doesn't intersect node for update" if not @intersects(oldpos)
    throw "newpos doesn't intersect node for update" if not @intersects(newpos)
    throw "Illegal state for old position" if @covers(oldpos) ^ id of @bigItems
    super(id, oldpos, newpos)

  createChildren: () =>
    @children = [
      new NodeDebug([@bounds[0], @bounds[1], @midPoint[0], @midPoint[1]], @depth + 1, @quadtree),
      new NodeDebug([@bounds[0], @midPoint[1], @midPoint[0], @bounds[3]], @depth + 1, @quadtree),
      new NodeDebug([@midPoint[0], @bounds[1], @bounds[2], @midPoint[1]], @depth + 1, @quadtree),
      new NodeDebug([@midPoint[0], @midPoint[1], @bounds[2], @bounds[3]], @depth + 1, @quadtree)
    ]

  makeBranch: () =>
    throw "Calling make branch on a branch node" if not @leaf
    throw "Calling make branch on a node with too few items" if @numItems <= @quadtree.maxItems
    throw "Calling makeBranch on a node that already has children" if @children.length > 0
    super()

class QuadTreeDebug extends QuadTree
  constructor: (@bounds, @maxDepth, @maxItems = 10) ->
    console.log('debug constructor')
    if @bounds[0] >= @bounds[2] or @bounds[1] >= @bounds[3]
      throw "Illegal bounding box for quadtree"
    @positions = {}
    @root = new NodeDebug(@bounds, 0, @)

  put: (id, minX, minY, maxX = minX, maxY = minY) =>
    throw "Illegal bounding box for put" if minX > maxX or minY > maxY
    throw "Coordinate out of bounds for put" if minX < @bounds[0] or minY < @bounds[1] or maxX >= @bounds[2] or maxY >= @bounds[3]
    super(id, minX, minY, maxX, maxY)

  find: (minX, minY, maxX = minX, maxY = minY) =>
    throw "Illegal bounding box for search" if minX > maxX or minY > maxY
    #TODO: should be safe to search outside of the tree area -- make sure that is true
    super(minX, minY, maxX, maxY)

  remove: (id) =>
    throw "Item not present in quadtree" if not id in @positions
    super(id)
