{CompositeDisposable} = require('atom')

{RelatedViewSelect} = require('./related-view')
{PathMatcher} = require('./path-matcher')
{ConfigWatcher} = require('./config-watcher')

class Related
  subscriptions: null
  pathMatcher: null

  activate: ->
    @subscriptions = new CompositeDisposable()
    @pathMatcher = new PathMatcher()

    @configWatcher = new ConfigWatcher()
    @configWatcher.setupConfig((config) => @pathMatcher.loadPatterns(config))

    @setupEvents()

  setupEvents: ->
    @subscriptions.add(atom.commands.add('atom-workspace',
      'related:show-related-files': => @showRelated()))
    @subscriptions.add(atom.commands.add('atom-workspace',
      'related:edit-related-patterns': => @editConfig()))

  deactivate: ->
    @subscriptions.dispose()

  showRelated: ->
    @view ?= new RelatedViewSelect(@pathMatcher)
    @pathMatcher.waitOnPatternLoad().then(=>
      @view.toggle()
    )

  editConfig: ->
    @configWatcher.editConfig()

module.exports =
  new Related()
