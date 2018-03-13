//
//  DestinationController.swift
//  App
//
//  Created by Daniel Skevarp on 2018-03-12.
//


import Foundation
import Vapor
import HTTP
import AuthProvider
import MySQL



final class DestinationController : SuperController {
    
    func getDestination() throws -> ResponseRepresentable {
        let user = try self.request.user()
        guard let dest = try? self.request.parameters.next(Destination.self) else {
            return try self.createResponse(payload: "", status: (.error, "Destination doesnt exists"))
        }
        return try dest.getDestinationDataForUser(user: user)
    }
    
    func updateDestination() throws -> ResponseRepresentable {
        let user = try request.user()
        guard let dest = try? request.parameters.next(Destination.self) else {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, "Dest doesnt exists"))
        }
        
        try dest.updateDestinationFromJSON((self.message?.payload.asJSON())!)
        dest.createFeedData(feedObjectType: dest.objectType, feedObjectId: dest.objectIdentifier, timestamp: Date().timeIntervalSinceNow, feedType: .destinationUpdated)
        
        /// Save an return the updated trip.
        try dest.save()
        
        ///create , save and add the destination image if it exists
        if let json = try self.message?.payload.asJSON() {
            do{
                let destImage = try json.get("destinationImage") as attachmentPayload
                print(destImage)
                guard let base64data = Data(base64Encoded: destImage.base64, options: .ignoreUnknownCharacters) else {
                    throw TriprAPIMessageError.invalidData(field: "destinationImage")
                }
                let file = try FileHandler.uploadBase64File(user:user, file: base64data, filename: destImage.filename)
                dest.destinationImage = file.id?.int
                try dest.save()
            }catch{
                    //No new image so lets just continue
            }
        }
        
        ///check if its connect to a trip then notify and make feed.
        if let trip = dest.getDestinationsTrip() {
            try trip.notifyFollowers(notificationType: .DestinationUpdated, parameters: [(paramId : 1, relatedObject: dest.objectType, relatedObjectId: dest.objectIdentifier.int!)])
            
            try trip.createFeedForMe(feedObjectType: dest.objectType, feedObjectId: dest.objectIdentifier, timestamp: Date().timeIntervalSince1970, feedType: .destinationUpdated)
        }
        
        return try self.createResponse(payload: try dest.getDestinationDataForUser(user: user), status: (.ok, "Destination updated successfully"))
    }
    
    func createNewDestination() throws -> ResponseRepresentable {
        do {
            let me = try self.request.user()
            let destData = try createNewDestinationPayload.init(json: (self.message?.payload.asJSON())!)
            
            let dest = try Destination.createNewDestination(arrivalDate: destData.arrivalDate,
                                                            departureDate: destData.departureDate,
                                                            isPrivate: destData.isPrivate,
                                                            creator: me,
                                                            trip: nil,
                                                            name: destData.name)
            
            var myFollowers = [User]()
            for follower in (me.followers) {
                let user = try follower.getFollowerUser()
                myFollowers.append(user)
            }
            
            try me.createFeedData(feedObjectType: dest.objectType, feedObjectId: dest.objectIdentifier, timestamp: Date().timeIntervalSince1970, feedType: .destinationCreated, users: myFollowers)
            
            if let image = destData.destinationImage {
                guard let base64data = Data(base64Encoded: image.base64, options: .ignoreUnknownCharacters) else {
                    throw TriprAPIMessageError.invalidData(field: "destinationImage")
                }
                let file = try FileHandler.uploadBase64File(user:me, file: base64data, filename: image.filename)
                dest.destinationImage = file.id?.int
                try dest.save()
            }
            
            return try self.createResponse(payload: try dest.makeJSON(), status: (.ok, "Destination created"))
            
        }catch let error as TriprAPIMessageError{
            return try self.createResponse(payload: "", status: (.error, error.getErrorCode()))
        }catch let error as MySQLError {
            var errorReason = error.reason
            if error.code == MySQL.MySQLError.Code.dupEntry {
                errorReason = "Destination already exists"
            }
            return try self.createResponse(payload: "", status: (.error, errorReason))
        }
        
    }
    
}


