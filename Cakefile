{exec} = require 'child_process'
{reporters} = require 'nodeunit'
fs = require 'fs'
isWindows = require('os').platform().substring(0,3) is 'win'
util = require('util')

COFFEE_CMD = if isWindows then 'coffee.cmd' else 'coffee'
UGLIFY_CMD = if isWindows then 'uglifyjs.cmd' else 'uglifyjs'

BUILD = 'build'

del = (name) ->
  try stats = fs.statSync(name)
  if not stats?
    return
  if stats.isFile()
    fs.unlinkSync(name)
  else
    del("#{name}/#{file}") for file in fs.readdirSync(name)
    fs.rmdirSync(name)

copy = (src, dest) ->
  srcfile = fs.createReadStream(src)
  destfile = fs.createWriteStream(dest)
  destfile.once 'open', (fd) ->
    util.pump(srcfile, destfile)

compile = (output, inputs...) ->
  exec "#{COFFEE_CMD} -cb -o #{BUILD} -j #{output} #{inputs.join(' ')}", (err, stdout, stderr) ->
    throw err if err
    console.log (stdout + stderr) if stdout or stderr
    exec "#{UGLIFY_CMD} --lift-vars --unsafe -d DEBUG=false -b -o #{BUILD}/#{output}-min.js #{BUILD}/#{output}.js", (err, stdout, stderr) ->
      throw err if err
      console.log (stdout + stderr) if stdout or stderr
      exec "#{UGLIFY_CMD} -d DEBUG=true -ns -b -o #{BUILD}/#{output}-debug.js #{BUILD}/#{output}.js", (err, stdout, stderr) ->
        throw err if err
        console.log (stdout + stderr) if stdout or stderr
        del("#{BUILD}/#{output}.js")

task 'clean', 'clean temporary build artifacts', (options) ->
  del(BUILD)

task 'build', 'build the project', (options) ->
  try fs.mkdirSync(BUILD)

  compile('qt', 'src/main/quadtree.coffee')
  compile('display', 'src/main', 'src/display')
  compile('test', 'src/main', 'src/test')

  for file in fs.readdirSync('src/display/')
    copy("src/display/#{file}", "#{BUILD}/#{file}") if file.slice(-6) isnt 'coffee'

task 'test', 'run nodeunit tests', (options) ->
  reporters.default.run(["#{BUILD}/test-debug.js"])
