import AppIntents

struct CloneLocalRepositoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Clone remote repository"
    static var description = IntentDescription("Clones a remote Git repository to a local folder.")

    @Parameter(title: "Local folder")
    var localPath: URL

    @Parameter(title: "Remote repository URL")
    var remoteURL: URL

    @Parameter(title: "Remote username")
    var username: String

    @Parameter(title: "Remote password")
    var password: String

    init(localPath: URL, remoteURL: URL, credentials: RemoteCredentials) {
        self.localPath = localPath
        self.remoteURL = remoteURL
        self.username = credentials.username
        self.password = credentials.password
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

        do {
            // clone remote repository
            let repo = try GitClient.clone(
                fromRemoteURL: remoteURL, toLocalURL: localPath, username: username,
                password: password)
            let remoteName = try repo.remoteNames()[0]  // TODO: get this somehow else?
            let remote = try GTRemote(name: remoteName, in: repo)
            // TODO: No branch is cloned?
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
