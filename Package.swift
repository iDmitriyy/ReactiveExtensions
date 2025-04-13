// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ReactiveExtensions",
  platforms: [
    .iOS(.v16),
    .tvOS(.v16),
    .macOS(.v13),
    .watchOS(.v9),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "ReactiveExtensions", targets: ["ReactiveExtensions"]),
        
    .library(name: "AsyncExtensions", targets: ["AsyncExtensions"]),
    .library(name: "CombineExtensions", targets: ["CombineExtensions"]),
    .library(name: "RxExtensions", targets: ["RxExtensions"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-async-algorithms", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/CombineCommunity/RxCombine.git", .upToNextMajor(from: "2.0.1")),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.8.0")),
  ],
  targets: [
    .target(name: "ReactiveExtensions"),
    .target(name: "AsyncExtensions"),
    .target(name: "CombineExtensions"),
    .target(name: "RxExtensions", dependencies: [.product(name: "RxSwift", package: "RxSwift"),
                                                 .product(name: "RxCocoa", package: "RxSwift")]),
    
    .testTarget(name: "ReactiveExtensionsTests", dependencies: ["ReactiveExtensions"]),
    .testTarget(name: "AsyncExtensionsTests", dependencies: ["AsyncExtensions"]),
    .testTarget(name: "CombineExtensionsTests", dependencies: ["CombineExtensions"]),
    .testTarget(name: "RxExtensionsTests", dependencies: ["RxExtensions",
                                                          .product(name: "RxSwift", package: "RxSwift"),
                                                          .product(name: "RxCocoa", package: "RxSwift"),
                                                          .product(name: "RxTest", package: "RxSwift"),
                                                          .product(name: "RxBlocking", package: "RxSwift")]),
  ],
  swiftLanguageModes: [.version("6")]
)

for target: PackageDescription.Target in package.targets {
  {
    var settings: [PackageDescription.SwiftSetting] = $0 ?? []
    settings.append(.enableUpcomingFeature("InternalImportsByDefault"))
    $0 = settings
  }(&target.swiftSettings)
}
