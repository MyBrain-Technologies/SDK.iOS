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
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.0")
  ],
  targets: [
    .target(
      name: "CPP",
      path: "Sources/CPP",
      linkerSettings: [
        .linkLibrary("libNF_Melomind"),
        .linkLibrary("libSNR"),
        .linkLibrary("libfftw3"),
        .linkLibrary("libTransformations"),
        .linkLibrary("libQualityChecker"),
        .linkLibrary("libTimeFrequency"),
        .linkLibrary("libDataManipulation"),
        .linkLibrary("libPreProcessing"),
        .linkLibrary("libAlgebra"),
      ]
    ),
    .target(
      name: "MyBrainTechnologiesSDK",
      dependencies: ["Alamofire", "RealmSwift", "SwiftyJSON", "CPP"],
      path: "Sources/Swift"
    )
  ],
  swiftLanguageVersions: [.v5]
)
