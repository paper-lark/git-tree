import SwiftUI

enum RepositoryAsyncOperationKind {
    case push, pull, commit
}

class RepositoryAsyncOperation: ObservableObject {
    let kind: RepositoryAsyncOperationKind

    @Published var currentProgress: Float = 0

    init(kind: RepositoryAsyncOperationKind, currentProgress: Float = 0) {
        self.kind = kind
        self.currentProgress = currentProgress
    }

    func updateProgress(current: Float) {
        withAnimation {
            self.currentProgress = current
        }
    }
}
