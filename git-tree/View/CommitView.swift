import SwiftUI

struct CommitView: View {
    let commit: Commit

    var body: some View {
        VStack(alignment: .leading) {
            if let msg = commit.message {
                Text(msg)
            } else {
                Text("No message").italic()
            }
            HStack(alignment: .firstTextBaseline) {
                Text(commit.sha)
                    .truncationMode(.middle)
                Text(commit.date.formatted(date: .abbreviated, time: .shortened))
                    .padding(.leading)
                    .fixedSize()
            }
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
    }
}

struct CommitView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CommitView(
                commit: Commit(
                    sha: "e3af08efadaa5e87e3d33b634157d0ebb7c7614a",
                    message: "some commit",
                    date: Date.now
                ))
            CommitView(
                commit: Commit(
                    sha: "e3af08efadaa5e87e3d33b634157d0ebb7c7614b",
                    date: Date.now
                ))
        }
    }
}
