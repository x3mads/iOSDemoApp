import SwiftUI
import XMediator

private enum ConsentValue: String, CaseIterable, Identifiable {
    case notSet
    case trueValue
    case falseValue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .notSet: return "Not set"
        case .trueValue: return "True"
        case .falseValue: return "False"
        }
    }

    init(_ value: Bool?) {
        switch value {
        case .some(true): self = .trueValue
        case .some(false): self = .falseValue
        case .none: self = .notSet
        }
    }

    var boolValue: Bool? {
        switch self {
        case .notSet: return nil
        case .trueValue: return true
        case .falseValue: return false
        }
    }
}

private struct PrivacyTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .foregroundColor(Colors.primaryTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PrivacyAndConsentView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var isFormAvailable = false
    @State private var isCheckingAvailability = false
    @State private var isShowingForm = false
    @State private var hasUserConsent: Bool?
    @State private var doNotSell: Bool?
    @State private var isChildDirected: Bool?
    @State private var logs: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Card.minimalSpacing) {
                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        PrivacyTitle("CMP Provider")
                        Text("Manage user consent for personalized advertising using the Consent Management Platform.")
                            .foregroundColor(Colors.text)
                        Divider().overlay(Colors.loomitOutline)
                        HStack {
                            Text(isCheckingAvailability ? "Checking..." : (isFormAvailable ? "Privacy form available" : "Privacy form not available"))
                            Spacer(minLength: 0)
                            Image(systemName: isFormAvailable ? "checkmark.circle.fill" : "xmark.circle")
                                .foregroundColor(isFormAvailable ? Colors.loomitGreen : Colors.secondaryText)
                        }
                    }
                }

                Card {
                    VStack(spacing: Theme.Card.minimalSpacing) {
                        HStack(spacing: 8) {
                            PrimaryButton("Check", size: 14, maxWidth: true) { checkAvailability() }
                            PrimaryButton("Show Form", size: 14, maxWidth: true) { showForm() }
                                .disabled(!isFormAvailable || isShowingForm)
                        }
                        SecondaryButton("Reset CMP State", size: 14, maxWidth: true) {
                            resetCMP()
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        PrivacyTitle("Consent Information")
                        consentPicker("Has User Consent",
                                      subtitle: "User has given consent for personalized ads",
                                      value: $hasUserConsent)
                        consentPicker("Do Not Sell (CCPA)",
                                      subtitle: "User opted out of data sale",
                                      value: $doNotSell)
                        consentPicker("Child Directed (COPPA)",
                                      subtitle: "App is directed to children",
                                      value: $isChildDirected)
                        HStack(spacing: 8) {
                            SecondaryButton("Get", size: 14, maxWidth: true) {
                                loadConsent()
                            }
                            PrimaryButton("Set", size: 14, maxWidth: true) {
                                saveConsent()
                            }
                        }
                    }
                    .tint(Colors.loomitGreen)
                }

                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        PrivacyTitle("Event Log")
                        if logs.isEmpty {
                            Text("No events yet")
                                .foregroundColor(Colors.secondaryText)
                        } else {
                            ForEach(Array(logs.enumerated()), id: \.offset) { _, log in
                                Text(log)
                                    .font(.system(size: 12))
                                    .foregroundColor(Colors.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
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
        .navigationTitle("Privacy & Consent")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadConsent()
            checkAvailability()
        }
    }

    private func consentPicker(_ title: String,
                               subtitle: String,
                               value: Binding<Bool?>) -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Picker(title, selection: Binding(get: {
                ConsentValue(value.wrappedValue)
            }, set: {
                value.wrappedValue = $0.boolValue
            })) {
                ForEach(ConsentValue.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private func checkAvailability() {
        isCheckingAvailability = true
        log("Checking privacy form availability...")
        isFormAvailable = XMediatorAds.cmpProvider.isPrivacyFormAvailable()
        isCheckingAvailability = false
        log("Privacy form available: \(isFormAvailable)")
    }

    private func showForm() {
        guard let viewController = Utils.getTopViewController() else { return }
        isShowingForm = true
        log("Showing privacy form...")
        XMediatorAds.cmpProvider.presentPrivacyForm(fromViewController: viewController) { error in
            Task { @MainActor in
                isShowingForm = false
                if let error {
                    log("Privacy form error: \(error.localizedDescription)")
                } else {
                    log("Privacy form completed successfully")
                    loadConsent()
                }
            }
        }
    }

    private func resetCMP() {
        XMediatorAds.cmpProvider.reset()
        log("CMP state reset")
        loadConsent()
        checkAvailability()
    }

    private func loadConsent() {
        let information = XMediatorAds.getConsentInformation()
        hasUserConsent = information.hasUserConsent
        doNotSell = information.doNotSell
        isChildDirected = information.isChildDirected
        log("Consent information loaded")
    }

    private func saveConsent() {
        XMediatorAds.setConsentInformation(ConsentInformation(hasUserConsent: hasUserConsent,
                                                              doNotSell: doNotSell,
                                                              isChildDirected: isChildDirected))
        log("Consent information saved")
    }

    private func log(_ message: String) {
        logs.insert(message, at: 0)
        if logs.count > 20 { logs.removeLast() }
    }
}
