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

<img width="1920" height="1080" alt="normal" src="https://github.com/user-attachments/assets/a232efba-6199-443b-bafa-b707a3fda491" />

## Visual mode

<img width="1920" height="1080" alt="visual" src="https://github.com/user-attachments/assets/33068e38-eea8-403c-b08e-8c8ffdeac0b7" />

## Select mode

<img width="1920" height="1080" alt="select" src="https://github.com/user-attachments/assets/c5108ef7-6094-433c-aef9-4a6a363d1954" />

## Insert mode

<img width="1920" height="1080" alt="insert" src="https://github.com/user-attachments/assets/6c71278e-6199-4dfe-a25a-96de92f191eb" />

## Command-line mode

<img width="1920" height="1080" alt="command" src="https://github.com/user-attachments/assets/d8f18bb7-2c5c-4eae-bacf-34d2d2724401" />

## Command-line mode (search)

<img width="1920" height="1080" alt="search" src="https://github.com/user-attachments/assets/e9c97d42-7790-4c48-b264-9ee9d5242d6f" />

## Terminal-mode

<img width="1920" height="1080" alt="terminal" src="https://github.com/user-attachments/assets/4838e458-de82-4403-bddb-f793a5559df9" />

## Fugitive buffers

<img width="1920" height="1080" alt="fugitive" src="https://github.com/user-attachments/assets/68f607a4-e947-468b-aeec-37ff9f0e7297" />

## Language Server

<img width="1920" height="1080" alt="lsp1" src="https://github.com/user-attachments/assets/c3041102-60fc-48ba-b4ff-3d987d1e73d5" />
<img width="1920" height="1080" alt="lsp2" src="https://github.com/user-attachments/assets/0999a17f-9040-4977-8fa0-a02ebccd6d26" />
