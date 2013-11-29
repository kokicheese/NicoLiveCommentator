###
#
# 
#
###

{exec, spawn} = require 'child_process'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'


Compiler = require './compiler.coffee'
Watcher  = require './watcher.coffee'
Wait = require './wait.coffee'

class Director

  old =
    task: null
    option: null

  #wait = require './wait.coffee'
  wait = (callbacks, done)->
    new Wait(callbacks, done)
  
  buildTargets = []

  tmp = {}

  tasks = []
  
  switches = []

  watchTargets = []
  addWatchTarget = (dir)->
    watchTargets.push dir if watchTargets.indexOf(dir) is -1

  setOptions: ->
    @option '-w', '--watch', 'Crate daemon process.'

  setTask: ->
    @task 'build', 'Project build.', @buildRun

  constructor: ()->
    @old = old
    for k of old
      old[k] = root[k]
      root[k] = @[k].bind(@)
    @tasks = tasks
    @wait = wait
    root.build = @build.bind(@)
    @cwd = process.cwd()
    @src = path.join @cwd, 'src/'
    @out = path.join @cwd, 'target/'
    @Compilers =
      js: Compiler.Coffee
      css: Compiler.Stylus
      html: Compiler.Jade
    @switches = switches
    @buildTargets = buildTargets
    @setOptions()
    @setTask()

  addBuildTarget: (src, target)->
    @buildTargets.push [src, target]

  build: (srcPath, options, callback)->
    err = new Error('undefine srcPath.') unless srcPath
    [callback, options] = [options, {}] unless callback
    self = @
    ftypeError = new Error "Not file type. must be File or Directory"
    tasks.push (next)->
      #console.log 'build.task'
      outDir = options.out || self.out
      solo = (_path, cb)->
        f = path.basename _path
        fspt = path.basename(f).split('.')
        for name, type of Compiler
          if ".#{fspt[1]}" is type.extname
            if srcPath.indexOf(f) < 0
              base = path.join srcPath, f
            else
              base = srcPath
            outf = path.join outDir, fspt[0] + type.out_extname
            buildTargets.push new type
              src: base
              target: outf
            cb() if cb
      tplC = (_path)->
      readdir = (_path, cb)->
        fs.readdir _path, (err, fls)->
          cb err, fls
      fs.stat srcPath, (err, stats)->
        next err if err?
        if stats.isFile()
          addWatchTarget srcPath
          solo srcPath, ->
            next()
        else if stats.isDirectory()
          readdir srcPath, (err, fls)->
            tmp.srcDir =
              tasks: []
              dir: srcPath
              outPath: []
              paths: []
              i: 0
              j: 0
            {tasks, i, paths, outPath, j} = tmp.srcDir
            out = path.basename(srcPath)
            for f in fls
              paths.push path.join srcPath, f
              tasks.push (next)->
                _path = paths[i]
                ++i
                fs.stat _path, (err, st)->
                  next err if err
                  if st.isFile()
                    addWatchTarget srcPath
                    solo _path, ->
                      next()
                  else if st.isDirectory()
                    b = path.basename _path
                    for name of self.Compilers
                      if b is name
                        readdir _path, (err, fls)->
                          next err if err
                          _index = null
                          fls = _(fls).filter (f)->
                            if f.indexOf('index') < 0
                              f
                            else
                              _index = f
                              return
                          fls.push _index if _index
                          fls = _(fls).map (f)-> path.join srcPath, b, f
                          addWatchTarget path.join srcPath, b
                          c = self.Compilers[b]
                          outPath = path.join outDir, out + c.out_extname
                          next null, new c
                            src: fls
                            target: outPath
                  else
                    next()
            wait tasks, (err, res)->
              next err if err
              res = _(res).filter (r)->
                r
              if res.length > 0
                for b in res
                  self.buildTargets.push b
              next()
        else
          next ftypeError
      
                    
  buildRun: (options, res)->
    tmp.build =
      tasks: []
      compilers: []
      i: 0
    { tasks, compilers, i} = tmp.build
    for b in @buildTargets
      compilers.push b
      tasks.push (next)->
        b = compilers[i]
        ++i
        b.build ->
          next()
    wait tasks, ->
      if options.watch?
        options.watch = false
        for dir, i in watchTargets
          dir = path.join process.cwd(), dir
          new Watcher dir, (e, fn)->
            if 'change' is e
              console.log e, fn
              exec 'cake build', (err, stdout, stderr)->
                throw err if err
                console.log stdout
      else
        console.log 'build done'
    
  task: (name, description, action) ->
    [action, desctiption] = [description, action] unless action
    self = @
    ext_action = (options)->
      self.wait self.tasks, action.bind(self, options)
    old.task name, description, ext_action

  option: (letter, flag, description) ->
    switches.push [letter, flag, description]
    old.option letter, flag, description
    
  old: old
  
module.exports = exports = Director

