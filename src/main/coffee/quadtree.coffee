intersects = (p1, p2) ->
  #TODO: double check edge conditions -- make sure I don't have p1 and p2 reversed
  #TODO: move this into Node?
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
    #TODO: not sure if I need numBigItems or not. Think about this when I start rolling empty quads back up into the parent

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
    #TODO: consider other options for this
    pos[0] <= @bounds[0] and pos[1] <= @bounds[1] and pos[2] >= @bounds[2] and pos[3] >= @bounds[3]

  insert: (id, pos) =>
    #TODO: remove these precondition checks
    throw "PRECONDITION: pos intersects node for insert" if not @intersects(pos)
    #PRECONDITION pos intersects
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
    throw "PRECONDITION: pos intersects node for remove" if not @intersects(pos)
    #PRECONDITION pos intersects
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

  update: (id, oldpos, newpos) =>
    throw "PRECONDITION: oldpos intersects node for update" if not @intersects(oldpos)
    throw "PRECONDITION: newpos intersects node for update" if not @intersects(newpos)
    #TODO: can just check presence in bigItems as shortcut for covers(oldpos)
    #TODO: these if/else branching trees can be cleaned up some once I know they work
    if @covers(oldpos)
      if @covers(newpos)
        #used to cover node, still does -- nothing to do
        @bigItems[id] = newpos
      else
        #used to cover, doesn't anymore
        delete @bigItems[id]
        @numBigItems -= 1
        @insert(id, newpos)
    else #not @covers(oldpos)
      if @covers(newpos)

        #didnt used to cover, does now
        @remove(id, oldpos)

        @bigItems[id] = newpos
        @numBigItems += 1
      else
        #didnt cover before, doesn't now
        if @leaf
          @items[id] = newpos
        else
          #TODO: check if I am a leaf //Same as previous -- @children will simply be empty
          for own child in @children
            if child.intersects(oldpos)
              if child.intersects(newpos)
                #intersected before, still does
                child.update(id, oldpos, newpos)
              else
                #intersected before, doesn't anymore
                child.remove(id, oldpos)
            else
              if child.intersects(newpos)
                #didn't used to intersect, does now -- insert
                child.insert(id, newpos)
              else
                #didnt intersect before, doesn't now -- nothing to do




  intersecttest: (pos) =>
    #TODO: write this, use in find/insert/update to reduce number of checks run
    #TODO: can I simplify somewhat if I know that intersects_self is true?
    [covers_self, intersects_child_0, intersects_child_1, intersects_child_2, intersects_child_3]
#    [intersect_self, covers_self, intersects_child_0, intersects_child_1, intersects_child_2, intersects_child_3]

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
    @numItems = 0
    @items = {}
    @insert(item, pos) for own item, pos of temp
    #TODO: do I need this temp assignment?
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
    @positions[id] = newPosition

    if oldPosition?
      @root.update(id, oldPosition, newPosition)
    else
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
    throw "Item not present in quadtree" if not id in @positions
    pos = @positions[id]
    delete @positions[id]
    @root.remove(id, pos)
    true
