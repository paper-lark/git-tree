import AppIntents

struct DeleteLocalRepository: AppIntent {
    static var title: LocalizedStringResource = "Delete local repository"
    static var description = IntentDescription("Deletes an existing local Git repository.")

    @Parameter(title: "Folder")
    var localPath: URL

    init(localPath: URL) {
        self.localPath = localPath
    }

    init() {}

    func perform() async throws -> some IntentResult {
        // delete repository from bookmarks
        var bookmarks = RepositoryBookmarkStore.getBookmarks()
        bookmarks.removeValue(forKey: localPath.absoluteString)
        RepositoryBookmarkStore.storeBookmarks(bookmarks: bookmarks)

        // stop access to the directory
        localPath.stopAccessingSecurityScopedResource()

        return .result()
    }
}
