//
//  FollowRoutes.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-02.
//

import Foundation
import AuthProvider
import MySQL
import HTTP
import Vapor
import FluentProvider

/** Class for handling user routes and their functionality */
class FollowRoutes {
    
    var followable : Followable?
    
    init() {}
    
    /** Add follow routes /api/vX/XXX/id/follow
        These routes are generic and can be used on all objects implementing Followable protocols routes.
    */
    func addRoutes(routeBuilder: RouteBuilder){
        /** GET Routes */
        routeBuilder.get("test", handler: thisisatest)
        routeBuilder.get("follow", handler: follow)
        routeBuilder.get("follow", Follow.parameter, "accept", handler: acceptFollow)
        /** Follow a followable object , by a logged in user
            In the exmaple of following a user.
            then the user uri has to be /api/vX/user/testuser/
            and this route builder adds follow so complete uri will be
            /api/vX/user/testuser/follow
            This will add a follow request , if testuser is private, by the logged in user
            or if testuser is public it will automatically accept the follow request and logged in user
            is now following testuser.
        */
//        routeBuilder.get("follow", handler: startFollowing)
        
        /** POST Routes */
    }

    func acceptFollow(request: Request) throws -> ResponseRepresentable {
        guard let user = try? request.parameters.next(User.self) else {
            var json = JSON()
            try json.set("error", "User doesnt exists")
            return try Response.init(status: .badRequest, json: json )
        }
        
        let follower = try request.user()
        try user.acceptFollow(follower: follower.id!)
        if (user.id == follower.id) {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                     URI: request.uri.path,
                                                                     priority: .medium,
                                                                     reference: "",
                                                                     status: (.error,"You cant follow yourself")).makeJSON()
        }
        
        try user.startFollowing(by: follower.id!)
        return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                 URI: request.uri.path,
                                                                 reference: "",
                                                                 status: (.ok, "User followed")).makeJSON()
    }
    
    func follow(request: Request) throws -> ResponseRepresentable {
        guard let user = try? request.parameters.next(User.self) else {
            var json = JSON()
            try json.set("error", "User doesnt exists")
            return try Response.init(status: .badRequest, json: json )
        }
        let follower = try request.user()
        if (user.id == follower.id) {
            return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                     URI: request.uri.path,
                                                                     priority: .medium,
                                                                     reference: "",
                                                                     status: (.error,"You cant follow yourself")).makeJSON()
        }
        
        try user.startFollowing(by: follower.id!)
        return try triprAPIResponseMessage.getNewResponseMessage(payload: "",
                                                                 URI: request.uri.path,
                                                                 reference: "",
                                                                 status: (.ok, "User followed")).makeJSON()
    }
    
    func thisisatest(request: Request) throws -> ResponseRepresentable {
        
        return "this is a testasfasfsa"
    }
//    func startFollowing(request : Request) throws -> ResponseRepresentable {
//
//    }
    
}

