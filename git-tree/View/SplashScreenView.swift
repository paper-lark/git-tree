import SwiftUI

struct SplashScreenView: View {
    @State var repositories: [Repository] = []
    @State var isLoaded: Bool = false

    var body: some View {
        VStack {
            if isLoaded {
                RepositoryListView(repositories: repositories)
            } else {
                VStack {
                    Image("Git")
                        .overlay(alignment: .bottom) {
                            Text("Loading…")
                                .alignmentGuide(.bottom) { dimension in
                                    dimension[.top] - 32
                                }
                        }

                }
            }
        }.task {
            repositories = try! await RepositoryQuery().suggestedEntities()
            isLoaded = true
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
