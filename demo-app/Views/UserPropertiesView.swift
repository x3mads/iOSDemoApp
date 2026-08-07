import SwiftUI
import XMediator

private struct UserTertiaryButton: View {
    let text: String
    let action: () -> Void

    init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Colors.primaryTitle)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Colors.tertiaryBackground)
                .overlay(Capsule().stroke(Colors.primaryTitle.opacity(0.6), lineWidth: 1))
                .clipShape(Capsule())
        }
    }
}

private struct UserPropertiesTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .foregroundColor(Colors.primaryTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct UserPropertiesView: View {
    @State private var userId = ""
    @State private var installDate = ""
    @State private var totalAmountSpent = ""
    @State private var currencyCode = ""
    @State private var numberOfPurchases = ""
    @State private var customProperties: [CustomPropertyRow] = []
    @State private var logs: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Card.minimalSpacing) {
                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        UserPropertiesTitle(text: "User Properties")
                        Text("Set user properties for ad targeting and analytics.")
                            .foregroundColor(Colors.text)
                        settingsField("User ID", text: $userId)
                        HStack(spacing: 8) {
                            SecondaryButton("Get", size: 14, maxWidth: true) { loadUserId() }
                            PrimaryButton("Set", size: 14, maxWidth: true) { saveUserId() }
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        UserPropertiesTitle(text: "Install Date")
                        settingsField("ISO 8601 date", text: $installDate)
                        Text("Leave empty to clear the install date.")
                            .font(.system(size: 12))
                            .foregroundColor(Colors.secondaryText)
                        HStack(spacing: 8) {
                            SecondaryButton("Get", size: 14, maxWidth: true) { loadInstallDate() }
                            PrimaryButton("Set", size: 14, maxWidth: true) { saveInstallDate() }
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        UserPropertiesTitle(text: "Purchase Summary")
                        settingsField("Total amount spent", text: $totalAmountSpent)
                            .keyboardType(.decimalPad)
                        settingsField("Currency code", text: $currencyCode)
                        settingsField("Number of purchases", text: $numberOfPurchases)
                            .keyboardType(.numberPad)
                        HStack(spacing: 8) {
                            SecondaryButton("Get", size: 14, maxWidth: true) { loadPurchaseInfo() }
                            PrimaryButton("Set", size: 14, maxWidth: true) { savePurchaseInfo() }
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        UserPropertiesTitle(text: "Custom Properties")
                        Text("Add typed properties for user targeting and analytics.")
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
                        UserTertiaryButton("Add Property") {
                            customProperties.append(CustomPropertyRow())
                        }
                        HStack(spacing: 8) {
                            SecondaryButton("Get", size: 14, maxWidth: true) { loadCustomProperties() }
                            PrimaryButton("Set", size: 14, maxWidth: true) { saveCustomProperties() }
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        UserPropertiesTitle(text: "Event Log")
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
        .navigationTitle("User Properties")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadProperties()
        }
    }

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

    private func loadUserId() {
        userId = XMediatorAds.getUserProperties().userId ?? ""
        log("User ID loaded")
    }

    private func saveUserId() {
        var properties = XMediatorAds.getUserProperties()
        properties.userId = userId.isEmpty ? nil : userId
        XMediatorAds.setUserProperties(properties)
        log("User ID saved")
        loadUserId()
    }

    private func loadInstallDate() {
        installDate = XMediatorAds.getUserProperties().installDate.map { ISO8601DateFormatter().string(from: $0) } ?? ""
        log("Install date loaded")
    }

    private func saveInstallDate() {
        let current = XMediatorAds.getUserProperties()
        XMediatorAds.setUserProperties(UserProperties(userId: current.userId,
                                                      installDate: ISO8601DateFormatter().date(from: installDate),
                                                      purchaseSummary: current.purchaseSummary,
                                                      customProperties: current.customProperties))
        log("Install date saved")
        loadInstallDate()
    }

    private func loadPurchaseInfo() {
        let properties = XMediatorAds.getUserProperties()
        totalAmountSpent = properties.purchaseSummary?.totalAmountSpent.map { String($0) } ?? ""
        currencyCode = properties.purchaseSummary?.currencyCode ?? ""
        numberOfPurchases = properties.purchaseSummary?.numberOfPurchases.map { String($0) } ?? ""
        loadCustomProperties(properties.customProperties.getAll())
        log("Purchase summary loaded")
    }

    private func savePurchaseInfo() {
        saveProperties()
    }

    private func loadCustomProperties(_ values: [String: AnyHashable]) {
        customProperties = values.compactMap { key, value in
            switch value {
            case let value as Bool:
                return CustomPropertyRow(key: key, value: String(value), valueType: .bool)
            case let value as Int:
                return CustomPropertyRow(key: key, value: String(value), valueType: .int)
            case let value as Double:
                return CustomPropertyRow(key: key, value: String(value), valueType: .double)
            case let value as String:
                return CustomPropertyRow(key: key, value: value, valueType: .string)
            default:
                return nil
            }
        }
    }

    private func loadCustomProperties() {
        loadCustomProperties(XMediatorAds.getUserProperties().customProperties.getAll())
        log("Custom properties loaded")
    }

    private func saveCustomProperties() {
        let current = XMediatorAds.getUserProperties()
        var properties = CustomProperties()
        customProperties.forEach { property in
            let key = property.key.trimmingCharacters(in: .whitespacesAndNewlines)
            let value = property.value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { return }
            switch property.valueType {
            case .string: properties.addString(key: key, value: value)
            case .bool: if let value = Bool(value) { properties.addBool(key: key, value: value) }
            case .int: if let value = Int(value) { properties.addInt(key: key, value: value) }
            case .double: if let value = Double(value) { properties.addDouble(key: key, value: value) }
            case .float: if let value = Float(value) { properties.addDouble(key: key, value: Double(value)) }
            }
        }
        XMediatorAds.setUserProperties(UserProperties(userId: current.userId,
                                                      installDate: current.installDate,
                                                      purchaseSummary: current.purchaseSummary,
                                                      customProperties: properties))
        log("Custom properties saved")
        loadCustomProperties(XMediatorAds.getUserProperties().customProperties.getAll())
    }

    private func loadProperties() {
        let properties = XMediatorAds.getUserProperties()
        userId = properties.userId ?? ""
        installDate = properties.installDate.map { ISO8601DateFormatter().string(from: $0) } ?? ""
        totalAmountSpent = properties.purchaseSummary?.totalAmountSpent.map { String($0) } ?? ""
        currencyCode = properties.purchaseSummary?.currencyCode ?? ""
        numberOfPurchases = properties.purchaseSummary?.numberOfPurchases.map { String($0) } ?? ""
        loadCustomProperties(properties.customProperties.getAll())
        log("User properties loaded")
    }

    private func saveProperties() {
        let current = XMediatorAds.getUserProperties()
        XMediatorAds.setUserProperties(UserProperties(userId: current.userId,
                                                      installDate: current.installDate,
                                                      purchaseSummary: InAppPurchaseSummary(totalAmountSpent: Double(totalAmountSpent),
                                                                                            currencyCode: currencyCode.isEmpty ? nil : currencyCode,
                                                                                            numberOfPurchases: Int(numberOfPurchases)),
                                                      customProperties: current.customProperties))
        log("Purchase summary saved")
        loadPurchaseInfo()
    }

    private func log(_ message: String) {
        logs.insert(message, at: 0)
        if logs.count > 20 { logs.removeLast() }
    }
}
