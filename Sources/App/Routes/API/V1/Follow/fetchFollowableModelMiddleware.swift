//
//  fetchFollowableModelMiddleware.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-02.
//

import Foundation
import HTTP
import Authentication

/*** middleware for securing endpoints to only logged in users */
//public final class fetchFollowableModelMiddleware: Middleware {
//
//    var model : Followable?
//
//    public init() {
//
//    }
//
//    public func respond(to req: Request, chainingTo next: Responder) throws -> Response {
//
//        guard let followable = try? req.parameters.next(Followable) else {
//            var json = JSON()
//            try json.set("error", "User doesnt exists")
//            return try Response.init(status: .badRequest, json: json )
//        }
//
//        self.model = followable
//    }
//}

