import Virtualization

/// Implements the virtual machine
struct AkiVM {
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

        vmc.bootLoader = self.generateBootLoaderObject(vmDir)
        vmc.cpuCount = config.processors
        vmc.memorySize = config.memory * (1024 * 1024)

        try vmc.validate()
        return vmc
    }

    /// Generates Linux boot loader object
    private func generateBootLoaderObject(_ vmDir: URL) -> VZLinuxBootLoader {
        let bootLoader = VZLinuxBootLoader(
            kernelURL: vmDir.appendingPathComponent("vmlinuz")
        )

        bootLoader.initialRamdiskURL = vmDir.appendingPathComponent("initrd")

        return bootLoader
    }
}
