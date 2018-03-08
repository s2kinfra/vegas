//
//  TriprMessage+JSONConvertiable.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-01.
//

import Foundation

/**
 Extension for TriprAPIMessage classes to confirm to JSONConvertiable protocol
 */

/// triprAPIResponseStatusMessageData to and from json
extension triprAPIResponseStatusMessageData : JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("code", code.rawValue)
        try json.set("text", text)
        return json
    }
    
    init(json: JSON) throws {
        self.init(code: responseStatusCode(rawValue : try json.get("code"))!, text: try json.get("text"))
    }
    
}

/// Response message to and from JSON
extension triprAPIResponseMessage : JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("messageId", messageId)
        try json.set("timestamp", timestamp)
        try json.set("payload", payload)
        try json.set("URI", URI)
        try json.set("priority", priority.rawValue)
        try json.set("reference", reference)
        try json.set("attachment", attachment)
        try json.set("status", status.makeJSON())
        
        return json
    }
    
    init(json: JSON) throws {
        self.timestamp = try json.get("timestamp")
        self.payload = (try json["payload"]?.asString())!
        self.URI = try json.get("URI")
        self.priority = TriprAPIMessagePriority(rawValue: try json.get("priority"))!
        self.reference = try json.get("reference")
        if let attachmentString : String = try json.get("attachment") {
            self.attachment = Data.init(bytes:attachmentString.bytes)
        }else {
            self.attachment = nil
        }
        self.messageId = try json.get("messageId")
    }
    
    
}

/// Request message to and from JSON
extension triprAPIRequestMessage : JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("messageId", messageId)
        try json.set("timestamp", timestamp)
        try json.set("payload", payload)
        try json.set("URL", URL)
        try json.set("priority", priority.rawValue)
        try json.set("reference", reference)
        try json.set("attachment", attachment)
        
        return json
    }
    
    init(json: JSON) throws {
        self.timestamp = try json.get("timestamp")
        self.payload = (try json["payload"]?.asString())!
        self.URL = ""
        self.APIKey = try json.get("APIKey")
        self.priority = TriprAPIMessagePriority(rawValue: try json.get("priority"))!
        self.reference = try json.get("reference")
        if let attachmentString : String = try json.get("attachment") {
            self.attachment = Data.init(bytes:attachmentString.bytes)
        }else {
            self.attachment = nil
        }
        self.messageId = try json.get("messageId")
    }
    
    
    
}
