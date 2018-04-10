//
//  SearchPayload.swift
//  App
//
//  Created by Daniel Skevarp on 2018-04-09.
//

import Foundation


struct PayloadSearchInput: JSONConvertible {
    var searchTerm : String
    
    init(searchTerm _searchTerm : String){
        self.searchTerm = _searchTerm
    }
    
    init(json: JSON) throws {
        guard let searchTerm : String = try json.get("searchTerm") else {
            throw TriprAPIMessageError.missingData(field: "searchTerm")
        }
        
        self.searchTerm = searchTerm
        
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("searchTerm", searchTerm)
        return json
    }
    
    
}

struct PayloadSearchResult: JSONConvertible {
    
    var trips : [Trip]?
    var users : [User]?
    
    init(users _users : [User]?, trips _trips : [Trip]?) {
        self.trips = _trips
        self.users = _users
    }
    
    init(json: JSON) throws {
        guard let users : [User] = try json.get("users") else {
            throw TriprAPIMessageError.missingData(field: "users")
        }
        guard let trips : [Trip] = try json.get("trips") else {
            throw TriprAPIMessageError.missingData(field: "trips")
        }
        
        self.users = users
        self.trips = trips
        
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("users", users)
        try json.set("trips", trips)
        return json
    }
    
    
}
