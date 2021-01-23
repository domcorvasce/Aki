import Foundation
import ArgumentParser

/// Implements the command-line interface for handling the VM.
struct AkiCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A lightweight VM for running Linux under macOS"
    )

    mutating func run() throws {
        let vm = AkiVM()
        vm.start()

        var lastState = vm.getState()

        // TODO: Avoid this loop
        while true {
            if vm.getState() != lastState {
                print("VM state changed: \(vm.getState())")
                lastState = vm.getState()
            }

            sleep(1)
        }
    }
}
