import Foundation

class RepositoryViewModel: ObservableObject {
    let model: RepositoryInfoModel
    let credentials: RemoteCredentialsModel

    @Published var changedFiles: [ChangedFileModel] = []
    @Published var currentBranch: String = ""
    @Published var headCommitSHA: String = ""
    @Published var localBranches: [String] = []
    @Published var currentOperation: RepositoryAsyncOperation? = nil
    @Published var commitMessage: String = ""

    init(model: RepositoryInfoModel, credentials: RemoteCredentialsModel) {
        self.model = model
        self.credentials = credentials
        self.changedFiles = []
        self.currentBranch = ""
        self.headCommitSHA = ""
        self.localBranches = []

        self.updateHeadInfo()
    }

    // FIXME: Similar to GitClient::getCloneRemoteOptions()
    func getRemoteOptions() -> [String: Any] {
        return [
            GTRepositoryRemoteOptionsCredentialProvider: GTCredentialProvider {
                _, _, _ in
                try! GTCredential(
                    userName: self.credentials.username, password: self.credentials.password)
            }
        ]
    }

    func updateHeadInfo() {
        let branches = try! model.repository.localBranches()
        try! model.checkout(branch: branches.first!.name!)
        try! model.repository.index().addAll()

        changedFiles = try! GitClient.getChangesForRepository(model.repository)
        localBranches = try! model.repository.localBranches().compactMap { $0.name }

        let branch = try! model.repository.currentBranch()
        currentBranch = branch.name ?? ""
        headCommitSHA = try! branch.targetCommit().sha
    }

    func commit() {
        guard currentOperation == nil else {
            return
        }
        currentOperation = RepositoryAsyncOperation(kind: .commit)

        let message = commitMessage
        commitMessage = ""
        let model = self.model

        DispatchQueue.global(qos: .userInitiated).async {
            let indexTree = try! model.repository.index().writeTree()
            let parentCommit = try! model.repository.currentBranch().targetCommit()

            try! model.repository.createCommit(
                with: indexTree, message: message, parents: [parentCommit],
                updatingReferenceNamed: "HEAD")

            DispatchQueue.main.async {
                self.updateHeadInfo()
                self.currentOperation = nil
            }
        }
    }

    func pull() {
        guard currentOperation == nil else {
            return
        }
        let op = RepositoryAsyncOperation(kind: .pull, currentProgress: 0)
        currentOperation = op
        let model = self.model
        let opts = self.getRemoteOptions()

        DispatchQueue.global(qos: .userInitiated).async {
            // TODO: select remote
            let remote = try! GTRemote(name: "origin", in: model.repository)
            let currentBranch = try! model.repository.currentBranch()

            try! model.repository.pull(currentBranch, from: remote, withOptions: opts) {
                progress, _ in
                if let op = self.currentOperation {
                    DispatchQueue.main.async {
                        op.updateProgress(
                            current: Float(progress.pointee.received_objects)
                                / min(Float(progress.pointee.received_objects), 1))
                    }
                }
            }

            DispatchQueue.main.async {
                self.updateHeadInfo()
                self.currentOperation = nil
            }
        }
    }

    func push() {
        guard currentOperation == nil else {
            return
        }
        currentOperation = RepositoryAsyncOperation(kind: .push)

        let model = self.model
        let opts = self.getRemoteOptions()

        DispatchQueue.global(qos: .userInitiated).async {
            let currentBranch = try! model.repository.currentBranch()
            let remote = try! GTRemote(name: "origin", in: model.repository)

            try! model.repository.push(currentBranch, to: remote, withOptions: opts) {
                current, total, _, _ in
                if let op = self.currentOperation {
                    DispatchQueue.main.async {
                        op.updateProgress(current: Float(current) / min(Float(total), 1))
                    }
                }
            }

            DispatchQueue.main.async {
                self.updateHeadInfo()
                self.currentOperation = nil
            }
        }
    }

    func resetToRemote() {
        guard currentOperation == nil else {
            return
        }
        currentOperation = RepositoryAsyncOperation(kind: .reset)

        let model = self.model

        DispatchQueue.global(qos: .userInitiated).async {
            let currentBranch = try! model.repository.currentBranch()

            var error: NSError? = nil
            if let remoteBranch = currentBranch.trackingBranchWithError(&error, success: nil),
                error == nil
            {
                try! model.repository.reset(to: remoteBranch.targetCommit(), resetType: .soft)
            }

            DispatchQueue.main.async {
                self.updateHeadInfo()
                self.currentOperation = nil
            }
        }
    }
}
