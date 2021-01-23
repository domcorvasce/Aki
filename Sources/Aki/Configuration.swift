import Foundation
import Yams

struct Configuration: Codable {
    /// RAM assigned to the VM (in megabytes)
    var memory: UInt64 = 512

    /// Processors assigned to the VM
    var processors: Int = 2

    /// Virtual machine's dedicated directory
    var vmDir: String = "~/aki"

    /// CD ROM image filename
    var cdrom: String = ""

    // Primay disk filename
    var disk: String = "disk.img"

    // Kernel filename (e.g. vmlinuz)
    var kernel: String = "vmlinuz"

    // InitRAM disk (e.g. initramfs)
    var initramfs: String = "initrd"
}

/// Returns the path of the configuration file
private func getConfigPath() -> URL {
    FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".akiconfig")
}

/// Reads the configuration file from the user's directory
internal func readConfig() -> Configuration {
    let configPath = getConfigPath()
    let decoder = YAMLDecoder()

    // If missing, write to file and return an instance of the default config
    if !FileManager.default.fileExists(atPath: configPath.path) {
        writeConfig()
        return Configuration()
    }

    let config = try! String(contentsOf: configPath, encoding: .utf8)
    return try! decoder.decode(Configuration.self, from: config)
}

/// Writes default configuration to the user's directory
internal func writeConfig() {
    let configPath = getConfigPath()
    let config = Configuration()
    let encoder = YAMLEncoder()

    do {
        let encoded = try encoder.encode(config)
        try encoded.write(to: configPath, atomically: true, encoding: .utf8)
        print("The default configuration file has been initialized (~/.akiconfig)")
    } catch {
        print("Unable to write default configuration file to ~/.akiconfig")
    }
}
