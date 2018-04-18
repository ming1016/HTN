// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTNCLI",
//    products: [
//        .executable(name: "htn", targets: ["CLI"])
//    ],
    dependencies: [
        .package(url: "https://github.com/ming1016/HTN", from: "0.1.0"),
//        .package(url: "../../HTN", .branch("master")),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "4.2.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.1.1"),
        .package(url: "https://github.com/kylef/PathKit", from: "0.9.1")
    ],
    targets: [
        .target(name: "HTNCLI", dependencies: ["HTN", "SwiftCLI", "Rainbow", "PathKit"])
    ]
)
