//
//  Feed.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-04.
//

import Foundation
import Vapor
import FluentProvider
import AuthProvider

enum FeedType : Int {
    case followAccepted = 1,
    followDeclined = 2,
    followRequest = 3,
    tripCreated = 10,
    tripFollowed = 11,
    tripUpdated = 12,
    commentAdded = 20,
    photoAdded = 30,
    unknown = 9999
}

final class Feed : Model,DataStorage {
   
    var storage = Storage()
    var dataStorage = dataStorageRow()
    var dataStorageACL = dataStorageACLRow()
    
    
    func getFullFeedDataAsJSON( ) throws -> JSON {
        var json = JSON()
        
        try json.set("feedType", self.feedType!.rawValue)
        try json.set("id", self.id)
        try json.set("timestamp", self.timestamp)
        
        
        switch self.entryObjectType! {
        case "App.Trip" :
            var subObject = JSON()
            let trip = try Trip.find(self.entryObjectId!)
            try subObject.set("trip", try trip?.makeJSONForFeed())
            try json.set("entryObject", subObject)
            
        case "App.User" :
            var subObject = JSON()
            let user = try User.find(self.entryObjectId!)
            try subObject.set("user", try user?.makeBasicJSON())
            try json.set("entryObject", subObject)
            
        default:
            print("entry object : \(self.entryObjectType!) hasnt been mapped")
            abort()
        }
        
        switch self.feedObjectType! {
        case "App.Comment":
            var subObject = JSON()
            let comment = try Comment.find(self.feedObjectId!)
            try subObject.set("comment", comment)
            try json.set("feedObject", subObject)
            
        case "App.Trip" :
            var subObject = JSON()
            let trip = try Trip.find(self.feedObjectId!)
            try subObject.set("trip", trip)
            try json.set("feedObject", subObject)
        default:
            print("feed object : \(self.feedObjectType!) hasnt been mapped")
            abort()
        }
        
        
        return json
    }
    var feedObjectType : String?{
        set(newValue) {
            self.dataStorage["feedObjectType"] = newValue
        }
        get {
            return getDataFor(key: "feedObjectType")
        }
    }
    var feedObjectId : Int?{
        set(newValue) {
            self.dataStorage["feedObjectId"] = newValue
        }
        get {
            return getDataFor(key: "feedObjectId")
        }
    }
    var entryObjectType : String?{
        set(newValue) {
            self.dataStorage["entryObjectType"] = newValue
        }
        get {
            return getDataFor(key: "entryObjectType")
        }
    }
    var entryObjectId : Int?{
        set(newValue) {
            self.dataStorage["entryObjectId"] = newValue
        }
        get {
            return getDataFor(key: "entryObjectId")
        }
    }
    var timestamp : Double?{
        set(newValue) {
            self.dataStorage["timestamp"] = newValue
        }
        get {
            return getDataFor(key: "timestamp")
        }
    }
    
    var feedType : FeedType? {
        set(newValue) {
            self.dataStorage["feedType"] = newValue?.rawValue
        }
        get {
            guard let ft = FeedType.init(rawValue: getDataFor(key: "feedType")!) else {
                return .unknown
            }
            return ft
        }
    }
    
    init() {}
    
    init(entryObjectType _entryObject : String, entryObjectId _entryObjectId: Identifier, feedObjectType _feedObjectType : String, feedObjectId _feedObjectId : Identifier, timestamp _time : Double = Date().timeIntervalSince1970, feedType _type : FeedType) {
        
        self.entryObjectType = _entryObject
        self.entryObjectId = _entryObjectId.int
        self.feedObjectType = _feedObjectType
        self.feedObjectId = _feedObjectId.int
        self.timestamp = _time
        self.feedType = _type
        self.initDatalevels()
    }
    
    func initDatalevels() {
        self.setDataLevel(key: "entryObjectType", levels: [.row , .json])
        self.setDataLevel(key: "entryObjectId", levels: [.row , .json])
        self.setDataLevel(key: "feedObjectType", levels: [.row , .json])
        self.setDataLevel(key: "feedObjectId", levels: [.row , .json])
        self.setDataLevel(key: "timestamp", levels: [.row , .json])
        self.setDataLevel(key: "feedType", levels: [.row, .json])
    }
    
//
//    func setDataLevel(key: String, level: DataACL) {
//        guard dataStorageACL[key] != nil else {
//            dataStorageACL[key] = [level]
//            return
//        }
//        dataStorageACL[key]?.append(level)
//    }
//
//    func setDataLevel(key: String, levels: [DataACL]) {
//        for level in levels {
//            if let dl = dataStorageACL[key] {
//                if !dl.contains(level){
//                    dataStorageACL[key]?.append(level)
//                }
//            }else{
//                dataStorageACL[key] = [level]
//            }
//        }
//    }
    
    
    
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
    
}


// MARK: Fluent Preparation

extension Feed: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("entryObjectType")
            builder.int("entryObjectId")
            builder.string("feedObjectType")
            builder.int("feedObjectId")
            builder.int("feedType")
            builder.double("timestamp")
            
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSONConvertible
/** Convert to user from JSON and from JSON to User */
extension Feed: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init()
        for (k,v) in json.object! {
            self.dataStorage[k] = v
        }
    }
    
    func makeJSON() throws -> JSON {
//        var json = JSON()
//        for data in try getData(level: .json).enumerated() {
//            try json.set(data.element.key,data.element.value)
//        }
//        try json.set("id",self.id)
//        return json
       
        return try self.getFullFeedDataAsJSON()
    }
}

extension Feed : Timestampable {}
extension Feed : Parameterizable {}
