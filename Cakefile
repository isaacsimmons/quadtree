{exec} = require 'child_process'
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

compile = (output, bare, input...) ->
  exec "#{COFFEE_CMD} -c#{if bare then 'b' else ''} -o #{build} -j #{output} #{input.join(' ')}", (err, stdout, stderr) ->
    throw err if err
    console.log (stdout + stderr) if stdout or stderr
#  coffee.on 'exit', () -> try fs.rmdirSync('-p')

task 'build', 'build the project', (options) ->
  try fs.mkdirSync(build)

  compile('qt', false, 'src/main/coffee/quadtree-basic.coffee')
  compile('quadtree', true, 'src/main/coffee')
  compile('display', true, 'src/display/coffee')
  compile('test', true, 'src/main/coffee', 'src/test/coffee')

  copy("src/display/css/#{file}", "#{build}/#{file}") for file in fs.readdirSync('src/display/css')
  copy("src/display/html/#{file}", "#{build}/#{file}") for file in fs.readdirSync('src/display/html')

task 'minify', 'Minify javascript output', (options) ->
#  '--unsafe' ?
  uglify = spawn(UGLFIY_CMD, ['--lift-vars', '-mt', '-o', 'build/qt-min.js', 'build/qt.js'])
  uglify.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'cc', 'Minify javascript output', (options) ->
#  '--unsafe' ?
#  uglify = spawn('java', ['-jar' '--lift-vars', '-mt', '-o', 'build/qt-min.js', 'build/qt.js'])
  uglify.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'test', 'run nodeunit tests', (options) ->
  reporters.default.run(["#{build}/test.js"])
