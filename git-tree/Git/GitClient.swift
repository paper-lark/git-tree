import Foundation

struct GitClient {
    static let gitFolder = ".git"

    static func clone(fromRemoteURL: URL, toLocalURL: URL, username: String, password: String)
        throws -> GTRepository
    {
        // TODO: show progress
        // https://libgit2.org/docs/guides/101-samples/#repositories_clone_progress
        // TODO: does not checkout remote branch
        return try GTRepository.clone(
            from: fromRemoteURL, toWorkingDirectory: toLocalURL,
            options: getCloneRemoteOptions(username: username, password: password))
    }

    static func getRepository(localPath: URL) throws -> GTRepository {
        let repositoryFolder =
            (localPath.lastPathComponent == gitFolder
            ? localPath : URL(filePath: gitFolder, relativeTo: localPath)).absoluteURL
        return try GTRepository(url: repositoryFolder)
    }

    static func getChangesForRepository(_ repository: GTRepository) throws -> [ChangedFileModel] {
        var files: [URL: ChangedFileModel] = [:]

        func process(delta: GTStatusDelta) {
            let changeType = FileChangeType.fromDeltaType(delta.status)
            let oldFileURL = getFileURL(file: delta.newFile, relativeTo: repository.fileURL)
            let newFileURL = getFileURL(file: delta.oldFile, relativeTo: repository.fileURL)
            guard let key = newFileURL ?? oldFileURL else {
                return
            }

            files[key] = ChangedFileModel(
                oldFileURL: oldFileURL,
                newFileURL: newFileURL,
                changeType: changeType)
        }

        try repository.enumerateFileStatus(options: nil) { headToIndex, indexToWorkingDir, _ in
            if let diff = headToIndex {
                process(delta: diff)
            }
            if let diff = indexToWorkingDir {
                process(delta: diff)
            }
        }

        return files.sorted { $0.key.relativePath < $1.key.relativePath }.map { $0.value }
    }

    static func getFileURL(file: GTDiffFile?, relativeTo: URL?) -> URL? {
        guard let filePath = file?.path else {
            return nil
        }
        return URL.init(filePath: filePath, relativeTo: relativeTo)
    }

    static func getCloneRemoteOptions(username: String, password: String) throws -> [String: Any] {
        let credentials = try GTCredential(userName: username, password: password)
        return [
            GTRepositoryCloneOptionsCredentialProvider: GTCredentialProvider {
                _, _, _ in credentials
            },
            GTRepositoryCloneOptionsCheckoutOptions: GTCheckoutOptions(strategy: .force),
        ]
    }
}
