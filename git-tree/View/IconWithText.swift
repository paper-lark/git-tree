import SwiftUI

struct IconWithText: View {
    let systemIcon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Image(systemName: systemIcon)
            Text(text)
        }
    }
}

struct IconWithText_Previews: PreviewProvider {
    static var previews: some View {
        IconWithText(systemIcon: "arrow.up.doc", text: "Send")
    }
}
