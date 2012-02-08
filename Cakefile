{exec} = require 'child_process'
{reporters} = require 'nodeunit'
fs = require 'fs'
isWindows = require('os').platform().substring(0,3) is 'win'
util = require('util')

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
    util.pump(srcfile, destfile)

compile = (output, inputs...) ->
  console.log('start ' + output)
  e = exec "#{COFFEE_CMD} -cb -o #{build} -j #{output} #{inputs.join(' ')}", (err, stdout, stderr) ->
    console.log('running ' + output)
    throw err if err
    console.log (stdout + stderr) if stdout or stderr
  uglify = () ->
    exec "#{UGLFIY_CMD} --lift-vars --unsafe -d DEBUG=false -mt -b -o #{build}/#{output}-min.js #{build}/#{output}.js", (err, stdout, stderr) ->
      throw err if err
      console.log (stdout + stderr) if stdout or stderr
    exec "#{UGLFIY_CMD} -d DEBUG=true -ns -b -o #{build}/#{output}-debug.js #{build}/#{output}.js", (err, stdout, stderr) ->
      throw err if err
      console.log (stdout + stderr) if stdout or stderr
  e.on('exit', uglify)
  console.log('done ' + output)

task 'build', 'build the project', (options) ->
  try fs.mkdirSync(build)

  compile('qt', 'src/main/quadtree-basic.coffee')
  compile('display', 'src/main', 'src/display')
  compile('test', 'src/main', 'src/test')

  for file in fs.readdirSync('src/display/')
    copy("src/display/#{file}", "#{build}/#{file}") if file.slice(-6) is not 'coffee'

minify = (source) ->
  exec "#{UGLFIY_CMD} --lift-vars -mt -o #{source}-uglify.js #{source}.js", (err, stdout, stderr) ->
    throw err if err
    console.log (stdout + stderr) if stdout or stderr

  exec "java -jar tools/compiler.jar --js #{source}.js --js_output_file #{source}-cc.js", (err, stdout, stderr) ->
    #      --compilation_level=ADVANCED_OPTIMIZATIONS
    throw err if err
    console.log (stdout + stderr) if stdout or stderr


task 'minify', 'Minify javascript output', (options) ->
  minify("#{build}/qt")
  minify("#{build}/display")

task 'test', 'run nodeunit tests', (options) ->
  reporters.default.run(["#{build}/test-min.js"])
