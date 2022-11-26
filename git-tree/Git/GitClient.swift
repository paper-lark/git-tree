import Foundation

struct GitClient {
    static let gitFolder = ".git"
    
    static func getRepository(localPath: URL) -> GTRepository? {
        do {
            let repositoryFolder = (localPath.lastPathComponent == gitFolder ? localPath : URL(filePath: gitFolder, relativeTo: localPath)).absoluteURL
            return try GTRepository(url: repositoryFolder)
        } catch let err {
            print(err)
            return nil
        }
    }
    
    static func getChangesForRepository(_ repository: GTRepository) -> [URL] {
        var files: Set<URL> = []
        try! GTDiff(workingDirectoryToHEADIn: repository).enumerateDeltas { delta, _ in
            if let filePath = delta.newFile?.path {
                files.insert(URL.init(filePath: filePath, relativeTo: repository.fileURL))
            }
        }
        return Array(files)
    }
}
  
