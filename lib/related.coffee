{CompositeDisposable} = require('atom')

{RelatedViewSelect} = require('./related-view')
{PathMatcher} = require('./path-matcher')
{ConfigWatcher} = require('./config-watcher')

class Related
  config:
    openSingleItemAutomatically:
      type: 'boolean'
      default: false
      description: 'If only a single file matches, automatically open that item instead of prompting'
    onlyShowCreateIfNoResults:
      type: 'boolean'
      default: false
      description: 'Only offer to create files if there are no pre-existing results'

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
