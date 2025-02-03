import SwiftUI

@main
struct DemoApp: App {
    @StateObject var viewModel = ContentViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
