import CoreGraphics

/// 4px base grid — mirrors --space-N CSS tokens
enum ApricotSpacing {
    static let s0: CGFloat = 0
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 20
    static let s6: CGFloat = 24
    static let s8: CGFloat = 32
    static let s10: CGFloat = 40
    static let s12: CGFloat = 48
    static let s16: CGFloat = 64
    static let s20: CGFloat = 80
}

/// mirrors --radius-* CSS tokens
enum ApricotRadius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xl2: CGFloat = 28
    static let full: CGFloat = 999
}
