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
    @Published var latestError = ErrorDescription.noError()

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
    ) -> Bool {
        // check if repository already exists
        guard repositories.firstIndex(where: { $0.localPath == remoteURL }) == nil else {
            return true
        }

        // clone remote repository
        do {
            let newRepository = try RepositoryInfoModel.clone(
                fromRemoteURL: remoteURL,
                toLocalPath: localURL,
                credentials: credentials)
            addRepository(newRepository)
            return true
        } catch {
            latestError.showError(
                header: "Failed to fetch remote repository", description: error.localizedDescription
            )
            return false
        }
    }

    func addRepository(fromLocalURL localURL: URL) -> Bool {
        // check if repository already exists
        guard repositories.firstIndex(where: { $0.localPath == localURL }) == nil else {
            return true
        }

        // initialize local repository
        do {
            let newRepository = try RepositoryInfoModel.initWith(localPath: localURL)
            addRepository(newRepository)
            return true
        } catch {
            latestError.showError(
                header: "Failed to open local repository", description: error.localizedDescription)
            return false
        }
    }

    func removeRepository(withLocalURL localURL: URL) {
        if let index = repositories.firstIndex(where: { $0.localPath == localURL }) {
            repositories.remove(at: index).cleanup()
        }
        repositoryBookmarks.removeValue(forKey: localURL.absoluteString)
    }

    private func addRepository(_ newRepository: RepositoryInfoModel) {
        repositories.append(newRepository)

        if let bookmarkData = try? newRepository.localPath.bookmarkData(
            options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
        {
            repositoryBookmarks[newRepository.localPath.absoluteString] = bookmarkData
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
