class Scenario
  constructor: (@maxSize) ->
    @counts = {cluster: 5, large: 15, medium: 3, small: 10, point: 20}
    @speeds = {cluster: 1, small: 2, point: 3}
    @sizes = {small: 1, medium: 2, large: 4, cluster: 10}

    @clusters = []
    @clusterSpeeds = []
    
    @points = []
    @small = []
    @medium = []
    @large = []


  randomCoord: (buffer = 0) ->
    [Math.random() * (@maxSize - buffer), Math.random() * (@maxSize - buffer)]

  randomDelta: (size) ->
    [Math.random() * 2 * size - size, Math.random() * 2 * size - size]

  randomPosDelta: (size) ->
    [Math.random() * size, Math.random() * size]

  sum: (v1, v2) ->
    [v1[0] + v2[0], v1[1] + v2[1]]

  add: (v1, v2) ->
    v1[0] += v2[0]
    v1[1] += v2[1]

  initCoords: () =>
    for large in [0...@counts['large']]
      @large[large] = @randomCoord(@sizes['large'])
    for cluster in [0...@counts['cluster']]
      @clusters[cluster] = @randomCoord(@sizes['cluster'] + @sizes['medium'])
      heading = Math.random() * Math.PI * 2
      @clusterSpeeds[cluster] = [Math.sin(heading) * @speeds['cluster'], Math.cos(heading) * @speeds['cluster']]
      for point in [0...@counts['point']]
        @points[cluster * @counts['point'] + point] = @sum(@clusters[cluster], @randomPosDelta(@sizes['cluster']))
      for smallitem in [0...@counts['small']]
        @small[cluster * @counts['small'] + smallitem] = @sum(@clusters[cluster], @randomPosDelta(@sizes['cluster']))
      for mediumitem in [0...@counts['medium']]
        @medium[cluster * @counts['medium'] + mediumitem] = @sum(@clusters[cluster], @randomPosDelta(@sizes['cluster']))
    true

  outOfRange: (p1, box, boxsize) ->
    p1[0] > box[0] + boxsize or p1[0] < box[0] or p1[1] > box[1] + boxsize or p1[1] < box[1]

  driftCoords: () =>
    for cluster in [0...@counts['cluster']]
      clusterDelta = @clusterSpeeds[cluster]
      @add(@clusters[cluster], clusterDelta)
      if @sizes['medium'] > @clusters[cluster][0] or @clusters[cluster][0] > @maxSize - @sizes['cluster'] - @sizes['medium'] or @sizes['medium'] > @clusters[cluster][1] or @clusters[cluster][1] > @maxSize - @sizes['cluster'] - @sizes['medium']
        @clusters[cluster] = @randomCoord(@sizes['cluster'] + @sizes['medium'])
      for point in [0...@counts['point']]
        i = cluster * @counts['point'] + point
        @add(@points[i], @randomDelta(@speeds['point']))
        @points[i] = @sum(@clusters[cluster], @randomPosDelta(@sizes['cluster'])) if @outOfRange(@points[i], @clusters[cluster], @sizes['cluster'])
      for smallitem in [0...@counts['small']]
        i = cluster * @counts['small'] + smallitem
        @add(@small[i], @randomDelta(@speeds['small']))
        @small[i] = @sum(@clusters[cluster], @randomPosDelta(@sizes['cluster'])) if @outOfRange(@small[i], @clusters[cluster], @sizes['cluster'])
      for mediumitem in [0...@counts['medium']]
        i = cluster * @counts['medium'] + mediumitem
        @add(@medium[i], clusterDelta)
        @medium[i] = @sum(@clusters[cluster], @randomPosDelta(@sizes['cluster'])) if @outOfRange(@medium[i], @clusters[cluster], @sizes['cluster'])
    true

  storeCoords: (qt) =>
    for point, i in @points
      qt.put("point#{i}", point[0], point[1])
    for sbox, si in @small
      qt.put("small#{si}", sbox[0], sbox[1], sbox[0] + @sizes['small'], sbox[1] + @sizes['small'])
    for mbox, mi in @medium
      qt.put("medium#{mi}", mbox[0], mbox[1], mbox[0] + @sizes['medium'], mbox[1] + @sizes['medium'])
    for lbox, li in @large
      qt.put("large#{li}", lbox[0], lbox[1], lbox[0] + @sizes['large'], lbox[1] + @sizes['large'])