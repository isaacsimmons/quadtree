
class Renderer
  constructor: (@canvas, @quad, @scale = 1) ->
    @context = @canvas.getContext('2d')
    @context.linewidth = 2
    @xscale = @canvas.width / (@quad.bounds[2] - @quad.bounds[0])
    @yscale = @canvas.height / (@quad.bounds[3] - @quad.bounds[1])

  scalexy: (pos) =>
    [pos[0] * @xscale, pos[1] * @yscale, pos[2] * @xscale, pos[3] * @yscale]

  drawbox: (pos, linecolor = 'black', bgcolor = 'white') =>
    @context.fillStyle = bgcolor
    @context.strokeStyle = linecolor
    pos = @scalexy(pos)
    @context.fillRect(pos[0], pos[1], pos[2] - pos[0], pos[3] - pos[1])
    @context.strokeRect(pos[0], pos[1], pos[2] - pos[0], pos[3] - pos[1])

  clear: () =>
    @context.fillStyle = "blue"
    @context.fillRect(0, 0, @canvas.width, @canvas.height)

  drawnode: (node) =>
    @drawbox([node.bounds[0], node.bounds[1], node.bounds[2], node.bounds[3]])
    @drawnode(child) for own child in node.children

  draw: (query) =>
    @clear()
    @drawnode(@quad.root)

