import SwiftUI

struct SplashScreenView: View {
    @State var isActive: Bool = false

    var body: some View {
        if self.isActive {
            RepositoryListView()
        } else {
            VStack {
                Image("Git")
            }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        self.isActive = true
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
