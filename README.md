# love-build
GitHub Action for building a [LÖVE](https://love2d.org/) Project. 

This action produces a LÖVE file, along with macOS and Windows executable
packages for a LÖVE project. For projects making use of
[luarocks](https://luarocks.org/) packages, this build action supports
[loverocks](https://github.com/Alloyed/loverocks) when a `conf.lua` is supplied
in the source directory and the `enable_loverocks` input flag is set to true.

For macOS application configuration, you can supply an `Info.plist` file in the
source directory which will be copied into the built application. If not
provided, the default LÖVE `Info.plist` will be used.

### Basic Configuration

To build a LÖVE 11.3 project with the `main.lua` at the root of your repository,
use the following job steps to check out and build your project.

```yaml
steps:
- uses: actions/checkout@v2
- uses: nhartland/love-build@master
  with:
   app_name: 'hello_world'
   love_version: '11.3'
```

### Extended configuration

```yaml
steps:
- uses: actions/checkout@v2
- uses: nhartland/love-build@master
with:
  app_name: 'hello_world'
  love_version: '11.3'
  # runs `loverocks deps` in the source_dir to build luarocks dependencies.
  enable_loverocks: true 
  # Use when the `main.lua` is in a subdirectory of your repository (here in `src/love`).
  source_dir: ${{ github.workspace }}/src/love
  # Specifies the location for temporary build files (by default `love-build` in your repository root.
  # You should only need to change this if you are already using a directory `love-build` in your repo root.
  build_dir: ${{ github.workspace }}/otherbuilddir
  # Specifies the output location for the distributables, by default the repository root directory.
  result_dir: ${{ github.workspace }}/result_dir
```

To see the full options specification please refer to the [action.yml](action.yml).

### Produced artifacts

The built distributables are located in the `results_dir` path, by default the root of your repository.
This action returns three output variables specifying the filenames relative to `results_dir`.

```yaml
  love-filename: 
    description: 'Filename of built love file'
  win32-filename: 
    description: 'Filename of built win32 application'
  macos-filename: 
    description: 'Filename of built macos application'
```

If `results_dir` is left as default (the GitHub working directory), the produced artifacts can therefore be uploaded with the following steps:
```yaml
steps:
- uses: actions/checkout@v2
- uses: nhartland/love-build@master
  id: love-build
  with:
    app_name: 'game_of_life'
    love_version: '11.3'
- uses: actions/upload-artifact@v1
  with:
    name: macos-build
    path: ${{ steps.love-build.outputs.macos-filename }}
- uses: actions/upload-artifact@v1
  with:
    name: win32-build
    path: ${{ steps.love-build.outputs.win32-filename }}
- uses: actions/upload-artifact@v1
  with:
    name: love-build
    path: ${{ steps.love-build.outputs.love-filename }}
```

### Working Examples

In this directory are two test cases, a basic "Hello World" with no `luarocks`
dependencies and a Game of Life simulation using the
[forma](https://github.com/nhartland/forma) package installed via `loverocks`.

The code for these test applications can be found in the [tests](tests).

The build workflows for these can be found in the [GitHub workflow
subdirectory](.github/workflows/Tests.yml).


### Limitations

This action so far only performs the minimal build required for getting
applications running, for example icons are not yet configurable.

Furthermore the macOS build is unverified by Apple and therefore will need
to be manually opened in the Security and Preferences pane at least for the
first time it is run.
