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

        while true {
            print(vm.getState())
            sleep(1)
        }
    }
}
