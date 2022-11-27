import Foundation

class RepositoryViewModel: ObservableObject {
    let model: RepositoryInfoModel
    let credentials: RemoteCredentialsModel

    @Published var changedFiles: [ChangedFileModel] = []
    @Published var currentBranch: String = ""
    @Published var headCommitSHA: String = ""

    init(model: RepositoryInfoModel, credentials: RemoteCredentialsModel) {
        self.model = model
        self.credentials = credentials
        self.changedFiles = []
        self.currentBranch = ""
        self.headCommitSHA = ""

        self.updateHeadInfo()
    }

    func commitAll(message: String) {
        let index = try! model.repository.index()
        try! index.addAll()
        let indexTree = try! index.writeTree()

        let parentCommit = try! model.repository.currentBranch().targetCommit()
        try! model.repository.createCommit(
            with: indexTree, message: message, parents: [parentCommit],
            updatingReferenceNamed: "HEAD")
        updateHeadInfo()
    }

    func pull() {
        let remote = try! GTRemote(name: "origin", in: model.repository)
        let currentBranch = try! model.repository.currentBranch()

        // TODO: run async
        try! model.repository.pull(currentBranch, from: remote, withOptions: getRemoteOptions())
        updateHeadInfo()
    }

    func push() {
        let currentBranch = try! model.repository.currentBranch()
        let remote = try! GTRemote(name: "origin", in: model.repository)

        // TODO: run async
        try! model.repository.push(currentBranch, to: remote, withOptions: getRemoteOptions())
        updateHeadInfo()
    }

    func getRemoteOptions() -> [String: Any] {
        return [
            GTRepositoryRemoteOptionsCredentialProvider: GTCredentialProvider {
                credentialType, remote, username in
                try! GTCredential(
                    userName: self.credentials.username, password: self.credentials.password)
            }
        ]
    }

    func updateHeadInfo() {
        changedFiles = GitClient.getChangesForRepository(model.repository)

        if let branch = try? model.repository.currentBranch() {
            currentBranch = branch.name ?? ""
            headCommitSHA = (try? branch.targetCommit().sha) ?? ""
        }
    }
}
