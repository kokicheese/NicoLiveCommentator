Wait = require './wait.coffee'

cbs = []
cbs.push (next)->
  setTimeout ->
    console.log 'A'
    next()
  , 1000
  
cbs.push (next)->
  setTimeout ->
    console.log 'B'
    next()
  , 0

wait = new Wait cbs,->
  console.log 'done'
