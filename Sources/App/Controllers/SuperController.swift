//
//  SuperController.swift
//  App
//
//  Created by Daniel Skevarp on 2018-03-06.
//

import Foundation

enum controllerInterface : Int {
    case api = 0 , www = 1
}

class SuperController {
    var interface : controllerInterface
    var message : triprAPIRequestMessage?
    var request : Request
    
    init(forInterface _interface : controllerInterface, request _request : Request, message _message : triprAPIRequestMessage? = nil) {
        self.interface = _interface
        self.request = _request
        self.message = _message
    }
    
    static func createResponse(payload : JSON, request _request: Request, message _message : triprAPIRequestMessage? , reference _ref : String? = nil, interface _if : controllerInterface, status: (responseStatusCode, String))  throws -> ResponseRepresentable {
        let reference : String?
        
        switch _if {
        case .api:
            switch status.0 {
            case .ok :
                if _ref == nil {
                    reference = _message?.messageId
                }else {
                    reference = _ref
                }
                return try triprAPIResponseMessage.getNewResponseMessage(payload: payload,
                                                                         URI: _request.uri.path,
                                                                         priority: .high,
                                                                         reference: reference,
                                                                         status: status).makeJSON()
            case .error:
                if _ref == nil {
                    reference = try _request.json?.asString()
                }else {
                    reference = _ref
                }
                return try triprAPIResponseMessage.getNewResponseMessage(payload: payload,
                                                                         URI: _request.uri.path,
                                                                         priority: .high,
                                                                         reference: reference,
                                                                         status: status).makeJSON()
            case .info:
                return ""
            }
            
        case .www:
            return ""
        }
    }
    func createResponse(payload : JSON, reference _ref : String? = nil, status: (responseStatusCode, String))  throws -> ResponseRepresentable {
        let reference : String?
        
        switch self.interface {
        case .api:
            switch status.0 {
            case .ok :
                if _ref == nil {
                    reference = self.message?.messageId
                }else {
                    reference = _ref
                }
                return try triprAPIResponseMessage.getNewResponseMessage(payload: payload,
                                                                         URI: self.request.uri.path,
                                                                         priority: .high,
                                                                         reference: reference,
                                                                         status: status).makeJSON()
            case .error:
                if _ref == nil {
                    reference = try self.request.json?.asString()
                }else {
                    reference = _ref
                }
                return try triprAPIResponseMessage.getNewResponseMessage(payload: payload,
                                                                         URI: self.request.uri.path,
                                                                         priority: .high,
                                                                         reference: reference,
                                                                         status: status).makeJSON()
            case .info:
                return ""
            }
            
        case .www:
            return ""
        }
    }
    
    
}
