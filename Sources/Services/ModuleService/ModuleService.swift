//
//  ModuleService.swift
//  OdooRPC
//
//  Created by Peter on 20.04.2024.
//

import Foundation

public class ModuleService {
    private let rpcClient: RPCClient

    init(rpcClient: RPCClient) {
        self.rpcClient = rpcClient
    }

    public func loadModulesServer(completion: @escaping (Result<ModuleStatus, Error>) -> Void) {
        let endpoint = "/web/session/modules"  // Endpoint for fetching modules

        rpcClient.sendRPCRequest(endpoint: endpoint, method: .post, params: [:]) { result in
            switch result {
            case .success(let data):
                do {
                    let moduleNames = try JSONDecoder().decode([String].self, from: data)
                    let moduleStatus = self.createModuleStatus(from: moduleNames)
                    completion(.success(moduleStatus))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func createModuleStatus(from moduleNames: [String]) -> ModuleStatus {
        var moduleStatus = ModuleStatus()
        moduleStatus.mailMessages = moduleNames.contains("prt_mail_messages")
        moduleStatus.mailMessagesPro = moduleNames.contains("prt_mail_messages_pro")
        moduleStatus.cetmixCommunicator = moduleNames.contains("cetmix_communicator")

        return moduleStatus
    }
}
