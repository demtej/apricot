import Foundation

extension String {
    /// Shortens the string to `maxLength` characters, keeping the start and end
    /// and replacing the middle with "…". If the string already fits, it's returned unchanged.
    /// For odd `maxLength`, the leading portion gets the extra character.
    func abbreviated(to maxLength: Int) -> String {
        guard count > maxLength, maxLength > 1 else { return self }

        let tailLength = maxLength / 2
        let headLength = maxLength - tailLength

        return "\(prefix(headLength))…\(suffix(tailLength))"
    }
}
