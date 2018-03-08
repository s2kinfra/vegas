//
//  Followable.swift
//  App
//
//  Created by Daniel Skevarp on 2018-01-21.
//
import Foundation
import Vapor
import FluentProvider

enum FollowableErrors : Error {
    ///Invalid credentials sent when trying to login
    case followExists,
    ///No credentials or insuffient credentials sent for login
    followDoesntExists,
    ///Follow request exists
    followRequestExists
}
protocol Followable : ObjectIdentifiable{
    var followers : [Follow] {get}
    var following : [Follow] {get}
    var doesFollowNeedAccept : Bool {get}
    func startFollowing(by : Identifier) throws
    func stopFollowing(by : Identifier) throws
    func acceptFollow(follower: Identifier) throws
    func declineFollow(follower: Identifier) throws
}


extension Followable {
    
    // returns the found model for the resolved url parameter
    
    var followers : [Follow] {
        get{
            do {
                let follower = try Follow.makeQuery().and { andGroup in
                    try andGroup.filter("object", .equals, self.objectType)
                    try andGroup.filter("objectId", .equals, self.objectIdentifier)
                    try andGroup.filter("accepted", .equals, true)
                    }.all()
                return follower
            }catch {
                return [Follow]()
            }
        }
    }
    
    var following : [Follow] {
        get {
            do {
                let following = try Follow.makeQuery().and { andGroup in
                    try andGroup.filter("follower", .equals, objectIdentifier)
                    try andGroup.filter("accepted", .equals, true)
                    }.all()
                return following
            }catch {
                return [Follow]()
            }
        }
    }
    
    var followingRequests : [Follow] {
        get {
            do {
                let following = try Follow.makeQuery().and { andGroup in
                    try andGroup.filter("object", .equals, objectType)
                    try andGroup.filter("follower", .equals, objectIdentifier)
                    try andGroup.filter("accepted", .equals, false)
                    }.all()
                return following
            }catch {
                return [Follow]()
            }
        }
    }
    
    var followerRequest : [Follow] {
        get {
            do {
                let follower = try Follow.makeQuery().and { andGroup in
                    try andGroup.filter("object", .equals, self.objectType)
                    try andGroup.filter("objectId", .equals, self.objectIdentifier)
                    try andGroup.filter("accepted", .equals, false)
                    }.all()
                return follower
            }catch {
                return [Follow]()
            }
        }
    }
    
    func startFollowing(by : Identifier) throws {
        if followExists(followerId: by) {
            throw FollowableErrors.followExists
        }
        if followRequestExists(followerId: by){
            throw FollowableErrors.followRequestExists
        }
        let follow = Follow.init(object: objectType, objectId: objectIdentifier, follower: by)
        try follow.save()
        if doesFollowNeedAccept == false {
            try self.acceptFollow(follower: by)
        }
    }
    
    func stopFollowing(by : Identifier) throws {
        guard let follow = try Follow.makeQuery().and({ andGroup in
            try andGroup.filter("object", .equals, objectType)
            try andGroup.filter("objectId", .equals, objectIdentifier)
            try andGroup.filter("follower", .equals, by)
            try andGroup.filter("accepted", .equals, true)
        }).first() else {
            //            TODO: throw!
            let error = Abort.init(.badRequest, metadata: by.makeNode(in: nil), reason: "Follow not found")
            throw error
        }
        try follow.delete()
    }
    
    func acceptFollow(follower: Identifier) throws {
        guard let follow = try Follow.makeQuery().and({ andGroup in
            try andGroup.filter("object", .equals, objectType)
            try andGroup.filter("objectId", .equals, objectIdentifier)
            try andGroup.filter("follower", .equals, follower)
            try andGroup.filter("accepted", .equals, false)
        }).first() else {
            //            TODO: throw!
            let error = Abort.init(.badRequest, metadata: follower.makeNode(in: nil), reason: "Follow request not found")
            throw error
        }
        follow.accepted = true
        try follow.save()
        
    }
    
    func declineFollow(follower: Identifier) throws {
        guard let follow = try Follow.makeQuery().and({ andGroup in
            try andGroup.filter("object", .equals, objectType)
            try andGroup.filter("objectId", .equals, objectIdentifier)
            try andGroup.filter("follower", .equals, follower)
            try andGroup.filter("accepted", .equals, false)
        }).first() else {
            //            TODO: throw!
            let error = Abort.init(.badRequest, metadata: follower.makeNode(in: nil), reason: "Follow request not found")
            throw error
        }
        try follow.delete()
    }
    
    private func followRequestExists( followerId : Identifier) -> Bool {
        for follow in self.followerRequest {
            if follow.follower == followerId {
                return true
            }
        }
        
        return false
    }
    private func followExists( followerId : Identifier) -> Bool {
        for follow in self.followers {
            if follow.follower == followerId {
                return true
            }
        }
        
        return false
    }
}


