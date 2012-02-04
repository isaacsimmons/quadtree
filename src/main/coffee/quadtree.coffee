intersects = (p1, p2) ->
  #TODO: double check edge conditions -- make sure I don't have p1 and p2 reversed
  #TODO: move this into Node?
  p2[2] >= p1[0] and p2[0] < p1[2] and p2[3] >= p1[1] and p2[1] < p1[3]

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
      res.push(id)# if intersects(pos, q) #TODO: make sure this really isn't necessary

    for own id, pos of @items
      res.push(id) if intersects(pos, q)

    for own child in @children
      child.find(q, res) if child.intersects(q)

    res

  intersects: (q) =>
    intersects(q, @bounds)

  covers: (q) =>
    #TODO: consider other options for this
    q[0] <= @bounds[0] and q[1] <= @bounds[1] and q[2] >= @bounds[2] and q[3] >= @bounds[3]

  insert: (id, pos) =>
    throw "PRECONDITION: pos intersects node for insert" if not @intersects(pos)

    #TODO: should numItems *not* count bigItems?
    if @covers(pos)
      @bigItems[id] = pos
      return

    @numItems += 1

    if @leaf
      @items[id] = pos #TODO: I don't really need to store these here with the pointer back to the tree
      @makeBranch() if @numItems > @quadtree.maxItems and @depth < @quadtree.maxDepth
    else
      for own child in @children
        child.insert(id, pos) if child.intersects(pos)
    true

  remove: (id, pos) =>
    throw "PRECONDITION: pos intersects node for remove" if not @intersects(pos)

    if id of @bigItems
      #If the item is stored in our bigItems map, just remove it and we are done
      delete @bigItems[id]
      return

    @numItems -= 1

    if @leaf
      #If we are a leaf, it should be stored here
      throw "Item not found" if not id in @items
      delete @items[id]
      #TODO: check if this needs to be rolled back up into its parent
    else
      #recurse to children
      for own child in @children
        child.remove(id, pos) if child.intersects(pos)
      @makeLeaf() if @numItems <= (@quadtree.maxItems / 2)

  makeLeaf: () =>
    throw "CALLING makeLeaf on a leaf node" if @leaf
    throw "CALLING makeLeaf on a node with too many items under it" if @numItems > (@quadtree.maxItems / 2)
    @leaf = true
    for own child in @children

      child.makeLeaf() if not child.leaf  #TODO: still not sure that I understand how this condition ever happens
      for own id, pos of child.bigItems
        @items[id] = pos #if not id in @items  #Not sure if I should bother with this if -- probably no slower to just overwrite
      for own id, pos of child.items
        @items[id] = pos
    @children = []

  update: (id, oldpos, newpos) =>
    throw "PRECONDITION: oldpos intersects node for update" if not @intersects(oldpos)
    throw "PRECONDITION: newpos intersects node for update" if not @intersects(newpos)
    #TODO: can just check presence in bigItems as shortcut for covers(oldpos)
    #TODO: these if/else branching trees can be cleaned up some once I know they work
    if @covers(oldpos)
      if @covers(newpos)
        #used to cover node, still does -- nothing to do
        throw "ILLEGAL STATE: UPDATE COVERS" if id not of @bigItems
        @bigItems[id] = newpos
      else
        #used to cover, doesn't anymore
        throw "ILLEGAL STATE: UPDATE COVERS 2" if id not of @bigItems
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
          #TODO: check if I am a leaf //Same as previous -- @children will simply be empty
          for own child in @children
            if child.intersects(oldpos)
              if child.intersects(newpos)
                #intersected before, still does
                child.update(id, oldpos, newpos)
              else
                #intersected before, doesn't anymore
                child.remove(id, oldpos)
            else if child.intersects(newpos)
              #didn't used to intersect, does now -- insert
              child.insert(id, newpos)


  intersecttest: (q) =>
    #TODO: write this, use in find/insert/update to reduce number of checks run
    #TODO: can I simplify somewhat if I know that intersects_self is true?
    [covers_self, intersects_child_0, intersects_child_1, intersects_child_2, intersects_child_3]
#    [intersect_self, covers_self, intersects_child_0, intersects_child_1, intersects_child_2, intersects_child_3] //Nah, always intersects self?

  makeBranch: () =>
    #turn node into a branch node
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
    @insert(item, pos) for own item, pos of @items
    @items = {}
    true

class QuadTree
  constructor: (@bounds, @maxDepth, @maxItems = 10) ->
    if @bounds[0] >= @bounds[2] or @bounds[1] >= @bounds[3]
      throw "Illegal bounding box for quadtree"
    @positions = {}
    @root = new Node(@bounds, 0, @)

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

    @root.find([minX, minY, maxX, maxY], [])

  remove: (id) =>
    throw "Item not present in quadtree" if not id in @positions
    @root.remove(id, @positions[id])
    delete @positions[id]
