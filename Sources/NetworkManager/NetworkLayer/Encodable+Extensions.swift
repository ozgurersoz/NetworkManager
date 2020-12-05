//
//  Encodable+Extensions.swift
//  NetworkManager
//
//  Created by Özgür Ersöz on 5.12.2020.
//

import Foundation

extension Encodable {
    func encoded() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
