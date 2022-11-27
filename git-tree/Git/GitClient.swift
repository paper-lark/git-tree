import Foundation

struct GitClient {
    static let gitFolder = ".git"

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
        let tree = try! repository.currentBranch().targetCommit().tree!

        try! GTDiff(workingDirectoryFrom: tree, in: repository).enumerateDeltas { delta, _ in
            // get delta information
            let leftFile = getFileURL(file: delta.oldFile, relativeTo: repository.fileURL)
            let rightFile = getFileURL(file: delta.newFile, relativeTo: repository.fileURL)
            let patch = try! delta.generatePatch()

            // infer file and change type
            let fileURL: URL
            let changeType: FileChangeType
            if rightFile != nil {
                changeType =
                    leftFile == nil
                    ? FileChangeType.added
                    : (leftFile != rightFile ? FileChangeType.renamed : FileChangeType.modified)
                fileURL = rightFile!
            } else if leftFile != nil {
                changeType = FileChangeType.deleted
                fileURL = leftFile!
            } else {
                return
            }

            // update model
            let model =
                files[fileURL]
                ?? ChangedFileModel(
                    fileURL: fileURL, changeType: changeType, linesAdded: 0, linesDeleted: 0)
            files[fileURL] = ChangedFileModel(
                fileURL: model.fileURL, changeType: model.changeType,
                linesAdded: model.linesAdded + patch.addedLinesCount,
                linesDeleted: model.linesDeleted + patch.deletedLinesCount)
        }

        return files.sorted { $0.key.relativePath < $1.key.relativePath }.map { $0.value }
    }

    static func getFileURL(file: GTDiffFile?, relativeTo: URL?) -> URL? {
        guard let filePath = file?.path else {
            return nil
        }
        return URL.init(filePath: filePath, relativeTo: relativeTo)
    }
}
