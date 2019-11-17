`init.vim` is my *vimrc*. That's the default *neovim* initialization file.

```
$ git clone 'https://github.com/lbrayner/dotvim'
$ cd dotvim
dotvim$ git submodule update --init
```

# As a bundle

You can use these configurations (`init.vim` + plugins) without affecting your
setup (`:h -u`).

```
dotvim$ vim -u bundle.vim
```

Note that vim could also be `nvim` or `gvim`.

# The regular way

If you use *neovim*:

```
dotvim$ ln -s "$(readlink -f ..)"/dotvim ~/.config/nvim
```

If you use *vim*:

```
dotvim$ ln -s "$(readlink -f ..)"/dotvim ~/.vim
dotvim$ ln -s "$(readlink -f ..)"/dotvim/init.vim ~/.vimrc
```

Packages (`:h packages`) are submodules in `pack/bundle/start`.

![Screenshot](https://user-images.githubusercontent.com/5733531/69013343-b3b7d800-095d-11ea-8f93-423edb5addd1.png)
