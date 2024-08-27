import Foundation

class RemoteCredentialsViewModel: ObservableObject {
    private static let account = "gittree"
    private static let service = "remote-credentials"

    @Published var username: String
    @Published var password: String

    init() {
        let credentials = KeychainHelper.standard.read(
            service: RemoteCredentialsViewModel.service,
            account: RemoteCredentialsViewModel.account,
            type: RemoteCredentialsModel.self)

        self.username = credentials?.username ?? ""
        self.password = credentials?.password ?? ""
    }

    func toModel() -> RemoteCredentialsModel {
        return RemoteCredentialsModel(username: username, password: password)
    }

    func persist() {
        KeychainHelper.standard.save(
            toModel(), service: RemoteCredentialsViewModel.service,
            account: RemoteCredentialsViewModel.account)
    }
}
