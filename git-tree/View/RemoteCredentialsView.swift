import SwiftUI

struct RemoteCredentialsView: View {
    @ObservedObject var credentials: RemoteCredentialsViewModel

    var body: some View {
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

struct RemoteCredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            RemoteCredentialsView(credentials: RemoteCredentialsViewModel())
        }
    }
}
