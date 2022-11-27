import SwiftUI

struct RemoteCredentialsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var credentials: RemoteCredentialsViewModel

    var body: some View {
        Form {
            Section("Remote credentials") {
                TextField("Username", text: $credentials.username)
                    .textContentType(.username)
                    .autocorrectionDisabled(true)
                SecureField("Password", text: $credentials.password)
                    .textContentType(.password)
                    .autocorrectionDisabled(true)
            }
        }
    }
}

struct RemoteCredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteCredentialsView(credentials: RemoteCredentialsViewModel())
    }
}
