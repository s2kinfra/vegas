//
//  TripRoutes.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-12.
//

import Foundation
import AuthProvider
import MySQL
import HTTP
import Vapor

/** Class for handling user routes and their functionality */
class TripRoutes {
    /// Add User routes /api/vX/trip
    func addRoutes(routeBuilder: RouteBuilder){
        /// Framework for checking that a user is authenticate before letting them access certain endpoints
        //        do {
        let passmw = isAuthenticatedMiddleware()
        
        let secureArea = routeBuilder.grouped(passmw)
        secureArea.post(Trip.parameter, "destination", handler: createNewDestination)
        secureArea.put(Trip.parameter, handler: updateTrip)
        secureArea.get(Trip.parameter, handler: getTrip)
        secureArea.post(Trip.parameter, "comment", handler: addComment)
        secureArea.post("", handler: createTrip)
        secureArea.get("forUser",User.parameter, handler: getUsersTrip)
        secureArea.get(Trip.parameter, "follow", handler: followTrip)
        secureArea.get(Trip.parameter, "accept" , User.parameter, handler: acceptFollow)
        secureArea.post(Trip.parameter, "timeline", handler: getTripTimeline)
        secureArea.post(Trip.parameter, "addAttendant", handler: addAttendant)
        //        /// Test routes
        //        routeBuilder.get("test", handler: createFeedKeys)
        //        /// Open GET Routes
        //        routeBuilder.get("logout", handler: logoutUser)
        //        /// Open POST Routes
        //        routeBuilder.post("login", handler: loginUser)
        //        routeBuilder.post("register", handler: registerUser)
        //
        //        ///Closed Routes , required logged in user
        //        let secureArea = routeBuilder.grouped(passmw)
        //        /// GET Routes
        //        secureArea.get(User.parameter, handler: getUser)
        //
        //
        //        /// Timeline routes for user, returns Feed objects
        //        secureArea.post("timeline", handler: getOwnTimeline)
        //        secureArea.post(User.parameter, "timeline", handler: getUserTimeline)
        //
        //        /// Followable routes
        //        secureArea.get(User.parameter, "follow", handler: followUser)
        //        secureArea.get(User.parameter, "accept", handler: acceptFollow)
        //        secureArea.get(User.parameter, "reject", handler: rejectFollow)
        //        secureArea.get(User.parameter, "unfollow", handler: stopFollow)
        //
        //        /// Notification routes
        //        secureArea.get("notifications", handler: getNotifications)
    }
    
    func addAttendant(request: Request) throws -> ResponseRepresentable {
        do {
            let message = try request.getAPIRequestMessage()
            let trip = TripController.init(forInterface: .api, request: request, message: message)
            return try trip.addNewAttendant()
        }catch let error as TriprAPIMessageError {
            return try TripController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func createNewDestination(request: Request) throws -> ResponseRepresentable {
        do {
            let message = try request.getAPIRequestMessage()
            let trip = TripController.init(forInterface: .api, request: request, message: message)
            return try trip.createNewDestination()
        }catch let error as TriprAPIMessageError {
            return try TripController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func getUsersTrip(request: Request) throws -> ResponseRepresentable {
        let trip = TripController.init(forInterface: .api, request: request)
        return try trip.getUsersTrips()
    }
    
    func acceptFollow(request: Request) throws -> ResponseRepresentable {
        let trip = TripController.init(forInterface: .api, request: request)
        return try trip.acceptFollow()
    }
    
    func getTripTimeline(request : Request) throws -> ResponseRepresentable {
        do {
            let message = try request.getAPIRequestMessage()
            let trip = TripController.init(forInterface: .api, request: request, message: message)
            return try trip.acceptFollow()
        }catch let error as TriprAPIMessageError {
            return try TripController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func addComment(request: Request) throws -> ResponseRepresentable {
        do{
            let message = try request.getAPIRequestMessage()
            let trip = TripController.init(forInterface: .api, request: request, message: message)
            return try trip.addComment()
        }catch let error as TriprAPIMessageError {
            return try TripController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func updateTrip(request: Request) throws -> ResponseRepresentable {
        do{
            let message = try request.getAPIRequestMessage()
            let trip = TripController.init(forInterface: .api, request: request, message: message)
            return try trip.updateTrip()
        }catch let error as TriprAPIMessageError {
            return try TripController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func followTrip(request: Request) throws -> ResponseRepresentable {
        guard let trip = try? request.parameters.next(Trip.self) else {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: (request.json?.asString())!,
                                                                     URI: request.uri.path,
                                                                     priority: .high,
                                                                     reference: request.json?.asString(),
                                                                     status: (.error, "Trip doesnt exists")).makeJSON()
        }
        
        let user = try request.user()
        do {
            try trip.startFollowing(by: user.id!)
            _ = try trip.createNotification(notificationType: .FollowRequest, parameters: [(1, user.objectType, user.objectIdentifier.int!)])
        } catch _ as FollowableErrors {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                     URI: request.uri.path,
                                                                     priority: .high,
                                                                     reference: "",
                                                                     status: (.error,"You already follow/requested to follow \(trip.name!)")).makeJSON()
        }
        
        return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                 URI: request.uri.path,
                                                                 priority: .medium,
                                                                 reference: "",
                                                                 status: (.ok,"You have requested to follow \(trip.name!)")).makeJSON()
        
    }
    
    func createTrip(request: Request) throws -> ResponseRepresentable {
        do{
            let message = try request.getAPIRequestMessage()
            let trip = TripController.init(forInterface: .api, request: request, message: message)
            return try trip.createTrip()
        }catch let error as TriprAPIMessageError {
            return try TripController.createResponse(payload: request.json!, request: request, message: nil,interface: .api, status: (.error, error.getErrorCode()))
        }
    }
    
    func getTrip(request: Request) throws -> ResponseRepresentable {
        let trip = TripController.init(forInterface: .api, request: request, message: nil)
        return try trip.getTrip()
    }
}

