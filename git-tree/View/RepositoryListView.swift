import SwiftUI

struct RepositoryListView: View {
    @ObservedObject var vm: RepositoryListViewModel

    @State private var selection: String? = nil
    @State private var showAddRepository = false
    @State private var showCredentialsEditor = false
    @State private var showCloneRepository = false

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
                                RepositoryView(
                                    vm: RepositoryViewModel(
                                        model: repo, credentials: vm.credentials.toModel()))
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddRepository) {
                AddRepositoryScreenView(vm: vm)
            }
            .sheet(
                isPresented: $showCredentialsEditor, onDismiss: { vm.credentials.persist() },
                content: {
                    RemoteCredentialsScreenView(credentials: vm.credentials)
                }
            )
            .sheet(
                isPresented: $showCloneRepository
            ) {
                CloneRemoteRepositoryScreenView(vm: vm)
            }
            .toolbar {
                Button(
                    action: { showCredentialsEditor = true },
                    label: {
                        Image(systemName: "person")
                    })
                Menu {
                    Button {
                        showAddRepository = true
                    } label: {
                        Text("Add local repository")
                        Image(systemName: "folder")
                    }
                    Button {
                        showCloneRepository = true
                    } label: {
                        Text("Add remote repository")
                        Image(systemName: "globe")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            .navigationTitle("Repositories")
            .errorMessage(error: $vm.latestError)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryListView(vm: RepositoryListViewModel())
    }
}
