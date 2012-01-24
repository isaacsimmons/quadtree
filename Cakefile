{spawn} = require 'child_process'

option '-w', '--watch', 'watch for changes and continually build'

task 'build', 'build the project', (options) ->
  args = ['-cb' + (if options.watch then 'w' else ''), '-o', 'build', '.']
  coffee = spawn('coffee', args)
  coffee = spawn('coffee.cmd', args) if not coffee.pid #We have no PID. Guess that this is windows
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()