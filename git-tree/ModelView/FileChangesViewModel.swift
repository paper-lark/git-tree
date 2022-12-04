import Foundation

class FileChangesViewModel: ObservableObject {
    let changedFile: ChangedFileModel
    let vm: RepositoryViewModel
    
    @Published var changes: [String] = []
    @Published var isLoading = false
    
    init(file: ChangedFileModel, vm: RepositoryViewModel) {
        self.changedFile = file
        self.vm = vm
    }
    
    func loadChanges() {
        isLoading = true
        DispatchQueue.main.async {
            self.changes = self.vm.getChangesFor(fileURL: self.changedFile.fileURL)
            self.isLoading = false
        }
    }
}
