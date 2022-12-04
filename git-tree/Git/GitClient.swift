import Foundation

struct GitClient {
    static let gitFolder = ".git"

    static func clone(fromRemoteURL: URL, toLocalURL: URL, username: String, password: String)
        -> GTRepository?
    {
        return try! GTRepository.clone(
            from: fromRemoteURL, toWorkingDirectory: toLocalURL,
            options: getCloneRemoteOptions(username: username, password: password))
    }

    static func getRepository(localPath: URL) -> GTRepository? {
        do {
            let repositoryFolder =
                (localPath.lastPathComponent == gitFolder
                ? localPath : URL(filePath: gitFolder, relativeTo: localPath)).absoluteURL
            return try GTRepository(url: repositoryFolder)
        } catch let err {
            print(err)
            return nil
        }
    }

    static func getChangesForRepository(_ repository: GTRepository) -> [ChangedFileModel] {
        var files: [URL: ChangedFileModel] = [:]

        func process(delta: GTStatusDelta) {
            let changeType = FileChangeType.fromDeltaType(delta.status)
            let oldFileURL = getFileURL(file: delta.newFile, relativeTo: repository.fileURL)
            let newFileURL = getFileURL(file: delta.oldFile, relativeTo: repository.fileURL)
            guard let key = newFileURL ?? oldFileURL else {
                return
            }

            files[key] = ChangedFileModel(
                fileURL: key,
                oldFileURL: oldFileURL,
                newFileURL: newFileURL,
                changeType: changeType)
        }

        try! repository.enumerateFileStatus(options: nil) { headToIndex, indexToWorkingDir, _ in
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

    static func getCloneRemoteOptions(username: String, password: String) -> [String: Any] {
        return [
            GTRepositoryCloneOptionsCredentialProvider: GTCredentialProvider {
                _, _, _ in
                try! GTCredential(
                    userName: username, password: password)
            }
        ]
    }
}
