// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "MyBrainTechnologiesSDK",
  platforms: [.iOS(.v9)],
  products: [
    .library(
      name: "MyBrainTechnologiesSDK",
      targets: ["MyBrainTechnologiesSDK"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", from: "4.9.0"),
    .package(url: "https://github.com/realm/realm-cocoa", from: "3.19.0"),
  ],
  targets: [
    .target(
      name: "MyBrainTechnologiesSDK",
      path: "Sources/Swift",
      dependencies: ["Alamofire", "Realm"]
    ),
    .target(
      name: "CPP",
      path: "Sources/CPP"
    )
  ],
  swiftLanguageVersions: [.v5]
)
