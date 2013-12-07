###
#
# 
#
###

{exec, spawn} = require 'child_process'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
{fork} = require 'child_process'


Compiler = require './compiler.coffee'
#Watcher  = require './watcher.coffee'
#Wait = require './wait.coffee'



class Director

  old = {}
  
  wait = (callbacks, done)->
    async.parallel callbacks, done if callbacks?
  
  buildTargets = []
  
  tmp = {}
  
  buildTasks = []
  
  switches = []

  workers = []
  
  watchTargets = []
  addWatchTarget = (dir, compiler)->
    console.log compiler
    #watchTargets.push {dir: dir, build: compiler} if watchTargets.indexOf(dir) is -1

  setOptions: ->
    @option '-w', '--watch', 'Crate daemon process.'
  
  setTask: ->
    @task 'build', 'Project build.', @buildRun
  
  constructor: ()->
    @old = old
    @buildTasks = buildTasks
    @wait = wait
    @cwd = process.cwd()
    @src = path.join @cwd, 'src/'
    @out = path.join @cwd, 'target/'
    @Compilers =
      js: Compiler.Coffee
      css: Compiler.Stylus
      html: Compiler.Jade
    @switches = switches
    @buildTargets = buildTargets
    @cmdSet
      build: @build.bind(@)
      task: @task.bind(@)
      option: @option.bind(@)
    @setOptions()
    @setTask()
    #@workers = workers
    #@workerStart()
  
  cmdSet: (cmd, func)->
    set = (cmd, func)->
      old[cmd] = root[cmd] if root[cmd]?
      root[cmd] = func
    if _(cmd).isObject()
      for c, v of cmd
        set c, v
    else
      set cmd, func
  
  addBuildTarget: (src, target)->
    @buildTargets.push [src, target]

  build: (srcPath, options, callback)->
    err = new Error('undefine srcPath.') unless srcPath
    [callback, options] = [options, {}] unless callback
    self = @
    id = buildTasks.length
    outDir = @out
    buildTasks.push (next)->
      fs.stat srcPath, (err, stats)->
        next(err) if err
        check_compiler = (fname)->
          for n, c of self.Compilers
            if fname is n
              return c
        if stats.isDirectory()
          fs.readdir srcPath, (err, fls)->
            next(err) if err
            _task = []
            _(fls).each (fname)->
              _path = path.join(srcPath, fname)
              _task.push (next)->
                compiler = check_compiler(fname)
                fs.readdir _path, (err, fls)->
                  next(err) if err
                  index = null
                  fls = _(fls).filter (f)->
                    if f.indexOf('index') < 0
                      f
                    else
                      index = f
                      return
                  fls.push index if index
                  srcs = _(fls).map (f)->
                    path.join(_path, f)
                  next null, new compiler
                    src: srcs
                    target: path.join(outDir, path.basename(srcPath) + compiler.out_extname)

                    
            wait _task, (err, res)->
              if err?.length?
                next(err) if err.length > 0
              next null, res
        else if stats.isFile()
          #check extname = ->
          comp = do ->
            for n, c of self.Compilers
              if path.extname(srcPath) is c.extname
                return c
          
          next null, [new comp
            src: srcPath
            target: path.join(outDir, path.basename(srcPath, comp.extname) + comp.out_extname)
            ]
        else
          next(Director.Error.TypeError)

  buildRun: (options, res)->
    bs = []
    wait buildTasks, (err, res)->
      _(res).each (b)->
        _(b).each (b)->
          bs.push b
      _(bs).each (b)->
        buildTargets.push b
        b.build ->
          cb = ->
            spawn 'git', ['diff', @target], { stdio: [0, 1, 2] }
          @watch(cb) if options.watch?
        
  
  workerStart: ->
    _(@workerNum).times (id)->
      child = fork __dirname + '/worker.coffee',  [id]
      child.on 'message', (m)->
        console.log m.log if m.log?
      child.send 'build'
      workers.push child
    
        
         
  ###
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
            buildTargets.push cmp = new type
              src: base
              target: outf
            addWatchTarget _path, cmp
            cb() if cb
      tplC = (_path)->
      readdir = (_path, cb)->
        fs.readdir _path, (err, fls)->
          cb err, fls
      fs.stat srcPath, (err, stats)->
        next err if err?
        if stats.isFile()
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
                          c = self.Compilers[b]
                          addWatchTarget path.join(srcPath, b), c
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
              exec 'cake build', (err, stdout, stderr)->
                throw err if err
                exec "git diff #{fn}", (err, stdout, stderr)->
                  throw err if err
                  process.stdout.write stdout
      else
        console.log 'build done'
  ###
      
  task: (name, description, action) ->
    [action, desctiption] = [description, action] unless action
    self = @
    old.task name, description, action

  option: (letter, flag, description) ->
    switches.push [letter, flag, description]
    old.option letter, flag, description

  workerNum: require('os').cpus().length
  
  @Error:
    TypeError: new TypeError "Not file type. must be File or Directory"
  
module.exports = exports = Director

