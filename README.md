# Aki

A lightweight VM for running Linux under macOS using the
[Virtualization.framework](https://developer.apple.com/documentation/virtualization).

## Requirements

- macOS 11+ (Intel, Apple Silicon)
- Swift 5.3+

## Installation

Clone this repository:

```shell
git clone https://github.com:domcorvasce/Aki
```

Initialize a XCode project. You need to sign the code before you can use the Virtualization API. You don't need a paid developer account &mdash; unless you need bridged networking.

```shell
cd Aki
swift package generate-xcodeproj
open .
```

Finally, open the project in XCode, enable **Automatic manage signing** in the **Signing** section of your manifest, and edit the `Aki.entitlements` file accordingly to your needs.

## Getting Started

The first time you run Aki, it'll initialize an `.akiconfig` file into your user's directory. You can edit this file to alter the behaviour of the VM:

```yaml
memory: 512 # RAM memory (in megabytes)
processors: 2 # Processors assigned
vmDir: /Users/dom/Desktop/Aki # Where are VM files stored
cdrom: extended.iso # Live CD filename
disk: disk.img # RAW image disk filename (for storage)
kernel: vmlinuz-lts # Kernel image
initramfs: initramfs-lts # Initial RAM disk image
kernelArgs: console=hvc0 # Kernel arguments
```

You can check whether the configuration is valid by typing:

```shell
aki validate
```

## License

Aki is released under [BSD 3-Clause "New" or "Revised" License](./LICENSE).
