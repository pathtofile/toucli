import Foundation

let _keyName: String = "com.pathtofile.toucli.key"

func usageAndExit() -> Int32 {
    print("Usage: toucli <encrypt|decrypt|wipe|e|d|w>")
    return 1
}

func encryptData() {
    // Read from stdin
    let dataIn = FileHandle.standardInput.availableData as CFData

    // Encrypt
    let (dataOut, error) = encryptDataSE(key: _keyName, data: dataIn)
    if let err = error {
        print("Error encrypting data -", err.localizedDescription)
        exit(1)
    }

    // Output
    FileHandle.standardOutput.write(dataOut!)
}

func decryptData() {
    // Read from stdin
    let dataIn = FileHandle.standardInput.availableData as CFData

    // Decrypt
    let (dataOut, error) = decryptDataSE(key: _keyName, data: dataIn)
    if let err = error {
        print("Error decrypting data -", err.localizedDescription)
        exit(1)
    }

    // Output
    FileHandle.standardOutput.write(dataOut!)
}

func wipeKey() {
    // Delete key
    if let err = deleteKeySE(key: _keyName) {
        print("Error deleting key -", err.localizedDescription)
        exit(1)
    }
}

func main() throws {
    guard CommandLine.argc == 2 else { exit(usageAndExit()) }

    switch CommandLine.arguments[1] {
    case "e", "encrypt":
        encryptData()
    case "d", "decrypt":
        decryptData()
    case "w", "wipe":
        wipeKey()
    default:
        exit(usageAndExit())
    }
}

try! main()
