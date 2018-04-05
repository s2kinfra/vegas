//
//  timelinePayload.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-06.
//

import Foundation

struct timelineResponsePayload: JSONConvertible {

    var creator : User
    var timestamp : Double
    var text : Comment?
    var attachment : Attachment?
    var comments : [Comment] = [Comment]()
    var envies : [Envy] = [Envy]()
    
    init( creator _creator : User, timestamp _timestamp : Double, attachment _attachment : Attachment? = nil, text _text : Comment?, comments _comments : [Comment]? = nil, envies _envies: [Envy]? = nil) {

        self.creator = _creator
        self.timestamp = _timestamp
        self.attachment = _attachment
        self.text = _text
        if _comments != nil {
            self.comments = _comments!
        }

        if _envies != nil {
            self.envies = _envies!
        }

    }
    init(json: JSON) throws {
        guard let creator : User = try json.get("creator") else {
            throw TriprAPIMessageError.missingData(field: "creator")
        }
        guard let timestamp : Double = try json.get("timestamp") else {
            throw TriprAPIMessageError.missingData(field: "timestamp")
        }
        self.creator = creator
        self.timestamp = timestamp
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("timestamp", timestamp)
        try json.set("creator", creator)
        try json.set("comments", comments)
        try json.set("attachment", attachment)
        return json
    }

}

struct tripTimelineRequestPayload  : JSONConvertible{
    var numberOfFeeds  : Int = 25
    var startIndex : Int = 0
    var user : Int = 0
    init() {
        
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("numberOfFeeds", numberOfFeeds)
        try json.set("startIndex", startIndex)
        return json
    }
    
    init(json: JSON) throws {
        guard let startIdx : Int = try json.get("startIndex") else {
            throw TriprAPIMessageError.missingData(field: "startIndex")
        }
        guard let numFeeds : Int = try json.get("numberOfFeeds") else {
            throw TriprAPIMessageError.missingData(field: "numberOfFeeds")
        }
        self.startIndex = startIdx
        self.numberOfFeeds = numFeeds
    }
}

struct ownTimelineRequestPayload  : JSONConvertible{
    var numberOfFeeds  : Int = 25
    var startIndex : Int = 0
    
    init() {
        
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("numberOfFeeds", numberOfFeeds)
        try json.set("startIndex", startIndex)
        return json
    }
    
    init(json: JSON) throws {
        guard let startIdx : Int = try json.get("startIndex") else {
            throw TriprAPIMessageError.missingData(field: "startIndex")
        }
        guard let numFeeds : Int = try json.get("numberOfFeeds") else {
            throw TriprAPIMessageError.missingData(field: "numberOfFeeds")
        }
        self.startIndex = startIdx
        self.numberOfFeeds = numFeeds
    }
}


struct userTimelineRequestPayload  : JSONConvertible{
    var numberOfFeeds  : Int = 25
    var startIndex : Int = 0
    var user : Int = 0
    init() {
        
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("numberOfFeeds", numberOfFeeds)
        try json.set("startIndex", startIndex)
        return json
    }
    
    init(json: JSON) throws {
        guard let startIdx : Int = try json.get("startIndex") else {
            throw TriprAPIMessageError.missingData(field: "startIndex")
        }
        guard let numFeeds : Int = try json.get("numberOfFeeds") else {
            throw TriprAPIMessageError.missingData(field: "numberOfFeeds")
        }
        self.startIndex = startIdx
        self.numberOfFeeds = numFeeds
    }
}
