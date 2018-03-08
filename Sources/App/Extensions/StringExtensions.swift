//
//  StringExtensions.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-01.
//

import Foundation

extension String {
    func asJSON() throws -> JSON {
        return try JSON.init(bytes: self.bytes)
    }
}
