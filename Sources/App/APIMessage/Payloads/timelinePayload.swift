//
//  timelinePayload.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-06.
//

import Foundation

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
