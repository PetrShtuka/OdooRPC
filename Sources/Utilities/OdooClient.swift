//
//  OdooClient.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

class OdooClient {
    private let rpcClient: RPCClient
    
    init(baseURL: URL, authService: AuthService) {
        self.rpcClient = RPCClient(baseURL: baseURL, authService: authService)
    }
    
    var authService: AuthService {
        return AuthService(client: rpcClient)
    }
    
    var messagesService: MessagesServer {
        return MessagesServer(rpcClient: rpcClient)
    }
    
    var userDataService: UserDataService {
        return UserDataService(rpcClient: rpcClient)
    }
    
    var odooService: OdooService {
        return OdooService(rpcClient: rpcClient)
    }
    
    var authenticationServiceTotp: AuthenticationServiceTotp {
        return AuthenticationServiceTotp(rpcClient: rpcClient)
    }
    
    var databaseService: DatabaseService {
        return DatabaseService(rpcClient: rpcClient)
    }
}
