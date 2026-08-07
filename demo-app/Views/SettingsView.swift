import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var appKey = Settings.currentMediator.appKey
    @State private var selectedPreset = Settings.mediators.first(where: { $0.appKey == Settings.currentMediator.appKey })?.name ?? "Custom"
    @State private var bannerPlacementId = Settings.currentMediator.bannerPlacementId ?? ""
    @State private var interstitialPlacementId = Settings.currentMediator.interstitialPlacementId ?? ""
    @State private var rewardedPlacementId = Settings.currentMediator.rewardedPlacementId ?? ""
    @State private var appOpenPlacementId = Settings.currentMediator.appOpenPlacementId ?? ""
    @State private var nativeCompactPlacementId = Settings.currentMediator.nativeCompactPlacementId ?? ""
    @State private var nativeStandardPlacementId = Settings.currentMediator.nativeStandardPlacementId ?? ""
    @State private var bannerSizeType = Settings.bannerSizeType
    @State private var adaptiveMaxWidth = Settings.adaptiveMaxWidth.map { String($0) } ?? ""
    @State private var nativeLayoutType = Settings.nativeLayoutType
    @State private var testMode = Settings.testMode
    @State private var verbose = Settings.verbose
    @State private var cmpAutomation = Settings.cmpAutomation
    @State private var cmpDebugGeography = Settings.cmpDebugGeographyOption
    @State private var customProperties = Settings.customProperties.map { CustomPropertyRow(key: $0.key, value: $0.value, valueType: CustomPropertyType(rawValue: $0.type) ?? .string) }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Card.minimalSpacing) {
                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        SettingsTitle("SDK Configuration")
                        HStack(alignment: .bottom, spacing: 8) {
                            settingsField("App Key", text: $appKey)
                                .onChange(of: appKey) { newValue in
                                    updatePreset(for: newValue)
                                }
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Preset")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Colors.secondaryTitle)
                                Picker("Preset", selection: $selectedPreset) {
                                    Text("Custom").tag("Custom")
                                    ForEach(Settings.mediators, id: \.self) { mediator in
                                        Text(mediator.name).tag(mediator.name)
                                    }
                                }
                                .pickerStyle(.menu)
                                .onChange(of: selectedPreset) { newValue in
                                    guard newValue != "Custom",
                                          let mediator = Settings.mediators.first(where: { $0.name == newValue }) else { return }
                                    load(mediator: mediator)
                                }
                            }
                        }
                        Toggle(isOn: $testMode) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Test mode")
                                Text("Enable test ads")
                                    .font(.system(size: 13))
                                    .foregroundColor(Colors.text)
                            }
                        }
                        Toggle(isOn: $verbose) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Verbose logging")
                                Text("Enable detailed SDK logs")
                                    .font(.system(size: 13))
                                    .foregroundColor(Colors.text)
                            }
                        }
                        Toggle(isOn: $cmpAutomation) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("CMP automation")
                                Text("Auto-show consent form on init")
                                    .font(.system(size: 13))
                                    .foregroundColor(Colors.text)
                            }
                        }
                        HStack {
                            Text("CMP Debug Geography")
                            Spacer(minLength: 0)
                            Picker("CMP Debug Geography", selection: $cmpDebugGeography) {
                                ForEach(CMPDebugGeographyOption.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .tint(Colors.loomitGreen)
                }

                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        SettingsTitle("Placement IDs")
                        settingsField("Banner Placement", text: $bannerPlacementId)
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("Banner size")
                            if bannerSizeType == .adaptive {
                                TextField("Max width", text: $adaptiveMaxWidth)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Spacer(minLength: 0)
                            }
                            Picker("Banner size", selection: $bannerSizeType) {
                                ForEach(BannerSizeType.allCases) { option in
                                    Text(option.rawValue.capitalized).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Colors.loomitGreen)
                        }
                        settingsField("Interstitial Placement", text: $interstitialPlacementId)
                        settingsField("Rewarded Placement", text: $rewardedPlacementId)
                        settingsField("App Open Placement", text: $appOpenPlacementId)
                        settingsField("Native Compact Placement", text: $nativeCompactPlacementId)
                        settingsField("Native Standard Placement", text: $nativeStandardPlacementId)
                        HStack {
                            Text("Native template")
                            Spacer(minLength: 0)
                            Picker("Native template", selection: $nativeLayoutType) {
                                Text("Standard").tag(NativeLayoutType.standard)
                                Text("Compact").tag(NativeLayoutType.compact)
                            }
                            .pickerStyle(.menu)
                            .tint(Colors.loomitGreen)
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        SettingsTitle("User Custom Properties")
                        Text("Add typed properties sent with user data during SDK initialization.")
                            .font(.system(size: 13))
                            .foregroundColor(Colors.text)
                        ForEach(Array($customProperties.enumerated()), id: \.element.id) { index, $property in
                            if index > 0 {
                                Divider().overlay(Colors.loomitOutline)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Value type", selection: $property.valueType) {
                                    ForEach(CustomPropertyType.allCases) { type in
                                        Text(type.rawValue.capitalized).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                                HStack(alignment: .bottom, spacing: 8) {
                                    settingsField("Key", text: $property.key)
                                    settingsField("Value", text: $property.value)
                                        .keyboardType(property.valueType.isNumber ? .numberPad : .default)
                                    Button {
                                        customProperties.removeAll { $0.id == property.id }
                                    } label: {
                                        Image(systemName: "minus.circle")
                                    }
                                    .foregroundColor(Colors.loomitError)
                                }
                            }
                        }
                        TertiaryButton("Add Property") {
                            customProperties.append(CustomPropertyRow())
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.View.paddingHorizontal)
            .padding(.top, Theme.View.paddingTop)
            .padding(.bottom, Theme.View.paddingBottom)
            .frame(maxWidth: .infinity)
        }
        .background(Colors.primaryBackground.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: reset) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .accessibilityLabel("Reset to Defaults")
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 4) {
                PrimaryButton("Save Settings", maxWidth: true, onPress: save)
                Text("Changes require app restart to take effect.")
                    .font(.system(size: 12))
                    .foregroundColor(Colors.text)
            }
            .padding(.horizontal, Theme.View.paddingHorizontal)
            .padding(.vertical, 8)
            .padding(.top, 8)
            .background(Colors.primaryBackground)
        }
    }

    @ViewBuilder
    private func settingsField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Colors.secondaryTitle)
            TextField(title, text: text)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(Colors.textFieldText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func updatePreset(for appKey: String) {
        guard let mediator = Settings.mediators.first(where: { $0.appKey == appKey }) else {
            selectedPreset = "Custom"
            return
        }
        selectedPreset = mediator.name
        bannerPlacementId = mediator.bannerPlacementId ?? ""
        interstitialPlacementId = mediator.interstitialPlacementId ?? ""
        rewardedPlacementId = mediator.rewardedPlacementId ?? ""
        appOpenPlacementId = mediator.appOpenPlacementId ?? ""
        nativeCompactPlacementId = mediator.nativeCompactPlacementId ?? ""
        nativeStandardPlacementId = mediator.nativeStandardPlacementId ?? ""
    }

    private func save() {
        let mediator = Mediator(name: "Custom",
                                appKey: appKey,
                                bannerPlacementId: optional(bannerPlacementId),
                                interstitialPlacementId: optional(interstitialPlacementId),
                                appOpenPlacementId: optional(appOpenPlacementId),
                                rewardedPlacementId: optional(rewardedPlacementId),
                                nativeCompactPlacementId: optional(nativeCompactPlacementId),
                                nativeStandardPlacementId: optional(nativeStandardPlacementId))
        let properties = customProperties.compactMap { property -> StoredCustomProperty? in
            let key = property.key.trimmingCharacters(in: .whitespacesAndNewlines)
            let value = property.value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty, !value.isEmpty else { return nil }
            return StoredCustomProperty(key: key, value: value, type: property.valueType.rawValue)
        }
        Settings.save(mediator: mediator,
                      customProperties: properties,
                      bannerSizeType: bannerSizeType,
                      adaptiveMaxWidth: Double(adaptiveMaxWidth),
                      nativeLayoutType: nativeLayoutType,
                      testMode: testMode,
                      verbose: verbose,
                      cmpAutomation: cmpAutomation,
                      cmpDebugGeography: cmpDebugGeography)
        viewModel.mediator = mediator
        dismiss()
    }

    private func reset() {
        Settings.resetToDefaults()
        load(mediator: Settings.currentMediator)
        bannerSizeType = Settings.bannerSizeType
        adaptiveMaxWidth = ""
        nativeLayoutType = Settings.nativeLayoutType
        customProperties = []
        testMode = Settings.testMode
        verbose = Settings.verbose
        cmpAutomation = Settings.cmpAutomation
        cmpDebugGeography = Settings.cmpDebugGeographyOption
    }

    private func load(mediator: Mediator) {
        selectedPreset = Settings.mediators.first(where: { $0.appKey == mediator.appKey })?.name ?? "Custom"
        appKey = mediator.appKey
        bannerPlacementId = mediator.bannerPlacementId ?? ""
        interstitialPlacementId = mediator.interstitialPlacementId ?? ""
        rewardedPlacementId = mediator.rewardedPlacementId ?? ""
        appOpenPlacementId = mediator.appOpenPlacementId ?? ""
        nativeCompactPlacementId = mediator.nativeCompactPlacementId ?? ""
        nativeStandardPlacementId = mediator.nativeStandardPlacementId ?? ""
        adaptiveMaxWidth = Settings.adaptiveMaxWidth.map { String($0) } ?? ""
    }

    private func optional(_ value: String) -> String? {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

enum CustomPropertyType: String, CaseIterable, Identifiable {
    case string
    case bool
    case int
    case double
    case float

    var id: String { rawValue }
    var isNumber: Bool { self != .string && self != .bool }
}

struct CustomPropertyRow: Identifiable {
    let id = UUID()
    var key: String = ""
    var value: String = ""
    var valueType: CustomPropertyType = .string
}

private struct SettingsTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .foregroundColor(Colors.primaryTitle)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
