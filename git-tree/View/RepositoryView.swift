import SwiftUI

struct RepositoryView: View {
    @ObservedObject var vm: RepositoryViewModel
    @State var commitMessage: String = ""
    @State var isPushing: Bool = false
    @State var isPulling: Bool = false
    @State var isCommitting: Bool = false

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
            }.padding()

            List {
                ForEach(vm.changedFiles) { file in
                    ChangedFileView(model: file)
                }
            }.refreshable {
                vm.updateHeadInfo()
            }
            Divider()
            HStack {
                TextField("Commit message", text: $commitMessage)
                Button("Commit") { commit() }
                    .keyboardShortcut(.return)
                    .disabled(isCommitting || vm.changedFiles.isEmpty)
            }.padding()
        }
        .navigationTitle(vm.model.name)
        .toolbar {
            Button(
                action: { pull() },
                label: { IconWithText(systemIcon: "arrow.down.doc", text: "Pull") }
            ).disabled(isPulling)
            Button(
                action: { push() },
                label: { IconWithText(systemIcon: "arrow.up.doc", text: "Push") }
            ).disabled(isPushing)
        }
    }

    private func commit() {
        isCommitting = true
        let message = commitMessage
        commitMessage = ""
        DispatchQueue.main.async {
            vm.commitAll(message: message)
            isCommitting = false
        }
    }

    private func pull() {
        isPulling = true
        DispatchQueue.main.async {
            vm.pull()
            isPulling = false
        }
    }

    private func push() {
        isPushing = true
        DispatchQueue.main.async {
            vm.push()
            isPushing = false
        }
    }
}

// TODO: add preview for repository
//struct RepositoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        RepositoryView()
//    }
//}
