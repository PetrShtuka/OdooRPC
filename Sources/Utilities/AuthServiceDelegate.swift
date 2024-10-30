//
//  File.swift
//
//
//  Created by Peter on 28.04.2024.
//

import Foundation

public protocol AuthServiceDelegate: AnyObject {
    func requestTwoFactorCode(completion: @escaping (String) -> Void)
}
