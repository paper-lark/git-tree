import Foundation

class KeychainHelper {
    static let standard = KeychainHelper()
    private init() {}

    func save<T>(_ item: T, service: String, account: String) where T: Codable {
        do {
            let data = try JSONEncoder().encode(item)
            save(data, service: service, account: account)

        } catch {
            assertionFailure("Failed to encode item for keychain: \(error)")
        }
    }

    func save(_ data: Data, service: String, account: String) {
        // add data to keychain
        let query =
            [
                kSecValueData: data,
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
            ] as CFDictionary
        let status = SecItemAdd(query, nil)

        // proceess result
        switch status {
        case errSecDuplicateItem:
            // data already exists
            let query =
                [
                    kSecAttrService: service,
                    kSecAttrAccount: account,
                    kSecClass: kSecClassGenericPassword,
                ] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            SecItemUpdate(query, attributesToUpdate)

        case errSecSuccess:
            // success
            print("Data saved to Keychain")

        default:
            // unknown error
            print("Failed to save data to Keychain: \(status)")
        }
    }

    func read<T>(service: String, account: String, type: T.Type) -> T? where T: Codable {
        guard let data = read(service: service, account: account) else {
            return nil
        }

        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            assertionFailure("Failed to decode item from keychain: \(error)")
            return nil
        }
    }

    func read(service: String, account: String) -> Data? {
        let query =
            [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
                kSecReturnData: true,
            ] as CFDictionary

        var result: AnyObject?
        SecItemCopyMatching(query, &result)

        return (result as? Data)
    }
}
