protocol FeatureFlagProviding {
    var addressInsightsEnabled: Bool { get }
}

struct LocalFeatureFlags: FeatureFlagProviding {
    let addressInsightsEnabled: Bool

    init(addressInsightsEnabled: Bool = true) {
        self.addressInsightsEnabled = addressInsightsEnabled
    }
}
