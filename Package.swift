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
      cxxSettings: [
        .headerSearchPath("signalProcessingSDK/include/SignalProcessing"),
        .headerSearchPath("signalProcessingSDK/include/MyBrainTechSDK"),
        .headerSearchPath("signalProcessingSDK/include"),
        .headerSearchPath("CPPSignalProcessing/Codebridge"),
        .headerSearchPath("CPPSignalProcessing/SignalProcessing.Cpp")
      ],
      linkerSettings: [
      .linkedLibrary("signalProcessingSDK/lib/libAlgebra.a"),
      .linkedLibrary("signalProcessingSDK/lib/libDataManipulation.a"),
      .linkedLibrary("signalProcessingSDK/lib/libfftw3.a"),
      .linkedLibrary("signalProcessingSDK/lib/libNF_Melomind.a"),
      .linkedLibrary("signalProcessingSDK/lib/libPreProcessing.a"),
      .linkedLibrary("signalProcessingSDK/lib/libQualityChecker.a"),
      .linkedLibrary("signalProcessingSDK/lib/libSNR.a"),
      .linkedLibrary("signalProcessingSDK/lib/libTimeFrequency.a"),
      .linkedLibrary("signalProcessingSDK/lib/libTransformations.a")
//        .unsafeFlags(["-LsignalProcessingSDK/lib"])
      ]
    ),
    .target(
      name: "MyBrainTechnologiesSDK",
      dependencies: ["Alamofire", "RealmSwift", "SwiftyJSON", "CPP"],
      path: "Sources/Swift"
    )
  ],
  swiftLanguageVersions: [.v5],
  cxxLanguageStandard: .gnucxx11
)
