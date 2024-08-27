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
    @Published var currentOperation: RepositoryAsyncOperation? = nil

    func loadBookmarks() {
        let currentBookmarks = self.repositoryBookmarks
        self.repositories = []
        self.repositoryBookmarks = [:]

        // start loading bookmarked repositories
        let op = RepositoryAsyncOperation(kind: .load, currentProgress: 0)
        currentOperation = op

        DispatchQueue.global(qos: .userInitiated).async {
            for (oldURL, bookmarkData) in currentBookmarks {
                // check bookmark state
                var isStale = false
                guard
                    let localURL = try? URL(
                        resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale),
                    !isStale
                else {
                    // TODO: Remove stale bookmarks
                    continue
                }

                // load repository
                if let newRepository = try? RepositoryInfoModel.initWith(localPath: localURL) {
                    DispatchQueue.main.async {
                        self.addRepository(newRepository)
                    }
                } else {
                    print("Removing invalid repository")
                    DispatchQueue.main.async {
                        self.removeRepository(withLocalURL: localURL)
                    }
                }
            }

            DispatchQueue.main.async {
                self.currentOperation = nil
            }
        }
    }

    func addRepository(
        fromRemoteURL remoteURL: URL, toLocalURL localURL: URL, credentials: RemoteCredentialsModel
    ) {
        // check if repository already exists
        guard repositories.firstIndex(where: { $0.localPath == remoteURL }) == nil else {
            return
        }

        // start cloning repository
        let op = RepositoryAsyncOperation(kind: .clone, currentProgress: 0)
        currentOperation = op

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let newRepository = try RepositoryInfoModel.clone(
                    fromRemoteURL: remoteURL,
                    toLocalPath: localURL,
                    credentials: credentials)

                DispatchQueue.main.async {
                    self.addRepository(newRepository)
                    self.currentOperation = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.latestError.showError(
                        header: "Failed to fetch remote repository",
                        description: error.localizedDescription
                    )
                    self.currentOperation = nil
                }
            }
        }
    }

    func addRepository(fromLocalURL localURL: URL) {
        // check if repository already exists
        guard repositories.firstIndex(where: { $0.localPath == localURL }) == nil else {
            return
        }

        // start loading local repository
        let op = RepositoryAsyncOperation(kind: .load, currentProgress: 0)
        currentOperation = op

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let newRepository = try RepositoryInfoModel.initWith(localPath: localURL)
                DispatchQueue.main.async {
                    self.addRepository(newRepository)
                    self.currentOperation = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.latestError.showError(
                        header: "Failed to open local repository",
                        description: error.localizedDescription)
                    self.currentOperation = nil
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
