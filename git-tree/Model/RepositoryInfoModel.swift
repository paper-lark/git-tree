import Foundation

struct RepositoryInfoModel : Identifiable {
    let name: String
    let localPath: URL
    let repository: GTRepository
    
    var id: String {
        get { return localPath.absoluteString }
    }
    
    static func initWith(localPath: URL) -> RepositoryInfoModel? {
        guard localPath.startAccessingSecurityScopedResource() else {
            return nil
        }
        
        let repo = GitClient.getRepository(localPath: localPath)
        guard repo != nil else {
            return nil
        }
        
        return RepositoryInfoModel(name: localPath.lastPathComponent, localPath: localPath, repository: repo!)
    }
    
    func cleanup() {
        localPath.stopAccessingSecurityScopedResource()
    }
}
