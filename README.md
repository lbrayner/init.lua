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

![Screenshot](https://user-images.githubusercontent.com/5733531/93657020-2887f280-fa05-11ea-9ba7-d2c315189a0a.png)

## Command-line mode

![Screenshot](https://user-images.githubusercontent.com/5733531/93722648-d9f66780-fb6e-11ea-8195-807190df753c.png)

## Command-line mode (search)

![Screenshot](https://user-images.githubusercontent.com/5733531/93722644-d82ca400-fb6e-11ea-8aae-cbea95af5730.png)
