import SwiftUI

enum RepositoryAsyncOperationKind {
    case load, clone, push, pull, commit, reset
}

class RepositoryAsyncOperation: ObservableObject {
    let kind: RepositoryAsyncOperationKind

    @Published var currentProgress: Float = 0

    init(kind: RepositoryAsyncOperationKind, currentProgress: Float = 0) {
        self.kind = kind
        self.currentProgress = currentProgress
    }

    func updateProgress(current: Float) {
        self.currentProgress = current
    }
}
