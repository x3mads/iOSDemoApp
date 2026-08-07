import SwiftUI
import XMediator

struct EventTrackerView: View {
    @State private var amount = ""
    @State private var currency = "USD"
    @State private var sku = ""
    @State private var name = ""
    @State private var isCustomEvent = false
    @State private var appEventName = AppEventName.pageView
    @State private var customEventName = ""
    @State private var properties: [CustomPropertyRow] = []
    @State private var logs: [String] = []

    private let standardEvents: [AppEventName] = [.pageView, .viewItem, .viewItemList, .addToCart, .removeFromCart, .viewCart, .beginCheckout, .purchase, .addPaymentInfo, .wishlistUpdated, .refundRequested, .financialDeposit, .financialWithdraw, .financialTransaction, .submitApplication, .accountOpened, .accountClosed, .gameStart, .gameOver, .levelStart, .levelComplete, .levelFail, .levelQuit, .levelSkip, .levelUp, .virtualResourceTransaction, .energyDepleted, .useProp, .gameShopEnter, .storeItemClick, .achievementUnlocked, .achievementStep, .cutsceneStart, .cutsceneSkip, .firstInteraction, .tutorialStart, .tutorialStep, .tutorialComplete, .tutorialSkip, .appOpen, .signUp, .login, .accountVerificationStart, .accountVerificationComplete, .accountLinked, .search, .generateLead, .productReview, .friendInvite, .socialShare, .socialAccept, .giftTransaction, .groupJoined, .chatSent, .postView, .postCreated, .subscribe, .startTrial, .subscriptionCanceled, .order, .booking, .bookingConfirmed, .bookingCanceled, .onlineCheckIn, .promoCodeApplied, .pushNotificationEnable, .pushNotificationClick, .reEngage, .update, .customerSegment, .locationCoordinates
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Card.minimalSpacing) {
                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        EventTitle("Purchase Event")
                        settingsField("Amount", text: $amount).keyboardType(.decimalPad)
                        settingsField("Currency", text: $currency)
                        settingsField("SKU (optional)", text: $sku)
                        settingsField("Name (optional)", text: $name)
                        PrimaryButton("Track Purchase", maxWidth: true) { trackPurchase() }
                    }
                }
                Card {
                    VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                        EventTitle("App Event")
                        Picker("Event type", selection: $isCustomEvent) {
                            Text("Standard").tag(false)
                            Text("Custom").tag(true)
                        }
                        .pickerStyle(.segmented)
                        if isCustomEvent {
                            settingsField("Event name", text: $customEventName)
                        } else {
                            HStack {
                                Text("Event name")
                                Spacer(minLength: 0)
                                Picker("Event name", selection: $appEventName) {
                                    ForEach(standardEvents, id: \.self) { event in
                                        Text(event.rawValue).tag(event)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                        ForEach(Array($properties.enumerated()), id: \.element.id) { index, $property in
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
                                    Button { properties.removeAll { $0.id == property.id } } label: {
                                        Image(systemName: "minus.circle")
                                    }
                                    .foregroundColor(Colors.loomitError)
                                }
                            }
                        }
                        EventTertiaryButton("Add Property") { properties.append(CustomPropertyRow()) }
                        PrimaryButton("Track App Event", maxWidth: true) { trackAppEvent() }
                    }
                }
                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        EventTitle("Event Log")
                        if logs.isEmpty {
                            Text("No events yet").foregroundColor(Colors.secondaryText)
                        } else {
                            ForEach(Array(logs.enumerated()), id: \.offset) { _, log in
                                Text(log).font(.system(size: 12)).foregroundColor(Colors.text)
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
        .navigationTitle("Event Tracker")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func settingsField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(Colors.secondaryTitle)
            TextField(title, text: text).textFieldStyle(.roundedBorder).foregroundColor(Colors.textFieldText)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func trackPurchase() {
        guard let value = Double(amount), !currency.isEmpty else {
            log("Invalid purchase amount or currency")
            return
        }
        XMediatorAds.eventTracker.track(purchase: PurchaseEvent(amount: value, currency: currency, sku: sku.isEmpty ? nil : sku, name: name.isEmpty ? nil : name))
        log("Purchase tracked")
    }

    private func trackAppEvent() {
        let eventName = isCustomEvent ? customEventName.trimmingCharacters(in: .whitespacesAndNewlines) : appEventName.rawValue
        guard !eventName.isEmpty else {
            log("Event name is required")
            return
        }
        let event = AppEvent.custom(name: eventName, properties: buildProperties())
        XMediatorAds.eventTracker.track(appEvent: event)
        log("App event '\(eventName)' tracked")
    }

    private func buildProperties() -> CustomProperties? {
        var result = CustomProperties()
        properties.forEach { property in
            let key = property.key.trimmingCharacters(in: .whitespacesAndNewlines)
            let value = property.value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { return }
            switch property.valueType {
            case .string: result.addString(key: key, value: value)
            case .bool: if let value = Bool(value) { result.addBool(key: key, value: value) }
            case .int: if let value = Int(value) { result.addInt(key: key, value: value) }
            case .double: if let value = Double(value) { result.addDouble(key: key, value: value) }
            case .float: if let value = Float(value) { result.addDouble(key: key, value: Double(value)) }
            }
        }
        return result.getAll().isEmpty ? nil : result
    }

    private func log(_ message: String) {
        logs.insert(message, at: 0)
        if logs.count > 20 { logs.removeLast() }
    }
}

private struct EventTertiaryButton: View {
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

private struct EventTitle: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).fontWeight(.bold).foregroundColor(Colors.primaryTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
