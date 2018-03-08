//
//  isAuthenticatedMiddleware.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-02.
//

import HTTP
import Authentication

/*** middleware for securing endpoints to only logged in users */
public final class isAuthenticatedMiddleware: Middleware {
    
    public init() {}
    
    public func respond(to req: Request, chainingTo next: Responder) throws -> Response {
        // if the user has already been authenticated
        // by a previous middleware, continue
        let _ = try req.user()
        return try next.respond(to: req)
    }
}

