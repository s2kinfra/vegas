//
//  RequestExtensions.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-01.
//

import Foundation

extension Request {
    func getAPIRequestMessage() throws -> triprAPIRequestMessage {
        guard let messageId = self.data["messageId"]?.string else {
            throw TriprAPIMessageError.missingData(field: "MessageId")
        }
        
        
        guard let payload = self.json!["payload"] else {
            print("no payload")
            throw TriprAPIMessageError.missingData(field: "payload")
            
        }
        guard let timestamp = self.data["timestamp"]?.double else {
            print("no timestamp")
            throw TriprAPIMessageError.missingData(field: "timestamp")
        }
        
        var requestMessage = triprAPIRequestMessage.init(payload: try payload.asString(), URL: self.uri.path, priority: .medium)
        
        
        if let attachment = self.data["attachment"]?.string {
            print("no attachment which is fine")
            requestMessage.attachment = attachment.data(using: .utf8)
        }
        
        if let reference = self.data["reference"]?.string {
            print("no reference which is fine")
            requestMessage.reference = reference
        }
        
        
        requestMessage.timestamp = timestamp
        requestMessage.messageId = messageId
        
        
        return requestMessage
    }
}

extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}



