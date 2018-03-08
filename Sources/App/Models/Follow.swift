//
//  Follower.swift
//  App
//
//  Created by Daniel Skevarp on 2017-09-26.
//

import Vapor
import FluentProvider

final class Follow : Model, ObjectIdentifiable{
    var objectIdentifier: Identifier {
        get {
            return self.id!
        }
    }
    
    var storage : Storage = Storage()
    
    var object : String
    var objectId : Identifier
    var follower : Identifier
    var accepted : Bool = false
    
    init(object _object : String , objectId _objectId : Identifier, follower _follower: Identifier, accepted _accepted : Bool = false)
    {
        self.object = _object
        self.objectId = _objectId
        self.follower = _follower
        self.accepted = _accepted
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("object", object)
        try row.set("objectId", objectId)
        try row.set("follower", follower)
        try row.set("accepted", accepted)
        return row
    }
    
    init(row: Row) throws {
        object = try row.get("object")
        objectId = try row.get("objectId")
        follower = try row.get("follower")
        accepted = try row.get("accepted")
    }
    
    func getFollowerUser() throws -> User {
        guard let user = try User.find(follower) else {
            throw Abort.init(.badRequest, reason: "Couldnt find user with id \(self.follower)")
        }
        return user
    }
}

extension Follow: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(object: try json.get("object"),
                  objectId: try json.get("objectId"),
                  follower: try json.get("follower"),
                  accepted: try json.get("accepted")
            
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("object", object)
        try json.set("objectId", objectId)
        try json.set("follower", follower)
        try json.set("accepted", accepted)
        return json
    }
    
}
extension Follow: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("object")
            builder.int("objectId")
            builder.foreignId(for: User.self, optional: false, unique: false, foreignIdKey: "follower", foreignKeyName: "follow_follower")
            builder.bool("accepted")
        }
        
        try database.raw("ALTER TABLE `follows` ADD UNIQUE INDEX `ix_follow` (`object`, `objectId`, `follower`);")
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension Follow : Timestampable {}
