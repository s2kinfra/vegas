//
//  ObjectIdentifiable.swift
//  App
//
//  Created by Daniel Skevarp on 2017-09-26.
//

import Foundation

typealias ObjectIdentifiableObject = (String, Identifier)

protocol ObjectIdentifiable {
    var objectType : String { get }
    var objectIdentifier : Identifier { get }
    var objectKey : String { get }
    static var objectType : String { get }
}

extension ObjectIdentifiable {
    
    var objectKey : String {
        get {
            return "\(self.objectType)\(self.objectIdentifier.int!)"
        }
    }
    static var objectType : String {
        get {
            return "App.\(String(describing: self))"
        }
    }
    var objectType : String {
        get {
            return String(describing: self)
        }
    }
}
