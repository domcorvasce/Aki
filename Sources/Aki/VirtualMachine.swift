import Virtualization

/// Implements the virtual machine
class AkiVM: NSObject, VZVirtualMachineDelegate {
    // Instance of the VM
    private var vm: VZVirtualMachine?

    // VM queue
    private var queue: DispatchQueue = DispatchQueue(label: "vm.async.queue")

    /// Initializes VM objects as requested by the Virtualization.framework
    func start() {
        do {
            let config = try VirtualMachineConfiguration(readConfig())
            try config.validate()

            self.vm = VZVirtualMachine(configuration: config.get(), queue: self.queue)
            self.vm?.delegate = self
        } catch {
            print(error)
            return
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
}
