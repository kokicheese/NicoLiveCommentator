#

defaultOptions =
  src: null    # Source path.
  code: null   # SourceCode this is pre code.
  target: null # Output path.

{exec, spawn} = require 'child_process'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'


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
      fs.writeFile outPath, @code, cb.bind(@)

  compile: (cb)->
    @code = @srcCode
    cb.call @ if cb?

  watch: (cb)->
    unless @watch_ps?
      _s = _(@src)
      i = 0
      diff_cache = ""
      callback = (e, fname)=>
        basefile = fname
        if 'change' is e
          build = =>
            diff = (f, cb)=>
              if cb?
                exec "git diff #{f}", (err, stout, sterr)->
                  cb(err) if err
                  cb null, stout, sterr
            b = =>
              @build =>
                console.log @target
                cb.call(@, e, fname) if cb?
            done = (err, res)=>
              _i = 0
              cache = ""
              _(res).each (_j)->
                _i += _j.toString().length
                cache += _j.toString()
              unless cache is diff_cache
                diff_cache = _.clone(cache)
                b() if _i > 0
            if _s.isArray()
              task = []
              _s.each (f)=>
                task.push (next)=>
                  diff f, (err, out)=>
                    next err, out
              async.parallel task, done
            else
              diff fname, (err, out)=>
                done err, [out.length]
          ###
          # 2013/12/7 kokicheese
          # 原因不明　何故かfs.watchが３回実行される対策
          # node v0.11.2
          # Mac OS X 64 bit Mavericks
          ###
          #console.log ++i
          if ++i is 1
            i = 0
            build()
          else
            i = 0
      @watch_ps = []
      if _s.isArray()
        _s.each (f)=>
          @watch_ps.push fs.watch f, callback
      else
        @watch_ps.push fs.watch @src, callback

    
  build: (cb = (->))->
    self = @
    @srcUnpack (err)->
      if err
        throw err
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
