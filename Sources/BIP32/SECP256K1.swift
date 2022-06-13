import Foundation
import secp256k1

enum SECP256K1 {
    static let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY))
    static let n: [UInt8] = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                             0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE,
                             0xBA, 0xAE, 0xDC, 0xE6, 0xAF, 0x48, 0xA0, 0x3B,
                             0xBF, 0xD2, 0x5E, 0x8C, 0xD0, 0x36, 0x41, 0x41 - 1] // -1 here so that we can use > only to check

    static func publicKey(for privateKey: Data, compressed: Bool = true) -> Data? {
        guard privateKey.count == 32,
              var publicKey = SECP256K1.publicKey(for: privateKey),
              let serialized = serialize(publicKey: &publicKey, compressed: compressed) else { return nil }
        return serialized
    }

    static private func publicKey(for privateKey: Data) -> secp256k1_pubkey? {
        guard privateKey.count == 32 else { return nil }
        var publicKey = secp256k1_pubkey()
        let result = privateKey.withUnsafeBytes { pkRawBufferPointer -> Int32? in
            guard let pkRawPointer = pkRawBufferPointer.baseAddress, pkRawBufferPointer.count > 0 else { return nil }
            let privateKeyPointer = pkRawPointer.assumingMemoryBound(to: UInt8.self)
            let res = secp256k1_ec_pubkey_create(context!, &publicKey, privateKeyPointer)
            return res
        }
        return result == 0 ? nil : publicKey
    }

    static private func serialize(publicKey: inout secp256k1_pubkey, compressed: Bool = true) -> Data? {
        var keyLength = compressed ? 33 : 65
        var serializedPublicKey = Data(repeating: 0x00, count: keyLength)
        let result = serializedPublicKey.withUnsafeMutableBytes { rawBuffPointer -> Int32? in
            guard let rawPointer = rawBuffPointer.baseAddress, rawBuffPointer.count > 0 else { return nil }
            return withUnsafeMutablePointer(to: &keyLength, { keyPtr -> Int32 in
                withUnsafeMutablePointer(to: &publicKey, { pubKeyPtr -> Int32 in
                    secp256k1_ec_pubkey_serialize(context!,
                                                  rawPointer.assumingMemoryBound(to: UInt8.self),
                                                  keyPtr,
                                                  pubKeyPtr,
                                                  UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
                })
            })
        }
        return result == 0 ? nil : Data(serializedPublicKey)
    }

    static func isValid(privateKey: Data) -> Bool {
        // Equals to 0?
        if privateKey.reduce(into: true, { $0 = ($0 && $1 == 0) }) {
            return false
        }
        // Greater than or equal to n
        for (index, value) in privateKey.enumerated() {
            if value == Self.n[index] {
                continue
            } else {
                return value < Self.n[index]
            }
        }
        return true
    }
}


