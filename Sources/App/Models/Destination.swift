//
//  Destination.swift
//  App
//
//  Created by Daniel Skevarp on 2018-03-11.
//

import Foundation
import FluentProvider

enum DestinationErrors : Error {
    ///Invalid credentials sent when trying to login
    case Unauthorized,
    ///No credentials or insuffient credentials sent for login
    followDoesntExists,
    ///Follow request exists
    followRequestExists
    
    var errorMessage : String {
        get {
            switch self {
            case .Unauthorized:
                return "Unauthorized"
            default:
                return "Undefined error"
            }
        }
    }
}

final class Destination : Model,ObjectIdentifiable, DataStorage {
    var dataStorage = dataStorageRow()
    var dataStorageACL = dataStorageACLRow()
    var storage: Storage = Storage()
    
    var objectIdentifier: Identifier {
        get {
            return self.id!
        }
    }
    
    init() {
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
        self.setDataLevel(key: "isPrivate", levels: [.row, .json, .guest])
        self.setDataLevel(key: "creator", levels: [.row, .json, .guest])
        self.setDataLevel(key: "startDate", levels: [.row, .json])
        self.setDataLevel(key: "endDate", levels: [.row, .json])
        self.setDataLevel(key: "timestamp", levels: [.row, .json, .guest])
        self.setDataLevel(key: "name", levels: [.row, .json, .guest])
        self.setDataLevel(key: "destinationImage", level: .row)
        self.setDataLevel(key: "trip", levels: [.row,.json])
    }
    
    var destinationImage : Int? {
        set(newValue) {
            self.dataStorage["tripImage"] = newValue
        }
        get{
            return getDataFor(key: "tripImage")
        }
    }
    
    var name : String? {
        set(newValue) {
            self.dataStorage["name"] = newValue
        }
        get{
            return getDataFor(key: "name")
        }
    }
    var isPrivate : Bool? {
        set(newValue) {
            self.dataStorage["isPrivate"] = newValue
        }
        get {
            return getDataFor(key: "isPrivate")
        }
    }
    
    var startDate : Double?{
        set(newValue) {
            self.dataStorage["startDate"] = newValue
        }
        get {
            return getDataFor(key: "startDate")
        }
    }
    var endDate : Double?{
        set(newValue) {
            self.dataStorage["endDate"] = newValue
        }
        get {
            return getDataFor(key: "endDate")
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
    var trip : Int? {
        set(newValue) {
            self.dataStorage["trip"] = newValue
        }
        get{
            return getDataFor(key: "trip")
        }
    }
    
    var places : [String]? //should of course have own type, just for prototyping
    var _creator : User {
        get {
            do{
                return (try User.find(creator))!
            }catch{
                return User()
            }
        }
    }
    var creator : Int? {
        set(newValue) {
            self.dataStorage["creator"] = newValue
        }
        get {
            return getDataFor(key: "creator")
            //            return getDataFor(key: "creator").int
        }
    }
    
    var _destinationImage : File {
        get {
            guard let fileId = self.destinationImage else {
                let workDir = Config.workingDirectory()
                let file = File.init(name: "defaultProfilePicture", path: "/img/profile/default-avatar.png", absolutePath: "\(workDir)public/img/profile/profile.png", user_id: self.id!, type: .image)
                file.id = 0
                return file
            }
            guard let file = try? File.find(fileId)! else {
                let workDir = Config.workingDirectory()
                let file = File.init(name: "defaultProfilePicture", path: "/img/profile/default-avatar.png", absolutePath: "\(workDir)public/img/profile/default-avatar.png", user_id: self.id!, type: .image)
                file.id = 0
                return file
            }
            
            return file
        }
    }
    
    init(startDate _startdate : Double, endDate _enddate : Double, isPrivate _isprivate : Bool, creator _creator : Int, name _name : String) {
        self.isPrivate = _isprivate
        self.startDate = _startdate
        self.endDate = _enddate
        self.creator = _creator
        self.name = _name
        self.timestamp = Date().timeIntervalSince1970
        self.initDatalevels()
    }
    
    func isUserTiedToDestination(user _user : User) -> Bool {
        if _user.id?.int == self.creator {
            return true
        }
        
        for follower in self.followers {
            if follower.id == _user.id {
                return true
            }
        }
        
        return false
    }
    
    func updateDestinationFromJSON(_ json : JSON) throws {
        for (k,v) in json.object! {
            self.dataStorage[k] = v
        }
        
        try self.save()
    }
    
    func acceptFollowRequest(from _from : Identifier,by _by : Identifier) throws {
        ///Right now only the creator can accept follow requests
        if _by == self._creator.id! {
            try self.acceptFollow(follower: _from)
            return
        }
        
        throw TripErrors.Unauthorized
    }
    
    func notifyFollowers(notificationType _type: NotificationType, parameters _params: [NotificationParameter]?) throws {
        
        for follower in self.followers {
            let user = try follower.getFollowerUser()
            let _ = try user.createNotification(notificationType: _type, parameters: _params)
        }
        let _ = try self._creator.createNotification(notificationType: _type, parameters: _params)
    }
    
    func getTripDataForUser(user _user: User) throws -> JSON {
        var json = JSON()
        
        if isUserTiedToDestination(user: _user) {
            return try self.makeJSON()
        }else {
            /// Only data that is allowed from an "outside" perspective
            for data in try getData(level: .json).enumerated() {
                try json.set(data.element.key,data.element.value)
            }
            try json.set("creator", self._creator.makeBasicJSON())
            try json.set("timeline", "")
            try json.set("followers", "")
            try json.set("destinationImage", "")
            try json.set("id",self.id!)
        }
        
        return json
    }
    
    func inviteUser(user _user : User) throws {
        
    }
    
    static func getUsersDestinations(user : User, requester: User) throws -> [Destination] {
        var destinations = [Destination]()
        
        if try user.isUserRelatedTo(user: requester) || user.id! == requester.id! {
            let allDestinations = try Destination.makeQuery().filter("creator", .equals, user.id!).all()
            destinations = allDestinations
        }else {
            let allDestinations = try Destination.makeQuery().filter("creator", .equals, user.id!).filter("isPrivate", .equals, false).all()
            destinations = allDestinations
        }
        
        return destinations
    }
    
    static func createNewDestination(startDate _startdate : Double, endDate _enddate : Double, isPrivate _isprivate : Bool, creator _creator : User, trip _trip : Int?, name _name : String) throws -> Destination {
        
        let destination = Destination.init(startDate: _startdate, endDate: _enddate, isPrivate: _isprivate, creator: _creator.id!.int!, name : _name)
        destination.trip = _trip
        try destination.save()
        return destination
    }
    
    
}


// MARK: Followable
extension Destination : Followable {
    var doesFollowNeedAccept: Bool {
        guard let isPriv = self.isPrivate else {
            return true //default private
        }
        return isPriv
    }
    
    
}

// MARK: Fluent Preparation
extension Destination: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: User.self, optional: false, unique: false, foreignIdKey: "creator", foreignKeyName: "trip_creator")
            builder.string("name")
            builder.double("startDate")
            builder.double("endDate")
            builder.bool("isPrivate")
            builder.int("trip", optional: true, unique: false)
            builder.foreignId(for: File.self, optional: true, unique: false, foreignIdKey: "tripImage", foreignKeyName: "trip_tripimage")
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
extension Destination: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init()
        for (k,v) in json.object! {
            self.dataStorage[k] = v
        }
        self.id = try json.get("id")
    }
    
    func makeJSONForFeed() throws -> JSON {
        var json = JSON()
        for data in try getData(level: .json).enumerated() {
            try json.set(data.element.key,data.element.value)
        }
        try json.set("creator", self._creator.makeBasicJSON())
        var JSONfollowers = [User]()
        for follower in self.followers {
            let user = try follower.getFollowerUser()
            JSONfollowers.append(user)
        }
        try json.set("followers", JSONfollowers)
        try json.set("id",self.id)
        return json
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        for data in try getData(level: .json).enumerated() {
            try json.set(data.element.key,data.element.value)
        }
        try json.set("creator", self._creator.makeBasicJSON())
        try json.set("timeline", try self.getTimelineItemsAsJSON())
        var JSONfollowers = [JSON]()
        for follower in self.followers {
            let user = try follower.getFollowerUser()
            JSONfollowers.append(try user.makeBasicJSON())
        }
        try json.set("followers", JSONfollowers)
        try json.set("tripImage", _destinationImage)
        try json.set("id",self.id!)
        return json
    }
}
extension Destination : Notifiable {
    func createNotification(notificationType _type: NotificationType, parameters _params: [NotificationParameter]?) throws -> Notification
    {
        let notif = Notification.init(receiver: Identifier(self.creator!), notificationType: _type)
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
// MARK : Timelineable
extension Destination : Timelineable {}
extension Destination : Commentable {}
extension Destination : Attachable {}
extension Destination : Envyable {}
extension Destination : Timestampable {}
extension Destination : Parameterizable {}


