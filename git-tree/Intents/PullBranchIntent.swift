import AppIntents

struct PullBranchIntent: ProgressReportingIntent {
    static var title: LocalizedStringResource = "Pull a branch from remote"
    static var description = IntentDescription(
        "Pulls a branch to a local Git repository from remote.")

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

        try repo.pull(
            currentBranch, from: remote,
            withOptions: GitClient.getRemoteOptions(username: username, password: password)
        ) {
            update, _ in
            self.progress.completedUnitCount = Int64(update.pointee.received_objects)
            self.progress.totalUnitCount = Int64(min(update.pointee.received_objects, 1))
        }

        return .result()
    }
}
