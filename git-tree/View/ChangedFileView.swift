import SwiftUI

struct ChangedFileView: View {
    let model: ChangedFileModel
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            changeType
            Text(model.fileURL.relativePath)
            Spacer()
            lines
        }
    }
    
    private var changeType: some View {
        switch model.changeType {
        case .Modified:
            return Text("M").foregroundColor(.orange).bold()
        case .Deleted:
            return Text("D").foregroundColor(.red).bold()
        case .Added:
            return Text("A").foregroundColor(.green).bold()
        case .Renamed:
            return Text("R").foregroundColor(.orange).bold()
        }
    }
    
    private var lines: some View {
        HStack {
            Text("+\(model.linesAdded)").foregroundColor(.green)
            Text("/").foregroundColor(.secondary)
            Text("-\(model.linesDeleted)").foregroundColor(.red)
        }
    }
}

struct ChangedFileView_Previews: PreviewProvider {
    static var previews: some View {
        let model = ChangedFileModel(fileURL: URL(filePath: "test.txt"), changeType: .Modified, linesAdded: 10, linesDeleted: 20)
        ChangedFileView(model: model)
    }
}
