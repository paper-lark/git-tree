import SwiftUI

struct DocumentPickerView: UIViewControllerRepresentable {
    let addRepository: (URL) -> Void

    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(addRepository: addRepository)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIDocumentPickerViewController(
            forOpeningContentTypes: [.folder], asCopy: false)
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = false

        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate
{
    private let addRepository: (URL) -> Void

    init(addRepository: @escaping (URL) -> Void) {
        self.addRepository = addRepository
    }

    func documentPicker(
        _ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]
    ) {
        for url in urls {
            addRepository(url)
        }
    }
}
