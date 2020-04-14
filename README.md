# love-build

![Test](https://github.com/nhartland/love-build/workflows/Test/badge.svg)

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

To build and upload a LÖVE 11.3 project with the `main.lua` at the root of your
repository, use the following job steps:

```yaml
steps:
- uses: actions/checkout@v2
# Build the applications
- uses: nhartland/love-build@v1-beta
  with:
   app_name: 'hello_world'
   love_version: '11.3'
# Upload the built applications
- uses: actions/upload-artifact@v1
  with:
    name: built-applications
    path: 'release'
```

### Extended configuration

```yaml
steps:
- uses: actions/checkout@v2
- uses: nhartland/love-build@v1-beta
  with:
    app_name: 'hello_world'
    love_version: '11.3'
    # Sets up luarocks dependencies according to provided rockspec
    # Use the path relative to your repository root.
    dependencies: 'dependencies-1-1.rockspec'
    # Use when the `main.lua` is in a subdirectory of your repository (here in `src/love`).
    source_dir: 'src/love'
    # Specifies the output location for the distributables, by default 'release'.
    result_dir: 'nondefault_result_dir'
```

To see the full options specification please refer to the [action.yml](action.yml).

### Produced artifacts

The built applications are located in the `results_dir` path, by default the
root of your repository. This action returns four output variables specifying
the filenames relative to the working directory.

```yaml
  love-filename: 
    description: 'Filename of built love file'
  win32-filename: 
    description: 'Filename of built win32 application'
  win64-filename: 
    description: 'Filename of built win64 application'
  macos-filename: 
    description: 'Filename of built macos application'
```

The applications can therefore be built and individually uploaded with the
following steps: 

```yaml
steps:
- uses: actions/checkout@v2
- uses: nhartland/love-build@v1-beta
  id: love-build
  with:
    app_name: 'hello_world'
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
    name: win64-build
    path: ${{ steps.love-build.outputs.win64-filename }}
- uses: actions/upload-artifact@v1
  with:
    name: love-build
    path: ${{ steps.love-build.outputs.love-filename }}
```

### Working Examples

In this directory are two test cases, a basic "Hello World" with no dependencies
and a Game of Life simulation using the
[forma](https://github.com/nhartland/forma) package installed via `loverocks`.

- [Test Applications](tests)
- [Test Workflow](.github/workflows/test_workflow.yml)

### Limitations

This action so far only performs the minimal build required for getting
applications running, for example icons are not yet configurable.

Furthermore the macOS build is unverified by Apple and therefore will need
to be manually opened in the Security and Preferences pane at least for the
first time it is run.
