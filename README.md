# OpenGamepadUI Plugin Template

This repository contains a reference template for creating a plugin for
[OpenGamepadUI](https://github.com/ShadowBlip/OpenGamepadUI).

## Requirements

You will need to install the dependencies for OpenGamepadUI listed
[here](https://github.com/ShadowBlip/OpenGamepadUI#requirements).

## Usage

This repository contains the basic files you need to write your own plugin.
It includes a [Makefile](Makefile) which you can use to build and package your
plugin. For help using the Makefile, run:

```bash
make help
```

Use the following steps to get started:

1. Fork this repository and clone your repository locally

2. Clone the [OpenGamepadUI](https://github.com/ShadowBlip/OpenGamepadUI) repository next to your plugin folder. It should look something like this:

```bash
$ ls
OpenGamepadUI
OpenGamepadUI-plugin-template
```

3. Edit `plugin.json` in your plugin repository and fill our your plugin details

4. Run `make build` from your plugin repository to symlink your plugin inside the OpenGamepadUI project directory

5. Open the OpenGamepadUI project in the Godot editor

Once you have completed these steps, you can use the Godot editor to write your
plugin.

You can build and install this plugin with:

```bash
make install
```

For more in-depth documentation on how to write plugins, refer to the
[Plugin Development Guide](https://github.com/ShadowBlip/OpenGamepadUI/blob/main/docs/PLUGINS.md)

## Distribution

You can distribute your plugin by building a plugin package with:

```bash
make dist
```

This will create a zip file under the `dist` directory.

To have your plugin be considered for inclusion in the OpenGamepadUI plugin store,
create a pull request to the [OpenGamepadUI-plugins](https://github.com/ShadowBlip/OpenGamepadUI-plugins)
repository with an entry for your plugin to have your plugin listed in the
plugin store.
