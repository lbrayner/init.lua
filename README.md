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

![Screenshot](https://user-images.githubusercontent.com/5733531/70392788-55ad6c00-19c2-11ea-9627-7e01922d4bbd.png)

## Insert mode

![Screenshot](https://user-images.githubusercontent.com/5733531/70392787-5514d580-19c2-11ea-9d5e-f440cb868623.png)

## Visual mode

![Screenshot](https://user-images.githubusercontent.com/5733531/70392785-5514d580-19c2-11ea-8d17-da39fff08de8.png)
