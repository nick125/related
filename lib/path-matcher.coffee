fs = require 'fs'
glob = require 'glob'
path = require 'path'
q = require 'q'

fixPath = (orig, regex) ->
  sep = if regex then path.sep.replace('\\', '\\\\') else path.sep
  orig.replace('/', sep)

class Pattern
  constructor: (matcher, outputs) ->
    @matcher = new RegExp(fixPath(matcher, true))
    @outputs = (fixPath(outputPattern) for outputPattern in outputs)

  isMatch: (inputPath) ->
    @matcher.exec(inputPath)

  getResults: (inputPath) ->
    inputPath.replace(@matcher, pattern) for pattern in @outputs

getFilesystemMatches = (root, filePattern) ->
  expandedPath = path.join(root, filePattern)
  if (filePattern.indexOf("*") >= 0)
    matches = glob.sync(expandedPath)
    match for match in matches when fs.statSync(match).isFile
  else
    if fs.existsSync(expandedPath) then [expandedPath] else []

class PathMatcher
  constructor: ->
    @waitingOnPatternLoad = []
    @hasLoadedPatterns = false
    @patterns = []

  loadPatterns: (patterns) ->
    @patterns = []

    for input, outputs of patterns
      @patterns.push(new Pattern(input, outputs))

    @hasLoadedPatterns = true
    for waiter in @waitingOnPatternLoad
      waiter.resolve()

    @waitingOnPatternLoad.length = 0

  findMatches: (root, currentPath) ->
    # Load the patterns if we haven't already (but this
    # really should've already been done)
    loadPatterns() if not @patterns

    matches = (p for p in @patterns when p.isMatch(currentPath))
    resolvedPaths = (pattern.getResults(currentPath) for pattern in matches)
    flatMatches = [].concat (resolvedPaths)...

    [].concat (getFilesystemMatches(root, match) for match in flatMatches)...

  waitOnPatternLoad: () ->
    if @hasLoadedPatterns
      q()

    deferred = q.defer()
    @waitingOnPatternLoad.push(deferred)

    deferred.promise

module.exports =
  PathMatcher: PathMatcher
