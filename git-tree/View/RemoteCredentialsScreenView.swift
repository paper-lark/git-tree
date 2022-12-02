import SwiftUI

struct RemoteCredentialsScreenView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var credentials: RemoteCredentialsViewModel

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
            .navigationBarTitle("Edit remote credentials", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    dismiss()
                })
        }
    }
}

struct RemoteCredentialsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteCredentialsScreenView(credentials: RemoteCredentialsViewModel())
    }
}
