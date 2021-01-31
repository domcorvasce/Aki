# Aki

A simple VM for running Linux under macOS using the
[Virtualization.framework](https://developer.apple.com/documentation/virtualization).

## Requirements

- macOS 11+
- Swift 5.3+

## Installation

Clone this repository:

```zsh
git clone https://github.com:domcorvasce/Aki
```

Export a `SIGNING_CERT` environment variable with the identifier of your **digital signing identity** (see the **SIGNING IDENTITIES** section of `man codesign`):

```zsh
export SIGNING_CERT='<your-username>@icloud.com'
```

Then, install the CLI:

```zsh
make install
```

## Getting Started

### Initialize VM configuration

Run `aki` in the Terminal.

The first time you do, it'll initialize an `.akiconfig` file into your user's directory. You can edit this file to alter the behaviour of the VM:

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

#### Disks

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

### Boot VM

Once you have edited the VM configuration, run `aki start` to boot the VM. If the `pty` configuration option has been enabled, you can use `screen` to attach to the *pseudoterminal* associated with the VM.

```zsh
$ aki start
```

## Credits

**Virtualization.framework** doesn't have much documentation right now. It was useful to look at the following projects whenever I got stuck: [SimpleVM](https://github.com/KhaosT/SimpleVM) by [@KhaosT](https://github.com/KhaosT), [vftool](https://github.com/evansm7/vftool) by [@evansm7](https://github.com/evansm7), and [vmcli](https://github.com/gyf304/vmcli) by [@gyf304](https://github.com/gyf304).

## License

Aki is released under [BSD 3-Clause "New" or "Revised" License](./LICENSE).
