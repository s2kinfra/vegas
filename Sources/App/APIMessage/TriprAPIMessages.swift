//
//  TriprAPIMessages.swift
//  triprIOS
//
//  Created by Daniel Skevarp on 2018-01-02.
//  Copyright © 2018 Daniel Skevarp. All rights reserved.
//

import Foundation


enum TriprAPIMessageError: Error {
    case missingData(field : String)
    case invalidData(field: String)
    case outOfStock
    
    
    func getErrorCode() -> String {
        switch self {
        case .missingData(let field):
            return "missing field \(field)"
        default:
            return "something else"
        }
    }
}

//enum httpResponseStatusCode : Int, Codable {
//    case success_ok = 200, success_created = 201, success_accepted = 202, success_no_content = 204,
//    redirect_moved_perm = 301,
//    client_error_bad_reequest = 400, client_error_unauthorized = 401, client_error_forbidden = 403, client_error_not_found = 404, client_error_to_many_requests = 429,
//    server_error_internal_error = 500, server_error_not_implemented = 501, server_error_bad_gateway = 502, server_error_service_unavailble = 503
//
//    var isErrorCode : Bool {
//        if self.rawValue >= 300 {
//            return true
//        }else {
//            return false
//        }
//    }
//
//    var code_text : String {
//        switch self {
//        case .success_ok:
//            return "OK"
//        case .success_created:
//            return "Created"
//        case .success_accepted:
//            return "Accepted"
//        case .success_no_content:
//            return "No Content"
//        case .redirect_moved_perm:
//            return "Moved Permanently"
//        case .client_error_bad_reequest:
//            return "Bad Request"
//        case .client_error_unauthorized:
//            return "Unauthorized"
//        case .client_error_forbidden:
//            return "Forbidden"
//        case .client_error_not_found:
//            return "Not Found"
//        case .client_error_to_many_requests:
//            return "To many requests"
//        case .server_error_internal_error:
//            return "Internal server error"
//        case .server_error_not_implemented:
//            return "Not implemented"
//        case .server_error_bad_gateway:
//            return "Bad gateway"
//        case .server_error_service_unavailble:
//            return "Service Unavailable"
//        }
//    }
//
//}

enum TriprAPIMessagePriority : Int {
    case low = 0, medium, high
    
}

enum httpMethod : String {
    case POST = "POST", GET = "GET", PUT = "PUT", DELETE = "DELETE"
}

enum httpContentTypes : String {
    case json = "application/json",
    www_form = "application/x-www-form-urlencoded",
    form_data = "multipart/form-data"
    
    var string : String { get { return self.rawValue } }
}

//
//protocol triprPayloadMessage {
//    func getPayloadString() -> String
//}

//protocol TriprAPIServiceMessage {
//
//    var queable : Bool {get}
//    var messageId : String { get set }
//    var reference : String? {get set}
//    var priority : TriprAPIMessagePriority { get }
//    var sent : Bool { get set }
//    var timestamp : Double { get }
//    var payload : String { get }
//    var URL : String { get }
//    var httpMethod : httpMethod { get }
//    var contentType : httpContentTypes { get }
//    var attachment : Data? { get }
//
//
//}

protocol TriprAPIMessageData {
    var messageId : String { get set }
    var reference : String? {get set}
    var priority : TriprAPIMessagePriority { get }
    var timestamp : Double { get }
    var payload : String { get }
    var attachment : Data? { get }
}

protocol TriprAPIRequestMessageData : TriprAPIMessageData {
    var URL : String { get }
    var APIKey : String? { get }
}

enum responseStatusCode : Int {
    case ok = 100, error = 999, info = 200
}

struct triprAPIResponseStatusMessageData {
    var code: responseStatusCode = .ok
    var text : String = ""
}

protocol triprAPIResponseMessageData : TriprAPIMessageData {
    var URI : String { get }
    var status : triprAPIResponseStatusMessageData { get set }
}

struct triprAPIResponseMessage : triprAPIResponseMessageData {
    var messageId: String
    var timestamp: Double
    var payload: String
    var URI: String
    var priority: TriprAPIMessagePriority
    var reference : String?
    var attachment : Data?
    var status = triprAPIResponseStatusMessageData()
    
    init(payload: String, attachment : Data? = nil, reference : String? = nil, uri : String, contentType : httpContentTypes = .json, priority : TriprAPIMessagePriority = .medium, status: (responseStatusCode, String)) {
        self.timestamp = Date().timeIntervalSince1970
        self.payload = payload
        self.URI = uri
        self.priority = priority
        self.reference = reference
        self.attachment = attachment
        self.messageId = UUID.init().uuidString
        self.status.code = status.0
        self.status.text = status.1
    }
    
    static func getNewResponseMessage(payload: JSON, URI: String, priority : TriprAPIMessagePriority = .medium, reference : String?, attachment : Data? = nil, status: (responseStatusCode, String)) throws -> triprAPIResponseMessage{
        
        var message = triprAPIResponseMessage.init(payload: try payload.asString(),
                                                   attachment: attachment,
                                                   reference: reference,
                                                   uri: URI,
                                                   priority: priority,
                                                   status: status)
        
        message.timestamp = Date().timeIntervalSince1970
        message.messageId = UUID.init().uuidString
        
        return message
    }
    
    static func getNewResponseMessage(payload: String, URI: String, priority : TriprAPIMessagePriority = .medium, reference : String?, attachment : Data? = nil, status: (responseStatusCode, String)) throws -> triprAPIResponseMessage{
        
        var message = triprAPIResponseMessage.init(payload: payload,
                                                   attachment: attachment,
                                                   reference: reference,
                                                   uri: URI,
                                                   priority: priority,
                                                   status: status)
        
        message.timestamp = Date().timeIntervalSince1970
        message.messageId = UUID.init().uuidString
        return message
    }
}

struct triprAPIRequestMessage : TriprAPIRequestMessageData {
    var messageId: String
    var timestamp: Double
    var payload: String
    var URL: String
    var priority: TriprAPIMessagePriority
    var reference : String?
    var attachment : Data?
    var APIKey: String?
    
    init(payload: String, attachment : Data? = nil, reference : String? = nil, URL : String, priority : TriprAPIMessagePriority) {
        self.timestamp = Date().timeIntervalSince1970
        self.payload = payload
        self.URL = URL
        self.priority = priority
        self.reference = reference
        self.attachment = attachment
        self.messageId = UUID.init().uuidString
        self.APIKey = ""
    }
}



