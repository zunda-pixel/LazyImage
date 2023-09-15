// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LazyImage",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .watchOS(.v8),
    .tvOS(.v15),
  ],
  products: [
    .library(
      name: "LazyImage",
      targets: ["LazyImage"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/zunda-pixel/AcyncCache", branch: "main"),
  ],
  targets: [
    .target(
      name: "LazyImage",
      dependencies: [
        .product(name: "AsyncCache", package: "AcyncCache"),
      ]
    ),
    .testTarget(
      name: "LazyImageTests",
      dependencies: ["LazyImage"]
    ),
  ]
)
