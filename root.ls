/**
 * User: gisborne
 * Date: 9/21/14
 * Time: 13:57
 *
 * Root scope. Also may be used as prototype for other scopes
 */

require! method_override: 'method-override'
require! bodyParser: 'body-parser'
require! path
require! _: 'prelude-ls'

require! './db'
require! scp: './scope'
export scope = new scp.scope

require! './rootFns'

getMethod = (req) ->
  query = req.query
  if (method = query['_method']) && method.match(/put/i)
    'put'
  else
    req.method

getScope = (name) ->
  db.getModelScope name


export rootHandle = (req, res, next) ->
  method = getMethod req

  url = req.url
  url_parts = url.split '/' |> _.tail #We throw away the inevitable blank before the opening /
  handle method, url_parts, req, res, next

defaultHandle = (method, req, res, next) ->
    res.send 'foo ' + req.url #ToDo What do we do with GET '/'?

handle = (method, url, req, res, next) ->
  next_scope_name = _.head url
  if next_scope_name !== ''
    rest_url = _.tail url

    next_scope = getScope next_scope_name
    next_scope.handle method, scope, rest_url, req, res,  -> #next line is the "next" handler
      throw new Error 'Unrecognized scope name: ' + next_scope_name
  else
    defaultHandle method, req, res, next #This is usually GET '/'