import SwiftUI

struct RepositoryView: View {
    @ObservedObject var vm: RepositoryViewModel
    
    var body: some View {
        VStack {
            HStack {
                
            }
            Text("Current branch: \(vm.currentBranch)")
            Text("Latest commit: \(vm.headCommitSHA)")
            Text("Changed files:")
            List {
                ForEach(vm.changedFiles, id: \.absoluteString) { url in
                    // TODO: update on actions in repository
                    Text(url.relativePath)
                }
            }.refreshable {
                vm.updateHeadInfo()
            }
        }
        .navigationTitle(vm.model.name)
        .toolbar {
            Button("Commit all") { vm.commitAll() }
            Button("Pull") { vm.pull() }
            Button("Push") { vm.push() }
        }
    }
}

//struct RepositoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        RepositoryView()
//    }
//}
