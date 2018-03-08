//
//  JSONExtensions.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-01.
//

import Foundation

extension JSON {
    func asString() throws -> String {
        return String.init(bytes: self.makeBody().bytes!)
    }
}
