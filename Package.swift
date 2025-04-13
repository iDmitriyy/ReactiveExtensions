// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ReactiveExtensions",
  products: [
    .library(name: "ReactiveExtensions",
             targets: ["ReactiveExtensions"]),
        
    .library(name: "AsyncExtensions", targets: ["AsyncExtensions"]),
    .library(name: "CombineExtensions", targets: ["CombineExtensions"]),
    .library(name: "RxExtensions", targets: ["RxExtensions"]),
  ],
  targets: [
    .target(name: "ReactiveExtensions"),
    .target(name: "AsyncExtensions"),
    .target(name: "CombineExtensions"),
    .target(name: "RxExtensions"),
    
    .testTarget(name: "ReactiveExtensionsTests", dependencies: ["ReactiveExtensions"]),
    .testTarget(name: "AsyncExtensionsTests", dependencies: ["AsyncExtensions"]),
    .testTarget(name: "CombineExtensionsTests", dependencies: ["CombineExtensions"]),
    .testTarget(name: "RxExtensionsTests", dependencies: ["RxExtensions"]),
  ]
)
