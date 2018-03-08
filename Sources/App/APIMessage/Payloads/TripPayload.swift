//
//  TripPayload.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-12.
//

import Foundation


struct updateTripPayload : JSONConvertible {
    var name : String
    var isPrivate : Bool
    var tripStartDate : Double
    var tripEndDate : Double
    var tripImage : attachmentPayload?
    
    init(isPrivate _isPrivate: Bool,tripStartDate _tripStartDate : Double,tripEndDate _tripEndDate : Double, name _name : String, tripImage _image : attachmentPayload? = nil ) {
        
        self.isPrivate = _isPrivate
        self.tripStartDate = _tripStartDate
        self.tripEndDate = _tripEndDate
        self.name = _name
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("isPrivate", isPrivate)
        try json.set("tripStartDate", tripStartDate)
        try json.set("tripEndDate", tripEndDate)
        try json.set("name", name)
        try json.set("tripImage", tripImage)
        
        return json
    }
    
    init(json: JSON) throws {
        
        guard let isPrivate : Bool = try json.get("isPrivate") else {
            throw TriprAPIMessageError.missingData(field: "isPrivate")
        }
        guard let tripStartDate : Double = try json.get("startDate") else {
            throw TriprAPIMessageError.missingData(field: "startDate")
        }
        guard let tripEndDate : Double = try json.get("endDate") else {
            throw TriprAPIMessageError.missingData(field: "endDate")
        }
        guard let name : String = try json.get("name") else {
            throw TriprAPIMessageError.missingData(field: "name")
        }
        self.name = name
        self.isPrivate = isPrivate
        self.tripStartDate = tripStartDate
        self.tripEndDate = tripEndDate
        self.tripImage = try json.get("tripImage")
    }
    
}

struct createNewTripPayload  : JSONConvertible{
    
    var name : String
    var isPrivate : Bool
    var tripStartDate : Double
    var tripEndDate : Double
    var tripImage : attachmentPayload?
    
    init(isPrivate _isPrivate: Bool,tripStartDate _tripStartDate : Double,tripEndDate _tripEndDate : Double, name _name : String,tripImage _image : attachmentPayload? = nil ) {
        
        self.isPrivate = _isPrivate
        self.tripStartDate = _tripStartDate
        self.tripEndDate = _tripEndDate
        self.name = _name
        self.tripImage = _image
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("isPrivate", isPrivate)
        try json.set("tripStartDate", tripStartDate)
        try json.set("tripEndDate", tripEndDate)
        try json.set("name", name)
        try json.set("tripImage", tripImage)
        
        return json
    }
    
    init(json: JSON) throws {
        
        guard let isPrivate : Bool = try json.get("isPrivate") else {
            throw TriprAPIMessageError.missingData(field: "isPrivate")
        }
        guard let tripStartDate : Double = try json.get("startDate") else {
            throw TriprAPIMessageError.missingData(field: "startDate")
        }
        guard let tripEndDate : Double = try json.get("endDate") else {
            throw TriprAPIMessageError.missingData(field: "endDate")
        }
        guard let name : String = try json.get("name") else {
            throw TriprAPIMessageError.missingData(field: "name")
        }
        self.name = name
        self.isPrivate = isPrivate
        self.tripImage = try json.get("tripImage")
        self.tripStartDate = tripStartDate
        self.tripEndDate = tripEndDate
    }
}

