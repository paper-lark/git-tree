import AppIntents

struct GetRepositoryDetailsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get repository details"
    static var description = IntentDescription("Returns details about a local Git repository.")

    @Parameter(title: "Repository")
    var repository: Repository

    init(repository: Repository) {
        self.repository = repository
    }

    init() {}

    func perform() async throws -> some ReturnsValue<RepositoryDetails> {
        let repo = try GitClient.getRepository(localPath: repository.localPath)

        var currentBranchDetails: RepositoryCurrentBranchDetails? = nil
        if let currentBranch = try? repo.currentBranch() {
            let changedFiles = try GitClient.getChangesForRepository(repo)
            let targetCommit = try currentBranch.targetCommit()
            currentBranchDetails = RepositoryCurrentBranchDetails(
                currentBranch: getBranchName(branch: currentBranch),
                targetCommit: Commit(
                    sha: targetCommit.sha,
                    message: targetCommit.message,
                    date: targetCommit.commitDate
                ),
                changedFiles: changedFiles
            )
        }

        return .result(
            value: RepositoryDetails(
                repository: repository,
                localBranches: try repo.localBranches().map(getBranchName),
                remotes: try repo.remoteNames(),
                remoteBranches: try repo.remoteBranches().map(getBranchName),
                currentBranch: currentBranchDetails
            ))
    }

    private func getBranchName(branch: GTBranch) -> String {
        return branch.name ?? "<unknown>"
    }
}
