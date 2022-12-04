import SwiftUI

struct RepositoryView: View {
    @ObservedObject var vm: RepositoryViewModel

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Branch:")
                    Picker(selection: $vm.currentBranch, label: Text("Branch")) {
                        ForEach(vm.localBranches, id: \.self) { branch in
                            Text(branch).tag(branch)
                        }
                    }
                    .onChange(of: vm.currentBranch, perform: { _ in vm.updateHeadInfo() })
                }
                Text("Latest commit: \(vm.headCommitSHA)")

                if let op = vm.currentOperation {
                    RepositoryAsyncOperationView(operation: op).padding(.top)
                }
            }.padding()

            Divider()

            List {
                ForEach(vm.changedFiles) { file in
                    ChangedFileView(model: file)
                }
            }.refreshable {
                vm.updateHeadInfo()
            }
            Divider()
            HStack {
                TextField("Commit message", text: $vm.commitMessage)
                Button("Commit") { vm.commit() }
                    .keyboardShortcut(.return)
                    .disabled(vm.currentOperation != nil || vm.changedFiles.isEmpty)
            }.padding()
        }
        .navigationTitle(vm.model.name)
        .toolbar {
            Button(
                action: { vm.pull() },
                label: { IconWithText(systemIcon: "arrow.down.doc", text: "Pull") }
            ).disabled(vm.currentOperation != nil)
            Button(
                action: { vm.push() },
                label: { IconWithText(systemIcon: "arrow.up.doc", text: "Push") }
            ).disabled(vm.currentOperation != nil)
        }
    }
}

// TODO: add preview for repository
//struct RepositoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        RepositoryView()
//    }
//}
