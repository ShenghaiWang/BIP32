import BIP39
import Foundation
import CryptoSwift

public struct BIP32 {
    public struct HPWalletKey {
        public let `private`: Data
        public let `public`: Data
        public let chaincode: Data
        public let depth: Data
        public let fingerprintOfParent: Data
        public let childNumber: Data

        public init?(seed: Data) {
            guard seed.count >= 16 && seed.count <= 64 else { return nil }
            guard let hmacKey = "Bitcoin seed".data(using: .ascii) else { return nil }
            let hmac = HMAC(key: hmacKey.bytes, variant: HMAC.Variant.sha2(.sha512))
            guard let entropy = try? hmac.authenticate(seed.bytes),
                entropy.count == 64 else { return nil }
            `private` = Data(entropy.prefix(32))
            guard SECP256K1.isValid(privateKey: `private`) else { return nil }
            guard let publicKey = SECP256K1.publicKey(for: `private`) else { return nil }
            `public` = publicKey
            chaincode = Data(entropy.suffix(32))
            depth = Data([0x00])
            fingerprintOfParent = Data([0x00, 0x00, 0x00, 0x00])
            childNumber = Data([0x00, 0x00, 0x00, 0x00])
        }

        public func publicKey(netType: NetType = .mainnet) -> String {
            var data = netType.publicVersion + depth + fingerprintOfParent + childNumber + chaincode + `public`
            let hashedData = data.sha256().sha256()
            let checksum = hashedData[0..<4]
            data.append(checksum)
            return data.base58Encoded
        }

        public func privateKey(netType: NetType = .mainnet) -> String {
            var data = netType.privateVersion + depth + fingerprintOfParent + childNumber + chaincode + Data([0x00]) + `private`
            let hashedData = data.sha256().sha256()
            let checksum = hashedData[0..<4]
            data.append(checksum)
            return data.base58Encoded
        }
    }
}

public enum NetType {
    case mainnet
    case testnet

    var publicVersion: Data {
        switch self {
        case .mainnet: return Data([0x04, 0x88, 0xB2, 0x1E])
        case .testnet: return Data([0x04, 0x35, 0x87, 0xCF])
        }
    }

    var privateVersion: Data {
        switch self {
        case .mainnet: return Data([0x04, 0x88, 0xAD, 0xE4])
        case .testnet: return Data([0x04, 0x35, 0x83, 0x94])
        }
    }
}

