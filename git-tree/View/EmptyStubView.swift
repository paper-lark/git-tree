import SwiftUI

struct EmptyStubView: View {
    let title: String

    var body: some View {
        Text(title)
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct EmptyStubView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStubView(title: "No repositories found")
    }
}
