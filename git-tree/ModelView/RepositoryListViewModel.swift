import Foundation

class RepositoryListViewModel : ObservableObject {
    @Published var repositories: [RepositoryInfoModel] = []
    @Published var credentials = RemoteCredentialsViewModel()
    
    func addRepository(fromLocalURL localURL: URL) {
        if let newRepository = RepositoryInfoModel.initWith(localPath: localURL) {
            repositories.append(newRepository)
        }
    }
}
