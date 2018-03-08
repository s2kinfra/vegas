//
//  UserRoutes.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-02.
//

import Foundation

import AuthProvider
import MySQL
import HTTP
import Vapor

/** Class for handling user routes and their functionality */
class UserRoutes {
    
    /// Add User routes /api/vX/user
    func addRoutes(routeBuilder: RouteBuilder){
        /// Framework for checking that a user is authenticate before letting them access certain endpoints
        //        do {
        let passmw = isAuthenticatedMiddleware()
        
        ///Open Routes
        
        /// Test routes
        routeBuilder.get("test", handler: createFeedKeys)
        /// Open GET Routes
        routeBuilder.get("logout", handler: logoutUser)
        /// Open POST Routes
        routeBuilder.post("login", handler: loginUser)
        routeBuilder.post("register", handler: registerUser)
        
        ///Closed Routes , required logged in user
        let secureArea = routeBuilder.grouped(passmw)
        /// GET Routes
        secureArea.get(User.parameter, handler: getUser)
        
        
        /// Timeline routes for user, returns Feed objects
        secureArea.post("timeline", handler: getOwnTimeline)
        secureArea.post(User.parameter, "timeline", handler: getUserTimeline)
        
        /// Followable routes
        secureArea.get(User.parameter, "follow", handler: followUser)
        secureArea.get(User.parameter, "accept", handler: acceptFollow)
        secureArea.get(User.parameter, "reject", handler: rejectFollow)
        secureArea.get(User.parameter, "unfollow", handler: stopFollow)
        
        /// Notification routes
        secureArea.get("notifications", handler: getNotifications)
    }
    
    ///Test route
    func createFeedKeys(request : Request) throws -> ResponseRepresentable {
        let user = try request.user()
        user.createFeedData(feedObjectType: user.objectType, feedObjectId: user.objectIdentifier, timestamp: Date().timeIntervalSince1970, feedType: .unknown)
        
        return "feed created"
    }
    
    /** Notifications , can be moved */
    func getNotifications(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        
        let notifications = user.notifications
        return try notifications.makeJSON()
    }
    /** Feed routes for user */
    
    func getUserTimeline(request: Request) throws -> ResponseRepresentable {
        do {
            let message = try request.getAPIRequestMessage()
            do {
                let timelineData = try userTimelineRequestPayload.init(json: message.payload.asJSON())
                guard let user = try User.find(Identifier(timelineData.user)) else {
                    return try triprAPIResponseMessage.getNewResponseMessage(payload: message.payload,
                                                                             URI: request.uri.path,
                                                                             reference: message.messageId,
                                                                             status: (.error, "Requested user doesnt exists")).makeJSON()
                }
                
                let timeline = try user.getTimelineItems(startIndex: timelineData.startIndex, numberOfFeeds: timelineData.numberOfFeeds)
                
                return try triprAPIResponseMessage.getNewResponseMessage(payload: try timeline.makeJSON(),
                                                                         URI: request.uri.path,
                                                                         reference: message.messageId,
                                                                         status: (.ok, "Timeline served")).makeJSON()
            }catch let error{
                return try triprAPIResponseMessage.getNewResponseMessage(payload: message.payload,
                                                                         URI: request.uri.path,
                                                                         reference: message.messageId,
                                                                         status: (.error, error.localizedDescription)).makeJSON()
            }
        }catch let error as TriprAPIMessageError {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: (request.json?.asString())!,
                                                                     URI: request.uri.path,
                                                                     priority: .high,
                                                                     reference: request.json?.asString(),
                                                                     status: (.error, error.getErrorCode())).makeJSON()
        }
    }
    
    func getOwnTimeline(request: Request) throws -> ResponseRepresentable {
        
        do {
            let message = try request.getAPIRequestMessage()
            do {
                //let userdata = try message.payload.asJSON()
                let timelineData = try ownTimelineRequestPayload.init(json: message.payload.asJSON())
                let user = try request.user()
                let timeline = try user.getTimelineItems(startIndex: timelineData.startIndex, numberOfFeeds: timelineData.numberOfFeeds).makeJSON()
                
                return try triprAPIResponseMessage.getNewResponseMessage(payload: timeline,
                                                                         URI: request.uri.path,
                                                                         reference: message.messageId,
                                                                         status: (.ok, "Timeline served")).makeJSON()
                
            }catch let error as TriprAPIMessageError{
                var json = JSON()
                try json.set("error", error.getErrorCode())
                return try Response.init(status: .badRequest, json: json )
            }catch let error as MySQLError {
                var json = JSON()
                try json.set("error", error.reason)
                return try Response.init(status: .badRequest, json: json )
            }
        }catch let error as TriprAPIMessageError {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: (request.json?.asString())!,
                                                                     URI: request.uri.path,
                                                                     priority: .high,
                                                                     reference: request.json?.asString(),
                                                                     status: (.error, error.getErrorCode())).makeJSON()
        }
    }
    
    /** Followable routes */
    /// Stop follow user
    func stopFollow(request : Request) throws -> ResponseRepresentable {
        guard let follower = try? request.parameters.next(User.self) else {
            var json = JSON()
            try json.set("error", "User doesnt exists")
            return try Response.init(status: .badRequest, json: json )
        }
        
        let me = try request.user()
        try me.stopFollowing(by: follower.id!)
        return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                 URI: request.uri.path,
                                                                 reference: "",
                                                                 status: (.ok, "You have now stopped following \(follower.fullname)")).makeJSON()
    }
    /// Reject follow request
    func rejectFollow(request: Request) throws -> ResponseRepresentable {
        guard let follower = try? request.parameters.next(User.self) else {
            var json = JSON()
            try json.set("error", "User doesnt exists")
            return try Response.init(status: .badRequest, json: json )
        }
        
        let me = try request.user()
        try me.declineFollow(follower: follower.id!)
        return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                 URI: request.uri.path,
                                                                 reference: "",
                                                                 status: (.ok, "Follow request was rejected")).makeJSON()
    }
    /// accept follow request.
    func acceptFollow(request: Request) throws -> ResponseRepresentable {
        /// get the follower user object from the parameters of the request
        guard let follower = try? request.parameters.next(User.self) else {
            var json = JSON()
            try json.set("error", "User doesnt exists")
            return try Response.init(status: .badRequest, json: json )
        }
        /// get a instance of me
        let me = try request.user()
        
        do {
            /// accept the followers request
            try me.acceptFollow(follower: follower.id!)
            
            ///if Im not private then the follower can tell his followers that he now is following me
            if !me.isPrivate! {
                follower.createFeedData(feedObjectType: me.objectType, feedObjectId: me.objectIdentifier, timestamp: Date().timeIntervalSince1970, feedType: .followAccepted)
            }
            
            /// Send a notification to follower that he/she has been accepted
            _ = try follower.createNotification(notificationType: .FollowAccepted, parameters: [(1, me.objectType, me.objectIdentifier.int!)])
            
            return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                     URI: request.uri.path,
                                                                     reference: "",
                                                                     status: (.ok, "You accepted the follow request from \(follower.fullname)")).makeJSON()
            
        } catch _ as FollowableErrors {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                     URI: request.uri.path,
                                                                     priority: .medium,
                                                                     reference: "",
                                                                     status: (.error,"No request found from user \(follower.fullname)")).makeJSON()
        }
    }
    
    /// Follow user
    func followUser(request: Request) throws -> ResponseRepresentable {
        guard let user = try? request.parameters.next(User.self) else {
            var json = JSON()
            try json.set("error", "User doesnt exists")
            return try Response.init(status: .badRequest, json: json )
        }
        
        let me = try request.user()
        if (me.id == user.id) {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                     URI: request.uri.path,
                                                                     priority: .medium,
                                                                     reference: "",
                                                                     status: (.error,"You follow yourself")).makeJSON()
        }
        do {
            try user.startFollowing(by: me.id!)
            _ = try user.createNotification(notificationType: .FollowRequest, parameters: [(1, me.objectType, me.objectIdentifier.int!)])
        } catch _ as FollowableErrors {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                     URI: request.uri.path,
                                                                     priority: .medium,
                                                                     reference: "",
                                                                     status: (.error,"You already follow \(user.fullname)")).makeJSON()
        }
        
        return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                 URI: request.uri.path,
                                                                 priority: .medium,
                                                                 reference: "",
                                                                 status: (.ok,"You have requested to follow \(user.fullname)")).makeJSON()
    }
    /** Logout a user */
    func logoutUser(request : Request) throws -> ResponseRepresentable {
        
        do {
            try request.auth.unauthenticate()
            return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                     URI: request.uri.path,
                                                                     priority: .medium,
                                                                     reference: "",
                                                                     status: (.ok, "User logged out")).makeJSON()
        }catch {
            var json = JSON()
            try json.set("error", "Unable to logout user")
            return try Response.init(status: .badRequest, json: json )
        }
    }
    
    func testing(request: Request) throws -> ResponseRepresentable {
        guard let user = try? request.parameters.next(User.self) else {
            var json = JSON()
            try json.set("error", "User doesnt exists")
            return try Response.init(status: .badRequest, json: json )
        }
        return try user.makeJSON()
    }
    
    /** get a user, user parameter is set up to be username and not id!*/
    func getUser(request : Request) throws -> ResponseRepresentable {
        guard let user = try? request.parameters.next(User.self) else {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                     URI: request.uri.path,
                                                                     priority: .medium,
                                                                     reference: "",
                                                                     status: (.error ,"User doesnt exists")).makeJSON()
        }
        
        return try triprAPIResponseMessage.getNewResponseMessage(payload: try user.makeJSON(),
                                                                 URI: request.uri.path,
                                                                 priority: .medium,
                                                                 reference: "",
                                                                 status: (.ok,"User exists")).makeJSON()
    }
    
    /** Login a user */
    func loginUser(request: Request) throws -> ResponseRepresentable {
        
        do {
            let message = try request.getAPIRequestMessage()
            do {
                let userData = try UserPayloadLogin.init(json: message.payload.asJSON())
                let user = try User.loginUser(userData: userData)
                try request.auth.authenticate(user, persist: true)
                return try triprAPIResponseMessage.getNewResponseMessage(payload: try user.makeJSON(),
                                                                         URI: request.uri.path,
                                                                         priority: .high,
                                                                         reference: message.messageId,
                                                                         status: (.ok, "User logged in successfully")).makeJSON()
            }catch let error as TriprAPIMessageError{
                return try triprAPIResponseMessage.getNewResponseMessage(payload: (request.json?.asString())!,
                                                                         URI: request.uri.path,
                                                                         priority: .high,
                                                                         reference: message.messageId,
                                                                         status: (.error, error.getErrorCode())).makeJSON()
            }catch let error as MySQLError {
                return try triprAPIResponseMessage.getNewResponseMessage(payload: (request.json?.asString())!,
                                                                         URI: request.uri.path,
                                                                         priority: .high,
                                                                         reference: message.messageId,
                                                                         status: (.error, error.reason)).makeJSON()
            }catch let error as AuthenticationError{
                
                var errorReason : String = error.reason
                if error.status == HTTP.Status.unauthorized {
                    errorReason = "Invalid credentials"
                }
                return try triprAPIResponseMessage.getNewResponseMessage(payload: (request.json?.asString())!,
                                                                         URI: request.uri.path,
                                                                         priority: .high,
                                                                         reference: message.messageId,
                                                                         status: (.error, errorReason)).makeJSON()
            }catch let error {
                return try triprAPIResponseMessage.getNewResponseMessage(payload: (request.json?.asString())!,
                                                                         URI: request.uri.path,
                                                                         priority: .high,
                                                                         reference: message.messageId,
                                                                         status: (.error, error.localizedDescription)).makeJSON()
            }
        } catch let error as TriprAPIMessageError {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: (request.json?.asString())!,
                                                                     URI: request.uri.path,
                                                                     priority: .high,
                                                                     reference: request.json?.asString(),
                                                                     status: (.error, error.getErrorCode())).makeJSON()
        }
        
    }
    
    /** Register a new user */
    func registerUser(request: Request) throws -> ResponseRepresentable {
        // check that email and password are supplied
        do {
            let message = try request.getAPIRequestMessage()
            do {
                //let userdata = try message.payload.asJSON()
                let userData = try UserPayloadRegister.init(json: message.payload.asJSON())
                let user = try User.registerNewUser(userData: userData)
                try request.auth.authenticate(user, persist: true)
                return try triprAPIResponseMessage.getNewResponseMessage(payload: try user.makeJSON(),
                                                                         URI: request.uri.path,
                                                                         priority: .high,
                                                                         reference: message.messageId,
                                                                         status: (.ok, "User registered successfully")).makeJSON()
                
            }catch let error as TriprAPIMessageError{
                return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                         URI: request.uri.path,
                                                                         priority: .high,
                                                                         reference: request.json?.asString(),
                                                                         status: (.error, error.getErrorCode())).makeJSON()
            }catch let error as MySQLError {
                var errorReason = error.reason
                if error.code == MySQL.MySQLError.Code.dupEntry {
                    errorReason = "Username or Email adress already registered"
                }
                return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                         URI: request.uri.path,
                                                                         priority: .high,
                                                                         reference: request.json?.asString(),
                                                                         status: (.error, errorReason)).makeJSON()
            }
        }catch let error as TriprAPIMessageError {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: (request.json?.asString())!,
                                                                     URI: request.uri.path,
                                                                     priority: .high,
                                                                     reference: request.json?.asString(),
                                                                     status: (.error, error.getErrorCode())).makeJSON()
        }
    }
    
    
}

