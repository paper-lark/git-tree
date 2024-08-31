import AppIntents

struct PushBranchIntent: ProgressReportingIntent {
    static var title: LocalizedStringResource = "Push a branch to remote"
    static var description = IntentDescription(
        "Pushes a branch from a local Git repository to remote.")

    @Parameter(title: "Repository")
    var repository: Repository

    @Parameter(title: "Remote name")
    var remote: String

    @Parameter(title: "Remote username")
    var username: String

    @Parameter(title: "Remote password")
    var password: String

    init(repository: Repository, remote: String, username: String, password: String) {
        self.repository = repository
        self.remote = remote
        self.username = username
        self.password = password
    }

    init() {}

    func perform() async throws -> some IntentResult {
        let repo = try GitClient.getRepository(localPath: repository.localPath)
        let remote = try GTRemote(name: remote, in: repo)
        let currentBranch = try repo.currentBranch()

        try repo.push(
            currentBranch, to: remote,
            withOptions: GitClient.getRemoteOptions(username: username, password: password)
        ) {
            current, total, _, _ in
            self.progress.completedUnitCount = Int64(current)
            self.progress.totalUnitCount = Int64(total)
        }

        return .result()
    }
}
