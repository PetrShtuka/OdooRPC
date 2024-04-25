//
//  OdooClient.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public class OdooClient {
    private let rpcClient: RPCClient
    
    // Initialize the services as lazy properties to ensure they are only created when needed
    public lazy var authService: AuthService = AuthService(client: rpcClient)
    public lazy var messagesService: MessagesServer = MessagesServer(rpcClient: rpcClient)
    public lazy var userDataService: UserDataService = UserDataService(rpcClient: rpcClient)
    public lazy var odooService: OdooService = OdooService(rpcClient: rpcClient)
    public lazy var authenticationServiceTotp: AuthenticationServiceTotp = AuthenticationServiceTotp(rpcClient: rpcClient)
    public lazy var databaseService: DatabaseService = DatabaseService(rpcClient: rpcClient)

    // The initializer injects the authService dependency into the RPCClient
  
    // Make the initializer public so it can be accessed from outside the module
    public init(baseURL: URL) {
        self.rpcClient = RPCClient(baseURL: baseURL)
    }
}
