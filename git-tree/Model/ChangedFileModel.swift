import Foundation

enum FileChangeType {
    case added, modified, deleted, renamed
}

struct ChangedFileModel: Identifiable, Hashable {
    let fileURL: URL
    let changeType: FileChangeType
    let linesAdded: UInt
    let linesDeleted: UInt

    var id: String {
        fileURL.absoluteString
    }
}
