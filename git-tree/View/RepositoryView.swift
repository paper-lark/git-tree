import AppIntents
import SwiftUI

struct RepositoryView: View {
    var repository: Repository

    @State private var credentials = RemoteCredentialsStore.getCredentials()
    @State private var repositoryDetails = RepositoryDetails()

    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss

    @State private var selectedFiles = Set<String>()
    @State private var commitMessage = ""
    @State private var isLoaded = false
    @State private var latestError = ErrorDescription.noError()

    @State private var selectedRemote = ""
    @State private var selectedBranch = ""

    var body: some View {
        VStack {
            if !isLoaded {
                ProgressView("Opening repository")
            } else {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Branch:")
                        if let current = repositoryDetails.currentBranch {
                            Picker(selection: $selectedBranch, label: Text("Branch")) {
                                ForEach(repositoryDetails.localBranches, id: \.self) { branch in
                                    Text(branch).tag(branch)
                                }
                            }
                            //                            .onChange(of: $current.currentBranch, perform: {
                            //                                _ in vm.updateHeadInfo()
                            //                            })
                        }

                    }
                    HStack(alignment: .firstTextBaseline) {
                        Text("Remote:")
                        Picker(selection: $selectedRemote, label: Text("Remote")) {
                            ForEach(repositoryDetails.remotes, id: \.self) { branch in
                                Text(branch).tag(branch)
                            }
                        }

                    }
                    Text(
                        "Latest commit: \(repositoryDetails.currentBranch?.latestCommitSHA ?? "<none>")"
                    )
                }.padding()

                Divider()

                if let current = repositoryDetails.currentBranch {
                    List(
                        current.changedFiles.filter(shouldDisplayChangedFile),
                        selection: $selectedFiles
                    ) { file in
                        ChangedFileView(model: file)
                    }
                    .refreshable {
                        do {
                            selectedFiles.removeAll()
                            try await updateDetails()
                        } catch {
                            latestError.showError(
                                header: "Failed to refresh", description: error.localizedDescription
                            )
                            dismiss()
                        }
                    }
                }

                if isEditing() {
                    Divider()
                    HStack {
                        TextField("Commit message", text: $commitMessage)
                        Button {
                            Task {
                                do {
                                    let _ = try await CommitChangesIntent(
                                        repository: repository,
                                        files: selectedFiles,
                                        message: commitMessage
                                    ).perform()
                                    try await updateDetails()
                                    editMode?.wrappedValue = .inactive
                                } catch {
                                    latestError.showError(
                                        header: "Failed to commit",
                                        description: error.localizedDescription)
                                }
                            }
                        } label: {
                            Text("Commit")
                        }
                        .keyboardShortcut(.return)
                        .disabled(commitMessage.isEmpty)
                    }.padding()
                }
            }
        }
        .moveDisabled(true)
        .deleteDisabled(true)  // TODO: support reset for specific file
        .navigationTitle(repository.name)
        .errorMessage(error: $latestError)
        .toolbar {
            if repositoryDetails.currentBranch != nil {
                if !isEditing() {
                    Menu {
                        Button("Reset to remote") {
                            Task {
                                do {
                                    let _ = try await ResetToRemoteBranchIntent(
                                        repository: repository
                                    )
                                    .perform()
                                    try await updateDetails()
                                } catch {
                                    latestError.showError(
                                        header: "Failed to reset to remote",
                                        description: error.localizedDescription)
                                }
                            }
                        }

                        Button("Pull") {
                            Task {
                                do {
                                    let _ = try await PullBranchIntent(
                                        repository: repository,
                                        remote: selectedRemote,
                                        username: credentials.username,
                                        password: credentials.password
                                    ).perform()
                                    try await updateDetails()
                                } catch {
                                    latestError.showError(
                                        header: "Failed to pull from remote",
                                        description: error.localizedDescription)
                                }
                            }
                        }

                        Button("Push") {
                            Task {
                                do {
                                    let _ = try await PushBranchIntent(
                                        repository: repository,
                                        remote: selectedRemote,
                                        username: credentials.username,
                                        password: credentials.password
                                    ).perform()
                                    try await updateDetails()
                                } catch {
                                    latestError.showError(
                                        header: "Failed to push to remote",
                                        description: error.localizedDescription)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "doc.badge.gearshape")
                    }
                }

                EditButton()
            }
        }
        .task {
            defer { isLoaded = true }
            do {
                try await updateDetails()
            } catch {
                latestError.showError(
                    header: "Failed to open repository", description: error.localizedDescription)
                dismiss()
            }
        }
    }

    private func updateDetails() async throws {
        if let details = try await GetRepositoryDetailsIntent(repository: repository).perform()
            .value
        {
            repositoryDetails = details
            selectedBranch = details.currentBranch?.currentBranch ?? ""
            selectedRemote = details.remotes.first ?? ""
        }
    }

    private func isEditing() -> Bool {
        return editMode?.wrappedValue.isEditing ?? false
    }

    private func shouldDisplayChangedFile(file: ChangedFile) -> Bool {
        switch file.changeType {
        case .unmodified, .ignored:
            return false
        case .added, .deleted, .modified, .untracked, .renamed, .copied, .typeChange, .unreadable,
            .untracked,
            .conflicted:
            return true
        }
    }
}

// TODO: add preview for repository
//struct RepositoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        RepositoryView()
//    }
//}
