class FlatTree
  constructor: () ->
    @items = {}

  intersects: (p1, p2) ->
    #TODO: move this into Node?
    if p1.length is 2
      if p2.length is 2
        return p1[0] is p2[0] and p1[1] is p2[1]
      else
        return p1[0] >= p2[0] and p1[0] <= p2[2] and p1[1] >= p2[1] and p1[1] <= p2[3]
    else
      if p2.length is 2
        return p2[0] >= p1[0] and p2[0] <= p1[2] and p2[1] >= p1[1] and p2[1] <= p1[3]
      else
        return p2[2] >= p1[0] and p2[0] <= p1[2] and p2[3] >= p1[1] and p2[1] <= p1[3]

  put: (id, pos) =>
    @items[id] = pos

  remove: (id) =>
    delete @items[id]

  find: (q) =>
    ret = {}
    for own id, pos of @items
      ret[id] = true if @intersects(q, pos)
    ret


