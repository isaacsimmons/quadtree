{exec} = require 'child_process'
{reporters} = require 'nodeunit'
fs = require 'fs'
isWindows = require('os').platform().substring(0,3) is 'win'
#compiler = require 'require/compiler'

COFFEE_CMD = if isWindows then 'coffee.cmd' else 'coffee'
UGLFIY_CMD = if isWindows then 'uglifyjs.cmd' else 'uglifyjs'

build = 'build'

task 'clean', 'clean temporary build artifacts', (options) ->
  try fs.unlinkSync("#{build}/#{file}") for file in fs.readdirSync(build)
  try fs.rmdirSync(build)

copy = (src, dest) ->
  srcfile = fs.createReadStream(src)
  destfile = fs.createWriteStream(dest)
  destfile.once 'open', (fd) ->
    require('util').pump(srcfile, destfile)

task 'temp', 'testing stuff', (options) ->
  console.log(compiler.compile('./build/main/coffee/quadtree-basic', {beautify: true, ascii_only: true}))

compile = (output, bare, input...) ->
  exec "#{COFFEE_CMD} -c#{if bare then 'b' else ''} -o #{build} -j #{output} #{input.join(' ')}", (err, stdout, stderr) ->
    throw err if err
    console.log (stdout + stderr) if stdout or stderr
#  coffee.on 'exit', () -> try fs.rmdirSync('-p')

task 'build', 'build the project', (options) ->
  try fs.mkdirSync(build)

  compile('qt', false, 'src/main/coffee/quadtree-basic.coffee')
  compile('quadtree', true, 'src/main/coffee')
  compile('display', true, 'src/main/coffee', 'src/display/coffee')
  compile('test', true, 'src/main/coffee', 'src/test/coffee')

  copy("src/display/css/#{file}", "#{build}/#{file}") for file in fs.readdirSync('src/display/css')
  copy("src/display/html/#{file}", "#{build}/#{file}") for file in fs.readdirSync('src/display/html')

minify = (source) ->
  exec "#{UGLFIY_CMD} --lift-vars -mt -o #{source}-uglify.js #{source}.js", (err, stdout, stderr) ->
    throw err if err
    console.log (stdout + stderr) if stdout or stderr

  exec "java -jar tools/compiler.jar --js #{source}.js --js_output_file #{source}-cc.js", (err, stdout, stderr) ->
    #      --compilation_level=ADVANCED_OPTIMIZATIONS
    throw err if err
    console.log (stdout + stderr) if stdout or stderr


task 'minify', 'Minify javascript output', (options) ->
  minify("#{build}/quadtree")
  minify("#{build}/display")

task 'test', 'run nodeunit tests', (options) ->
  reporters.default.run(["#{build}/test.js"])
