import SwiftUI

struct RepositoryView: View {
    var repository: Repository
    @State private var repositoryDetails = RepositoryDetails()

    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss

    @State private var selectedFiles = Set<String>()
    @State private var commitMessage = ""
    @State private var isLoaded = false
    @State private var latestError = ErrorDescription.noError()

    var body: some View {
        VStack {
            if !isLoaded {
                ProgressView("Opening repository")
            } else {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Branch:")
                        //                    if let current = repositoryDetails.currentBranch {
                        //                        Picker(selection: $current.currentBranch, label: Text("Branch")) {
                        //                            ForEach(repositoryDetails.localBranches, id: \.self) { branch in
                        //                                Text(branch).tag(branch)
                        //                            }
                        //                        }
                        //                        .onChange(of: $current.currentBranch, perform: {
                        //                            _ in vm.updateHeadInfo()
                        //                        })
                        //                    }

                    }
                    Text(
                        "Latest commit: \(repositoryDetails.currentBranch?.latestCommitSHA ?? "<none>")"
                    )

                    //                if let op = vm.currentOperation {
                    //                    RepositoryAsyncOperationView(operation: op).padding(.top)
                    //                }
                }.padding()

                Divider()

                if let current = repositoryDetails.currentBranch {
                    List(
                        current.changedFiles.filter(shouldDisplayChangedFile),
                        selection: $selectedFiles
                    ) { file in
                        ChangedFileView(model: file)
                    }
                    //                .refreshable {
                    //                    vm.updateHeadInfo()
                    //                    selectedFiles.removeAll()
                    //                }
                }

                if isEditing() {
                    Divider()
                    HStack {
                        TextField("Commit message", text: $commitMessage)
                        Button("Commit") {
                            //                        vm.commit(files: selectedFiles)
                            editMode?.wrappedValue = .inactive
                        }
                        .keyboardShortcut(.return)
                        .disabled(
                            //                        vm.currentOperation != nil || vm.changedFiles.isEmpty
                            false
                        )
                    }.padding()
                }
            }
        }
        .moveDisabled(true)
        .deleteDisabled(true)  // TODO: support reset for specific file
        .navigationTitle(repositoryDetails.repository.name)
        .toolbar {
            if repositoryDetails.currentBranch != nil {
                EditButton()

                if !isEditing() {
                    Button(
                        action: {
                            //                            vm.resetToRemote()
                        },
                        label: { IconWithText(systemIcon: "doc.badge.gearshape", text: "Reset") }
                    ).disabled(
                        //                        vm.currentOperation != nil
                        false
                    )
                    Button(
                        action: {
                            //                            vm.pull()
                        },
                        label: { IconWithText(systemIcon: "arrow.down.doc", text: "Pull") }
                    ).disabled(
                        //                        vm.currentOperation != nil
                        false
                    )
                    Button(
                        action: {
                            //                            vm.push()
                        },
                        label: { IconWithText(systemIcon: "arrow.up.doc", text: "Push") }
                    ).disabled(
                        //                        vm.currentOperation != nil
                        false
                    )
                }
            }
        }
        .task {
            defer { isLoaded = true }
            do {
                if let details = try await GetRepositoryDetails(repository: repository).perform()
                    .value
                {
                    repositoryDetails = details
                }
            } catch {
                latestError.showError(
                    header: "Failed to open repository", description: error.localizedDescription)
                dismiss()
            }
        }
    }

    private func isEditing() -> Bool {
        return editMode?.wrappedValue.isEditing ?? false
    }

    private func shouldDisplayChangedFile(file: ChangedFile) -> Bool {
        switch file.changeType {
        case .unmodified, .ignored, .untracked:
            return false
        case .added, .deleted, .modified, .untracked, .renamed, .copied, .typeChange, .unreadable,
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
