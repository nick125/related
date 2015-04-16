{CompositeDisposable} = require 'atom'

{RelatedViewSelect} = require './related-view'
{PathMatcher} = require './path-matcher'

defaultPatterns = [
  {
    in: ".+/(.+).coffee"
    out: [
      "spec/$1-spec.coffee"
      "test/$1-bar.coffee"
    ]
  },
  {
    in: ".+/(.+)-spec.coffee"
    out: [
      "*/$1.coffee"
    ]
  }
]

module.exports =
  config:
    patterns:
      title: 'Patterns'
      description: 'The patterns to use to match the current file to potential related files'
      type: 'array'
      default: defaultPatterns
      items:
        type: 'object'
        properties:
          in:
            title: 'Input Filter'
            description: 'Regex that matches a filename'
            type: 'string'
          out:
            type: 'array'
            title: 'Mapped Files'
            description: 'Files to display, if they exist and the input filter is matched'
            items:
              type: 'string'
  subscriptions: null
  pathMatcher: null

  activate: () ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add(atom.commands.add('atom-workspace', 'related:showRelated': => @showRelated()))

    @pathMatcher = new PathMatcher()

    @subscriptions.add(atom.config.observe('related.patterns', (patterns) => @pathMatcher.loadPatterns(patterns)))

  deactivate: ->
    @subscriptions.dispose()

  showRelated: () ->
    @view ?= new RelatedViewSelect(@pathMatcher)
    @view.toggle()
