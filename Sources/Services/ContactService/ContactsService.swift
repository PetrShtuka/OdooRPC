//
//  ContactsService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class ContactsService {
    private let rpcClient: RPCClient

    // Initializer for ContactsService, takes an RPCClient instance
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }

    // Method to load contacts based on the action and search parameters
    public func loadContacts(action: ContactAction, searchParameters: ContactParameters, completion: @escaping (Result<[ContactsModel], Error>) -> Void) {
        let endpoint = (action == .fetch) ? "/web/dataset/call_kw" : "/web/dataset/search_read"
        let parameters = buildParameters(for: action, searchParameters: searchParameters)

        // Send the RPC request to load contacts
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: parameters) { result in
            switch result {
            case .success(let data):
                // Handle the successful response
                self.handleSuccessResponse(data, completion: completion)
            case .failure(let error):
                // Return any errors encountered during the request
                completion(.failure(error))
            }
        }
    }

    // Handle successful response by decoding the data
    private func handleSuccessResponse(_ data: Data, completion: @escaping (Result<[ContactsModel], Error>) -> Void) {
        if let contactsArray = try? decodeArrayResponse(data) {
            // Successfully decoded an array of contacts
            completion(.success(contactsArray))
        } else if let contactsResult = try? decodeObjectResponse(data) {
            // Successfully decoded a single contact object
            completion(.success(contactsResult))
        } else {
            // Handle invalid response format error
            completion(.failure(NSError(domain: "Invalid response format", code: -1, userInfo: nil)))
        }
    }

    // Decode response containing an array of contacts
    private func decodeArrayResponse(_ data: Data) throws -> [ContactsModel] {
        let decodedArrayResponse = try JSONDecoder().decode(RPCArrayResponse<ContactsModel>.self, from: data)
        return decodedArrayResponse.result ?? []
    }

    // Decode response containing a single contact object
    private func decodeObjectResponse(_ data: Data) throws -> [ContactsModel] {
        let decodedObjectResponse = try JSONDecoder().decode(RPCResponse<ContactsResult>.self, from: data)
        return decodedObjectResponse.result?.records ?? []
    }

    // Build parameters for the RPC request based on action and search parameters
    private func buildParameters(for action: ContactAction, searchParameters: ContactParameters) -> [String: Any] {
        var domain: [[Any]] = []

        // Build domain filters based on search parameters
        if let idFilter = searchParameters.idFilter {
            domain.append(idFilter.asDomain())
        }

        if !searchParameters.searchName.isEmpty {
            domain += [["display_name", "ilike", searchParameters.searchName]]
        }

        if !searchParameters.searchEmail.isEmpty {
            domain += [["email", "ilike", searchParameters.searchEmail]]
        }

        // Define fields to retrieve
        let fields = searchParameters.customFields ?? [
            "id",
            "street",
            "street2",
            "mobile",
            "phone",
            "zip",
            "city",
            "country_id",
            "display_name",
            "is_company",
            "parent_id",
            "type",
            "child_ids",
            "comment",
            "email",
            "name",
            "__last_update",
            determineAvatarField(serverVersion: searchParameters.serverVersion)
        ]

        // Prepare kwargs for the RPC request
        var kwargs: [String: Any] = [
            "domain": domain,
            "fields": fields,
            "limit": searchParameters.limit,
            "context": [
                "lang": searchParameters.language,
                "tz": searchParameters.timeZone,
                "uid": searchParameters.uid
            ]
        ]

        // Add any additional parameters if provided
        if let additionalParams = searchParameters.additionalParams {
            for (key, value) in additionalParams {
                kwargs[key] = value
            }
        }

        // Build final parameters for the RPC call
        var parameters: [String: Any] = [
            "model": "res.partner",
            "args": [],
            "kwargs": kwargs
        ]

        // Set method based on action type
        if action == .fetch {
            parameters["method"] = "search_read"
        }

        return parameters
    }

    // Determine the avatar field based on server version
    private func determineAvatarField(serverVersion: Double) -> String {
        return serverVersion >= 15 ? "avatar_128" : "image_small"
    }
}
