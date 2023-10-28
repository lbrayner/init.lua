**Requires Neovim 0.10.0 or greater.**

```
$ git clone 'https://github.com/lbrayner/dotvim'
$ cd dotvim
dotvim$ git submodule update --init
```

# As a bundle

You can use these configurations (`init.lua` + plugins) without affecting your
setup (`:h -u`).

```
dotvim$ nvim -u bundle.lua
```

# The regular way

```
dotvim$ ln -s "$(readlink -f ..)"/dotvim ~/.config/nvim
```

Packages (`:h packages`) are submodules in `pack/bundle/start`.

# Screenshots

## Normal mode

![Screenshot](https://user-images.githubusercontent.com/5733531/277468651-b8ec387c-9b0f-464a-a3be-eb9e4c00fcf2.png)

## Visual mode

![Screenshot](https://user-images.githubusercontent.com/5733531/277468644-6206d0d8-bff0-4d0b-ac4a-09f6562f5128.png)

## Insert mode

![Screenshot](https://user-images.githubusercontent.com/5733531/277468649-2664962d-8d64-41b9-b35c-9c055e21c196.png)

## Command-line mode

![Screenshot](https://user-images.githubusercontent.com/5733531/277468645-26d2ac22-5340-49b2-8c0c-526c9e139f4c.png)

## Command-line mode (search)

![Screenshot](https://user-images.githubusercontent.com/5733531/277468641-48804bb7-0e0f-4adc-a051-cd56b9fddc71.png)

## Terminal-mode

![Screenshot](https://user-images.githubusercontent.com/5733531/277469194-36532403-e079-416d-b47f-10416a07a6bb.png)

## Fugitive buffers

![Screenshot](https://user-images.githubusercontent.com/5733531/277468633-516cfd70-f4d5-4dc0-be23-14acb6007fd4.png)
![Screenshot](https://user-images.githubusercontent.com/5733531/277468627-7ed4190e-5cd5-4551-ab4e-7a1cfd492c7d.png)

## Language Server

![Screenshot](https://user-images.githubusercontent.com/5733531/277468624-480d521d-9918-45a4-be85-4e6f3faa9859.png)
![Screenshot](https://user-images.githubusercontent.com/5733531/277468616-44baae72-7f77-4dff-b966-a4a224abb8e2.png)
