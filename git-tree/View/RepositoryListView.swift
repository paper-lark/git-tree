import SwiftUI

struct RepositoryListView: View {
    @ObservedObject private var vm = RepositoryListViewModel().loadBookmarks()
    
    @State private var selection: String? = nil
    @State private var showRepositoryPicker = false
    @State private var showCredentialsEditor = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if vm.repositories.isEmpty {
                        Text("No repositories found")
                            .foregroundColor(.secondary)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(vm.repositories) { repo in
                            NavigationLink(repo.name) {
                                RepositoryView(vm: RepositoryViewModel(model: repo, credentials: vm.credentials.toModel()))
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showRepositoryPicker) {
                DocumentPicker(vm: vm)
            }
            .sheet(isPresented: $showCredentialsEditor, onDismiss: { vm.credentials.persist() }) {
                RemoteCredentialsView(credentials: vm.credentials)
            }
            .toolbar {
                Button(action: {showCredentialsEditor = true}, label: {
                    Image(systemName: "person")
                })
                Button(
                    action: {showRepositoryPicker  = true},
                    label: {
                        Image(systemName: "plus")
                    }
                )
            }.navigationTitle("Repositories")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryListView()
    }
}
