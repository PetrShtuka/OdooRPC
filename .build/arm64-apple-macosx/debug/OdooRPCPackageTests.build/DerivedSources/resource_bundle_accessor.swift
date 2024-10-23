import Foundation

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("OdooRPC_OdooRPCPackageTests.bundle").path
        let buildPath = "/Users/peter/Desktop/New Cetmix project/libary/OdooConnectorSwift/.build/arm64-apple-macosx/debug/OdooRPC_OdooRPCPackageTests.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            // Users can write a function called fatalError themselves, we should be resilient against that.
            Swift.fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}