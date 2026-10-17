// swift-tools-version:5.7
// livr-swift-validator ships only an Xcode project/CocoaPods spec, so its
// sources (cloned by container.sh) are compiled here as a plain SwiftPM target.
import PackageDescription

let package = Package(
    name: "LivrConformance",
    targets: [
        .target(
            name: "Livr",
            path: "livr-swift-validator/Livr",
            exclude: ["Info.plist", "Livr.h"],
            // In Xcode, Foundation reaches these files through the framework's
            // umbrella header; SwiftPM needs it imported explicitly.
            swiftSettings: [.unsafeFlags(["-Xfrontend", "-import-module", "-Xfrontend", "Foundation"])]
        ),
        .executableTarget(
            name: "Harness",
            dependencies: ["Livr"],
            path: "Sources/Harness"
        ),
    ],
    // The library declares SWIFT_VERSION = 4.2 (Swift 5 changed `try?` semantics).
    swiftLanguageVersions: [.v4_2]
)
