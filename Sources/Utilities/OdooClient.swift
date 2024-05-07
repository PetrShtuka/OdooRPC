//
//  OdooClient.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public class OdooClient {
    private var rpcClient: RPCClient
    private lazy var _authService: AuthService = {
        let service = AuthService(client: rpcClient)
        rpcClient.updateSessionService(service)
        return service
    }()
    
    public var authService: AuthService {
        return _authService
    }

    private let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.rpcClient = RPCClient(baseURL: baseURL)
    }
    
    // Остальные сервисы
    public lazy var messagesService: MessagesServer = MessagesServer(rpcClient: rpcClient)
    public lazy var userDataService: UserDataService = UserDataService(rpcClient: rpcClient)
    public lazy var odooService: OdooService = OdooService(rpcClient: rpcClient)
    public lazy var authenticationServiceTotp: AuthenticationServiceTotp = AuthenticationServiceTotp(rpcClient: rpcClient)
    public lazy var databaseService: DatabaseService = DatabaseService(rpcClient: rpcClient)
    public lazy var databaseServiceCetmixCommunicator: CetmixCommunicatorService = CetmixCommunicatorService(rpcClient: rpcClient)
}
