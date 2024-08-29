import SwiftUI

struct CloneRemoteRepositoryScreenView: View {
    @Environment(\.dismiss) var dismiss

    @State private var repositoryURL: String = ""
    @State private var selectedLocalURL: URL? = nil
    @State private var showFolderSelect = false
    @State private var credentials = RemoteCredentials(username: "", password: "")
    @State private var latestError = ErrorDescription.noError()
    @State private var isCloningRepository = false

    var onSuccess: (Repository) -> Void

    var body: some View {
        NavigationView {
            if isCloningRepository {
                ProgressView {
                    Text("Cloning repository…")
                }
            }

            Form {
                RemoteRepositoryView(repositoryURL: $repositoryURL)
                RemoteCredentialsView(credentials: $credentials)
                Button("Select local folder") {
                    showFolderSelect = true
                }
            }
            .fileImporter(isPresented: $showFolderSelect, allowedContentTypes: [.folder]) {
                result in
                switch result {
                case .success(let directory):
                    selectedLocalURL = directory
                case .failure(let error):
                    latestError.showError(
                        header: "Failed to open folder", description: error.localizedDescription
                    )
                }
            }
            .navigationBarTitle("Add remote repository", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Clone") {
                    if let remoteURL = URL(string: repositoryURL), let localURL = selectedLocalURL {
                        isCloningRepository = true

                        Task {
                            defer { isCloningRepository = false }

                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            do {
                                if let newRepository = try await CloneLocalRepositoryIntent(
                                    localPath: localURL, remoteURL: remoteURL,
                                    credentials: credentials
                                ).perform().value {
                                    onSuccess(newRepository)
                                    dismiss()
                                }
                            } catch {
                                latestError.showError(
                                    header: "Failed to open repository",
                                    description: error.localizedDescription)
                            }

                        }
                    }
                }.disabled(!isParametersValid())
            )
            .errorMessage(error: $latestError)
        }
    }

    private func isParametersValid() -> Bool {
        if let _ = URL(string: repositoryURL), let _ = selectedLocalURL {
            return true
        }
        return false
    }
}

struct CloneRepositoryScreenView_Previews: PreviewProvider {
    @State static var show: Bool = true

    static var previews: some View {
        VStack {
            Button("Show") {
                show = true
            }
        }.sheet(isPresented: $show) {
            CloneRemoteRepositoryScreenView { _ in
                print("Success")
            }
        }
    }
}
