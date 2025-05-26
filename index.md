---
id: index
layout: index.vto
---
<a href="/about">
<pre class="command-line" data-user="hyperprior">
<code class="language-bash">
whoami | describe
</code>
</pre>
</a>

<h1 class="site-title">hyperprior</h1>
<pre>
<code class="language-bash">
#!/usr/bin/env nu
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
print (ls posts | to-post-table)
</code>
</pre>

<table class="shell-table">
      <tr>
        <th>#</th>
        <th>name</th>
        <th>size</th>
        <th>modified</th>
      </tr>
<tr><td>0</td>
  <td><a href="posts/good-shit" class="sh-link">good shit</td>
  <td>2.1 kB</td>
  <td>2 days ago</td></tr><tr><td>1</td>
  <td><a href="posts/nu-shell" class="sh-link">nushell is something different entirely</td>
  <td>332 B</td>
  <td>2 days ago</td></tr><tr><td>2</td>
  <td><a href="posts/what-im-reading" class="sh-link">what i'm reading</td>
  <td>3.2 kB</td>
  <td>7 minutes ago</td></tr>
</table>
