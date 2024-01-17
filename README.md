**Requires Neovim 0.10.0 or greater.**

```
$ git clone 'https://github.com/lbrayner/init.lua'
$ cd init.lua
init.lua$ git submodule update --init
```

# As a bundle

You can use these configurations (`init.lua` + plugins) without affecting your
setup (`:h -u`).

```
init.lua$ nvim -u bundle.lua
```

# The regular way

```
init.lua$ ln -s "$(readlink -f ..)"/init.lua ~/.config/nvim
```

Packages (`:h packages`) are submodules in `pack/bundle/start`.

# Screenshots

## Normal mode

![Screenshot](https://user-images.githubusercontent.com/5733531/278879863-8b28ff16-074f-4a5b-a2cf-d8ffb3f3bb4f.png)

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

![Screenshot](https://user-images.githubusercontent.com/5733531/278879467-9280913e-070c-421f-995d-06af1f8cced0.png)

## Language Server

![Screenshot](https://user-images.githubusercontent.com/5733531/278879472-f870d669-7353-4f84-b196-40e16a4462b1.png)
![Screenshot](https://user-images.githubusercontent.com/5733531/278879470-f1acba2a-1b80-4582-9b5e-ede43ee24772.png)
