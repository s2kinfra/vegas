//
//  UserPayloads.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-01.
//

import Foundation
import Vapor

struct UserPayloadRegister : JSONConvertible {
    var username  : String
    var password : String
    var firstname : String?
    var lastname  : String?
    var email     : String
    var sessionTimeout : Double?
    
    init() {
        username = ""
        password = ""
        firstname = nil
        lastname = nil
        email = ""
        sessionTimeout = 0
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("username", username)
        try json.set("firstname", firstname)
        try json.set("lastname", lastname)
        try json.set("email", email)
        try json.set("password", password)
        try json.set("sessionTimeout", sessionTimeout)
        return json
    }
    
    init(json: JSON) throws {
        do{
            self.sessionTimeout = try json.get("sessionTimeout")
            self.username = try json.get("username")
            self.firstname = try json.get("firstname")
            self.lastname = try json.get("lastname")
            self.email = try json.get("email")
            self.password = try json.get("password")
        }catch {
            throw UserErrors.missingCredentials
        }
    }
    
}

struct PayloadUserUpdateProfileImage  : JSONConvertible{
    
    var profileImage : attachmentPayload
    
    init(profileImage _image : attachmentPayload ) {
        self.profileImage = _image
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("profileImage", profileImage)
        
        return json
    }
    
    init(json: JSON) throws {
        
        guard let profileImage: attachmentPayload = try json.get("profileImage") else {
            throw TriprAPIMessageError.missingData(field: "profileImage")
        }
        self.profileImage = profileImage
    }
}

struct UserPayloadLogin : JSONConvertible {
    var username  : String
    var password : String
    
    init() {
        username = ""
        password = ""
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("username", username)
        try json.set("password", password)
        return json
    }
    
    init(json: JSON) throws {
        do{
            self.username = try json.get("username")
            self.password = try json.get("password")
        }catch {
            throw UserErrors.missingCredentials
        }
    }
    
}

