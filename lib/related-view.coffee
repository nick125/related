{SelectListView} = require 'atom-space-pen-views'

class RelatedViewSelect extends SelectListView
  initialize: (@pathMatcher) ->
    super
    @addClass 'overlay from-top'

  viewForItem: (item) ->
    """
    <li>
      <div>#{item.displayPath}</div>
      <div><small>#{item.realPath}</small></div>
    </li>
    """

  confirmed: (item) ->
    @cancel()

    atom.workspace.open(item.realPath)

  getFilterKey: ->
    'displayPath'

  show: ->
    @storeFocusedElement()

    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  hide: ->
    @panel.hide()

  toggle: ->
    if @panel?.isVisible()
      @cancel()
    else
      if @populate()
        @show()

  getRoot: (filename, paths) ->
    for pathName in paths
      if filename.indexOf(pathName) >= 0
        return pathName

  processItem: (item) ->
    return displayPath: path.basename(item), realPath: item

  populate: ->
    currentPath = atom.workspace.getActiveTextEditor().getPath()
    if currentPath
      root = @getRoot currentPath, atom.project?.getPaths()
      newPath = path.relative(root, currentPath)

      matches = (@processItem(item) for item in @pathMatcher.findMatches(root, newPath))

      @setItems(matches)

      return true
    else
      return false

  cancelled: ->
    @hide()

module.exports =
  RelatedViewSelect: RelatedViewSelect
