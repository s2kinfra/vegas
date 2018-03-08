//
//  CommentPayload.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-15.
//

import Foundation

struct addCommentPayload : JSONConvertible {
    var text : String
    var timestamp : Double
    var attachments : [attachmentPayload]?
    
    init(text _text: String, timestamp _stamp : Double, attachment _file : [attachmentPayload]? = nil) throws {
        self.text = _text
        self.timestamp = _stamp
        self.attachments = _file        
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("text", text)
        try json.set("timestamp", timestamp)
        try json.set("attachments", attachments)
        return json
    }
    
    init(json: JSON) throws {
        
        guard let text : String = try json.get("text") else {
            throw TriprAPIMessageError.missingData(field: "text")
        }
        guard let timestamp : Double = try json.get("timestamp") else {
            throw TriprAPIMessageError.missingData(field: "timestamp")
        }
        
        self.text = text
        self.timestamp = timestamp
        self.attachments = try json.get("attachments")
    }
    
}
