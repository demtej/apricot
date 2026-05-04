@testable import Apricot
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@MainActor
class SnapshotTestCase: XCTestCase {
    private static let fixedDeviceConfig = ViewImageConfig(
        safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
        size: CGSize(width: 390, height: 844),
        traits: UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(horizontalSizeClass: .compact),
            UITraitCollection(verticalSizeClass: .regular),
            UITraitCollection(displayScale: 3)
        ])
    )

    static var isRecording: Bool {
        ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"
    }

    func assertScreenSnapshot(
        of view: some View,
        named name: String? = nil,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let rootView = view
            .environment(\.locale, Locale(identifier: "en_US_POSIX"))
            .environment(\.calendar, Calendar(identifier: .gregorian))
            .preferredColorScheme(.light)

        let controller = UIHostingController(rootView: rootView)
        controller.view.backgroundColor = UIColor(Color.apricotBgPage)

        assertSnapshot(
            of: controller,
            as: .image(on: Self.fixedDeviceConfig),
            named: name,
            record: Self.isRecording,
            file: file,
            testName: testName,
            line: line
        )
    }
}
