#

defaultOptions =
  src: null # Source path.
  code: null # SourceCode this is pre code.
  target: null # Output path.

fs = require 'fs'
path = require 'path'
_ = require 'underscore'


class Compiler

  srcCode: null
  code: null

  constructor: (options = {})->
    unless _(options).isObject
      throw new TypeError "Parameter 'options' must be a object, not #{typeof options}"
    else
      for k, v of defaultOptions
        options[k] = v unless options.hasOwnProperty(k)
      for k, v of options
        @[k] = v

  srcUnpack: (cb)->
    self = @
    src = @src

    readFile = (srcPath, cb)->
      fs.exists srcPath, (e)->
        unless e
          cb.call self, new Error "Not exists: #{srcPath}" if cb?
        else
          fs.readFile srcPath, (err, date)->
            if err?
              cb.call self, err if cb?
            else
              self.srcCode = date.toString()
              cb.call self, null, self.srcCode if cb?
    #          
    _src = _(src)
    if      _src.isString()
      readFile src, cb
    else if _src.isArray()
      tmpCode = ""
      _src.each (srcPath, i)->
        readFile srcPath, (err, code)->
          if err
            cb.call self, err
          else
            tmpCode += code
        
            if i is (src.length - 1)
              self.srcCode = tmpCode
              cb.call self, null, self.srcCode
      
  outCode: (cb = (->))->
    self = @
    if !!(outPath = @target) and @code?
      fs.writeFile outPath, @code, cb

  compile: (cb)->
    @code = @srcCode
    cb.call @ if cb?
  
  build: (cb = (->))->
    self = @
    @srcUnpack (err)->
      if err
        console.log err
        #cb.call self, err if cb?
      else
        @compile (err)->
          throw err if err?
          self.outCode cb

class Compiler.Coffee extends Compiler

  @extname: '.coffee'
  @out_extname: '.js'
  
  coffee: require 'coffee-script'
  
  constructor: (options = {})->
    super

  compile: (cb)->
    @code = @coffee.compile @srcCode
    cb null

class Compiler.Jade extends Compiler
  @extname: '.jade'
  @out_extname: '.html'

  jade: require 'jade'
  
  constructor: (options = {})->
    super

  compile: (cb)->
    fn = @jade.compile @srcCode, {} # {} = options
    @code = fn({}) # {} = locals
    cb null

class Compiler.Stylus extends Compiler
  @extname: '.styl'
  @out_extname: '.css'

  stylus: require 'stylus'

  constructor: (options = {})->
    super

  compile: (cb)->
    @stylus(@srcCode)
    .include(require('nib').path)
    .render (err, css)=>
      #throw err if err
      @code = css
      cb err

        

module.exports = exports = Compiler
