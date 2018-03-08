//
//  AttachmentPayload.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-15.
//

import Foundation


struct attachmentPayload : JSONConvertible {
    var base64 : String
    var filename : String
    
    init(base64 _base64 : String, filename _filename : String) {
        self.base64 = _base64
        self.filename = _filename
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("base64", base64)
        try json.set("filename", filename)
        return json
    }
    
    init(json: JSON) throws {
        
        guard let base64 : String = try json.get("base64") else {
            throw TriprAPIMessageError.missingData(field: "base64")
        }
        guard let filename : String = try json.get("filename") else {
            throw TriprAPIMessageError.missingData(field: "filename")
        }
        self.base64 = base64
        self.filename = filename
    }
    
}
