//
//  FeedKeys.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-05.
//

import Foundation
import FluentProvider

final class FeedKeys : Model {
    var storage: Storage = Storage()
    
    var objectKey : String
    var feedId : Identifier
    
    init(objectKey _objkey : String, feedId _feedId: Identifier) {
        self.objectKey = _objkey
        self.feedId = _feedId
    }
    
    init(row: Row) throws {
        self.objectKey = try row.get("objectKey")
        self.feedId = try row.get("feedId")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("objectKey", self.objectKey)
        try row.set("feedId", self.feedId)
        return row
    }
    
}


extension FeedKeys: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("objectKey")
            builder.int("feedId")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


