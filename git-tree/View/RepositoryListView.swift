import SwiftUI

struct RepositoryListView: View {
    @State var repositories: [Repository]
    @State var latestError: ErrorDescription = .noError()

    @State private var selection: String? = nil
    @State private var showAddLocalRepository = false
    @State private var showCloneRepository = false
    @State private var isAddingLocalRepository = false

    var body: some View {
        NavigationView {
            VStack {
                if isAddingLocalRepository {
                    ProgressView {
                        Text("Adding repository…")
                    }
                }

                if repositories.isEmpty {
                    Text("No repositories found")
                        .foregroundColor(.secondary)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                } else {
                    List(repositories) { repo in
                        NavigationLink(repo.name) {
                            RepositoryView(repository: repo)
                        }.swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                repositories.removeAll { $0.id == repo.id }
                                Task {
                                    do {
                                        let _ = try await DeleteLocalRepository(
                                            localPath: repo.localPath
                                        ).perform()
                                    } catch {
                                        latestError.showError(
                                            header: "Failed to delete repository",
                                            description: error.localizedDescription)
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }

                    .listStyle(.plain)
                    .refreshable {
                        Task {
                            do {
                                repositories = try await RepositoryQuery().suggestedEntities()
                            } catch {
                                latestError.showError(
                                    header: "Failed to refresh repositories",
                                    description: error.localizedDescription)
                            }
                        }
                    }
                    .moveDisabled(true)
                }
                //                if let op = vm.currentOperation {
                //                    RepositoryAsyncOperationView(operation: op).padding(.top)
                //                }
            }
            .fileImporter(isPresented: $showAddLocalRepository, allowedContentTypes: [.folder]) {
                result in
                switch result {
                case .success(let directory):
                    isAddingLocalRepository = true
                    Task {
                        defer { isAddingLocalRepository = false }
                        do {
                            if let newRepository = try await AddLocalRepositoryIntent(
                                localPath: directory
                            ).perform().value {
                                addRepository(newRepository: newRepository)
                            }
                        } catch {
                            latestError.showError(
                                header: "Failed to open repository",
                                description: error.localizedDescription)
                        }

                    }
                case .failure(let error):
                    latestError.showError(
                        header: "Failed to open repository", description: error.localizedDescription
                    )
                }
            }
            .sheet(
                isPresented: $showCloneRepository
            ) {
                CloneRemoteRepositoryScreenView(onSuccess: addRepository)
            }
            .toolbar {
                Menu {
                    Button {
                        showAddLocalRepository = true
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
            .errorMessage(error: $latestError)
        }
    }

    private func addRepository(newRepository: Repository) {
        repositories = repositories + [newRepository]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryListView(repositories: [
            Repository(name: "Test", localPath: URL(fileURLWithPath: "."))
        ])
    }
}
