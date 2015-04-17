# Related for Atom
Related is a port of the [sublime-related-files](https://github.com/fabiokr/sublime-related-files) plugin for Atom.

Related provides a quick way to access files that are "related" to the file currently opened. The relationship
between files is defined through a set of patterns. For example, a file that matches the regex lib/(.+).coffee
might be related to the file spec/$1-spec.coffee -- that is, if I currently have the file lib/foo.coffee open
and the file spec/foo-spec.coffee exists, Related will show it as a file to jump to.

## Keymapping
By default, Related uses ctrl+shift+r.

## Configuration
Related doesn't come with a default pattern set. To add a pattern, see the "Edit patterns"
options under the Packages -> Related menu. 
