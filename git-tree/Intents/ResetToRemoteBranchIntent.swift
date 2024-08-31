import AppIntents

struct ResetToRemoteBranchIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset to remote branch"
    static var description = IntentDescription(
        "Resets a local Git repository to the state of remote.")

    @Parameter(title: "Repository")
    var repository: Repository

    init(repository: Repository) {
        self.repository = repository
    }

    init() {}

    func perform() async throws -> some IntentResult {
        let repo = try GitClient.getRepository(localPath: repository.localPath)
        let currentBranch = try repo.currentBranch()

        var error: NSError? = nil
        let branch = currentBranch.trackingBranchWithError(&error, success: nil)
        if let err = error {
            throw err
        }
        guard let remoteBranch = branch else {
            throw RepositoryError.remoteDoesNotExist
        }
        try repo.reset(to: remoteBranch.targetCommit(), resetType: .soft)

        return .result()
    }
}
