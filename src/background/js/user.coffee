
class User

  password = null
  
  constructor: (@mail, pass)->
    pasword = pass
    login()
  login: ->
    console.log @mail, password
  @login: (mail, pass)->
    new User mail, pass
    
