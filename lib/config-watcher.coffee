fs = require('fs')
path = require('path')
CSON = require('season')

class ConfigWatcher
  _defaultConfigName: 'defaultPatterns.cson'
  _storedConfigName: 'related-patterns.cson'

  constructor: ->
    @configPath = path.join(atom.getConfigDirPath(), @_storedConfigName)

    @copyDefaultConfig(@configPath) if not fs.existsSync(@configPath)

  editConfig: ->
    atom.workspace.open(@configPath)

  setupConfig: (@callback) ->
    fs.watch(@configPath, => @reloadConfig(@configPath))

    @reloadConfig(@configPath)

  reloadConfig: (@configPath) ->
    CSON.readFile(@configPath, (error, config = {}) =>
      if config
        @callback(config)
    )

  copyDefaultConfig: (target) ->
    # Get the source
    packagePath = atom.packages.getLoadedPackage('related').path
    defaultConfigPath = path.join(packagePath, 'resources', @_defaultConfigName)

    inputStream = fs.createReadStream(defaultConfigPath)
    outputStream = fs.createWriteStream(target)

    inputStream.pipe(outputStream) if inputStream and outputStream

module.exports =
  ConfigWatcher: ConfigWatcher
