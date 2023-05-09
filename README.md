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

![Screenshot](https://user-images.githubusercontent.com/5733531/236511466-fbb19859-0ec8-4733-8cb1-a64974b37c94.png)

## Visual mode

![Screenshot](https://user-images.githubusercontent.com/5733531/236511428-cd4f4471-7263-4f30-af65-0366a87ccdae.png)

## Insert mode

![Screenshot](https://user-images.githubusercontent.com/5733531/236511440-3778db1e-5735-43c1-adeb-017f26e9cc45.png)

## Command-line mode

![Screenshot](https://user-images.githubusercontent.com/5733531/236511452-b6a4df7c-e49b-4ace-bca7-045b9ace0a8f.png)

## Command-line mode (search)

![Screenshot](https://user-images.githubusercontent.com/5733531/236511457-09f978da-4a95-4f15-a66d-50cb8f3e85fb.png)

## Terminal-mode

![Screenshot](https://user-images.githubusercontent.com/5733531/236511434-6a5a53a8-7b44-4dbb-9758-290ca98a7fb4.png)

## Fugitive buffers

![Screenshot](https://user-images.githubusercontent.com/5733531/237135198-09ad0fbc-68fc-4201-b4fc-e6a29a992aec.png)
![Screenshot](https://user-images.githubusercontent.com/5733531/237135188-bb771185-623d-4c63-a35c-8f6b216dc4b4.png)

## Language Server

![Screenshot](https://user-images.githubusercontent.com/5733531/237135178-ce72ca35-4a64-4abd-a28f-c2597c55ba6a.png)
![Screenshot](https://user-images.githubusercontent.com/5733531/237135156-0cebcbb3-9c41-4be2-a5e6-d742ceb6c0a8.png)
