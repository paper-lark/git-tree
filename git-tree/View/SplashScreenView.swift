import SwiftUI

struct SplashScreenView: View {
    @State var isLoaded: Bool = false
    private var vm = RepositoryListViewModel()

    var body: some View {
        if self.isLoaded {
            RepositoryListView(vm: vm)
        } else {
            VStack {
                Image("Git")
                    .overlay(alignment: .bottom) {
                        Text("Loading…")
                            .alignmentGuide(.bottom) { dimension in
                                dimension[.top] - 32
                            }
                    }

            }.onAppear {
                DispatchQueue.main.async {
                    // load repository data
                    vm.loadBookmarks()

                    // proceed to
                    withAnimation {
                        self.isLoaded = true
                    }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
