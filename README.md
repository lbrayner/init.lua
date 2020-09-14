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

# Screenshots

## Normal mode

![Screenshot](https://user-images.githubusercontent.com/5733531/93029066-e0c12f80-f5ee-11ea-91ec-d99f8f84d161.png)

## Visual mode

![Screenshot](https://user-images.githubusercontent.com/5733531/93029065-df900280-f5ee-11ea-9c93-a26c0042f9f7.png)

## Insert mode

![Screenshot](https://user-images.githubusercontent.com/5733531/93029060-dbfc7b80-f5ee-11ea-938f-7c025cfc4c06.png)

