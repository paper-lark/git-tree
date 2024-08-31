import Foundation

struct RemoteCredentialsStore {
    static func getCredentials() -> RemoteCredentials {
        return KeychainHelper.standard.read(
            service: service,
            account: account,
            type: RemoteCredentials.self) ?? RemoteCredentials()
    }

    static func store(credentials: RemoteCredentials) {
        KeychainHelper.standard.save(
            credentials, service: service,
            account: account)
    }

    private static let account = "gittree"
    private static let service = "remote-credentials"
}
