import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    @ObservedObject var vm: RepositoryListViewModel
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(vm: _vm)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    @ObservedObject var vm: RepositoryListViewModel
    
    init(vm: ObservedObject<RepositoryListViewModel>) {
        _vm = vm
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // NOTE: https://developer.apple.com/documentation/uikit/view_controllers/providing_access_to_directories
        // TODO: store bookmark for later use
        for url in urls {
            vm.addRepository(fromLocalURL: url)
        }
    }
}
