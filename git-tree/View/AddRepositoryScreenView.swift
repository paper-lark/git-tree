import SwiftUI

struct AddRepositoryScreenView: View {
    @ObservedObject var vm: RepositoryListViewModel

    var body: some View {
        DocumentPickerView(addRepository: { url in
            vm.addRepository(fromLocalURL: url)
        })
    }
}

// TODO: implement
//struct AddRepositoryScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddRepositoryScreenView()
//    }
//}
