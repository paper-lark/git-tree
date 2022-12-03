import SwiftUI

struct ChangedFileView: View {
    let model: ChangedFileModel

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
            return Text("M").foregroundColor(.orange)
        case .typeChange:
            return Text("T").foregroundColor(.orange)
        case .renamed:
            return Text("R").foregroundColor(.orange)

        case .added:
            return Text("A").foregroundColor(.green)
        case .copied:
            return Text("C").foregroundColor(.green)
        case .unmodified:
            return Text("U").foregroundColor(.gray)

        case .ignored:
            return Text("I").foregroundColor(.gray)
        case .untracked:
            return Text("U").foregroundColor(.gray)

        case .deleted:
            return Text("D").foregroundColor(.red)
        case .unreadable:
            return Text("U").foregroundColor(.red)
        case .conflicted:
            return Text("C").foregroundColor(.red)
        }
    }
}

struct ChangedFileView_Previews: PreviewProvider {
    static var previews: some View {
        let models = [
            ChangedFileModel(
                oldFileURL: URL(filePath: "long/long/long/long/long/long/test.txt"),
                newFileURL: URL(filePath: "test.md"),
                changeType: .renamed),
            ChangedFileModel(
                oldFileURL: URL(filePath: "test2.txt"),
                newFileURL: URL(filePath: "test2.txt"),
                changeType: .modified),
            ChangedFileModel(
                oldFileURL: URL(filePath: "test3.txt"),
                newFileURL: nil,
                changeType: .deleted),
            ChangedFileModel(
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
