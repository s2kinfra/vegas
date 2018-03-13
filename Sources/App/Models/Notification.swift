//
//  Notification.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-08.
//

import Foundation
import FluentProvider

enum NotificationType : Int {
    /// FollowTypes
    case TripCreated = 20,
         TripUpdated = 21,
         CommentAdded = 30,
         DestinationAdded = 40,
         DestinationUpdated = 41,
         FollowRequest = 50,
         FollowAccepted = 51
}

final class Notification : Model, DataStorage{
    
    
    var dataStorage = dataStorageRow() 
    var dataStorageACL = dataStorageACLRow()
    var storage : Storage = Storage()
    
    var owner : Parent<Notification, User> {
        return parent(id: Identifier(receiver!))
    }
    
    var objectIdentifier: Identifier {
        get {
            return self.id!
        }
    }
    
    var parameters : [NotificationParameterData] {
        get {
            guard let param = try? NotificationParameterData.makeQuery().filter("notif", .equals, self.id!).all() else {
                return [NotificationParameterData]()
            }
            return param
        }
    }
    
    var receiver : Int? {
        set(newValue) {
            self.dataStorage["receiver"] = newValue
        }
        get {
            return getDataFor(key: "receiver")
        }
    }
    
    var notificationType : Int? {
        set(newValue) {
            self.dataStorage["notificationType"] = newValue
        }
        get {
            return getDataFor(key: "notificationType")
        }
    }
    var timestamp : Double? {
        set(newValue) {
            self.dataStorage["timestamp"] = newValue
        }
        get {
            return getDataFor(key: "timestamp")
        }
    }
    var read : Bool? {
        set(newValue) {
            self.dataStorage["read"] = newValue
        }
        get {
            return getDataFor(key: "read")
        }
    }
    
    init() {  initDatalevels() }
    
    init(receiver _rec : Identifier,
         notificationType _notifType : NotificationType,
         timestamp _stamp : Double = Date().timeIntervalSince1970,
         read _read : Bool = false) {
        
        receiver = _rec.int
        notificationType = _notifType.rawValue
        timestamp = _stamp
        read = _read
        initDatalevels()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        for data in try getData(level: .row).enumerated() {
            try row.set(data.element.key,data.element.value)
        }
        try row.set("id", self.id)
        return row
    }
    
    init(row: Row) throws {
        id = try row.get("id")
        for (k,v) in row.object! {
            self.dataStorage[k] = v
        }
        initDatalevels()
    }
    
    func initDatalevels() {
        setDataLevel(key: "receiver", levels: [.json, .row])
        setDataLevel(key: "notificationType", levels: [.json, .row])
        setDataLevel(key: "timestamp", levels: [.json, .row])
        setDataLevel(key: "read", levels: [.json, .row])
    }
    
    static func createNotification( receiver _rec : Identifier, notificationType _type : NotificationType, parameters _params : [NotificationParameter]? ) throws -> Notification {
        let notif = Notification.init(receiver: _rec, notificationType: _type)
        try notif.save()
        if let notifparams = _params {
            for param in notifparams {
                let parameter = NotificationParameterData.init(notifcation_id: notif.id!,
                                                               parameter: param.paramId,
                                                               relatedObject: param.relatedObject,
                                                               relatedObjectId: param.relatedObjectId)
                try parameter.save()
            }
        }
        return notif
    }
    
}

extension Notification: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init()
        for (k,v) in json.object! {
            self.dataStorage[k] = v
        }
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        for data in try getData(level: .json).enumerated() {
            try json.set(data.element.key,data.element.value)
        }
        try json.set("id", self.id)
        try json.set("parameters", try parameters.makeJSON())
        return json
    }
}

extension Notification: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: User.self, optional: false, unique: false, foreignIdKey: "receiver", foreignKeyName: "notif_receiver")
            builder.int("notificationType")
            builder.double("timestamp")
            builder.bool("read")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension Notification : Parameterizable {}
extension Notification : Timestampable {}


typealias NotificationParameter = (paramId : Int, relatedObject:  String, relatedObjectId: Int)

final class NotificationParameterData : Model {
    var storage : Storage = Storage()
    
    var notif : Identifier
    var parameter : Int
    var relatedObject : String
    var relatedObjectId : Int
    
    var notification : Parent<NotificationParameterData, Notification> {
        return parent(id: notif)
    }
    
    init( notifcation_id _id : Identifier, parameter _parameter : Int, relatedObject _object : String, relatedObjectId _relobjid: Int){
        self.notif = _id
        self.parameter = _parameter
        self.relatedObject = _object
        self.relatedObjectId = _relobjid
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", self.id)
        try row.set("notif", self.notif)
        try row.set("parameter", self.parameter)
        try row.set("relatedObject", self.relatedObject)
        try row.set("relatedObjectId", self.relatedObjectId)
        return row
    }
    
    init(row: Row) throws {
        notif = try row.get("notif")
        parameter = try row.get("parameter")
        relatedObject = try row.get("relatedObject")
        relatedObjectId = try row.get("relatedObjectId")
        id = try row.get("id")
    }
    
}
extension NotificationParameterData: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(notifcation_id: try json.get("notif"),
                  parameter: try json.get("parameter"),
                  relatedObject: try json.get("relatedObject"),
                  relatedObjectId: try json.get("relatedObjectId"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("notif", self.notif)
        try json.set("parameter", self.parameter)
        try json.set("relatedObject", self.relatedObject)
        try json.set("relatedObjectId", self.relatedObjectId)
        
        return json
    }
}

extension NotificationParameterData: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Notification.self, optional: false, unique: false, foreignIdKey: "notif")
            builder.int("parameter")
            builder.string("relatedObject")
            builder.int("relatedObjectId")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
extension NotificationParameterData : Timestampable {}

