import Foundation

struct RepositoryBookmarkStore {
    static func getBookmarks() -> [String: Data] {
        return UserDefaults.standard.dictionary(forKey: "repositories") as? [String: Data] ?? [:]
    }

    static func storeBookmarks(bookmarks: [String: Data]) {
        UserDefaults.standard.set(bookmarks, forKey: "repositories")
    }

    static func addBookmark(localPath: URL, bookmarkData: Data) {
        var bookmarks = RepositoryBookmarkStore.getBookmarks()
        bookmarks[localPath.absoluteString] = bookmarkData
        RepositoryBookmarkStore.storeBookmarks(bookmarks: bookmarks)
    }

    static func removeBookmark(localPath: URL) {
        var bookmarks = RepositoryBookmarkStore.getBookmarks()
        bookmarks.removeValue(forKey: localPath.absoluteString)
        RepositoryBookmarkStore.storeBookmarks(bookmarks: bookmarks)
    }
}
