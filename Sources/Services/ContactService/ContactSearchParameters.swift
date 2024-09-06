//
//  ContactSearchParameters.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public struct ContactParameters {
    public var searchName: String
    public var searchEmail: String
    public var idFilter: IDFilterType?
    public var uid: Int
    public var timeZone: String
    public var language: String
    public var limit: Int
    public var serverVersion: Double
    public var lastContactId: Int?
    public var customFields: [String]?
    public var additionalParams: [String: Any]?
    public var sessionId: String

    public init(uid: Int, sessionId: String, searchName: String = "", searchEmail: String = "", idFilter: IDFilterType? = nil, timeZone: String = "", language: String = "", limit: Int = 100, serverVersion: Double = 0.0, lastContactId: Int? = nil, customFields: [String]? = nil, additionalParams: [String: Any]? = nil) {
        self.uid = uid
        self.sessionId = sessionId
        self.searchName = searchName
        self.searchEmail = searchEmail
        self.idFilter = idFilter
        self.timeZone = timeZone
        self.language = language
        self.limit = limit
        self.serverVersion = serverVersion
        self.lastContactId = lastContactId
        self.customFields = customFields
        self.additionalParams = additionalParams
    }
}
