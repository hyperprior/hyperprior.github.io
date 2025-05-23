import lume from "lume/mod.ts";
import search from "lume/plugins/search.ts";
import prism from "lume/plugins/prism.ts";


const site = lume();
site.use(search());
site.use(prism({
  languages: [
    "markup", "css", "clike", "javascript", "typescript",
    "bash", "python", "rust", "go", "java", "c", "cpp",
    "json", "yaml", "toml", "sql", "graphql", "dockerfile",
    "nginx", "apache", "diff", "git", "regex"
  ],
  plugins: [
    "line-numbers",           // Add line numbers
    "show-language",          // Show language name
    "copy-to-clipboard",      // Copy button
    "toolbar",                // Toolbar container
    "download-button",        // Download code button
    "match-braces",          // Highlight matching braces
    "diff-highlight",        // Highlight diffs
    "command-line"           // Command line styling
  ],
  
  options: {
    "data-start": 1,
    "data-line": "1,3-5,7",
    "data-user": "user",
    "data-host": "localhost"
  }
}));


site.add("/styles.css");

export default site;
