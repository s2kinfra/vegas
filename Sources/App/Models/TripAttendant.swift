//
//  TripAttendant.swift
//  App
//
//  Created by Daniel Skevarp on 2018-03-14.
//

import Foundation
import FluentProvider


final class TripAttendant : Model, PivotProtocol {
    static var leftIdKey: String = "trip_id"
    static var rightIdKey: String = "user_id"
    
    
    typealias Left = Trip
    typealias Right = User
    
    var storage: Storage = Storage()
    
    var accepted : Bool
    var user_id : String
    var trip_id : String
    
    
    init(user_id _uid : String, trip_id _tid : String, accepted _acc : Bool) {
        self.accepted = _acc
        self.user_id = _uid
        self.trip_id = _tid
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(idKey, id)
        try row.set(TripAttendant.leftIdKey, trip_id)
        try row.set(TripAttendant.rightIdKey, user_id)
        try row.set("accepted", self.accepted)
        return row
    }
    
    public init(row: Row) throws {
        trip_id = try row.get(TripAttendant.leftIdKey)
        user_id = try row.get(TripAttendant.rightIdKey)
        accepted = try row.get("accepted")
        id = try row.get(self.idKey)
    }
    
    
}

extension TripAttendant: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        let user = try User.find(self.user_id)
        try json.set("user", user?.makeBasicJSON())
        try json.set("accepted", self.accepted)
        return json
    }
    
    convenience init(json: JSON) throws {
        self.init(user_id: try json.get("user_id"),
                  trip_id: try json.get("trip_id"),
                  accepted: try json.get("accepted"))
    }
    
    
}

extension TripAttendant: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: Left.self, foreignIdKey: leftIdKey)
            builder.foreignId(for: Right.self, foreignIdKey: rightIdKey)
            builder.bool("accepted", optional: false, unique: false, default: false)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}



