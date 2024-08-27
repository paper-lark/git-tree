import SwiftUI

struct RepositoryAsyncOperationView: View {
    @ObservedObject var operation: RepositoryAsyncOperation

    var body: some View {
        ProgressView(value: operation.currentProgress) {
            Text(description)
        }.progressViewStyle(.linear)
    }

    private var description: String {
        switch operation.kind {
        case .load:
            return "Loading repository"

        case .clone:
            return "Cloning repository"

        case .push:
            return "Pushing to remote"

        case .pull:
            return "Pulling from remote"

        case .commit:
            return "Commiting changes"

        case .reset:
            return "Resetting changes"
        }
    }
}

struct RepositoryAsyncOperationView_Previews: PreviewProvider {
    static var operation = RepositoryAsyncOperation(kind: .push, currentProgress: 0.1)

    static var previews: some View {
        VStack {
            RepositoryAsyncOperationView(operation: operation)
            Button("Add progress") {
                withAnimation {
                    operation.updateProgress(current: operation.currentProgress + 0.1)
                }
            }
        }
    }
}
