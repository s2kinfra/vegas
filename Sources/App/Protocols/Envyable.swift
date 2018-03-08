//
//  Envyable.swift
//  App
//
//  Created by Daniel Skevarp on 2017-09-26.
//

import Foundation

import Vapor
import FluentProvider

//TODO: EVENTS

protocol Envyable : ObjectIdentifiable{
    
    var envies : [Envy] {get}
    func addEnvyBy(user _user: User) throws
    func removeEnvyBy(user _user: User) throws
    func removeEnvy(envy : Envy) throws
//    func getCreators()->[Identifier]
//    func createNotification(sender : Identifier) throws
    
}

extension Envyable {
    
    var objectType : String {
        get {
            return String(describing: self)
        }
    }
    
//    func createNotification(sender : Identifier) throws {
//        for creator in getCreators().enumerated(){
//            let notification = Notification.init(relatedObject: objectType, relatedObjectId: objectIdentifier, receiver: creator.element, sender: sender)
//            try notification.save()
//            try notification.send()
//        }
//    }
    var envies: [Envy] {
        get {
            //            TODO: FETCH FROM DATABASE AND RETURN BUT MAYBE SOME CACHE?
            guard let envies = try? Envy.getEnviesForObject(Object: objectType, ID: objectIdentifier) else {
                return [Envy]()
            }
            return envies
        }
    }
    
    func isObjectEnviedBy(user _user: Identifier) throws -> Bool {
        let envies = try Envy.makeQuery().and( { andGroup in
            try andGroup.filter("enviedObject", .equals, objectType)
            try andGroup.filter("enviedObjectId", .equals, objectIdentifier)
            try andGroup.filter("enviedBy", .equals, _user)
        }).all()
        
        if envies.count > 0 {
            return true
        }else {
            return false
        }
    }
    
    func addEnvyBy(user _user: User) throws {
        let envy = Envy.init(enviedBy: _user.id!, enviedObject: objectType, enviedObjectId: objectIdentifier)
        try envy.save()
//        try createNotification(sender: _user.id!)
    }
    
    func removeEnvy(envy : Envy) throws {
        try envy.delete()
    }
    
    func removeEnvyBy(user _user : User) throws {
        guard let envy = try Envy.makeQuery().and({ andGroup in
            try andGroup.filter("enviedObject", .equals, objectType )
            try andGroup.filter("enviedObjectId", .equals, objectIdentifier)
            try andGroup.filter("enviedBy", .equals, _user.id!)
        }).first() else {
            //            TODO: throw instead
            return
        }
        
        try envy.delete()
    }
}

