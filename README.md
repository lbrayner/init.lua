`init.vim` is my *vimrc*. That's the default *neovim* initialization file.

```
git clone 'https://github.com/lbrayner/dotvim'
cd dotvim
git submodule update --init
```

If you use *neovim*:

```
ln -s <FULL_PATH>/dotvim ~/.config/nvim
```

If you use *vim*:

```
ln -s <FULL_PATH>/dotvim ~/.vim
ln -s <FULL_PATH>/init.vim ~/.vimrc
```
