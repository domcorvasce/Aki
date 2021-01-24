# Aki

A lightweight VM for running Linux under macOS using the
[Virtualization.framework](https://developer.apple.com/documentation/virtualization).

## Requirements

- macOS 11+
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
memory: 1024                         # amount of RAM assigned to the VM (in megabytes)
cores: 2                             # amount of CPU cores assigned to the VM
nat: true                            # enables NAT
redirectIO: true                     # redirects current terminal IO to the VM

# Kernel configuration
kernel:
  path: '/Users/my-user/vmlinuz'     # kernel path
  args: 'console=hvc0'               # boot arguments
  initramfsPath: ''                  # initial RAM disk path (leave empty to skip)

# Disk images
images:
- path: '/Users/my-user/ubuntu.iso'  # disk image path
  readOnly: true                     # attaches it in read-only mode
```

## License

Aki is released under [BSD 3-Clause "New" or "Revised" License](./LICENSE).
