import SwiftUI

struct CloneRemoteRepositoryScreenView: View {
    @Environment(\.dismiss) var dismiss
    @State var repositoryURL: String = ""
    @State var selectedLocalURL: URL? = nil
    @State var showFolderSelect = false
    @ObservedObject var vm: RepositoryListViewModel

    var body: some View {
        NavigationView {
            Form {
                RemoteRepositoryView(repositoryURL: $repositoryURL)
                RemoteCredentialsView(credentials: vm.credentials)
                Button("Select local folder") {
                    showFolderSelect = true
                }
            }
            .sheet(isPresented: $showFolderSelect) {
                DocumentPickerView(addRepository: { url in
                    selectedLocalURL = url
                })
            }
            .navigationBarTitle("Add remote repository", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Clone") {
                    if let remoteURL = URL(string: repositoryURL), let localURL = selectedLocalURL {
                        if vm.addRepository(
                            fromRemoteURL: remoteURL, toLocalURL: localURL,
                            credentials: vm.credentials.toModel()
                        ) {
                            dismiss()
                        }
                    }
                }
            )
            .errorMessage(error: $vm.latestError)
        }
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
            CloneRemoteRepositoryScreenView(vm: RepositoryListViewModel())
        }
    }
}
