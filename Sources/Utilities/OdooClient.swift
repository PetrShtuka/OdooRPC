//
//  OdooClient.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public class OdooClient {
    private let rpcClient: RPCClient
    
    init(baseURL: URL, authService: AuthService) {
        self.rpcClient = RPCClient(baseURL: baseURL, sessionService: authService)
    }
    
    public var authService: AuthService {
        return AuthService(client: rpcClient)
    }
    
    public var messagesService: MessagesServer {
        return MessagesServer(rpcClient: rpcClient)
    }
    
    public var userDataService: UserDataService {
        return UserDataService(rpcClient: rpcClient)
    }
    
    public var odooService: OdooService {
        return OdooService(rpcClient: rpcClient)
    }
    
    public var authenticationServiceTotp: AuthenticationServiceTotp {
        return AuthenticationServiceTotp(rpcClient: rpcClient)
    }
    
    public var databaseService: DatabaseService {
        return DatabaseService(rpcClient: rpcClient)
    }
}
