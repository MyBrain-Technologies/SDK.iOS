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
      cSettings: [
          .headerSearchPath("Sources/CPP/signalProcessingSDK/include"),
          .headerSearchPath("Sources/CPP/signalProcessingSDK/include/SignalProcessing/DataManipulation")
      ],
      cxxSettings: [
        .headerSearchPath("Sources/CPP/signalProcessingSDK/include"),
        .headerSearchPath("Sources/CPP/signalProcessingSDK/include/SignalProcessing/DataManipulation")
      ],
      linkerSettings: [
        .linkedLibrary("libNF_Melomind"),
        .linkedLibrary("libSNR"),
        .linkedLibrary("libfftw3"),
        .linkedLibrary("libTransformations"),
        .linkedLibrary("libQualityChecker"),
        .linkedLibrary("libTimeFrequency"),
        .linkedLibrary("libDataManipulation"),
        .linkedLibrary("libPreProcessing"),
        .linkedLibrary("libAlgebra")
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
