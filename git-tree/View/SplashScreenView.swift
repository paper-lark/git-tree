import SwiftUI

struct SplashScreenView: View {
    @State var repositories: [Repository] = []
    @State var isLoaded: Bool = false
    @State var latestError: ErrorDescription = .noError()

    var body: some View {
        VStack {
            if isLoaded && !latestError.showError {
                RepositoryListView(repositories: repositories)
            } else {
                VStack {
                    Image("Git")
                        .overlay(alignment: .bottom) {
                            Text("GitTree")
                                .alignmentGuide(.bottom) { dimension in
                                    dimension[.top] - 32
                                }
                        }
                }
            }
        }.task {
            defer { isLoaded = true }
            do {
                repositories = try await RepositoryQuery().suggestedEntities()
            } catch {
                latestError.showError(
                    header: "Failed to load repositories", description: error.localizedDescription)
            }
        }.errorMessage(error: $latestError)
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
