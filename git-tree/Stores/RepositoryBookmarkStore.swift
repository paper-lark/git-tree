import Foundation

struct RepositoryBookmarkStore {
    static func getBookmarks() -> [String: Data] {
        return UserDefaults.standard.dictionary(forKey: "repositories") as? [String: Data] ?? [:]
    }

    static func storeBookmarks(bookmarks: [String: Data]) {
        UserDefaults.standard.set(bookmarks, forKey: "repositories")
    }
}
