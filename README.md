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

![Screenshot](https://user-images.githubusercontent.com/5733531/93657005-04c4ac80-fa05-11ea-8340-19cd8388935d.png)

## Visual mode

![Screenshot](https://user-images.githubusercontent.com/5733531/93657004-042c1600-fa05-11ea-95be-6421f9278030.png)

## Insert mode

![Screenshot](https://user-images.githubusercontent.com/5733531/93722646-d95dd100-fb6e-11ea-95e0-95fc8726596c.png)

## Command-line Mode

![Screenshot](https://user-images.githubusercontent.com/5733531/93722648-d9f66780-fb6e-11ea-8195-807190df753c.png)

## Search Mode

![Screenshot](https://user-images.githubusercontent.com/5733531/93722644-d82ca400-fb6e-11ea-8aae-cbea95af5730.png)
