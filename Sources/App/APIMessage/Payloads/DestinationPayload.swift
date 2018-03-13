//
//  DestinationPayload.swift
//  App
//
//  Created by Daniel Skevarp on 2018-03-12.
//


struct updateDestinationPayload : JSONConvertible {
    var name : String
    var isPrivate : Bool
    var arrivalDate : Double
    var departureDate : Double
    var destinationImage : attachmentPayload?
    
    init(isPrivate _isPrivate: Bool,arrivalDate _arrivalDate : Double,departureDate _departureDate : Double, name _name : String, destinationImage _image : attachmentPayload? = nil ) {
        
        self.isPrivate = _isPrivate
        self.arrivalDate = _arrivalDate
        self.departureDate = _departureDate
        self.name = _name
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("isPrivate", isPrivate)
        try json.set("arrivalDate", arrivalDate)
        try json.set("departureDate", departureDate)
        try json.set("name", name)
        try json.set("destinationImage", destinationImage)
        
        return json
    }
    
    init(json: JSON) throws {
        
        guard let isPrivate : Bool = try json.get("isPrivate") else {
            throw TriprAPIMessageError.missingData(field: "isPrivate")
        }
        guard let arrivalDate : Double = try json.get("arrivalDate") else {
            throw TriprAPIMessageError.missingData(field: "arrivalDate")
        }
        guard let departureDate : Double = try json.get("departureDate") else {
            throw TriprAPIMessageError.missingData(field: "departureDate")
        }
        guard let name : String = try json.get("name") else {
            throw TriprAPIMessageError.missingData(field: "name")
        }
        self.name = name
        self.isPrivate = isPrivate
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
        self.destinationImage = try json.get("destinationImage")
    }
    
}

struct createNewDestinationPayload  : JSONConvertible{
    
    var name : String
    var isPrivate : Bool
    var arrivalDate : Double
    var departureDate : Double
    var destinationImage : attachmentPayload?
    
    init(isPrivate _isPrivate: Bool,arrivalDate _arrivalDate : Double,departureDate _departureDate : Double, name _name : String,destinationImage _image : attachmentPayload? = nil ) {
        
        self.isPrivate = _isPrivate
        self.arrivalDate = _arrivalDate
        self.departureDate = _departureDate
        self.name = _name
        self.destinationImage = _image
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("isPrivate", isPrivate)
        try json.set("arrivalDate", arrivalDate)
        try json.set("departureDate", departureDate)
        try json.set("name", name)
        try json.set("destinationImage", destinationImage)
        
        return json
    }
    
    init(json: JSON) throws {
        
        guard let isPrivate : Bool = try json.get("isPrivate") else {
            throw TriprAPIMessageError.missingData(field: "isPrivate")
        }
        guard let arrivalDate : Double = try json.get("arrivalDate") else {
            throw TriprAPIMessageError.missingData(field: "arrivalDate")
        }
        guard let departureDate : Double = try json.get("departureDate") else {
            throw TriprAPIMessageError.missingData(field: "departureDate")
        }
        guard let name : String = try json.get("name") else {
            throw TriprAPIMessageError.missingData(field: "name")
        }
        self.name = name
        self.isPrivate = isPrivate
        self.destinationImage = try json.get("destinationImage")
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
    }
}


