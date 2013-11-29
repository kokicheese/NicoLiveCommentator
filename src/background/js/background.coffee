
class Background

  class _Background
    constructor: ()->
      @manager = Manager
      
    createAppWindow: (options)->
      chrome.runtime
      
  instance = null
  getInstance: -> instance ?= new _Background
  
