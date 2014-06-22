http = require 'http'
dead = http.createServer (req, res) ->
  res.statusCode = 200
  res.setHeader 'Content-Type', 'text/plain'
  res.setHeader 'Content-Length', 14
  res.end 'The dead walk!'
dead.listen 3000
