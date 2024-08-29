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
        credentials: RemoteCredentials
    ) throws -> RepositoryInfoModel {
        // check if local path is available
        guard localPath.startAccessingSecurityScopedResource() else {
            throw RepositoryError.filePathUnavailable
        }

        // clone remote repository
        let repo = try GitClient.clone(
            fromRemoteURL: remoteURL, toLocalURL: localPath, username: credentials.username,
            password: credentials.password)

        return RepositoryInfoModel(
            name: localPath.lastPathComponent, localPath: localPath, repository: repo)
    }

    static func initWith(localPath: URL) throws -> RepositoryInfoModel {
        // check if local path is available
        guard localPath.startAccessingSecurityScopedResource() else {
            throw RepositoryError.filePathUnavailable
        }

        // get repository
        let repo = try GitClient.getRepository(localPath: localPath)

        return RepositoryInfoModel(
            name: localPath.lastPathComponent, localPath: localPath, repository: repo)
    }

    func cleanup() {
        localPath.stopAccessingSecurityScopedResource()
    }

    func checkout(branch: String) -> Bool {
        guard let branch = try? repository.localBranches().first(where: { $0.name == branch })
        else {
            return false
        }

        let commit = try! branch.targetCommit()
        try! repository.checkoutCommit(commit, options: nil)
        try! repository.moveHEAD(to: branch.reference)

        return true
    }
}
