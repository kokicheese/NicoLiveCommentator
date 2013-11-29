#
#

async = require 'async'

class Wait
  self = null
  constructor: (@callbacks, @done)->
    async.parallel @callbacks, @done

module.exports = exports = Wait
