import SwiftUI

enum AdType {
    case banner
    case native
}

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State var adShown: Bool = false
    @State var adType: AdType = .banner
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ScrollView {
                    SettingsSection()
                    InitSection()
                    ShowSection(adShown: $adShown, adType: $adType)
                    AnotherSection()
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                
                AdViewSection(adShown: $adShown, adType: $adType)
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
                            if let nativePlacementId = Settings.nativeLayoutType == .standard ? viewModel.mediator.nativeStandardPlacementId : viewModel.mediator.nativeCompactPlacementId {
                                Text("native: \(nativePlacementId)")
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
    @Binding var adShown: Bool
    @Binding var adType: AdType

    var body: some View {
        VStack {
            HStack {
                if adShown && adType == .banner {
                    Button("Hide Banner") {
                        adType = .banner
                        adShown = false
                    }.buttonStyle(.bordered)
                } else {
                    Button("Show Banner") {
                        adType = .banner
                        adShown = true
                    }.buttonStyle(.bordered)
                        .disabled(viewModel.mediator.bannerPlacementId == nil)
                }
                
                if adShown && adType == .native {
                    Button("Hide Native") {
                        adType = .banner
                        adShown = false
                    }.buttonStyle(.bordered)
                } else {
                    Button("Show Native") {
                        adType = .native
                        adShown = true
                    }.buttonStyle(.bordered)
                        .disabled(Settings.nativeLayoutType == .standard ? viewModel.mediator.nativeStandardPlacementId == nil : viewModel.mediator.nativeCompactPlacementId == nil)
                }
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

struct AdViewSection: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @Binding var adShown: Bool
    @Binding var adType: AdType
    
    var body: some View {
        Divider().frame(height: 2).background(Color.gray).padding(.horizontal)
        VStack {
            if adShown {
                if adType == .banner {
                    AnyView(BannerView())
                } else {
                    AnyView(NativeView())
                }
            } else {
                Text("Ad Placeholder")
            }
        }
        .frame(width: adType == .banner ? Settings.bannerSize.get().width : Settings.nativeLayoutType.size().width,
               height: adType == .banner ? Settings.bannerSize.get().height : Settings.nativeLayoutType.size().height)
        .background(Color.gray)
    }
}

#Preview {
    ContentView().environmentObject(ContentViewModel())
}
