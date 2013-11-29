

fs = require 'fs'
path = require 'path'

class Watcher
  constructor: (@target, @options, @action)->
    [@action, @options] = [@options, @action] unless @action
    @ext_action = (e, f)=>
      if path.basename(@target) is f
        fn = @target
      else
        fn = path.join @target, f
      @action e, fn

    @instance = fs.watch @target, @ext_action
    

module.exports = exports = Watcher
