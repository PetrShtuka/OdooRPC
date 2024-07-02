//
//  ContactSearchParameters.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public struct ContactParameters {
    public var searchName: String = ""
    public var searchEmail: String = ""
    public var idFilter: IDFilterType?
    public var uid: Int
    public var timeZone: String = ""
    public var language: String = ""
    public var limit: Int = 100
    public var serverVersion: Double = 0.0
    public var lastContactId: Int? = nil
    public var customFields: [String]?
    public var additionalParams: [String: Any]?
    public var sessionId: String
    
    public init(searchName: String, searchEmail: String, idFilter: IDFilterType? = nil, uid: Int, timeZone: String, language: String, limit: Int, serverVersion: Double, lastContactId: Int? = nil, customFields: [String]? = nil, additionalParams: [String : Any]? = nil, sessionId: String) {
        self.searchName = searchName
        self.searchEmail = searchEmail
        self.idFilter = idFilter
        self.uid = uid
        self.timeZone = timeZone
        self.language = language
        self.limit = limit
        self.serverVersion = serverVersion
        self.lastContactId = lastContactId
        self.customFields = customFields
        self.additionalParams = additionalParams
        self.sessionId = sessionId
    }
}
