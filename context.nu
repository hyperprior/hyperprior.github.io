#!/usr/bin/env nu

let system = 'you are building a static site for a personal blog using lume
all pages are .md files at the root level
all blog posts are under posts/
all templates are done with vento templates in .vto files

please look at each file to understan the overall structure of the project,
and then you will be asked specific questions to improve the site.

'

let files = fd --type file
  | split row "\n"
  | filter {|file| $file !~ '.html|.nu|CNAME|404.md|README|flake'}
  | each {|file| $'
<file>
  <name>($file)</name>
  (open $file)
</file>'
}
  | reduce { |elt, acc| $acc + $elt }

print $system + $files
