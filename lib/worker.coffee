###
#
# worker process
#
###

id = process.argv[2]

log = (msg)->
  process.send({log: msg})

process.on 'message', (msg)->
  log msg

