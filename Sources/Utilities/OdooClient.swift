//
//  OdooClient.swift
//  OdooRPC
//
//  Created by Peter on 13.04.2024.
//

import Foundation

public class OdooClient {
    private var rpcClient: RPCClient
    private var _authService: AuthService

    public var authService: AuthService {
        return _authService
    }

    private let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.rpcClient = RPCClient(baseURL: baseURL)
        self._authService = AuthService(client: rpcClient)
        self.rpcClient.updateSessionService(_authService)
    }

    public lazy var messagesService: MessagesServer = MessagesServer(rpcClient: rpcClient)
    public lazy var userDataService: UserDataService = UserDataService(rpcClient: rpcClient)
    public lazy var odooService: OdooService = OdooService(rpcClient: rpcClient)
    public lazy var authenticationServiceTotp: AuthenticationServiceTotp = AuthenticationServiceTotp(rpcClient: rpcClient)
    public lazy var databaseService: DatabaseService = DatabaseService(rpcClient: rpcClient)
    public lazy var databaseServiceCetmixCommunicator: CetmixCommunicatorService = CetmixCommunicatorService(rpcClient: rpcClient)
    public lazy var moduleServiceOdoo: ModuleService = ModuleService(rpcClient: rpcClient)
    public lazy var contactsService: ContactsService = ContactsService(rpcClient: rpcClient)
    public lazy var attachmentService: AttachmentService = AttachmentService(rpcClient: rpcClient)
    public lazy var mailChannelMessageService: MailChannelMessageService = MailChannelMessageService(rpcClient: rpcClient)
    public lazy var mailChannelService: MailChannelService = MailChannelService(rpcClient: rpcClient)
    public lazy var messageSenderService: MessageSenderService = MessageSenderService(rpcClient: rpcClient)
}
