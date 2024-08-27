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
    static var previews: some View {
        let vm = RepositoryAsyncOperation(kind: .push, currentProgress: 0)

        VStack {
            RepositoryAsyncOperationView(operation: vm)
            Button("Add progress") {
                vm.updateProgress(current: vm.currentProgress + 0.1)
            }
        }
    }
}
