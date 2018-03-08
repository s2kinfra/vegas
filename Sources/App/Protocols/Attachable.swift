//
//  FileHandling.swift
//  App
//
//  Created by Daniel Skevarp on 2017-09-26.
//

import Foundation
import Vapor
import FluentProvider

protocol Attachable : ObjectIdentifiable {
    
    var attachments : [Attachment] {get}
    func addAttachment(file _file : File) throws -> Attachment
    func removeAttachment(file _file : File) throws
    func removeAttachment(attachment : Attachment) throws
    
}

extension Attachable {
    
    var attachments : [Attachment] {
        get {
            guard let attachments = try? Attachment.makeQuery().and({ andGroup in
                try andGroup.filter("object", .equals, objectType)
                try andGroup.filter("objectId", .equals, objectIdentifier)
            }).all() else {
                return [Attachment]()
            }
            return attachments
        }
    }
    
    func addAttachment(file _file: File) throws -> Attachment{
        let attachment = Attachment.init(file: _file.id!, object: self.objectType, objectId: self.objectIdentifier)
        try attachment.save()
        return attachment
    }
 
    func removeAttachment(attachment : Attachment) throws {
        try attachment.delete()
    }
    
    func removeAttachment(file _file : File) throws {
        guard let attachment = try Attachment.makeQuery().and({ andGroup in
            try andGroup.filter("object", .equals, objectType)
            try andGroup.filter("objectId", .equals, objectIdentifier)
            try andGroup.filter("file", .equals, _file.id!)
        }).first() else {
            //            TODO: update throw to proper throw
            throw Abort.badRequest
        }
       try attachment.delete()
    }
}
