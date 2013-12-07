

class MSScoket extends chrome.socket
  constructor: ->
    MSScoket.create 'tcp', (info)=>
      @id = info.socketId
      console.log @id
