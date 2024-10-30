//
//  Credentials.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

// Structure to handle the login credentials
public struct Credentials {
    public var username: String    // Used as login
    public  var password: String
    public var database: String

    public init(username: String,
                password: String,
                database: String) {
        self.username = username
        self.password = password
        self.database = database
    }
}

// Extension to Credentials to make it easier to use with the AuthModule
extension Credentials {
    public func asDictionary() -> [String: Any] {
        return [
            "db": self.database,
            "login": self.username,
            "password": self.password
        ]
    }
}
