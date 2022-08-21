import Foundation
import Darwin

let _keyLabel: String = "toucli"
let _keyPrefix: String = "com.pathtofile.toucli."
let _keyFormat: String = "\(_keyPrefix)%@"

func getKeyName(_ key: String) -> String {
    let index = key.index(key.startIndex, offsetBy: _keyPrefix.count)
    return String(key.suffix(from: index))
}

func printErr(_ text: String) {
    fputs(String(format: "%@\n", text), stderr)
}
