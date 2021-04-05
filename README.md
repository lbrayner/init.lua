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

![Screenshot](https://user-images.githubusercontent.com/5733531/113568321-b5cc1680-95e6-11eb-9183-72c4bc52f65a.png)

## Visual mode

![Screenshot](https://user-images.githubusercontent.com/5733531/113568319-b5cc1680-95e6-11eb-9115-1c7ef04bc05c.png)

## Insert mode

![Screenshot](https://user-images.githubusercontent.com/5733531/113568315-b49ae980-95e6-11eb-9d3c-01023fc91d19.png)

## Command-line mode

![Screenshot](https://user-images.githubusercontent.com/5733531/113568498-0d6a8200-95e7-11eb-8e31-2756ef060a7b.png)

## Command-line mode (search)

![Screenshot](https://user-images.githubusercontent.com/5733531/113568318-b5338000-95e6-11eb-8994-c56739006e31.png)
