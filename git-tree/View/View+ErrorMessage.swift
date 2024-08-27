import SwiftUI

extension View {
    func errorMessage(error: Binding<ErrorDescription>) -> some View {
        return self.alert(
            isPresented: error.showError,
            content: {
                Alert(
                    title: Text(error.header.wrappedValue),
                    message: Text(error.description.wrappedValue),
                    dismissButton: .cancel())
            })
    }
}
