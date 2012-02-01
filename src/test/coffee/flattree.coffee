class FlatTree
  constructor: () ->
    @items = {}

  intersects: (p1, p2) ->
    p2[2] >= p1[0] and p2[0] < p1[2] and p2[3] >= p1[1] and p2[1] < p1[3]

  put: (id, minX, minY, maxX = minX, maxY = minY) =>
    @items[id] = [minX, minY, maxX, maxY]

  remove: (id) =>
    delete @items[id]

  find: (minX, minY, maxX = minX, maxY = minY) =>
    q = [minX, minY, maxX, maxY]
    ret = []
    for own id, pos of @items
      ret.push(id) if @intersects(q, pos)
    ret


