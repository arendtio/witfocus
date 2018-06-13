# Installation

## Arch Linux
For Arch Linux exists an AUR package which you can install
with one of the [AUR-Helpers](https://wiki.archlinux.org/index.php/AUR_helpers) (e.g. aurman):

```
aurman -S witfocus
```

## Dependencies

In order to run witfocus you require the following programs to be installed: `bash vim gawk coreutils`.
To build it from the source you will need the `autotools` (aka `autoconf` and `automake`).

## From Source

Download the source, extract it and run the following commands:
```
autoreconf --install

./configure
make
sudo make install
```

