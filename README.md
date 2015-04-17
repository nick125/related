# Related for Atom
Related is a port of the [sublime-related-files](https://github.com/fabiokr/sublime-related-files) plugin for Atom.

Related provides a quick way to access files that are "related" to the file currently opened.

The relationship between files is defined through a set of patterns. For example,
```cson
"lib/(.+).coffee": [
  "spec/$1-spec.coffee"
]
```
provides a mapping from a CoffeeScript file in lib/ to a unit test in spec/ -- that is, if I
currently have the file lib/foo.coffee open and the file spec/foo-spec.coffee exists, Related
will show it as a file to jump to. Each pattern can have multiple results, and a single file
can match multiple patterns.

## Keymapping
By default, Related uses ctrl+shift+r.

## Configuration
Related doesn't come with a default pattern set. To add a pattern, see the "Edit patterns"
options under the Packages -> Related menu.
