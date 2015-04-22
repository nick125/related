fs = require('fs')
glob = require('glob')
path = require('path')
q = require('q')

fixPath = (orig, regex) ->
  sep = if regex then path.sep.replace('\\', '\\\\') else path.sep
  orig.replace(/\//g, sep)

qglob = q.nfbind(glob.glob)

class OutputPattern
  @patternParse: /([^#]+)#?(.*)/

  constructor: (@matcher, pattern) ->
    matches = OutputPattern.patternParse.exec(pattern)

    @pattern = fixPath(matches[1])
    @flags = if matches[2] then (matches[2].split('#')) else []

  isCreate: ->
    'create' in @flags

  execute: (inputPath) ->
    inputPath.replace(@matcher, @pattern)

class Pattern
  constructor: (matcher, outputs) ->
    @matcher = new RegExp(fixPath(matcher, true))
    @outputs = (new OutputPattern(@matcher, output) for output in outputs)

  isMatch: (inputPath) ->
    @matcher.exec(inputPath)

fsFilterMatches = (root, filePattern) ->
  expandedPath = path.join(root, filePattern)

  qglob(expandedPath).then((matches) ->
    (match for match in matches when fs.statSync(match).isFile())
  ).then((matches) ->
    return matches
  )

class PathMatcher
  @parsePathResult: (outputPath, exists) ->
    fsPath: outputPath
    fileName: path.basename(outputPath)
    exists: exists

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

    results = []
    for p in @patterns
      if not p.isMatch(currentPath)
        continue

      for output in p.outputs
        outputPath = output.execute(currentPath)

        if output.isCreate()
          expandedPath = path.join(root, outputPath)

          results.push(q([
            PathMatcher.parsePathResult(
              expandedPath,
              fs.existsSync(expandedPath) and fs.statSync(expandedPath).isFile()
            )]))
        else
          results.push(fsFilterMatches(root, outputPath).then((paths) ->
            (PathMatcher.parsePathResult(fsPath, true) for fsPath in paths)
          ))

    q.all(
      results
    ).then((results) ->
      # Flatten the results of q.all into a single array
      [].concat(results...)
    )

  waitOnPatternLoad: ->
    if @hasLoadedPatterns
      return q()

    deferred = q.defer()
    @waitingOnPatternLoad.push(deferred)

    deferred.promise

module.exports =
  PathMatcher: PathMatcher
