//
//  SearchRoutes.swift
//  App
//
//  Created by Daniel Skevarp on 2018-04-09.
//

import Foundation
import AuthProvider
import MySQL
import HTTP
import Vapor

/** Class for handling user routes and their functionality */
class SearchRoutes {
    /// Add User routes /api/vX/trip
    func addRoutes(routeBuilder: RouteBuilder){
        /// Framework for checking that a user is authenticate before letting them access certain endpoints
        //        do {
        let passmw = isAuthenticatedMiddleware()
        
        let secureArea = routeBuilder.grouped(passmw)
        secureArea.post("all", handler: searchAll)
        secureArea.post("user", handler: searchUsers)
        secureArea.post("trip", handler: searchTrips)
    }
    
    
    func searchAll(request: Request) throws -> ResponseRepresentable {
        do {
            let message = try request.getAPIRequestMessage()
            let search = SearchController.init(forInterface: .api, request: request, message: message)
            return try search.searchAll()
        }catch let error as TriprAPIMessageError {
            return try TripController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func searchUsers(request: Request) throws -> ResponseRepresentable {
        do {
            let message = try request.getAPIRequestMessage()
            let search = SearchController.init(forInterface: .api, request: request, message: message)
            return try search.searchUsers()
        }catch let error as TriprAPIMessageError {
            return try TripController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func searchTrips(request: Request) throws -> ResponseRepresentable {
        do {
            let message = try request.getAPIRequestMessage()
            let search = SearchController.init(forInterface: .api, request: request, message: message)
            return try search.searchTrips()
        }catch let error as TriprAPIMessageError {
            return try TripController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
   
}
