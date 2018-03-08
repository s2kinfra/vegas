//
//  Envy.swift
//  App
//
//  Created by Daniel Skevarp on 2017-09-21.
//

import Foundation
import Vapor
import FluentProvider

final class Envy : Model{
    var storage: Storage = Storage()
    var enviedBy : Identifier
    var enviedObject : String
    var enviedObjectId : Identifier
    var timestamp : Double
    
    init(enviedBy _user: Identifier, enviedObject _object : String, enviedObjectId _id : Identifier, timestamp _timestamp : Double = Date().timeIntervalSince1970) {
        self.enviedBy = _user
        self.enviedObject = _object
        self.timestamp = _timestamp
        self.enviedObjectId = _id
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", self.id)
        try row.set("enviedBy" , enviedBy)
        try row.set("enviedObject", enviedObject)
        try row.set("enviedObjectId", enviedObjectId)
        try row.set("timestamp", timestamp)
        return row
    }
    
    required init(row: Row) throws {
        enviedBy = try row.get("enviedBy")
        enviedObject = try row.get("enviedObject")
        enviedObjectId = try row.get("enviedObjectId")
        timestamp = try row.get("timestamp")
        id = try row.get("id")
    }
    
    static func getEnviesForObject(Object _object: String, ID _id : Identifier) throws -> [Envy] {
        let envies = try Envy.makeQuery().and( { andGroup in
             try andGroup.filter("enviedObject", .equals, _object)
             try andGroup.filter("enviedObjectId", .equals, _id)
            }).all()
        
        return envies
    }
    
    
    
}

extension Envy: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(enviedBy: try json.get("enviedBy"),
                  enviedObject: try json.get("enviedObject"),
                  enviedObjectId: try json.get("enviedObjectId"),
                  timestamp: try json.get("timestamp"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("enviedBy", enviedBy)
        try json.set("enviedObject", enviedObject)
        try json.set("id", id)
        try json.set("enviedObjectId", enviedObjectId)
        try json.set("timestamp", timestamp)
        return json
    }
}

extension Envy: Timestampable { }

extension Envy: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: User.self, optional: false, unique: false, foreignIdKey: "enviedBy", foreignKeyName: "envy_enviedBy")
            builder.string("enviedObject")
            builder.int("enviedObjectId")
            builder.double("timestamp")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

