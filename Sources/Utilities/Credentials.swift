//
//  Credentials.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

// Structure to handle the login credentials
public struct Credentials {
    var username: String    // Used as login
    var password: String
    var database: String
}

// Extension to Credentials to make it easier to use with the AuthModule
extension Credentials {
    func asDictionary() -> [String: Any] {
        return [
            "db": self.database,
            "login": self.username,
            "password": self.password
        ]
    }
}
