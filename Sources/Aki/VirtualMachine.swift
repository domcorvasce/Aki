import Virtualization

/// Implements the virtual machine
struct AkiVM {
    /// Manages the state of the VM
    let vm: VZVirtualMachine

    /// Initializes VM objects as requested by the Virtualization.framework
    init() {
        self.vm = VZVirtualMachine(configuration: AkiVM.generateConfig())
    }

    /// Generates VM configuration object based on the configuration file
    private static func generateConfig() -> VZVirtualMachineConfiguration {
        let config = readConfig()
        let vmc = VZVirtualMachineConfiguration()

        vmc.cpuCount = config.processors
        vmc.memorySize = config.memory

        return vmc
    }
}
