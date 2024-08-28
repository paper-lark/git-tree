import Foundation

enum FileChangeType {
    case unmodified, added, deleted, modified, renamed, copied, ignored, untracked, typeChange,
        unreadable, conflicted

    static func fromDeltaType(_ value: GTDeltaType) -> FileChangeType {
        switch value {
        case .unmodified:
            return .unmodified
        case .added:
            return .added
        case .deleted:
            return .deleted
        case .modified:
            return .modified
        case .renamed:
            return .renamed
        case .copied:
            return .copied
        case .ignored:
            return .ignored
        case .untracked:
            return .untracked
        case .typeChange:
            return .typeChange
        case .unreadable:
            return .unreadable
        case .conflicted:
            return .conflicted
        default:
            return .unreadable
        }
    }
}

struct ChangedFileModel: Identifiable, Hashable {
    let oldFileURL: URL?
    let newFileURL: URL?
    let changeType: FileChangeType

    var id: String {
        newFileURL?.relativePath ?? oldFileURL?.relativePath ?? ""
    }
}
