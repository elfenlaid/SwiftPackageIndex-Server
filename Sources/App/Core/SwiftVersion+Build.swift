extension SwiftVersion {
    static let v5_0: Self = .init(5, 0, 3)
    static let v5_1: Self = .init(5, 1, 5)
    static let v5_2: Self = .init(5, 2, 4)
    static let v5_3: Self = .init(5, 3, 3)
    static let v5_4: Self = .init(5, 4, 0)

    /// Currently supported swift versions for building
    static var allActive: [Self] {
        [v5_0, v5_1, v5_2, v5_3, v5_4]
    }

    var xcodeVersion: String? {
        // Match with https://gitlab.com/finestructure/swiftpackageindex-builder/-/blob/main/Sources/BuilderCore/ArgumentTypes.swift#L36
        // NB: this is used for display purposes and not critical for compiler selection
        switch self {
            case .v5_0:
                return "Xcode 10.3"
            case .v5_1:
                return "Xcode 11.3.1"
            case .v5_2:
                return "Xcode 11.6"
            case .v5_3:
                return "Xcode 12.2"
            case .v5_4:
                return "Xcode 12.5"
            default:
                return nil
        }
    }

    var compatibility: SwiftVersion? {
       for version in SwiftVersion.allActive {
            if self.isCompatible(with: version) { return version }
        }
        return nil
    }
}
