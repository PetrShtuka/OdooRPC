//
//  OdooError.swift
//  OdooRPC
//
//  Created by Peter on 23.04.2024.
//
import Foundation

// OdooError из библиотеки OdooRPC
enum OdooError: Error {
    case userError(String)
    case accessError(String)
    case validationError(String)
    case internalServerError(String)
    case networkError(String)
    case sessionExpired(String)
    case unknownError(String)
    case noConnection
    case timeout
    case cancelled

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
    
    var localizedDescription: String {
        switch self {
        case .userError(let message):
            return "User Error: \(message)"
        case .accessError(let message):
            return "Access Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .internalServerError(let message):
            return "Internal Server Error: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        case .sessionExpired(let message):
            return "Session Expired: \(message)"
        case .unknownError(let message):
            return "Unknown Error: \(message)"
        case .noConnection:
            return "No Internet Connection"
        case .timeout:
            return "Request Timeout"
        case .cancelled:
            return "Request Cancelled"
        }
    }
}

extension OdooError {
    // Создаем OdooError из NSError
    static func from(_ error: Error) -> OdooError {
        if let odooError = error as? OdooError {
            return odooError
        }
        
        let nsError = error as NSError
        
        // Проверяем, содержит ли NSError информацию о серверной ошибке Odoo
        if nsError.domain == "OdooServerError" {
            let details = nsError.userInfo["odooErrorDetail"] as? String ?? nsError.localizedDescription
            return .internalServerError(details)
        }
        
        // Проверяем сетевые ошибки
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return .noConnection
            case NSURLErrorTimedOut:
                return .timeout
            case NSURLErrorCancelled:
                return .cancelled
            default:
                return .networkError(nsError.localizedDescription)
            }
        }
        
        return .unknownError(nsError.localizedDescription)
    }
}
