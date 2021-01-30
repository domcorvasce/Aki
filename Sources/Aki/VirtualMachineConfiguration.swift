import Virtualization

typealias VMC = VZVirtualMachineConfiguration
typealias MemoryBalloon = VZVirtioTraditionalMemoryBalloonDeviceConfiguration

struct VirtualMachineConfiguration {
    /// User configuration options
    let config: Configuration

    /// Virtual machine configuration object
    let vmc: VMC

    init(_ config: Configuration) throws {
        self.config = config
        self.vmc = VMC()
        try self.build()
    }

    /// Validates the VM configuration object
    public func validate() throws {
        try self.vmc.validate()
    }

    /// Returns the VM configuration object
    public func get() -> VMC {
        self.vmc
    }

    /// Builds the VM configuration based on the user's configuration options
    private func build() throws {
        let memorySize = self.config.memory * (1024 * 1024)

        assert(self.config.cores >= VMC.minimumAllowedCPUCount)
        assert(self.config.cores <= VMC.maximumAllowedCPUCount)
        assert(memorySize >= VMC.minimumAllowedMemorySize)
        assert(memorySize <= VMC.maximumAllowedMemorySize)

        // Configure general VM settings
        self.vmc.cpuCount = self.config.cores
        self.vmc.memorySize = memorySize
        self.vmc.entropyDevices = [VZVirtioEntropyDeviceConfiguration()]

        if self.config.memoryBalloon {
            self.vmc.memoryBalloonDevices = [MemoryBalloon()]
        }

        if self.config.nat {
            self.attachNAT()
        }

        if self.config.pty {
            self.attachTerminal()
        }

        try self.attachStorage()
        self.attachBootLoader()
    }

    /// Attaches storage devices based on the user's configuration
    private func attachStorage() throws {
        // Attach disks images
        for image in self.config.images {
            let disk = try VZDiskImageStorageDeviceAttachment(
                url: NSURL.fileURL(withPath: image.path),
                readOnly: image.readOnly
            )

            self.vmc.storageDevices.append(VZVirtioBlockDeviceConfiguration(attachment: disk))
        }
    }

    /// Setup NAT to interface the guest with the host
    private func attachNAT() {
        let network = VZVirtioNetworkDeviceConfiguration()
        network.attachment = VZNATNetworkDeviceAttachment()
        self.vmc.networkDevices = [network]
    }

    /// Attaches the current terminal to the VM
    private func attachTerminal() {
        // Ask for a free pseudoterminal
        var ptyFd: Int32 = -1
        var ttyFd: Int32 = -1
        var ttyOptions: termios = termios()

        let ecode = openpty(&ptyFd, &ttyFd, nil, &ttyOptions, nil)

        if ecode == -1 {
            NSLog("Unable to get a pseudoterminal.")
            return
        }

        // Enable raw mode for the pseudoterminal
        tcgetattr(ttyFd, &ttyOptions)
        cfmakeraw(&ttyOptions)
        tcsetattr(ttyFd, TCSAFLUSH, &ttyOptions)
        fcntl(ptyFd, F_SETFL, fcntl(ptyFd, F_GETFL) | O_NONBLOCK)

        // Attach pseudoterminal to the VM
        let term = VZVirtioConsoleDeviceSerialPortConfiguration()
        let pty = FileHandle(fileDescriptor: ptyFd, closeOnDealloc: true)

        term.attachment = VZFileHandleSerialPortAttachment(
            fileHandleForReading: pty, fileHandleForWriting: pty)

        let ptyId = String(cString: ttyname(ttyFd))
        NSLog("The target pseudoterminal is \(ptyId)")

        self.vmc.serialPorts = [term]
    }

    /// Attaches boot loader configuration
    private func attachBootLoader() {
        let bootLoader = VZLinuxBootLoader(kernelURL: NSURL.fileURL(withPath: self.config.kernel.path))
        bootLoader.commandLine = self.config.kernel.args

        if self.config.kernel.initramfsPath != "" {
            bootLoader.initialRamdiskURL = NSURL.fileURL(withPath: self.config.kernel.initramfsPath)
        }

        self.vmc.bootLoader = bootLoader
    }
}
