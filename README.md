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

![Screenshot](https://user-images.githubusercontent.com/5733531/114028946-663c5380-984f-11eb-9d9b-cf69c32b2c88.png)

## Visual mode

![Screenshot](https://user-images.githubusercontent.com/5733531/114028940-65a3bd00-984f-11eb-97b1-a9fc61a097a2.png)

## Insert mode

![Screenshot](https://user-images.githubusercontent.com/5733531/114028944-65a3bd00-984f-11eb-9d7d-f18e98232ed1.png)

## Command-line mode

![Screenshot](https://user-images.githubusercontent.com/5733531/114028939-650b2680-984f-11eb-8785-e78dc0fff121.png)

## Command-line mode (search)

![Screenshot](https://user-images.githubusercontent.com/5733531/114028934-64729000-984f-11eb-8deb-6e101f9f7bed.png)
