import Foundation

class RepositoryListViewModel : ObservableObject {
    @Published var credentials = RemoteCredentialsViewModel()
    @Published var repositories: [RepositoryInfoModel] = []
    
    func addRepository(fromLocalURL localURL: URL) {
        if let newRepository = RepositoryInfoModel.initWith(localPath: localURL) {
            repositories.append(newRepository)
        }
    }
}
