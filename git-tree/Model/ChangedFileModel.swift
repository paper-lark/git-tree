import Foundation

enum FileChangeType {
    case Added, Modified, Deleted, Renamed
}

struct ChangedFileModel : Identifiable, Hashable {
    let fileURL: URL
    let changeType: FileChangeType
    let linesAdded: UInt
    let linesDeleted: UInt
    
    var id: String {
        get { fileURL.absoluteString }
    }
}
