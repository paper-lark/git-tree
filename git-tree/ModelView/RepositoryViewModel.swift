import Foundation

class RepositoryViewModel: ObservableObject {
    let model: RepositoryInfoModel
    let credentials: RemoteCredentialsModel

    @Published var changedFiles: [ChangedFileModel] = []
    @Published var currentBranch: String = ""
    @Published var headCommitSHA: String = ""
    @Published var localBranches: [String] = []

    init(model: RepositoryInfoModel, credentials: RemoteCredentialsModel) {
        self.model = model
        self.credentials = credentials
        self.changedFiles = []
        self.currentBranch = ""
        self.headCommitSHA = ""
        self.localBranches = []

        self.updateHeadInfo()
    }

    func commitAll(message: String) {
        let indexTree = try! model.repository.index().writeTree()
        let parentCommit = try! model.repository.currentBranch().targetCommit()

        try! model.repository.createCommit(
            with: indexTree, message: message, parents: [parentCommit],
            updatingReferenceNamed: "HEAD")
        updateHeadInfo()
    }

    func pull() {
        let remote = try! GTRemote(name: "origin", in: model.repository)
        let currentBranch = try! model.repository.currentBranch()

        try! model.repository.pull(currentBranch, from: remote, withOptions: getRemoteOptions())
        updateHeadInfo()
    }

    func push() {
        let currentBranch = try! model.repository.currentBranch()
        let remote = try! GTRemote(name: "origin", in: model.repository)

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
    
    func getChangesFor(fileURL: URL) -> [String] {
        let opts: [String: Any] = [
            GTDiffOptionsPathSpecArrayKey: [fileURL.relativePath],
            GTDiffOptionsMaxSizeKey: 16 * 1024 // max diff size: 1MB
        ]
        
        var changes: [String] = []
        try! GTDiff(workingDirectoryToHEADIn: model.repository, options: opts).enumerateDeltas { block, _ in
            if let s = try? String(data: block.generatePatch().patchData(), encoding: .utf8) {
                changes.append(s)
            }
        }
        print(changes)
        return changes
    }

    func updateHeadInfo() {
        try! model.checkout(branch: model.repository.localBranches().first!.name!)
        try! model.repository.index().addAll()

        changedFiles = GitClient.getChangesForRepository(model.repository)        
        localBranches = try! model.repository.localBranches().compactMap { $0.name }

        let branch = try! model.repository.currentBranch()
        currentBranch = branch.name ?? ""
        headCommitSHA = try! branch.targetCommit().sha
    }
}
