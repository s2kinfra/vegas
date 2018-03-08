//
//  UserExtensions.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-01.
//

import Foundation

import Sessions
import AuthProvider
import BCrypt
import Vapor
import Fluent


// MARK: Notifiable
extension User : Notifiable {
    
}

// MARK: Followable
extension User : Followable {
    var doesFollowNeedAccept: Bool {
        get {
            return self.isPrivate!
        }
    }
    
    var objectIdentifier: Identifier {
        return self.id!
    }
    
    
}

// MARK: JSONConvertible
/** Convert to user from JSON and from JSON to User */
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init()
        for (k,v) in json.object! {
            self.dataStorage[k] = v
        }
        self.id = try json.get("id")
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        for data in try getData(level: .json).enumerated() {
            try json.set(data.element.key,data.element.value)
        }
        try json.set("id", self.id)
        try json.set("followers", self.followers)
        try json.set("following", self.following)
        try json.set("followingRequests", self.followingRequests)
        try json.set("followerRequests", self.followerRequest)
        try json.set("profileImage", self.profileImage)
        return json
    }
    
    func makeBasicJSON() throws -> JSON {
        var json = JSON()
        for data in try getData(level: .json).enumerated() {
            try json.set(data.element.key,data.element.value)
        }
        try json.set("id", self.id!)
        try json.set("profileImage", self.profileImage)
        return json
    }
}

// MARK: HTTP

/// This allows User models to be returned
/// directly in route closures
extension User: ResponseRepresentable { }

struct sessionCacheStruct {
    var user : User
    var timestamp : Double
    
    init( user: User, timestamp: Double){
        self.user = user
        self.timestamp = timestamp
    }
}


// MARK: SessionPersistable
extension User: SessionPersistable {
    
    static var sessionCache = [String : sessionCacheStruct]()
    
    
    public func persist(for req: Request) throws {
        let session = try req.assertSession()
        if session.data["session-entity-id"]?.wrapped != id?.wrapped {
            try req.assertSession().data.set("session-entity-id", id)
            User.sessionCache[String(describing: id!.wrapped.int!)] = sessionCacheStruct(user: self, timestamp: Date().timeIntervalSince1970)
        }
        
    }
    
    public func unpersist(for req: Request) throws {
        let session = try req.assertSession()
        if session.data["session-entity-id"]?.wrapped != id?.wrapped {
            User.sessionCache.removeValue(forKey: String(describing: id!.wrapped.int!))
        }
        try req.assertSession().data.removeKey("session-entity-id")
    }
    
    public static func fetchPersisted(for request: Request) throws -> User? {
        guard let id = try request.assertSession().data["session-entity-id"] else {
            return nil
        }
        
        if let sessionStruct = User.sessionCache[String(describing: id.wrapped.int!)] {
            return sessionStruct.user
        }else {
            guard let user = try User.find(id) else {
                return nil
            }
            
            User.sessionCache[String(describing: user.id!.wrapped.int!)] = sessionCacheStruct(user: user, timestamp: Date().timeIntervalSince1970)
            return user
        }
    }
}


// MARK: Fluent Preparation

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("username", length: 255, optional: false, unique: true)
            builder.string("email", length: 255, optional: false, unique: true)
            builder.bytes("password")
            builder.string("firstname")
            builder.string("lastname")
            builder.int("profilePicture",optional : true, unique: false)
            builder.bool("isPrivate", optional: false, unique: false, default: false)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User : Timelineable {}

// MARK: PasswordAuthentication
extension User: PasswordAuthenticatable {
    
    public static let passwordVerifier: PasswordVerifier? = User.passwordHasher
    public var hashedPassword: String? {
        return _password?.makeString()
    }
    public static let passwordHasher = BCryptHasher(cost: 10)
    
    public static func authenticate(_ creds: Password) throws -> User {
        let user: User
        
        if let verifier = passwordVerifier {
            guard let match = try User
                .makeQuery()
                .or( { orGroup in
                    try orGroup.filter(usernameKey, creds.username)
                    try orGroup.filter("username", creds.username)
                })
                .first()
                else {
                    throw AuthenticationError.invalidCredentials
            }
            
            guard let hash = match.hashedPassword else {
                throw AuthenticationError.invalidCredentials
            }
            
            guard try verifier.verify(
                password: creds.password.makeBytes(),
                matches: hash.makeBytes()
                ) else {
                    throw AuthenticationError.invalidCredentials
            }
            
            user = match
        } else {
            guard let match = try User
                .makeQuery()
                .or({orGroup in
                    try orGroup.filter(usernameKey, creds.username)
                    try orGroup.filter("username", creds.username)
                })
                .filter(passwordKey, creds.password)
                .first()
                else {
                    throw AuthenticationError.invalidCredentials
            }
            
            user = match
        }
        
        return user
    }
    
}

extension User : Timestampable {}
//
extension User : Parameterizable {
    /// the unique key to use as a slug in route building
    public static var uniqueSlug: String {
        return "username"
    }
    
    // returns the found model for the resolved url parameter
    public static func make(for parameter: String) throws -> User {
        guard let found = try User.makeQuery().filter(User.self, .compare("username", .equals, parameter.makeNode(in: nil))).first() else {
            throw Abort(.notFound, reason: "No \(User.self) with that identifier was found.")
        }
        return found
    }
}
//


