{SelectListView} = require('atom-space-pen-views')
path = require('path')

_existsTemplate = (item) ->
  """
  <li>
    <div>#{item.fileName}</div>
    <div><small>#{item.fsPath}</small></div>
  </li>
  """
_createTemplate = (item) ->
  """
  <li>
    <div>Create #{item.fileName}</div>
    <div><small>#{item.fsPath}</small></div>
  </li>
  """

class RelatedViewSelect extends SelectListView
  initialize: (@pathMatcher) ->
    super
    @addClass('overlay from-top')

  viewForItem: (item) ->
    if item.exists then _existsTemplate(item) else _createTemplate(item)

  confirmed: (item) ->
    @cancel()

    atom.workspace.open(item.fsPath)

  getFilterKey: ->
    'displayPath'

  show: ->
    @storeFocusedElement()

    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  hide: ->
    @panel?.hide()

  toggle: ->
    if @panel?.isVisible()
      @cancel()
    else
      @populate().done((shouldShow) =>
        @show() if shouldShow
      )

  getRoot: (filePath, rootPaths) ->
    rootPaths = ("#{rootPath}#{path.sep}" for rootPath in rootPaths)

    until rootPaths.indexOf("#{filePath}#{path.sep}") >= 0
      filePath = path.dirname(filePath)

    return filePath

  populate: ->
    currentPath = atom.workspace.getActiveTextEditor().getPath()
    if currentPath
      root = @getRoot(currentPath, atom.project?.getPaths())
      newPath = path.relative(root, currentPath)

      return @pathMatcher.findMatches(root, newPath).then((items) =>
        createItems = (item for item in items when not item.exists)
        existingItems = (item for item in items when item.exists)

        # Remove the create items if we have existing results
        if existingItems.length > 0 and atom.config.get('related.onlyShowCreateIfNoResults')
          items = existingItems

        items = items.sort((a, b) -> (not a.exists - not b.exists))

        if (items.length is 1 and atom.config.get('related.openSingleItemAutomatically'))
          @confirmed(items[0])
          return false
        else
          @setItems(items)
          return true
      )

    return q(false)

  cancelled: ->
    @hide()

module.exports =
  RelatedViewSelect: RelatedViewSelect
