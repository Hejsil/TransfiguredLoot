# Transfigured Loot

A set of Rabbit and Steel mods that adds "transfigured" version of loot. Inspired by Path of Exile
[Transfigured Gems](https://www.poewiki.net/wiki/Transfigured_skill_gem).

The mods are currently work in progress. Currently a little over 60 pieces of loot have been
implemented, but none of them have art or correct colors.

## Build

As you might have noticed, there are no csv or ini files in this repository. That is because
the Transfigured Loot mods are generated from the `generate.zig` "script".

TODO: Pointers on how to get zig installed

To generate the mods, run:

```sh
zig run generate.zig
```

This will try to find the Rabbit and Steel mods folder and generate the mods inside it (currently
only works on Linux). The mods folder can be specified like so:

```sh
# Generates the mods in the "Mods" folder in the current directory
zig run generate.zig -- Mods
```
