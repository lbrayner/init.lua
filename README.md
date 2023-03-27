**Requires Neovim 0.8.0+.**

`init.vim` is my *vimrc*. That's the default *Neovim* initialization file.

```
$ git clone 'https://github.com/lbrayner/dotvim'
$ cd dotvim
dotvim$ git submodule update --init
```

# As a bundle

You can use these configurations (`init.vim` + plugins) without affecting your
setup (`:h -u`).

```
dotvim$ nvim -u bundle.vim
```

# The regular way

```
dotvim$ ln -s "$(readlink -f ..)"/dotvim ~/.config/nvim
```

Packages (`:h packages`) are submodules in `pack/bundle/start`.

# Screenshots

## Normal mode

![Screenshot](https://user-images.githubusercontent.com/5733531/122801268-463afe80-d29a-11eb-9b78-f87cee3ee49c.png)

## Visual mode

![Screenshot](https://user-images.githubusercontent.com/5733531/122801265-463afe80-d29a-11eb-9494-a46aaf93897a.png)

## Insert mode

![Screenshot](https://user-images.githubusercontent.com/5733531/122801259-4509d180-d29a-11eb-84a9-567958ab5f2d.png)

## Command-line mode

![Screenshot](https://user-images.githubusercontent.com/5733531/122801262-45a26800-d29a-11eb-8950-aeff35a8f013.png)

## Command-line mode (search)

![Screenshot](https://user-images.githubusercontent.com/5733531/122801263-45a26800-d29a-11eb-8db9-be617eea7361.png)

## Terminal-mode

![Screenshot](https://user-images.githubusercontent.com/5733531/174203958-b8139cce-4893-424b-9c8f-75ad7eff6f4e.png)
