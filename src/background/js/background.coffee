
class Background

  class _Background
    constructor: ()->
      
    onLauncher: ->
      @createAppWindow()
      
    createAppWindow: (options)->
      unless @window
        @window = true
        chrome.app.window.create 'init.html', (@window)=>
          console.log @window

      
  instance = null
  @getInstance: -> instance ?= new _Background
  
