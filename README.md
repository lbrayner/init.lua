**Requires Neovim 0.11.2 or greater.**

Remove or backup `~/.config/nvim`.

```
$ git clone 'https://github.com/lbrayner/init.lua' ~/.config/nvim
```

# As a bundle

You can use these configurations (`init.lua` + plugins) without affecting your
setup (`:h -u`).

```
$ git clone 'https://github.com/lbrayner/init.lua'
$ cd init.lua
init.lua$ nvim -u bundle.lua
```

# Install rocks.nvim

Before installing [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim),
check the
[requirements](https://github.com/nvim-neorocks/rocks.nvim#pencil-requirements)
(don't mind `netrw`).

Install `rocks.nvim`:

```
nvim --clean -c "source https://raw.githubusercontent.com/nvim-neorocks/rocks.nvim/master/installer.lua"
```

Keep the default Rocks installation path `~/.local/share/nvim/rocks`.

There is no need to change `init.lua`. Quit Neovim.

Create `~/.local/share/nvim/site/pack/rocks/start` for `rocks-git.nvim` (this is a bug):

```
mkdir -p ~/.local/share/nvim/site/pack/rocks/start
```

**Be aware** that `rocks-git.nvim` installs plugins as Vim packages in
`~/.local/share/nvim/site/pack/rocks/start`. See `:h packages`. Packages in
`pack/*/start` are implicitly loaded on start-up.

Start Neovim and run `:Rocks sync`. Restart Neovim.

Check [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim) for the latest
instructions.

# Screenshots

## Normal mode

![Screenshot from 2024-08-27 10-09-16](https://github.com/user-attachments/assets/4f824ae4-bbd9-46dc-801f-1a6132656d58)

## Visual mode

![Screenshot from 2024-08-27 10-09-36](https://github.com/user-attachments/assets/ca08f5d4-298a-458c-87cf-de399a7a2e75)

## Insert mode

![Screenshot from 2024-08-27 10-10-09](https://github.com/user-attachments/assets/306c0e4d-a652-4c1a-9263-216e6c3397ef)

## Command-line mode

![Screenshot from 2024-08-27 10-10-35](https://github.com/user-attachments/assets/cd3fdacc-33f7-47c2-8ce6-f2fa7f90538f)


## Command-line mode (search)

![Screenshot from 2024-08-27 10-11-03](https://github.com/user-attachments/assets/c8606137-5dbe-4b10-86de-0861c5d6d52a)

## Terminal-mode

![Screenshot from 2024-08-27 10-11-24](https://github.com/user-attachments/assets/92fe15ae-b6a3-4dec-9cd0-d90a2e2f4da2)


## Fugitive buffers

![Screenshot from 2024-08-27 10-13-14](https://github.com/user-attachments/assets/31995d0c-f2e4-4f33-b48d-a622432f7d90)


## Language Server

![Screenshot from 2024-08-27 10-15-06](https://github.com/user-attachments/assets/9ad45a59-bc28-4586-a7e8-c0465b7b5043)
![Screenshot from 2024-08-27 10-21-40](https://github.com/user-attachments/assets/f5880e44-400b-4d32-9b49-9e6a8498fc8e)
