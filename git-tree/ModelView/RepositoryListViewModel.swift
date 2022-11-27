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

    func loadBookmarks() -> Self {
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

        return self
    }

    func addRepository(fromLocalURL localURL: URL, withBookmark: Bool = true) {
        guard repositories.firstIndex(where: { $0.localPath == localURL }) == nil else {
            return
        }

        if let newRepository = RepositoryInfoModel.initWith(localPath: localURL) {
            repositories.append(newRepository)

            if withBookmark {
                if let bookmarkData = try? localURL.bookmarkData(
                    options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
                {
                    repositoryBookmarks[localURL.absoluteString] = bookmarkData
                }
            }
        }
    }

    func removeRepository(withLocalURL localURL: URL) {
        if let index = repositories.firstIndex(where: { $0.localPath == localURL }) {
            repositories.remove(at: index).cleanup()
        }
        repositoryBookmarks.removeValue(forKey: localURL.absoluteString)
    }
}
