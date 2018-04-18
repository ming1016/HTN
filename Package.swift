// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTN",
    products: [
        .library(name: "HTN",targets: [ "HTN" ]),
    ],
    dependencies: [],
    targets: [
        .target(name: "HTN", dependencies: [], path: "Sources"),
    ]
)
