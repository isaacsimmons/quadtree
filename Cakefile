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

afterbuild = () ->

task 'build', 'build the project', (options) ->
#  args = ['-cb' + (if options.watch then 'w' else ''), '-o', 'build', '-j', 'quadtree', 'src/main/coffee']
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

#  console.log('build!!') if fs.statSync('afea').isDirectory()
#  console.log('src!!') if fs.statSync('src').isDirectory()

#  fs.rmdirSync('-p') #Nod sure why the coffee commands are littering these -p directories around
#  fs.rmdirSync('notadir')







