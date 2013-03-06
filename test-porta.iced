fs = require 'fs'
http = require 'http'
path = require 'path'
{
  spawn
  exec
} = require 'child_process'

lsremote = (repo, cb)->
  await exec "git ls-remote #{repo}", defer e, out, err
  return cb e if e
  cb null, (out.match /^([0-9a-z]+)\s+refs\/heads\/(.+)$/mg).map (b)->
    b = b.match /^([0-9a-z]+)\s+refs\/heads\/(.+)$/m
    return branch: b[2], head: b[1]

module.exports = ()->
  runnings = []
  branchesJSON = ""
  
  process.on 'exit',->
    for running in runnings
      try
        running.process.kill()
      catch e
    console.log "process exiting.."
  process.on 'SIGINT', ->
    process.exit -1
  process.on 'SIGTERM', ->
    process.exit -1

  if process.argv.length != 3
    console.log "Usage: test-porta GITENTRYPOINT"
    return process.exit 1
  repo = process.argv[2]

  while true
    await lsremote repo, defer e, branches
    if e
      console.error e.message
    else
      if branchesJSON != JSON.stringify branches
        console.log "heads changed, stopping..."
        branchesJSON = JSON.stringify branches
        for running in runnings
          try
            running.process.kill()
          catch e
        for running in runnings
          await exec "rm -Rf #{running.path}", defer e

        runnings =[]
        for branch in branches
          running = 
            path: "#{branch.branch}.#{repo.replace /[^0-9a-z]/g, '-'}.test-porta.tmp"
          console.log "checking out to #{running.path}..."
          await exec "rm -Rf #{running.path}", defer e
          await exec "mkdir #{running.path}", defer e
          await exec "git clone --depth=1 --recursive --branch #{branch.branch} #{repo} #{running.path}", defer e
          opt = 
            cwd: path.join process.cwd(), running.path
            stdio: 'inherit'
            env: {}
          opt.env[k] = v for k, v of process.env
          opt.env['TESTPORTABRANCH'] = branch.branch
          opt.env['TESTPORTAREPO'] = repo
          running.process = spawn './.test-porta',[], opt 
          running.process.on 'exit', ->
            console.error "#{running.path} exited.."
          runnings.push running

             
      else
        console.log "heads not changed. #{runnings.leng} running.."
    await setTimeout defer(), 10000


  



    



    
