
class Renderer
  constructor: (@canvas, @quadtree, @scale = 1) ->
    @context = @canvas.getContext('2d')

  drawbox: (pos) =>
    @context.rect(pos[0] * @scale, pos[1] * @scale, pos[2] * @scale, pos[3] * @scale)

  clear: () =>
    @context.fillStyle("blue")
    @context.fillRect(0, 0, @canvas.width, @canvas.height)

  draw: (query) =>

