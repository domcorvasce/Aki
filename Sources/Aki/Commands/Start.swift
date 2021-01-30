import Foundation
import ArgumentParser

internal struct Start: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Starts the Linux VM"
    )

    mutating func run() throws {
        let dispatchGroup = DispatchGroup()
        let vm = AkiVM(dispatchGroup: dispatchGroup)

        vm.start()
        dispatchMain()
    }
}
