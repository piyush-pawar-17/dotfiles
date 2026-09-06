# Windows Setup

This guide configures the Windows tiling desktop in `windows/`. It uses
[GlazeWM](https://github.com/glzr-io/glazewm) for window management and
[Zebar](https://github.com/glzr-io/zebar) for the status bar.

## Requirements

- Windows 11 is recommended because GlazeWM's configured window-border and
  corner-style effects use Windows 11 APIs
- Install a current Node.js LTS release and [pnpm](https://pnpm.io/installation)
  to build the Zebar React theme
- Install the applications launched by the keybindings: Alacritty and Google
  Chrome

Install the applications with winget:

```powershell
winget install GlazeWM
winget install Zebar
winget install Alacritty.Alacritty
winget install Google.Chrome
```

Restart the terminal after installing pnpm so it is available on `PATH`.

## Install Configuration

GlazeWM and Zebar load their configuration from `%USERPROFILE%\.glzr`. Run the
following commands from the repository root to create the destination paths and
copy the repository files:

```powershell
$configRoot = Join-Path $HOME ".glzr"
New-Item -ItemType Directory -Force "$configRoot\glazewm", "$configRoot\zebar"
Copy-Item ".\windows\glaze\config.yaml" "$configRoot\glazewm\config.yaml" -Force
Copy-Item ".\windows\zebar\settings.json" "$configRoot\zebar\settings.json" -Force
Copy-Item ".\windows\zebar\theme" "$configRoot\zebar\theme" -Recurse -Force
```

## Build the Zebar Theme

The configured Zebar widget loads `theme/dist/index.html`, so build the React
and Vite project after copying it:

```powershell
Set-Location "$HOME\.glzr\zebar\theme"
pnpm install --frozen-lockfile
pnpm build
```

Use `pnpm dev` while editing the theme and `pnpm lint` to check it. Run
`pnpm build` again before restarting Zebar.

## GlazeWM Behavior

The GlazeWM configuration starts Zebar and defines nine workspaces. Workspace
1 is kept alive for Alacritty, and Chrome is moved to workspace 2. The layout
uses 8px gaps, focused and unfocused Catppuccin-inspired borders, and a 48px
top gap for Zebar.

Important keybindings:

- `Alt+Enter`: launch Alacritty
- `Alt+C`: launch Chrome
- `Alt+E`: open File Explorer
- `Alt+H/J/K/L` or arrow keys: move focus
- `Alt+Shift+H/J/K/L`: move the focused window
- `Alt+1` through `Alt+9`: switch workspaces
- `Alt+Shift+1` through `Alt+Shift+9`: move a window and switch to its workspace
- `Alt+Shift+Space`: toggle floating mode
- `Alt+F`: toggle fullscreen
- `Alt+R`: enter resize mode, then use H/J/K/L or arrow keys
- `Alt+Shift+R`: reload the GlazeWM configuration
- `Alt+Shift+E`: exit GlazeWM

Update the application commands and workspace rules in
`windows/glaze/config.yaml` if Alacritty or Chrome use different executable
names on this machine.

## Start and Update

Start GlazeWM from the Start menu. Its startup command launches Zebar, which
loads `%USERPROFILE%\.glzr\zebar\settings.json` and the default theme preset.

After editing GlazeWM configuration, use `Alt+Shift+R`. After changing the
Zebar theme, rebuild it and restart Zebar or restart GlazeWM. This repository's
Windows directory is intentionally excluded from Stow.
