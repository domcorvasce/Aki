import Virtualization

/// Implements the virtual machine
struct AkiVM {
    private let inPipe = Pipe()
    private let outPipe = Pipe()

    /// Initializes VM objects as requested by the Virtualization.framework
    func run() {
        do {
            let config = try self.generateConfig()
            let vm = VZVirtualMachine(configuration: config)
        } catch {
            print(error)
        }
    }

    /// Generates VM configuration object based on the configuration file
    private func generateConfig() throws -> VZVirtualMachineConfiguration {
        let config = readConfig()
        let vmDir = NSURL.fileURL(withPath: config.vmDir)
        let vmc = VZVirtualMachineConfiguration()

        let console = VZVirtioConsoleDeviceSerialPortConfiguration()
        console.attachment = VZFileHandleSerialPortAttachment(
            fileHandleForReading: inPipe.fileHandleForReading,
            fileHandleForWriting: outPipe.fileHandleForWriting
        )

        let cdrom = VZVirtioBlockDeviceConfiguration(
            attachment: try! VZDiskImageStorageDeviceAttachment(
                url: vmDir.appendingPathComponent(config.cdrom),
                readOnly: true
            )
        )

        let disk = VZVirtioBlockDeviceConfiguration(
            attachment: try! VZDiskImageStorageDeviceAttachment(
                url: vmDir.appendingPathComponent(config.disk),
                readOnly: false
            )
        )

        let memoryBalloon = VZVirtioTraditionalMemoryBalloonDeviceConfiguration()
        let natNetwork = VZVirtioNetworkDeviceConfiguration()
        natNetwork.attachment = VZNATNetworkDeviceAttachment()

        vmc.bootLoader = self.generateBootLoaderObject(vmDir)
        vmc.cpuCount = config.processors
        vmc.memorySize = config.memory * (1024 * 1024)
        vmc.memoryBalloonDevices = [memoryBalloon]
        vmc.networkDevices = [natNetwork]
        vmc.serialPorts = [console]
        vmc.storageDevices = [cdrom, disk]
        vmc.entropyDevices = [VZVirtioEntropyDeviceConfiguration()]

        try vmc.validate()
        return vmc
    }

    /// Generates Linux boot loader object
    private func generateBootLoaderObject(_ vmDir: URL) -> VZLinuxBootLoader {
        let bootLoader = VZLinuxBootLoader(
            kernelURL: vmDir.appendingPathComponent("vmlinuz")
        )

        bootLoader.initialRamdiskURL = vmDir.appendingPathComponent("initrd")
        bootLoader.commandLine = "console=hvc0"

        return bootLoader
    }
}
