import SwiftUI

struct RemoteCredentialsView: View {
    @Binding var credentials: RemoteCredentials

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
    @State static var credentials = RemoteCredentials()
    static var previews: some View {
        Form {
            RemoteCredentialsView(credentials: $credentials)
        }
    }
}
