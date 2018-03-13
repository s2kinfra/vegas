//
//  File.swift
//  App
//
//  Created by Daniel Skevarp on 2018-03-13.
//


import Foundation
import AuthProvider
import MySQL
import HTTP
import Vapor

/** Class for handling user routes and their functionality */
class DestinationRoutes {
    /// Add User routes /api/vX/trip
    func addRoutes(routeBuilder: RouteBuilder){
        /// Framework for checking that a user is authenticate before letting them access certain endpoints
        //        do {
        let passmw = isAuthenticatedMiddleware()
        
        let secureArea = routeBuilder.grouped(passmw)
        secureArea.get(Destination.parameter, handler: getDestination)
        secureArea.post("", handler: createDestination)
        secureArea.put(Destination.parameter, handler: updateDestination)
//        secureArea.post(Trip.parameter, "destination", handler: createNewDestination)
//        secureArea.put(Trip.parameter, handler: updateTrip)
//        secureArea.get(Trip.parameter, handler: getTrip)
//        secureArea.post(Trip.parameter, "comment", handler: addComment)
//        secureArea.post("", handler: createTrip)
//        secureArea.get("forUser",User.parameter, handler: getUsersTrip)
//        secureArea.get(Trip.parameter, "follow", handler: followTrip)
//        secureArea.get(Trip.parameter, "accept" , User.parameter, handler: acceptFollow)
//        secureArea.get(Trip.parameter, "invite", User.parameter, handler: inviteUser)
//        secureArea.post(Trip.parameter, "timeline", handler: getTripTimeline)
    }
    
    
    func updateDestination(request: Request) throws -> ResponseRepresentable {
        do{
            let message = try request.getAPIRequestMessage()
            let dest = DestinationController.init(forInterface: .api, request: request, message: message)
            return try dest.updateDestination()
        }catch let error as TriprAPIMessageError {
            return try DestinationController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func createDestination(request: Request) throws -> ResponseRepresentable {
        do{
            let message = try request.getAPIRequestMessage()
            let dest = DestinationController.init(forInterface: .api, request: request, message: message)
            return try dest.createNewDestination()
        }catch let error as TriprAPIMessageError {
            return try DestinationController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func getDestination(request: Request) throws -> ResponseRepresentable {
        let dest = DestinationController.init(forInterface: .api, request: request, message: nil)
        return try dest.getDestination()
    }
}


