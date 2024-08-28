import AppIntents

struct Repository: AppEntity {
    typealias DefaultQuery = RepositoryQuery

    static var defaultQuery = RepositoryQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("Repository"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) repositories")
        )
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(localPath.relativePath)")
    }

    //    @Property(title: "Name")
    var name: String

    //    @Property(title: "Path")
    var localPath: URL

    var id: String {
        return localPath.path(percentEncoded: false)
    }
}

struct RepositoryQuery: EntityQuery {
    func entities(for identifiers: [Repository.ID]) async throws -> [Repository] {
        return try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [Repository] {
        let repositoryBookmarks = RepositoryBookmarkStore.getBookmarks()
        var repositories: [Repository] = []

        // load bookmarked repositories
        for (oldURL, bookmarkData) in repositoryBookmarks {
            // check bookmark state
            var isStale = false
            guard
                let localPath = try? URL(
                    resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale),
                !isStale
            else {
                continue
            }

            // check if repository exists
            if let repo = try? GitClient.getRepository(localPath: localPath) {
                repositories.append(
                    Repository(name: localPath.lastPathComponent, localPath: localPath))
            }
        }

        return repositories.sorted { $0.name.lowercased() > $1.name.lowercased() }
    }

    func defaultResult() async -> Repository? {
        return nil
    }
}
