import Foundation
import Security

// We also use a keychain label to help prevent
// user or deleting the wrong key
let _keyLabel: String = "toucli"

// Helper to print debug logs to stderr
func printErr(_ text: String) {
    fputs(String(format: "%@\n", text), stderr)
}

// Convert OSStatus from Sec* functions into an Error object
func OSStatusToError(_ status: Int32) -> Error {
    let userInfo: Dictionary = [
        NSLocalizedDescriptionKey: SecCopyErrorMessageString(status, nil)! as String
    ]
    return NSError(domain: _keyLabel, code: Int(status), userInfo: userInfo) as Error
}

// Create Key
func _createKeySE(key: String) -> (SecKey?, Error?) {
    let access = SecAccessControlCreateWithFlags(
        kCFAllocatorDefault,
        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        [.privateKeyUsage, .biometryAny],
        nil)!

    let attributes: NSDictionary = [
        kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
        kSecAttrKeySizeInBits: 256,
        kSecAttrTokenID: kSecAttrTokenIDSecureEnclave,
        kSecPrivateKeyAttrs: [
            kSecAttrIsPermanent: true,
            kSecAttrApplicationTag: key,
            kSecAttrApplicationLabel: _keyLabel,
            kSecAttrAccessControl: access
        ]
    ]

    var error: Unmanaged<CFError>?
    let priKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error)
    if let err = error {
        return (nil, (err.takeRetainedValue() as Error))
    }

    return (priKey, nil)
}

// Get or create key
func _getKeySE(key: String, createIfMissing: Bool = true) -> (SecKey?, Error?) {
    let query: NSDictionary = [
        kSecClass: kSecClassKey,
        kSecAttrApplicationTag: key,
        kSecAttrApplicationLabel: _keyLabel,
        kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
        kSecReturnRef: true
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status == errSecItemNotFound && createIfMissing {
        // No key exists yet, create one
        printErr(String(format: "Key not found, creating..."))
        return _createKeySE(key: key)
    }

    if status != errSecSuccess {
        return (nil, OSStatusToError(status))
    }

    let key = item as! SecKey?
    return (key, nil)
}

// Encrypt data with key
func encryptDataSE(key: String, data: CFData) -> (Data?, Error?) {
    // Get or create key
    let (priKey, errorGet) = _getKeySE(key: key, createIfMissing: true)
    if let err = errorGet {
        return (nil, err)
    }
    let publicKey = SecKeyCopyPublicKey(priKey!)!

    // Encrypt data
    let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
    var error: Unmanaged<CFError>?
    let data = SecKeyCreateEncryptedData(publicKey, algorithm, data, &error)
    if data == nil {
        return (nil, error!.takeRetainedValue() as Error)
    }

    return (data as Data?, nil)
}

// Decrypt data with key
func decryptDataSE(key: String, data: CFData) -> (Data?, Error?) {
    // Get key
    let (priKey, errorGet) = _getKeySE(key: key, createIfMissing: false)
    if let err = errorGet {
        return (nil, err)
    }

    // Decrypt data
    let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
    var error: Unmanaged<CFError>?
    let data = SecKeyCreateDecryptedData(priKey!, algorithm, data, &error)
    if data == nil {
        return (nil, error!.takeRetainedValue() as Error)
    }

    return (data as Data?, nil)
}

// Delete key
func deleteKeySE(key: String) -> Error? {
    let query: NSDictionary = [
        kSecClass: kSecClassKey,
        kSecAttrApplicationTag: key,
        kSecAttrApplicationLabel: _keyLabel,
        kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
        kSecReturnRef: true
    ]

    let status = SecItemDelete(query)
    guard status == errSecSuccess else { return OSStatusToError(status)}
    return nil
}
