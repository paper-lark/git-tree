import SwiftUI

struct ChangedFileView: View {
    let model: ChangedFile

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            if let oldFileURL = model.oldFileURL {
                if model.newFileURL != oldFileURL {
                    Text(oldFileURL.relativePath)
                }
            }

            if model.oldFileURL != nil && model.newFileURL != nil
                && model.oldFileURL != model.newFileURL
            {
                Image(systemName: "arrow.right")
            }

            if let newFileURL = model.newFileURL {
                Text(newFileURL.relativePath)
            }
            Spacer()
            changeType.bold().font(.body.monospaced()).padding(.leading, 16)
        }.lineLimit(1)
    }

    private var changeType: some View {
        switch model.changeType {
        case .modified:
            return Text("M").foregroundColor(.orange).help("The file was modified.")
        case .typeChange:
            return Text("T").foregroundColor(.orange).help(
                "The file has changed from a blob to either a submodule, symlink or directory. Or vice versa."
            )
        case .renamed:
            return Text("R").foregroundColor(.orange).help("The file has been renamed.")
        case .added:
            return Text("A").foregroundColor(.green).help("The file was added to the index.")
        case .copied:
            return Text("C").foregroundColor(.green).help("The file was duplicated.")
        case .unmodified:
            return Text("U").foregroundColor(.gray).help("The file has no changes.")
        case .ignored:
            return Text("I").foregroundColor(.gray).help("The file is ignored.")
        case .untracked:
            return Text("U").foregroundColor(.green).help(
                "The file has been added to the working directory and is therefore currently untracked."
            )
        case .deleted:
            return Text("D").foregroundColor(.red).help(
                "The file was removed from the working directory.")
        case .unreadable:
            return Text("U").foregroundColor(.red).help("The file is unreadable.")
        case .conflicted:
            return Text("C").foregroundColor(.red).help(
                "The file is conflicted in the working directory.")
        }
    }
}

struct ChangedFileView_Previews: PreviewProvider {
    @State static var isSelected: Bool = false

    static var previews: some View {
        let models = [
            ChangedFile(
                oldFileURL: URL(filePath: "long/long/long/long/long/long/test.txt"),
                newFileURL: URL(filePath: "test.md"),
                changeType: .renamed),
            ChangedFile(
                oldFileURL: URL(filePath: "test2.txt"),
                newFileURL: URL(filePath: "test2.txt"),
                changeType: .modified),
            ChangedFile(
                oldFileURL: URL(filePath: "test3.txt"),
                newFileURL: nil,
                changeType: .deleted),
            ChangedFile(
                oldFileURL: nil,
                newFileURL: URL(filePath: "test3.txt"),
                changeType: .added),
        ]

        List {
            ForEach(models) { model in
                ChangedFileView(model: model)
            }
        }
    }
}
