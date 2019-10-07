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
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/Alamofire/Alamofire", from: "4.9.0"),
    .package(url: "https://github.com/realm/realm-cocoa", from: "3.19.0"),
  ],
  targets: [
    .target(
      name: "MyBrainTechnologiesSDK",
      path: "Sources/Swift"
    ),
    .target(
      name: "CPP",
      path: "Sources/CPP"
    )
  ],
  swiftLanguageVersions: [.v5]
)
