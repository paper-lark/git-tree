import AppIntents

struct RepositoryDetails: TransientAppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("Repository"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) repositories")
        )
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(repository.name)",
            subtitle: "\(repository.localPath.relativePath)")
    }

    var repository: Repository = Repository(name: "", localPath: URL(fileURLWithPath: "."))

    var localBranches: [String] = []
    var remoteBranches: [String] = []
    var currentBranch: RepositoryCurrentBranchDetails? = nil

    var id: String { repository.id }
}

struct RepositoryCurrentBranchDetails: Identifiable {
    var currentBranch: String
    var latestCommitSHA: String
    var changedFiles: [ChangedFile]

    var id: String { currentBranch }
}
