# TOUCLI

Use TouchID and the Secure Enclave to encrypt data from the commandline.
I Pronounce it 'toe-clee', but you can say it however you'd like.

![Toucli Demo video](demo.mov)

# Overview
This tool solves a small but specific problem that I had.

I wanted to pass in sensitive data (such as API keys) into 3rd partry programs, but
with these constraints:
1. Data is encrypted on disk
2. Require me to use TouchID to access/decrypt the data

This would reduce the risk of rouge usermode malware on my device being able
to steal or use these secrets, but I could still use the secrets 'transparently' in
programs that provide their own security mechanisims.

Toucli achieves all this by providing a sinple 'pipe' to encrypt data to and from other
programs or files, using the Apple Secure Enclave to generate an encryption key that can only be used
with biometric interaction from the user. This key is then used to encrpyt or decrypt the data.
(see the section below for more information).

# Security Overview
To understand exactly how the encryption works, key sizes, etc, read this documentation from Apple: [Protecting Keys with the secure enclave](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/protecting_keys_with_the_secure_enclave
))

Toucli simply implements the bare minimum around the example code:
1. Read data from stdin
2. Get or Create toucli keypair from Secure Enclave
3. Use keypair to generate a new symetric encryption key
4. Encrypt data using new key
5. Send encrypted data out through stdout

Step `3.` is done automatically by the API. Decrypting is the same in reverse.

# System Requirements
Needs a Mac with a Secure Enclave. Only tested on a Macbook Air M1 running Montery.

# Non-Goals
## Transferable keys
By storing the key in the the Secure Enclave, it **cannot** be exported or re-used
on another machine. If you lose your Mac but still have the encrypted data, it should
**not** be recoverable. This was fine for my purposes, where I use a password vault
for actual storage (Locked down behind MFA etc), and use toucli for local access.


## Other features
A non-goal of toucli was to implement anything other than encryption and decryption.
Anything else (saving files to disk, base64ing data, sending data to a URL) increases
the code complexity in the project and attack surface,
making it harder for people to read the code and assess if it meets their security levels.

# Installation
You can use either HomeBrew to install the App, or just download the latest App from [GitHub](https://github.com/pathtofile/toucli/releases/latest)
and drag it into your 'Applications' folder.

To use Homebew:
```bash
brew install pathtofile/toucli/toucli
```

Either way, the `touli` binary will be availible at:
```
/Applications/toucli.app/Contents/MacOS/toucli
```

If using Homebrew, a symlink will also be installed into `/opt/homebrew/bin/`, so if that
is on your PATH you can just run `toucli`.

# Usage
```bash
# Encrypt data and save on disk
echo "apple" | toucli encrypt > /path/to/encrypted/file
echo "apple" | toucli e > /path/to/encrypted/file
cat plain.txt | toucli e > plain_encrypted.bin
toucli e <plain.txt >plain_encrypted.bin

# Decrypt file
cat /path/to/encrypted/file | toucli decrypt
cat /path/to/encrypted/file | toucli d
toucli d <plain_encrypted.bin >plain.txt

# Decrypt data for use as an evironment variable
export API_KEY=$(cat /path/to/api_key_encrypted_file | toucli d )
./third_party_tool --api-key-variable "API_KEY"

# Store and use encrypted data as base64
echo "apple" | toucli e | base64 > /path/to/encrypted/fileb64
cat /path/to/encrypted/fileb64 | base64 -d | toucli d

# Wipe key
toucli wipe
toucli w
```

# Uninstallation
First run `touclie wipe` to remove the key from the secure enclave,
then either drag the App into the bin, or if using homebrew:
```bash
brew uninstall pathtofile/toucli/toucli
```

# Icon credits
App icon made by Akalidz from www.flaticon.com
