//
//  SearchController.swift
//  App
//
//  Created by Daniel Skevarp on 2018-04-09.
//

import Foundation
import Vapor
import HTTP
import AuthProvider
import MySQL

final class SearchController : SuperController {
    
    func searchAll() throws -> ResponseRepresentable {
       
        let searchInput = try PayloadSearchInput.init(json: (self.message?.payload.asJSON())!)
        if searchInput.searchTerm.count < 3 {
            return try self.createResponse(payload: (self.request.json)!, status: (.ok, "Search term has to be atleast 3 characters"))
        }
        let trips = try Trip.makeQuery().filter("name", .contains , searchInput.searchTerm).limit(25).all()
        let users = try User.makeQuery().or({ orGroup in
            try orGroup.filter("username", .contains, searchInput.searchTerm)
            try orGroup.filter("firstname", .contains, searchInput.searchTerm)
            try orGroup.filter("lastname", .contains, searchInput.searchTerm)
        }).limit(25).all()
        
        do {
             let payload = PayloadSearchResult.init(users: users, trips: trips)
//            try trip.attendants.add(user)
            return try self.createResponse(payload: try payload.makeJSON(), status: (.ok, "Searchresult returned"))
            
        }catch let error {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, error.localizedDescription))
        }
        
    }
    
    func searchUsers() throws -> ResponseRepresentable {
        
        let searchInput = try PayloadSearchInput.init(json: (self.message?.payload.asJSON())!)
        if searchInput.searchTerm.count < 3 {
            return try self.createResponse(payload: (self.request.json)!, status: (.ok, "Search term has to be atleast 3 characters"))
        }
        
        let users = try User.makeQuery().or({ orGroup in
            try orGroup.filter("username", .contains, searchInput.searchTerm)
            try orGroup.filter("firstname", .contains, searchInput.searchTerm)
            try orGroup.filter("lastname", .contains, searchInput.searchTerm)
        }).limit(25).all()
        
        do {
            let payload = PayloadSearchResult.init(users: users, trips: nil)
            return try self.createResponse(payload: try payload.makeJSON(), status: (.ok, "Searchresult returned"))
            
        }catch let error {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, error.localizedDescription))
        }
        
    }
    
    func searchTrips() throws -> ResponseRepresentable {
        
        let searchInput = try PayloadSearchInput.init(json: (self.message?.payload.asJSON())!)
        if searchInput.searchTerm.count < 3 {
            return try self.createResponse(payload: (self.request.json)!, status: (.ok, "Search term has to be atleast 3 characters"))
        }
        let trips = try Trip.makeQuery().filter("name", .contains , searchInput.searchTerm).limit(25).all()
        
        do {
            let payload = PayloadSearchResult.init(users: nil, trips: trips)
            return try self.createResponse(payload: try payload.makeJSON(), status: (.ok, "Searchresult returned"))
            
        }catch let error {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, error.localizedDescription))
        }
        
    }
    
}

