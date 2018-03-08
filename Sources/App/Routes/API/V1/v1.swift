//
//  v1.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-01.
//

import Foundation
import Vapor

/**
 Class defining all routes for Api interface Version 1.
 All subroutes are added by specific route classes, such as UserRoutes, SearchRoutes, TripRoutes etc.
 
 */
final class RoutesV1: RouteCollection {
    let drop : Droplet
    
   /// Instansiation requires the droplet
    init(drop : Droplet) {
        self.drop = drop
    }
    
    ///Function for builder the route tree
    func build(_ builder: RouteBuilder) throws {
        
        /// API
        builder.group("api") { api in
            ///V1
            api.group("v1") { v1 in
                /// Test routes
                v1.get("test", handler: test)
                /// User routes
                v1.group("user") { user in
                   let userRoutes = UserRoutes.init()
                    userRoutes.addRoutes(routeBuilder: user)
                }
                v1.group("trip") { trip in
                    
                    let tripRoutes = TripRoutes.init()
                    tripRoutes.addRoutes(routeBuilder: trip)
                }
            }
        }
    }
    
    ///test routes handler
    func test(request : Request) throws -> ResponseRepresentable {
        var json = JSON()
        
        try json.set("test", "test")
        
        return json
    }
}
