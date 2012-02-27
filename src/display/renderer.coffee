
class Renderer
  constructor: (@canvas, @quad) ->
    @context = @canvas.getContext('2d')
    @xscale = @canvas.width / (@quad.bounds[2] - @quad.bounds[0])
    @yscale = @canvas.height / (@quad.bounds[3] - @quad.bounds[1])

  scalexy: (pos) =>
    if pos.length is 2
      return [pos[0] * @xscale, pos[1] * @yscale]
    return [pos[0] * @xscale, pos[1] * @yscale, pos[2] * @xscale, pos[3] * @yscale]

  drawBox: (pos, linecolor = 'black') =>
    @context.strokeStyle = linecolor
    @context.linewidth = 2
    pos = @scalexy(pos)
    if pos.length is 2
      @context.strokeRect(pos[0], pos[1], 1, 1)
    else
      @context.strokeRect(pos[0], pos[1], pos[2] - pos[0], pos[3] - pos[1])

  clear: () =>
    @context.clearRect(0, 0, canvas.width, canvas.height)

  drawNode: (node) =>
    @drawBox([node.bounds[0], node.bounds[1], node.bounds[2], node.bounds[3]])
    @drawNode(child) for child in node.children

  draw: (query) =>
    @clear()
    @drawNode(@quad.root)
    @drawBox(pos, 'green') for own id, pos of @quad.positions