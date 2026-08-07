import SwiftUI

@main
struct DemoApp: App {
    @StateObject private var adsStore: AdsStore
    @StateObject private var viewModel: ContentViewModel

    init() {
        let adsStore = AdsStore()
        _adsStore = StateObject(wrappedValue: adsStore)
        _viewModel = StateObject(wrappedValue: ContentViewModel(adsStore: adsStore))
        NavBarStyle.setUp()
        SegmentedControlStyle.setUpSegmentedControl()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(adsStore)
        }
    }
}
