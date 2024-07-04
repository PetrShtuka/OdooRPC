//
//  ContactsService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class ContactsService {
    private let rpcClient: RPCClient
    
    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }
    
//    public func loadContacts(action: ContactAction, searchParameters: ContactParameters, completion: @escaping (Result<[ContactsModel], Error>) -> Void) {
//        let endpoint = (action == .fetch) ? "/web/dataset/call_kw" : "/web/dataset/search_read"
//        let parameters = buildParameters(for: action, searchParameters: searchParameters)
//        
//        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: parameters) { result in
//            switch result {
//            case .success(let data):
//                do {
//                    // Decode the result array properly
//                    let decodedResult = try JSONDecoder().decode(RPCResponse<[ContactsModel]>.self, from: data)
//                    if let contactsArray = decodedResult.result {
//                        completion(.success(contactsArray))
//                    } else {
//                        completion(.failure(NSError(domain: "No contacts found", code: -1, userInfo: nil)))
//                    }
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    public func loadContacts(action: ContactAction, searchParameters: ContactParameters, completion: @escaping (Result<[ContactsModel], Error>) -> Void) {
        let endpoint = (action == .fetch) ? "/web/dataset/call_kw" : "/web/dataset/search_read"
        let parameters = buildParameters(for: action, searchParameters: searchParameters)
        
        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    // Попытка декодировать как объект с массивом результатов
                    let decodedArrayResponse = try JSONDecoder().decode(RPCArrayResponse<ContactsModel>.self, from: data)
                    if let contactsArray = decodedArrayResponse.result {
                        completion(.success(contactsArray))
                        return
                    }
                } catch {
                    // Игнорируем ошибку и попробуем декодировать как объект с вложенным массивом
                }
                
                do {
                    // Попытка декодировать как объект с вложенным массивом результатов
                    let decodedObjectResponse = try JSONDecoder().decode(RPCResponse<ContactsResult>.self, from: data)
                    if let contactsResult = decodedObjectResponse.result?.records {
                        completion(.success(contactsResult))
                        return
                    }
                } catch {
                    // Если обе попытки декодирования не удались, возвращаем ошибку
                    completion(.failure(error))
                }
                
                // Если ни один из вариантов не удался
                completion(.failure(NSError(domain: "Invalid response format", code: -1, userInfo: nil)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func buildParameters(for action: ContactAction, searchParameters: ContactParameters) -> [String: Any] {
        var domain: [[Any]] = []
        
        if let idFilter = searchParameters.idFilter {
            domain.append(idFilter.asDomain())
        }
        
        if !searchParameters.searchName.isEmpty {
            domain += [["display_name", "ilike", searchParameters.searchName]]
        }
        
        if !searchParameters.searchEmail.isEmpty {
            domain += [["email", "ilike", searchParameters.searchEmail]]
        }
        
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
        
        if let additionalParams = searchParameters.additionalParams {
            for (key, value) in additionalParams {
                kwargs[key] = value
            }
        }
        
        var parameters: [String: Any] = [
            "model": "res.partner",
            "args": [],
            "kwargs": kwargs
        ]
        
        if action == .fetch {
            parameters["method"] = "search_read"
        }
        
        return parameters
    }
    
    private func determineAvatarField(serverVersion: Double) -> String {
        return serverVersion >= 15 ? "avatar_128" : "image_small"
    }
}

struct RPCResponse<ResultType: Decodable>: Decodable {
    let jsonrpc: String
    let id: Int?
    let result: ResultType?
}

struct ContactsResult: Decodable {
    let length: Int
    let records: [ContactsModel]
}

struct RPCArrayResponse<ResultType: Decodable>: Decodable {
    let jsonrpc: String
    let id: Int?
    let result: [ResultType]?
}
