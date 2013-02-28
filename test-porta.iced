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
  if process.argv.length != 3
    console.log "Usage: test-porta GITENTRYPOINT"
    return process.exit 1
  repo = process.argv[2]
  runnings = []
  branchesJSON = ""
  while true
    await lsremote repo, defer e, branches
    continue if e
    if branchesJSON != JSON.stringify branches
      console.log "heads changed, stopping..."
      branchesJSON = JSON.stringify branches
      for running in runnings
        try
          running.process.kill()
        catch e
        await exec "rm -Rf #{running.path}", defer e

      runnings =[]
      for branch in branches
        running = 
          path: "#{branch.branch}.#{(repo.match /\/([^\/]+)$/)[1]}.test-porta.tmp"
        console.log "checking out to #{running.path}..."
        await exec "rm -Rf #{running.path}", defer e
        await exec "mkdir #{running.path}", defer e
        await exec "git clone --depth=1 --recursive --branch #{branch.branch} #{repo} #{running.path}", defer e
        opt = 
          cwd: path.join process.cwd(), running.path
          stdio: 'inherit'
        running.process = spawn './.test-porta',[], opt 
        running.process.on 'exit', ->
          console.error "#{running.path} exited.."

           
    else
      console.log "heads not changed."
    await setTimeout defer(), 5000


  



    



    