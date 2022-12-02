import SwiftUI

struct RemoteRepositoryView: View {
    @Binding var repositoryURL: String

    var body: some View {
        Section("Remote repository") {
            TextField("Repository URL", text: $repositoryURL)
                .textContentType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
    }
}

struct RemoteRepositoryView_Previews: PreviewProvider {
    @State static var url: String = ""

    static var previews: some View {
        Form {
            RemoteRepositoryView(repositoryURL: $url)
        }
    }
}
