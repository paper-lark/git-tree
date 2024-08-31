import AppIntents

struct AddLocalRepositoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Add new local repository"
    static var description = IntentDescription("Adds a new local Git repository.")

    @Parameter(title: "Folder")
    var localPath: URL

    init(localPath: URL) {
        self.localPath = localPath
    }

    init() {}

    func perform() async throws -> some ReturnsValue<Repository> {
        // gain access to the directory
        if !localPath.startAccessingSecurityScopedResource() {
            throw RepositoryError.filePathUnavailable
        }
        guard
            let bookmarkData = try? localPath.bookmarkData(
                options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
        else {
            throw RepositoryError.filePathUnavailable
        }

        // check if folder is a valid repository
        do {
            let _ = try GitClient.getRepository(localPath: localPath)
        } catch {
            localPath.stopAccessingSecurityScopedResource()
            throw error
        }

        // add new repository to bookmarks
        let newRepository = Repository(localPath: localPath)
        RepositoryBookmarkStore.addBookmark(
            localPath: newRepository.localPath, bookmarkData: bookmarkData)

        return .result(value: newRepository)
    }
}
