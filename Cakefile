{spawn} = require 'child_process'
{reporters} = require 'nodeunit'
fs = require 'fs'
isWindows = require('os').platform().substring(0,3) is 'win'

COFFEE_CMD = if isWindows then 'coffee.cmd' else 'coffee'
UGLFIY_CMD = if isWindows then 'uglifyjs.cmd' else 'uglifyjs'

build = 'build'

task 'clean', 'clean temporary build artifacts', (options) ->
  fs.unlinkSync("#{build}/#{file}") for file in fs.readdirSync(build)
  fs.rmdirSync(build)

copy = (src, dest) ->
  srcfile = fs.createReadStream(src)
  destfile = fs.createWriteStream(dest)
  destfile.once 'open', (fd) ->
    require('util').pump(srcfile, destfile)

task 'build', 'build the project', (options) ->
  try fs.mkdirSync(build)

  #TODO: if coffee outputs errors, they get swallowed

  coffee = spawn(COFFEE_CMD, ['-cb', '-o', build, '-j', 'quadtree', 'src/main/coffee'])
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.on 'exit', () -> try fs.rmdirSync('-p')

  coffee = spawn(COFFEE_CMD, ['-cb', '-o', build, '-j', 'display', 'src/display/coffee'])
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.on 'exit', () -> try fs.rmdirSync('-p')

  copy("src/display/css/#{file}", "#{build}/#{file}") for file in fs.readdirSync('src/display/css')
  copy("src/display/html/#{file}", "#{build}/#{file}") for file in fs.readdirSync('src/display/html')

  coffee = spawn(COFFEE_CMD, ['-cb', '-o', build, '-j', 'test', 'src/main/coffee', 'src/test/coffee'])
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.on 'exit', () -> try fs.rmdirSync('-p')

task 'minify', 'Minify javascript output', (options) ->
#  fs.unlinkSync("#{build}/#{file}") for file in fs.readdirSync(build)
  uglify = spawn(UGLFIY_CMD, ['-o', 'build/quadtree-min.js', 'build/quadtree.js'])
  uglify.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'test', 'run nodeunit tests', (options) ->
  reporters.default.run(["#{build}/test.js"])
