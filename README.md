# aergia

aergia is a small plugin to that helps you manage snippets.

### installation

#### [pathogen](https://github.com/tpope/vim-pathogen):

```bash
cd ~/.vim/bundle
git clone https://github.com/henricattoire/aergia.git
```

### snippets

* stored in a directory (determined by `g:aergia_snippets`)
```
~/.vim/bundle/aergia/snippets
```

It is possible to structure this directory to your liking because aegria also searches
its subdirectories when looking for snippets.

* filetype aware snippets
```
python_def
```

Filetype aware snippets are snippets that only work in files of the given filetype. In the example, 
a ```def``` snippet is created for python files (syntax: filetype_key or filetype-key). Filetype aware 
snippets have a priority over normal snippets.

* example of a snippet file
```
def {+}():
    {+}
```

Snippet files can contains tags `{+}` and it is possible to jump from tag to tag using the same key
to invoke a snippet.
