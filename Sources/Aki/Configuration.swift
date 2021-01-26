import Foundation
import Yams

/// Hosts configuration options for the Linux kernel
internal struct KernelConfiguration: Codable {
    /// Path to the kernel file (e.g. ~/my-dir/vmlinuz)
    var path: String = ""

    /// Kernel command-line arguments
    var args: String = ""

    /// Path to the initial RAM disk file (e.g. ~/my-dir/initramfs)
    var initramfsPath: String = ""
}

/// Hosts information about the disks images to attach to the VM
internal struct DiskImageConfiguration: Codable {
    /// Path to the disk (e.g. ~/my-dir/ubuntu.iso)
    var path: String = "<path>/<live-cd>.iso"

    /// Indicates whether the disk is read-only
    var readOnly: Bool = true
}

public struct Configuration: Codable {
    /// Amount of RAM to assign to the VM (in megabytes)
    var memory: UInt64 = 1024

    /// Amount of CPU cores to assign to the VM
    var cores: Int = 1

    /// Indicates whether to enable NAT on the guest system.
    /// The guest will be assigned a private IP address that can be accessed from the host.
    var nat: Bool = true

    /// Indicates whether to setup a pseudo-terminal to interact with the VM
    var pty: Bool = true

    /// Indicates whether to enable memory ballooning
    var memoryBalloon: Bool = true

    /// Linux kernel configuration
    var kernel = KernelConfiguration()

    /// Disks images configuration
    var images: [DiskImageConfiguration] = [DiskImageConfiguration()]
}

/// Returns the path of the configuration file
private func getConfigPath() -> URL {
    FileManager
        .default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".akiconfig")
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
