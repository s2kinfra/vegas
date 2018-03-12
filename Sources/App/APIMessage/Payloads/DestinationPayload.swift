//
//  DestinationPayload.swift
//  App
//
//  Created by Daniel Skevarp on 2018-03-12.
//


struct updateDestinationPayload : JSONConvertible {
    var name : String
    var isPrivate : Bool
    var destinationStartDate : Double
    var destinationEndDate : Double
    var destinationImage : attachmentPayload?
    
    init(isPrivate _isPrivate: Bool,destinationStartDate _destinationStartDate : Double,destinationEndDate _destinationEndDate : Double, name _name : String, destinationImage _image : attachmentPayload? = nil ) {
        
        self.isPrivate = _isPrivate
        self.destinationStartDate = _destinationStartDate
        self.destinationEndDate = _destinationEndDate
        self.name = _name
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("isPrivate", isPrivate)
        try json.set("destinationStartDate", destinationStartDate)
        try json.set("destinationEndDate", destinationEndDate)
        try json.set("name", name)
        try json.set("destinationImage", destinationImage)
        
        return json
    }
    
    init(json: JSON) throws {
        
        guard let isPrivate : Bool = try json.get("isPrivate") else {
            throw TriprAPIMessageError.missingData(field: "isPrivate")
        }
        guard let destinationStartDate : Double = try json.get("startDate") else {
            throw TriprAPIMessageError.missingData(field: "startDate")
        }
        guard let destinationEndDate : Double = try json.get("endDate") else {
            throw TriprAPIMessageError.missingData(field: "endDate")
        }
        guard let name : String = try json.get("name") else {
            throw TriprAPIMessageError.missingData(field: "name")
        }
        self.name = name
        self.isPrivate = isPrivate
        self.destinationStartDate = destinationStartDate
        self.destinationEndDate = destinationEndDate
        self.destinationImage = try json.get("destinationImage")
    }
    
}

struct createNewDestinationPayload  : JSONConvertible{
    
    var name : String
    var isPrivate : Bool
    var destinationStartDate : Double
    var destinationEndDate : Double
    var destinationImage : attachmentPayload?
    
    init(isPrivate _isPrivate: Bool,destinationStartDate _destinationStartDate : Double,destinationEndDate _destinationEndDate : Double, name _name : String,destinationImage _image : attachmentPayload? = nil ) {
        
        self.isPrivate = _isPrivate
        self.destinationStartDate = _destinationStartDate
        self.destinationEndDate = _destinationEndDate
        self.name = _name
        self.destinationImage = _image
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("isPrivate", isPrivate)
        try json.set("destinationStartDate", destinationStartDate)
        try json.set("destinationEndDate", destinationEndDate)
        try json.set("name", name)
        try json.set("destinationImage", destinationImage)
        
        return json
    }
    
    init(json: JSON) throws {
        
        guard let isPrivate : Bool = try json.get("isPrivate") else {
            throw TriprAPIMessageError.missingData(field: "isPrivate")
        }
        guard let destinationStartDate : Double = try json.get("startDate") else {
            throw TriprAPIMessageError.missingData(field: "startDate")
        }
        guard let destinationEndDate : Double = try json.get("endDate") else {
            throw TriprAPIMessageError.missingData(field: "endDate")
        }
        guard let name : String = try json.get("name") else {
            throw TriprAPIMessageError.missingData(field: "name")
        }
        self.name = name
        self.isPrivate = isPrivate
        self.destinationImage = try json.get("destinationImage")
        self.destinationStartDate = destinationStartDate
        self.destinationEndDate = destinationEndDate
    }
}


