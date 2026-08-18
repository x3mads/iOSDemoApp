import Foundation
import UIKit
import XMediator

struct StoredCustomProperty {
    let key: String
    let value: String
    let type: String
}

enum BannerSizeType: String, CaseIterable, Identifiable {
    case phone
    case tablet
    case mrec
    case adaptive

    var id: String { rawValue }
}

enum CMPDebugGeographyOption: Int, CaseIterable, Identifiable {
    case disabled = 0
    case eea = 1
    case notEEA = 2
    case notEEAOther = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .disabled: return "Disabled"
        case .eea: return "EEA"
        case .notEEA: return "Not EEA"
        case .notEEAOther: return "Not EEA (other)"
        }
    }
}

struct Settings {
    static let mediators = [
        Mediator(name: "X3M",
                 appKey: "V148L4C6R1",
                 bannerPlacementId: "V14CYR4VHLR3JH3D",
                 interstitialPlacementId: "V14CYR4ZKLBZYB0A",
                 rewardedPlacementId: "V14CYR4Z2LTF1CFZ"),
        Mediator(name: "MAX",
                 appKey: "V148L42DRG",
                 bannerPlacementId: "V142XB3LRNZCM7",
                 interstitialPlacementId: "V142XBGL601BCD",
                 appOpenPlacementId: "V14JHR48HLHAQ304",
                 rewardedPlacementId: "V142DRKLYD2CVX",
                 nativeStandardPlacementId: "V14CHR2V3LDA0Q4H"),
        Mediator(name: "LevelPlay",
                 appKey: "V148L42DR3",
                 bannerPlacementId: "V142YBZL36TNH7",
                 interstitialPlacementId: "V142YB3L1J9DKT",
                 rewardedPlacementId: "V142YBGLYF22ST",
                 nativeCompactPlacementId: "V14CHR2V2LNGAA5Z",
                 nativeStandardPlacementId: "V14CHR2V2LNGAA5Z"),
        Mediator(name: "AdMob",
                 appKey: "V148L48DB9",
                 bannerPlacementId: "V14JHR4VKLPYKX70",
                 interstitialPlacementId: "V14JHR4V2LCPBMMY",
                 appOpenPlacementId: "V14JHR4VHLG8A741",
                 rewardedPlacementId: "V14JHR4V3L78QZQ2",
                 nativeCompactPlacementId: "V14CHR283LHF2D38",
                 nativeStandardPlacementId: "V14CHR282LMQFCPE"),
        Mediator(name: "Custom",
                 appKey: "<replace>",
                 bannerPlacementId: "<replace_or_nil>",
                 interstitialPlacementId: "<replace_or_nil>",
                 appOpenPlacementId: "<replace_or_nil>",
                 rewardedPlacementId: "<replace_or_nil>",
                 nativeStandardPlacementId: "<replace_or_nil>")
    ]

    private static let appKeyKey = "app_key"
    private static let bannerPlacementIdKey = "banner_placement"
    private static let interstitialPlacementIdKey = "interstitial_placement"
    private static let rewardedPlacementIdKey = "rewarded_placement"
    private static let appOpenPlacementIdKey = "app_open_placement"
    private static let nativeCompactPlacementIdKey = "native_compact_placement"
    private static let nativeStandardPlacementIdKey = "native_standard_placement"
    private static let bannerSizeTypeKey = "banner_size_type"
    private static let bannerAdaptiveMaxWidthKey = "banner_adaptive_max_width"
    private static let nativeLayoutTypeKey = "native_layout_type"
    private static let testModeKey = "test_mode"
    private static let verboseKey = "verbose"
    private static let cmpAutomationKey = "cmp_automation"
    private static let cmpDebugGeographyKey = "cmp_debug_geography"
    private static let customPropertiesKey = "user_custom_properties"

    static var currentMediator: Mediator {
        let defaults = UserDefaults.standard
        guard let appKey = defaults.string(forKey: appKeyKey) else { return mediators.first! }
        return mediators.first { $0.appKey == appKey } ?? Mediator(
            name: "Custom", appKey: appKey,
            bannerPlacementId: optionalValue(defaults.string(forKey: bannerPlacementIdKey)),
            interstitialPlacementId: optionalValue(defaults.string(forKey: interstitialPlacementIdKey)),
            appOpenPlacementId: optionalValue(defaults.string(forKey: appOpenPlacementIdKey)),
            rewardedPlacementId: optionalValue(defaults.string(forKey: rewardedPlacementIdKey)),
            nativeCompactPlacementId: optionalValue(defaults.string(forKey: nativeCompactPlacementIdKey)),
            nativeStandardPlacementId: optionalValue(defaults.string(forKey: nativeStandardPlacementIdKey))
        )
    }

    static var bannerSizeType: BannerSizeType {
        BannerSizeType(rawValue: UserDefaults.standard.string(forKey: bannerSizeTypeKey) ?? "") ?? .phone
    }

    static var bannerSize: Banner.Size {
        switch bannerSizeType {
        case .phone: return .phone
        case .tablet: return .tablet
        case .mrec: return .mrec
        case .adaptive: return .adaptive(maxWidth: adaptiveMaxWidth)
        }
    }

    static var adaptiveMaxWidth: Double? {
        let width = UserDefaults.standard.double(forKey: bannerAdaptiveMaxWidthKey)
        return width > 0 ? width : nil
    }

    static var nativeLayoutType: NativeLayoutType {
        UserDefaults.standard.string(forKey: nativeLayoutTypeKey) == "compact" ? .compact : .standard
    }

    static var testMode: Bool {
        UserDefaults.standard.object(forKey: testModeKey) as? Bool ?? true
    }

    static var verbose: Bool {
        UserDefaults.standard.object(forKey: verboseKey) as? Bool ?? true
    }

    static var cmpAutomation: Bool {
        UserDefaults.standard.object(forKey: cmpAutomationKey) as? Bool ?? false
    }

    static var cmpDebugGeographyValue: Int {
        UserDefaults.standard.object(forKey: cmpDebugGeographyKey) as? Int ?? 0
    }

    static var cmpDebugGeographyOption: CMPDebugGeographyOption {
        CMPDebugGeographyOption(rawValue: UserDefaults.standard.integer(forKey: cmpDebugGeographyKey)) ?? .disabled
    }

    static var cmpDebugGeography: CMPDebugGeography {
        switch cmpDebugGeographyOption {
        case .disabled: return .disabled
        case .eea: return .EEA
        case .notEEA, .notEEAOther: return .other
        }
    }

    static var customProperties: [StoredCustomProperty] {
        guard let values = UserDefaults.standard.stringArray(forKey: customPropertiesKey) else { return [] }
        return values.compactMap { encoded in
            let parts = encoded.split(separator: "|", maxSplits: 2).map(String.init)
            guard parts.count == 3 else { return nil }
            return StoredCustomProperty(key: parts[1], value: parts[2], type: parts[0])
        }
    }

    static func save(mediator: Mediator,
                     customProperties: [StoredCustomProperty],
                     bannerSizeType: BannerSizeType,
                     adaptiveMaxWidth: Double?,
                     nativeLayoutType: NativeLayoutType,
                     testMode: Bool,
                     verbose: Bool,
                     cmpAutomation: Bool,
                     cmpDebugGeography: CMPDebugGeographyOption) {
        let defaults = UserDefaults.standard
        defaults.set(mediator.appKey, forKey: appKeyKey)
        defaults.set(mediator.bannerPlacementId ?? "", forKey: bannerPlacementIdKey)
        defaults.set(mediator.interstitialPlacementId ?? "", forKey: interstitialPlacementIdKey)
        defaults.set(mediator.rewardedPlacementId ?? "", forKey: rewardedPlacementIdKey)
        defaults.set(mediator.appOpenPlacementId ?? "", forKey: appOpenPlacementIdKey)
        defaults.set(mediator.nativeCompactPlacementId ?? "", forKey: nativeCompactPlacementIdKey)
        defaults.set(mediator.nativeStandardPlacementId ?? "", forKey: nativeStandardPlacementIdKey)
        defaults.set(bannerSizeType.rawValue, forKey: bannerSizeTypeKey)
        defaults.set(adaptiveMaxWidth, forKey: bannerAdaptiveMaxWidthKey)
        defaults.set(nativeLayoutType == .compact ? "compact" : "standard", forKey: nativeLayoutTypeKey)
        defaults.set(testMode, forKey: testModeKey)
        defaults.set(verbose, forKey: verboseKey)
        defaults.set(cmpAutomation, forKey: cmpAutomationKey)
        defaults.set(cmpDebugGeography.rawValue, forKey: cmpDebugGeographyKey)
        defaults.set(customProperties.map { "\($0.type)|\($0.key)|\($0.value)" }, forKey: customPropertiesKey)
    }

    static func resetToDefaults() {
        let defaults = UserDefaults.standard
        [appKeyKey, bannerPlacementIdKey, interstitialPlacementIdKey, rewardedPlacementIdKey, appOpenPlacementIdKey, nativeCompactPlacementIdKey, nativeStandardPlacementIdKey, bannerSizeTypeKey, bannerAdaptiveMaxWidthKey, nativeLayoutTypeKey, testModeKey, verboseKey, cmpAutomationKey, cmpDebugGeographyKey, customPropertiesKey].forEach(defaults.removeObject(forKey:))
    }

    private static func optionalValue(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("<replace") else { return nil }
        return trimmed
    }
}

struct Mediator: Hashable {
    let name: String
    let appKey: String
    let bannerPlacementId: String?
    let interstitialPlacementId: String?
    let appOpenPlacementId: String?
    let rewardedPlacementId: String?
    let nativeCompactPlacementId: String?
    let nativeStandardPlacementId: String?

    init(name: String, appKey: String, bannerPlacementId: String? = nil, interstitialPlacementId: String? = nil, appOpenPlacementId: String? = nil, rewardedPlacementId: String? = nil, nativeCompactPlacementId: String? = nil, nativeStandardPlacementId: String? = nil) {
        self.name = name
        self.appKey = appKey
        self.bannerPlacementId = bannerPlacementId
        self.interstitialPlacementId = interstitialPlacementId
        self.appOpenPlacementId = appOpenPlacementId
        self.rewardedPlacementId = rewardedPlacementId
        self.nativeCompactPlacementId = nativeCompactPlacementId
        self.nativeStandardPlacementId = nativeStandardPlacementId
    }
}
