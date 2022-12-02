import Foundation
import SwiftUI

class RepositoryListViewModel: ObservableObject {
    @Published var credentials = RemoteCredentialsViewModel()
    @Published var repositoryBookmarks: [String: Data] =
        UserDefaults.standard.dictionary(forKey: "repositories") as? [String: Data] ?? [:]
    {
        didSet {
            UserDefaults.standard.set(repositoryBookmarks, forKey: "repositories")
        }
    }
    @Published var repositories: [RepositoryInfoModel] = []

    func loadBookmarks() {
        let currentBookmarks = self.repositoryBookmarks
        self.repositories = []
        self.repositoryBookmarks = [:]

        for (oldURL, bookmarkData) in currentBookmarks {
            print("Loading bookmarked repository: \(oldURL)")
            var isStale = false
            guard
                let localURL = try? URL(
                    resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale), !isStale
            else {
                continue
            }
            print("Loaded bookmarked repository: \(localURL.absoluteString)")
            self.addRepository(fromLocalURL: localURL)
        }
    }

    func addRepository(
        fromRemoteURL remoteURL: URL, toLocalURL localURL: URL, credentials: RemoteCredentialsModel
    ) {
        guard repositories.firstIndex(where: { $0.localPath == remoteURL }) == nil else {
            return
        }

        if let newRepository = RepositoryInfoModel.clone(
            fromRemoteURL: remoteURL, toLocalPath: localURL, credentials: credentials)
        {
            addRepository(newRepository)
        }
    }

    func addRepository(fromLocalURL localURL: URL) {
        guard repositories.firstIndex(where: { $0.localPath == localURL }) == nil else {
            return
        }

        if let newRepository = RepositoryInfoModel.initWith(localPath: localURL) {
            addRepository(newRepository)
        }
    }

    func removeRepository(withLocalURL localURL: URL) {
        if let index = repositories.firstIndex(where: { $0.localPath == localURL }) {
            repositories.remove(at: index).cleanup()
        }
        repositoryBookmarks.removeValue(forKey: localURL.absoluteString)
    }

    private func addRepository(_ model: RepositoryInfoModel) {
        repositories.append(newRepository)

        if let bookmarkData = try? localURL.bookmarkData(
            options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
        {
            repositoryBookmarks[localURL.absoluteString] = bookmarkData
        }
    }
}

// TODO: move to helpers
func stripFileExtension(_ filename: String) -> String {
    var components = filename.components(separatedBy: ".")
    guard components.count > 1 else { return filename }
    components.removeLast()
    return components.joined(separator: ".")
}
