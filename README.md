# Related for Atom
Related is a port of the [sublime-related-files](https://github.com/fabiokr/sublime-related-files) plugin for Atom.

Related provides a quick way to access files that are "related" to the file currently opened. For example, Related includes
a set of patterns for switching between C/C++/Objective-C source and header files.

![Related in action](https://raw.githubusercontent.com/nick125/related/master/related.gif)

## What is a "related" file?
The relationship between files is defined through a set of **patterns**. For example,
```cson
"lib/(.+).coffee": [
  "spec/$1-spec.coffee"
]
```
provides a mapping from a CoffeeScript file (through a **matcher**) in lib/ to a unit test in spec/ (through a **result**)
-- that is, if I currently have the file lib/foo.coffee open and the file spec/foo-spec.coffee exists, Related
will show it as a file to jump to. Each pattern can have multiple results, and a single file
can match multiple patterns.

### Creating files
Related allows you to optionally create related files by specifying the 'create' flag at the end of your result. For example,
with the currently open file "lib/foo.coffee",
```cson
"lib/(.+).coffee": [
  "spec/$1-spec.coffee#create"
]
```
would prompt you to create "spec/foo-spec.coffee" if it doesn't already exist.

## Keymapping
By default, Related uses ctrl+shift+r.

## Configuration
Related includes a limited default pattern set, but there are some additional examples in the examples/ directory. To add a pattern,
see the "Edit related patterns" options under the Packages -> Related menu.

Related provides the following configuration options:
 * openSingleItemAutomatically - If only a single existing file matches the pattern, automatically open it instead of prompting
 * onlyShowCreateIfNoResults - Only offer to create files if there are no other existing results.
