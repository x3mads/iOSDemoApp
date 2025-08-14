import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State var bannerShown: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ScrollView {
                    SettingsSection()
                    InitSection()
                    ShowSection(bannerShown: $bannerShown)
                    AnotherSection()
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                
                BannerViewSection(bannerShown: $bannerShown)
                Spacer()
            }
        }
    }
}

struct SettingsSection: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var showingPopover = false

    var body: some View {
        VStack {
            Text("Settings").font(.title2)
            HStack {
                HStack {
                    Menu {
                        VStack {
                            Text("app_key: \(viewModel.mediator.appKey)").font(.system(size: 2))
                            if let bannerPlacementId = viewModel.mediator.bannerPlacementId {
                                Text("banner: \(bannerPlacementId)")
                            }
                            if let interstitialPlacementId = viewModel.mediator.interstitialPlacementId {
                                Text("interstitial: \(interstitialPlacementId)")
                            }
                            if let appOpenPlacementId = viewModel.mediator.appOpenPlacementId {
                                Text("app_open: \(appOpenPlacementId)")
                            }
                            if let rewardedPlacementId = viewModel.mediator.rewardedPlacementId {
                                Text("rewarded: \(rewardedPlacementId)")
                            }
                        }
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    Text("Mediator")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                Picker("Mediator", selection: $viewModel.mediator) {
                    ForEach(viewModel.mediators(), id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .disabled(viewModel.initStatus != .idle)
            }
            HStack {
                Text("CMP")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Toggle("", isOn: $viewModel.cmp).labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
            }
            .disabled(viewModel.initStatus != .idle)
            HStack {
                Text("EEA Region")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Toggle("", isOn: $viewModel.eeaRegion).labelsHidden()
                    .disabled(!viewModel.cmp)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
            }
            .disabled(!viewModel.cmp)
            .disabled(viewModel.initStatus != .idle)
        }
        .padding(.bottom)
    }
}

struct InitSection: View {
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Button("Init SDK") { viewModel.start() }.buttonStyle(.bordered)
        }
        .disabled(viewModel.initStatus != .idle)
    }
}

struct ShowSection: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @Binding var bannerShown: Bool

    var body: some View {
        VStack {
            if !bannerShown {
                Button("Show Banner") { bannerShown = true }.buttonStyle(.bordered)
                    .disabled(viewModel.mediator.bannerPlacementId == nil)
            }
            else {
                Button("Hide Banner") { bannerShown = false }.buttonStyle(.bordered)
                    .disabled(viewModel.mediator.bannerPlacementId == nil)
            }
            Button("Show Interstitial") { viewModel.showInterstitial() }.buttonStyle(.bordered)
                .disabled(viewModel.mediator.interstitialPlacementId == nil)
            Button("Show AppOpen") { viewModel.showAppOpen() }.buttonStyle(.bordered)
                .disabled(viewModel.mediator.appOpenPlacementId == nil)
            Button("Show Rewarded") { viewModel.showRewarded() }.buttonStyle(.bordered)
                .disabled(viewModel.mediator.rewardedPlacementId == nil)
        }
        .padding()
        .disabled(viewModel.initStatus != .initialized)
    }
}

struct AnotherSection: View {
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Button("Debugging Suite") { viewModel.openDebuggingSuite() }.buttonStyle(.bordered)
            HStack {
                Button("Open CMP") { viewModel.openCMP() }.buttonStyle(.bordered)
                Button("Reset CMP") { viewModel.resetCMP() }.buttonStyle(.bordered)
            }
            .disabled(!viewModel.cmp)
            .disabled(viewModel.initStatus != .initialized)
        }
    }
}

struct BannerViewSection: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @Binding var bannerShown: Bool
    
    var body: some View {
        Divider().frame(height: 2).background(Color.gray).padding(.horizontal)
        VStack {
            bannerShown ? AnyView(BannerView()) : AnyView(Text("Banner Placeholder"))
        }
        .onDisappear() {
            bannerShown = false
        }
        .frame(width: Settings.bannerSize.get().width,
               height: Settings.bannerSize.get().height)
        .background(Color.gray)
    }
}

#Preview {
    ContentView().environmentObject(ContentViewModel())
}
