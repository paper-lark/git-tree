import Foundation

struct RepositoryInfoModel: Identifiable {
    let name: String
    let localPath: URL
    let repository: GTRepository

    var id: String {
        return localPath.absoluteString
    }

    static func clone(
        fromRemoteURL remoteURL: URL, toLocalPath localPath: URL,
        credentials: RemoteCredentialsModel
    ) -> RepositoryInfoModel? {
        guard localPath.startAccessingSecurityScopedResource() else {
            return nil
        }

        guard
            let repo = GitClient.clone(
                fromRemoteURL: remoteURL, toLocalURL: localPath, username: credentials.username,
                password: credentials.password)
        else {
            return nil
        }

        return RepositoryInfoModel(
            name: localPath.lastPathComponent, localPath: localPath, repository: repo)
    }

    static func initWith(localPath: URL) -> RepositoryInfoModel? {
        guard localPath.startAccessingSecurityScopedResource() else {
            return nil
        }

        guard let repo = GitClient.getRepository(localPath: localPath) else {
            return nil
        }

        return RepositoryInfoModel(
            name: localPath.lastPathComponent, localPath: localPath, repository: repo)
    }

    func cleanup() {
        localPath.stopAccessingSecurityScopedResource()
    }
}
