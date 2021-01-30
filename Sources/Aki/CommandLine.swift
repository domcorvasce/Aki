import Foundation
import ArgumentParser

/// Implements the command-line interface for handling the VM.
internal struct AkiCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A lightweight VM for running Linux under macOS",
        subcommands: [Start.self]
    )

    mutating func run() throws {
        print("Type `aki start` to boot the VM")
    }
}
