import SwiftUI

struct RepositoryView: View {
    @ObservedObject var vm: RepositoryViewModel
    @State var commitMessage: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Branch: \(vm.currentBranch)")
                Text("Commit: \(vm.headCommitSHA)")
            }
            
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
                Button("Commit") {
                    vm.commitAll(message: commitMessage)
                    commitMessage = ""
                }
                .keyboardShortcut(.return)
                .disabled(vm.changedFiles.isEmpty)
            }.padding()
        }
        .navigationTitle(vm.model.name)
        .toolbar {
            Button(action: { vm.pull() }, label: { IconWithText(systemIcon: "arrow.down.doc", text: "Pull") })
            Button(action: { vm.push() }, label: { IconWithText(systemIcon: "arrow.up.doc", text: "Push") })
        }
    }
}

//struct RepositoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        RepositoryView()
//    }
//}
