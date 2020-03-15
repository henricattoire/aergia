# aergia

aergia is a small plugin that helps you manage snippets.

![demo](https://media.giphy.com/media/MCLkzZHaazl5YP4XBG/source.gif)

### installation

#### [pathogen](https://github.com/tpope/vim-pathogen):

```bash
cd ~/.vim/bundle
git clone https://github.com/henricattoire/aergia.git
```

Or use your favorite package manager to install `aergia`.

### configuration

* key (default: `<c-a>`)
```vim
let g:aergia_key = '<tab>'
```

Key used to trigger `aergia`. Setting this to `<tab>` when you have other plugins like supertab installed, can cause unexpected behaviour.


* snippets (default: `~/.vim/bundle/aergia/snippets`)
```vim
let g:aergia_snippets = '~/snippets'
```

It is possible to structure this directory to your liking because `aegria` also searches
its subdirectories when looking for snippets.


### snippets

* example of a snippet file
```
def {+}():
    {+}
```

Snippet files can contains tags `{+}` and it is possible to jump from tag to tag using the same key
to invoke a snippet. Putting this snippet in a file called `def` will allow you to use the snippet
by typing `def` [key](#configuration) in insert mode.

* named tags
```
def {name}():
    """ {name}: {+} """
    {+}
```

Snippet files can also contain named tags. When you set the value for one tag, `aergia` will automatically change
all other tags with the same name.

* command tags
```
public class {$expand('%:t:r')=name} {
  public {name}() {
    {+}
  }
}
```

If a tag starts with a `$`, the tag will be replaced with whatever output the command (read: function) returned. You can
also let command tags mimic the behaviour of a named tag (syntax: `{$command=name}`).

* filetype aware snippets
```
python_def
```

Filetype aware snippets are snippets that only work in files of the given filetype. In the example, 
a `def` snippet is created for python files (syntax: `filetype_name` or `filetype-name`). Filetype aware 
snippets have a priority over normal snippets.
