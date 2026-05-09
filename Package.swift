// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "K8Switcher",
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .executableTarget(
      name: "K8Switcher",
      linkerSettings: [
        .linkedFramework("AppKit")
      ]
    ),
    .testTarget(
      name: "K8SwitcherTests",
      dependencies: ["K8Switcher"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
