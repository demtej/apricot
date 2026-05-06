protocol FeatureFlagProvider {
    var addressInsightsEnabled: Bool { get }
}

struct LocalFeatureFlags: FeatureFlagProvider {
    let addressInsightsEnabled: Bool

    init(addressInsightsEnabled: Bool = true) {
        self.addressInsightsEnabled = addressInsightsEnabled
    }
}
