#!/env/bin/env nu

def frontmatter []: binary -> list<string> {
  lines
  | split list '---'
  | skip
  | flatten
}
def title []: list<string> -> string {
  $in
  | where {|line| $line =~ 'title:'}
  | str replace 'title:' ''
  | str trim
  | first
}

def to-post-table [] {
  $in
  | select name modified size
  | where name ends-with '.md'
  | enumerate
  | each {|post|
    $post.item
    | merge {
      row-number: $post.index
      title: (open $post.item.name | frontmatter | title)
      slug: ($post.item.name | str replace -r '(.+).md' '$1')
      modified: ($post.item.modified | date humanize)
    }
  }
}

def to-html-table-row [
  # record
  # last-updated: string,
  # title: string
  # row-number: int
]: record -> string {
  $in
  | $'<tr><td>($in.row-number)</td>
  <td><a href="($in.slug)" class="sh-link">($in.title)</td>
  <td>($in.size)</td>
  <td>($in.modified)</td></tr>'
}


let lps = (view source to-post-table)

let output = $"---
id: index
layout: index.vto
---
<a href=\"/about\">
<pre class=\"command-line\" data-user=\"hyperprior\">
<code class=\"language-bash\">
whoami | describe
</code>
</pre>
</a>

<h1 class=\"site-title\">hyperprior</h1>
<pre>
<code class=\"language-bash\">
#!/usr/bin/env nu
($lps)
print \(ls posts | to-post-table\)
</code>
</pre>

<table class=\"shell-table\">
      <tr>
        <th>#</th>
        <th>name</th>
        <th>size</th>
        <th>modified</th>
      </tr>
(ls posts | to-post-table | each {|post| to-html-table-row } | str join)
</table>
"

$output | save index.md --force

print $output
print (ls posts | to-post-table | (select row-number title size modified))
