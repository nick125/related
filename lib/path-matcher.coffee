fs = require 'fs'
glob = require 'glob'
path = require 'path'

class Pattern
  constructor: (inputPattern, outputPatterns) ->
    @inputPattern = new RegExp(inputPattern.replace('/', path.sep.replace('\\', '\\\\')))
    @outputPatterns = (outputPattern.replace('/', path.sep) for outputPattern in outputPatterns)

  doesMatch: (inputPath) ->
    @inputPattern.exec(inputPath)

  getResults: (inputPath) ->
    inputPath.replace(@inputPattern, pattern) for pattern in @outputPatterns

getFilesystemMatches = (root, filePattern) ->
  expandedPath = path.join(root, filePattern)
  if (filePattern.indexOf "*" >= 0)
    matches = glob.sync(expandedPath)
    match for match in matches when fs.statSync(match).isFile
  else
    if fs.existsSync(expandedPath) then [expandedPath] else []

class PathMatcher
  constructor: ->
    @patterns = []

  loadPatterns: (patternsList) =>
    patternsList = [] if !patternsList

    @patterns = (new Pattern(pattern.in, pattern.out) for pattern in patternsList)

  findMatches: (root, currentPath) ->
    # Load the patterns if we haven't already (but this
    # really should've already been done)
    loadPatterns() if not @patterns

    matchesToCheck = [].concat (pattern.getResults(currentPath) for pattern in @patterns when pattern.doesMatch currentPath)...

    [].concat (getFilesystemMatches(root, match) for match in matchesToCheck)...

module.exports =
  PathMatcher: PathMatcher
