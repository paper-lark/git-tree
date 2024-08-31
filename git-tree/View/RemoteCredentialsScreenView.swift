import SwiftUI

struct RemoteCredentialsScreenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var credentials = RemoteCredentialsStore.getCredentials()

    var body: some View {
        NavigationView {
            Form {
                Section("Remote credentials") {
                    TextField("Username", text: $credentials.username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    SecureField("Password", text: $credentials.password)
                        .textContentType(.password)
                        .autocorrectionDisabled(true)
                }
            }
            .navigationBarTitle("Remote credentials", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Save") {
                    RemoteCredentialsStore.store(credentials: credentials)
                    dismiss()
                })
        }
    }
}

struct RemoteCredentialsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteCredentialsScreenView()
    }
}
