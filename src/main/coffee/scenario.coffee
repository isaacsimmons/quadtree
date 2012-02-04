class Scenario
  constructor: (@qt) ->
    @maxSize = Math.min(@qt.bounds[2] - @qt.bounds[0], @qt.bounds[3] - @qt.bounds[1])
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
#    console.log("INITIAL MEDIUM: #{JSON.stringify(@medium)}")
#    console.log("INITIAL SPEEDS: #{JSON.stringify(@clusterSpeeds)}")
    true

  outOfRange: (p1, box, boxsize) ->
    p1[0] > box[0] + boxsize or p1[0] < box[0] or p1[1] > box[1] + boxsize or p1[1] < box[1]

  driftCoords: () =>
#    console.log('driftin')
#    console.log("WTF D1: #{@medium[0][0]}") if !@medium[0][0]
    for cluster in [0...@counts['cluster']]
      clusterDelta = @clusterSpeeds[cluster]
      console.log("LOADED SPEED: #{clusterDelta}")
      @add(@clusters[cluster], clusterDelta)
#      console.log("CHECKING SPEED 1: #{clusterDelta}")
      if @sizes['medium'] > @clusters[cluster][0] or @clusters[cluster][0] > @maxSize - @sizes['cluster'] - @sizes['medium'] or @sizes['medium'] > @clusters[cluster][1] or @clusters[cluster][1] > @maxSize - @sizes['cluster'] - @sizes['medium']
        @clusters[cluster] = @randomCoord(@sizes['cluster'] + @sizes['medium'])
#      console.log("CHECKING SPEED 1: #{clusterDelta}")
      for point in [0...@counts['point']]
        i = cluster * @counts['point'] + point
        @add(@points[i], @randomDelta(@speeds['point']))
        @points[i] = @sum(@clusters[cluster], @randomPosDelta(@sizes['cluster'])) if @outOfRange(@points[i], @clusters[cluster], @sizes['cluster'])
#      console.log("CHECKING SPEED 1: #{clusterDelta}")
      for smallitem in [0...@counts['small']]
        i = cluster * @counts['small'] + smallitem
        @add(@small[i], @randomDelta(@speeds['small']))
        @small[i] = @sum(@clusters[cluster], @randomPosDelta(@sizes['cluster'])) if @outOfRange(@small[i], @clusters[cluster], @sizes['cluster'])
#      console.log("CHECKING SPEED 1: #{clusterDelta}")
      for mediumitem in [0...@counts['medium']]
        i = cluster * @counts['medium'] + mediumitem
#        console.log("INCREASING #{JSON.stringify(@medium[i])} BY #{JSON.stringify(clusterDelta)}") if @medium[0][0]
        @add(@medium[i], clusterDelta)
#        console.log("WTF D12: #{@medium[0][0]}") if !@medium[0][0]
        @medium[i] = @sum(@clusters[cluster], @randomPosDelta(@sizes['cluster'])) if @outOfRange(@medium[i], @clusters[cluster], @sizes['cluster'])
#    console.log("WTF D2: #{@medium[0][0]}") if !@medium[0][0]
    true

  storeCoords: () =>
#    console.log("WTF STORIN1") if @medium[0][0] is null
#    console.log("OUT1: #{JSON.stringify(@points)}")
    for point, i in @points
      @qt.put("point#{i}", point[0], point[1])
#    console.log("OUT2: #{JSON.stringify(@small)}")
    for sbox, si in @small
      @qt.put("small#{si}", sbox[0], sbox[1], sbox[0] + @sizes['small'], sbox[1] + @sizes['small'])
#    console.log("OUT3: #{JSON.stringify(@medium)}")
#    console.log("WTF STORIN22: #{@medium[0][0]}") if !@medium[0][0]
    for mbox, mi in @medium
      @qt.put("medium#{mi}", mbox[0], mbox[1], mbox[0] + @sizes['medium'], mbox[1] + @sizes['medium'])
#    console.log("OUT4: #{JSON.stringify(@large)}")
    for lbox, li in @large
      @qt.put("large#{li}", lbox[0], lbox[1], lbox[0] + @sizes['large'], lbox[1] + @sizes['large'])


  tick: () =>
#    console.log('tick')
    @driftCoords()
    @storeCoords()

