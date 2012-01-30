{spawn} = require 'child_process'
fs = require 'fs'

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
  args = ['-cb', '-o', build, '-j', 'quadtree', 'src/main/coffee']
  coffee = spawn('coffee', args)
  coffee = spawn('coffee.cmd', args) if not coffee.pid #We have no PID. Guess that this is windows
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.on 'exit', () -> try fs.rmdirSync('-p')

  args = ['-cb', '-o', build, '-j', 'display', 'src/display/coffee']
  coffee = spawn('coffee', args)
  coffee = spawn('coffee.cmd', args) if not coffee.pid #We have no PID. Guess that this is windows
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.on 'exit', () -> try fs.rmdirSync('-p')

  copy("src/display/css/#{file}", "#{build}/#{file}") for file in fs.readdirSync('src/display/css')
  copy("src/display/html/#{file}", "#{build}/#{file}") for file in fs.readdirSync('src/display/html')

  args = ['-cb', '-o', build, '-j', 'test', 'src/test/coffee']
  coffee = spawn('coffee', args)
  coffee = spawn('coffee.cmd', args) if not coffee.pid #We have no PID. Guess that this is windows
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.on 'exit', () -> try fs.rmdirSync('-p')