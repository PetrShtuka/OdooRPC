// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "OdooRPC",
    products: [
        .library(name: "OdooRPC", targets: ["OdooRPC"])
    ],
    targets: [
        .target(name: "OdooRPC", dependencies: [], path: "Sources")
    ]
)
