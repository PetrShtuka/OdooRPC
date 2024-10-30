//
//  OdooError.swift
//  OdooRPC
//
//  Created by Peter on 23.04.2024.
//

import Foundation

enum OdooError: Error {
    case userError(String)
    case accessError(String)
    case validationError(String)
    case internalServerError(String)
    case networkError(String)
    case sessionExpired(String)
    case unknownError(String)

    static func from(json: [String: Any]) -> OdooError {
        guard let error = json["error"] as? [String: Any],
              let data = error["data"] as? [String: Any],
              let name = data["name"] as? String,
              let message = data["message"] as? String else {
            return .unknownError("Invalid error format")
        }

        switch name {
        case "odoo.exceptions.AccessError":
            return .accessError(message)
        case "odoo.exceptions.ValidationError":
            return .validationError(message)
        case "odoo.exceptions.UserError":
            return .userError(message)
        case "odoo.exceptions.InternalError":
            return .internalServerError(message)
        case "odoo.http.SessionExpiredException":
            return .sessionExpired(message)
        default:
            return .unknownError(message)
        }
    }
}
