import Virtualization

/// Implements the virtual machine
class AkiVM: NSObject, VZVirtualMachineDelegate {
    // IO pipes
    private let inPipe = Pipe()
    private let outPipe = Pipe()

    // Instance of the VM
    private var vm: VZVirtualMachine?

    // VM queue
    private var queue: DispatchQueue = DispatchQueue(label: "vm.async.queue")

    /// Initializes VM objects as requested by the Virtualization.framework
    func start() {
        do {
            let config = try self.generateConfig()
            self.vm = VZVirtualMachine(configuration: config, queue: self.queue)
            self.vm?.delegate = self
        } catch {
            print(error)
        }

        print("Starting VM...")

        self.queue.async {
            self.vm?.start { result in
                switch result {
                case .success:
                    print("VM started successfully")
                    break
                case .failure(let err):
                    print(err)
                }
            }
        }
    }

    /// Stops VM
    func stop() {
        if self.vm?.canRequestStop == true {
            queue.async {
                if let virtualMachine = self.vm {
                    do {
                        try virtualMachine.requestStop()
                    } catch {
                        print("Cannot stop VM due to error: \(error)")
                    }

                    self.vm = nil
                }
            }
        }

        print("Cannot stop VM due to its state: '\(self.getState())'")
    }

    /// Returns the state of the VM
    func getState() -> String {
        switch self.vm?.state {
        case .stopped:
            return "Stopped"
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        case .error:
            return "Error"
        case .starting:
            return "Starting"
        case .pausing:
            return "Pausing"
        case .resuming:
            return "Resuming"
        default:
            return "Unknown"
        }
    }

    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        NSLog("VM did stop successfully")
    }

    func virtualMachine(_ virtualMachine: VZVirtualMachine,
                        didStopWithError error: Error) {
        NSLog("VM did stop with an error: \(error)")
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
