//
//  Attachment.swift
//  App
//
//  Created by Daniel Skevarp on 2017-09-27.
//

import Foundation
import Vapor
import FluentProvider


final class Attachment : Model{
    
    var storage: Storage = Storage()
    
    let file : Identifier
    let object : String
    let objectId : Identifier
    let timestamp : Double
    
    init(file _file : Identifier , object _object : String, objectId _objectId : Identifier) {
        file = _file
        object = _object
        objectId = _objectId
        timestamp = Date().timeIntervalSince1970
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("file", file)
        try row.set("object", object)
        try row.set("objectId", objectId)
        try row.set("timestamp", timestamp)
        return row
    }
    
    init(row: Row) throws {
        file = try row.get("file")
        object = try row.get("object")
        objectId = try row.get("objectId")
        timestamp = try row.get("timestamp")
    }
    
    func getAsFile() throws -> File {
        let file = try File.find(self.file)
        return file!
    }
}

extension Attachment : JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("file_id",file)
        try json.set("object",object)
        try json.set("objectId",objectId)
        try json.set("timestamp",timestamp)
        try json.set("file", try getAsFile())
        return json
    }
    
    
}

extension Attachment: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("object")
            builder.int("objectId")
            builder.foreignId(for: File.self, optional: false, unique: false, foreignIdKey: "file", foreignKeyName: "attach_file")
            builder.double("timestamp")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension Attachment : Timestampable {}



