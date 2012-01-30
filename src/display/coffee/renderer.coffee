
class Renderer
  constructor: (@canvas, @quad, @scale = 1) ->
    @context = @canvas.getContext('2d')
    @context.linewidth = 2
    @xscale = @canvas.width / @quad.sizeX
    @yscale = @canvas.height / @quad.sizeY
    console.log("width: #{@canvas.width}, sizex: #{@quad.sizeX}")
    console.log("xscale: #{@xscale}, yscale: #{@yscale}")

  drawbox: (pos, linecolor = 'black', bgcolor = 'white') =>
    @context.fillStyle = bgcolor
    @context.strokeStyle = linecolor
    console.log("Drawing rectangle at (#{pos[0] * @xscale}, #{pos[1] * @yscale}, #{pos[2] * @xscale}, #{pos[3] * @yscale})")
    @context.fillRect(pos[0] * @xscale, pos[1] * @yscale, (pos[2] - pos[0]) * @xscale, (pos[3] - pos[1]) * @yscale)
    @context.strokeRect(pos[0] * @xscale, pos[1] * @yscale, (pos[2] - pos[0]) * @xscale, (pos[3] - pos[1]) * @yscale)

  clear: () =>
    @context.fillStyle = "blue"
    @context.fillRect(0, 0, @canvas.width, @canvas.height)

  drawnode: (node) =>
    @drawbox([node.minX, node.minY, node.maxX, node.maxY])
    @drawnode(child) for own child in node.children

  draw: (query) =>
    @clear()
    @drawnode(@quad.root)

