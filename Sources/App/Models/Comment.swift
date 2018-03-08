//
//  Comment.swift
//  App
//
//  Created by Daniel Skevarp on 2017-09-27.
//

import Foundation
import Vapor
import FluentProvider



final class Comment : Model , Attachable, Envyable{
    
    
    var objectIdentifier: Identifier {
        get {
            return id!
        }
    }
    
    var storage: Storage = Storage()
    var text : String
    var writtenBy : Identifier
    var timestamp : Double
    var commentedObject : String
    var commentedObjectId: Identifier
    
    func getCreators() -> [Identifier] {
        var creators = [Identifier]()
        creators.append(self.id!)
        return creators
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("text", text)
        try row.set("writtenBy", writtenBy)
        try row.set("timestamp", timestamp)
        try row.set("commentedObject", commentedObject)
        try row.set("commentedObjectId", commentedObjectId)
        return row
    }
    
    init(row: Row) throws {
        text = try row.get("text")
        writtenBy = try row.get("writtenBy")
        timestamp = try row.get("timestamp")
        commentedObject = try row.get("commentedObject")
        commentedObjectId = try row.get("commentedObjectId")
        id = try row.get("id")
    }
    
    init(text _text: String, writtenBy _user: Identifier, commentedObject _object : String, commentedObjectId _objectId : Identifier, timestamp _timestamp : Double = Date().timeIntervalSince1970)
    {
        self.commentedObjectId = _objectId
        self.commentedObject = _object
        self.text = _text
        self.writtenBy = _user
        self.timestamp = _timestamp
    }
}

extension Comment: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(text: try json.get("text"),
                  writtenBy: try json.get("writtenBy"),
                  commentedObject: try json.get("commentedObject"),
                  commentedObjectId: try json.get("commentedObjectId"),
                  timestamp: try json.get("timestamp"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        let writer = try User.find(writtenBy)
        
        try json.set("text", text)
        try json.set("writtenBy", writer?.makeBasicJSON())
        try json.set("id", id!)
        try json.set("commentedObject", commentedObject)
        try json.set("commentedObjectId", commentedObjectId)
        try json.set("timestamp", timestamp)
        try json.set("attachments", try self.attachments.makeJSON())
        return json
    }
}


extension Comment: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("commentedObject")
            builder.int("commentedObjectId")
            builder.string("text")
            builder.foreignId(for: User.self, optional: false, unique: false, foreignIdKey: "writtenBy", foreignKeyName: "comment_writtenBy")
            builder.double("timestamp")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Comment : Timestampable {}

