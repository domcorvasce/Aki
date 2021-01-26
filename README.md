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

Now, open the project in XCode, enable **Automatic manage signing** in the **Signing** section of your manifest, and edit the `Aki.entitlements` file accordingly to your needs. Then, hit "Run".

## Getting Started

The first time you run Aki, it'll initialize an `.akiconfig` file into your user's directory. You can edit this file to alter the behaviour of the VM:

```yaml
memory: 1024                         # amount of RAM assigned to the VM (in megabytes)
cores: 2                             # amount of CPU cores assigned to the VM
nat: true                            # enables NAT
pty: true                            # enables pseudoterminal to interact with the VM
memoryBalloon: true                  # enables memory ballooning

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

### Disks

Currently, the *Virtualization.framework* doesn't support mounting physical devices. Instead, you must use disk images. Disks are mounted in the same order as they are defined, and are given an identifier of the form `/dev/vdX`. For instance, defining:

```yaml
images:
- path: livecd.iso
  readOnly: true
- path: storage.vmdk
  readOnly: false
```

will result into two disks attached to the VM: `/dev/vda`, and `/dev/vdb`.

Virtualization.framework has support for many flat files  including VMDK, VDI, and RAW images.

## Credits

**Virtualization.framework** doesn't have much documentation right now. Hence, it was useful to look at the following projects whenever I got stuck: [SimpleVM](https://github.com/KhaosT/SimpleVM) by [@KhaosT](https://github.com/KhaosT), [vftool](https://github.com/evansm7/vftool) by [@evansm7](https://github.com/evansm7), and [vmcli](https://github.com/gyf304/vmcli) by [@gyf304](https://github.com/gyf304).

## License

Aki is released under [BSD 3-Clause "New" or "Revised" License](./LICENSE).
