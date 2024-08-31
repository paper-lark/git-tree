import AppIntents

struct DeleteLocalRepositoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete local repository"
    static var description = IntentDescription("Deletes an existing local Git repository.")

    @Parameter(title: "Local folder")
    var localPath: URL

    init(localPath: URL) {
        self.localPath = localPath
    }

    init() {}

    func perform() async throws -> some IntentResult {
        // delete repository from bookmarks
        RepositoryBookmarkStore.removeBookmark(localPath: localPath)

        // stop access to the directory
        localPath.stopAccessingSecurityScopedResource()

        return .result()
    }
}
