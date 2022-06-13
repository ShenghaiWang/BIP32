import Foundation

extension Data {
    private var base58Characters: String {
        "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    }

    var base58Encoded: String {
        var bytes = self.bytes
        var numberOfLeadingZero = 0
        while bytes.first == 0 {
            numberOfLeadingZero += 1
            bytes.removeFirst()
        }
        let size = bytes.count * 138 / 100 + 1
        var encoded: [UInt8] = Array(repeating: 0, count: size)
        var length = 0
        bytes.forEach { byte in
            var carry = Int(byte)
            var i = 0
            for j in 0..<encoded.count where carry != 0 || i < length {
                carry += 256 * Int(encoded[encoded.count - j - 1])
                encoded[encoded.count - j - 1] = UInt8(carry % 58)
                carry /= 58
                i += 1
            }
            length = i
        }

        while encoded.first == 0 {
            encoded.removeFirst()
        }

        return String(repeating: "1", count: numberOfLeadingZero)
        + String(encoded.map { base58Characters[base58Characters.index(base58Characters.startIndex, offsetBy: Int($0))] })
    }
}
