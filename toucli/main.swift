import Foundation

func usageAndExit() -> Int32 {
    print("Usage: clisd <encrypt|decrypt|list|clear|wipe|e|d|l|c|w> [key]")
    return 1
}

func encryptData(_ key: String = _keyLabel) {
    // Read from stdin
    let dataIn = FileHandle.standardInput.availableData as CFData

    // Encrypt
    let toucliKey = String(format: _keyFormat, key)
    let (dataOut, error) = encryptDataSE(key: toucliKey, data: dataIn)
    if let err = error {
        print("Error encrypting data -", err.localizedDescription)
        exit(1)
    }

    // Output
    FileHandle.standardOutput.write(dataOut!)
}

func decryptData(_ key: String = _keyLabel) {
    // Read from stdin
    let dataIn = FileHandle.standardInput.availableData as CFData

    // Decrypt
    let toucliKey = String(format: _keyFormat, key)
    let (dataOut, error) = decryptDataSE(key: toucliKey, data: dataIn)
    if let err = error {
        print("Error decrypting data -", err.localizedDescription)
        exit(1)
    }

    // Output
    FileHandle.standardOutput.write(dataOut!)
}

func listKeys() {
    // Get all keys
    let (keys, error) = listKeysSE()
    if let err = error {
        print("Error listing keys -", err.localizedDescription)
        exit(1)
    }

    for key in keys {
        print(getKeyName(key))
    }
}

func DeleteKey(_ key: String = _keyLabel) {
    let toucliKey = String(format: _keyFormat, key)
    if let err = deleteKeySE(key: toucliKey) {
        print("Error deleting key -", err.localizedDescription)
        exit(1)
    }
}

func wipeKeys() {
    // Clear all keys
    let (keys, error) = listKeysSE()
    if let err = error {
        print("Error listing keys - ", err.localizedDescription)
        exit(1)
    }

    for key in keys {
        if let error = deleteKeySE(key: key) {
            print("Error deleting key -", error.localizedDescription)
            exit(1)
        }
    }
}

func main() throws {
    guard CommandLine.argc >= 2 && CommandLine.argc <= 3 else { exit(usageAndExit()) }
    let command = CommandLine.arguments[1]
    var key = "toucli"
    if CommandLine.argc == 3 {
        key = CommandLine.arguments[2]
    }

    switch command {
    case "e", "encrypt":
        encryptData(key)
    case "d", "decrypt":
        decryptData(key)
    case "l", "list":
        listKeys()
    case "c", "clear":
        DeleteKey(key)
    case "w", "wipe":
        wipeKeys()
    default:
        exit(usageAndExit())
    }
}

try! main()
