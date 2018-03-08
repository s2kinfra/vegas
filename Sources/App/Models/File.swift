//
//  Photo.swift
//  App
//
//  Created by Daniel Skevarp on 2017-09-20.
//

import Foundation
import Vapor
import FluentProvider

enum fileType : Int {
    
    case image = 1, movie = 2
    
}
final class File : Model {
    
    var storage = Storage()
    var belongsTo : Parent<File, User>  { return parent(id: uploadedBy) }
    var uploadedBy : Identifier
    var name : String = ""
    var path : String = ""
    var absolutePath : String = ""
    var type : fileType = .image
    
    init(){
        uploadedBy = 0
    }
    
    init(row: Row) throws {
        name = try row.get("name")
        path = try row.get("path")
        absolutePath = try row.get("absolutePath")
        uploadedBy = try row.get(User.foreignIdKey)
        if let filetype = fileType.init(rawValue: try row.get("filetype")) { type = filetype } else {
            type = .image
        }
        id = try row.get(idKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.foreignIdKey, uploadedBy)
        try row.set("name", name)
        try row.set("path", path)
        try row.set("absolutePath", absolutePath)
        try row.set("filetype", type.hashValue)
        try row.set("id", id)
        return row
    }
    
    
    init(name _name : String, path _path : String, absolutePath: String, user_id : Identifier, type: fileType) {
        self.name = _name
        self.path = _path
        self.absolutePath = absolutePath
        self.uploadedBy = user_id
        self.type = type
    }
    
}

extension File: Timestampable { }

extension File: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(User.self)
            builder.string("name")
            builder.string("path")
            builder.string("absolutePath")
            builder.int("filetype")
            builder.bool("active", optional: true, unique: false, default: false)
            
        }
        
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

//extension File: Commentable {
//    var objectIdentifier: Identifier {
//        guard let fid = self.id else {
//            return 0
//        }
//        return fid
//    }
//}

extension File: JSONConvertible {
    convenience init(json: JSON) throws {
        
        try self.init(
            name: json.get("name"),
            path: json.get("path"),
            absolutePath: json.get("absolutePath"),
            user_id: json.get("userId"),
            type: json.get("filetype")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("userId", uploadedBy)
        try json.set("path", path)
        try json.set("absolutePath", absolutePath)
        try json.set("filetype", type.rawValue)
//        try json.set("comments", try comments.makeJSON())
        return json
    }
}


extension File: ResponseRepresentable {}

