import AppIntents

struct CommitChangesIntent: AppIntent {
    static var title: LocalizedStringResource = "Commit changes"
    static var description = IntentDescription("Commits specified files to a local Git repository.")

    @Parameter(title: "Repository")
    var repository: Repository

    @Parameter(title: "Files to commit")
    var files: Set<String>

    @Parameter(title: "Commit message")
    var message: String

    init(repository: Repository, files: Set<String>, message: String) {
        self.repository = repository
        self.files = files
        self.message = message
    }

    init() {}

    func perform() async throws -> some IntentResult {
        let repo = try GitClient.getRepository(localPath: repository.localPath)

        // add specified files to index
        guard let tree = try repo.currentBranch().targetCommit().tree else {
            throw RepositoryError.unexpectedError
        }
        // NOTE: In-memory index should be better but it fails on addFile().
        // let index = try GTIndex.inMemoryIndex(with: repo)
        let index = try repo.index()
        try index.clear()
        try index.addContents(of: tree)
        for file in files {
            try index.addFile(file)
        }

        // write index and commit it
        let indexTree = try index.writeTree()
        let parentCommit = try repo.currentBranch().targetCommit()
        let createdCommit = try repo.createCommit(
            with: indexTree, message: message, parents: [parentCommit],
            updatingReferenceNamed: "HEAD")
        try repo.reset(to: createdCommit, resetType: .soft)

        return .result()
    }
}
